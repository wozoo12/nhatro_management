import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhatro_management/features/invoice/presentation/cubit/checkout_state.dart';
import 'package:nhatro_management/features/room/data/repositories/room_repository.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final RoomRepository? _roomRepository;
  CheckoutCubit([this._roomRepository]) : super(CheckoutInitial());

  void calculateSettlement({
    required double deposit,
    required double finalCharges,
    required double damageFees,
  }) {
    final double refundAmount = deposit - (finalCharges + damageFees);
    emit(CheckoutCalculated(
      deposit: deposit,
      finalCharges: finalCharges,
      damageFees: damageFees,
      refundAmount: refundAmount,
    ));
  }

  Future<void> processCheckout(
      {required int roomId,
      required int contractId,
      required DateTime checkoutDate}) async {
    emit(CheckoutLoading());
    try {
      if (_roomRepository == null)
        throw StateError('Thiếu RoomRepository để lưu thanh lý.');
      await _roomRepository!.finishCheckout(
          roomId: roomId, contractId: contractId, checkoutDate: checkoutDate);
      emit(CheckoutSuccess(
          "Đã hoàn tất thanh lý phòng. Phòng hiện đang trống."));
    } catch (e) {
      emit(CheckoutError("Lỗi thanh lý: ${e.toString()}"));
    }
  }
}
