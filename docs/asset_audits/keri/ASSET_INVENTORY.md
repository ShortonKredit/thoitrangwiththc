# Keri Phase 2A Asset Inventory

Date: 2026-07-14

This inventory records the read-only Phase 2A review of `C:\Users\ADMIN\Desktop\keri_asset_audit`. No archive, PSD, PNG, candidate copy, contact sheet, screenshot, or working file was copied into this repository.

## Inputs Reviewed

- `07_notes/PREP_HANDOFF.md`
- `02_license_evidence/download_hashes.txt`
- `03_inventory/extraction_log.txt`
- `03_inventory/all_files.csv`
- `03_inventory/image_metadata.csv`
- `03_inventory/source_files.csv`
- `04_selected_for_proof/`
- Extracted `Credits.txt`, template `README.md`, and `game/dressup.rpy`
- Selected candidate PNGs were visually inspected from the external workspace only.

## Archive Overview

| Archive | Size | Hash status | Extraction |
|---|---:|---|---|
| `Keri-C_by_Konett.rar` | 3,922,851 bytes | SHA256 matched handoff | Success via `tar` |
| `Keri-Dressup-RenPy-Template.zip` | 55,398,007 bytes | SHA256 matched handoff | Success via `Expand-Archive` |

## Total Files

| Source archive | Files |
|---|---:|
| `Keri-C_by_Konett` | 2 |
| `Keri-Dressup-RenPy-Template` | 322 |
| Total | 324 |

## Extension Counts

| Extension | Count |
|---|---:|
| `.png` | 267 |
| `.psd` | 1 |
| `.rpy` | 5 |
| `.rpyc` | 5 |
| `.rpym` | 1 |
| `.rpymc` | 1 |
| `.md` | 1 |
| `.txt` | 1 |
| `.sample` | 11 |
| `.idx` | 1 |
| `.pack` | 1 |
| No extension | 29 |

## Image Counts By Suspected Category

| Category | Count | Notes |
|---|---:|---|
| Body/base | 5 | `base1.png` through `base5.png` |
| Bottom | 20 | 18 production full-canvas bottoms plus two UI/reference `bottom.png` files |
| Top | 32 | 30 production full-canvas tops plus two UI/reference `top.png` files |
| Hair | 75 | 5 hairstyles x 15 colors |
| Eyes | 30 | 3 eye shapes x 10 colors |
| Eyebrows | 5 | One per skin tone |
| Mouth | 5 | One per skin tone |
| UI | 78 | Ren'Py/template interface assets |
| Unknown | 17 | Mostly misc face effects plus `Modern_School.png` |

## Canvas Groups

- Main character production layers: `948x1920`, 184 files.
- Ren'Py composite target in script/readme: `467x946`.
- The template displays the character at `zoom 0.5`, so the production PNGs appear designed as full-resolution doubled assets for the smaller Ren'Py composite.
- Project target canvas remains `1024x1536`; Keri layers would need normalization and alignment before any Godot proof import.

## Production Layer Bounds

| Category | Canvas | Typical visible bounds |
|---|---|---|
| Body/base | `948x1920` | `62,44,922,1920` |
| Long pants, `bottom1_*` | `948x1920` | `125,1132,646,1920` |
| Shorts, `bottom2_*` | `948x1920` | `125,1132,644,1647` |
| Skirt, `bottom3_*` | `948x1920` | about `48,1130,689,1878` |
| Tops | `948x1920` | from about `62,568` through `898,1517`, depending style |
| Hair | `948x1920` | style-dependent, e.g. `198,44,727,849` for `hair1_*` |
| Eyes | `948x1920` | about `299-302,261-288,549,354` |
| Eyebrows | `948x1920` | `312,239,540,285` |
| Mouth | `948x1920` | `377,422,449,449` |

## Selected Candidates For Later Proof

These are external candidates only. They were not copied or imported.

| Candidate | Original source path |
|---|---|
| Body | `01_extracted_original/Keri-Dressup-RenPy-Template/Keri-Dressup-RenPy-Template/game/Create_Character/Base/base1.png` |
| Long pants | `.../Create_Character/Bottoms/bottom1_1.png` |
| Shorts | `.../Create_Character/Bottoms/bottom2_1.png` |
| Skirt | `.../Create_Character/Bottoms/bottom3_1.png` |
| Top 1 | `.../Create_Character/Tops/top1_1.png` |
| Top 2 | `.../Create_Character/Tops/top2_1.png` |
| Hair | `.../Create_Character/Hair/hair1_1.png` |
| Eyes | `.../Create_Character/Eyes/eyes1_1.png` |
| Eyebrows | `.../Create_Character/Eyebrows/eyebrows1_1.png` |
| Mouth | `.../Create_Character/Mouth/mouth1_1.png` |

## Template Findings

`dressup.rpy` defines a Ren'Py `Composite` with this order: base, bottom, top, eyebrows, eyes, mouth, hair. All are placed at `(0, 0)`.

Template option counts found from scripts and files:

- 5 skin variants.
- 5 hairstyle variants.
- 15 hair colors.
- 3 eye shapes.
- 10 eye colors.
- 5 top styles, generally 6 variations each.
- 3 bottom styles, generally 6 variations each.
- 5 eyebrow variants.
- 5 mouth variants.
- Misc face effects exist but are not used in the main composite.

## Keri-C PSD Findings

- `Keri-C_by_Konett.psd` exists and is 9,628,971 bytes.
- Pillow opens metadata as PSD, `467x946`, RGB, `n_frames=168`.
- `psd_tools` is not installed, so full layer hierarchy, folder membership, exact order, visibility, and clipping/group semantics were not available.
- Byte-level resource-name scan found plausible layer/resource names including `base`, `skin`, `eyewhite`, `blendskin`, `eyes`, `mouth`, `eyebrows`, `skinshadow`, `jeans`, `shorts`, `shirt`, `skirt`, `shirtdress`, and `hair`.
- Because full PSD layer semantics were not readable, this audit does not conclude that legs, feet, or any source layer are absent from the PSD.

## Asset Compatibility Classification

| Asset group | Classification | Evidence |
|---|---|---|
| Template body/base PNGs | requires_extension | Upper body and thighs are usable, but visible body reaches canvas bottom at lower shins with no ankles or feet. |
| Template tops | likely_compatible | Full-canvas, aligned with body, independent of missing lower legs. |
| Template skirt | likely_usable_as_is | Full-canvas, covers hip/thigh and does not depend heavily on feet. |
| Template shorts | likely_usable_as_is | Full-canvas, short enough to avoid missing lower-leg dependency. |
| Template long pants | requires_extension | Pants are cut at canvas bottom and would need lower-leg/ankle/foot extension or replacement. |
| Template hair | minor_cleanup_required | Usable single layer, but not split into `hair_back` and `hair_front`. |
| Template face parts | likely_compatible | Separate eyes, eyebrows, and mouth exist. Nose appears baked into body/base. |
| Keri-C PSD | uncertain | Source exists and has readable metadata/resource names, but full layer semantics were not decoded. |
| Dresses | requires_redraw | No standalone dress category was found in the template PNG inventory. PSD resource scan suggests `shirtdress`, but it was not available as an exported production layer. |
| Shoes | requires_redraw | No shoe assets found. |
| Accessories | requires_redraw | No production accessory category found beyond misc face effects. |
