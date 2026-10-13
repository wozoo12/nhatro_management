import 'package:url_launcher/url_launcher.dart';

class ZaloService {
  /// Mở ứng dụng Zalo (hoặc link web nếu không có app) với số điện thoại được điền sẵn
  static Future<void> openZaloChat(String phoneNumber, {String? message}) async {
    // Chuẩn hóa số điện thoại: bỏ số 0 ở đầu và thêm +84 nếu cần, 
    // nhưng link zalo.me/phone hỗ trợ định dạng chuẩn 09xxx hoặc 849xxx
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Tạo link zalo.me
    final uri = Uri.parse('https://zalo.me/$cleanPhone');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Không thể mở Zalo. Vui lòng kiểm tra lại số điện thoại hoặc cài đặt app Zalo.';
      }
    } catch (e) {
      throw 'Đã xảy ra lỗi khi mở Zalo: $e';
    }
  }

  /// Tạo mẫu tin nhắn nhắc nợ / gửi hóa đơn
  static String buildInvoiceMessage({
    required String roomNumber,
    required String monthYear,
    required double totalAmount,
    required String dueDate,
  }) {
    return 'Xin chào! Gửi bạn hóa đơn tiền trọ Phòng $roomNumber tháng $monthYear.\n'
        'Tổng số tiền: ${totalAmount.toStringAsFixed(0)} VNĐ.\n'
        'Hạn thanh toán: $dueDate.\n'
        'Vui lòng thanh toán sớm nhé. Cảm ơn bạn!';
  }
}
