import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dịch vụ chia sẻ nội dung hóa đơn qua Zalo, SMS hoặc ứng dụng khác.
class InvoiceShareService {
  static final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  /// Tạo nội dung tin nhắn hóa đơn dạng text.
  static String buildInvoiceMessage({
    required String roomNumber,
    required String tenantName,
    required String monthYear,
    required String dueDate,
    required double roomRent,
    required double serviceFee,
    required int elecUsage,
    required double elecRate,
    required int elecBefore,
    required int elecAfter,
    required double grandTotal,
  }) {
    final displayMonth = _formatMonthYear(monthYear);
    final elecTotal = elecUsage * elecRate;

    return '''
🏠 HÓA ĐƠN TIỀN TRỌ — Tháng $displayMonth

📍 Phòng: $roomNumber
👤 Người thuê: $tenantName
📅 Hạn đóng: $dueDate

💰 Chi tiết:
• Tiền phòng: ${_currencyFormat.format(roomRent)}
• Rác + Nước: ${_currencyFormat.format(serviceFee)}
• Điện: $elecUsage số × ${_currencyFormat.format(elecRate)} = ${_currencyFormat.format(elecTotal)}
  (Chỉ số: $elecBefore → $elecAfter)

✅ TỔNG CỘNG: ${_currencyFormat.format(grandTotal)}

Vui lòng thanh toán đúng hạn. Xin cảm ơn!
'''.trim();
  }

  /// Chia sẻ qua hệ thống (chọn Zalo, Messenger, v.v.).
  static Future<void> shareViaSystem(String message) async {
    await Share.share(message, subject: 'Hóa đơn tiền trọ');
  }

  /// Mở Zalo chat với số điện thoại khách (Sang tự dán nội dung hóa đơn).
  static Future<bool> openZaloChat(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return false;

    // Zalo yêu cầu số điện thoại định dạng 84xxxxxxxxx
    final zaloPhone = cleaned.startsWith('0') ? '84${cleaned.substring(1)}' : cleaned;
    final uri = Uri.parse('https://zalo.me/$zaloPhone');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Mở ứng dụng SMS với nội dung hóa đơn đã điền sẵn.
  static Future<bool> openSms(String phoneNumber, String message) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return false;

    final uri = Uri.parse('sms:$cleaned?body=${Uri.encodeComponent(message)}');
    return launchUrl(uri);
  }

  static String _formatMonthYear(String my) {
    try {
      final parts = my.split('-');
      if (parts.length == 2) return '${int.parse(parts[1])}/${parts[0]}';
    } catch (_) {}
    return my;
  }
}
