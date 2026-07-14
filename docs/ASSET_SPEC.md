# Asset Specification

## Canvas

- Working canvas: **1024 × 1536 px** (2:3).
- Format: PNG with transparency.
- Every wearable layer uses the full canvas; do not crop tightly around the item.
- All files share the same body position and origin.
- Thumbnail: 256 × 256 px, cropped for readability.

## Layer order

1. background
2. hair_back
3. accessory_back
4. body
5. face
6. shoes
7. bottom
8. top
9. dress_back
10. dress_main
11. body_foreground
12. hair_front
13. glasses
14. face_accessory
15. headwear
16. accessory_front
17. effect_front

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
- Correct 1024×1536 canvas after normalization.
- Transparent background and clean alpha edges.
- No duplicated limbs or accidental body parts.
- Item aligns with shoulder, waist, hip, knee and foot anchors.
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
