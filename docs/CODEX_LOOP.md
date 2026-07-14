# Codex Engineering Loop

Use Codex in VS Code on the local repository. Work one milestone at a time.

## Standard Loop

1. Read `AGENTS.md` and relevant `docs/` files.
2. Check `git status`, `git log --oneline -5`, and `git remote -v`.
3. Confirm the working tree is clean unless the user explicitly allows otherwise.
4. Inspect before editing.
5. Make the smallest coherent change.
6. Run:

```powershell
python tools/validate_catalog.py
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_project.ps1"
```

7. Read all output and fix failures.
8. For web/export changes, also run `./tools/export_web.ps1` and test through `./tools/serve_web.ps1`.
9. Review `git diff` and `git diff --check`.
10. Report changed files, command results, diff-review notes, and manual visual checks.

## Standard Prompt Ending

```text
Work in an engineering loop: inspect -> make a small change -> run python tools/validate_catalog.py -> run powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_project.ps1" -> read all output -> fix failures -> review git diff and git diff --check. If the milestone affects Web export, also run ./tools/export_web.ps1 and test through ./tools/serve_web.ps1. Do not claim visual correctness; list the exact visual checks I must perform.
```

## Current Phase Boundary

- Phase 0, Phase 1, and Phase 1.1 are complete.
- Phase 1.2 is the documentation/engineering-loop rebaseline.
- Phase 2A starts only when the user explicitly asks for Keri asset/license audit.
- Do not import Keri, generate AI assets, create a proof pack, or start web hardening during Phase 1.2.

## Recommended Next Milestones

1. Phase 2A - Keri asset and license audit.
2. Phase 2B - full-body leg extension proof.
3. Phase 2C - face replacement proof.
4. Phase 2D - tiny wardrobe proof pack.
5. Phase 3+ - content expansion and web hardening after the proof gate passes.
