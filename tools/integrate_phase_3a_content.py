#!/usr/bin/env python3
"""Audit the local Keri PNG template set and apply the Phase 3A content mapping."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
from datetime import date
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = Path(
    "C:/Users/ADMIN/Desktop/keri_asset_audit/01_extracted_original/"
    "Keri-Dressup-RenPy-Template/Keri-Dressup-RenPy-Template/game/Create_Character"
)
INVENTORY_PATH = ROOT / "docs/asset_audits/keri/PHASE_3A_CONTENT_INVENTORY.json"
PHASE_2C_INVENTORY = ROOT / "docs/asset_audits/keri/PHASE_2C_APPEARANCE_INVENTORY.json"
CATALOG_PATH = ROOT / "data/catalog.json"
VISIBLE_BOTTOM = 1660
PROVENANCE = (
    "Local extracted PNG source/template set; Konett original Keri material and "
    "LunaLucid/Namastaii Ren'Py template/adaptation; attribution and license caveats retained."
)

TOP_NAMES = {
    1: "Áo dáng dài",
    2: "Áo phối lớp",
    3: "Áo quây dáng dài",
    4: "Áo lệch tà tay ngắn",
    5: "Áo lệch tà tay dài",
}
EXISTING_RUNTIME = {
    "Tops/top1_1.png": "assets/characters/keri/proof/keri_fallback_top.png",
    "Tops/top2_1.png": "assets/tops/keri/proof/top_casual_02.png",
    "Tops/top3_1.png": "assets/tops/keri/proof/top_casual_01.png",
    "Bottoms/bottom2_1.png": "assets/characters/keri/proof/keri_fallback_bottom.png",
    "Bottoms/bottom2_2.png": "assets/bottoms/keri/proof/bottom_shorts_02.png",
    "Bottoms/bottom2_3.png": "assets/bottoms/keri/proof/bottom_shorts_01.png",
}
EXISTING_ITEM_IDS = {
    "Tops/top2_1.png": "top_keri_casual_02",
    "Tops/top3_1.png": "top_keri_casual_01",
    "Bottoms/bottom2_2.png": "bottom_keri_shorts_02",
    "Bottoms/bottom2_3.png": "bottom_keri_shorts_01",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def rect_from_bbox(bbox: tuple[int, int, int, int] | None) -> list[int]:
    if bbox is None:
        return [0, 0, 0, 0]
    left, top, right, bottom = bbox
    return [left, top, right - left, bottom - top]


def parse_variant(file_name: str) -> tuple[int | None, int | None]:
    match = re.search(r"(\d+)(?:_(\d+))?\.[Pp][Nn][Gg]$", file_name)
    if not match:
        return None, None
    return int(match.group(1)), int(match.group(2)) if match.group(2) else None


def phase_2c_destinations() -> dict[str, str]:
    data = json.loads(PHASE_2C_INVENTORY.read_text(encoding="utf-8"))
    return {
        str(Path(entry["source_path"]).resolve()).lower(): str(entry.get("destination_path", ""))
        for entry in data.get("assets", [])
    }


def classify(path: Path, source: Path, bbox: tuple[int, int, int, int] | None, phase_2c: dict[str, str]) -> dict:
    relative = path.relative_to(source).as_posix()
    group = path.parent.name
    style, color = parse_variant(path.name)
    bottom = bbox[3] if bbox else 0
    destination = ""
    existing_runtime_mapping = ""
    category = ""
    layer_role = ""
    content_type = group.lower()
    style_id = f"style_{style:02d}" if style is not None else ""
    color_id = f"color_{color:02d}" if color is not None else ""
    variant_group = ""
    compatible = True
    reason = "948x1920 RGBA layer on the shared Keri origin and canvas."
    decision = "exclude"
    crop_risk = "low"

    if group == "Tops":
        content_type, category, layer_role = "top", "top", "top"
        variant_group = f"keri_top_style_{style:02d}"
        if relative == "Tops/top1_1.png":
            destination = existing_runtime_mapping = EXISTING_RUNTIME[relative]
            decision = "exclude_duplicate_renderer_fallback"
            reason += " Byte-identical source is reserved as the immutable renderer fallback top."
        elif relative in EXISTING_ITEM_IDS:
            destination = existing_runtime_mapping = EXISTING_RUNTIME[relative]
            decision = "include_existing_runtime"
        else:
            destination = f"assets/clothing/keri/tops/top_style_{style:02d}_color_{color:02d}.png"
            decision = "include_new_runtime"
    elif group == "Bottoms":
        category, layer_role = "bottom", "bottom"
        if style == 1:
            content_type = "long_trousers"
            variant_group = "keri_long_trousers_style_01"
            destination = f"assets/clothing/keri/bottoms/trousers_style_01_color_{color:02d}.png"
            decision, crop_risk = "include_new_runtime", "viewport_continuation"
            reason += (
                f" Long trouser legs continue below the y={VISIBLE_BOTTOM} viewport, but the audited viewport shows "
                "a natural uninterrupted garment with aligned waist and no exposed cut seam."
            )
        elif style == 2:
            content_type = "shorts"
            variant_group = "keri_shorts_style_01"
            if relative == "Bottoms/bottom2_1.png":
                destination = existing_runtime_mapping = EXISTING_RUNTIME[relative]
                decision = "exclude_duplicate_renderer_fallback"
                reason += " Byte-identical source is reserved as the immutable renderer fallback bottom."
            elif relative in EXISTING_ITEM_IDS:
                destination = existing_runtime_mapping = EXISTING_RUNTIME[relative]
                decision = "include_existing_runtime"
            else:
                destination = f"assets/clothing/keri/bottoms/shorts_style_01_color_{color:02d}.png"
                decision = "include_new_runtime"
        else:
            content_type = "skirt"
            variant_group = "keri_skirt_style_01"
            destination = f"assets/clothing/keri/bottoms/skirt_style_01_color_{color:02d}.png"
            decision, crop_risk = "include_new_runtime", "viewport_continuation"
            reason += (
                f" Skirt art continues to y={bottom}, below the y={VISIBLE_BOTTOM} viewport, but the audited viewport "
                "shows an intentional flowing continuation with aligned waist and no exposed cut seam."
            )
    elif group in {"Base", "Hair", "Eyes", "Eyebrows", "Mouth"} or (
        group == "Misc" and path.name.lower().startswith("blush")
    ):
        content_type = {"Base": "skin", "Hair": "hair", "Eyes": "eyes", "Eyebrows": "eyebrows", "Mouth": "mouth", "Misc": "makeup"}[group]
        category = content_type
        layer_role = "body_core" if group == "Base" else ("hair_front" if group == "Hair" else category)
        destination = existing_runtime_mapping = phase_2c.get(str(path.resolve()).lower(), "")
        decision = "already_integrated_phase_2c"
        reason += " This appearance layer was integrated and audited in Phase 2C."
    else:
        content_type, category, layer_role = "face_effect", "face_effect", "face_effect"
        lower_name = path.name.lower()
        if lower_name == "sweat.png":
            style_id, color_id = "sweat", "variant_01"
            variant_group, destination = "keri_face_effect_sweat", "assets/face/keri/effects/sweat_01.png"
        elif lower_name in {"tears.png", "tears1.png"}:
            style_id, color_id = "tears_style_01", "base"
            variant_group, destination = "keri_face_effect_tears_style_01", "assets/face/keri/effects/tears_style_01_base.png"
        elif lower_name.startswith("tears1_"):
            variant = int(re.search(r"_(\d+)", lower_name).group(1))
            style_id, color_id = "tears_style_01", f"variant_{variant:02d}"
            variant_group = "keri_face_effect_tears_style_01"
            destination = f"assets/face/keri/effects/tears_style_01_variant_{variant:02d}.png"
        elif lower_name == "tears2.png":
            style_id, color_id = "tears_style_02", "base"
            variant_group, destination = "keri_face_effect_tears_style_02", "assets/face/keri/effects/tears_style_02_base.png"
        else:
            variant = int(re.search(r"_(\d+)", lower_name).group(1))
            style_id, color_id = "tears_style_02", f"variant_{variant:02d}"
            variant_group = "keri_face_effect_tears_style_02"
            destination = f"assets/face/keri/effects/tears_style_02_variant_{variant:02d}.png"
        if lower_name == "tears1.png":
            compatible, decision = False, "exclude_exact_duplicate"
            existing_runtime_mapping = "assets/face/keri/effects/tears_style_01_base.png"
            reason = "Byte-identical duplicate of Misc/tears.png; excluded to avoid two indistinguishable runtime choices."
        else:
            decision = "include_new_runtime"
            reason += " Alpha content is confined to the face region and aligns with the audited eyes and cheeks."

    return {
        "inferred_content_type": content_type,
        "inferred_runtime_category": category,
        "inferred_layer_role": layer_role,
        "style_id": style_id,
        "color_id": color_id,
        "variant_group": variant_group,
        "existing_runtime_mapping": existing_runtime_mapping,
        "compatible": compatible,
        "compatibility_reason": reason,
        "include_phase_3a": decision in {"include_existing_runtime", "include_new_runtime"},
        "phase_3a_decision": decision,
        "destination_path": destination,
        "crop_risk": crop_risk,
        "manual_QA_required": decision in {"include_existing_runtime", "include_new_runtime"},
        "provenance_note": PROVENANCE,
    }


def build_inventory(source: Path) -> list[dict]:
    phase_2c = phase_2c_destinations()
    assets: list[dict] = []
    for path in sorted(source.rglob("*"), key=lambda value: str(value).lower()):
        if not path.is_file() or path.suffix.lower() != ".png":
            continue
        with Image.open(path) as image:
            alpha = image.getchannel("A") if image.mode == "RGBA" else None
            bbox = alpha.getbbox() if alpha is not None else None
            entry = {
                "source_path": str(path), "file_name": path.name, "sha256": sha256(path),
                "width": image.width, "height": image.height, "mode": image.mode,
                "alpha": alpha is not None, "visible_bounds": list(bbox) if bbox else [],
                "source_group": path.parent.name,
            }
        entry.update(classify(path, source, bbox, phase_2c))
        assets.append(entry)
    return assets


def copy_new_runtime_assets(assets: list[dict]) -> None:
    for entry in assets:
        if entry["phase_3a_decision"] != "include_new_runtime":
            continue
        source_path = Path(entry["source_path"])
        destination = ROOT / entry["destination_path"]
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source_path, destination)
        if sha256(destination) != entry["sha256"]:
            raise RuntimeError(f"Copied PNG hash mismatch: {destination}")


def item_metadata(entry: dict, item_id: str) -> dict:
    relative = Path(entry["source_path"]).as_posix()
    style, color = parse_variant(entry["file_name"])
    content_type = entry["inferred_content_type"]
    is_top, is_effect = content_type == "top", content_type == "face_effect"
    category = "face_effect" if is_effect else ("top" if is_top else "bottom")
    if is_top:
        display, order = f"{TOP_NAMES[style]} - màu {color:02d}", style * 100 + color
    elif content_type == "shorts":
        display, order = f"Quần short - màu {color:02d}", 100 + color
    elif content_type == "long_trousers":
        display, order = f"Quần dài - màu {color:02d}", 300 + color
    elif content_type == "skirt":
        display, order = f"Chân váy - màu {color:02d}", 400 + color
    else:
        display = "Mồ hôi" if entry["style_id"] == "sweat" else f"Nước mắt {entry['style_id'][-2:]} - {entry['color_id']}"
        order = 500 + len(relative)
    item = {
        "id": item_id, "category": category, "display_name": display, "accessible_name": display,
        "description": "Layer Keri dùng canvas gốc 948x1920, không scale/crop/warp.",
        "render_key": "png", "random_enabled": not is_effect, "order": order, "occupies": [category],
        "tags": ["keri_product", category, entry["style_id"]], "conflicts_with_tags": [],
        "layers": {category: f"res://{entry['destination_path']}"}, "placeholder": {},
        "preview_mode": "effect_crop" if is_effect else ("top_crop" if is_top else "bottom_crop"),
        "preview_rect": rect_from_bbox(tuple(entry["visible_bounds"])),
        "preview_padding_ratio": 0.16 if is_effect else 0.08,
        "preview_background": "#f1dfd4" if is_effect else "#f7f1f5",
        "style_id": entry["style_id"], "color_id": entry["color_id"], "variant_group": entry["variant_group"],
        "source_sha256": entry["sha256"], "source_file": relative.split("/Create_Character/")[-1],
    }
    if not is_top and not is_effect:
        item["ui_group"] = "trousers" if content_type == "long_trousers" else content_type
    return item


def item_id_for(entry: dict, source: Path) -> str:
    relative = Path(entry["source_path"]).relative_to(source).as_posix()
    if relative in EXISTING_ITEM_IDS:
        return EXISTING_ITEM_IDS[relative]
    style, color = parse_variant(entry["file_name"])
    content_type = entry["inferred_content_type"]
    if content_type == "top":
        return f"top_keri_style_{style:02d}_color_{color:02d}"
    if content_type == "shorts":
        return f"bottom_keri_shorts_color_{color:02d}"
    if content_type == "long_trousers":
        return f"bottom_keri_trousers_color_{color:02d}"
    if content_type == "skirt":
        return f"bottom_keri_skirt_color_{color:02d}"
    return "face_effect_" + Path(entry["destination_path"]).stem


def update_catalog(source: Path, assets: list[dict]) -> None:
    data = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    data["schema_version"] = 3
    character = data["character"]
    layer_order = character["layer_order"]
    if "face_effect" not in layer_order:
        layer_order.insert(layer_order.index("hair_front"), "face_effect")
    face_categories = character["face_feature_categories"]
    if "face_effect" not in face_categories:
        face_categories.append("face_effect")
    layers_after = character["face_import_metadata"]["layers_after_imported_face"]
    if "face_effect" not in layers_after:
        layers_after.insert(layers_after.index("hair_front"), "face_effect")

    categories = {category["id"]: category for category in data["categories"]}
    bottom_category = categories["bottom"]
    bottom_category["item_groups"] = [
        {"id": "shorts", "display_name": "Quần short", "order": 10},
        {"id": "trousers", "display_name": "Quần dài", "order": 20},
        {"id": "skirt", "display_name": "Chân váy", "order": 30},
    ]
    face_category = categories["face"]
    if "face_effect" not in face_category["subcategory_ids"]:
        face_category["subcategory_ids"].append("face_effect")
    if "face_effect" not in categories:
        data["categories"].append({
            "id": "face_effect", "display_name": "Hiệu ứng",
            "description": "Nước mắt và mồ hôi độc lập trên vùng mặt.",
            "allow_none": True, "random_default": False, "order": 21,
            "hidden": False, "parent_category": "face",
        })
    else:
        categories["face_effect"]["random_default"] = False

    by_id = {item["id"]: index for index, item in enumerate(data["items"])}
    data["items"][by_id["bottom_none"]]["show_in_all_groups"] = True
    if "effect_none" not in by_id:
        by_id["effect_none"] = len(data["items"])
        data["items"].append({
            "id": "effect_none", "category": "face_effect", "display_name": "Không hiệu ứng",
            "accessible_name": "Không hiệu ứng khuôn mặt", "description": "Tắt nước mắt và mồ hôi.",
            "render_key": "none", "random_enabled": True, "order": 0, "occupies": [],
            "tags": ["none"], "conflicts_with_tags": [], "layers": {}, "placeholder": {},
        })
    for entry in assets:
        if entry["phase_3a_decision"] not in {"include_existing_runtime", "include_new_runtime"}:
            continue
        item_id = item_id_for(entry, source)
        item = item_metadata(entry, item_id)
        if item_id in by_id:
            data["items"][by_id[item_id]] = item
        else:
            by_id[item_id] = len(data["items"])
            data["items"].append(item)
    data["initial_state"]["background"] = "background_none"
    data["initial_state"]["face_effect"] = "effect_none"
    CATALOG_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def write_inventory(source: Path, assets: list[dict]) -> None:
    payload = {
        "source_label": "local extracted PNG source/template set", "source_root": str(source),
        "audit_date": date.today().isoformat(), "canvas_size": [948, 1920],
        "visible_canvas_rect": [0, 0, 948, VISIBLE_BOTTOM],
        "visible_bounds_format": ["left", "top", "right_exclusive", "bottom_exclusive"],
        "asset_count": len(assets), "assets": assets,
    }
    INVENTORY_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--apply", action="store_true", help="Copy accepted PNGs and update data/catalog.json")
    args = parser.parse_args()
    source = args.source.resolve()
    if not source.is_dir():
        raise SystemExit(f"Source directory not found: {source}")
    assets = build_inventory(source)
    if len(assets) != 184:
        raise SystemExit(f"Expected 184 audited PNGs, found {len(assets)}")
    write_inventory(source, assets)
    if args.apply:
        copy_new_runtime_assets(assets)
        update_catalog(source, assets)
    decisions: dict[str, int] = {}
    for entry in assets:
        key = entry["phase_3a_decision"]
        decisions[key] = decisions.get(key, 0) + 1
    print(f"Audited {len(assets)} PNGs: {json.dumps(decisions, sort_keys=True)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
