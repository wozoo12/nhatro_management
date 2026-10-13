enum TransactionType { thu, chi }

class FinanceTransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String category; // Cọc giữ chỗ, Thu tiền tháng, Hoàn cọc, Sửa chữa...
  final String? roomId;
  final String? tenantName;
  final String? note;

  FinanceTransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    this.roomId,
    this.tenantName,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'type': type.name,
    'date': date.toIso8601String(),
    'category': category,
    'room_id': roomId,
    'tenant_name': tenantName,
    'note': note,
  };
}
