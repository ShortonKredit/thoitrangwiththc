# Current State

Date: 2026-07-16

Baseline: Phase 0 through Phase 2C are complete. Phase 3A content completion is implemented, passes automated checks, and remains **MANUAL VISUAL QA PENDING**. Phase 3B Local Face Import is not started. Phase 3C-A GitHub Pages preview exports and passes local HTTP/Chrome smoke; cross-browser/mobile manual QA and deployment remain pending.

## Current Architecture

The project is a Godot 4.7 Standard, Compatibility-renderer, 2D layered dress-up toy.

```text
data/catalog.json
        |
        v
ItemCatalog -> GameState -> Main UI
        |          |          |
        |          |          v
        |          |       DollView
        |          |          |
        v          v          v
catalog validation, compatibility, local save, procedural/PNG rendering
```

- `data/catalog.json` is the content source of truth.
- `scripts/core/item_catalog.gd` validates catalog data and sanitizes saved IDs.
- `scripts/core/game_state.gd` owns selected item IDs, compatibility rules, category locks, undo/redo history, reset, and snapshots.
- `scripts/rendering/doll_view.gd` draws the procedural placeholder character and is prepared for future PNG layers.
- `scripts/main.gd` builds the player UI from catalog/category data and does not own per-item rendering rules.
- `scripts/core/save_service.gd` stores local save data only.

## Working Features

- Catalog validation passes with 16 state categories and 236 items.
- Godot 4.7 import, parse, startup smoke, and logic smoke tests pass locally.
- Main scene runs locally in Godot.
- Category and item selection are data-driven.
- Compatibility clears conflicting top/bottom/dress selections through slot metadata.
- Random remains a tested backend contract and respects category locks, but it is not exposed in the Phase 3A product UI.
- Undo/redo operate on full state snapshots.
- Reset is available and keeps the base outfit invariant.
- Local save/load is sanitized against the current catalog.
- PNG capture, fullscreen, and clear-save helpers remain reusable backend code but are not exposed in the Phase 3A product UI.
- Header text has been simplified to the player-facing title.
- Optional `thumbnail_path` and `accessible_name` metadata exist with text fallback.
- Phase 2B selector thumbnails are generated in memory from preview modes: alpha visible bounds for PNG layers, body+face crop for face items, procedural cover previews for backgrounds, and a drawn X for none items.
- Phase 2C adds five silhouette-identical skin variants, 75 combined-hair variants, 30 eye variants, five eyebrow variants, five mouth variants, and two blush layers from the local extracted PNG source/template set.
- The `Khuôn mặt` main category exposes non-empty, data-driven skin, eyes, eyebrows, mouth, makeup, and effect groups. No eyelash subcategory is shown because the audited source contains no eyelash PNG.
- Save schema version 3 adds the independent `face_effect` slot; version-1/version-2 saves sanitize missing effects to `effect_none` and the legacy composite face to separate defaults.
- The polished clean/reset default is `skin_tone_01` with hair, legacy face, eyes, eyebrows, mouth, and makeup all set to their `none` items. Existing valid saves still restore their saved appearance until the player resets.
- Skin selector thumbnails are opaque representative color swatches; they no longer render a miniature character.
- Eyes, eyebrows, mouth, and makeup thumbnails crop only their own visible feature bounds on a consistent neutral background.
- Hair thumbnails use hair-only visible bounds, reduced padding, a neutral background, and centered fitting.
- Phase 3A audits all 184 PNGs and integrates 29 tops, five shorts, six trousers, six skirts, and 13 unique face effects.
- The action bar contains only textless Undo, Redo, and Reset icon buttons with tooltip, accessibility, focus, hover, pressed, and disabled states.
- Reset is one undoable history action, persists the catalog default locally, supports Redo, and clears the redo branch after a new post-Undo selection.
- Product garments/effects store style/color/variant metadata and use focused alpha-bound thumbnails on a neutral background.
- The clean/reset background selection is `background_none`, which renders the default studio background.

## Mandatory Invariants

