# MASTER PROMPT: XÂY DỰNG GAME WEB “THỜI TRANG WITH THC”

Bạn là một nhóm chuyên gia gồm:

* Product Manager chuyên về casual game và game dành cho gia đình.
* UX Researcher chuyên nghiên cứu game thời trang, dress-up game và game trẻ em.
* UI/UX Designer chuyên thiết kế giao diện game web.
* Senior Godot Developer có kinh nghiệm với Godot 4.x, GDScript và Web Export.
* Frontend/Web Engineer có kinh nghiệm triển khai WebAssembly game.
* QA Engineer chuyên kiểm thử game, trình duyệt và xử lý ảnh người dùng.
* Security & Privacy Engineer chuyên xử lý ảnh cục bộ và dữ liệu trẻ em.
* DevOps Engineer chuyên Netlify, Cloudflare Pages và GitHub-based deployment.

Hãy giúp tôi nghiên cứu, thiết kế, hoàn thiện, kiểm thử và triển khai một game thời trang thay đồ trên web.

Không được vội viết code trước khi hiểu rõ sản phẩm. Hãy thực hiện theo từng giai đoạn được mô tả trong prompt này.

---

# 1. BỐI CẢNH DỰ ÁN

Tôi muốn xây dựng một game thời trang thay đồ vui nhộn dành cho:

* Vợ tôi.
* Con gái tôi.
* Các thành viên trong gia đình.
* Có thể mở rộng thành game công khai nếu sản phẩm đủ hoàn thiện.

Game cần mang cảm giác:

* Vui vẻ.
* Dễ thương.
* Hài hước.
* Thao tác đơn giản.
* Không gây áp lực.
* Không có cạnh tranh độc hại.
* Không bắt buộc đăng nhập.
* Không có quảng cáo trong phiên bản đầu.
* Không có gacha.
* Không có tiền ảo.
* Không có chat với người lạ.
* Không có bảng xếp hạng.
* Không upload ảnh người dùng lên máy chủ.

Tên hiển thị dự kiến:

**Thời Trang with THC**

Slug dùng cho website:

**thoitrangwiththc**

Địa chỉ triển khai ưu tiên:

**https://thoitrangwiththc.netlify.app**

Nếu tên này đã có người dùng, đề xuất các tên theo thứ tự:

1. `thoitrangwiththc-game.netlify.app`
2. `game-thoitrangwiththc.netlify.app`
3. `tu-do-thc.netlify.app`
4. `thoitrang-nha-thc.netlify.app`

Phương án dự phòng trên Cloudflare Pages:

1. `thoitrangwiththc.pages.dev`
2. `thoitrangwiththc-game.pages.dev`

Không được tự ý mua tên miền trả phí.

Hãy phân biệt rõ:

* Domain riêng như `thoitrangwiththc.com` thường cần mua và gia hạn.
* Subdomain nền tảng như `thoitrangwiththc.netlify.app` có thể được dùng miễn phí nếu còn tên.

Nếu ký tự “THC” có khả năng bị hiểu nhầm thành nội dung liên quan đến chất kích thích trong bối cảnh game trẻ em, hãy:

* Giữ nguyên slug `thoitrangwiththc` theo yêu cầu của tôi.
* Không sử dụng hình ảnh, biểu tượng, nội dung hoặc từ ngữ liên quan đến cần sa.
* Xem “THC” là tên viết tắt hoặc tên thương hiệu gia đình.
* Đánh giá rủi ro về branding, tìm kiếm và khả năng bị hiểu nhầm.
* Đề xuất một vài tên hiển thị thân thiện hơn nhưng không tự ý thay đổi tên chính nếu chưa được yêu cầu.

---

# 2. PROJECT HIỆN TẠI

Dự án hiện tại được xây dựng bằng:

* Godot 4.x, dự kiến Godot 4.7.
* GDScript.
* Renderer Compatibility.
* Mục tiêu ban đầu là máy tính.
* Sau đó cần export thành game web.

Project hiện có thể chứa các file như:

* `project.godot`
* `main.tscn`
* `scripts/main.gd`
* `scripts/doll_canvas.gd`

