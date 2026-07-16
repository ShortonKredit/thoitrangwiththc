# Phase 2C Appearance Report - Skin, Face, and Hair Layering

Date: 2026-07-16

Status: **COMPLETE**

Closure: the Phase 3A start gate on 2026-07-16 records Phase 2C as complete. The checklist below is retained as the accepted visual-QA record and regression checklist.

## Default and thumbnail UX polish

The Phase 2C polish pass changes no item/category counts and imports no additional assets.

- Clean initialization and reset now use `skin_tone_01`, `hair_none`, `face_none`, `eyes_none`, `eyebrows_none`, `mouth_none`, and `makeup_none`.
- Valid saved selections still restore normally. Missing or legacy slots sanitize against the new safe defaults, while reset always returns to the new default state.
- Skin thumbnails use dedicated `skin_swatch` mode with one opaque representative color per audited skin variant. No head, face, or body is rendered in these tiles.
- Eyes, eyebrows, mouth, and makeup use `feature_crop` mode. Each item stores its own alpha-derived visible rectangle, padding ratio, and common neutral background, so only the relevant feature is enlarged and centered.
- Hair uses `hair_preview` mode with existing hair-only visible bounds, reduced padding, a consistent neutral background, and centered square fitting.
- None choices remain textless X tiles and continue to override any configured preview metadata.
- The two-column grid, vertical scrolling, category/subcategory structure, selected border styling, clothing proof pack, and fallback outfit logic are unchanged.

## Scope and baseline

Phase 2C closes the accepted Phase 2B proof in documentation, audits the available local appearance PNGs, integrates skin/hair/face-feature state, and prepares a metadata-only seam for a future local face-import phase. It does not implement local face import, face recognition, biometric analysis, full-body work, foot-dependent content, bulk wardrobe integration, Phase 3, commit, or push.

Pre-edit baseline:

- `git status --short`: clean.
- `git diff --check`: clean.
- `python tools/validate_catalog.py`: `Catalog valid: 10 categories, 51 items.`
- The first sandboxed `check_project.ps1` run could not write Godot editor settings/user logs and crashed during startup. This was an environment restriction, not a repository failure.
- The approved out-of-sandbox baseline run passed Godot 4.7 import/parse, main-scene startup, and logic smoke with `SMOKE TEST PASSED` and `Project checks passed.`

## Phase 2B closure

The owner confirmed Phase 2B manual visual QA. `CURRENT_STATE.md`, `PHASE_STATUS.md`, `ROADMAP.md`, and `PHASE_2B_INTEGRATION_REPORT.md` now record Phase 2B as complete. The accepted proof has usable thumbnails, stable split body/fallback architecture, a two-column grid, visible background previews, an acceptable three-quarter crop, textless item cards, and hidden empty categories. Historical issues/checklists remain in the Phase 2B report.

## Audit source and provenance

Primary source:

```text
C:\Users\ADMIN\Desktop\keri_asset_audit\01_extracted_original\
Keri-Dressup-RenPy-Template\Keri-Dressup-RenPy-Template\
game\Create_Character\
```

This report calls it the **local extracted PNG source/template set**, not the full original Keri set. Provenance remains Konett for original Keri material and LunaLucid/Namastaii for the Ren'Py template/adaptation, with the license caveats recorded in `LICENSE_PROVENANCE.md`.

The complete per-file inventory is `PHASE_2C_APPEARANCE_INVENTORY.json`. It records source path, filename, SHA256, width, height, mode, alpha, visible bounds, category, subgroup, potential runtime category, compatibility, compatibility reason, Phase 2C include/exclude decision, destination, and provenance note for every audited appearance PNG.

## Inventory summary

All 136 audited files are RGBA PNG, `948x1920`, transparent, and aligned to origin `(0, 0)`.

| Source group | Count | Phase 2C decision |
|---|---:|---|
| Base | 5 | Include all as mandatory skin variants |
| Hair | 75 | Include all; 5 combined styles x 15 colors |
| Eyes | 30 | Include all; 3 shapes x 10 colors |
| Eyebrows | 5 | Include all |
| Mouth | 5 | Include all |
| Misc blush | 2 | Include as makeup |
| Misc tears/sweat/expression effects | 14 | Exclude from proof; outside requested slots and includes duplicate/effect variants |

No `Eyelashes`, `Lips`, `Makeup`, or separate `Face` source directory exists. Eyelashes therefore have no runtime category or empty UI subcategory. Blush is sourced from `Misc`.

## Base1 through base5 classification

`Base/base1.png` through `Base/base5.png` qualify as skin variants:

- identical `948x1920` RGBA canvas and `(0, 0)` origin;
- identical alpha bounds `(62, 44, 922, 1920)`;
- identical nonzero pixel occupancy: `818390`;
- byte-identical alpha masks, silhouette, anatomy, pose, and body geometry;
- no scaling, warp, crop, or reposition required;
- no clothing or facial-feature layer baked in;
- visible differences are skin color and shading.

