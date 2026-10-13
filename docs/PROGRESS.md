# Nhật ký Tiến độ Dự án LOZIDO - Quản lý Nhà trọ

## 📌 Tổng quan
- **Sản phẩm:** Mobile App LOZIDO (Chủ nhà)
- **Kiến trúc:** Feature-First Clean Architecture + BLoC
- **Backend:** Supabase (PostgreSQL + Cloud Storage + Auth)
- **Trạng thái (Cập nhật 28/09/2026):** **HOÀN THÀNH 100% LUỒNG NGHIỆP VỤ E2E TỪ TẠO HỢP ĐỒNG ĐẾN THU TIỀN**.

---

## 🛠 Các Module đã hoàn thiện (End-to-End)

### 1. Luồng Xác thực & Khởi tạo (Auth & Onboarding)
- [x] Đăng nhập & Đăng ký: Tích hợp luồng Xác thực Email OTP thật (Supabase Auth), gửi mã 6 số qua email.
- [x] Luồng Quên mật khẩu: Gọi resetPasswordForEmail, xác thực mã OTP thật và cập nhật mật khẩu an toàn.
- [x] Wizard tạo nhà trọ: Validate dữ liệu đầu vào (chặn số âm, bắt lỗi rỗng), tích hợp Bản đồ (Address/Map Picker), thêm trường cấu hình (Ngày chốt tiền, Số người tối đa).

### 2. Module Hợp đồng & Khách thuê
- [x] **Quét mã QR CCCD gắn chip:** Trích xuất tự động 100% thông tin khách thuê (Số CCCD, Họ tên, Ngày sinh, Địa chỉ...).
- [x] **Trình quét hiện đại (`CccdScannerView`):** Giao diện quét laser xanh, bật flash, chọn ảnh từ gallery.
- [x] **Lập hợp đồng nhanh:** Quét CCCD để tự động điền form Hợp đồng hoặc tự động nhận diện khách cũ. Nối luồng trực tiếp từ Dashboard.

### 3. Module Hóa đơn & Thu tiền
- [x] **Quản lý hóa đơn:** Tạo và xem chi tiết hóa đơn (Tiền phòng, điện nước, dịch vụ).
- [x] **Xuất PDF & In ấn:** Hỗ trợ xuất hóa đơn ra file PDF và in trực tiếp qua máy in nhiệt Bluetooth (Mini Thermal Printer 58mm).
- [x] **Thanh toán QR (VietQR):** Tự động sinh mã QR thanh toán trên hóa đơn. Mã QR đã nhúng sẵn Số tiền và Nội dung chuyển khoản (VD: "Tro P101 2026-09"). Khách chỉ cần quét là xong.
- [x] **Zalo Notification (`ZaloService`):** Tích hợp nút "Gửi Zalo cho khách" trên Hóa đơn. Tự động mở app Zalo, điền sẵn số điện thoại khách và nội dung tin nhắn báo phí chuyên nghiệp.

### 4. Module Vận hành & Quản lý
- [x] **Thanh lý / Trả phòng (`RoomCheckoutView`):** Luồng làm thủ tục cho khách dọn đi. Tự động cấn trừ tiền cọc, tính toán điện nước tháng cuối để chốt số tiền cần thu thêm hoặc hoàn trả.
- [x] **Quản lý tài sản (`AssetManagementView`):** Kiểm kê trang thiết bị, nội thất trong phòng (Máy lạnh, chìa khóa...). Dễ dàng đánh dấu tình trạng Hư hỏng/Bình thường qua công tắc trực quan.

