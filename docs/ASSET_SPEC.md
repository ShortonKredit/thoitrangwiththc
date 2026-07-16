# Asset Specification

## Canvas

- Working canvas: **1024 × 1536 px** (2:3).
- Format: PNG with transparency.
- Every wearable layer uses the full canvas; do not crop tightly around the item.
- All files share the same body position and origin.
- Thumbnail: 256 × 256 px, cropped for readability.

## MVP Keri Three-Quarter-Body Exception

For the Phase 2B three-quarter-body Keri integration proof, use the existing Keri canvas as the proof anchor:

- Keri MVP proof canvas: **948 × 1920 px**.
- All Keri proof layers must share this canvas and origin.
- Do not extend the canvas or add missing feet for MVP.
- Supported MVP items must fit the three-quarter-body crop.
- Shoes, socks, full-length trousers, full-length dresses, and foot-dependent items are deferred/post-MVP.

The older `1024 × 1536` target remains a general future-production reference, but it is not a reason to restart leg-extension work during MVP.

## Thumbnail metadata

Wardrobe items may later declare:

```json
{
  "thumbnail_path": "res://assets/thumbnails/top_blouse_01.png",
  "accessible_name": "Áo blouse nơ"
}
```

Both fields are optional in the current placeholder catalog. If `thumbnail_path` is absent or empty, the UI keeps showing the text `display_name`. If a thumbnail path is provided, it must start with `res://`. Do not remove `display_name`; it remains required for fallback text, tooltips, accessibility, status text and debugging.

## Layer order

1. background
2. hair_back
3. accessory_back
4. body
5. face
6. base_outfit
7. shoes
8. bottom
9. top
10. dress_back
11. dress_main
12. body_foreground
13. hair_front
14. glasses
15. face_accessory
16. headwear
17. accessory_front
18. effect_front

### Keri Phase 2C layer order

The actual Phase 2C catalog order is:

```text
background -> hair_back -> accessory_back -> body_core/selected skin
-> fallback_bottom -> fallback_top -> base_outfit -> shoes -> bottom -> top
-> dress_back -> dress_main -> body_foreground -> imported_face (metadata only)
-> legacy face -> eyes -> eyebrows -> eyelashes (reserved) -> mouth -> makeup
-> hair_front/combined hair -> glasses -> face_accessory -> headwear
-> accessory_front -> effect_front
```

All imported appearance PNGs remain untouched RGBA `948x1920` files at origin `(0, 0)`. `base1..base5` have identical alpha masks and geometry; they are valid skin variants. The available hair source consists of combined layers, so Phase 2C maps them to `hair_front` and documents the limitation instead of splitting the PNGs.

Face metadata lives in `character.face_import_metadata` in `data/catalog.json`. Rectangles use full-canvas pixel coordinates. It is an integration seam only; no imported-face runtime asset exists in Phase 2C.

`base_outfit` is a permanent modest underlayer. In procedural mode it is drawn by `DollView`; in PNG mode it should be supplied as a full-canvas transparent PNG under `character.layers`, not as a wardrobe item.

## Phase 3A Keri product content

- Source: local extracted PNG source/template set under `game/Create_Character`.
- Full audit: 184 RGBA PNGs at 948×1920 with alpha-derived visible bounds and SHA256 mapping.
- Accepted selectable garments: 29 tops and five shorts; 30 new PNG files were copied unchanged and four proof paths were reused.
- Excluded: long trousers reaching y=1920, skirts whose hem falls below the y=1660 product crop, expression effects, and byte-identical selectable copies of renderer fallbacks.
- Runtime paths: `assets/clothing/keri/tops/` and `assets/clothing/keri/bottoms/`, plus retained Phase 2B proof paths.
- Production files are never resized, cropped, warped, recompressed, or edited to fit.

Catalog garment metadata includes `style_id`, `color_id`, `variant_group`, `source_sha256`, and a focused preview definition. `top_crop` and `bottom_crop` use the audited `[x, y, width, height]` alpha rectangle, neutral background, and padding to create an in-memory 192×192 preview. None tiles remain drawn X controls and never reference a PNG.

## File naming

```text
hair_long_straight_01_back.png
hair_long_straight_01_front.png
top_blouse_01.png
bottom_pleated_skirt_01.png
dress_casual_01_back.png
dress_casual_01_main.png
shoes_sneakers_01.png
accessory_handbag_01_front.png
```

Use lowercase snake_case and stable IDs. Do not encode display text in filenames.

## AI output acceptance checklist

- Same pose and camera as the master character.
- Correct shared canvas after normalization; for Keri MVP proof this is 948×1920.
- Transparent background and clean alpha edges.
- No duplicated limbs or accidental body parts.
- Item aligns with the supported three-quarter-body anchors.
- Style, line thickness, shading and lighting match the anchor.
- No logo, copyrighted character, trademark or franchise-specific motif.
- Front/back sections are separated when they cross body foreground layers.
- Thumbnail remains readable at 256 px.

## Recommended production workflow

1. Generate/select one master character anchor.
2. Lock pose, proportions, face area and body anchors.
3. Generate a tiny proof pack first.
4. Normalize in an image editor: remove background, align, scale, clean alpha.
5. Test all layers in Godot.
6. Only then generate the full category pack.
