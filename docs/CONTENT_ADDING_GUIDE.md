# Adding Wardrobe Content

## Add a metadata-only placeholder item

1. Open `data/catalog.json`.
2. Copy an item in the same category.
3. Assign a unique stable ID.
4. Choose a supported `render_key` and placeholder colors.
5. Set slots/tags/conflicts.
6. Optionally add `thumbnail_path` later when a real thumbnail PNG exists; keep `display_name` for fallback text.
7. Run `./tools/check_project.ps1`.

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
    },
    "preview_mode": "top_crop",
    "preview_rect": [109, 675, 592, 842],
    "preview_padding_ratio": 0.08,
    "preview_background": "#f7f1f5",
    "style_id": "top_shirt_02",
    "color_id": "color_white",
    "variant_group": "top_shirt_02",
    "source_sha256": "..."
}
```

Requirements:

- Full shared transparent canvas.
- For the Keri three-quarter-body MVP proof, use 948×1920 and the same origin as the Keri anchor.
- Same body template and position.
- Asset path uses `res://`.
- File ID matches catalog ID.
- Use front/back layers when needed.
- Record an audited source hash and source-to-destination mapping for production content.
- Store style/color grouping metadata when the source is organized as style × color.
- Use `top_crop`, `bottom_crop`, or `effect_crop` with an audited alpha-derived rectangle; do not rewrite the production PNG to create a thumbnail.
- Judge viewport compatibility from the rendered visible content. Alpha continuing below y=1660 is not, by itself, a rejection reason.
- Keep shorts, trousers, and skirts in the single `bottom` state slot and use `item_groups`/`ui_group` metadata for navigation.
- Do not add shoes, socks, full-length dresses, reconstructed feet, or other foot-dependent presentation for MVP.

## Do not

- Add item-specific `if item_id == ...` branches to UI.
- Change the body pose for one outfit.
- Mix unrelated AI art styles.
- Store user photos in the asset folder.
- Add unsupported deferred categories as empty MVP UI categories.

## Phase 3A audit helper

`python tools/integrate_phase_3a_content.py` regenerates the read-only-source inventory. `--apply` additionally copies only accepted new PNGs unchanged and idempotently updates Phase 3A catalog garment records. The validator checks the resulting inventory paths/hashes, so do not hand-wave an excluded source into runtime content.
