# Thời Trang with THC

Game thay đồ 2D đời thường thời trang, xây dựng bằng **Godot 4.7 + GDScript**, ưu tiên desktop web.

## Trạng thái hiện tại

Đây là foundation hoàn chỉnh để bắt đầu engineering loop bằng Codex trong VS Code:

- Nhân vật nữ placeholder được vẽ bằng GDScript, không cần asset ảnh để chạy.
- Catalog data-driven với tóc, áo, quần/váy, đầm, giày, kính, mũ, phụ kiện và phông nền.
- Chọn/tháo item ngay lập tức.
- Tự xử lý xung đột giữa đầm và áo/bottom.
- Random có khóa danh mục.
- Undo/redo toàn state.
- Reset có xác nhận.
- Lưu outfit cục bộ, không cần tài khoản/database.
- Xuất PNG trên desktop và trình duyệt.
- Web export preset, script test/export và cấu hình Netlify.
- Kiến trúc sẵn để thay procedural placeholder bằng PNG layered do AI/artist tạo.

## Mở project

1. Cài **Godot 4.7 Standard** và export templates tương ứng.
2. Mở Godot → Import → chọn `project.godot`.
3. Nhấn F6/F5.

Không cần bản .NET.

## Dùng Codex trong VS Code

1. Mở **toàn bộ thư mục repo** bằng VS Code.
2. Cài Codex IDE extension.
3. Đảm bảo terminal gọi được `godot --version`.
4. Yêu cầu Codex đọc `AGENTS.md` trước khi sửa.
5. Giao từng milestone nhỏ và yêu cầu chạy engineering loop.

## Kiểm tra local

```powershell
./tools/check_project.ps1
```

Script sẽ import project và chạy smoke test logic.

## Export Web

```powershell
./tools/export_web.ps1
./tools/serve_web.ps1
```

Mở `http://localhost:8000`, sau đó kiểm tra Console/Network trong DevTools.

## Push commit đầu tiên

Repository đích:

`https://github.com/ShortonKredit/thoitrangwiththc.git`

Có thể chạy:

```powershell
./tools/first_push.ps1
```

Script yêu cầu Git đã đăng nhập/có quyền push.

## Deploy Netlify

Cách đơn giản nhất:

1. Chạy `./tools/export_web.ps1`.
2. Kéo thư mục `build/web` vào Netlify Drop.
3. Kiểm tra URL thật bằng Chrome, Edge và Firefox.

Chi tiết tại `docs/DEPLOYMENT.md`.

## Thêm trang phục

- Với placeholder: thêm item vào `data/catalog.json`; chỉ dùng cho test logic.
- Với asset thật: tạo PNG 1024×1536 nền trong suốt, cùng body template, rồi khai báo đường dẫn trong `layers`.
- Khi chuyển hoàn toàn sang PNG, đổi `character.mode` từ `procedural` thành `png`.

Xem `docs/CONTENT_ADDING_GUIDE.md` và `docs/ASSET_SPEC.md`.

## Quyền riêng tư

- Không đăng nhập.
- Không database người dùng.
- Không có API upload ảnh.
- Save data chỉ chứa ID outfit và khóa random trong `user://`/IndexedDB.
- Tính năng khuôn mặt chưa được triển khai trong milestone này.

## License

Mã nguồn mẫu: MIT. Asset do AI/artist tạo về sau cần được kiểm tra giấy phép riêng.
