# Test Plan

## Automated local checks

```powershell
./tools/check_project.ps1
```

Expected:

- Godot import exits 0.
- Catalog validation passes.
- Smoke test prints `SMOKE TEST PASSED`.

## Native visual smoke test

Run in Godot and verify:

1. Game opens without error.
2. All nine category buttons appear.
3. Selecting an item updates the character immediately.
4. Selected button remains highlighted.
5. Dress clears top and bottom.
6. Selecting top or bottom clears dress.
7. Lock hair, random several times and verify hair remains.
8. Random is undone with one Undo click.
9. Redo restores it.
10. Reset shows a clear confirmation.
11. Close and reopen; outfit is restored.
12. Save PNG excludes wardrobe controls.

## Web local test

```powershell
./tools/export_web.ps1
./tools/serve_web.ps1
```

Open Chrome/Edge/Firefox and check:

- no red Console errors;
- `.wasm`, `.pck`, `.js` and assets return HTTP 200;
- fullscreen works only after button click;
- PNG download works;
- refresh restores save when browser storage is allowed;
- no outbound API requests except static site files.

## Viewport sizes

- 1440×900 target.
- 1280×720 minimum desktop check.
- 1024×768 best effort.
