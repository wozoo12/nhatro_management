import 'package:flutter/material.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/core/widgets/custom_text_field.dart';
import 'package:nhatro_management/core/utils/formatters.dart';
import 'package:nhatro_management/features/tasks/data/models/task_model.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(TaskModel) onTaskAdded;

  const AddTaskBottomSheet({super.key, required this.onTaskAdded});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _roomController = TextEditingController();

  TaskCategory _category = TaskCategory.issue;
  TaskPriority _priority = TaskPriority.normal;
  DateTime _dueDate = DateTime.now().add(const Duration(hours: 4));

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề công việc!')),
      );
      return;
    }

    final newTask = TaskModel(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      category: _category,
      roomNumber: _roomController.text.trim().isEmpty ? null : _roomController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      isCompleted: false,
    );

    widget.onTaskAdded(newTask);
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
                  'Tạo công việc / Lịch hẹn',
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
              label: 'Tiêu đề công việc *',
              hintText: 'VD: Thay bóng đèn hành lang',
              isRequired: true,
              controller: _titleController,
            ),
            const SizedBox(height: 14),
            const Text('Loại công việc *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TaskCategory.values.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text(_getCategoryText(cat)),
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _category = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Số phòng (tùy chọn)',
                    hintText: 'VD: 102',
                    controller: _roomController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mức độ ưu tiên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TaskPriority>(
                        value: _priority,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: TaskPriority.low, child: Text('Thấp')),
                          DropdownMenuItem(value: TaskPriority.normal, child: Text('Bình thường')),
                          DropdownMenuItem(value: TaskPriority.urgent, child: Text('Khẩn cấp', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _priority = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Thời hạn hoàn thành *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _dueDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppFormatters.formatDate(_dueDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Mô tả chi tiết',
              hintText: 'Nhập ghi chú thêm cho công việc này...',
              controller: _descController,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thêm công việc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryText(TaskCategory cat) {
    switch (cat) {
      case TaskCategory.issue:
        return 'Sự cố';
      case TaskCategory.appointment:
        return 'Lịch hẹn';
      case TaskCategory.billing:
        return 'Thu tiền';
      case TaskCategory.personal:
        return 'Cá nhân';
    }
  }
}
