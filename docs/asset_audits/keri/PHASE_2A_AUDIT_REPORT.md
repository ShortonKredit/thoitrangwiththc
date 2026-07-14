# Phase 2A Audit Report - Keri Asset And License Audit

Date: 2026-07-14

## 1. Executive Summary

Phase 2A is complete with a **CONDITIONAL GO TO PHASE 2B** decision. Keri has enough local source, provenance, and usable upper-body material to justify a narrow full-body leg-extension proof, but it is not approved as the final anchor.

The strongest candidate is the template `base1.png`: it has a complete upper body and thighs but is cut at the lower shins with no ankles or feet. Shorts and skirt candidates are likely usable for an MVP proof; long pants are not usable as-is because they are cropped through the lower legs.

No artwork was modified. No AI output was generated. No Godot import was performed. No source archive or image asset was copied into the repository. No commit or push was performed.

## 2. Preparation Inputs Reviewed

- `07_notes/PREP_HANDOFF.md`
- `02_license_evidence/download_hashes.txt`
- `03_inventory/extraction_log.txt`
- `03_inventory/all_files.csv`
- `03_inventory/image_metadata.csv`
- `03_inventory/source_files.csv`
- `04_selected_for_proof/`
- Extracted `Credits.txt`, template `README.md`, and `game/dressup.rpy`
- Selected candidate PNGs were visually inspected from `C:\Users\ADMIN\Desktop\keri_asset_audit` only.

## 3. Archive/Source Overview

Two archives were prepared:

- `Keri-C_by_Konett.rar`: original Konett archive containing `Credits.txt` and `Keri-C_by_Konett.psd`.
- `Keri-Dressup-RenPy-Template.zip`: LunaLucid/Namastaii Ren'Py template and exported character PNG layers.

Hashes matched the preparation handoff. Extraction succeeded. No extraction blocker was found.

## 4. Asset Counts

- 324 total files.
- 267 PNG files.
- 1 PSD.
- 5 body/base PNGs.
- 75 hair PNGs.
- 30 eye PNGs.
- 5 eyebrow PNGs.
- 5 mouth PNGs.
- 32 top-category files, including 30 production full-canvas top PNGs and two UI/reference `top.png` files.
- 20 bottom-category files, including 18 production full-canvas bottom PNGs and two UI/reference `bottom.png` files.
- No production dress, shoes, or accessory category was found.

## 5. PSD/Source-Layer Findings

`Keri-C_by_Konett.psd` exists and Pillow can open metadata: PSD, `467x946`, RGB, `n_frames=168`.

A byte-level scan found plausible PSD resource names including `base`, `skin`, `eyes`, `mouth`, `eyebrows`, `jeans`, `shorts`, `shirt`, `skirt`, `shirtdress`, and `hair`.

Limits:

- `psd_tools` is not installed.
- Full layer names, group/folder hierarchy, exact visibility, clipping, and order were not decoded.
- The 168 Pillow frame/layer-like entries are not enough to claim the PSD structure is fully understood.
- This audit does not conclude that leg or foot layers do not exist in the PSD.

## 6. Template Findings

The template uses a Ren'Py `Composite` at `467x946`, placing all layers at `(0, 0)` in this order:

1. Base
2. Bottom
3. Top
4. Eyebrows
5. Eyes
6. Mouth
7. Hair

The exported production PNGs are mostly `948x1920`, with 184 files in that canvas group. The screen adds `keri` at `zoom 0.5`, matching the smaller composite target.

Template options found:

- 5 skin variants.
- 5 hairstyles.
- 15 hair colors.
- 3 eye shapes.
- 10 eye colors.
- 5 top choices with up to 6 variations.
- 3 bottom choices with up to 6 variations.
- 5 eyebrows and 5 mouths.
- Misc face effects exist, but are not part of the main composite.

## 7. Keri-C Findings

Keri-C provides the original PSD and license evidence. It appears to include source concepts for body/base, skin, face, hair, jeans, shorts, shirt, skirt, and shirtdress based on readable PSD resource names. Exact PSD layer compatibility with the template PNGs is still uncertain.

Do not assume Keri-A/B/C compatibility. This audit treats Keri-C PSD and the Ren'Py template PNGs as related but not fully proven interchangeable sources.

## 8. Canvas/Alignment Comparison

The project spec is `1024x1536`. Keri template production PNGs are `948x1920`. They share a common full canvas and origin within the template, which is good for conversion, but they cannot be dropped into this project without normalization.

Keri is therefore technically plausible for a data-driven Godot layered renderer after a separate conversion/proof step.

## 9. Body Candidate

Candidate:

`C:\Users\ADMIN\Desktop\keri_asset_audit\04_selected_for_proof\body\base1.png`

Original:

`01_extracted_original/Keri-Dressup-RenPy-Template/Keri-Dressup-RenPy-Template/game/Create_Character/Base/base1.png`

Metadata:

- Canvas: `948x1920`.
- Mode: RGBA.
- Visible bounds: `62,44,922,1920`.
- Body is unclothed and therefore would require the existing project `base_outfit` invariant or a future modest base layer before any product use.

Visual findings:

- Head, torso, arms, hands, hips, and upper legs are present.
- Upper body is high enough quality for a proof.
- Thighs are present.
- Knees are not clearly complete.
- Lower legs are partially present.
- Ankles and feet are absent.
- The lower body is cut at the bottom canvas edge.
- No Phase 2A edit or leg extension was performed.

AI outpainting suitability: **medium**. The pose and upper-body style are clear, but lower-leg completion and feet require careful manual QA.

## 10. Exact Leg-Crop Assessment

