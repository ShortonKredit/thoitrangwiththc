#!/usr/bin/env python3
"""Dependency-free validation for data/catalog.json."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "data" / "catalog.json"


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
    if character.get("canvas_size") != [1024, 1536]:
        errors.append("The locked MVP canvas size is 1024x1536.")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(f"Catalog valid: {len(categories)} categories, {len(items)} items.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
