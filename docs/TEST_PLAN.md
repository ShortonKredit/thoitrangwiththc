# Test Plan

Automated checks prove parser, catalog, and state invariants. Manual visual checks prove layout, artwork, layering, and browser behavior. Passing one category does not replace the other.

## Automated Local Checks

Run before and after each milestone change:

```powershell
python tools/validate_catalog.py
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_project.ps1"
```

Expected:

- catalog validation prints `Catalog valid: 9 categories, 45 items`;
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

## Automated Gaps

Automated checks do not prove:

- exact visual header spacing;
- whether the base outfit covers the body attractively;
- real PNG layer alignment;
- skin tone or anatomy quality;
- hair front/back visual order;
- face mask quality;
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

## Visual QA Checklist

Check these by eye after UI or asset work:

- header spacing and title readability;
- wardrobe/category alignment and spacing;
- active, selected, disabled, hover, pressed, and locked states;
- status text readability and placement;
- item area behavior when a category has few items;
- base outfit coverage at all valid clothing states;
- outfit overlap and layer order;
- shoulder, waist, hip, knee, ankle, and foot alignment for PNG assets;
- skin tone consistency;
- leg anatomy and proportions;
- hair back/front separation;
- face mask shape, placement, and edge quality;
- thumbnail clarity at final UI size;
- no text overflow at target window sizes.

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
