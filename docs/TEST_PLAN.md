# Test Plan

Automated checks prove parser, catalog, and state invariants. Manual visual checks prove layout, artwork, layering, and browser behavior. Passing one category does not replace the other.

## Automated Local Checks

Run before and after each milestone change:

```powershell
python tools/validate_catalog.py
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_project.ps1"
```

Expected after Phase 2C:

- catalog validation prints `Catalog valid: 15 categories, 180 items`;
- Godot 4.7 import and script parse exit 0;
- main scene startup smoke exits 0;
- logic smoke test prints `SMOKE TEST PASSED`;
- project check prints `Project checks passed`.

## Automated Coverage

Current checks cover:

- catalog JSON validity;
- category and item counts;
- item IDs and category membership;
- compatibility rules for top/bottom/dress conflicts;
- random selection with category locks;
- undo/redo full-state snapshots;
- reset behavior;
- local-save sanitization against the current catalog;
- `base_outfit` layer-order presence;
- `base_outfit` not entering selected state or save snapshots;
- all-none top/bottom/dress state being valid;
- optional `thumbnail_path` validation;
- missing thumbnail/text fallback behavior;
- `accessible_name` fallback to `display_name`;
- main scene startup without parse/runtime failure.
- Phase 2B Keri proof layer paths exist.
- Keri proof PNG layers use the `948x1920` canvas and RGBA color type.
- Hidden/deferred categories such as shoes do not appear in the visible MVP proof category list.
- Random does not change hidden categories.
- Phase 2B UI constants keep the item grid at two columns.
- Phase 2B item tiles are configured as textless thumbnail tiles.
- Phase 2B category display names include required Vietnamese accents.
- Phase 2B thumbnail preview modes select `none`, `cover`, `face_preview`, or `visible_bounds` as appropriate.
- Phase 2B visible-bounds thumbnail helpers detect cropped alpha regions for Keri hair, top, and bottom proof PNGs.
- Phase 2B face thumbnail crop stays inside the 948x1920 Keri canvas.
- Phase 2C skin items have exact expected source hashes and skin has no none item.
- Hair, eyes, eyebrows, mouth, makeup, legacy face, dress, and background none policies are validated.
- Hair none removes the combined `hair_front` layer; undo/redo restores both hair and none states.
- Skin swaps replace `body_core` while preserving fallback coverage.
- Face feature slots render independently and follow the catalog layer order.
- Empty face subcategories, including absent eyelashes, remain hidden.
- Face/head/skin preview rectangles, safe clipping bounds, face center, and mask bounds stay inside the canvas.
- Save schema v2 restores Phase 2C state and version-1 Phase 2B saves sanitize the legacy face composite safely.
- Clean initialization and reset return to skin 01 with hair, eyes, eyebrows, mouth, and makeup set to none.
- Skin items use distinct opaque `skin_swatch` metadata instead of character previews.
- Eyes, eyebrows, mouth, and makeup use validated per-item `feature_crop` rectangles inside the Keri canvas.
- Visible hair items use `hair_preview`; all optional none items still resolve to the X-tile mode.

## Automated Gaps

Automated checks do not prove:

- exact visual header spacing;
- whether the base outfit covers the body attractively;
- real PNG layer alignment;
- skin tone or anatomy quality;
- hair front/back visual order;
- face mask quality;
- whether the three-quarter-body crop looks intentional;
- whether unsupported full-length items visually exceed the MVP crop;
- thumbnail crop/readability;
- browser canvas/download behavior;
- hover/pressed visual feel.

## Native Visual Smoke Test

Run in Godot and verify:

1. Game opens without red errors.
2. Header text is visible and not clipped.
3. All nine category buttons appear.
4. Active category is easy to identify.
5. Selecting an item updates the character immediately.
6. Selected item remains visibly highlighted.
7. Dress clears top and bottom.
8. Selecting top or bottom clears dress.
9. Top, bottom, and dress can all be none while the base outfit remains visible.
10. Lock hair, random several times, and verify hair remains unchanged.
11. Undo reverses one random action.
12. Redo restores that random action.
13. Reset shows confirmation and returns to valid defaults.
14. Close and reopen; saved outfit is restored or safely sanitized.
15. Save PNG excludes wardrobe controls.

