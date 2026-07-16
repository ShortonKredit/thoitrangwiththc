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

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(f"Catalog valid: {len(categories)} categories, {len(items)} items.")
    return 0


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
