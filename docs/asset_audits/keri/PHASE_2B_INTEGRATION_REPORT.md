# Phase 2B Integration Report - Keri Three-Quarter-Body Proof

Date: 2026-07-14

## Scope

Phase 2B imports a tiny Keri proof pack into the existing Godot catalog and renderer. It does not start full-body leg extension, donor-leg compositing, shoes, socks, long trousers, full-length dresses, backend work, image generation, commit, or push.

Phase 2B is **COMPLETE**. The owner confirmed manual visual QA on 2026-07-16.

Proof pack included:

- 1 body core.
- 1 internal fallback top.
- 1 internal fallback bottom.
- 1 combined hair layer.
- 1 fixed face configuration, composited locally from audited eyebrows, eyes, and mouth layers.
- 2 selectable tops.
- 2 selectable short bottoms.

Short dress: not available in current proof source. Accessory: not available in current proof source.

## Blocker Correction

The earlier Phase 2B correction only addressed filename/provenance. It still used a flattened runtime body:

`assets/characters/keri/proof/keri_clothed_base.png`

That file was a composite of:

1. `base1.png`
2. `bottom2_1.png`
3. `top1_1.png`

Manual QA found the architectural failure: the gray striped fallback top was baked into the body layer and remained visible under selected garments. This was a layer architecture blocker, not a naming issue.

The flattened composite has been removed from runtime. It is no longer referenced by `data/catalog.json` or the renderer, and the file plus `.import` sidecar were deleted from the Phase 2B proof folder.

Runtime now uses three independent internal character layers:

- `body_core`
- `fallback_top`
- `fallback_bottom`

The fallback layers are not selectable wardrobe items and do not appear in the category UI.

## Internal Runtime Layers

All internal runtime layers use canvas `948x1920`, RGBA, origin `(0, 0)`, with no scale, crop, warp, recolor, or reposition.

| Role | Source path | SHA256 | Destination path | Visible alpha bounds |
|---|---|---|---|---|
| body_core | `C:\Users\ADMIN\Desktop\keri_asset_audit\04_selected_for_proof\body\base1.png` | `555132e38e2ec9efbdbf1e2e034f32fab36f01752e264457daed5993a578386c` | `assets/characters/keri/proof/keri_body_core.png` | `(62, 44, 922, 1920)` |
| fallback_top | `C:\Users\ADMIN\Desktop\keri_asset_audit\04_selected_for_proof\tops\top1_1.png` | `3d21587ec7bd3b19d7e9d18676eb39ff784a5d1083c9110915414fa868f58f9d` | `assets/characters/keri/proof/keri_fallback_top.png` | `(123, 568, 782, 1442)` |
| fallback_bottom | `C:\Users\ADMIN\Desktop\keri_asset_audit\04_selected_for_proof\bottoms\bottom2_1.png` | `6a112916adfca3d721c6600d95b66b7f6e7be124ef1727203bb182cd73c24a3b` | `assets/characters/keri/proof/keri_fallback_bottom.png` | `(125, 1132, 644, 1647)` |

## Selectable Proof Assets

The selectable first top/bottom were moved off the fallback source files so `top1_1.png` and `bottom2_1.png` are not reused as normal UI garments.

