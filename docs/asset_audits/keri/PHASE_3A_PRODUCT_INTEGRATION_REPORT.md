# Phase 3A Product Integration Report

Date: 2026-07-16

Status: **MANUAL VISUAL QA PENDING**

## Scope and boundary

Phase 3A simplifies the product action bar and integrates every compatible wardrobe PNG found in the local extracted PNG source/template set. It does not implement local face import, file picking, biometric analysis, Phase 3B, web export/release, Phase 3C, full-body reconstruction, donor legs, shoes, socks, production-PNG editing, PSD export, AI asset work, commit, or push.

## Baseline

Before edits:

- `git status --short`: clean.
- `git diff --check`: clean.
- `python tools/validate_catalog.py`: `Catalog valid: 15 categories, 180 items.`
- The first sandboxed `check_project.ps1` run reached Godot 4.7 import but could not save `C:/Users/ADMIN/AppData/Roaming/Godot/editor_settings-4.7.tres` and timed out at startup. This was an environment restriction.
- The approved out-of-sandbox baseline passed Godot 4.7 import/parse, main-scene startup, logic smoke with `SMOKE TEST PASSED`, and `Project checks passed.`

## Phase 2C closure

The Phase 3A start instruction records Phase 2C as complete. Current-state, phase-status, roadmap, and the Phase 2C appearance report now close that milestone. The Phase 2C appearance architecture, defaults, inventory, immutable anchors, and accepted manual checks remain the baseline for Phase 3A.

## Action-bar simplification

The product action bar now contains only three equal icon buttons in one compact row:

| Public node | Glyph | Tooltip and accessible name | State behavior |
|---|---|---|---|
| `UndoButton` | `↶` | `Hoàn tác` | Disabled when history cannot undo. |
| `RedoButton` | `↷` | `Làm lại` | Disabled when history cannot redo. |
| `ResetButton` | `⟳` | `Reset` | Enabled while the state is valid. |

The glyphs use the Godot default font; no emoji asset or external font was added. All three buttons retain normal, hover, pressed, disabled, and focus styles and use keyboard focus.

Removed from the product UI:

- Random;
- Save PNG;
- Fullscreen;
- Clear saved data.

Their buttons, tooltips, keyboard handlers, focus targets, UI signals, clear-save dialog, and unused layout cells are gone. Reusable backend methods such as randomization, PNG capture, fullscreen switching, and save clearing remain outside the Phase 3A product UI.

## Reset and history contract

Reset remains a single full-state history action. It restores the catalog defaults, writes the resulting state through the existing state-change save path, refreshes UI/renderer selection, and keeps category locks under the existing `keep_locks=true` contract.

The Phase 3A default selection is:

```text
skin_tone_01
hair_none
face_none
eyes_none
eyebrows_none
mouth_none
makeup_none
top_none
bottom_none
dress_none
glasses_none
headwear_none
accessory_none
background_none
```

The hidden, deferred shoes migration slot retains its existing valid legacy default and does not appear in the UI or contribute a PNG layer. With top and bottom set to none, `fallback_top` and `fallback_bottom` render. Undo immediately after Reset restores the complete pre-reset outfit; Redo reapplies Reset; a new selection after Undo clears the redo branch.

## Audit source and method

Source root:

```text
C:\Users\ADMIN\Desktop\keri_asset_audit\01_extracted_original\
Keri-Dressup-RenPy-Template\Keri-Dressup-RenPy-Template\
game\Create_Character\
```

This report calls it the **local extracted PNG source/template set**. The audit recursively scanned the actual source tree. For each PNG it read SHA256, dimensions, image mode, alpha presence, and alpha-derived visible bounds, then classified runtime category/layer, style/color metadata, crop risk, compatibility, include/exclude decision, destination, provenance, and manual-QA requirement. Representative source styles were also inspected visually. No filename-only compatibility decision was used.

The complete 184-entry record is `PHASE_3A_CONTENT_INVENTORY.json`. Visible bounds use `[left, top, right_exclusive, bottom_exclusive]`.

## Inventory summary