### 5. Module Báo cáo & Hệ thống
- [x] **Biểu đồ doanh thu:** Tích hợp `fl_chart` vẽ biểu đồ cột (BarChart) 6 tháng gần nhất tại tab Tổng quan, hỗ trợ xem số tiền chi tiết khi chạm vào cột.
- [x] **Sổ quỹ / Thu chi (`FinanceView`):** Thống kê dòng tiền ra/vào và lợi nhuận thực tế của nhà trọ.
- [x] **Cài đặt & Hệ thống (`SettingsView`):** Cấu hình ngân hàng nhận tiền (dùng cho QR), cấu hình thông báo (Push / Tự động nhắc nợ) và quản lý bảo mật (Sinh trắc học).

## 🚀 Các tính năng Nâng cao (Bản Super App V2 - Hoàn thiện 21/09/2026)

### 6. Cải tiến UI/UX & Dark Mode
- [x] **Dark Mode (Chế độ ban đêm):** Tích hợp Theme động tự chuyển đổi Light/Dark theo hệ điều hành. Thiết lập lại cấu trúc màu sắc (`app_theme.dart`) trên toàn hệ thống.
- [x] **Micro-animations:** Cài đặt package `lottie` chuẩn bị cho các hiệu ứng tương tác cao cấp.

### 7. Bảng điều khiển Thông minh (Dashboard 2.0)
- [x] **Smart Reminders:** Bổ sung thanh cuộn Lời nhắc thông báo nhanh các Hóa đơn quá hạn, Hợp đồng sắp hết, và Yêu cầu sửa chữa.
- [x] **Tỷ lệ lấp đầy (Occupancy):** Thêm biểu đồ hình tròn (Pie Chart) bằng `fl_chart` hiển thị sinh động tình trạng phòng đang thuê và phòng trống.

### 8. Quản lý Vận hành
- [x] **Quản lý sự cố (Ticketing):** Tính năng theo dõi các vấn đề cần sửa chữa (Hư ống nước, cháy đèn...). Hỗ trợ đổi trạng thái Đang chờ -> Đang sửa -> Đã xong và tính chi phí sửa chữa.

### 9. Fix lỗi & Hoàn thiện luồng E2E (Cập nhật 28/09/2026)
- [x] **Luồng Ký hợp đồng:** Khắc phục lỗi Crash ở `CreateContractView` do sai kiểu dữ liệu (`_selectedTenantId` thay vì `TenantModel`).
- [x] **Supabase Storage:** Sửa lỗi từ chối quyền tải ảnh lên bucket `tenants-cccd` bằng cách hướng dẫn cấu hình Policy RLS (cho phép `INSERT`).
- [x] **Đồng bộ Giao diện:** Trỏ tính năng "Quản lý phòng" ở Trang chủ về đúng `DashboardView` chứa dữ liệu thật và các logic nghiệp vụ (Chốt điện, Lập hóa đơn).
- [x] **Sửa lỗi UI (Pixel Overflow):** Sửa lỗi tràn giao diện bằng cách thêm `SingleChildScrollView` cho khung xem Hóa đơn (`InvoicePreviewDialog`).
- [x] **Đồng bộ màu sắc & UX:** Chuyển đổi toàn bộ theme của App sang màu Xanh lá chủ đạo (`primaryGreen`), nhưng xử lý thông minh để giữ lại các màu nhận diện thương hiệu (Xanh Zalo) và màu trạng thái (Xanh dương cho 'Đang ở', Đỏ cho 'Nợ tiền'). Sửa lỗi biên dịch do biến màu bị ghi đè.
- [x] **Hoàn thiện Điều hướng (Navigation):** Bổ sung `AppBar` chuẩn và nút Quay lại (Back) cho màn hình Quản lý phòng (`DashboardView`).
- [x] **E2E Flow Verified:** Luồng đi từ Tạo khách hàng -> Ký hợp đồng -> Khởi tạo Hóa đơn (Chốt điện) -> Gửi Zalo/VietQR thanh toán -> Đánh dấu Đã Thu Tiền đã hoạt động thông suốt 100%.

---
**Developer:** Nguyễn Hoàng Sang
**Cập nhật lần cuối:** 28/09/2026
