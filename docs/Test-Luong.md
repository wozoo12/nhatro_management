# KỊCH BẢN KIỂM THỬ (E2E TESTING) - ỨNG DỤNG LOZIDO

Tài liệu này cung cấp luồng kiểm tra (Test Flow) chi tiết từ lúc khởi tạo ứng dụng đến khi vận hành. Vui lòng đánh dấu `[x]` vào các mục đã test thành công.

---

## 🛠 LUỒNG 1: KHỞI TẠO VÀ XÁC THỰC (ONBOARDING)

### 1. Đăng nhập / Đăng ký
- [ ] Mở ứng dụng, hiển thị đúng màn hình Welcome (Màu xanh chủ đạo).
- [ ] Test tính năng "Báo lỗi đỏ" nếu không nhập Email hoặc nhập sai định dạng.
- [ ] Đăng nhập/Đăng ký bằng Email: Nhập Email -> Nhận OTP qua Email thật -> Đăng nhập thành công.
- [ ] Test luồng "Quên mật khẩu": Nhập Email -> Nhận OTP qua Email thật -> Đổi mật khẩu mới thành công.

### 2. Thiết lập Nhà trọ (Wizard)
- [ ] Form Nhập liệu: Bỏ trống "Tên nhà trọ", nhấn Tiếp tục -> Phải báo lỗi (bắt buộc nhập).
- [ ] Form Nhập liệu: Nhập số âm vào Diện tích (-5) -> Phải báo lỗi (không cho nhập số âm).
- [ ] Bản đồ (Map Picker): Bấm chọn vị trí, kéo thả ghim -> Địa chỉ và tọa độ Lat/Lng tự động điền ngược về form.
- [ ] Số lượng phòng / Người tối đa: Kiểm tra giao diện tăng giảm (Nút +/-) hoạt động trơn tru.

---

## 🚪 LUỒNG 2: THÊM KHÁCH THUÊ & HỢP ĐỒNG (CORE BIZ)

### 1. Quét CCCD Gắn Chip (Tính năng quan trọng)
- [ ] Từ Trang chủ, bấm "Lập hợp đồng mới" -> Chọn phòng trống.
- [ ] Tại màn hình thêm Khách thuê, bấm nút "Quét QR".
- [ ] Đưa CCCD (hoặc hình ảnh CCCD giả lập) vào khung quét laser.
- [ ] Hệ thống tự động điền 100% dữ liệu: Họ tên, Số CCCD, Ngày sinh, Địa chỉ (Parse chính xác).

### 2. Ký hợp đồng
- [ ] Test trường Giá tiền cọc: Tự động format dấu chấm (Vd: 2.000.000).
- [ ] Bấm Hoàn tất: Màn hình hiển thị "Hợp đồng thành công" (Popup Lottie / Checkmark).
- [ ] Trạng thái phòng ở trang chủ đổi từ "Trống" sang "Đang thuê" (Chuyển màu xanh).

---

## 💵 LUỒNG 3: HÓA ĐƠN & GIAO DỊCH (TRANSACTIONS)

### 1. Tạo hóa đơn cuối tháng
- [ ] Chọn một phòng "Đang thuê" -> Chọn "Chốt điện nước" hoặc "Tạo hóa đơn".
- [ ] Nhập chỉ số Điện/Nước mới. App tự động tính toán (Chỉ số Mới - Chỉ số Cũ) x Đơn giá.
- [ ] Kiểm tra tổng tiền hóa đơn đã bao gồm tiền phòng + điện nước + dịch vụ rác, wifi.

### 2. Thanh toán QR (VietQR)
- [ ] Vào chi tiết Hóa đơn vừa tạo.
- [ ] Kiểm tra mã QR dưới cùng: Lấy điện thoại mở app Ngân hàng (Momo, Vietcombank) quét thử mã QR.
- [ ] App ngân hàng hiển thị đúng: Số tài khoản, Số tiền cần đóng, Nội dung chuyển khoản (Vd: Tro P101).

### 3. Thông báo Zalo (Zalo Notification)
- [ ] Bấm nút "Gửi Zalo cho khách".
- [ ] Ứng dụng tự động nhảy sang app Zalo cá nhân.
- [ ] Tự động mở khung chat với số điện thoại của khách và điền sẵn lời chào + báo phí phòng.

