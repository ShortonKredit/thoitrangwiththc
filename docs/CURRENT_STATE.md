# Current State

Date: 2026-07-14

Baseline: Phase 0, Phase 1, and Phase 1.1 are complete. Phase 1.2 is the current documentation rebaseline and engineering-loop alignment phase.

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

- Catalog validation passes with 9 categories and 45 items.
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

- Character, clothing, hair, accessories, and backgrounds are still procedural placeholders.
- `thumbnail_path` support exists, but the current catalog does not depend on real thumbnail assets.
- Future PNG layer paths are scaffolded but not production art.
- Web export foundation exists, but browser QA is deferred until a web-focused phase.

## Not Yet Fully Visually Verified

- Final layer alignment and body coverage with real PNG assets.
- Skin tone, leg anatomy, face style, hair front/back separation, and face mask quality.
- Thumbnail readability and crop quality.
- Browser rendering across Chrome, Edge, and Firefox after export.
- Small viewport behavior beyond the captured Phase 1 screenshots.

## Asset Direction

The asset direction is not locked. Keri is only a candidate reference for a future proof phase, not an official dependency, not imported content, and not a required art source.

## Phase Boundary

- Phase 2 has not started.
- No Keri download/import has been performed in this phase.
- No AI asset generation has been performed in this phase.
- No backend, database, login, API, or CI work has been added.
