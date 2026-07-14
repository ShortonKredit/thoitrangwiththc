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