---

## ⚙️ LUỒNG 4: VẬN HÀNH & BÁO CÁO (SUPER APP V2)

### 1. Quản lý sự cố (Ticketing)
- [ ] Từ Trang chủ -> Bấm "Quản lý sự cố".
- [ ] Xem danh sách các sự cố. Các thẻ trạng thái (Đang chờ, Đang sửa, Đã xong) đổi màu chuẩn xác.
- [ ] Thử bấm nút Cập nhật trạng thái sự cố.

### 2. Thanh lý / Trả phòng
- [ ] Từ Trang chủ -> Bấm "Thanh lý / Trả phòng".
- [ ] Nhập số điện nước cuối cùng để chốt bill.
- [ ] App cấn trừ Tiền cọc - Tiền điện nước tháng cuối = Số tiền hoàn lại cho khách.
- [ ] Phòng tự động trở về trạng thái "Phòng trống" (Màu cam).

### 3. Dashboard 2.0 & Dark Mode
- [ ] Kiểm tra Biểu đồ tròn (Pie Chart): Số lượng phòng Đang thuê / Phòng trống khớp với thực tế.
- [ ] Lời nhắc thông minh (Smart Reminders): Cuộn ngang trơn tru.
- [ ] Kéo thanh công cụ điện thoại xuống -> Bật "Chế độ Ban đêm" (Dark Mode).
- [ ] Ứng dụng lập tức chuyển nền đen tuyền, chữ trắng, bảo vệ mắt.

---

## 📱 LUỒNG 5: CÁC TAB ĐIỀU HƯỚNG MỚI (BOTTOM NAVIGATION BAR)

### 1. Tab "Công việc" (Tasks & Reminders)
- [ ] Chuyển sang tab "Công việc": Kiểm tra giao diện hiển thị đúng 2 khối thống kê (Cần làm / Đã hoàn tất).
- [ ] Lọc công việc theo Chip: Bấm các chip "Sự cố", "Lịch hẹn", "Thu tiền", "Cá nhân", danh sách lọc chính xác.
- [ ] Đánh dấu hoàn tất: Tích vào checkbox, tiêu đề có gạch ngang mờ và số lượng cập nhật ngay.
- [ ] Bấm nút FAB "Thêm việc": Mở `AddTaskBottomSheet`, nhập việc mới -> Danh sách công việc tự động cập nhật lên đầu.

### 2. Tab "Tìm khách" (Listing & Leads CRM)
- [ ] Chuyển sang tab "Tìm khách": Banner hiển thị đúng số phòng trống.
- [ ] Sub-tab "Đăng tin phòng trống":
  - [ ] Thẻ phòng trống hiển thị đúng giá, diện tích, tiện nghi.
  - [ ] Nút "Sao chép tin": Bấm sao chép, hiển thị SnackBar thông báo thành công và clipboard có nội dung chuẩn SEO.
  - [ ] Nút "Đăng Zalo": Tự động mở ứng dụng Zalo cá nhân.
- [ ] Sub-tab "Khách tiềm năng":
  - [ ] Lọc khách theo chip "Quan tâm", "Hẹn xem", "Đã cọc".
  - [ ] Nút Gọi điện (`tel:`), nút Nhắn tin Zalo hoạt động chính xác.
  - [ ] Bấm nút FAB "Thêm khách": Điền form `AddLeadBottomSheet`, lưu lại khách thuê tiềm năng.

### 3. Tab "Thêm" (Settings & More)
- [ ] Chuyển sang tab "Thêm": Hiển thị đúng card thông tin chủ nhà ("Chủ trọ Pro").
- [ ] Kiểm tra điều hướng các module con:
  - [ ] Bấm "Tài khoản ngân hàng & VietQR" -> Chuyển sang màn hình `SettingsView`.
  - [ ] Bấm "Sổ quỹ & Thu chi" -> Chuyển sang màn hình `FinanceView`.
  - [ ] Bấm "Quản lý tài sản" -> Chuyển sang màn hình `AssetManagementView`.
  - [ ] Bấm "Mẫu hợp đồng & Nội quy trọ" -> Hiển thị popup nội quy tiêu chuẩn.