Phiên bản hiện tại đã có prototype được vẽ bằng code, gồm:

* Một nhân vật placeholder.
* Bốn kiểu tóc.
* Bốn kiểu trang phục.
* Bốn loại giày.
* Một số phụ kiện.
* Một số phông nền.
* Nút random.
* Nút reset.
* Chế độ fullscreen.
* Chức năng lưu ảnh ở mức prototype.

Trước khi chỉnh sửa:

1. Hãy đọc toàn bộ source code hiện có.
2. Chạy project nếu môi trường cho phép.
3. Ghi lại cấu trúc project.
4. Xác định phần nào có thể giữ lại.
5. Xác định phần nào nên refactor.
6. Không được viết lại toàn bộ project chỉ vì muốn thay đổi kiến trúc.
7. Không xóa tính năng đang hoạt động nếu chưa có tính năng thay thế tốt hơn.
8. Không khẳng định đã chạy hoặc kiểm thử nếu thực tế chưa chạy được.

Nếu không được cung cấp repository hoặc source code:

* Hãy tạo kiến trúc và kế hoạch phù hợp.
* Đánh dấu rõ những phần cần kiểm tra khi nhận được project.
* Không tự giả định rằng code hiện tại hoạt động hoàn hảo.

---

# 3. MỤC TIÊU SẢN PHẨM

Xây dựng một dress-up game có vòng chơi chính:

1. Người dùng mở website.
2. Game tải nhanh và hiển thị nhân vật mặc định.
3. Người dùng chọn tóc, áo, váy, quần, đầm, giày và phụ kiện.
4. Món đồ được mặc ngay sau một lần click.
5. Người dùng có thể thêm ảnh khuôn mặt của mình nếu muốn.
6. Người dùng tự căn chỉnh khuôn mặt bằng kéo, zoom và xoay.
7. Người dùng có thể tạo hiệu ứng hài hước.
8. Người dùng có thể random trang phục.
9. Người dùng có thể khóa những phần không muốn random.
10. Người dùng có thể hoàn tác thao tác.
11. Người dùng có thể thay đổi phông nền.
12. Người dùng có thể lưu kết quả thành ảnh PNG.
13. Ảnh mặt được xử lý hoàn toàn trên thiết bị.
14. Không yêu cầu tạo tài khoản.
15. Không gửi ảnh lên server.

Game phải hoạt động tốt trước tiên trên:

* Máy tính Windows.
* Chrome.
* Microsoft Edge.
* Firefox.

Sau đó kiểm tra thêm:

* Safari trên macOS.
* Trình duyệt trên tablet.
* Điện thoại ở chế độ ngang nếu có thể hỗ trợ hợp lý.

Desktop web là ưu tiên số một. Không hy sinh trải nghiệm desktop chỉ để hỗ trợ màn hình điện thoại quá nhỏ.

---

# 4. NGHIÊN CỨU THỊ TRƯỜNG TRƯỚC KHI THIẾT KẾ

Trước khi đưa ra UI hoặc code, hãy nghiên cứu các game thời trang hiện tại.

## 4.1. Game tham khảo bắt buộc

Phân tích kỹ game sau:

https://gamevui.vn/thoi-trang-winx-3/game

Cần phân biệt:

* Trải nghiệm của bản thân game.
* Trải nghiệm của website GameVui đang nhúng game.
* Quảng cáo, menu, đăng nhập và nội dung đề xuất của website không nhất thiết là tính năng của game.

Hãy phân tích:

* Người chơi bắt đầu game như thế nào.
* Có màn hình chọn nhân vật không.
* Cách hiển thị nhân vật.
* Cách phân loại trang phục.
* Cách chọn item.
* Trạng thái item đang được chọn.
* Có nút tháo item hay không.
* Có reset hay không.
* Có lưu ảnh hay không.
* Có animation hay không.
* Có âm thanh hay không.
* Có hướng dẫn hay không.
* Có yêu cầu xoay ngang hay không.
* UI có phù hợp với trẻ em không.
* Điểm nào dễ hiểu.
* Điểm nào dễ gây nhầm.
* Điểm nào đã lỗi thời.
* Những bug hoặc edge case có thể xuất hiện.
* Phần nào nên học.
* Phần nào không nên sao chép.

