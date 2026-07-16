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
    category = ""
    layer_role = ""
    compatible = True
    reason = "948x1920 RGBA layer on the shared Keri origin and canvas."
    decision = "exclude"
    crop_risk = "low"

    if group == "Tops":
        category = "top"
        layer_role = "top"
        if relative == "Tops/top1_1.png":
            destination = EXISTING_RUNTIME[relative]
            decision = "exclude_duplicate_renderer_fallback"
            reason += " Byte-identical source is reserved as the immutable renderer fallback top."
        elif relative in EXISTING_ITEM_IDS:
            destination = EXISTING_RUNTIME[relative]
            decision = "include_existing_runtime"
        else:
            destination = f"assets/clothing/keri/tops/top_style_{style:02d}_color_{color:02d}.png"
            decision = "include_new_runtime"
    elif group == "Bottoms":
        layer_role = "bottom"
        if style == 1:
            category = "bottom_long_trousers"
            compatible = False
            crop_risk = "critical"
            reason = "Long trousers reach the 1920px canvas edge and depend on missing lower legs/feet outside the MVP crop."
        elif style == 2:
            category = "bottom_shorts"
            if relative == "Bottoms/bottom2_1.png":
                destination = EXISTING_RUNTIME[relative]
                decision = "exclude_duplicate_renderer_fallback"
                reason += " Byte-identical source is reserved as the immutable renderer fallback bottom."
            elif relative in EXISTING_ITEM_IDS:
                destination = EXISTING_RUNTIME[relative]
                decision = "include_existing_runtime"
            else:
                destination = f"assets/clothing/keri/bottoms/shorts_style_01_color_{color:02d}.png"
                decision = "include_new_runtime"
        else:
            category = "bottom_skirt"
            compatible = False
            crop_risk = "high"
            reason = (
                f"Skirt visible bounds extend to y={bottom}, below the current y={VISIBLE_BOTTOM} three-quarter crop; "
                "the hem would be visibly cut."
            )
    elif group in {"Base", "Hair", "Eyes", "Eyebrows", "Mouth"} or (
        group == "Misc" and path.name.lower().startswith("blush")
    ):
        category = {
            "Base": "skin",
            "Hair": "hair",
            "Eyes": "eyes",
            "Eyebrows": "eyebrows",
            "Mouth": "mouth",
            "Misc": "makeup",
        }[group]
        layer_role = "body_core" if group == "Base" else ("hair_front" if group == "Hair" else category)
        destination = phase_2c.get(str(path.resolve()).lower(), "")
        decision = "already_integrated_phase_2c"
        reason += " This appearance layer was integrated and audited in Phase 2C."
    else:
        category = "face_effect"
        layer_role = "effect_front"
        compatible = False
        reason = "Expression tears/sweat effect is outside Phase 3A product slots and includes redundant effect variants."

    return {
        "inferred_runtime_category": category,
        "inferred_layer_role": layer_role,
        "style_group": f"style_{style:02d}" if style is not None else "",
        "color_variant": f"color_{color:02d}" if color is not None else "",
        "compatible": compatible,
        "compatibility_reason": reason,
        "phase_3a_include_exclude": decision,
        "destination_path": destination,
        "provenance_note": PROVENANCE,
        "crop_risk": crop_risk,
        "manual_QA_required": decision in {"include_existing_runtime", "include_new_runtime"},
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
                "source_path": str(path),
                "file_name": path.name,
                "sha256": sha256(path),
                "width": image.width,
                "height": image.height,
                "mode": image.mode,
                "alpha": alpha is not None,
                "visible_bounds": list(bbox) if bbox is not None else [],
                "source_group": path.parent.name,
            }
        entry.update(classify(path, source, bbox, phase_2c))
        assets.append(entry)
    return assets


def copy_new_runtime_assets(source: Path, assets: list[dict]) -> None:
    for entry in assets:
        if entry["phase_3a_include_exclude"] != "include_new_runtime":
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
    is_top = entry["source_group"] == "Tops"
    category = "top" if is_top else "bottom"
    display = f"{TOP_NAMES[style]} - màu {color:02d}" if is_top else f"Quần short - màu {color:02d}"
    preview_rect = rect_from_bbox(tuple(entry["visible_bounds"]))
    return {
        "id": item_id,
        "category": category,
        "display_name": display,
        "accessible_name": display,
        "description": "Trang phục Keri dùng canvas gốc 948x1920, không scale/crop/warp.",
        "render_key": "png",
        "random_enabled": True,
        "order": style * 100 + color if is_top else 100 + color,
        "occupies": [category],
        "tags": ["keri_product", category, f"style_{style:02d}"],
        "conflicts_with_tags": [],
        "layers": {category: f"res://{entry['destination_path']}"},
        "placeholder": {},
        "preview_mode": "top_crop" if is_top else "bottom_crop",
        "preview_rect": preview_rect,
        "preview_padding_ratio": 0.08,
        "preview_background": "#f7f1f5",
        "style_id": f"{category}_style_{style:02d}" if is_top else "shorts_style_01",
        "color_id": f"color_{color:02d}",
        "variant_group": f"keri_{category}_style_{style:02d}" if is_top else "keri_shorts_style_01",
        "source_sha256": entry["sha256"],
        "source_file": relative.split("/Create_Character/")[-1],
    }


def item_id_for(entry: dict, source: Path) -> str:
    relative = Path(entry["source_path"]).relative_to(source).as_posix()
    if relative in EXISTING_ITEM_IDS:
        return EXISTING_ITEM_IDS[relative]
    style, color = parse_variant(entry["file_name"])
    if entry["source_group"] == "Tops":
        return f"top_keri_style_{style:02d}_color_{color:02d}"
    return f"bottom_keri_shorts_color_{color:02d}"


def update_catalog(source: Path, assets: list[dict]) -> None:
    data = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    by_id = {item["id"]: index for index, item in enumerate(data["items"])}
    for entry in assets:
        if entry["phase_3a_include_exclude"] not in {"include_existing_runtime", "include_new_runtime"}:
            continue
        item_id = item_id_for(entry, source)
        item = item_metadata(entry, item_id)
        if item_id in by_id:
            data["items"][by_id[item_id]] = item
        else:
            by_id[item_id] = len(data["items"])
            data["items"].append(item)
    data["initial_state"]["background"] = "background_none"
    CATALOG_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def write_inventory(source: Path, assets: list[dict]) -> None:
    payload = {
        "source_label": "local extracted PNG source/template set",
        "source_root": str(source),
        "audit_date": date.today().isoformat(),
        "canvas_size": [948, 1920],
        "visible_canvas_rect": [0, 0, 948, VISIBLE_BOTTOM],
        "visible_bounds_format": ["left", "top", "right_exclusive", "bottom_exclusive"],
        "asset_count": len(assets),
        "assets": assets,
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
        copy_new_runtime_assets(source, assets)
        update_catalog(source, assets)
    decisions: dict[str, int] = {}
    for entry in assets:
        key = entry["phase_3a_include_exclude"]
        decisions[key] = decisions.get(key, 0) + 1
    print(f"Audited {len(assets)} PNGs: {json.dumps(decisions, sort_keys=True)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
