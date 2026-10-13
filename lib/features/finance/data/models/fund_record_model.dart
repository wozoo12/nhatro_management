enum FundType { thu, chi }

class FundRecordModel {
  final String id;
  final String title;
  final double amount;
  final FundType type;
  final DateTime date;
  final String category; // Cọc giữ chỗ, Tiền phòng, Sửa chữa...
  final String? roomId;
  final String? tenantName;

  FundRecordModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    this.roomId,
    this.tenantName,
  });
}
