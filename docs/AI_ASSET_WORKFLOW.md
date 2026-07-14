# AI Asset Workflow

## Phase 1 - MVP Anchor

Use the selected Keri three-quarter-body candidate as the MVP proof anchor. Do not continue full-body leg extension during MVP.

The anchor must remain front-facing, non-chibi, everyday-fashion, original/provenance-safe, and family-friendly.

## Phase 2 - Three-Quarter-Body Proof Pack

Create only:

- 2 hairstyles
- 2 tops
- 2 short bottoms
- 1 short dress
- 2 accessories
- 1 background

Do not generate shoes, socks, full-length trousers, full-length dresses, or any foot-dependent item for MVP.

Do not generate the full pack until these assets align correctly in Godot.

## Phase 3 - Normalization

AI output is source material, not final game content. For every asset:

1. remove background;
2. place on the shared canvas;
3. align to body anchors;
4. correct scale and perspective;
5. clean alpha edges;
6. split front/back layers;
7. export PNG and thumbnail;
8. verify in-game.

## Prompt Skeleton

```text
Original 2D stylized fashion-game asset for the supplied three-quarter-body Keri reference. Everyday modern fashion, front view, same fixed pose, same body proportions, same camera, same clean linework and soft cel shading. Create only [ITEM], aligned exactly to the reference body and supported three-quarter-body crop. Transparent background, no text, no logo, no extra person, no duplicate limbs, no copyrighted character, shared 948x1920 Keri MVP proof canvas.
```

Reference-image consistency is required, but manual alignment remains part of the workflow.
