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
(category/item controls)        (procedural or PNG rendering)
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
- `layers` for future PNG paths
- placeholder colors

## Compatibility

Compatibility is generic:

- Dress occupies `top` and `bottom`.
- Top occupies `top` and therefore clears an active dress.
- Bottom occupies `bottom` and therefore clears an active dress.
- Tag conflicts cover cases such as a cap versus voluminous hair.

No per-ID outfit rules should be added to UI code.

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
