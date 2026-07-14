# AGENTS.md

## Project identity

- Project: **Thời Trang with THC**.
- Engine: **Godot 4.7 Standard**.
- Language: **GDScript**.
- Renderer: **Compatibility**.
- Product: a **2D layered dress-up toy** for desktop web.
- Character direction: female teenager, everyday fashion, stylized proportions, **not chibi**, not strongly magical/fantasy.

## Hard constraints

1. Do not convert the project to 3D.
2. Do not add login, account, chat, leaderboard, gacha, currency, ads or a user database.
3. Do not upload a user's face/photo to any server, analytics service or external AI API.
4. Do not rewrite the whole project when an incremental refactor is possible.
5. Do not remove working behavior unless a tested replacement exists.
6. Item count and category options must be data-driven; never hard-code ranges such as `0..3`.
7. New wardrobe content should normally require only PNG files plus catalog metadata.
8. Keep the repository runnable after every milestone.
9. Do not claim visual correctness without a visual check in Godot/browser.
10. Do not use copyrighted Winx, Barbie or other proprietary characters/assets.

## Required engineering loop

For each milestone:

1. Read this file and the relevant files under `docs/`.
2. Check `git status` and avoid unrelated changes.
3. Make the smallest coherent change.
4. Run `./tools/check_project.ps1` when Godot is available.
5. For web-related changes, run `./tools/export_web.ps1` and test through `./tools/serve_web.ps1`.
6. Read all command output and fix failures before stopping.
7. Review the diff for regressions, hard-coded item counts and accidental secrets.
8. Report changed files, commands run, results and remaining visual checks.

## Architecture rules

- `data/catalog.json` is the content source of truth.
- `item_catalog.gd` loads and validates content.
- `game_state.gd` owns selections, compatibility, locks and history.
- `doll_view.gd` renders either procedural placeholders or future PNG layers.
- UI code must not contain per-item rendering rules.
- Slot conflicts should be expressed through metadata (`occupies`, tags and conflict tags).
- Saved state must be versioned and sanitized against the current catalog.

## Testing commands

```powershell
./tools/check_project.ps1
./tools/export_web.ps1
./tools/serve_web.ps1
```

Manual checks are documented in `docs/TEST_PLAN.md`.