| Source | SHA256 | Runtime mapping |
|---|---|---|
| `Base/base1.png` | `555132e38e2ec9efbdbf1e2e034f32fab36f01752e264457daed5993a578386c` | Existing immutable `keri_body_core.png`; `skin_tone_01` |
| `Base/base2.png` | `acaf24d1ed69c6a6081c16c50f58f2451f4f65745f242dc80ca0bf45dec3f433` | `skins/skin_tone_02.png` |
| `Base/base3.png` | `e527f14ccdd6fa9452d5a6078eed9bb8cc5341e4ddccd1e6252f72cfc7a0aaae` | `skins/skin_tone_03.png` |
| `Base/base4.png` | `9894628e3eb2367cc644f1df525b36d6eeeb9df6063e11dcd3473c1e2b1c374a` | `skins/skin_tone_04.png` |
| `Base/base5.png` | `a9e1847597569ec1a354058c7daaa99523ef95233927061566afc4cea7a24f04` | `skins/skin_tone_05.png` |

Skin has no none item. Skin 01 reuses the immutable Phase 2B body anchor; skin 02-05 provide the same `body_core` layer role. The three Phase 2B anchor hashes and provenance remain unchanged.

## Source-to-destination mapping

Only appearance runtime PNGs needed by Phase 2C were copied; no archive, PSD, donor-leg output, experimental output, or wardrobe tree was copied.

| Source pattern | Destination pattern | Count |
|---|---|---:|
| `Base/base2..5.png` | `assets/characters/keri/skins/skin_tone_02..05.png` | 4 |
| `Hair/hair{1..5}_{1..15}.png` | `assets/hair/keri/phase_2c/hair_style_{01..05}_color_{01..15}.png` | 75 |
| `Eyes/eyes{1..3}_{1..10}.png` | `assets/face/keri/eyes/eyes_style_{01..03}_color_{01..10}.png` | 30 |
| `Eyebrows/eyebrows{1..5}_1.png` | `assets/face/keri/eyebrows/eyebrows_tone_{01..05}.png` | 5 |
| `Mouth/mouth{1..5}_1.png` | `assets/face/keri/mouths/mouth_tone_{01..05}.png` | 5 |
| `Misc/blush.png`, `blush_2.png` | `assets/face/keri/makeup/blush_01.png`, `blush_02.png` | 2 |

The 121 copied files retain their original bytes. `base1.png` is not duplicated because the required immutable `keri_body_core.png` already has the same hash.

## None policy

- Mandatory, no none: `skin` / `body_core`.
- Optional, visible none tile: hair, eyes, eyebrows, mouth, makeup, top, bottom, dress, and background.
- Hidden/future optional categories retain their existing none behavior where applicable.
- `top_none` and `bottom_none` activate renderer-owned fallback layers; `dress_none` disables dress.
- `background_none` returns to the renderer's default studio background.
- None items contain `render_key = "none"`, no PNG layers, accessible labels/tooltips, and use the existing X tile.
- Random eligibility is explicit per item. Hair/eyes/eyebrows/mouth none items are excluded from random; makeup none is eligible. Skin can never randomize to none.

## Catalog, state, and save changes

- Catalog schema is version 2 with 15 state categories and 180 items.
- New state slots: skin, eyes, eyebrows, mouth, and makeup; hair gains none and the audited variants.
- `face` remains a hidden UI container/migration slot. The Phase 2B composite item is hidden and `legacy_migration_only`; runtime defaults use `face_none` plus separate features.
- `ItemCatalog` loads parent/container navigation metadata, returns only non-empty subcategories, and excludes migration-only IDs during save sanitization.
- `GameState` remains the owner of selections, locks, compatibility, random, reset, history, and save state. Save version 2 includes every new slot.
- Version-1 Phase 2B saves load without crash. Missing new slots fall back to valid defaults, valid locks remain, and the legacy composite face sanitizes to `face_none` to prevent double rendering.

## UI and thumbnail behavior

Main categories remain `Tóc` and `Khuôn mặt` alongside the existing supported fashion/background categories. `Khuôn mặt` exposes data-driven subcategory buttons for `Màu da`, `Mắt`, `Lông mày`, `Miệng`, and `Trang điểm`; empty groups are omitted.

The existing two-column, textless, vertically scrolling item grid and selected styles are retained. Thumbnail preview modes are metadata-driven after the polish pass:

- skin: opaque representative color swatch only;
- eyes/eyebrows/mouth/makeup: the selected layer's own visible feature bounds on a neutral background;
- hair: hair-only visible-alpha bounds with reduced padding and a neutral background;
- none: existing X tile;
- background: procedural cover preview.

## Hair integration

