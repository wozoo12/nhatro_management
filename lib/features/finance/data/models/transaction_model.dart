import 'package:equatable/equatable.dart';

enum TransactionType { thu, chi }

class TransactionModel extends Equatable {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String category;
  final String? roomId;
  final String? refId; // ID của Hợp đồng hoặc Phiếu cọc liên quan

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    this.roomId,
    this.refId,
  });

  @override
  List<Object?> get props => [id, title, amount, type, date, category, roomId, refId];
}
