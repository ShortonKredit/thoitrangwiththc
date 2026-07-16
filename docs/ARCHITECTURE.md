# Architecture

## Data flow

```text
data/catalog.json
        ↓
ItemCatalog (load + validate + sanitize)
        ↓
GameState (selection + compatibility + locks + history)
        ↓
Main UI                         DollView
(category/item controls)        (base outfit + procedural or PNG rendering)
        ↓                            ↓
SaveService                    PNG capture
(user:// / IndexedDB)          local download only
```

## Content model

Each item has:

- stable `id`
- `category`
- display name/description
- `render_key` for procedural placeholders
- `occupies` slots
- `tags` and `conflicts_with_tags`
- `random_enabled`
- optional `thumbnail_path`
- optional `accessible_name`
- `layers` for future PNG paths
- placeholder colors
- optional `preview_mode` for data-driven thumbnail composition
- optional `legacy_migration_only` for IDs retained solely to sanitize old saves

Categories may declare `parent_category` for subcategory navigation. A hidden category with `ui_container = true` can remain a state/migration slot while exposing only non-empty child categories in the main UI. Phase 2C uses this for `Khuôn mặt` -> skin, eyes, eyebrows, mouth, and makeup.

`thumbnail_path` is optional. When it is missing or empty, the wardrobe UI keeps using `display_name` text. When it is present, it must use a `res://` path. `accessible_name` falls back to `display_name`.

## Compatibility

Compatibility is generic:

- Dress occupies `top` and `bottom`.
- Top occupies `top` and therefore clears an active dress.
- Bottom occupies `bottom` and therefore clears an active dress.
- Tag conflicts cover cases such as a cap versus voluminous hair.

No per-ID outfit rules should be added to UI code.

## Base outfit invariant

`DollView` always renders a modest base outfit above the body and below all player-selectable fashion layers. It is not a catalog item, not part of selected state, not saved, not randomized, not lockable and not removable through undo/redo/reset.

Layer intent:

```text
body
base_outfit
shoes / bottom / top / dress / accessories
```

For the future PNG path, `character.layer_order` includes `base_outfit`; the path can be supplied later through `character.layers` without changing wardrobe state logic.

In the Keri PNG proof, the invariant is implemented by renderer-owned `fallback_top` and `fallback_bottom`. A selected skin supplies the `body_core` layer role, but cannot be `none`; fallback coverage rules are unchanged by skin swaps.

## Phase 2C appearance state

Independent state categories are `skin`, `hair`, `eyes`, `eyebrows`, `mouth`, and `makeup`. The old `face` composite category is hidden and migration-only. All optional categories have catalog-defined none items; skin is mandatory and has no none item. Random eligibility is item metadata (`random_enabled`), so none is not implicitly chosen for every optional slot.

The local source has combined hair only. Each hairstyle maps to `hair_front`; no artificial split or production-PNG edit is performed. The renderer still supports multi-layer hair through an item's `layers` dictionary if a future source provides `hair_back` and `hair_front`.

Centralized `character.face_import_metadata` stores face/head preview rectangles, `face_rect`, `face_center`, safe clipping bounds, mask bounds, default transform, and layers before/after the metadata-only `imported_face` seam. Phase 2C does not implement file selection, face recognition, biometric analysis, or real-person image handling.

MVP note: shoes remain an architectural/future layer concept, but shoes and other foot-dependent items are deferred and should not appear as empty MVP UI categories.

## Rendering modes

### procedural

Default mode in this repository. It guarantees a runnable project without external assets.

### png

When a complete body and test content pack exists:

1. Add character/body paths to `character.layers`.
2. Add item paths to each item's `layers`.
3. Change `character.mode` to `png`.
4. Run smoke tests and visual layer checks.

## Persistence

Only selected item IDs and lock flags are saved. Save version 2 includes all Phase 2C category IDs. Saves are sanitized against the current catalog, so removed, renamed, wrong-category, or migration-only IDs fall back to defaults. Phase 2B version-1 saves remain loadable.

No database or account is required.
