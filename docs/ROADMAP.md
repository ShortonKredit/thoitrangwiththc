# Roadmap

This roadmap reflects the current post-Phase-1.1 baseline. It is intentionally proof-gated: do not scale asset production until the character anchor and tiny wardrobe proof pack are visually accepted.

## Completed

### Phase 0 - Baseline Foundation

- Godot 4.7 project foundation.
- Data-driven catalog with 9 categories and 45 items.
- Selection, compatibility, random locks, undo/redo, reset, and local save.
- Procedural placeholder renderer and future PNG path.
- Catalog validation, smoke tests, export scripts, and deployment notes.

### Phase 1 - Visual Verification and UI/UX Audit

- Baseline screenshots reviewed.
- UI issues documented in `docs/UI_AUDIT.md`.
- Low-risk layout/usability fixes applied.
- Automated checks passed after changes.

### Phase 1.1 - Product UI Cleanup and Modesty Foundation

- Player-facing title simplified.
- Persistent renderer-owned base outfit added.
- Catalog layer order includes `base_outfit`.
- Optional `thumbnail_path` and `accessible_name` metadata added with fallback behavior.
- Tests cover the base outfit invariant and thumbnail metadata validation.

### Phase 1.2 - Project Rebaseline and Engineering-Loop Alignment

- Current docs aligned with the actual codebase and test coverage.
- Long-lived constraints and invariants captured.
- Manual visual QA responsibilities separated from automated checks.
- Phase 2 proof-gated plan documented.

## Next: Phase 2 Proof Path

### Phase 2A - Keri Asset and License Audit

Goal: decide whether the Keri candidate can be used as a legitimate character anchor.

Allowed work:

- inspect source/license/provenance;
- document usage constraints;
- define required transformations or redraw scope;
- decide whether to reject, redraw, or proceed to proof.

Not allowed:

- importing Keri into the game;
- making Keri an official dependency before the gate;
- mass asset production.

### Phase 2B - Full-Body Leg Extension Proof

Goal: prove one full-body character anchor can support the game canvas and modest base outfit.

Acceptance criteria:

- full 1024x1536 transparent canvas;
- stable front-facing pose and anchor points;
- proportions remain stylized teenager, not chibi;
- base outfit coverage is visually acceptable;
- no duplicated limbs or anatomy artifacts;
- Godot visual check confirms framing.

### Phase 2C - Face Replacement Proof

Goal: prove any future face workflow can remain local-only and visually controlled.

Acceptance criteria:

- no upload/API/backend;
- face area, mask, scale, and placement are documented;
- privacy and failure cases are reviewed;
- no persistent main-header privacy banner is added unless the feature exists.

### Phase 2D - Wardrobe Proof Pack

Goal: create a tiny aligned PNG proof pack before producing many items.

Minimum pack:

- body/base outfit;
- one hair set with front/back if needed;
- one top;
- one bottom;
- one dress;
- one shoes item;
- one accessory or headwear item;
- readable thumbnails only if real thumbnails are provided.

Acceptance criteria:

- all layers share the same 1024x1536 canvas and origin;
- slot conflicts still work through metadata;
- top/bottom/dress all-none state remains valid;
- no blank-card fallback regression;
- Godot visual QA passes at target viewports.

## Phase 3+

Phase 3 should start only after the Phase 2 gate passes. Likely work:

- expand content one category at a time;
- harden web export and browser QA;
- improve tablet/mobile layout if needed;
- add polish such as audio/accessibility only after core rendering is stable.
