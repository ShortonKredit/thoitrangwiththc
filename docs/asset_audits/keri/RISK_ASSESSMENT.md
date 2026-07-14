# Keri Phase 2A Risk Assessment

Date: 2026-07-14

Severity and likelihood use `low`, `medium`, `high`, and `critical`. Blocker status applies to Phase 2B proof only, not to final product adoption.

| Risk | Evidence | Severity | Likelihood | Mitigation | Blocker | Expected phase |
|---|---|---:|---:|---|---|---|
| Missing lower legs/feet | Body visible bounds reach `y=1920`; visual check shows lower shins cut with no ankles/feet. | high | high | Extend lower legs, ankles, and feet on expanded/normalized canvas. | non-blocker | Phase 2B |
| AI outpainting feasibility | Upper body, thighs, line art, and skin tone are intact; crop occurs below knee/lower shin area. | high | medium | Use strict reference, preserve upper body, compare line/shading manually. | non-blocker | Phase 2B |
| Source resolution | Production PNGs are `948x1920`; target is `1024x1536`. | medium | high | Normalize canvas and scale once; do Godot visual QA before content expansion. | non-blocker | Phase 2B |
| PSD readability | Pillow opens PSD metadata and 168 frames, but full hierarchy is not decoded. | medium | high | Use PSD-capable tool later if layer truth matters. | non-blocker for proof | Phase 2B/2D |
| Upper-body preservation | Body candidate has complete head/torso/arms; visual check shows usable upper body. | medium | medium | Freeze upper body during extension; only add missing lower body. | non-blocker | Phase 2B |
| Skin-tone consistency | Five base skin variants exist; extension must match chosen base. | high | medium | Extend one selected base first; sample palette from source. | non-blocker | Phase 2B |
| Line-art consistency | Existing line art has soft shaded anime style; generated/edit work may drift. | high | medium | Manual cleanup and side-by-side inspection. | non-blocker | Phase 2B |
| Bottom compatibility | Shorts/skirt likely usable; long pants cut at bottom. | medium | high | Use skirt/shorts for MVP proof; defer long pants. | non-blocker | Phase 2B/2D |
| Long-pants extension | `bottom1_*` reaches `y=1920`; visually cropped through legs. | medium | high | Keep waist/hip/thigh area and redraw/extend lower legs after body proof. | non-blocker | Phase 2D |
| Hair front/back separation | Hair PNGs are single combined layers; no exported back/front split found. | medium | high | Use one simple proof hair or manually split for shoulder/face ordering later. | non-blocker | Phase 2C/2D |
| Face replacement readiness | Eyes/eyebrows/mouth are separate; nose and face base appear baked into body. | high | medium | Define mask and local-only flow in Phase 2C; do not upload photos. | non-blocker | Phase 2C |
| Missing dress assets | No exported dress category found; PSD scan suggests `shirtdress` but not production PNG. | medium | high | Redraw/create one dress only after proof gate. | non-blocker for Phase 2B | Phase 2D |
| Missing shoe assets | No shoe category found; feet are missing too. | high | high | Create shoes after body feet exist. | non-blocker for Phase 2B | Phase 2D |
| Missing accessory assets | No production accessory category found except misc face effects. | low | high | Add one simple accessory in proof pack later. | non-blocker | Phase 2D |
| Keri A/B/C compatibility | Local evidence does not establish cross-version compatibility. | medium | medium | Treat Keri-C/template as separate candidates; do not assume compatibility. | non-blocker | Phase 2A/2D |
| Canvas/alignment mismatch | Template PNG canvas is `948x1920`; project spec is `1024x1536`. | high | high | Normalize full canvas and anchor points before Godot import. | non-blocker | Phase 2B |
| License attribution | Credits require Konett attribution; template README names LunaLucid/Namastaii. | high | high | Keep attribution docs and in-product/project credit when assets are used. | non-blocker if honored | Phase 2A+ |
| License version unspecified | Keri-C says CC-BY-3.0; template README says CC-BY without version. | medium | high | Record exact evidence; do not overstate template version. | non-blocker for proof | Phase 2A+ |
| AI-generated new asset style drift | Future extension/new clothing may not match original line/shading. | high | medium | Keep proof pack tiny; require manual visual QA and reject drift. | non-blocker | Phase 2B/2D |
| Manual visual QA dependency | Automated checks cannot validate anatomy, crop, alignment, or style. | high | high | Require Godot/browser visual checks before claiming art correctness. | non-blocker | Every art phase |

## Main Risk Conclusion

No single Phase 2A risk blocks a controlled Phase 2B proof. The proof should be conditional: only extend the selected body, preserve the upper body, normalize canvas deliberately, and use skirt/shorts as immediate bottom candidates while long pants wait for later extension.
