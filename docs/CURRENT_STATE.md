# Current State

Date: 2026-07-16

Baseline: Phase 0, Phase 1, Phase 1.1, Phase 1.2, Phase 2A, and Phase 2B are complete. The owner accepted Phase 2B manual visual QA. Phase 2C skin, face, and hair layering is implemented and passes automated checks; Phase 2C manual visual QA is pending.

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

- Catalog validation passes with 15 state categories and 180 items.
- Godot 4.7 import, parse, startup smoke, and logic smoke tests pass locally.
- Main scene runs locally in Godot.
- Category and item selection are data-driven.
- Compatibility clears conflicting top/bottom/dress selections through slot metadata.
- Random respects category locks.
- Undo/redo operate on full state snapshots.
- Reset is available and keeps the base outfit invariant.
- Local save/load is sanitized against the current catalog.
- PNG capture exists for the doll view.
- Header text has been simplified to the player-facing title.
- Optional `thumbnail_path` and `accessible_name` metadata exist with text fallback.
- Phase 2B selector thumbnails are generated in memory from preview modes: alpha visible bounds for PNG layers, body+face crop for face items, procedural cover previews for backgrounds, and a drawn X for none items.
- Phase 2C adds five silhouette-identical skin variants, 75 combined-hair variants, 30 eye variants, five eyebrow variants, five mouth variants, and two blush layers from the local extracted PNG source/template set.
- The `Khuôn mặt` main category exposes only non-empty, data-driven subcategories: `Màu da`, `Mắt`, `Lông mày`, `Miệng`, and `Trang điểm`. No eyelash subcategory is shown because the audited source contains no eyelash PNG.
- Save schema version 2 restores all Phase 2C slots and sanitizes the legacy Phase 2B composite face to separate defaults.

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
- Web export foundation exists, but browser QA is deferred until a web-focused phase.

## Phase 2C Manual Visual QA Pending

- Skin swaps preserve visible alignment and fallback outfit coverage.
- Independent eyes, eyebrows, mouth, and makeup layers align with the head.
- All five hair shapes and their color variants remain readable; hair `none` removes hair completely.
- Face and skin thumbnails are readable at final tile size.
- Combined-hair front-only ordering is acceptable for the available source.
- Face anchor and mask-bound metadata is suitable as a future local-import seam without implementing import.
- Browser rendering across Chrome, Edge, and Firefox after export.
- Small viewport behavior beyond the captured Phase 1 screenshots.

## Asset Direction

Keri remains a conditional three-quarter-body proof candidate, not a final art anchor. The Phase 2B and Phase 2C runtime PNG proof assets are imported with the existing provenance caveats.

## Phase Boundary

- Phase 2A is complete as a documentation-only Keri asset/license audit.
- Phase 2B three-quarter-body integration proof is complete after owner-confirmed manual visual QA.
- Phase 2C appearance layering is implemented and remains `MANUAL VISUAL QA PENDING`.
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
- MVP-supported categories: hair, face/facial features, tops, short bottoms, short dresses, and accessories.
- Deferred/post-MVP: full-body leg extension, shoes, socks, full-length trousers, full-length dresses, and any item that requires visible feet.
- Shoes-related architecture may remain for future work, but shoes should not appear as an empty MVP UI category.