- The project remains 2D layered; no 3D migration.
- No login, account, backend, database, API, ads, gacha, currency, chat, or leaderboard.
- Catalog item/category counts stay data-driven and must not be hard-coded.
- `base_outfit` is renderer-owned and mandatory.
- `base_outfit` is not a catalog item, selected item, saved item, random candidate, lockable category, undo/redo target, or reset target.
- `top = none`, `bottom = none`, and `dress = none` is a valid state.
- Missing thumbnails fall back to text. Invalid thumbnail metadata must be rejected or fail safely.
- `display_name` remains required even after thumbnails exist.
- Visual correctness requires a human Godot/browser check.

## Placeholder Features

- The active character and tiny Keri proof pack render through PNG layers.
- The legacy placeholder catalog remains for migration/procedural reference, but non-proof fashion items are hidden from the Phase 2B UI where needed.
- `thumbnail_path` support exists, but the current catalog does not depend on real thumbnail asset files.
- Future PNG layer paths are scaffolded but not production art.
- Web preset/scripts produce a single-threaded GitHub Pages build under `docs/`; local SVG action icons avoid Web font-glyph dependencies.

## Phase 2C Closure

Phase 2C is complete per the Phase 3A start gate. Its skin/face/hair defaults, layering, thumbnail strategy, save migration, and metadata-only future face seam remain unchanged.

## Phase 3A Manual Visual QA Pending

- Readability and states of the three action icons at target viewports.
- Alignment, fallback coverage, and crop quality for 29 tops, five shorts, six trousers, and six skirts.
- Face alignment and focused thumbnails for 13 unique sweat/tears effects.
- Focused garment thumbnails, two-column vertical scrolling, none tiles, and selected borders.
- Reset persistence plus Undo/Redo Reset through the visible product UI.
- Phase 2C appearance and three-quarter-body crop regression checks.

## Asset Direction

Keri remains a conditional three-quarter-body proof candidate, not a final art anchor. The Phase 2B and Phase 2C runtime PNG proof assets are imported with the existing provenance caveats.

## Phase Boundary

- Phase 2A is complete as a documentation-only Keri asset/license audit.
- Phase 2B three-quarter-body integration proof is complete after owner-confirmed manual visual QA.
- Phase 2C appearance layering is complete.
- Phase 3A content completion is implemented with data-driven bottom groups and Face -> Effect; it remains `MANUAL VISUAL QA PENDING`.
- Phase 3B Local Face Import is not started.
- Phase 3C-A Web Preview is `MANUAL WEB QA PENDING`; a local build exists, but no public deployment has been committed/pushed or verified.
- Full-body leg extension is deferred/post-MVP.
- Keri proof PNG assets have been imported into Godot under `assets/**/keri/proof/`.
- No AI asset generation has been performed in this phase.
- No backend, database, login, API, or CI work has been added.

## Phase 2A Audit Result

- Decision: CONDITIONAL GO TO PHASE 2B.
- Audit docs: `docs/asset_audits/keri/`.
- Later MVP decision: GO TO THREE-QUARTER-BODY MVP INTEGRATION.
- Keri remains a proof candidate, not a final character anchor.
- Main finding: the body candidate has usable upper body and thighs; missing lower legs, ankles, and feet are no longer MVP blockers because the MVP crop is three-quarter-body.
- Bottom finding: short bottoms and short dresses are MVP-appropriate; shoes, socks, full-length trousers, and full-length dresses are deferred.
- License finding: Konett attribution is required; LunaLucid/Namastaii template provenance should be retained; template README license version remains unspecified by available template evidence.

## MVP Scope

- MVP character presentation: three-quarter-body Keri canvas.
- MVP-supported categories: hair, face/facial features, tops, short bottoms, and background; short dresses/accessories remain supported in architecture but no compatible production source exists in this audit.
- Deferred/post-MVP: full-body leg extension, shoes, socks, full-length trousers, full-length dresses, and any item that requires visible feet.
- Shoes-related architecture may remain for future work, but shoes should not appear as an empty MVP UI category.
