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

### 10. Hoàn thiện 3 Tab Thanh điều hướng chính (Cập nhật 13/10/2026)
- [x] **Tab CÔNG VIỆC (`TasksView`):**
  - Quản lý công việc và nhắc nhở lịch hẹn với BLoC (`TaskCubit`, `TaskState`).
  - Thanh đo tiến độ tổng quan (Cần làm / Đã xong).
  - Bộ lọc danh mục theo Chip: Sự cố, Lịch hẹn, Thu tiền, Việc cá nhân.
  - Checkbox đánh dấu hoàn thành nhanh, nút xóa, và `AddTaskBottomSheet` hỗ trợ tạo việc mới kèm thời hạn và mức độ ưu tiên.
- [x] **Tab TÌM KHÁCH (`TenantFindingView`):**
  - Quản lý tỷ lệ lấp đầy và phòng trống với BLoC (`TenantFindingCubit`, `TenantFindingState`).
  - Sub-tab "Đăng tin phòng trống": Thẻ phòng trống với giá, diện tích, tiện nghi và mẫu tin đăng chuẩn SEO kèm nút sao chép 1-chạm hoặc chia sẻ qua Zalo/Facebook.
  - Sub-tab "Khách tiềm năng (Leads CRM)": Quản lý danh sách người hỏi thuê phòng, ngày hẹn xem, nút gọi điện thoại trực tiếp (`url_launcher`), nhắn tin Zalo (`ZaloService`), và `AddLeadBottomSheet` để thêm khách mới.
- [x] **Tab THÊM (`MoreView`):**
  - Thẻ profile chủ nhà chuyên nghiệp ("Chủ trọ Pro").
  - Menu gom nhóm khoa học: Quản lý & Vận hành (Ngân hàng/VietQR, Sổ quỹ, Tài sản, Sự cố), Tiện ích ngoại vi (Máy in nhiệt Bluetooth 58mm, Zalo ZNS, Mẫu nội quy trọ), Hệ thống & Bảo mật (Dark mode toggle, Sinh trắc học, Thông tin ứng dụng, Đăng xuất Supabase an toàn).
- [x] **Sửa triệt để các lỗi Layout Pixel Overflow:**
  - Tab "CÔNG VIỆC": Khắc phục lỗi `OVERFLOWED BY 20 PIXELS` trong thẻ công việc bằng cấu trúc Custom `Row` + `Expanded(Column)` + `Wrap` tags.
  - Tab "TÌM KHÁCH" (Khách tiềm năng): Khắc phục lỗi `RIGHT OVERFLOWED BY 14 PIXELS` trên màn hình hẹp (360px-390px) bằng `Wrap` cho cụm phòng quan tâm & ngân sách, thêm `maxLines: 1` kèm `TextOverflow.ellipsis` cho tên khách và số phòng.

### 11. Hoàn thiện các tính năng cốt lõi tại Tab TRANG CHỦ (Cập nhật 13/10/2026)
- [x] **Top Header đa năng:**
  - Nút **Quét QR**: Tích hợp `CccdScannerView` mở camera quét thẻ CCCD gắn chip, tự động hiển thị thông tin công dân và nút chuyển sang ký hợp đồng ngay.
  - Dropdown tên nhà trọ & Icon Menu: Mở BottomSheet cho phép chuyển đổi tức thì giữa các nhà trọ trong danh sách hoặc bấm thêm nhà mới (`PropertyWizardView`).
- [x] **Thanh lý / Trả phòng theo phòng thực tế (`SelectableCheckoutRoomsView`):**
  - Thay thế việc hardcode phòng 101 bằng màn hình chọn phòng đang có khách thuê (`contract != null`).
  - Truyền dữ liệu số phòng, giá thuê và tiền cọc thực tế vào `RoomCheckoutView` để quyết toán chính xác.
- [x] **Cọc giữ chỗ & Ghi sổ quỹ thật (`AddDepositView`):**
  - Bổ sung controller số điện thoại, kết nối `FinanceCubit.acceptDeposit` để ghi nhận giao dịch vào Sổ quỹ.
  - Sau khi cọc, popup hiển thị thông tin tài khoản thật kèm nút **Chia sẻ** biên nhận cọc và nút **Gửi Zalo** trực tiếp cho khách thuê.
