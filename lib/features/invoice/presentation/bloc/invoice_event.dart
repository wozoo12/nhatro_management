import 'package:equatable/equatable.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

/// Tải lịch sử hóa đơn theo khu nhà.
class FetchInvoices extends InvoiceEvent {
  final int propertyId;
  const FetchInvoices(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

/// Tạo hóa đơn mới (Dùng cho luồng Lập hóa đơn thủ công)
class CreateManualInvoice extends InvoiceEvent {
  final int contractId;
  final String monthYear;
  final double roomCharge;
  final double otherFees;
  final int propertyId;

  const CreateManualInvoice({
    required this.contractId,
    required this.monthYear,
    required this.roomCharge,
    required this.otherFees,
    required this.propertyId,
  });

  @override
  List<Object?> get props => [contractId, monthYear, roomCharge, otherFees, propertyId];
}

/// Cập nhật trạng thái thanh toán (PAID / UNPAID).
class UpdateInvoiceStatus extends InvoiceEvent {
  final int invoiceId;
  final String status;
  final int propertyId;

  const UpdateInvoiceStatus({
    required this.invoiceId,
    required this.status,
    required this.propertyId,
  });

  @override
  List<Object?> get props => [invoiceId, status, propertyId];
}
