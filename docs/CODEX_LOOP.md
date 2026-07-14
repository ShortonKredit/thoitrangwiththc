# Codex Engineering Loop

Use Codex IDE extension in VS Code on the local repo.

## One milestone at a time

A good task includes:

- exact goal;
- files likely affected;
- acceptance criteria;
- commands Codex must run;
- manual visual checks it must request.

## Standard prompt ending

```text
Work in an engineering loop: inspect → make a small change → run ./tools/check_project.ps1 → read all output → fix failures → review the diff. If the milestone affects Web export, also run ./tools/export_web.ps1. Do not claim visual correctness; list the exact visual checks I must perform.
```

## Recommended next milestones

1. Verify this foundation on the user's Godot 4.7 installation.
2. Refine desktop UI after screenshots.
3. Generate and integrate the first PNG proof pack.
4. Switch one category at a time from procedural to PNG.
5. Add the local face-photo editor only after wardrobe/Web export is stable.
