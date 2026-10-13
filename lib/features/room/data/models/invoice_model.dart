/// Model đại diện cho Hóa đơn tiền nhà (Invoice)
class InvoiceModel {
  final int id;
  final int contractId;
  final int? readingId;
  final String monthYear; // Định dạng YYYY-MM
  final double roomCharge;
  final double elecCharge;
  final double waterCharge;
  final double otherFees;
  final double totalAmount;
  final String status; // UNPAID, PAID, OVERDUE
  final DateTime? paidAt;
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.contractId,
    this.readingId,
    required this.monthYear,
    required this.roomCharge,
    required this.elecCharge,
    required this.waterCharge,
    required this.otherFees,
    required this.totalAmount,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int,
      contractId: json['contract_id'] as int,
      readingId: json['reading_id'] as int?,
      monthYear: json['month_year'] as String,
      roomCharge: (json['room_charge'] as num).toDouble(),
      elecCharge: (json['elec_charge'] as num).toDouble(),
      waterCharge: (json['water_charge'] as num).toDouble(),
      otherFees: (json['other_fees'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
