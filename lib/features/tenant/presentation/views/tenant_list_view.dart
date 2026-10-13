import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tenant_bloc.dart';
import '../bloc/tenant_event.dart';
import '../bloc/tenant_state.dart';
import '../../data/models/tenant_model.dart';
import 'add_tenant_view.dart';
import 'tenant_detail_view.dart'; // Import màn hình chi tiết

/// [TenantListView] hiển thị danh sách toàn bộ khách thuê trong hệ thống.
/// Hỗ trợ tìm kiếm theo tên/số điện thoại và điều hướng thêm khách mới.
class TenantListView extends StatefulWidget {
  const TenantListView({super.key});

  @override
  State<TenantListView> createState() => _TenantListViewState();
}

class _TenantListViewState extends State<TenantListView> {
  // Bộ điều khiển ô nhập tìm kiếm
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Định nghĩa màu sắc đồng bộ với hệ thống
  static const Color primaryBlue = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    // Bước 1: Yêu cầu BLoC tải danh sách khách thuê từ Database ngay khi mở màn hình
    context.read<TenantBloc>().add(FetchTenants());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Quản lý Khách thuê', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- THANH TÌM KIẾM ---
          _buildSearchBox(),
          
          // --- DANH SÁCH (Sử dụng BlocBuilder để cập nhật UI theo dữ liệu thật) ---
          Expanded(
            child: BlocBuilder<TenantBloc, TenantState>(
              builder: (context, state) {
                // Hiển thị vòng xoay nếu đang tải
                if (state is TenantLoading) {
                  return const Center(child: CircularProgressIndicator(color: primaryBlue));
                }

                // Hiển thị lỗi nếu có sự cố
                if (state is TenantError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Lỗi: ${state.message}'),
                        TextButton(
                          onPressed: () => context.read<TenantBloc>().add(FetchTenants()),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                // Khi dữ liệu đã được tải về thành công
                if (state is TenantLoaded) {
                  // Logic lọc danh sách theo tên hoặc số điện thoại Sang nhập
                  final filtered = state.tenants.where((t) {
                    final query = _searchQuery.toLowerCase();
                    return t.fullName.toLowerCase().contains(query) || 
                           t.phone.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu khách thuê.'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context.read<TenantBloc>().add(FetchTenants()),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final tenant = filtered[index];
                        return _buildTenantCard(tenant);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      // Nút nổi để mở màn hình Thêm khách thuê mới
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTenantView()),
          );
        },
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('Thêm khách', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// Ô nhập tìm kiếm nhanh
  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Tìm khách thuê, số điện thoại...',
          prefixIcon: const Icon(Icons.search, color: mutedText),
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  /// Thẻ Card hiển thị thông tin từng khách thuê
  Widget _buildTenantCard(TenantModel tenant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: primaryBlue.withValues(alpha: 0.1),
          child: const Icon(Icons.person_rounded, color: primaryBlue, size: 28),
        ),
        title: Text(tenant.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_iphone_rounded, size: 14, color: mutedText),
                const SizedBox(width: 4),
                Text(tenant.phone, style: const TextStyle(color: mutedText, fontSize: 13)),
              ],
            ),
            if (tenant.identityCard != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('CCCD: ${tenant.identityCard}', style: const TextStyle(color: mutedText, fontSize: 12)),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFCBD5E1)),
        onTap: () {
          // ĐIỀU HƯỚNG SANG CHI TIẾT KHÁCH THUÊ
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TenantDetailView(tenant: tenant),
            ),
          );
        },
      ),
    );
  }
}
