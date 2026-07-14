# Keri MVP Scope Decision

Date: 2026-07-14

## Official Decision

GO TO THREE-QUARTER-BODY MVP INTEGRATION

## Context

Phase 2A completed the Keri asset and license audit with a historical decision of `CONDITIONAL GO TO PHASE 2B` for a controlled full-body leg-extension proof. After follow-up leg-extension experiments, the MVP scope is being rebaselined.

This document does not rewrite the Phase 2A audit result. It records a later product-scope decision: the MVP should integrate Keri as a three-quarter-body dress-up anchor instead of continuing full-body leg extension work.

## Previous Scope

The previous Phase 2B plan was a full-body leg-extension proof:

- preserve the selected Keri upper body;
- extend lower legs, ankles, and feet;
- normalize the result for the project canvas;
- visually test the result with skirt or shorts.

## Why The Scope Changed

Full-body leg extension is no longer appropriate for MVP because:

- the selected Keri body source is cut through the lower legs and has no ankles or feet;
- generative image editing did not produce stable production-quality results;
- donor-leg compositing creates risks around seams, anatomy, line art, style drift, and cleanup cost;
- full-body support is not required to prove the core dress-up game loop;
- continuing this path could slow or block the MVP.

## New MVP Scope

The MVP uses a three-quarter-body Keri presentation. The existing Keri `948x1920` canvas remains the layer anchor for the proof path.

MVP-supported content:

- hair;
- face or facial-feature layers;
- tops;
- short bottoms;
- short dresses;
- accessories.

MVP core features remain:

- category item selection;
- data-driven catalog;
- layer rendering;
- compatibility rules;
- mandatory base outfit;
- random outfit;
- reset;
- undo and redo;
- local save;
- item thumbnails;
- web export.

## Deferred Or Out Of MVP

The following are deferred/post-MVP:

- full-body leg extension;
- shoes;
- socks;
- full-length trousers;
- full-length dresses;
- items that require visible feet.

Shoes-related schema or architecture may remain for future support, but shoes must not appear as an empty MVP UI category.

## Asset Impact

- Keri can proceed as a three-quarter-body proof candidate.
- Missing lower legs and feet are no longer an MVP blocker.
- All MVP wardrobe assets must fit the supported three-quarter-body crop.
- Long pants, full-length dresses, socks, and shoes require a later full-body or manually completed body path.
- Keri is still not approved as the final product anchor until the integration proof passes visual QA.

## Source Code Impact

No source-code change is made by this decision document.

Future implementation may need catalog/UI filtering so deferred categories, such as shoes, do not appear empty in MVP. That implementation is outside this documentation-only rebaseline.

## UI Impact

The MVP UI should present only supported categories and items. It should not show shoes as an empty category. The character view should make the three-quarter crop feel intentional rather than like a broken full-body asset.

## Conditions To Reconsider Full-Body Support

Full-body support can be reconsidered post-MVP if one of these becomes available:

- a licensed, provenance-safe full-body base set;
- artist-finished legs and feet that match Keri's style;
- a production-quality body-extension workflow that preserves compatibility with Keri layers.

## Next Phase

Phase 2B is now `Three-Quarter-Body Integration Proof`.

The old Phase 2B full-body leg-extension proof is superseded and deferred.
