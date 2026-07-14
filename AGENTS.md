# AGENTS.md

## Project Identity

- Project: **Thoi Trang with THC**.
- Engine: **Godot 4.7 Standard**.
- Language: **GDScript**.
- Renderer: **Compatibility**.
- Product: a **2D layered dress-up toy** for desktop web.
- Character direction: female teenager, everyday fashion, stylized proportions, **not chibi**, not strongly magical/fantasy.

## Hard Constraints

1. Do not convert the project to 3D.
2. Do not add login, account, chat, leaderboard, gacha, currency, ads, API services, backend services, or a user database unless the user explicitly starts a later milestone for that.
3. Do not upload a user's face/photo to any server, analytics service, or external AI API.
4. Do not rewrite the whole project when an incremental refactor is possible.
5. Do not remove working behavior unless a tested replacement exists.
6. Item count and category options must be data-driven; never hard-code ranges such as `0..3`.
7. Do not change item/category counts unless the milestone explicitly asks for content changes.
8. New wardrobe content should normally require only PNG files plus catalog metadata.
9. Keep the repository runnable after every milestone.
10. Do not claim visual correctness without a visual check in Godot/browser.
11. Do not use copyrighted Winx, Barbie, or other proprietary characters/assets.
12. Do not commit or push unless the user explicitly requests it.
13. Do not start the next phase or milestone on your own.
14. For the MVP, full-body leg extension, shoes, socks, full-length trousers, full-length dresses, and foot-dependent items are out of scope unless the user explicitly starts a later post-MVP milestone.

## Long-Lived Invariants

- `data/catalog.json` is the content source of truth.
- UI code must not contain per-item rendering rules or fixed item counts.
- `item_catalog.gd` loads and validates content.
- `game_state.gd` owns selections, compatibility, locks, undo/redo history, reset behavior, and save-state sanitization.
- `doll_view.gd` renders either procedural placeholders or future PNG layers.
- Slot conflicts should be expressed through metadata (`occupies`, tags, and conflict tags).
- Saved state must be versioned and sanitized against the current catalog.
- The renderer-owned `base_outfit` is mandatory. It is not a wardrobe item, not selected state, not saved, not randomized, not lockable, and not removable through reset/undo/redo.
- The state where `top`, `bottom`, and `dress` are all `none` is valid because the base outfit still covers the character.
- `thumbnail_path` is optional. Missing thumbnails must fall back to text, and invalid/missing thumbnail resources must not create blank cards or crashes.
- Keep `display_name` and `accessible_name`; do not make thumbnail-only UI before real assets are available and verified.
- Automated checks do not replace visual QA for layout, layer alignment, body coverage, thumbnails, browser rendering, or final art quality.
- Do not add fake AI assets or mass-produce assets just to satisfy tests. Real content expansion must wait for the proof-pack gate.

## Required Engineering Loop

For each milestone:

1. Read this file and the relevant files under `docs/`.
2. Check `git status`, `git log --oneline -5`, and `git remote -v`; avoid unrelated changes.
3. Confirm the working tree is clean before starting unless the user explicitly says otherwise.
4. Make the smallest coherent change.
5. Run `python tools/validate_catalog.py`.
6. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_project.ps1"` when Godot is available.
7. For web-related changes, run `./tools/export_web.ps1` and test through `./tools/serve_web.ps1`.
8. Read all command output and fix failures before stopping.
9. Review the diff for regressions, hard-coded item counts, build artifacts, and accidental secrets.
10. Run `git diff --check`.
11. Report changed files, commands run, results, diff-review notes, and remaining manual visual checks.

## Architecture Rules

- `data/catalog.json` is the content source of truth.
- `item_catalog.gd` loads and validates content.
- `game_state.gd` owns selections, compatibility, locks, history, reset, and save sanitization.
- `doll_view.gd` renders either procedural placeholders or future PNG layers.
- UI code must not contain per-item rendering rules.
- Slot conflicts should be expressed through metadata (`occupies`, tags, and conflict tags).
- Saved state must be versioned and sanitized against the current catalog.

## Testing Commands

```powershell
python tools/validate_catalog.py
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_project.ps1"
./tools/export_web.ps1
./tools/serve_web.ps1
```

Manual checks are documented in `docs/TEST_PLAN.md`.