The audited source has five hair silhouettes with 15 color variants each. Each PNG is a single combined hair layer; no separate front/back files exist. All 75 variants map to `hair_front` and are tagged `combined_hair`. The renderer remains capable of consuming multiple named layers from future item metadata, but Phase 2C does not AI-split, edit, crop, or rewrite these production PNGs.

Hair has a manual none choice. When selected, the item contributes no layers and the renderer emits no `hair_front`/`hair_back` path.

## Face layers

Eyes, eyebrows, mouth, and makeup render independently on the shared canvas without transform. The source has no eyelash layer. The Phase 2B composite face remains only as a migration ID and is not used by the Phase 2C default runtime.

## Face anchor and mask metadata

`data/catalog.json -> character.face_import_metadata` is the single authoritative location:

- `face_rect`: `[270, 210, 320, 270]`
- `face_center`: `[430, 345]`
- default scale: `1.0`
- default rotation: `0.0` degrees
- safe clipping bounds: `[270, 210, 320, 270]`
- face mask bounds: `[286, 220, 288, 250]`
- head preview rect: `[190, 40, 560, 540]`
- skin preview rect: `[120, 20, 700, 900]`
- explicit arrays of layers before and after the metadata-only `imported_face` seam

All rectangles are validated inside `948x1920`. These values prepare a future renderer seam only. No file picker, real face image, recognition, biometric processing, upload, or network service was added.

## Runtime layer order

```text
background
hair_back
accessory_back
body_core / selected skin
fallback_bottom
fallback_top
base_outfit
shoes
bottom
top
dress_back
dress_main
body_foreground
imported_face (metadata only)
legacy face
eyes
eyebrows
eyelashes (reserved, no source/category)
mouth
makeup
hair_front / combined hair
glasses
face_accessory
headwear
accessory_front
effect_front
```

Fallback visibility remains atomic: a selected dress hides both fallbacks/separates; selected top/bottom hide only their matching fallback. Skin and face changes do not alter coverage logic.

## Automated coverage

Validator and Godot smoke coverage now includes:

- immutable Phase 2B body/fallback hashes and rejection of the flattened clothed base;
- exact runtime skin hashes and paths;
- skin mandatory/no-none and optional-slot none policy;
- non-empty face subcategory navigation and absent eyelash category;
- all layer PNG paths, RGBA mode, and `948x1920` canvas;
- skin swap coverage; combined hair and hair-none rendering;
- independent face layers and their order;
- thumbnail modes and centralized preview rectangles;
- selection, locks, random, reset, undo/redo, save/load, and version-1 migration;
- face/mask/clip metadata bounds.

Final automated result:

- `python tools/validate_catalog.py`: `Catalog valid: 15 categories, 180 items.`
- `check_project.ps1`: Godot 4.7 import/parse passed; startup smoke passed; logic smoke printed `SMOKE TEST PASSED`; `Project checks passed.`

Godot dummy-renderer cleanup/leak warnings remain informational and do not produce a nonzero result.

## Limitations

- Hair is combined and cannot provide true behind-body/front-of-face separation from this source.
- No eyelash PNG exists.
- Tears and sweat/expression effects are audited but excluded.
- Keri remains a conditional proof candidate, not a final product anchor.
- Automated checks do not establish visual alignment, thumbnail readability, or art quality.
- Browser export/QA is not part of this non-web milestone.

## Accepted manual visual QA / regression checklist

- Confirm all five skin choices keep identical pose/scale/alignment and fallback coverage.
- Confirm all five skin tiles contain only color, fill nearly the whole card, and are distinguishable without character imagery.
- Confirm hair none removes all hair; sample all five silhouettes and multiple colors.
- Confirm hair thumbnails are centered, large, hair-only, and consistently backed.
- Confirm eyes, eyebrows, mouth, and makeup change independently and optional none tiles work.
- Confirm each face-feature thumbnail shows only the relevant eyes/eyebrows/mouth/blush region rather than a full head/body.
- Confirm face features align on every skin tone without unwanted outlines or double-rendered legacy face.
- Confirm skin/face/hair previews are readable, centered, textless, and selected borders are clear.
- Confirm `Khuôn mặt` subcategories show only non-empty groups and the grid remains two columns with vertical-only scrolling.
- Exercise locks, random, reset, undo, redo, save/load, and a legacy save through the visible UI.
- Confirm fallback top/bottom behavior and the accepted three-quarter crop remain unchanged.
- Confirm no local face-import UI, real-person image, foot-dependent content, or Phase 3 feature appears.
- Confirm clean launch/reset uses skin 01 with hair, eyes, eyebrows, mouth, makeup, and legacy face all none; valid pre-existing saves may still restore their saved appearance before reset.

## Explicit boundary confirmation

- Phase 2C is **COMPLETE**.
- Phase 3A, Phase 3B, and Phase 3C were not started.
- Local face import was not implemented.
- No wardrobe bulk import, full-body, donor-leg, shoes, socks, long trousers, or full-length dresses were added.
- No production PNG was modified.
- No commit was made.
- No push was made.
