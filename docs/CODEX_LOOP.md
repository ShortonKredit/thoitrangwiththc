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

- Phase 0, Phase 1, Phase 1.1, Phase 1.2, and Phase 2A are complete.
- The full-body leg-extension path is deferred/post-MVP.
- Phase 2C is complete; Phase 3A is implemented and remains manual visual QA pending.
- Phase 3B Local Face Import and Phase 3C Web Release are not started and require separate explicit instructions.
- Do not continue generative leg extension, donor-leg compositing, shoes, full-length garments, face import, or web release from the Phase 3A thread.

## Phase Start Checklist

Before every new phase:

1. Read `AGENTS.md`, `docs/CURRENT_STATE.md`, `docs/PHASE_STATUS.md`, `docs/ROADMAP.md`, and any phase-specific decision docs.
2. Check `git status --short`, `git log --oneline -5`, and `git remote -v`.
3. Confirm the working tree is clean or that all existing changes are known and in-scope.
4. Run the baseline project check before implementation when the phase changes behavior or assets.
5. Execute only the explicit phase scope.
6. Run validation again after changes.
7. Review the diff for source/asset drift, hard-coded counts, build artifacts, and secrets.
8. Do not commit or push unless the user explicitly asks.

## Recommended Next Milestones

1. Phase 2A - Keri asset and license audit.
2. Phase 2B - three-quarter-body integration proof.
3. Phase 2C - face and hair layering proof (complete).
4. Phase 3A - product integration (manual visual QA pending).
5. Phase 3B - local face import (not started).
6. Phase 3C - web release (not started).