- Body visible bounds reach the bottom of the `948x1920` canvas.
- The crop occurs through the lower legs/shins.
- Ankles and feet are not present in the selected PNG.
- The thigh shape gives useful continuation information.
- The missing area is important, but it is not a Phase 2B blocker because the proof goal is specifically leg/foot extension.

Phase 2B can plausibly preserve the upper body and add lower legs, ankles, feet, and expanded/normalized canvas.

## 11. Bottom Assessment

| Bottom | Bounds | Assessment | Notes |
|---|---|---|---|
| `bottom1_*` long pants | `125,1132,646,1920` | requires_extension | Cropped at canvas bottom; not usable as-is. Waist/hip/thigh region may be reusable. |
| `bottom2_*` shorts | `125,1132,644,1647` | likely_usable_as_is | Does not depend heavily on missing lower legs. |
| `bottom3_*` skirt | about `48,1130,689,1878` | likely_usable_as_is | Best immediate bottom candidate; can likely continue after body extension. |

Answers to requested bottom questions:

1. The skirt can likely continue to be used after body leg extension, subject to visual QA.
2. Shorts can likely continue to be used.
3. Long pants can likely keep waist/hip/thigh art but need extended/redrawn lower legs.
4. Long pants not being immediately usable is not an MVP blocker because skirt and shorts remain plausible.

No bottom was edited.

## 12. Hair Assessment

The selected hair candidate is a single PNG layer, not an exported `hair_back`/`hair_front` pair. It includes front hair and longer side/back shapes in one layer. This is acceptable for a simple proof but risky for final shoulder/face ordering.

Readiness:

- Simple proof hair: medium/high.
- Proper layered renderer integration: medium after manual split.
- Face-photo overlap safety: medium/low until a mask and hair-front strategy exist.

## 13. Face Replacement Readiness

Eyes, eyebrows, and mouth are separate layers. Nose and blank face shape appear baked into the body/base. This is enough for a later face-placement proof, but not enough to implement face replacement now.

Phase 2C readiness: **medium**.

Required later:

- local-only face workflow;
- face mask;
- placement/scale guide;
- hair-front handling;
- proof that no photo upload/API/backend exists.

## 14. License/Provenance

Konett is the original Keri artist. LunaLucid/Namastaii authored the Ren'Py template/adaptation.

Local evidence:

- Keri-C `Credits.txt` states `CC-BY-3.0` and requires credit to Konett.
- Template `README.md` states Keri is `CC-BY license`, credits Konett, and identifies LunaLucid/Namastaii modifications/interface/code.
- Commercial-use text was not explicitly found in local text evidence.
- The template README does not specify a CC-BY version, so its version remains unspecified by available template README evidence.

License evidence is sufficient for a local proof if attribution and caveats are retained. It is not a legal conclusion.

## 15. Main Limitations

- Missing ankles and feet.
- No production dress, shoes, or accessory pack.
- Hair is not split front/back.
- PSD hierarchy is not fully readable with available tools.
- Template canvas differs from the project target canvas.
- Commercial-use statement was not explicitly found in local text evidence.
- Manual visual QA remains mandatory.

## 16. Mitigations

- Scope Phase 2B to one body candidate only.
- Preserve upper body; extend lower legs/feet only.
- Normalize to the project canvas after extension.
- Use skirt or shorts for immediate bottom proof.
- Defer long pants, dress, shoes, and accessories.
- Keep license/provenance documentation attached to any future proof.
- Use a PSD-capable tool later if PSD layer truth becomes decision-critical.

## 17. Selected Candidates For Later Proof

- `base1.png` for body.
- `bottom3_1.png` skirt as safest bottom proof.
- `bottom2_1.png` shorts as alternate bottom proof.
- `bottom1_1.png` long pants only as a later extension candidate.
- `hair1_1.png` as simple hair proof.
- `eyes1_1.png`, `eyebrows1_1.png`, and `mouth1_1.png` as face-part proof candidates.

## 18. Unknowns

- Full PSD hierarchy, visibility, and exact order.
- Whether PSD contains complete leg/foot alternatives.
- Whether all exported template PNGs are derived from the exact Keri-C PSD.
- License details beyond local evidence.
- Final acceptance of Keri as a product anchor.

## 19. Phase 2A Decision

**CONDITIONAL GO TO PHASE 2B**

Keri can move to one controlled full-body leg-extension proof if the conditions in `DECISION.md` are followed. This is not final-anchor approval.

## 20. Exact Phase 2B Scope

If Phase 2B is explicitly started later:

- Extend one selected body/base only.
- Add lower legs, ankles, feet, and needed canvas.
- Preserve upper body.
- Match skin tone, line art, and shading.
- Normalize to project canvas.
- Visually test with skirt or shorts.
- Do not start face replacement, wardrobe expansion, or long-pants completion unless separately approved.

## 20A. Later MVP Scope Update

After Phase 2A, follow-up experiments showed that full-body leg extension is too risky for MVP. The historical Phase 2A decision remains recorded, but the MVP path now defers leg extension and proceeds toward a three-quarter-body Keri integration proof. See `MVP_SCOPE_DECISION.md`.

## 21. Files Created In Repository

- `docs/asset_audits/keri/PHASE_2A_AUDIT_REPORT.md`
- `docs/asset_audits/keri/ASSET_INVENTORY.md`
- `docs/asset_audits/keri/LICENSE_PROVENANCE.md`
- `docs/asset_audits/keri/RISK_ASSESSMENT.md`
- `docs/asset_audits/keri/DECISION.md`

## 22. Explicit Confirmation

- No artwork modified.
- No AI output generated.
- No Godot import performed.
- No source archive copied.
- No candidate image copied into the repository.
- No source/gameplay/catalog change made.
- No Phase 2B implementation started.
- No commit performed.
- No push performed.
