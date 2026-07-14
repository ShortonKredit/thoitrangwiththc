# AI Asset Workflow

## Phase 1 — Master anchor

Generate 3–4 original female fashion-character candidates using the locked character brief. Select exactly one as the master reference.

The anchor must be front-facing, non-chibi, neutral pose, arms slightly separated, original and family-friendly.

## Phase 2 — Proof pack

Create only:

- 2 hairstyles
- 2 tops
- 2 bottoms
- 1 dress
- 2 shoes
- 2 accessories
- 1 background

Do not generate the full pack until these assets align correctly in Godot.

## Phase 3 — Normalization

AI output is source material, not final game content. For every asset:

1. remove background;
2. place on the shared canvas;
3. align to body anchors;
4. correct scale and perspective;
5. clean alpha edges;
6. split front/back layers;
7. export PNG and thumbnail;
8. verify in-game.

## Prompt skeleton

```text
Original 2D stylized fashion-game asset for the supplied master female character reference. Everyday modern fashion, front view, same fixed pose, same body proportions, same camera, same clean linework and soft cel shading. Create only [ITEM], aligned exactly to the reference body. Transparent background, no text, no logo, no extra person, no duplicate limbs, no copyrighted character, full 1024x1536 canvas.
```

Reference-image consistency is required, but manual alignment remains part of the workflow.
