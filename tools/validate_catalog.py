#!/usr/bin/env python3
"""Dependency-free validation for data/catalog.json."""
from __future__ import annotations

import json
import sys
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "data" / "catalog.json"
KERI_PROOF_CANVAS = [948, 1920]
DEFAULT_CANVAS = [1024, 1536]
KERI_FORBIDDEN_FLATTENED_BODY = "res://assets/characters/keri/proof/keri_clothed_base.png"
KERI_INTERNAL_LAYERS = {
    "body_core": (
        "res://assets/characters/keri/proof/keri_body_core.png",
        "555132e38e2ec9efbdbf1e2e034f32fab36f01752e264457daed5993a578386c",
    ),
    "fallback_top": (
        "res://assets/characters/keri/proof/keri_fallback_top.png",
        "3d21587ec7bd3b19d7e9d18676eb39ff784a5d1083c9110915414fa868f58f9d",
    ),
    "fallback_bottom": (
        "res://assets/characters/keri/proof/keri_fallback_bottom.png",
        "6a112916adfca3d721c6600d95b66b7f6e7be124ef1727203bb182cd73c24a3b",
    ),
}
KERI_SKIN_VARIANTS = {
    "skin_tone_01": (
        "res://assets/characters/keri/proof/keri_body_core.png",
        "555132e38e2ec9efbdbf1e2e034f32fab36f01752e264457daed5993a578386c",
    ),
    "skin_tone_02": (
        "res://assets/characters/keri/skins/skin_tone_02.png",
        "acaf24d1ed69c6a6081c16c50f58f2451f4f65745f242dc80ca0bf45dec3f433",
    ),
    "skin_tone_03": (
        "res://assets/characters/keri/skins/skin_tone_03.png",
        "e527f14ccdd6fa9452d5a6078eed9bb8cc5341e4ddccd1e6252f72cfc7a0aaae",
    ),
    "skin_tone_04": (
        "res://assets/characters/keri/skins/skin_tone_04.png",
        "9894628e3eb2367cc644f1df525b36d6eeeb9df6063e11dcd3473c1e2b1c374a",
    ),
    "skin_tone_05": (
        "res://assets/characters/keri/skins/skin_tone_05.png",
        "a9e1847597569ec1a354058c7daaa99523ef95233927061566afc4cea7a24f04",
    ),
}


