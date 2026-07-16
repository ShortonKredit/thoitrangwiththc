# Product Spec

## Product title

The in-game header shows:

```text
GAME THỜI TRANG
```

The repository/project name and deployment slug can remain `Thời Trang with THC` / `thoitrangwiththc`; the simplified title is the player-facing main-screen title.

## Product statement

**Thời Trang with THC** là creative dress-up toy 2D dành cho gia đình. Người chơi mở website, phối một outfit đời thường thời trang, random có kiểm soát và lưu ảnh PNG mà không phải đăng nhập.

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
- Hair, face/facial features, tops, short bottoms, short dresses, accessories, background.
- Compatibility rules.
- Selected state.
- Random locks.
- Undo/redo.
- Reset.
- Local save.
- PNG capture.
- Web export foundation.
- Renderer-invariant base outfit so the character is never shown without modest base clothing, even when top, bottom and dress are all set to none.
- Optional thumbnail metadata with text fallback until real thumbnails exist.
- Appearance customization with five skin tones, selectable combined hair, and independent eyes, eyebrows, mouth, and makeup layers.
- A `Khuôn mặt` main category with non-empty subcategory navigation and thumbnail-first, two-column item selection.

## Deferred

- Full-body leg extension.
- Shoes, socks, full-length trousers, full-length dresses, and foot-dependent items.
- Face photo editor.
- Local face import/file picker and any face recognition or biometric analysis.
- Privacy copy for the future face-photo flow; it is not shown persistently in the main header.
- Real PNG base outfit and item thumbnails for the Phase 2 art proof pack.
- Mobile-first UI.
- Dynamic remote content packs.
- Multiple body templates/poses.
- Advanced animation and audio.
