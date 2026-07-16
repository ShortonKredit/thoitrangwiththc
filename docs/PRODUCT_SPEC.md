# Product Spec

## Product title

The in-game header shows:

```text
GAME THỜI TRANG
```

The repository/project name and deployment slug can remain `Thời Trang with THC` / `thoitrangwiththc`; the simplified title is the player-facing main-screen title.

## Product statement

**Thời Trang with THC** là creative dress-up toy 2D dành cho gia đình. Người chơi mở game, phối một outfit đời thường và chỉnh sửa an toàn bằng Undo, Redo, Reset mà không phải đăng nhập.

## Audience

- Người dùng chính: vợ, con gái và thành viên gia đình.
- Nhân vật hiển thị: nữ thiếu niên 15–17 tuổi theo ngôn ngữ minh họa stylized, không phải mô tả người thật.
- Desktop web first; tablet là mục tiêu tiếp theo.

## Experience principles

- Vào là chơi được.
- Thay item trong một click.
- Không có thắng/thua hoặc áp lực thời gian.
- Luôn có undo.
- Không tài khoản, quảng cáo, gacha, tiền ảo hoặc chat.
- Dữ liệu riêng tư không rời thiết bị.

## MVP in this repository

- Một body template 3/4 người và pose chính diện.
- Hair, face/facial features, 29 production tops, five production shorts, and background. Dress/accessory slots remain architecturally supported but hidden until compatible production assets exist.
- Compatibility rules.
- Selected state.
- Random/lock logic remains valid in the backend; lock behavior remains supported, while Random has no Phase 3A product button.
- Undo/redo.
- Reset.
- Local save.
- PNG capture logic remains reusable but has no Phase 3A product button.
- Web export foundation.
- Renderer-invariant base outfit so the character is never shown without modest base clothing, even when top, bottom and dress are all set to none.
- Optional thumbnail metadata with text fallback until real thumbnails exist.
- Appearance customization with five skin tones, selectable combined hair, and independent eyes, eyebrows, mouth, makeup, and face-effect layers.
- A `Khuôn mặt` main category with non-empty subcategory navigation and thumbnail-first, two-column item selection.
- Clean/reset appearance starts with base skin 01 and no optional hair, eyes, eyebrows, mouth, makeup, or legacy face preset.
- Skin choices read as large color swatches; facial-feature cards show only the relevant feature crop; hair cards show centered hair-only previews.
- The action bar shows only three monochrome icon buttons: Undo, Redo, and Reset. Random, Save PNG, Fullscreen, and Clear saved data are absent from product UI.
- Reset is undoable, redoable, saves immediately, and restores skin 01, optional appearance none, fallback clothing, accessory none, and `background_none`/default studio.
- Product garment tiles are textless two-column previews generated from catalog alpha bounds; style/color grouping metadata is retained for future presentation work.
- `Quần / Váy` exposes non-empty, data-driven `Quần short`, `Quần dài`, and `Chân váy` groups over one mutually exclusive bottom slot.
- `Khuôn mặt -> Hiệu ứng` exposes 13 unique sweat/tears layers plus `effect_none`; effects never appear in the default state.

## Deferred

- Full-body leg extension.
- Shoes, socks, full-body/foot presentation, full-length dresses, and other foot-dependent items. Accepted trousers are shown only in the existing three-quarter viewport.
- Face photo editor.
- Local face import/file picker and any face recognition or biometric analysis.
- Privacy copy for the future face-photo flow; it is not shown persistently in the main header.
- Real PNG base outfit and item thumbnails for the Phase 2 art proof pack.
- Mobile-first UI.
- Dynamic remote content packs.
- Multiple body templates/poses.
- Advanced animation and audio.