- [ ] Kiểm tra Switch Dark Mode và Sinh trắc học hoạt động mượt mà.
- [ ] Bấm "Đăng xuất tài khoản": Hiển thị Dialog cảnh báo màu đỏ, bấm Đồng ý thì đăng xuất và trở về màn hình Welcome.

### 4. Tab "Trang chủ" (Home Core Enhancements)
- [ ] **Top Header:**
  - [ ] Bấm icon **Quét QR**: Mở camera quét thẻ CCCD, hiển thị popup bóc tách thông tin cá nhân và nút "Lập hợp đồng ngay".
  - [ ] Bấm vào **Tên nhà trọ / Menu**: Mở BottomSheet danh sách nhà trọ, chuyển đổi qua lại giữa các khu trọ hoặc bấm "Thêm nhà trọ mới".
- [ ] **Thanh lý / Trả phòng:**
  - [ ] Bấm "Thanh lý / Trả phòng" ở tab Quản lý: Hiển thị danh sách các phòng đang có người ở (`contract != null`) thay vì nhảy cứng vào phòng 101.
  - [ ] Chọn 1 phòng: Chuyển sang màn hình quyết toán với số phòng và tiền cọc thực tế của phòng đó.
- [ ] **Cọc giữ chỗ:**
  - [ ] Chọn phòng trống -> Điền họ tên, số điện thoại, số tiền cọc -> Bấm "Xác nhận nhận cọc".
  - [ ] Popup thành công hiển thị số điện thoại thật, bấm nút "Chia sẻ" hoặc "Gửi Zalo" hoạt động bình thường.
- [ ] **Tab Tổng quan:**
  - [ ] Bấm thẻ "Hóa đơn chưa thu": Chuyển ngay sang danh sách hóa đơn.
  - [ ] Bấm thẻ "Nợ tiền cần thu": Chuyển sang danh sách hóa đơn để đối soát.
  - [ ] Biểu đồ "Tỷ lệ lấp đầy" hiển thị đúng số phòng đang thuê và phòng trống theo thời gian thực.

---

**Kết luận:** Nếu toàn bộ các Check-box trên đều tick [x], ứng dụng LOZIDO của bạn đã sẵn sàng đóng gói (Build APK/AAB) và tự tin tung ra thị trường!

---

## LUỒNG 6: KIỂM THỬ LẠI THEO LỖI GHI NHẬN TRÊN LDPLAYER (15/10/2026)

> Trước khi chạy các mục cọc/thanh lý, áp dụng migration `supabase/migrations/202610150001_room_reservations.sql` lên đúng Supabase project của app.

> Cập nhật sau lỗi `rooms_status_check`: chạy tiếp migration `supabase/migrations/202610150002_allow_booked_room_status.sql` để cho phép trạng thái `BOOKED`.

- [ ] **Chọn loại hình nhà trọ:** Mở dropdown ở màn hình hẹp; danh sách cuộn được, không còn cảnh báo `BOTTOM OVERFLOWED`.
- [ ] **Bản đồ:** Mở bản đồ, kéo/zoom để chọn vị trí; tìm một địa chỉ; xác nhận ghim, tọa độ và địa chỉ cập nhật. Thử nút vị trí hiện tại sau khi cấp quyền GPS. Lưu nhà và kiểm tra tọa độ/địa chỉ được ghi nhận.
- [ ] **Nhận cọc P01:** Nhập người cọc, điện thoại, số tiền và ngày dự kiến; xác nhận. Kiểm tra phòng chuyển `BOOKED` màu xanh dương, không còn hiện như phòng trống ở danh sách cọc, dữ liệu cọc còn sau khi tải lại app.
- [ ] **Ký hợp đồng phòng đã cọc:** Phòng xuất hiện trong danh sách lập hợp đồng; thấy đúng người và tiền cọc đã nhận/còn thiếu. Thử chọn sai khách phải bị chặn. Ký đúng khách, kiểm tra tiền cọc thực tế gồm khoản đã nhận cộng phần nộp thêm; phòng chuyển `OCCUPIED` nhưng hóa đơn chưa thu không được tô xanh. Sau khi hóa đơn chuyển `PAID`, lưới phòng mới hiện xanh lá.
- [ ] **Thanh lý:** Hoàn tất checklist rồi kết thúc hợp đồng. Kiểm tra trạng thái hợp đồng thành `TERMINATED`, ngày kết thúc được lưu, phòng trở về `AVAILABLE` và không còn trong danh sách phòng đang thuê sau khi làm mới.
- [ ] **Danh sách cọc sau điều hướng:** Mở danh sách cọc, chuyển sang luồng ký hợp đồng rồi quay lại/mở lại danh sách cọc. Xác nhận danh sách tải theo nhà hiện tại; phòng `BOOKED` không còn được đề xuất nhận cọc lần hai.
- [ ] **Định dạng tiền:** Nhập số tiền cọc, tiền cọc hợp đồng, cọc phát sinh và ngân sách. Xác nhận dấu chấm phân cách hàng nghìn và giá trị lưu vẫn đúng.
- [ ] **Vị trí dự phòng:** Thử nút GPS với quyền app + Location hệ thống được bật. Khi GPS hoặc mạng không khả dụng, nhập tọa độ hoặc kéo ghim; xác nhận vẫn chọn/lưu được tọa độ.


