# Phase 3C-A GitHub Pages Web Preview Report

Date: 2026-07-16

Status: **MANUAL WEB QA PENDING**

## Baseline and scope

- Branch: `main`.
- Baseline/checkpoint: `26de024 Complete Phase 3A Keri content integration`.
- Initial Phase 3C-A working tree contained only the known Web preset, documentation, scripts, and generated Web build.
- Phase 3A remains **MANUAL VISUAL QA PENDING**.
- Phase 3B and Local Face Import were not started.
- This is a preview/beta build, not a production release.

## Web configuration

- Godot executable: `C:\Tools\Godot\Godot_v4.7-stable_win64_console.exe` through `godot.cmd`.
- Version: `4.7.stable.official.5b4e0cb0f`.
- Renderer: Compatibility / WebGL 2 compatible.
- Preset: `Web`, single-threaded, PWA disabled, no cross-origin isolation requirement.
- Output: `docs/index.html`.
- Export excludes previous `docs/index*` output, Markdown documentation, audit records, screenshots, and local build output from the PCK.
- `docs/.nojekyll` is present for GitHub Pages.

## Web action-icon compatibility defect

Manual Web QA found that Undo, Redo, and Reset were rendered as missing-glyph boxes. The action bar used Unicode characters as `Button.text`, and the Web runtime font did not reliably contain/render those glyphs.

The fix removes the font dependency entirely. Three project-owned monochrome SVGs were created from local path primitives:

```text
assets/ui/icons/undo.svg
assets/ui/icons/redo.svg
assets/ui/icons/reset.svg
```

Each SVG uses a transparent 24x24 viewBox, explicit `#493b43` strokes, and no text, emoji, font, `currentColor`, external URL, or `href`. `scripts/main.gd` preloads the textures and assigns them through `Button.icon`; action-button text is empty. Icons remain centered at their natural size, buttons remain 52x44, and disabled icons retain reduced-opacity visibility. Tooltip/accessibility copy and Undo/Redo/Reset/history logic are unchanged.

## Automated coverage

The logic smoke now verifies:

- all three SVG paths exist and load as 24x24 textures;
- SVG sources use explicit monochrome paths and contain no text/font/currentColor/external reference;
- action-button text is empty, preventing Unicode/emoji fallback;
- stable local texture paths, centered non-stretched layout, tooltip/accessibility copy, focus/styles, and disabled icon emphasis;
- Undo/Redo disabled-state behavior and Reset availability remain unchanged.

Results:

- `python tools/validate_catalog.py`: `Catalog valid: 16 categories, 236 items.`
- `check_project.ps1`: Godot import/parse passed, startup passed, `SMOKE TEST PASSED`, and `Project checks passed.`
- `export_web.ps1`: passed and regenerated the Web build.
- Export log explicitly packed `undo.svg`, `redo.svg`, and `reset.svg` imported textures.

## Generated Web files

| File | Bytes |
|---|---:|
| `index.html` | 5,454 |
| `index.js` | 279,815 |
| `index.wasm` | 39,509,339 |
| `index.pck` | 17,446,368 |
| `index.audio.worklet.js` | 7,298 |
| `index.audio.position.worklet.js` | 2,973 |
| `index.png` | 21,443 |
| `index.icon.png` | 7,747 |
| `index.apple-touch-icon.png` | 6,823 |

No file exceeds GitHub's normal 100 MiB per-file limit.

## Local HTTP and browser smoke

The build was served through `tools/serve_web.ps1` at `http://localhost:8060/`, never through `file://`.

- HTML, JS, WASM, PCK, icons, and both audio worklets returned HTTP 200.
- WASM used `application/wasm`; JavaScript files used `application/javascript`.
- No referenced asset returned 404.
- Generated configuration uses relative basename `index` and contains no localhost or Windows runtime path.
- The server was stopped after testing.

Chrome desktop headless WebGL smoke booted and rendered the complete game. Visual inspection confirmed:

- Undo shows a curved left arrow;
- Redo shows a curved right arrow;
- Reset shows a circular arrow;
- no missing-glyph boxes remain;
- all three buttons are equal-size and centered;
- disabled Undo/Redo remain recognizable with reduced emphasis;
- Reset remains enabled.

The Godot smoke suite verifies button callbacks/history behavior. Tooltip/accessibility values remain `Hoàn tác`, `Làm lại`, and `Reset`.

Edge headless and the small mobile automation viewport remained at or produced unreliable output around the Godot splash/WebGL renderer, so they do not establish interactive Edge/mobile correctness. Real Edge, Chrome Android, and Safari iPhone QA remains required.

## Deployment and remaining QA

Expected URL: `https://shortonkredit.github.io/thoitrangwiththc/`

This icon-fix round made no commit and no push. After owner browser QA passes, the existing Phase 3C-A changes/build can be committed and pushed, then GitHub Pages can serve branch `main` from `/docs`.

Remaining manual checks:

- real Chrome and Edge: hover/focus/pressed, tooltip, click Undo/Redo/Reset, outfit actions, console, refresh persistence;
- Android Chrome and iPhone Safari: icon rendering, touch, scrolling, portrait/landscape, and action buttons;
- public GitHub Pages URL after a later authorized commit/push.

No force-push or history rewrite was performed.
