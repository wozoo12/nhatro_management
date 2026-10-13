import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhatro_management/features/invoice/data/repositories/invoice_repository.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_state.dart';

/// BLoC quản lý logic Module 3: Hóa đơn & Thanh toán.
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository _repository;

  InvoiceBloc(this._repository) : super(InvoiceInitial()) {
    on<FetchInvoices>(_onFetchInvoices);
    on<UpdateInvoiceStatus>(_onUpdateInvoiceStatus);
    on<CreateManualInvoice>(_onCreateManualInvoice);
  }

  Future<void> _onFetchInvoices(FetchInvoices event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoading());
    try {
      final invoices = await _repository.getInvoicesByProperty(event.propertyId);
      emit(InvoiceLoaded(invoices: invoices));
    } catch (e) {
      emit(InvoiceError('Lỗi tải hóa đơn: ${e.toString()}'));
    }
  }

  Future<void> _onCreateManualInvoice(CreateManualInvoice event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoading());
    try {
      await _repository.createInvoice(
        contractId: event.contractId,
        monthYear: event.monthYear,
        roomCharge: event.roomCharge,
        otherFees: event.otherFees,
        status: 'UNPAID',
      );
      // Sau khi tạo thành công, tải lại danh sách hóa đơn mới nhất
      final invoices = await _repository.getInvoicesByProperty(event.propertyId);
      emit(InvoiceLoaded(invoices: invoices, message: 'Lập hóa đơn thành công!'));
    } catch (e) {
      emit(InvoiceError('Lỗi lập hóa đơn: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateInvoiceStatus(UpdateInvoiceStatus event, Emitter<InvoiceState> emit) async {
    final currentState = state;
    emit(InvoiceLoading());
    try {
      await _repository.updateInvoiceStatus(event.invoiceId, event.status);
      final invoices = await _repository.getInvoicesByProperty(event.propertyId);
      final label = event.status == 'PAID' ? 'Đã đánh dấu thanh toán' : 'Đã đánh dấu chưa thanh toán';
      emit(InvoiceLoaded(invoices: invoices, message: label));
    } catch (e) {
      emit(InvoiceError('Lỗi cập nhật: ${e.toString()}'));
      if (currentState is InvoiceLoaded) emit(currentState);
    }
  }
}
