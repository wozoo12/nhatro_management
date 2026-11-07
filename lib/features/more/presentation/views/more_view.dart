import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/features/finance/presentation/views/finance_view.dart';
import 'package:nhatro_management/features/onboarding/presentation/views/welcome_view.dart';
import 'package:nhatro_management/features/room/data/models/property_model.dart';
import 'package:nhatro_management/features/room/presentation/views/asset_management_view.dart';
import 'package:nhatro_management/features/room/presentation/views/issue_management_view.dart';
import 'package:nhatro_management/features/settings/presentation/views/settings_view.dart';

class MoreView extends StatefulWidget {
  final PropertyModel? property;

  const MoreView({super.key, this.property});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  bool _darkMode = false;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    final effectiveProperty = widget.property ?? PropertyModel(
      id: 1,
      name: 'Nhà trọ Lozido',
      address: 'TP. Hồ Chí Minh',
      createdAt: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        title: const Text('Tiện ích & Cài đặt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 20),

          _buildSectionHeader('QUẢN LÝ & VẬN HÀNH'),
          _buildMenuTile(
            icon: Icons.account_balance_rounded,
            iconColor: AppColors.blueCTA,
            title: 'Tài khoản ngân hàng & VietQR',
            subtitle: 'Cấu hình STK nhận tiền chuyển khoản tự động',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsView())),
          ),
          _buildMenuTile(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: Colors.purple,
            title: 'Sổ quỹ & Thu chi thực tế',
            subtitle: 'Quản lý dòng tiền vào ra và lợi nhuận',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceView())),
          ),
          _buildMenuTile(
            icon: Icons.inventory_2_rounded,
            iconColor: Colors.brown,
            title: 'Quản lý tài sản phòng',
            subtitle: 'Kiểm kê máy lạnh, giường tủ, chìa khóa',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetManagementView(property: effectiveProperty))),
          ),
          _buildMenuTile(
            icon: Icons.build_circle_rounded,
            iconColor: AppColors.dangerRed,
            title: 'Quản lý sự cố & Sửa chữa',
            subtitle: 'Theo dõi tiến độ khắc phục hư hỏng',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IssueManagementView())),
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('TIỆN ÍCH NGOẠI VI & THIẾT BỊ'),
          _buildMenuTile(
            icon: Icons.print_rounded,
            iconColor: Colors.teal,
            title: 'Máy in nhiệt Bluetooth (58mm)',
            subtitle: 'Kết nối máy in mini để in hóa đơn tức thì',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng in nhiệt Bluetooth đã sẵn sàng trong chi tiết Hóa đơn!')),
              );
            },
          ),
          _buildMenuTile(
            icon: Icons.chat_rounded,
            iconColor: Colors.blue,
            title: 'Thông báo Zalo tự động',
            subtitle: 'Gửi hóa đơn và thông báo nhắc nợ qua Zalo',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hệ thống Zalo Service đã được kích hoạt mặc định!')),
              );
            },
          ),
          _buildMenuTile(
            icon: Icons.description_rounded,
            iconColor: Colors.indigo,
            title: 'Mẫu hợp đồng & Nội quy trọ',
            subtitle: 'Xem các điều khoản thuê phòng tiêu chuẩn',
            onTap: () {
              _showContractTemplateDialog(context);
            },
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('HỆ THỐNG & TÀI KHOẢN'),
          _buildSwitchTile(
            icon: Icons.dark_mode_rounded,
            iconColor: Colors.deepPurple,
            title: 'Chế độ ban đêm (Dark Mode)',
            value: _darkMode,
            onChanged: (val) {
              setState(() => _darkMode = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(val ? 'Đã kích hoạt Dark Mode' : 'Đã chuyển sang Light Mode')),
              );
            },
          ),
          _buildSwitchTile(
            icon: Icons.fingerprint_rounded,
            iconColor: AppColors.primaryGreen,
            title: 'Bảo mật sinh trắc học',
            value: _biometricEnabled,
            onChanged: (val) {
              setState(() => _biometricEnabled = val);
            },
          ),
          _buildMenuTile(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.grey.shade700,
            title: 'Thông tin ứng dụng',
            subtitle: 'LOZIDO v2.0.1 • Bản quyền © quanlytro.me',
            onTap: () => _showAboutDialog(context),
          ),
          _buildMenuTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.dangerRed,
            title: 'Đăng xuất tài khoản',
            subtitle: 'Thoát khỏi phiên làm việc hiện tại',
            textColor: AppColors.dangerRed,
            onTap: () => _showLogoutDialog(context),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryGreen,
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nguyễn Hoàng Sang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navyText),
                ),
                const SizedBox(height: 2),
                const Text(
                  '0909 123 456',
                  style: TextStyle(fontSize: 13, color: AppColors.grayText),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Chủ trọ Pro',
                    style: TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor ?? AppColors.navyText,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.grayText))
            : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        secondary: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navyText),
        ),
        value: value,
        activeColor: AppColors.primaryGreen,
        onChanged: onChanged,
      ),
    );
  }

  void _showContractTemplateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nội quy phòng trọ tiêu chuẩn', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            '1. Giữ gìn an ninh trật tự, không tụ tập gây ồn ào sau 23:00.\n'
            '2. Khóa cổng cẩn thận khi ra vào nhà trọ.\n'
            '3. Tiết kiệm điện nước, tắt các thiết bị khi không có người trong phòng.\n'
            '4. Thanh toán tiền trọ đúng hạn từ ngày 01 đến ngày 05 hàng tháng.\n'
            '5. Báo trước ít nhất 30 ngày trước khi kết thúc hợp đồng trả phòng.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ứng dụng LOZIDO', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'LOZIDO - Giải pháp toàn diện cho Chủ nhà quản lý phòng trọ, căn hộ dịch vụ.\n\n'
          'Phiên bản: 2.0.1 (Super App V2)\n'
          'Bản quyền © 2026 quanlytro.me',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã hiểu', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (_) {}
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeView()),
                (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