| Source group | Count | Phase 3A result |
|---|---:|---|
| Base | 5 | Already integrated in Phase 2C. |
| Hair | 75 | Already integrated in Phase 2C. |
| Eyes | 30 | Already integrated in Phase 2C. |
| Eyebrows | 5 | Already integrated in Phase 2C. |
| Mouth | 5 | Already integrated in Phase 2C. |
| Misc | 16 | Two blush layers already integrated; 14 tears/sweat effects excluded. |
| Tops | 30 | 29 selectable compatible variants; one byte-identical renderer fallback source excluded from selection. |
| Bottoms | 18 | Five selectable shorts; one byte-identical fallback excluded from selection; six long trousers and six crop-risk skirts excluded. |

Decision totals:

- 122 appearance PNGs already integrated in Phase 2C;
- 4 compatible garment PNGs reused from the Phase 2B proof paths;
- 30 compatible garment PNGs copied unchanged for Phase 3A;
- 2 compatible but duplicate fallback sources excluded from selectable content;
- 26 incompatible/out-of-scope PNGs excluded.

No production dress, accessory, glasses, headwear, jewelry, background, or foreground-product group exists in this source tree.

## Include and exclude decisions

Included product content:

- top source styles 1-5, color variants 1-6, except `top1_1.png` because the exact bytes are the immutable renderer fallback top;
- short-bottom source style 2, color variants 1-6, except `bottom2_1.png` because the exact bytes are the immutable renderer fallback bottom;
- existing proof mappings for `top2_1`, `top3_1`, `bottom2_2`, and `bottom2_3` were retained instead of duplicating their bytes.

Excluded:

- `bottom1_1..6`: long trousers reach the 1920px canvas edge and depend on missing lower legs/feet;
- `bottom3_1..6`: alpha bounds end around y=1878, below the current y=1660 crop, so the skirt hem would be visibly cut;
- 14 tears/sweat PNGs: expression effects are outside Phase 3A product slots and include redundant variants;
- `top1_1` and `bottom2_1` as selectable items: their bytes are reserved for mandatory renderer fallbacks and adding identical selectable copies has no product value.

No excluded file was copied, cropped, resized, recompressed, warped, or otherwise repaired.

## Source-to-destination mapping

Existing mappings retained:

| Source | Runtime destination |
|---|---|
| `Tops/top2_1.png` | `assets/tops/keri/proof/top_casual_02.png` |
| `Tops/top3_1.png` | `assets/tops/keri/proof/top_casual_01.png` |
| `Bottoms/bottom2_2.png` | `assets/bottoms/keri/proof/bottom_shorts_02.png` |
| `Bottoms/bottom2_3.png` | `assets/bottoms/keri/proof/bottom_shorts_01.png` |

New unchanged copies use these patterns:

| Source pattern | Destination pattern | Count |
|---|---|---:|
| `Tops/top{1..5}_{1..6}.png`, excluding fallback and four existing proof cases | `assets/clothing/keri/tops/top_style_{01..05}_color_{01..06}.png` | 27 |
| `Bottoms/bottom2_{4..6}.png` | `assets/clothing/keri/bottoms/shorts_style_01_color_{04..06}.png` | 3 |

Every exact path and source/runtime SHA256 is recorded in the inventory and checked by the validator.

## Catalog and navigation

- Catalog schema remains version 2 because Phase 3A adds no state slot and requires no save-schema migration.
- Catalog grows from 15 categories / 180 items to **15 categories / 210 items**.
- Visible wardrobe content is 29 real tops plus `top_none`, and five real shorts plus `bottom_none`.
- Top items store `style_id`, `color_id`, and `variant_group` for five style groups and six source color positions.
- Shorts store the same variant seam for one short style and five selectable color positions.
- No bottom subcategory was added because only one compatible bottom type remains after the crop gate.
- Dress/accessory/glasses/headwear remain hidden because this source contains no accepted runtime PNG for them.
- Empty categories remain omitted through catalog navigation metadata; item/category counts are not hard-coded in UI/rendering code.

## None policy and compatibility

`top`, `bottom`, `dress`, `glasses`, `headwear`, `accessory`, and `background` retain visible or migration-safe none items as applicable. Skin remains mandatory without none. Hair, eyes, eyebrows, mouth, and makeup keep their Phase 2C none items.