| Asset | Source path | SHA256 | Destination path | Visible alpha bounds |
|---|---|---|---|---|
| Hair | `C:\Users\ADMIN\Desktop\keri_asset_audit\04_selected_for_proof\hair\hair1_1.png` | `26d6b0255b293ec2be9cf43c241ab8553e2f74a2ba042ca9311c9ff07205fe70` | `assets/hair/keri/proof/hair_long_brown_01.png` | `(198, 44, 727, 849)` |
| Top 01 | `C:\Users\ADMIN\Desktop\keri_asset_audit\01_extracted_original\Keri-Dressup-RenPy-Template\Keri-Dressup-RenPy-Template\game\Create_Character\Tops\top3_1.png` | `272d3f7e3e94ab8220faccd1361f7fd6de2ad7c68f5184ae1bbd5326450141bb` | `assets/tops/keri/proof/top_casual_01.png` | `(109, 675, 701, 1517)` |
| Top 02 | `C:\Users\ADMIN\Desktop\keri_asset_audit\04_selected_for_proof\tops\top2_1.png` | `d2189583a0cecff18c2ba93073fb5032e0cadda96424bbe3861c3917773b3b22` | `assets/tops/keri/proof/top_casual_02.png` | `(62, 574, 898, 1517)` |
| Shorts 01 | `C:\Users\ADMIN\Desktop\keri_asset_audit\01_extracted_original\Keri-Dressup-RenPy-Template\Keri-Dressup-RenPy-Template\game\Create_Character\Bottoms\bottom2_3.png` | `19133e526c754acc4eade9e062e64aac607a0e8d3dc9172af0968e64c0aafb20` | `assets/bottoms/keri/proof/bottom_shorts_01.png` | `(125, 1132, 644, 1647)` |
| Shorts 02 | `C:\Users\ADMIN\Desktop\keri_asset_audit\01_extracted_original\Keri-Dressup-RenPy-Template\Keri-Dressup-RenPy-Template\game\Create_Character\Bottoms\bottom2_2.png` | `7b3225252edd03ad9203f646a8ce1a27c72b6ccf6745d42dad75125c4587b23b` | `assets/bottoms/keri/proof/bottom_shorts_02.png` | `(125, 1132, 644, 1647)` |
| Face config | `eyebrows1_1.png`, `eyes1_1.png`, and `mouth1_1.png` from `04_selected_for_proof\face_parts` | `b48d4ef69152883ded6fe1af470500b74425341338f77b5bdb88a33687f29488` | `assets/face/keri/proof/face_default_01.png` | `(302, 239, 549, 449)` |

Face transform: local alpha composite only, no resize, crop, warp, AI generation, or external source modification.

## Runtime Visibility Rules

`DollView.get_png_layer_paths()` is the single renderer path used to build PNG draw layers. It applies these rules atomically per draw:

- No selected top and no selected dress: show `fallback_top`.
- Selected top: hide `fallback_top`, show selected top.
- No selected bottom and no selected dress: show `fallback_bottom`.
- Selected bottom: hide `fallback_bottom`, show selected bottom.
- Selected dress: hide `fallback_top`, `fallback_bottom`, selected top, and selected bottom; show selected dress layers when real dress PNGs exist.

The valid coverage invariant is:

- selected dress, or
- selected top or `fallback_top`, and selected bottom or `fallback_bottom`.

The Phase 2B catalog defaults to `top_none`, `bottom_none`, and `dress_none`, so reset displays the internal fallback outfit rather than a baked body composite.

## UI Refinement

The Phase 2B wardrobe UI was refined for manual proof review:

- Item selection changed from text-first buttons to a thumbnail-first two-column grid.
- Item tiles render no visible item names, IDs, categories, or file paths.
- Item names remain in metadata/tooltips for accessibility and debugging.
- `none` options use a drawn X tile with the same size as other item tiles, not a long text label.
- Item tiles use fixed minimum height and two equal grid columns on the desktop proof layout.
- Hover, focus, selected, disabled, and danger states use separate styleboxes and do not resize the grid.
- The category help line was removed.
- The bottom status bar was removed from the main layout.
- Category tabs remain text-based and data-driven.
- Empty or hidden categories do not appear as tabs.
- Vietnamese UI strings were normalized, including `Khuôn mặt`, `TỦ ĐỒ`, `Hoàn tác`, `Làm lại`, `Ngẫu nhiên`, `Đặt lại`, `Lưu PNG`, `Toàn màn hình`, `Xóa dữ liệu lưu`, and `Khóa`.

Manual QA then found that selector thumbnails were still using production PNG canvases directly, which made hair, face, tops, and bottoms read too small and left background tiles visually blank. The UI now builds separate in-memory preview images without resizing, cropping, or rewriting any production PNG:

- Hair, top, bottom, dress, and accessory layer previews use alpha visible bounds with padding, then fit into a cached square thumbnail texture.
- Face previews composite the selected face layer over `body_core`, crop a fixed Keri head/face region, then fit that crop into the selector tile.
- Background previews use catalog placeholder metadata to draw a small cover preview instead of an empty white tile.
- `none` options continue to use the drawn X tile and do not load external texture data.

