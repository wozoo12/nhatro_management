# ABC Design — thiết kế ảnh cho LOZIDO

Nhập một câu lệnh (tiêu đề bài viết) → hệ thống tự đối chiếu quy tắc thương hiệu và quy tắc thiết kế → xuất ảnh hoàn thiện.

## Cấu trúc thư mục

```
ABC_Design/
├── rules/
│   ├── brand.json     # Thương hiệu: màu, màu trạng thái phòng, font, giọng văn, từ cấm
│   ├── design.json    # Thiết kế: kích thước, lề, cỡ chữ, lưới phòng, ngưỡng tương phản
│   └── themes.json    # Từ khóa trong tiêu đề → chủ đề hình ảnh
├── assets/fonts/      # Inter ExtraBold / SemiBold / Medium (hỗ trợ tiếng Việt, giấy phép OFL)
├── src/abc_design.py  # Bộ tạo ảnh
└── output/            # Ảnh xuất ra + file báo cáo kiểm tra (.report.json)
```

## Luồng chạy

1. **Tiêu đề** → làm sạch (bỏ emoji, đổi chữ HOA về viết hoa đầu câu, gộp dấu câu lặp)
2. **Đối chiếu quy tắc thương hiệu** → độ dài, từ cường điệu bị cấm, màu và font cho phép
3. **Nhận diện chủ đề** từ từ khóa (hóa đơn, đặt cọc, trả phòng, tìm khách, sửa chữa, hợp đồng)
4. **Đối chiếu quy tắc thiết kế** → tự chọn cỡ chữ, cân dòng, kiểm tra tương phản WCAG ≥ 4.5:1
5. **Xuất ảnh** PNG + báo cáo ✔ / ✎ (tự sửa) / ⚠ (cảnh báo) / ✖ (chặn, cần sửa tiêu đề)

## Cách dùng

```bash
pip install pillow
python src/abc_design.py "Tạo hóa đơn VietQR trong 30 giây"
python src/abc_design.py "Đặt cọc giữ phòng" --sub "Tiền cọc tự trừ khi ký hợp đồng" --format all
python src/abc_design.py "Cách xử lý sự cố điện" --theme maintenance
```

Định dạng: `post` (1080×1350), `square` (1080×1080), `story` (1080×1920), hoặc `all`.

## Ý tưởng hình ảnh

Mỗi ảnh là một mặt tiền dãy trọ: lưới ô phòng lấy đúng quy ước màu của app
(xanh lá đã thu, đỏ chưa thu, xanh dương đã cọc, cam trống, xám sửa chữa).
Chủ đề của tiêu đề quyết định trạng thái nào chiếm nhiều nhất, ví dụ bài về đặt cọc sẽ nhiều ô xanh dương.

## Tùy chỉnh

- Đổi màu thương hiệu: sửa `ink`, `accent` trong `rules/brand.json` cho khớp seed color của `app_theme.dart`.
- Thêm chủ đề hoặc từ khóa: sửa `rules/themes.json` (từ khóa viết không dấu, chữ thường).
- Siết hoặc nới quy tắc: sửa `rules/design.json`.

## Dùng với Claude

Tải thư mục này lên một cuộc chat hoặc Project mới, dán nội dung `PROJECT_INSTRUCTIONS.md`.
Từ đó chỉ cần gõ: `tạo ảnh: <tiêu đề>`.
