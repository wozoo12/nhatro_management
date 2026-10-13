import '../../../core/constants/payment_constants.dart';

/// Dịch vụ tạo URL VietQR động qua API img.vietqr.io.
class VietQRService {
  /// Tạo URL ảnh QR thanh toán với số tiền và nội dung chuyển khoản.
  static String generateQrImageUrl({
    required double amount,
    required String transferContent,
  }) {
    final encodedInfo = Uri.encodeComponent(transferContent);
    final encodedName = Uri.encodeComponent(PaymentConstants.accountName);
    return 'https://img.vietqr.io/image/'
        '${PaymentConstants.bankBin}-${PaymentConstants.accountNumber}-compact2.png'
        '?amount=${amount.round()}'
        '&addInfo=$encodedInfo'
        '&accountName=$encodedName';
  }

  /// Nội dung chuyển khoản chuẩn cho hóa đơn tiền trọ.
  static String buildTransferContent({
    required String roomNumber,
    required String monthYear,
  }) {
    return 'Tro P$roomNumber $monthYear';
  }
}
