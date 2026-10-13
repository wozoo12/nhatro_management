import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhatro_management/features/invoice/presentation/cubit/checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

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

  Future<void> processCheckout(String roomId) async {
    emit(CheckoutLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(CheckoutSuccess("Đã hoàn tất thanh lý phòng. Phòng hiện đang trống."));
    } catch (e) {
      emit(CheckoutError("Lỗi thanh lý: ${e.toString()}"));
    }
  }
}
