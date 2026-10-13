/// Thông tin tài khoản ngân hàng dùng để tạo VietQR động.
/// Sang cần cập nhật các giá trị này theo tài khoản thật của chủ trọ.
class PaymentConstants {
  /// Mã BIN ngân hàng (VD: MB Bank = 970422, Vietcombank = 970436)
  static const String bankBin = '970422';

  /// Số tài khoản nhận tiền
  static const String accountNumber = '0123456789';

  /// Tên chủ tài khoản (không dấu, viết hoa)
  static const String accountName = 'NGUYEN HOANG SANG';

  /// Tên ngân hàng hiển thị trên UI
  static const String bankName = 'MB Bank';
}