Nếu không thể tương tác trực tiếp với canvas game:

* Không được bịa rằng đã chơi hoàn chỉnh.
* Hãy nói rõ giới hạn kiểm thử.
* Có thể sử dụng mô tả game, ảnh chụp, video gameplay, metadata và phản hồi người dùng.
* Phân biệt dữ liệu quan sát trực tiếp với suy luận.

Tuyệt đối không sao chép:

* Tên Winx.
* Nhân vật Winx.
* Logo Winx.
* Hình ảnh Winx.
* Trang phục hoặc asset độc quyền.
* Âm thanh và nhạc từ game đó.

Chỉ dùng game này để tham khảo UX, gameplay và cấu trúc giao diện.

## 4.2. Các game khác cần khảo sát

Khảo sát thêm những game phù hợp, ưu tiên các game vẫn còn người chơi hoặc có ảnh hưởng rõ ràng:

* Dress to Impress.
* SuitU.
* Shining Nikki.
* Infinity Nikki.
* Fashion Dreamer.
* Everskies.
* Các game Barbie dress-up hợp pháp.
* Doll Divine.
* Azaleas Dolls.
* Các HTML5 dress-up game đơn giản.
* Các game có photo mode.
* Các game cho phép tạo avatar hoặc đưa mặt người dùng vào nhân vật nếu tìm được.

Không cần sao chép toàn bộ danh sách nếu có game khác phù hợp hơn. Tuy nhiên phải giải thích lý do thay đổi phạm vi nghiên cứu.

## 4.3. Tiêu chí so sánh

Tạo bảng so sánh gồm ít nhất:

* Nền tảng.
* Đối tượng người chơi.
* Vòng chơi chính.
* Thời gian để tạo outfit đầu tiên.
* Cách phân loại item.
* Cách chọn và tháo item.
* Hiển thị trạng thái được chọn.
* Undo/redo.
* Random.
* Khóa danh mục khi random.
* Photo mode.
* Lưu ảnh.
* Tạo dáng.
* Thay phông nền.
* Tutorial.
* Tốc độ tải.
* Responsive.
* Accessibility.
* Monetization.
* Gacha.
* Quảng cáo.
* Đăng nhập.
* Social/chat.
* Các complaint phổ biến.
* Các bug phổ biến.
* Điều nên học.
* Điều cần tránh.

## 4.4. Nguồn nghiên cứu

Ưu tiên:

* Website chính thức.
* Documentation chính thức.
* Store listing.
* App Store reviews.
* Google Play reviews.
* Steam reviews.
* Bài đánh giá từ nguồn có uy tín.
* Cộng đồng như Reddit chỉ dùng để tìm mẫu complaint và phải ghi rõ đây là phản hồi cộng đồng.

Mọi kết luận quan trọng phải có nguồn.

Không sử dụng một review đơn lẻ để kết luận rằng toàn bộ game bị lỗi.

Phân biệt:

* Bug được nhiều người gặp.
* Ý kiến cá nhân.
* Vấn đề thiết kế.
* Vấn đề monetization.
* Vấn đề của nền tảng host.
* Vấn đề của thiết bị cụ thể.

## 4.5. Đầu ra của giai đoạn nghiên cứu

Trước khi code, cung cấp:

1. Executive summary.
2. Bảng so sánh game.
3. Danh sách UX pattern tốt.
4. Danh sách anti-pattern.
5. Danh sách bug phổ biến.
6. Những điểm áp dụng được cho Thời Trang with THC.
7. Những điểm không phù hợp với dự án gia đình.
8. Đề xuất phạm vi MVP.
9. Những giả định còn chưa chắc chắn.

---

# 5. ĐỊNH HƯỚNG TRẢI NGHIỆM

Sản phẩm nên được xem là một:

**Creative dress-up toy**

Không phải:

* Game cạnh tranh.
* Game cày cuốc.
* Game dịch vụ.
* Game gacha.
* Mạng xã hội.
* Nền tảng upload ảnh.
* Cửa hàng bán item.
* Công cụ chỉnh sửa ảnh chuyên nghiệp.

