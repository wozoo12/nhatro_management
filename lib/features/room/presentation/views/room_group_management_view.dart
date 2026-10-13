import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RoomGroup {
  String id;
  String name;
  RoomGroup(this.id, this.name);
}

class RoomGroupManagementView extends StatefulWidget {
  const RoomGroupManagementView({super.key});

  @override
  State<RoomGroupManagementView> createState() => _RoomGroupManagementViewState();
}

class _RoomGroupManagementViewState extends State<RoomGroupManagementView> {
  final List<RoomGroup> _groups = [
    RoomGroup("1", "Tầng trệt"),
    RoomGroup("2", "Tầng 1"),
    RoomGroup("3", "Tầng 2"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        title: const Text("Quản lý nhóm tầng/khu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Chú ý: Nhấp giữ sau đó kéo thả để sắp xếp thứ tự hiển thị của các tầng/khu.",
                      style: TextStyle(fontSize: 12, color: Colors.brown, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _groups.removeAt(oldIndex);
                  _groups.insert(newIndex, item);
                });
              },
              children: _groups.map((group) => _buildGroupItem(group)).toList(),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditGroupDialog(null),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGroupItem(RoomGroup group) {
    return Container(
      key: ValueKey(group.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ListTile(
        leading: const Icon(Icons.drag_handle_rounded, color: Colors.grey),
        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.blueCTA, size: 20),
          onPressed: () => _showEditGroupDialog(group),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  void _showEditGroupDialog(RoomGroup? group) {
    final controller = TextEditingController(text: group?.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(group == null ? "Thêm nhóm mới" : "Chỉnh sửa nhóm"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Ví dụ: Khu A, Tầng 3..."),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
