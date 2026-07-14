# Bug and Risk Register

| Risk | Priority | Prevention / Test |
|---|---:|---|
| Incorrect front/back layer order | Critical | Fixed layer order; visual test every content pack |
| Dress remains with top/bottom | Critical | Slot metadata + smoke test |
| Locked category changes during random | Critical | Lock-aware candidate selection + smoke test |
| Undo restores only part of state | High | Snapshot selected + locks as one history entry |
| Save refers to deleted item ID | High | Catalog sanitization on load |
| AI asset misalignment | Critical | One anchor, shared canvas, proof pack, visual checklist |
| PNG export contains wardrobe UI | High | Capture only `DollView` rect |
| Web build works natively but fails in browser | High | Local HTTP test, DevTools Console/Network |
| Browser storage unavailable/private mode | Medium | Graceful fallback; do not promise persistence |
| Asset file missing or wrong path | High | import check + warning + manual asset test |
| Random creates invalid combination | High | generic slot/tag compatibility; lock-aware selection |
| UI overflows at small window sizes | Medium | desktop-first minimum; test 1280×720 and 1440×900 |
| Face photo accidentally uploaded | Critical | no backend/API; future network inspection and privacy test |
