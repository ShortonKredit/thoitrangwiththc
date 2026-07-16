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

Status: Complete. Owner-confirmed manual visual QA passed on 2026-07-16.

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

Status: Complete.

Goal: verify face/facial-feature layers and hair front/back separation where needed.

Acceptance criteria:

- no upload/API/backend;
- no real-person face replacement in MVP;
- face/facial-feature placement is documented;
- hair front/back layering is verified if required by the selected hairstyle.

Implemented scope:

- five mandatory skin variants with identical alpha geometry;
- 75 combined-hair PNG variants plus a `none` choice;
- separate eyes, eyebrows, mouth, and makeup slots with data-driven `none` policy;
- face subcategory navigation, preview compositing, save schema v2, legacy migration, and centralized future face-import metadata;
- no eyelash category because the audited source has no eyelash PNG;
- no local face import, file picker, biometric analysis, Phase 3 work, or wardrobe bulk import.

### Phase 2D - MVP Wardrobe Proof Pack

Status: Superseded / incorporated into the explicitly started Phase 3A product-integration milestone.

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

## Phase 3 - Product Integration And Release

### Phase 3A - Product Integration

Status: Implemented; manual visual QA pending.

- closed Phase 2C;
- reduced the action bar to Undo, Redo, and Reset icon buttons;
- removed Random, Save PNG, Fullscreen, and Clear saved data from product UI;
- audited all 184 PNGs in the local extracted PNG source/template set;
- retained/reused four proof garments and copied 55 additional compatible PNGs unchanged;
- exposed 29 tops, five shorts, six trousers, and six skirts with focused thumbnails;
- added a `face_effect` slot with 13 unique sweat/tears layers and `effect_none`;
- added data-driven Shorts/Trousers/Skirts navigation over the single bottom slot;
- moved persistence to save v3 while retaining version-1/version-2 migration, history, reset, and regression tests;
- excluded only one exact duplicate effect and two redundant selectable copies of renderer fallbacks.

### Phase 3B - Local Face Import

Status: Not started. Must remain local-only and requires a separate explicit milestone/privacy gate.

### Phase 3C-A - GitHub Pages Web Preview

Status: Manual Web QA pending.

- Compatibility renderer and browser-safe runtime dependencies audited;
- single-threaded, non-PWA Web preset targets `docs/index.html`;
- local SVG action icons replace unreliable Unicode Web-font glyphs;
- export and local HTTP/Chrome smoke pass;
- Edge/mobile manual QA, Web build commit/push, Pages configuration, and public URL verification remain pending.

### Phase 3C - Production Web Release

Status: Not started. The preview must export, deploy, and pass desktop/mobile QA before production release work begins.

## Post-MVP

Full-body support, shoes, socks, foot-level presentation, and full-length dresses are post-MVP. Accepted trousers remain three-quarter-viewport content and do not add feet or shoes.
