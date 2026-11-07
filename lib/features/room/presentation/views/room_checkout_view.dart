import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/core/utils/formatters.dart';
import 'package:nhatro_management/features/invoice/presentation/cubit/checkout_cubit.dart';
import 'package:nhatro_management/features/invoice/presentation/cubit/checkout_state.dart';
import 'package:nhatro_management/features/room/data/repositories/room_repository.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_bloc.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_event.dart';

class RoomCheckoutView extends StatefulWidget {
  final int roomId;
  final int contractId;
  final int propertyId;
  final String roomNumber;
  final double? deposit;
  final double? roomPrice;

  const RoomCheckoutView({
    super.key,
    required this.roomId,
    required this.contractId,
    required this.propertyId,
    required this.roomNumber,
    this.deposit,
    this.roomPrice,
  });

  @override
  State<RoomCheckoutView> createState() => _RoomCheckoutViewState();
}

class _RoomCheckoutViewState extends State<RoomCheckoutView> {
  DateTime _checkoutDate = DateTime.now();
  bool _isAssetChecked = false;
  bool _isFinalInvoiceCreated = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckoutCubit(context.read<RoomRepository>()),
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBg,
        appBar: AppBar(
          title: Text("Thanh lý P.${widget.roomNumber}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: BlocConsumer<CheckoutCubit, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutSuccess) {
              _showSuccessDialog(context, state.message);
            } else if (state is CheckoutError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.dangerRed));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckoutDateSection(context),
                  const SizedBox(height: 24),
                  _buildChecklistSection(context),
                  const SizedBox(height: 24),
                  if (_isFinalInvoiceCreated) _buildSettlementSection(state),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildCheckoutDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ngày khách rời đi *",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
                context: context,
                initialDate: _checkoutDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)));
            if (date != null) setState(() => _checkoutDate = date);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppFormatters.formatDate(_checkoutDate),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primaryGreen, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistSection(BuildContext context) {
    int completed =
        (_isAssetChecked ? 1 : 0) + (_isFinalInvoiceCreated ? 1 : 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("VIỆC CẦN LÀM TRƯỚC KHI KẾT THÚC",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.grayText)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4)),
              child: Text("$completed/2 việc",
                  style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _checklistTile(
          title: "Lập hóa đơn tháng cuối",
          subtitle: "Chốt chỉ số điện, nước & cấn trừ cọc",
          isDone: _isFinalInvoiceCreated,
          onTap: () {
            setState(() => _isFinalInvoiceCreated = true);
            // Quyết toán tiền cọc và chi phí phát sinh
            context.read<CheckoutCubit>().calculateSettlement(
                  deposit: widget.deposit ?? 3000000,
                  finalCharges: widget.roomPrice != null
                      ? (widget.roomPrice! * 0.1)
                      : 183800,
                  damageFees: 0,
                );
          },
        ),
        const SizedBox(height: 12),
        _checklistTile(
          title: "Kiểm tra tài sản",
          subtitle: "Xác nhận hiện trạng nội thất thiết bị",
          isDone: _isAssetChecked,
          onTap: () => setState(() => _isAssetChecked = !_isAssetChecked),
        ),
      ],
    );
  }

  Widget _checklistTile(
      {required String title,
      required String subtitle,
      required bool isDone,
      required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
            left: BorderSide(
                color: isDone ? AppColors.primaryGreen : Colors.orange,
                width: 4)),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Icon(
          isDone
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isDone ? AppColors.primaryGreen : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettlementSection(CheckoutState state) {
    if (state is! CheckoutCalculated) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.mintBg,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2))),
      child: Column(
        children: [
          _settlementRow(
              "Tiền cọc đang giữ", AppFormatters.formatCurrency(state.deposit)),
          _settlementRow("Tiền dịch vụ tháng cuối",
              "- ${AppFormatters.formatCurrency(state.finalCharges)}"),
          const Divider(),
          _settlementRow(
            state.refundAmount >= 0
                ? "Số tiền hoàn trả khách"
                : "Số tiền khách cần đóng thêm",
            AppFormatters.formatCurrency(state.refundAmount.abs()),
            isTotal: true,
            color: state.refundAmount >= 0
                ? AppColors.primaryGreen
                : AppColors.dangerRed,
          ),
        ],
      ),
    );
  }

  Widget _settlementRow(String label, String value,
      {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 14 : 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTotal ? 16 : 14,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Đóng",
                      style: TextStyle(color: Colors.black87)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isAssetChecked && _isFinalInvoiceCreated)
                      ? () => context.read<CheckoutCubit>().processCheckout(
                          roomId: widget.roomId,
                          contractId: widget.contractId,
                          checkoutDate: _checkoutDate)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text("Kết thúc hợp đồng",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.primaryGreen, size: 70),
            const SizedBox(height: 16),
            const Text("Thao tác thành công!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<RoomBloc>()
                      .add(FetchDashboardData(widget.propertyId));
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGrayBg, elevation: 0),
                child: const Text("Đóng",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