Người dùng phải cảm thấy:

* Vào là chơi được.
* Không sợ làm sai.
* Có thể quay lại thao tác trước.
* Không cần đọc hướng dẫn dài.
* Kết quả thay đổi tức thì.
* Có thể tạo ảnh hài hước nhanh.
* Ảnh của mình không bị upload.
* Có thể đóng tab mà không lo dữ liệu riêng tư bị gửi đi.

Mục tiêu UX:

* Người mới thay được item đầu tiên trong vòng 5–10 giây.
* Tạo outfit đầu tiên trong vòng dưới 30 giây.
* Thêm và căn mặt trong khoảng dưới 60 giây.
* Không quá hai thao tác để mặc một item.
* Lưu ảnh thành công ngay lần thử đầu tiên.
* Không cần đọc hướng dẫn dài mới hiểu cách chơi.

---

# 6. CẤU TRÚC GIAO DIỆN ĐỀ XUẤT

Trên màn hình desktop, dùng bố cục gần như:

* 60–70% chiều rộng cho khu vực nhân vật.
* 30–40% chiều rộng cho tủ đồ.
* Thanh thao tác chính nằm phía dưới hoặc vị trí luôn nhìn thấy.

Wireframe tham khảo:

┌──────────────────────────────┬────────────────────────┐
│                              │ Tóc | Áo | Váy | Đầm  │
│                              │ Giày | Phụ kiện | Mặt │
│                              │                        │
│          NHÂN VẬT            │ Danh sách thumbnail   │
│                              │                        │
│                              │                        │
│                              │                        │
├──────────────────────────────┴────────────────────────┤
│ Undo | Redo | Random | Khóa | Reset | Lưu ảnh       │
└───────────────────────────────────────────────────────┘

Các tab nên dùng cả icon và chữ, ví dụ:

* Tóc.
* Áo.
* Váy.
* Quần.
* Đầm.
* Giày.
* Phụ kiện.
* Khuôn mặt.
* Phông nền.

Không chỉ dùng icon khó đoán.

Item đang mặc phải có trạng thái rõ ràng:

* Viền.
* Dấu tick.
* Nền khác.
* Tooltip hoặc tên.
* Không chỉ thay đổi màu rất nhẹ.

Mỗi category cần có lựa chọn:

* “Không dùng”.
* “Tháo”.
* Hoặc bấm lại item đang chọn để tháo nếu hành vi đó không gây nhầm.

---

# 7. TÍNH NĂNG MVP BẮT BUỘC

## 7.1. Hệ thống nhân vật

Bản MVP cần ít nhất một nhân vật.

Nhân vật phải được xây dựng theo layer:

1. Background.
2. Hair back.
3. Body.
4. Face image.
5. Shoes.
6. Bottom.
7. Top.
8. Dress.
9. Arms hoặc body foreground nếu cần.
10. Hair front.
11. Glasses.
12. Hat/crown.
13. Foreground accessories.
14. Effects.
15. UI.

Không nhất thiết dùng đúng thứ tự trên cho mọi asset. Hãy thiết kế hệ thống z-index hoặc slot có thể cấu hình.

## 7.2. Danh mục thời trang

Bản MVP nên có:

* 4–6 kiểu tóc.
* 6–10 áo.
* 4–8 váy hoặc quần.
* 4–8 bộ đầm.
* 4–6 đôi giày.
* 8–12 phụ kiện.
* 3–5 phông nền.
* 1 lựa chọn không dùng cho các category cho phép bỏ trống.

Nếu chưa có asset thật:

* Giữ placeholder có chất lượng đủ để test.
* Không dùng asset vi phạm bản quyền.
* Tạo cấu trúc dễ thay bằng PNG sau này.
* Không biến placeholder thành kiến trúc cố định khó thay thế.

## 7.3. Chọn item

Khi click thumbnail:

* Item phải xuất hiện ngay.
* Không cần nút “Xác nhận mặc”.
* UI phản hồi ngay lập tức.
* Không để click nhanh tạo nhiều item xung đột.
* Không để hai item cùng category vô tình tồn tại nếu category chỉ cho phép một.

