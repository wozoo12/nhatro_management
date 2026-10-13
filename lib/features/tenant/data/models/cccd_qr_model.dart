/// Model chứa dữ liệu sau khi giải mã mã QR của thẻ CCCD gắn chip (Bộ Công An)
class CccdQrModel {
  final String cccdNumber;    // Số CCCD 12 số
  final String? cmndNumber;   // Số CMND cũ 9 số (nếu có)
  final String fullName;      // Họ và tên
  final String birthDate;     // Ngày tháng năm sinh (dd/MM/yyyy)
  final String gender;        // Giới tính (Nam/Nữ)
  final String address;       // Nơi thường trú
  final String? issueDate;    // Ngày cấp (dd/MM/yyyy)

  const CccdQrModel({
    required this.cccdNumber,
    this.cmndNumber,
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.address,
    this.issueDate,
  });

  @override
  String toString() {
    return 'CccdQrModel(cccd: $cccdNumber, name: $fullName, dob: $birthDate, gender: $gender, address: $address)';
  }
}