- [x] **Tab Tổng quan tương tác thời gian thực:**
  - Thẻ nhắc nhở "Hóa đơn chưa thu": Đếm số hóa đơn `UNPAID` từ `InvoiceBloc`, bấm vào mở `InvoiceListView`.
  - Thẻ "Nợ tiền cần thu": Tính tổng số tiền các hóa đơn nợ thật, bấm vào mở `InvoiceListView`.
  - Biểu đồ "Tỷ lệ lấp đầy" (`OccupancyPieChartWidget`): Tự động tính toán tỷ lệ % phòng đang thuê / phòng trống dựa trên số lượng phòng thực tế từ `RoomBloc`.

---
**Developer:** Nguyễn Hoàng Sang
**Cập nhật lần cuối:** 13/10/2026

## 12. Sửa lỗi theo đợt test LDPlayer (15/10/2026)
- [x] **Sheet chọn loại hình nhà trọ:** Giới hạn chiều cao theo màn hình, thêm vùng an toàn và cuộn được để tránh `BOTTOM OVERFLOWED`.
- [x] **Bản đồ chọn vị trí:** Thay placeholder bằng bản đồ OpenStreetMap có thể kéo/zoom, ghim vị trí ở tâm, tìm địa chỉ, lấy GPS và reverse geocoding. Lưu tọa độ cùng địa chỉ trong `properties`.
- [x] **Cọc giữ chỗ:** Lưu thông tin người cọc/số điện thoại/tiền cọc/ngày dự kiến vào `room_reservations`; đổi trạng thái phòng sang `BOOKED` và biểu thị bằng xanh dương. Luồng nhận cọc gọi RPC để cập nhật trạng thái và tạo reservation trong một giao dịch.
- [x] **Ký hợp đồng từ phòng đã cọc:** Danh sách ký hợp đồng gồm phòng trống và phòng đã cọc. Với phòng đã cọc, chỉ cho ký đúng người đặt cọc; tiền đã cọc được tính vào `actual_deposit`, màn hình hiển thị số đã nhận và số còn thiếu, khi ký thì chuyển reservation sang `CONVERTED` và phòng sang `OCCUPIED`.
- [x] **Thanh lý hợp đồng:** Ghi hợp đồng thành `TERMINATED`, ngày kết thúc và đưa phòng về `AVAILABLE` bằng RPC; danh sách trả phòng hiển thị nhãn trạng thái thuê màu xanh lá. Sau khi xác nhận, dashboard được yêu cầu tải lại.
- [x] **Quy ước màu theo thanh toán:** Phòng `BOOKED` hiển thị xanh dương; phòng đang thuê có hóa đơn chưa trả hiển thị đỏ, chỉ hóa đơn `PAID` mới hiển thị xanh lá trong lưới phòng.
- [x] **Migration Supabase:** Người dùng xác nhận đã áp dụng `supabase/migrations/202610150001_room_reservations.sql` thành công.
- [ ] **Kiểm thử lại trên LDPlayer và đánh dấu checklist E2E:** Chưa xác nhận bằng chạy thử sau các thay đổi này.

## 13. Sửa tiếp lỗi phát sinh khi test Supabase/LDPlayer (15/10/2026)
- [x] **Ràng buộc trạng thái phòng:** Bổ sung migration `202610150002_allow_booked_room_status.sql` để constraint `rooms_status_check` chấp nhận `BOOKED`. Ảnh test cho thấy lần nhận cọc trước bị rollback vì DB chưa cho phép trạng thái này.
- [x] **Tải lại danh sách cọc:** `SelectableBookingRoomsView` tự tải lại dữ liệu tổng hợp theo nhà đang chọn khi mở và sau khi đóng form nhận cọc, không còn phụ thuộc dữ liệu còn sót trong `RoomBloc` sau màn hình ký hợp đồng.
- [x] **Định dạng tiền:** Thêm phân cách hàng nghìn bằng dấu chấm cho ô nhận cọc, tiền cọc khi ký hợp đồng, tiền cọc phát sinh, ngân sách khách tiềm năng và giá thuê nhập tại các form đã rà soát.
- [x] **Vị trí dự phòng:** Bổ sung chọn bằng tọa độ nhập tay, hỗ trợ nhập cặp vĩ độ/kinh độ vào tìm kiếm, cho phép chọn tọa độ khi tra địa chỉ mạng lỗi và hiển thị lỗi GPS cụ thể hơn.
- [x] **Migration trạng thái phòng:** Người dùng xác nhận đã chạy `supabase/migrations/202610150002_allow_booked_room_status.sql` thành công sau migration `202610150001`.
- [ ] **Cần thử lại trên LDPlayer:** Cấp quyền vị trí cho app và bật Location trong Android/LDPlayer; kiểm tra internet nếu bản đồ/tra cứu địa chỉ không tải.



