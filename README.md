# Thoi Trang with THC

2D everyday-fashion dress-up toy built with **Godot 4.7 Standard + GDScript**, targeting desktop web first.

## Current Status

The repository is past the initial foundation and UI audit milestones:

- Godot 4.7 local import, parse, startup smoke, and logic smoke checks pass.
- Catalog is data-driven with 16 state categories and 236 items after Phase 3A content completion.
- The main scene runs locally.
- Selection, compatibility, backend random locks, undo/redo, reset, local save, and PNG capture logic exist.
- The active Phase 2C proof uses selectable Keri skin, combined hair, eyes, eyebrows, mouth, and makeup PNG layers; legacy procedural/composite items remain only where needed for migration/reference.
- `DollView` owns a permanent `base_outfit` so the character remains modest even when top, bottom, and dress are all none.
- Optional `thumbnail_path` and `accessible_name` metadata are supported with text fallback.
- GitHub Pages Web-preview configuration and build target `docs/`; local export/HTTP smoke pass and manual browser QA remains pending.
- Phase 2A Keri audit is complete; MVP art proof work is now scoped to a three-quarter-body integration path.
- Phase 2C appearance work is complete. Phase 3A integrates 29 tops, five shorts, six trousers, six skirts, and 13 effects and remains manual visual QA pending.
- The product action bar contains only Undo, Redo, and Reset icon buttons; Random, Save PNG, Fullscreen, and Clear saved data are not exposed in the Phase 3A UI.

No login, backend, database, account system, API upload, ads, gacha, chat, or leaderboard exists.

## Open The Project

1. Install **Godot 4.7 Standard** and matching export templates.
2. Open Godot -> Import -> choose `project.godot`.
3. Run the main scene with F5/F6.

No .NET build is required.

## Use Codex In VS Code

1. Open the full repository folder in VS Code.
2. Make sure the terminal can run `godot --version`.
3. Ask Codex to read `AGENTS.md` before changes.
4. Work one milestone at a time.
5. Require the engineering loop and final diff review.

## Local Checks

```powershell
python tools/validate_catalog.py
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_project.ps1"
```

Expected:

- `Catalog valid: 16 categories, 236 items`
- `SMOKE TEST PASSED`
- `Project checks passed.`

## Export Web

For web/export milestones:

```powershell
./tools/export_web.ps1
./tools/serve_web.ps1
```

Official Godot 4.7 Web templates are required. After export succeeds, open `http://localhost:8060`, then check browser Console/Network. See `docs/TEST_PLAN.md` and `docs/PHASE_3C_WEB_PREVIEW_REPORT.md`.

Expected GitHub Pages preview: `https://shortonkredit.github.io/thoitrangwiththc/`

- Desktop: preview target; manual browser QA pending.
- Mobile: experimental.
- Local Face Import: not implemented.

## Add Wardrobe Content

- Placeholder/testing content: add metadata to `data/catalog.json`; item count remains data-driven.
- Real MVP PNG content: use a shared transparent canvas and origin aligned to the selected three-quarter-body anchor.
- Keep `display_name` even when thumbnails exist.
- Use `thumbnail_path` only when a real thumbnail asset is present.
- Do not add item-specific rendering branches to UI code.

See `docs/CONTENT_ADDING_GUIDE.md` and `docs/ASSET_SPEC.md`.

## Privacy

- No login.
- No user database.
- No API photo upload.
- Save data contains only outfit IDs and random locks in local Godot/browser storage.
- Any future face-photo workflow must remain local-only and pass a separate privacy review.

## License

Sample source code: MIT. Future artist/AI assets need separate provenance and license review before import.