## LUỒNG 7: KIỂM TRA LẠI BẢN ĐỒ, CỌC VÀ THÊM KHÁCH (15/10/2026)
- [ ] **Tọa độ thủ công:** Mở bản đồ, nhập vĩ độ/kinh độ trong hộp thoại (thử dấu chấm và dấu phẩy thập phân), bấm Định vị rồi Chọn vị trí. Nút Chọn vị trí cần hoạt động cả khi tra địa chỉ chậm/mất mạng.
- [ ] **Khách đặt cọc chuyển sang hợp đồng:** Cọc một phòng bằng tên và số điện thoại; vào Lập hợp đồng mới, chọn phòng đó. Thẻ khách cọc phải hiện đúng tên/số điện thoại; không phải nhập lại/chọn khách khác; tiền cọc đã nhận được trừ vào số còn phải đóng và cộng đúng vào tiền cọc thực tế.
- [ ] **Màu phòng ở danh sách ký hợp đồng:** Phòng đã cọc hiện nhãn xanh dương `ĐÃ CỌC`; phòng chưa cọc hiện nhãn đỏ `CHƯA CỌC`.
- [ ] **Thêm khách mới:** Từ màn hình lập hợp đồng, thêm hồ sơ khách không ảnh và thử lại với ảnh CCCD; form lưu xong đóng bình thường, không xuất hiện màn hình đen/assertion, danh sách khách cập nhật.
- [x] **Migration trạng thái BOOKED:** Người dùng báo đã chạy `202610150002_allow_booked_room_status.sql` thành công.

## LUỒNG 8: RÀ SOÁT NHẬN DIỆN GIAO DIỆN LOZIDO (07/11/2026)
- [ ] **Trang chủ:** Kiểm tra font Inter, header xanh lá, nền xám sáng, các thẻ module trắng bo góc và cách hiển thị tên nhà trọ dài.
- [ ] **Lưới phòng:** Kiểm tra màu trạng thái: đã thu xanh lá, chưa thu đỏ, đã cọc xanh dương, phòng trống cam, bảo trì xám; đối chiếu với hóa đơn thật.
- [ ] **Các form:** Kiểm tra font Inter, nền/viền ô nhập, nút chính và nút viền ở màn hình nhỏ; đảm bảo không tràn chữ hoặc mất tương phản.
- [ ] **Chế độ tối:** Kiểm tra nền navy đậm, bề mặt tối, chữ sáng và màu trạng thái vẫn phân biệt rõ.

## LUỒNG 9: XÁC NHẬN KHÔI PHỤC MÀU CHỦ ĐẠO (07/11/2026)
- [ ] Mở lại app trên LDPlayer: header trang chủ, tab đang chọn, nút chính và thanh điều hướng hiển thị xanh lá như màu cũ.
- [ ] Kiểm tra chữ và nền vẫn rõ; trạng thái phòng đã cọc xanh dương, chưa thu đỏ, phòng trống cam và bảo trì xám không bị đổi thành màu xanh.
- [ ] Kiểm tra cả giao diện sáng và tối.
