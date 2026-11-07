import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nhatro_management/core/utils/zalo_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../cubit/finance_cubit.dart';
import '../cubit/finance_state.dart';
import '../../../room/data/repositories/room_repository.dart';

class AddDepositView extends StatefulWidget {
  final String roomNumber;
  final int roomId;
  const AddDepositView(
      {super.key, required this.roomNumber, required this.roomId});

  @override
  State<AddDepositView> createState() => _AddDepositViewState();
}

class _AddDepositViewState extends State<AddDepositView> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime _moveInDate = DateTime.now().add(const Duration(days: 7));
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập số tiền cọc hợp lệ!'),
            backgroundColor: AppColors.dangerRed),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập họ tên người cọc!'),
            backgroundColor: AppColors.dangerRed),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập số điện thoại người cọc!'),
            backgroundColor: AppColors.dangerRed),
      );
      return;
    }

    context.read<FinanceCubit>().acceptDeposit(
          roomId: widget.roomNumber,
          roomDatabaseId: widget.roomId,
          tenantName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          amount: amount,
          moveInDate: _moveInDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinanceCubit(context.read<RoomRepository>()),
      child: BlocConsumer<FinanceCubit, FinanceState>(
        listener: (context, state) {
          if (state is FinanceActionSuccess) {
            _showSuccessDialog(context, state);
          } else if (state is FinanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.dangerRed),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text("Nhận cọc P.${widget.roomNumber}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Cảnh báo trạng thái
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.mintBg,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.primaryGreen),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Sau khi nhận cọc, phòng chuyển sang trạng thái 'Đã cọc' màu xanh dương.",
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.primaryGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: "Số tiền cọc nhận",
                      isRequired: true,
                      hintText: "VD: 1.000.000",
                      isCurrency: true,
                      keyboardType: TextInputType.number,
                      controller: _amountController,
                      suffixWidget: const Text("VNĐ",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 16),

                    _buildDatePicker(context),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: "Họ tên người cọc",
                      isRequired: true,
                      hintText: "Nhập tên khách",
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: "Số điện thoại",
                      isRequired: true,
                      hintText: "Nhập SĐT khách (VD: 0901234567)",
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state is FinanceLoading
                            ? null
                            : () => _handleSubmit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: state is FinanceLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text("Xác nhận nhận cọc",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ngày dự kiến vào ở *",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _moveInDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) setState(() => _moveInDate = date);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppFormatters.formatDate(_moveInDate),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Icon(Icons.calendar_month_rounded,
                    color: AppColors.primaryGreen, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context, FinanceActionSuccess state) {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText) ?? 0;
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();

    final receiptText = '🏠 BIÊN NHẬN CỌC GIỮ CHỖ - LOZIDO\n'
        '• Phòng: P.${widget.roomNumber}\n'
        '• Khách cọc: $name ($phone)\n'
        '• Số tiền cọc: ${AppFormatters.formatCurrency(amount)}\n'
        '• Ngày dự kiến dọn vào: ${AppFormatters.formatDate(_moveInDate)}\n'
        '• Trạng thái: Đã lưu thông tin cọc thành công!';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.primaryGreen, size: 60),
            const SizedBox(height: 16),
            const Text("Nhận cọc thành công!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              "Đã nhận cọc P.${widget.roomNumber}; trạng thái phòng đã được cập nhật.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Divider(height: 24),
            _buildAccountInfo("Phòng cọc:", "P.${widget.roomNumber}"),
            _buildAccountInfo("Số tiền:", AppFormatters.formatCurrency(amount)),
            _buildAccountInfo("Tài khoản khách:", phone),
            _buildAccountInfo("Mật khẩu mặc định:", "123456"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Share.share(receiptText);
                    },
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label:
                        const Text("Chia sẻ", style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ZaloService.openZaloChat(phone);
                    },
                    icon: const Icon(Icons.chat_bubble_rounded,
                        size: 16, color: Colors.white),
                    label: const Text("Gửi Zalo",
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueCTA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close AddDepositView
                },
                child: const Text("Hoàn tất & Đóng"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyText,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
