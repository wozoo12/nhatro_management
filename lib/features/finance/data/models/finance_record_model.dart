enum TransactionType { thu, chi }

class FinanceRecordModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime createdAt;
  final String category; // Cọc giữ chỗ, Tiền phòng, Sửa chữa, Hoàn cọc...
  final String? roomId;
  final String? note;

  FinanceRecordModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.category,
    this.roomId,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'type': type.name,
    'created_at': createdAt.toIso8601String(),
    'category': category,
    'room_id': roomId,
    'note': note,
  };
}