## 7.4. Quy tắc tương thích

Hệ thống phải tự xử lý:

* Mặc đầm thì tháo áo và quần nếu thiết kế không cho phối chung.
* Mặc áo không tự xóa váy.
* Mặc quần không tự xóa áo.
* Mũ có thể xung đột với một số kiểu tóc.
* Kính luôn nằm trước khuôn mặt.
* Vương miện nằm đúng lớp với tóc.
* Tóc dài có thể chia thành hair back và hair front.
* Túi có thể cần layer phía trước hoặc phía sau cánh tay.
* Giày không được nằm sau chân.
* Random không tạo tổ hợp layer lỗi.

Không hard-code toàn bộ quy tắc thành hàng chục điều kiện khó bảo trì. Hãy xây dựng metadata hoặc compatibility rule có thể mở rộng.

## 7.5. Undo và redo

Mọi thao tác thay đổi trạng thái nên được ghi vào history:

* Đổi tóc.
* Đổi trang phục.
* Đổi giày.
* Đổi phụ kiện.
* Đổi background.
* Random.
* Thêm ảnh mặt.
* Xóa ảnh mặt.
* Di chuyển mặt.
* Zoom mặt.
* Xoay mặt.
* Áp dụng hiệu ứng hài hước.
* Reset.

Undo/redo phải khôi phục toàn bộ state có liên quan, không chỉ texture.

Giới hạn lịch sử ở mức hợp lý, ví dụ 30–50 trạng thái.

## 7.6. Random có khóa danh mục

Nút Random phải hỗ trợ khóa:

* Khuôn mặt.
* Tóc.
* Áo.
* Váy/quần.
* Đầm.
* Giày.
* Phụ kiện.
* Background.

Ví dụ:

* Khóa mặt và tóc.
* Random chỉ thay quần áo, giày và phụ kiện.

Không được xóa ảnh mặt khi random trừ khi người dùng chủ động cho phép.

## 7.7. Reset

Nút Reset cần:

* Khôi phục outfit mặc định.
* Có thể giữ ảnh mặt hoặc xóa ảnh mặt tùy lựa chọn.
* Nếu reset xóa nhiều thay đổi, phải có xác nhận.
* Sau reset vẫn có thể undo.

Nội dung xác nhận phải rõ:

* “Đặt lại trang phục”.
* “Đặt lại tất cả, bao gồm ảnh khuôn mặt”.

Không dùng hộp thoại chỉ có nội dung mơ hồ như “Bạn có chắc không?”.

## 7.8. Lưu trạng thái cục bộ

Tự lưu:

* Outfit gần nhất.
* Category đang chọn.
* Background.
* Các khóa random.
* Tùy chỉnh âm thanh.
* Có thể lưu vị trí/zoom mặt nếu việc lưu ảnh mặt cục bộ được thực hiện an toàn.

Không upload state lên server.

Nếu không nên lưu ảnh mặt lâu dài vì privacy hoặc giới hạn trình duyệt:

* Chỉ lưu outfit metadata.
* Giải thích rõ rằng ảnh mặt sẽ bị xóa khi đóng hoặc refresh.
* Không tạo cảm giác sai rằng ảnh đã được lưu nếu chưa được lưu.

Cung cấp nút:

* “Xóa dữ liệu đã lưu”.
* “Xóa ảnh khuôn mặt”.

---

# 8. TÍNH NĂNG THÊM KHUÔN MẶT

Đây là tính năng quan trọng.

## 8.1. Luồng cơ bản

1. Người dùng bấm “Thêm khuôn mặt”.
2. Mở file picker.
3. Chỉ nhận định dạng ảnh phù hợp.
4. Hiển thị preview.
5. Tự sửa hướng ảnh nếu metadata làm ảnh bị xoay.
6. Đưa ảnh vào khung mask oval hoặc mask theo khuôn mặt nhân vật.
7. Người dùng kéo ảnh.
8. Người dùng zoom.
9. Người dùng xoay.
10. Người dùng xác nhận.
11. Ảnh được ghép vào nhân vật.
12. Người dùng có thể căn lại hoặc xóa.

