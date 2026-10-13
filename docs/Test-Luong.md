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

**Kết luận:** Nếu toàn bộ các Check-box trên đều tick [x], ứng dụng LOZIDO của bạn đã sẵn sàng đóng gói (Build APK/AAB) và tự tin tung ra thị trường!
