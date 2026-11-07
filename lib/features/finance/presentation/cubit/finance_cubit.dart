import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/fund_record_model.dart';
import 'finance_state.dart';
import '../../../room/data/repositories/room_repository.dart';

class FinanceCubit extends Cubit<FinanceState> {
  final RoomRepository? _roomRepository;
  FinanceCubit([this._roomRepository]) : super(FinanceInitial());

  // 1. NGHIỆP VỤ NHẬN CỌC GIỮ CHỖ
  Future<void> acceptDeposit({
    required String roomId,
    int roomDatabaseId = 0,
    required String tenantName,
    required String phone,
    required double amount,
    required DateTime moveInDate,
  }) async {
    emit(FinanceLoading());
    try {
      if (_roomRepository != null) {
        await _roomRepository!.createReservation(
            roomId: roomDatabaseId,
            tenantName: tenantName,
            phone: phone,
            amount: amount,
            moveInDate: moveInDate);
      }
      final newRecord = FundRecordModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Thu tiền cọc giữ chỗ P.$roomId",
        amount: amount,
        type: FundType.thu,
        date: DateTime.now(),
        category: "Cọc giữ chỗ",
        roomId: roomId,
        tenantName: tenantName,
      );

      emit(FinanceActionSuccess(
        message: "Đã nhận và lưu khoản cọc P.$roomId: +$amountđ",
        fundRecord: newRecord,
      ));
    } catch (e) {
      emit(FinanceError("Lỗi nhận cọc: ${e.toString()}"));
    }
  }

  // 2. NGHIỆP VỤ HỦY CỌC (BỎ CỌC)
  Future<void> cancelDeposit({
    required String roomId,
    required double refundAmount,
  }) async {
    emit(FinanceLoading());
    try {
      // Hủy reservation qua luồng quản lý tương ứng.
      // Logic: 2. Nếu có hoàn tiền (> 0) -> Sinh bản ghi Sổ quỹ (Chi hoàn cọc)
      FundRecordModel? refundRecord;
      if (refundAmount > 0) {
        refundRecord = FundRecordModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: "Chi hoàn trả cọc giữ chỗ P.$roomId",
          amount: refundAmount,
          type: FundType.chi,
          date: DateTime.now(),
          category: "Hoàn cọc",
          roomId: roomId,
        );
        // Lưu record vào DB...
      }

      emit(FinanceActionSuccess(
        message: "Đã hủy cọc P.$roomId. Phòng hiện đang trống.",
        fundRecord: refundRecord,
      ));
    } catch (e) {
      emit(FinanceError("Lỗi hủy cọc: ${e.toString()}"));
    }
  }
}