Nút bắt buộc:

* Chọn ảnh.
* Đổi ảnh.
* Căn lại.
* Phóng to.
* Thu nhỏ.
* Xoay trái.
* Xoay phải.
* Khôi phục căn chỉnh.
* Xóa ảnh.
* Xác nhận.
* Hủy.

Có thể hỗ trợ chuột:

* Kéo để di chuyển.
* Con lăn để zoom.
* Handle để xoay.

Nhưng không được bắt buộc người dùng phải biết gesture. Luôn có nút rõ ràng.

## 8.2. File ảnh

Chấp nhận:

* PNG.
* JPG/JPEG.
* WebP nếu môi trường hỗ trợ ổn định.

Từ chối hoặc cảnh báo:

* File không phải ảnh.
* File hỏng.
* File quá lớn.
* Kích thước không hợp lệ.
* Ảnh có chiều rộng hoặc chiều cao bằng 0.
* Format không hỗ trợ.

Không chỉ kiểm tra extension. Cần kiểm tra khả năng decode ảnh.

## 8.3. Xử lý ảnh lớn

Ảnh điện thoại có thể rất lớn.

Yêu cầu:

* Decode có kiểm soát.
* Downscale trước khi dùng làm texture nếu quá lớn.
* Đề xuất cạnh dài tối đa khoảng 1600–2048 px cho editor khuôn mặt, trừ khi có lý do kỹ thuật tốt hơn.
* Giải phóng texture cũ khi đổi ảnh.
* Không giữ nhiều bản sao ảnh full-resolution trong bộ nhớ.
* Hiển thị loading nếu xử lý mất thời gian.
* Không làm treo main thread nếu có thể tránh.

## 8.4. Orientation

Phải kiểm thử ảnh:

* Chụp dọc từ iPhone.
* Chụp ngang.
* Android.
* Ảnh đã chỉnh sửa.
* Ảnh không có EXIF.
* Ảnh bị rotate bằng metadata.

Không được để ảnh hiển thị xoay 90 hoặc 180 độ một cách khó hiểu.

## 8.5. Mask và mép ảnh

Ảnh khuôn mặt phải:

* Được mask theo hình oval hoặc shape phù hợp.
* Không để lộ viền chữ nhật.
* Có feather nhẹ nếu phù hợp.
* Có thể điều chỉnh độ sáng hoặc màu nhẹ để hòa với nhân vật.
* Không tự động thay đổi khuôn mặt quá mạnh.
* Không tự “làm đẹp” nếu người dùng không chọn.

Tóc phía trước và phụ kiện phải che đúng lên ảnh mặt.

## 8.6. Hiệu ứng hài hước

Có thể thêm các tùy chọn:

* Đầu to.
* Đầu nhỏ.
* Mặt dài.
* Mặt tròn.
* Má hồng.
* Kính khổng lồ.
* Ria mép.
* Vương miện lệch.
* Sticker trái tim.
* Sticker ngôi sao.
* Bong bóng thoại.
* Khung ảnh vui nhộn.

Các hiệu ứng phải:

* Dễ tắt.
* Có undo.
* Không làm hỏng ảnh gốc.
* Không sử dụng nội dung xúc phạm ngoại hình.
* Không gắn nhãn như “xấu”, “béo”, “già” hoặc các từ có thể gây khó chịu.

## 8.7. Quyền riêng tư

Ngay tại màn hình chọn ảnh, hiển thị thông báo ngắn:

**“Ảnh được xử lý trên thiết bị của bạn và không được gửi lên máy chủ.”**

Chỉ hiển thị câu này nếu kiến trúc thực sự hoạt động như vậy.

Yêu cầu kỹ thuật:

* Không POST ảnh lên API.
* Không gửi ảnh vào analytics.
* Không gửi ảnh vào logging.
* Không lưu ảnh lên CDN.
* Không tải ảnh sang dịch vụ AI.
* Không dùng face-recognition service bên ngoài.
* Không nhận diện danh tính.
* Không suy đoán tuổi, giới tính, cảm xúc hoặc đặc điểm nhạy cảm.
* Không giữ EXIF nếu không cần.
