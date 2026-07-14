# Adding Wardrobe Content

## Add a metadata-only placeholder item

1. Open `data/catalog.json`.
2. Copy an item in the same category.
3. Assign a unique stable ID.
4. Choose a supported `render_key` and placeholder colors.
5. Set slots/tags/conflicts.
6. Run `./tools/check_project.ps1`.

The item list and random range update automatically.

## Add a real PNG item

Example:

```json
{
  "id": "top_white_shirt_02",
  "category": "top",
  "display_name": "Sơ mi trắng 02",
  "render_key": "shirt",
  "occupies": ["top"],
  "tags": ["smart_casual"],
  "conflicts_with_tags": [],
  "layers": {
    "top": "res://assets/tops/top_white_shirt_02.png"
  }
}
```

Requirements:

- Full 1024×1536 transparent canvas.
- Same body template and position.
- Asset path uses `res://`.
- File ID matches catalog ID.
- Use front/back layers when needed.

## Do not

- Add item-specific `if item_id == ...` branches to UI.
- Change the body pose for one outfit.
- Mix unrelated AI art styles.
- Store user photos in the asset folder.