## 14. Theo dõi lần test tiếp theo trên LDPlayer (15/10/2026)
- [x] Người dùng xác nhận đã cấp quyền vị trí cho LDPlayer/app và chạy migration `202610150002_allow_booked_room_status.sql` thành công.
- [x] Người dùng xác nhận chọn ghim trực tiếp trên bản đồ được; thao tác nhập tọa độ thủ công còn lỗi.
- [x] Bản đồ: tọa độ nhập bằng dấu phẩy thập phân được chuẩn hóa; truy vấn reverse-geocoding có timeout 8 giây và nút xác nhận tọa độ không còn bị khóa trong lúc đợi địa chỉ.
- [x] Hợp đồng từ phòng đã cọc: hiển thị thẻ xanh dương tên/số điện thoại người cọc thay cho dropdown khách; khi lưu hợp đồng dùng đúng khách đã đặt cọc, tự tạo hồ sơ theo tên/số điện thoại nếu chưa có.
- [x] Danh sách ký hợp đồng: phòng đã cọc có nhãn và màu xanh dương; phòng chưa cọc có nhãn màu đỏ.
- [x] Thêm khách: đưa thao tác đóng form thành post-frame và bỏ tải danh sách trùng ngay trong BLoC; các màn hình cha tải lại sau khi form đóng để giảm xung đột vòng đời khi điều hướng.
- [ ] Người dùng cần retest nhập tọa độ thủ công, hợp đồng với phòng đã cọc và thêm khách trên LDPlayer; ảnh hiện tại chưa có stack trace đầy đủ để xác nhận nguyên nhân duy nhất của assertion Flutter.

## 15. Đồng bộ nhận diện giao diện theo ABC_Design (07/11/2026)
- [x] Đọc quy tắc thương hiệu và đưa Inter cùng các thành phần theme vào app; sau đó khôi phục màu chủ đạo xanh lá theo yêu cầu người dùng. Bảng màu chạy thực tế được ghi ở mục 16.
- [x] Đăng ký font Inter Medium/SemiBold/ExtraBold có sẵn từ `ABC_Design/assets/fonts` và đặt typography/theme dùng chung cho app.
- [x] Đồng bộ màn hình trang chủ: header xanh lá, thẻ module bo góc/nhẹ, màu icon giới hạn theo bảng màu thương hiệu, điều hướng dùng màu chủ đạo.
- [x] Đồng bộ màu trạng thái trong lưới phòng theo quy ước của bộ nhận diện.
- [ ] Cần mở app trên LDPlayer và rà lại các màn hình chính/sáng tối; một số màn hình cũ có màu gán trực tiếp nên cần các lượt đồng bộ tiếp theo.

## 16. Khôi phục màu chủ đạo xanh lá theo xác nhận của người dùng (07/11/2026)
- [x] Đổi màu chính toàn app và các nút/hành động theo theme về `#2E7D32`; dark theme dùng xanh lá `#4CAF50`.
- [x] Khôi phục nền xám sáng, màu chữ trung tính và các màu cũ của app; giữ quy ước trạng thái phòng xanh lá/đỏ/xanh dương/cam/xám.
- [x] Đổi header trang chủ, tab đang chọn và thanh điều hướng từ navy về xanh lá.
- [x] Cập nhật `ABC_Design/rules/brand.json` để bộ sinh ảnh dùng xanh lá làm màu LOZIDO, không còn navy là màu thương hiệu chính.
- [ ] Người dùng cần chạy lại app và xác nhận màu xanh lá đã trở lại trên LDPlayer.