For the three-quarter-body MVP proof, adjust the category expectation to the supported MVP categories only. Shoes and other deferred categories must not appear as empty UI categories.

## Visual QA Checklist

Check these by eye after UI or asset work:

- header spacing and title readability;
- wardrobe/category alignment and spacing;
- active, selected, disabled, hover, pressed, and locked states;
- status text readability and placement;
- no bottom status bar in the Phase 2B proof UI;
- no explanatory help line under the selected category in the Phase 2B proof UI;
- item area behavior when a category has few items;
- thumbnail-first item grid shows two large square-ish tiles per row at the desktop proof viewport;
- item cards do not show item names, IDs, categories, or file paths;
- none options use an icon-style tile, not visible text;
- background tiles show a distinguishable cover preview instead of a blank white card;
- hair, face, top, and bottom thumbnails are centered and readable at final tile size;
- base outfit coverage at all valid clothing states;
- outfit overlap and layer order;
- shared canvas and origin for all imported proof layers;
- shoulder, waist, hip, and supported lower-crop alignment for three-quarter-body PNG assets;
- lower crop edge looks intentional and does not expose an abrupt broken asset edge;
- skin tone consistency;
- hair back/front separation;
- face mask shape, placement, and edge quality;
- no shoes, socks, long trousers, full-length dresses, or foot-dependent items in MVP UI/content;
- no item extends beyond the supported three-quarter-body display region;
- thumbnail clarity at final UI size;
- no text overflow at target window sizes.

## Three-Quarter-Body MVP Checks

After Phase 2B/2D asset work, verify:

1. All Keri proof layers use the same canvas and origin.
2. The character crop reads as intentional three-quarter-body framing.
3. The lower crop does not reveal a hard broken edge or unfinished leg extension.
4. Shoes do not appear as an empty category.
5. Full-length garments and foot-dependent items are absent from the MVP catalog/UI.
6. Tops and short bottoms render correctly on the Keri body.
7. Short dresses replace top/bottom according to compatibility rules.
8. The base outfit is always present and not hidden by invalid states.
9. Random does not select disabled/deferred categories or unsupported items.
10. Old saves containing shoes or deferred categories sanitize without crash.
11. Undo, redo, reset, and local save still work after proof-pack import.
12. Web export displays the same intentional three-quarter-body crop.

## Phase 2C Native Visual Checklist

1. `Khuôn mặt` shows only `Màu da`, `Mắt`, `Lông mày`, `Miệng`, and `Trang điểm`.
2. Every subcategory uses two columns, vertical scrolling, no horizontal overflow, no visible item names, and a clear selected border.
3. Skin previews are large, opaque color swatches with no head/body imagery; all five tones remain distinguishable and retain identical runtime placement/coverage.
4. Hair previews contain only centered hair on the same neutral background, read large enough at tile size, and `none` removes all hair; sample all five shapes and several colors.
5. Eyes, eyebrows, mouth, and makeup cards show only their relevant feature crop on a consistent neutral background; runtime selections change independently without shifting or scaling.
6. Optional none tiles use the X visual and are distinguishable from missing/failed thumbnails.
7. Face feature thumbnails remain isolated to their own crop and readable on the shared neutral background.
8. Random respects locks, never removes mandatory skin, and only chooses metadata-eligible none items.
9. Clean launch and reset show skin 01 with hair, eyes, eyebrows, mouth, makeup, and legacy face all none; undo/redo covers skin, features, none, random, and reset.
10. Save/load restores every Phase 2C slot without errors and the fallback outfit remains correct.
11. Combined-hair ordering is acceptable for the actual source; no false front/back split is implied.
12. The face anchor/mask bounds are only metadata and no local face import UI appears.

## Web Local Test

Only required for web/export milestones:

```powershell
./tools/export_web.ps1
./tools/serve_web.ps1
```

Open Chrome, Edge, and Firefox and check:

- no red Console errors;
- `.wasm`, `.pck`, `.js`, and assets return HTTP 200;
- fullscreen works only after a user action;
- PNG download works;
- refresh restores save when browser storage is allowed;
- no outbound API requests except static site files.

## Viewport Sizes

- 1440x900 target desktop.
- 1280x720 minimum desktop check.
- 1024x768 best-effort compact desktop/tablet check.
