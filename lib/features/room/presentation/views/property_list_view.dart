import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/room_bloc.dart';
import '../bloc/room_event.dart';
import '../bloc/room_state.dart';
import '../../data/models/property_model.dart';
import 'dashboard_view.dart';

/// [PropertyListView] là màn hình khởi đầu để chọn khu nhà trọ.
/// Đã được cập nhật giao diện Pixel-Perfect và logic truyền dữ liệu an toàn để Sang Test.
class PropertyListView extends StatefulWidget {
  const PropertyListView({super.key});

  @override
  State<PropertyListView> createState() => _PropertyListViewState();
}

class _PropertyListViewState extends State<PropertyListView> {
  // --- HỆ THỐNG MÀU SẮC CHUẨN ---
  static const Color primaryBlue = Color(0xFF2E7D32);
  // static const Color accentBlue = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color mutedText = Color(0xFF64748B);
  // static const Color alertRed = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    // Tải danh sách khu nhà ngay khi khởi chạy
    context.read<RoomBloc>().add(FetchProperties());
  }

  /// [Dialog Thêm/Sửa]: Thiết kế hiện đại, hỗ trợ truyền dữ liệu an toàn lên Supabase
  void _showPropertyDialog(BuildContext context, {PropertyModel? property}) {
    final nameController = TextEditingController(text: property?.name);
    final addressController = TextEditingController(text: property?.address);
    final formKey = GlobalKey<FormState>();
    final bool isEdit = property != null;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Sửa khu nhà' : 'Thêm khu nhà mới',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkNavy),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên khu nhà *', 
                    hintText: 'VD: Nhà trọ Minh Anh',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (isEdit) {
                              context.read<RoomBloc>().add(UpdateProperty(
                                id: property.id, 
                                name: nameController.text, 
                                address: addressController.text,
                              ));
                            } else {
                              // Lấy userId thực tế. Nếu chưa đăng nhập sẽ trả về null.
                              // Việc truyền null giúp tránh lỗi định dạng UUID trống trên Supabase.
                              final userId = Supabase.instance.client.auth.currentUser?.id;
                              
                              context.read<RoomBloc>().add(AddProperty(
                                name: nameController.text, 
                                address: addressController.text, 
                                userId: userId, // userId có thể là null
                              ));
                            }
                            Navigator.pop(ctx);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue, 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(isEdit ? 'Cập nhật' : 'Lưu'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// [Dialog Xác nhận xóa]
  void _confirmDeleteProperty(BuildContext context, PropertyModel property) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${property.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              context.read<RoomBloc>().add(DeleteProperty(property.id));
              Navigator.pop(ctx);
            }, 
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          List<PropertyModel> properties = [];
          if (state is RoomLoaded) properties = state.properties;

          return Column(
            children: [
              _buildHeader(context), // Header xanh đồng bộ Dashboard
              Expanded(
                child: properties.isEmpty && state is! RoomLoading
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: () async => context.read<RoomBloc>().add(FetchProperties()),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: properties.length,
                          itemBuilder: (context, index) => _buildPropertyCard(context, properties[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPropertyDialog(context),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_rounded),
        label: const Text('Thêm khu nhà', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// [HEADER]: Đồng bộ 100% với DashboardView
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.home_work_rounded, color: primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản Lý Trọ',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Chọn khu nhà để bắt đầu quản lý',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
        ],
      ),
    );
  }

  /// [EMPTY STATE]: Giao diện tinh tế khi chưa có dữ liệu
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFF0F9FF), shape: BoxShape.circle),
            child: const Icon(Icons.home_work_outlined, size: 64, color: primaryBlue),
          ),
          const SizedBox(height: 24),
          const Text('Chưa có khu nhà nào', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkNavy)),
          const SizedBox(height: 8),
          const Text('Vui lòng thêm khu nhà trọ đầu tiên\nđể quản lý phòng và khách thuê.', 
            textAlign: TextAlign.center, style: TextStyle(color: mutedText, fontSize: 14)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showPropertyDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Thêm khu nhà đầu tiên', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// [PROPERTY CARD]: Thẻ khu nhà chuẩn Material 3
  Widget _buildPropertyCard(BuildContext context, PropertyModel property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: primaryBlue.withValues(alpha: 0.1),
          child: const Icon(Icons.apartment_rounded, color: primaryBlue),
        ),
        title: Text(property.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: darkNavy)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(property.address ?? 'Chưa cập nhật địa chỉ', style: const TextStyle(color: mutedText, fontSize: 13)),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _showPropertyDialog(context, property: property);
            if (v == 'delete') _confirmDeleteProperty(context, property);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Sửa')),
            const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
          ],
        ),
        onTap: () {
          // Chuyển sang Dashboard thật của khu nhà đó
          Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardView(property: property)));
        },
      ),
    );
  }
}