def main() -> int:
    errors: list[str] = []
    try:
        data = json.loads(CATALOG.read_text(encoding="utf-8"))
    except Exception as exc:
        print(f"ERROR: cannot parse {CATALOG}: {exc}", file=sys.stderr)
        return 1

    categories = data.get("categories", [])
    items = data.get("items", [])
    initial = data.get("initial_state", {})

    category_ids = [str(c.get("id", "")) for c in categories]
    if len(category_ids) != len(set(category_ids)):
        errors.append("Duplicate category IDs found.")
    if any(not value for value in category_ids):
        errors.append("Every category needs a non-empty ID.")

    item_ids = [str(i.get("id", "")) for i in items]
    if len(item_ids) != len(set(item_ids)):
        errors.append("Duplicate item IDs found.")
    if any(not value for value in item_ids):
        errors.append("Every item needs a non-empty ID.")

    by_id = {str(item.get("id")): item for item in items}
    by_category_metadata = {str(category.get("id")): category for category in categories}
    by_category: dict[str, list[dict]] = {category_id: [] for category_id in category_ids}
    for item in items:
        category_id = str(item.get("category", ""))
        if category_id not in by_category:
            errors.append(f"Item {item.get('id')} uses unknown category {category_id!r}.")
            continue
        by_category[category_id].append(item)
        layers = item.get("layers", {})
        if not isinstance(layers, dict):
            errors.append(f"Item {item.get('id')} layers must be an object.")
        for path in layers.values() if isinstance(layers, dict) else []:
            if not str(path).startswith("res://"):
                errors.append(f"Item {item.get('id')} layer path must start with res://: {path}")
                continue
            if str(path) == KERI_FORBIDDEN_FLATTENED_BODY:
                errors.append(f"Item {item.get('id')} must not reference flattened Keri clothed composite.")
            _validate_layer_png(errors, f"Item {item.get('id')}", str(path), data)
        thumbnail_path = str(item.get("thumbnail_path", "")).strip()
        if thumbnail_path and not thumbnail_path.startswith("res://"):
            errors.append(f"Item {item.get('id')} thumbnail_path must start with res://: {thumbnail_path}")
        if "preview_rect" in item:
            _validate_canvas_rect(errors, f"Item {item.get('id')} preview_rect", item.get("preview_rect"), data.get("character", {}).get("canvas_size", []))

    for category in categories:
        category_id = str(category["id"])
        if not by_category.get(category_id):
            errors.append(f"Category {category_id} has no items.")
        if category.get("allow_none"):
            if not any(item.get("render_key") == "none" for item in by_category.get(category_id, [])):
                errors.append(f"Category {category_id} allows none but has no none item.")
        selected_id = str(initial.get(category_id, ""))
        if selected_id not in by_id:
            errors.append(f"Initial state for {category_id} points to missing item {selected_id!r}.")
        elif str(by_id[selected_id].get("category")) != category_id:
            errors.append(f"Initial item {selected_id} is not in category {category_id}.")

    if int(data.get("schema_version", 0)) < 2:
        errors.append("Phase 2C catalog schema_version must be at least 2.")
    _validate_phase_2c_categories(errors, by_category, by_category_metadata, by_id)

    character = data.get("character", {})
    if character.get("mode") not in {"procedural", "png"}:
        errors.append("character.mode must be procedural or png.")
    character_canvas = character.get("canvas_size")
    if character_canvas not in [DEFAULT_CANVAS, KERI_PROOF_CANVAS]:
        errors.append("character.canvas_size must be 1024x1536 or the Keri proof canvas 948x1920.")
    character_layers = character.get("layers", {})
    if not isinstance(character_layers, dict):
        errors.append("character.layers must be an object.")
    elif character.get("id") == "keri_three_quarter_proof":
        for layer_name, (expected_path, expected_hash) in KERI_INTERNAL_LAYERS.items():
            actual_path = str(character_layers.get(layer_name, ""))
            if actual_path != expected_path:
                errors.append(f"Keri proof {layer_name} must reference {expected_path}, not {actual_path!r}.")
            elif _sha256(_resolve_res_path(actual_path)) != expected_hash:
                errors.append(f"Keri proof {layer_name} hash must be {expected_hash}.")
        if KERI_FORBIDDEN_FLATTENED_BODY in character_layers.values():
            errors.append("Flattened Keri clothed composite must not be referenced by character.layers.")
    for layer_name, path in character_layers.items() if isinstance(character_layers, dict) else []:
        if not str(path).startswith("res://"):
            errors.append(f"Character layer {layer_name} path must start with res://: {path}")
            continue
        _validate_layer_png(errors, f"Character layer {layer_name}", str(path), data)

    _validate_phase_2c_character(errors, data, by_id)

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(f"Catalog valid: {len(categories)} categories, {len(items)} items.")
    return 0


def _validate_phase_2c_categories(
    errors: list[str],
    by_category: dict[str, list[dict]],
    category_metadata: dict[str, dict],
    by_id: dict[str, dict],
) -> None:
    required = {"skin", "hair", "eyes", "eyebrows", "mouth", "makeup", "face"}
    missing = sorted(required.difference(by_category))
    if missing:
        errors.append(f"Missing Phase 2C categories: {missing}.")
        return

    if any(str(item.get("render_key", "")) == "none" for item in by_category["skin"]):
        errors.append("Mandatory skin category must not contain a none item.")
    for category_id in ("hair", "eyes", "eyebrows", "mouth", "makeup", "face", "background"):
        if not any(str(item.get("render_key", "")) == "none" for item in by_category.get(category_id, [])):
            errors.append(f"Optional category {category_id} must contain a none item.")

    face = category_metadata.get("face", {})
    expected_subcategories = ["skin", "eyes", "eyebrows", "mouth", "makeup"]
    if not bool(face.get("ui_container", False)) or face.get("subcategory_ids") != expected_subcategories:
        errors.append("Face UI container must declare the non-empty Phase 2C subcategory order.")
    for category_id in expected_subcategories:
        if str(category_metadata.get(category_id, {}).get("parent_category", "")) != "face":
            errors.append(f"Category {category_id} must be a face subcategory.")
    if "eyelashes" in category_metadata:
        errors.append("Eyelashes category must stay absent because the audited local source has no eyelash PNGs.")

    legacy_face = by_id.get("face_keri_default_01", {})
    if not bool(legacy_face.get("hidden", False)) or not bool(legacy_face.get("legacy_migration_only", False)):
        errors.append("Phase 2B face composite must be hidden and migration-only in Phase 2C.")


