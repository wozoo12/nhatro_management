import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// [ElectricityReadingDialog] dùng để nhập chỉ số điện mới và tính tiền ngay lập tức.
/// Giao diện được thiết kế hiện đại với tính năng cập nhật kết quả theo thời gian thực (Live Update).
class ElectricityReadingDialog extends StatefulWidget {
  final String roomNumber;    // Số phòng (Ví dụ: 101)
  final String tenantName;    // Tên khách thuê
  final int previousReading;  // Chỉ số điện của tháng trước
  final double elecRate;      // Đơn giá điện (VNĐ/số)
  final double roomPrice;     // Tiền phòng hàng tháng
  final double fixedFee;      // Tổng các phí cố định (Nước, rác, wifi...)

  const ElectricityReadingDialog({
    super.key,
    required this.roomNumber,
    required this.tenantName,
    required this.previousReading,
    this.elecRate = 4000.0,
    this.roomPrice = 1500000.0,
    this.fixedFee = 100000.0,
  });

  @override
  State<ElectricityReadingDialog> createState() => _ElectricityReadingDialogState();
}

class _ElectricityReadingDialogState extends State<ElectricityReadingDialog> {
  // ===========================================================================
  // HỆ THỐNG MÀU SẮC CHUẨN THEO DESIGN SPEC
  // ===========================================================================
  static const Color primaryBlue = Color(0xFF2E7D32);
  static const Color accentBlue = Color(0xFF4CAF50);
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color mutedText = Color(0xFF64748B);
  static const Color liveCalcBg = Color(0xFFF0F9FF);
  static const Color fixedFeeBg = Color(0xFFF8FAFC);
  static const Color dividerBlue = Color(0xFFBAE6FD);

  /// Controller quản lý ô nhập chỉ số điện mới
  final TextEditingController _currentReadingController = TextEditingController();

  /// Đối tượng hỗ trợ định dạng tiền tệ VNĐ
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  int _currentReading = 0; // Giá trị chỉ số mới đang nhập
  int _usage = 0;          // Lượng điện tiêu thụ (Mới - Cũ)
  double _elecTotal = 0;   // Tổng tiền điện tính được
  double _grandTotal = 0;  // Tổng hóa đơn dự kiến (Điện + Phòng + Phí)

  @override
  void initState() {
    super.initState();
    // Ban đầu đặt chỉ số mới bằng chỉ số cũ để tránh số âm
    _currentReading = widget.previousReading;
    _calculate();
    // Đăng ký hàm lắng nghe sự thay đổi của ô nhập liệu để cập nhật UI ngay lập tức
    _currentReadingController.addListener(_onReadingChanged);
  }

  /// Xử lý mỗi khi người dùng gõ phím vào ô nhập chỉ số
  void _onReadingChanged() {
    final value = int.tryParse(_currentReadingController.text);
    setState(() {
      // Nếu ô trống hoặc nhập lỗi, mặc định lấy số cũ
      _currentReading = value ?? widget.previousReading;
      _calculate(); // Tính toán lại toàn bộ số liệu dựa trên giá trị mới
    });
  }

  /// Logic tính toán chi phí dựa trên dữ liệu người dùng nhập
  void _calculate() {
    // Đảm bảo số điện tiêu thụ không bị âm nếu người dùng nhập số nhỏ hơn kỳ trước
    _usage = _currentReading > widget.previousReading
        ? _currentReading - widget.previousReading
        : 0;
    _elecTotal = _usage * widget.elecRate;
    _grandTotal = widget.roomPrice + widget.fixedFee + _elecTotal;
  }

  @override
  void dispose() {
    _currentReadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================================
              // HEADER SECTION
              // =================================================================
              Row(
                children: [
                  // ⚡ Yellow/Amber Lightning Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chốt chỉ số điện',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkNavy),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Phòng ${widget.roomNumber} — ${widget.tenantName}',
                          style: const TextStyle(fontSize: 14, color: mutedText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // =================================================================
              // SECTION 1: INPUT FIELDS (SIDE-BY-SIDE ROW)
              // =================================================================
              const Text(
                'Chỉ số đồng hồ điện',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkNavy),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Ô hiển thị chỉ số kỳ trước (ReadOnly)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Chỉ số kỳ trước', style: TextStyle(fontSize: 12, color: mutedText)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '${widget.previousReading}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: mutedText,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Ô nhập chỉ số kỳ này (Active)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chỉ số kỳ này',
                          style: TextStyle(fontSize: 12, color: accentBlue, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _currentReadingController,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Nhập số mới',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: accentBlue, width: 2),
                            ),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================================
              // SECTION 2: LIVE CALCULATION (LIGHT BLUE TINT)
              // =================================================================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: liveCalcBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildCalcRow(
                      'Số điện tiêu thụ',
                      '$_usage số',
                      isBold: true,
                      valueColor: primaryBlue,
                    ),
                    _buildCalcRow(
                      'Đơn giá',
                      '${_currencyFormat.format(widget.elecRate)}/số',
                      valueColor: const Color(0xFF0369A1),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(color: dividerBlue, thickness: 0.8),
                    ),
                    _buildCalcRow(
                      'Thành tiền điện',
                      _currencyFormat.format(_elecTotal),
                      isBold: true,
                      fontSize: 16,
                      valueColor: primaryBlue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =================================================================
              // SECTION 3: FIXED FEES & ESTIMATED TOTAL
              // =================================================================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: fixedFeeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PHÍ CỐ ĐỊNH THÁNG NÀY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: mutedText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCalcRow('Tiền phòng', _currencyFormat.format(widget.roomPrice)),
                    _buildCalcRow('🗑️ Rác + 💧 Nước', _currencyFormat.format(widget.fixedFee)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(thickness: 0.5, color: Color(0xFFCBD5E1)),
                    ),
                    _buildCalcRow(
                      'Tổng dự kiến',
                      _currencyFormat.format(_grandTotal),
                      isBold: true,
                      fontSize: 16,
                      valueColor: primaryBlue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // =================================================================
              // ACTION BUTTONS ROW
              // =================================================================
              Row(
                children: [
                  // Button "Huỷ"
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      child: const Text(
                        'Huỷ',
                        style: TextStyle(color: mutedText, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Button "Lưu chỉ số"
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Trả về chỉ số mới cho màn hình cha để xử lý lưu vào Database
                        Navigator.pop(context, _currentReading);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lưu chỉ số',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hàm phụ để xây dựng một hàng thông tin trong bảng tính toán
  Widget _buildCalcRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 13,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: fontSize, color: mutedText),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}
