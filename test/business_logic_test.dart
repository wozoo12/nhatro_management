import 'package:flutter_test/flutter_test.dart';
import 'package:nhatro_management/core/utils/formatters.dart';
import 'package:nhatro_management/features/invoice/presentation/cubit/checkout_cubit.dart';
import 'package:nhatro_management/features/invoice/presentation/cubit/checkout_state.dart';
import 'package:nhatro_management/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:nhatro_management/features/finance/presentation/cubit/finance_state.dart';
import 'package:nhatro_management/features/property_wizard/presentation/cubit/property_wizard_cubit.dart';

void main() {
  group('AppFormatters Tests', () {
    test('Định dạng tiền tệ VNĐ chuẩn xác', () {
      final formatted = AppFormatters.formatCurrency(2500000);
      expect(formatted, contains('2.500.000'));
    });

    test('Định dạng số điện thoại 10 số có dấu cách ngăn cách dễ đọc', () {
      expect(AppFormatters.formatPhone('0901234567'), equals('0901 234 567'));
      expect(AppFormatters.formatPhone('123'), equals('123'));
    });

    test('Định dạng ngày tháng dd/MM/yyyy chuẩn', () {
      final date = DateTime(2026, 9, 28);
      expect(AppFormatters.formatDate(date), equals('28/09/2026'));
    });
  });

  group('CheckoutCubit Tests (Nghiệp vụ Trả phòng & Cấn trừ cọc)', () {
    late CheckoutCubit cubit;

    setUp(() {
      cubit = CheckoutCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('Tính toán hoàn tiền cọc cho khách khi cọc > chi phí phát sinh', () {
      cubit.calculateSettlement(
        deposit: 2000000,
        finalCharges: 350000,
        damageFees: 150000,
      );

      expect(cubit.state, isA<CheckoutCalculated>());
      final state = cubit.state as CheckoutCalculated;
      expect(state.refundAmount, equals(1500000)); // 2.000.000 - 500.000 = 1.500.000 (Hoàn trả)
    });

    test('Tính toán số tiền khách cần bù thêm khi chi phí vượt quá tiền cọc', () {
      cubit.calculateSettlement(
        deposit: 1000000,
        finalCharges: 800000,
        damageFees: 500000,
      );

      final state = cubit.state as CheckoutCalculated;
      expect(state.refundAmount, equals(-300000)); // Cần thu thêm 300.000
    });
  });

  group('PropertyWizardCubit Tests (Validation Form Thiết lập Nhà trọ)', () {
    late PropertyWizardCubit cubit;

    setUp(() {
      cubit = PropertyWizardCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('Báo lỗi khi tên nhà trọ để trống', () {
      cubit.updatePropertyName('');
      final isValid = cubit.validateStep1();

      expect(isValid, isFalse);
      expect(cubit.state.propertyNameError, isNotNull);
    });

    test('Báo lỗi khi số lượng phòng nhỏ hơn hoặc bằng 0', () {
      cubit.updatePropertyName('Nhà trọ Bình An');
      cubit.toggleAutoCreate(true);
      cubit.updateRoomCount(0);
      final isValid = cubit.validateStep1();

      expect(isValid, isFalse);
      expect(cubit.state.roomCountError, isNotNull);
    });

    test('Báo lỗi khi diện tích nhỏ hơn hoặc bằng 0', () {
      cubit.updatePropertyName('Nhà trọ Bình An');
      cubit.toggleAutoCreate(true);
      cubit.updateRoomCount(10);
      cubit.updateArea(-5);
      final isValid = cubit.validateStep1();

      expect(isValid, isFalse);
      expect(cubit.state.areaError, isNotNull);
    });

    test('Hợp lệ khi điền đầy đủ dữ liệu hợp lệ', () {
      cubit.updatePropertyName('Nhà trọ Bình An');
      cubit.toggleAutoCreate(true);
      cubit.updateRoomCount(8);
      cubit.updateArea(25);
      final isValid = cubit.validateStep1();

      expect(isValid, isTrue);
      expect(cubit.state.propertyNameError, isNull);
      expect(cubit.state.roomCountError, isNull);
      expect(cubit.state.areaError, isNull);
    });
  });

  group('FinanceCubit Tests (Nghiệp vụ Cọc giữ chỗ & Hủy cọc)', () {
    late FinanceCubit cubit;

    setUp(() {
      cubit = FinanceCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('Nhận cọc thành công chuyển state sang FinanceActionSuccess và ghi sổ quỹ', () async {
      await cubit.acceptDeposit(
        roomId: '101',
        tenantName: 'Nguyễn Văn A',
        phone: '0909123456',
        amount: 500000,
        moveInDate: DateTime.now().add(const Duration(days: 7)),
      );

      expect(cubit.state, isA<FinanceActionSuccess>());
      final state = cubit.state as FinanceActionSuccess;
      expect(state.message, contains('101'));
      expect(state.fundRecord?.amount, equals(500000));
    });

    test('Hủy cọc giữ chỗ thành công', () async {
      await cubit.cancelDeposit(
        roomId: '101',
        refundAmount: 200000,
      );

      expect(cubit.state, isA<FinanceActionSuccess>());
      final state = cubit.state as FinanceActionSuccess;
      expect(state.message, contains('Đã hủy cọc P.101'));
    });
  });
}