def _validate_phase_2c_character(errors: list[str], data: dict, by_id: dict[str, dict]) -> None:
    character = data.get("character", {})
    canvas = character.get("canvas_size", [])
    order = character.get("layer_order", [])
    for first, second in (("body_core", "eyes"), ("eyes", "eyebrows"), ("eyebrows", "mouth"), ("mouth", "makeup"), ("makeup", "hair_front")):
        if first not in order or second not in order or order.index(first) >= order.index(second):
            errors.append(f"Phase 2C layer order must place {first} before {second}.")

    metadata = character.get("face_import_metadata", {})
    if not isinstance(metadata, dict):
        errors.append("character.face_import_metadata must be an object.")
    else:
        for key in ("face_rect", "safe_clipping_bounds", "face_mask_bounds", "head_preview_rect", "skin_preview_rect"):
            _validate_canvas_rect(errors, key, metadata.get(key), canvas)
        center = metadata.get("face_center")
        if not isinstance(center, list) or len(center) != 2:
            errors.append("face_center must contain two coordinates.")
        if not isinstance(metadata.get("layers_before_imported_face"), list) or not isinstance(metadata.get("layers_after_imported_face"), list):
            errors.append("Face import metadata must declare layers before and after imported_face.")

    for item_id, (expected_path, expected_hash) in KERI_SKIN_VARIANTS.items():
        item = by_id.get(item_id, {})
        actual_path = str(item.get("layers", {}).get("body_core", "")) if isinstance(item.get("layers"), dict) else ""
        if actual_path != expected_path:
            errors.append(f"{item_id} must map body_core to {expected_path}.")
        elif _sha256(_resolve_res_path(actual_path)) != expected_hash:
            errors.append(f"{item_id} hash must remain {expected_hash}.")


def _validate_canvas_rect(errors: list[str], label: str, value: object, canvas: object) -> None:
    if not isinstance(value, list) or len(value) != 4 or not isinstance(canvas, list) or len(canvas) != 2:
        errors.append(f"{label} must be a four-number canvas rect.")
        return
    try:
        x, y, width, height = (float(part) for part in value)
        canvas_width, canvas_height = (float(part) for part in canvas)
    except (TypeError, ValueError):
        errors.append(f"{label} must contain numeric values.")
        return
    if x < 0 or y < 0 or width <= 0 or height <= 0 or x + width > canvas_width or y + height > canvas_height:
        errors.append(f"{label} must stay inside the character canvas.")


def _validate_layer_png(errors: list[str], label: str, res_path: str, catalog_data: dict) -> None:
    local_path = _resolve_res_path(res_path)
    if not local_path.exists():
        errors.append(f"{label} layer path does not exist: {res_path}")
        return
    png_info = _read_png_info(local_path)
    if png_info is None:
        errors.append(f"{label} layer is not a readable PNG: {res_path}")
        return
    width, height, color_type = png_info
    expected_canvas = catalog_data.get("character", {}).get("canvas_size", DEFAULT_CANVAS)
    if [width, height] != expected_canvas:
        errors.append(f"{label} layer canvas must be {expected_canvas}: {res_path} is {width}x{height}")
    if color_type != 6:
        errors.append(f"{label} layer must be RGBA PNG color type 6: {res_path}")


def _resolve_res_path(res_path: str) -> Path:
    return ROOT / res_path.removeprefix("res://")


def _read_png_info(path: Path) -> tuple[int, int, int] | None:
    try:
        with path.open("rb") as file:
            if file.read(8) != b"\x89PNG\r\n\x1a\n":
                return None
            length = struct.unpack(">I", file.read(4))[0]
            chunk_type = file.read(4)
            if chunk_type != b"IHDR" or length < 13:
                return None
            data = file.read(length)
            width, height, _bit_depth, color_type = struct.unpack(">IIBB", data[:10])
            return width, height, color_type
    except OSError:
        return None


def _sha256(path: Path) -> str:
    try:
        import hashlib

        return hashlib.sha256(path.read_bytes()).hexdigest()
    except OSError:
        return ""


if __name__ == "__main__":
    raise SystemExit(main())
