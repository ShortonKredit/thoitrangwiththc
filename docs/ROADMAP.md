# Roadmap

This roadmap reflects the current three-quarter-body MVP baseline. It is intentionally proof-gated: do not scale asset production until the Keri integration proof and tiny MVP wardrobe proof pack are visually accepted.

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

## Phase 2 Three-Quarter-Body MVP Path

### Phase 2A - Keri Asset and License Audit

Status: Complete.

Historical decision: CONDITIONAL GO TO PHASE 2B. Keri remains a proof candidate, not a final anchor.

Later MVP scope decision: GO TO THREE-QUARTER-BODY MVP INTEGRATION.

Audit docs:

- `docs/asset_audits/keri/PHASE_2A_AUDIT_REPORT.md`
- `docs/asset_audits/keri/DECISION.md`
- `docs/asset_audits/keri/ASSET_INVENTORY.md`
- `docs/asset_audits/keri/LICENSE_PROVENANCE.md`
- `docs/asset_audits/keri/RISK_ASSESSMENT.md`
- `docs/asset_audits/keri/MVP_SCOPE_DECISION.md`

Goal: decide whether the Keri candidate can be used for a legitimate proof path.

Allowed work:

- inspect source/license/provenance;
- document usage constraints;
- define required transformations or redraw scope;
- decide whether to reject, redraw, or proceed to proof.

Not allowed:

- importing Keri into the game;
- making Keri an official dependency before the gate;
- mass asset production.

### Deferred - Full-Body Leg Extension Proof

Status: Deferred / post-MVP.

This path was superseded after follow-up experiments showed that full-body leg extension is too risky and unnecessary for MVP. It can be reconsidered only if a licensed full-body base, artist-finished legs, or production-quality extension workflow becomes available.

### Phase 2B - Three-Quarter-Body Integration Proof

Status: Automated checks passed / manual QA pending.

Goal: integrate a tiny Keri proof pack into Godot using the existing three-quarter-body canvas without rewriting the catalog.

Proof pack:

- 1 body core;
- 1 internal fallback top;
- 1 internal fallback bottom;
- 1 hair;
- 1 face or facial-feature configuration;
- 2 tops;
- 2 short bottoms;
- 1 short dress, if available in audited source;
- 1 accessory, if available in audited source.

Implemented proof pack:

- 1 body core;
- 1 internal fallback top;
- 1 internal fallback bottom;
- 1 combined hair layer;
- 1 fixed face configuration;
- 2 tops;
- 2 short bottoms.

Short dress and accessory were not available in the current proof source.

Acceptance criteria:

- all layers share one canvas and origin;
- items align with the three-quarter-body anchor;
- the mandatory base outfit always covers the character;
- dress and top/bottom conflicts obey metadata compatibility;
- the three-quarter crop looks intentional;
- shoes and other deferred categories do not appear as empty UI categories;
- random, reset, undo, redo, and save still work.

### Phase 2C - Face And Hair Layering Proof

Goal: verify face/facial-feature layers and hair front/back separation where needed.

Acceptance criteria:

- no upload/API/backend;
- no real-person face replacement in MVP;
- face/facial-feature placement is documented;
- hair front/back layering is verified if required by the selected hairstyle.

### Phase 2D - MVP Wardrobe Proof Pack

Goal: normalize about 3-5 items for each supported MVP category before producing more content.

Supported categories:

- hair;
- face/facial features;
- tops;
- short bottoms;
- short dresses;
- accessories.

Acceptance criteria:

- all layers share the selected three-quarter-body canvas and origin;
- slot conflicts still work through metadata;
- top/bottom/dress all-none state remains valid;
- no blank-card fallback regression;
- no shoes, socks, long trousers, or full-length dresses;
- Godot visual QA passes at target viewports.

## Phase 3 - Product Integration And Web Release

Phase 3 should start only after the MVP proof pack passes. Likely work:

- import approved MVP assets;
- finalize thumbnails and UI category visibility;
- test compatibility, random, history, reset, and save;
- export and smoke-test the web build.

## Post-MVP

Full-body support, shoes, socks, full-length trousers, and full-length dresses are post-MVP. They should return only after the body/source quality problem is solved without breaking Keri layer compatibility.
