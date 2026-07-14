# First Steps on Windows

## 1. Extract and open

Extract the ZIP so the resulting folder contains `project.godot` directly. Open that folder in VS Code.

## 2. Install tools

- Godot 4.7 Standard
- Godot 4.7 export templates
- Git
- Python 3
- VS Code + Codex IDE extension

Add the Godot executable directory to PATH and confirm:

```powershell
godot --version
```

## 3. Run the first engineering loop

```powershell
python tools/validate_catalog.py
./tools/check_project.ps1
./tools/run_game.ps1
```

Visually test the checklist in `docs/TEST_PLAN.md`.

## 4. Create the initial Git commit

```powershell
git init
git add .
git commit -m "Initial Godot fashion game foundation"
git branch -M main
git remote add origin https://github.com/ShortonKredit/thoitrangwiththc.git
git push -u origin main
```

Alternatively run `./tools/first_push.ps1` after Git authentication is ready.

## 5. First Codex task

```text
Read AGENTS.md and docs/CURRENT_STATE.md. Run the complete local verification loop for this Godot 4.7 project. Fix only parser, API, import or smoke-test issues required to make the foundation pass. Do not add new features or redesign the UI. After automated checks pass, run the game and give me a concise visual checklist. Review the final diff for unrelated changes.
```

## 6. Export and deploy

```powershell
./tools/export_web.ps1
./tools/serve_web.ps1
```

After browser testing passes, deploy `build/web` through Netlify Drop.
