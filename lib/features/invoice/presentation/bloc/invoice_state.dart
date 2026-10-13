import 'package:equatable/equatable.dart';
import 'package:nhatro_management/features/invoice/data/models/invoice_detail_model.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<InvoiceDetailModel> invoices;
  final String? message;

  const InvoiceLoaded({
    required this.invoices,
    this.message,
  });

  @override
  List<Object?> get props => [invoices, message];
}

class InvoiceError extends InvoiceState {
  final String message;
  const InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}
