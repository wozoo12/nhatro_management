import '../../features/tenant/data/models/cccd_qr_model.dart';

/// Tiện ích phân tích và trích xuất dữ liệu từ mã QR trên thẻ CCCD gắn chip (Việt Nam)
/// Cấu trúc chuẩn:
/// [Số CCCD]|[Số CMND cũ]|[Họ và tên]|[Ngày sinh]|[Giới tính]|[Nơi thường trú]|[Ngày cấp]
class CccdParser {
  /// Phân tích chuỗi dữ liệu mã QR
  /// Trả về [CccdQrModel] nếu đúng định dạng, hoặc ném [FormatException] nếu không hợp lệ
  static CccdQrModel parse(String rawData) {
    final cleaned = rawData.trim();
    if (!cleaned.contains('|')) {
      throw const FormatException('Mã QR không đúng định dạng CCCD gắn chip (thiếu ký tự phân tách |)');
    }

    final parts = cleaned.split('|');

    // Chuẩn thẻ CCCD thường có từ 6 đến 7 trường dữ liệu
    if (parts.length < 6) {
      throw const FormatException('Mã QR không đủ thông tin của thẻ CCCD gắn chip');
    }

    final cccdNumber = parts[0].trim();
    final cmndNumber = parts[1].trim().isEmpty ? null : parts[1].trim();
    final fullName = _normalizeName(parts[2].trim());
    final rawDob = parts[3].trim();
    final gender = parts[4].trim();
    final address = parts[5].trim();
    final rawIssueDate = parts.length > 6 ? parts[6].trim() : null;

    // Kiểm tra số CCCD (thường gồm 12 số)
    if (cccdNumber.isEmpty || cccdNumber.length < 9) {
      throw const FormatException('Số CCCD trong mã QR không hợp lệ');
    }

    final formattedDob = _formatDate(rawDob);
    final formattedIssueDate = rawIssueDate != null ? _formatDate(rawIssueDate) : null;

    return CccdQrModel(
      cccdNumber: cccdNumber,
      cmndNumber: cmndNumber,
      fullName: fullName,
      birthDate: formattedDob,
      gender: gender,
      address: address,
      issueDate: formattedIssueDate,
    );
  }

  /// Định dạng ngày sinh / ngày cấp từ chuỗi ddMMyyyy hoặc yyyy thành dd/MM/yyyy
  static String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    // Trường hợp 8 số ddMMyyyy
    if (rawDate.length == 8 && int.tryParse(rawDate) != null) {
      final day = rawDate.substring(0, 2);
      final month = rawDate.substring(2, 4);
      final year = rawDate.substring(4, 8);
      return '$day/$month/$year';
    }
    // Trường hợp chỉ có năm sinh 4 số
    if (rawDate.length == 4 && int.tryParse(rawDate) != null) {
      return rawDate;
    }
    return rawDate;
  }

  /// Chuẩn hóa Họ và tên sang viết hoa chữ cái đầu (Title Case) hoặc giữ nguyên
  static String _normalizeName(String rawName) {
    if (rawName.isEmpty) return '';
    final words = rawName.toLowerCase().split(' ');
    final capitalizedWords = words.where((w) => w.isNotEmpty).map((w) {
      return w[0].toUpperCase() + w.substring(1);
    });
    return capitalizedWords.join(' ');
  }
}
