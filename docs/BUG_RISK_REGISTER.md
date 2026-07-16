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
