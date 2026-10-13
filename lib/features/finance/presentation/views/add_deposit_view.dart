import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_text_field.dart';

class AddDepositView extends StatefulWidget {
  final String roomNumber;
  const AddDepositView({super.key, required this.roomNumber});

  @override
  State<AddDepositView> createState() => _AddDepositViewState();
}

class _AddDepositViewState extends State<AddDepositView> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime _moveInDate = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Nhận cọc P.${widget.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Cảnh báo trạng thái
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.mintBg, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryGreen),
                  SizedBox(width: 12),
                  Expanded(child: Text("Sau khi nhận cọc, phòng sẽ chuyển sang trạng thái 'Đã cọc' và tự động ghi vào Sổ quỹ.", style: TextStyle(fontSize: 12, color: AppColors.primaryGreen))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            CustomTextField(
              label: "Số tiền cọc nhận",
              isRequired: true,
              hintText: "VD: 1.000.000",
              keyboardType: TextInputType.number,
              controller: _amountController,
              suffixWidget: const Text("VNĐ", style: TextStyle(color: Colors.grey)),
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
            
            const CustomTextField(
              label: "Số điện thoại",
              isRequired: true,
              hintText: "Nhập SĐT khách",
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _showSuccessDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Xác nhận nhận cọc", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ngày dự kiến vào ở *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(context: context, initialDate: _moveInDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (date != null) setState(() => _moveInDate = date);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppFormatters.formatDate(_moveInDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                const Icon(Icons.calendar_month_rounded, color: AppColors.primaryGreen, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 60),
            const SizedBox(height: 16),
            const Text("Nhận cọc thành công!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text("Tài khoản App khách của ${_nameController.text} đã được tạo tự động.", textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const Divider(height: 32),
            _buildAccountInfo("Tài khoản:", "0901234567"),
            _buildAccountInfo("Mật khẩu:", "123456"),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng"))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueCTA), child: const Text("Chia sẻ", style: TextStyle(color: Colors.white)))),
              ],
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
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blueCTA)),
        ],
      ),
    );
  }
}