## Catalog And Code Changes

- `data/catalog.json` now uses `character.mode = "png"`, `canvas_size = [948, 1920]`, and internal Keri character layers.
- `character.layers` contains `body_core`, `fallback_top`, and `fallback_bottom`.
- Added `face` category and six Keri proof items.
- Preserved the placeholder catalog content; placeholder fashion items that do not render in PNG proof mode are hidden rather than removed.
- Hidden/deferred categories are skipped by UI and randomization but retained for save sanitization and future migration.
- `DollView` uses `visible_canvas_rect = [0, 0, 948, 1660]` for PNG drawing, preserving aspect ratio and hiding the unfinished lower-leg source edge.
- `tools/validate_catalog.py` checks layer paths, PNG existence, canvas size, RGBA color type, the three internal Keri layer hashes, and rejects any catalog reference to the flattened clothed composite.
- Smoke tests cover fallback visibility for no selection, selected top, selected bottom, selected dress, dress clearing, random, reset, undo/redo, save/load, accented category strings, hidden category tabs, the two-column textless item-grid contract, thumbnail preview modes, visible alpha bounds, face crop bounds, and background preview metadata.

## License And Provenance

Use remains conditional proof use only. Attribution/provenance from Phase 2A is retained:

- Konett: original Keri artist, local evidence says CC-BY-3.0.
- LunaLucid/Namastaii: Ren'Py template/adaptation author.
- Template README license version remains unspecified by available local evidence.

## Automated Tests

Baseline before the first Phase 2B edits:

- `git status --short`: clean.
- `git diff --check`: clean.
- `python tools/validate_catalog.py`: `Catalog valid: 9 categories, 45 items.`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_project.ps1"` initially failed before edits because the sandboxed Godot run could not save `editor_settings-4.7.tres`.

After split-layer correction:

- `python tools/validate_catalog.py`: `Catalog valid: 10 categories, 51 items.`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_project.ps1"`: import/parse passed, main scene startup smoke passed, logic smoke printed `SMOKE TEST PASSED`, project checks passed.
- Godot headless startup currently prints dummy-renderer cleanup warnings; `tools/check_project.ps1` captures stderr and still fails on nonzero exit codes or script/load fatal patterns.

## Manual QA Closure

The owner accepted the Phase 2B proof at a usable level, including:

- thumbnail previews are usable;
- split `body_core` / `fallback_top` / `fallback_bottom` architecture is stable;
- the two-column selector grid works;
- background previews display;
- the three-quarter-body crop is acceptable;
- item names remain hidden on cards;
- empty categories remain hidden.

The historical checklist below is retained for traceability:

- Keri appears centered and intentionally cropped.
- Lower crop does not read as a broken full-body asset.
- Hair and face alignment are acceptable.
- Both selectable tops and both selectable shorts align with `body_core`.
- Fallback top and fallback bottom disappear behind selected top/bottom instead of bleeding through.
- Shoes, dress, glasses, headwear, and accessory do not appear as empty MVP proof categories.
- Random, reset, undo, redo, save, and PNG capture behave correctly in the visible UI.
- Thumbnail grid shows exactly two item cards per row at the desktop proof viewport.
- Item cards show images only, with no visible item text.
- The none tile appears as an icon-style X tile.
- Background, hair, face, top, and bottom thumbnails are visually readable after preview crop/zoom.
- No bottom status bar or explanatory category help text remains.

## Limitations

- Hair is a single combined layer, not a production hair back/front split.
- No short dress or accessory was available in the current proof source.
- Hidden legacy dress metadata remains for compatibility tests and save migration, but no real dress PNG is imported.
- No browser export or browser visual QA was performed in this phase.
- Keri remains a proof candidate, not final product-anchor approval.

## Conclusion

The flattened runtime body architecture blocker was corrected by splitting Keri into `body_core`, `fallback_top`, and `fallback_bottom`. Automated checks pass and owner-confirmed manual QA is complete. Phase 2B is **COMPLETE**.
