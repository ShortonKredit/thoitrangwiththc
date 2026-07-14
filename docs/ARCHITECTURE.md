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

Only selected item IDs and lock flags are saved. Saves are sanitized against the current catalog, so removed/renamed IDs fall back to defaults.

No database or account is required.
