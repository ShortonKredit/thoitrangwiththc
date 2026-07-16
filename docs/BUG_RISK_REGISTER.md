# Bug and Risk Register

| Risk | Priority | Prevention / Test |
|---|---:|---|
| Incorrect front/back layer order | Critical | Fixed layer order; visual test every content pack |
| Base outfit accidentally becomes wardrobe state | Critical | Renderer-owned invariant; smoke tests for state/save/random/reset |
| Character exposed when top/bottom/dress are none | Critical | Base outfit invariant; manual visual check in all-none state |
| Dress remains with top/bottom | Critical | Slot metadata + smoke test |
| Locked category changes during random | Critical | Lock-aware candidate selection + smoke test |
| Undo restores only part of state | High | Snapshot selected + locks as one history entry |
| Save refers to deleted item ID | High | Catalog sanitization on load |
| Hard-coded item/category counts | High | Catalog-driven UI/state; diff review and smoke tests |
| Thumbnail metadata creates blank cards or crashes | High | Optional text fallback; `res://` validation; smoke tests |
| AI asset misalignment | Critical | One anchor, shared canvas, proof pack, visual checklist |
| Unlicensed/proprietary character dependency | Critical | Phase 2A source/license audit before import |
| PNG export contains wardrobe UI | High | Capture only `DollView` rect |
| Web build works natively but fails in browser | High | Local HTTP test, DevTools Console/Network |
| Browser storage unavailable/private mode | Medium | Graceful fallback; do not promise persistence |
| Asset file missing or wrong path | High | import check + warning + manual asset test |
| Random creates invalid combination | High | generic slot/tag compatibility; lock-aware selection |
| UI overflows at small window sizes | Medium | desktop-first minimum; test 1280x720 and 1440x900 |
| Face photo accidentally uploaded | Critical | no backend/API; future network inspection and privacy test |
| Keri lower legs and feet missing | Medium | Deferred out of MVP; verify three-quarter crop hides the missing lower body intentionally |
| Keri license/provenance overstated | High | Preserve Konett attribution, LunaLucid/Namastaii provenance, and exact license-version caveats from `docs/asset_audits/keri/` |
| Keri treated as final anchor too early | High | Phase 2A decision is conditional only; require later visual and owner acceptance gates |
| Three-quarter crop looks like a broken asset | High | Visual QA the lower framing in Godot and web; adjust viewport/crop before content expansion |
| Unsupported long item exceeds MVP crop | High | Keep full-length trousers, full-length dresses, socks, and shoes out of MVP catalog/UI; test every imported item |
| Shoes category appears empty in MVP UI | Medium | Hide/defer unsupported categories instead of showing blank categories; manually inspect category list |
| Old save contains deferred category/item | High | Sanitize saves against current catalog and disabled categories; smoke-test legacy save migration |
| Random selects unsupported item | High | Filter random candidates by enabled MVP categories/items; smoke-test random with locks |
| Roadmap drift reopens full-body work | Medium | Start phases from `PHASE_STATUS.md`, `ROADMAP.md`, and `MVP_SCOPE_DECISION.md`; diff-review prompts/docs |
| Phase 2B PNG proof passes automation but fails visual QA | High | Manual Godot/browser inspection before marking final acceptance; verify crop, layer alignment, and UI category visibility |
| Phase 2B thumbnail-first UI regresses usability | Medium | Manual QA the two-column grid, selected/hover/focus states, none tile, and text removal before marking Phase 2B complete |
| Skin variant changes body geometry or breaks fallback coverage | Critical | Validate exact hashes/canvas; classify identical alpha masks; smoke-test selected skin with fallback coverage |
| Optional appearance slot cannot be removed | High | Catalog none policy plus smoke tests for hair/eyes/eyebrows/mouth/makeup |
| Mandatory skin becomes none through random/save migration | Critical | Skin category forbids none; sanitize saves to a valid default; test random/reset/load |
| Separate facial features render in the wrong order | High | Central catalog layer order; smoke-test ordering; manual alignment check |
| Empty eyelash or face subcategory appears | Medium | Build subcategory navigation from non-empty catalog categories; keep absent source groups out |
| Combined hair is mistaken for a true front/back split | Medium | Tag/document combined mode; map only to `hair_front`; do not edit or AI-split production PNGs |
| Face anchor/mask magic numbers drift across files | High | Store authoritative rectangles/transforms in `character.face_import_metadata`; validate canvas bounds |
| Legacy Phase 2B composite face double-renders with separate features | High | Mark composite migration-only; save sanitization falls back to `face_none`; version-1 migration smoke test |
| Face thumbnails are too small or show isolated pixels | Medium | Crop each feature's alpha bounds, apply category-appropriate padding on a neutral background, and manually QA final tile size |
| Skin swatches accidentally render character imagery or nearly identical colors | Medium | Dedicated `skin_swatch` mode with validated opaque representative colors; manual comparison at tile size |
| Feature thumbnails show the whole face/body instead of the selected feature | Medium | Per-item alpha-bound `feature_crop` metadata, neutral background, canvas-bound validation, and mode smoke tests |
| Hair thumbnails are tiny or off-center | Medium | Hair-only visible bounds, reduced metadata padding, square centered fitting, and manual review across all five shapes |
| Reset or clean launch restores old preset hair/face features | High | Catalog default explicitly uses skin 01 and none IDs; smoke-test initialization, reset, save/load fallback, and legacy migration |
| Removed Phase 3A actions remain reachable through product UI/keyboard focus | High | Build only three public action nodes; smoke-test names/count/tooltips/focus; remove R/F11 UI shortcuts and clear-save dialog |
| Undo/Redo icon disabled state drifts from history | High | Drive buttons from `history_changed`; action-bar smoke test both disabled-state combinations |
| Reset save is overwritten by the pre-reset outfit after relaunch | Critical | Save on the normal state-change signal; isolated local-save smoke test Reset and reinitialize from disk |
| Undo Reset restores only part of the outfit | Critical | Reset is one full snapshot; test Undo/Redo across garment, appearance, background, and locks |
| New selection after Undo leaves stale Redo history | High | `HistoryManager.record` truncates the forward slice; smoke-test branching after Undo Reset |
| Audited garment bytes drift from source mapping | Critical | 184-entry inventory plus validator SHA256 checks for every included destination/catalog item |
| Renderer fallback bytes become redundant selectable garments | High | Inventory marks the two duplicate sources excluded; validator rejects their hashes in item layers |
| Long trousers or skirt continuation looks unnaturally cut at the three-quarter viewport | Critical | Keep source PNGs intact; audit actual viewport composites, record `viewport_continuation`, and manual-inspect all 12 accepted variants |
| Bottom UI groups accidentally create multiple simultaneous bottom slots | Critical | Keep every short/trouser/skirt item in category `bottom`; use navigation-only `item_groups`/`ui_group`; smoke-test replacement and fallback coverage |
| Face effect is baked into defaults or misaligned with facial features | High | Independent `face_effect` slot defaults to `effect_none`; alpha-focused thumbnails, render-order checks, migration tests, and manual alignment QA |
| Duplicate tears source becomes two indistinguishable runtime choices | Medium | Inventory records the shared SHA256 and maps `tears1.png` to the single retained `tears.png` runtime item |
| Huge flat garment list loses style/color relationships | Medium | Store `style_id`, `color_id`, and `variant_group`; defer complex picker UI without losing grouping metadata |
| Garment thumbnail shows full transparent canvas or unreadable item | High | `top_crop`/`bottom_crop` metadata with audited bounds, neutral background, padding, and manual final-size review |
| Archive or PSD enters runtime assets | High | Validator recursively rejects `.psd`, `.zip`, `.rar`, and `.7z` under `assets/` |