Garments continue using the existing data-driven `occupies` contract. Tops occupy `top`; shorts occupy `bottom`; a selected dress occupies both and clears separates. The renderer continues to apply fallback visibility atomically. Skin/face/hair changes do not alter clothing coverage.

## Thumbnail strategy

- Phase 3A tops use `top_crop` with their audited alpha bounds, 8% padding, centered square fitting, and a common neutral background.
- Shorts use `bottom_crop` with the same metadata-driven fitting strategy.
- Existing skin swatch, feature crop, hair preview, background cover, X none tile, two-column grid, vertical-only scrolling, textless item cards, and selected borders are retained.
- No production PNG is rewritten to create a thumbnail.

## Save/load and migration

Save version remains 2. Phase 2B/2C item IDs remain valid, and all new product IDs are normal catalog selections. Missing/wrong-category/legacy-only IDs sanitize to current defaults. The new metadata fields do not enter saved state. The save service accepts an optional path only to permit an isolated reset-persistence smoke test; the production path remains `user://outfit_state.json`.

## Automated coverage and results

Coverage now includes:

- exactly three public action buttons, stable glyphs, tooltips, accessible names, focus, and visual state styles;
- history-driven Undo/Redo disabled states and always-enabled Reset;
- Reset defaults, fallback coverage, local-save persistence, Undo/Redo of Reset, and redo-branch clearing;
- all 184 inventory records and required fields;
- source-to-destination SHA256 mapping for every included garment;
- rejection of excluded fallback bytes as selectable items;
- product PNG RGBA/canvas/path checks and absence of PSD/archive runtime assets;
- style/color/variant and thumbnail metadata;
- existing compatibility, random/lock backend, save/load, migration, Phase 2B anchors, and Phase 2C appearance regressions.

Latest automated result:

- `python tools/validate_catalog.py`: `Catalog valid: 15 categories, 210 items.`
- `check_project.ps1`: Godot 4.7 import/parse passed; main startup passed; logic smoke printed `SMOKE TEST PASSED`; `Project checks passed.`

Dummy-renderer cleanup/resource warnings remain informational and the checks return zero.

## Limitations

- Automated checks cannot prove garment/body alignment, readable thumbnails, action-glyph clarity, hover feel, or crop quality.
- No accepted dress, accessory, glasses, headwear, jewelry, or background PNG exists in the audited source.
- Skirts are excluded because the current crop removes their hem; this phase does not repair or rescale them.
- Keri remains a conditional proof/product candidate with the existing provenance caveats.
- Browser export/QA is Phase 3C work and was not started.

## Required manual visual QA

Action bar:

- confirm only the three icon buttons appear and the glyphs are readable;
- confirm `Hoàn tác`, `Làm lại`, and `Reset` tooltips/accessibility;
- confirm hover, pressed, focus, disabled states and compact layout at 1440x900, 1280x720, and 1024x768;
- confirm Random, Save PNG, Fullscreen, and Clear saved data have no button, tooltip, focus target, or empty layout gap.

Reset/state:

- select a complete look, Reset, close/reopen, and confirm the reset state persists;
- confirm skin 01, optional appearance none, fallback outfit, accessory none, and default background;
- confirm Undo Reset restores the full prior look, Redo reapplies Reset, and a new selection after Undo clears Redo.

Wardrobe:

- inspect all 29 tops and all five shorts on all five skin tones;
- confirm no fallback bleed, exposed body, wrong overlap, or abrupt crop;
- confirm top and bottom none tiles restore their matching fallback;
- confirm every thumbnail is centered, large, textless, distinct, and selected clearly;
- confirm the item grid stays two columns with vertical-only scrolling;
- confirm no long trousers, skirts, shoes, socks, dress, or empty accessory category appears.

Regression:

- sample hair, eyes, eyebrows, mouth, and makeup independently;
- exercise selection, locks/backend random through tests, undo, redo, reset, save/load, and a legacy save;
- confirm the accepted three-quarter crop and all three immutable Phase 2B anchors remain visually unchanged.

## Boundary confirmation

- Phase 2C is **COMPLETE**.
- Phase 3A is **MANUAL VISUAL QA PENDING**.
- Phase 3B Local Face Import is **NOT STARTED**.
- Local face import was not implemented.
- Phase 3C Web Release is **NOT STARTED**.
- No commit was made.
- No push was made.
