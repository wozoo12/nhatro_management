import 'package:flutter/material.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/core/widgets/custom_text_field.dart';
import 'package:nhatro_management/core/utils/formatters.dart';
import 'package:nhatro_management/features/tenant_finding/data/models/lead_model.dart';

class AddLeadBottomSheet extends StatefulWidget {
  final Function(LeadModel) onLeadAdded;

  const AddLeadBottomSheet({super.key, required this.onLeadAdded});

  @override
  State<AddLeadBottomSheet> createState() => _AddLeadBottomSheetState();
}

class _AddLeadBottomSheetState extends State<AddLeadBottomSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roomController = TextEditingController();
  final _budgetController = TextEditingController();
  final _noteController = TextEditingController();

  LeadStatus _status = LeadStatus.interested;
  DateTime? _appointmentDate;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _roomController.dispose();
    _budgetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập họ tên và số điện thoại!')),
      );
      return;
    }

    final double? budget =
        double.tryParse(_budgetController.text.replaceAll('.', '').trim());

    final newLead = LeadModel(
      id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      preferredRoom: _roomController.text.trim().isEmpty
          ? null
          : _roomController.text.trim(),
      budget: budget,
      status: _status,
      appointmentDate: _appointmentDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    widget.onLeadAdded(newLead);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thêm khách thuê tiềm năng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Họ và tên khách *',
              hintText: 'VD: Nguyễn Văn Nam',
              isRequired: true,
              controller: _nameController,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Số điện thoại *',
              hintText: 'VD: 0901234567',
              isRequired: true,
              keyboardType: TextInputType.phone,
              controller: _phoneController,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Phòng quan tâm',
                    hintText: 'VD: 102',
                    controller: _roomController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Ngân sách (VNĐ)',
                    hintText: 'VD: 3000000',
                    isCurrency: true,
                    keyboardType: TextInputType.number,
                    controller: _budgetController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Trạng thái khách *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: LeadStatus.values.map((status) {
                final isSelected = _status == status;
                return ChoiceChip(
                  label: Text(status.name == 'interested'
                      ? 'Quan tâm'
                      : status.name == 'viewingScheduled'
                          ? 'Hẹn xem'
                          : status.name == 'deposited'
                              ? 'Đã cọc'
                              : 'Đã hủy'),
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _status = status);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            const Text('Lịch hẹn xem phòng (nếu có)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (date != null) {
                  setState(() => _appointmentDate = date);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _appointmentDate != null
                          ? AppFormatters.formatDate(_appointmentDate!)
                          : 'Chưa đặt lịch hẹn',
                      style: TextStyle(
                        fontWeight: _appointmentDate != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _appointmentDate != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.event_available_rounded,
                        size: 20, color: AppColors.primaryGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Ghi chú nhu cầu',
              hintText: 'VD: Cần dọn vào trước ngày 15, có nuôi thú cưng...',
              controller: _noteController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lưu thông tin khách',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
