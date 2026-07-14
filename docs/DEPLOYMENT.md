# Deployment

## Local build

1. Install Godot 4.7 export templates.
2. Run:

```powershell
./tools/export_web.ps1
./tools/serve_web.ps1
```

3. Test `http://localhost:8000` in Chrome, Edge and Firefox.

## Netlify Drop — recommended first deployment

1. Confirm local web test passes.
2. Open Netlify Drop.
3. Drag the **contents/build folder `build/web`**, not the Godot source and not the ZIP.
4. Set the site name to `thoitrangwiththc` if available.
5. Test the live URL again.

## Git-connected Netlify

This repository contains `netlify.toml` with `build/web` as the publish directory. Netlify is not configured to install/export Godot automatically.

Simple workflow:

1. Export locally.
2. Commit `build/web` only if you decide to version builds.
3. Push to `main`.
4. Netlify publishes `build/web`.

For a cleaner repository, keep `build/` ignored and deploy through Netlify Drop until CI/CD is added.

## Production checks

- URL loads without console errors.
- WASM/PCK responses are 200.
- PNG download succeeds.
- Local save works in normal browser mode.
- No API request uploads user content.
- Cache updates after a new deployment.
