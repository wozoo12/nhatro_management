import 'package:flutter/material.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _enableNotifications = true;
  bool _autoRemindInvoice = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt & Zalo', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('TÀI KHOẢN & NGÂN HÀNG'),
          _buildSettingCard(
            children: [
              _buildListTile(Icons.person_outline, 'Thông tin cá nhân', 'Nguyễn Hoàng Sang', onTap: () {}),
              const Divider(height: 1, indent: 56),
              _buildListTile(Icons.account_balance_outlined, 'Tài khoản nhận tiền (VietQR)', 'MB Bank - 0987654321', onTap: () {}),
            ],
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('TÍCH HỢP ZALO & THÔNG BÁO'),
          _buildSettingCard(
            children: [
              _buildListTile(Icons.chat_bubble_outline, 'Mẫu tin nhắn nhắc nợ', 'Xin chào! Gửi bạn hóa đơn...', onTap: () {}),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                title: const Text('Gửi thông báo đẩy (Push)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: const Text('Nhận thông báo khi khách thanh toán', style: TextStyle(color: Colors.grey, fontSize: 12)),
                secondary: const Icon(Icons.notifications_active_outlined, color: Colors.blueGrey),
                activeColor: AppColors.primaryGreen,
                value: _enableNotifications,
                onChanged: (val) => setState(() => _enableNotifications = val),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                title: const Text('Tự động nhắc hóa đơn', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: const Text('Gửi thông báo trước hạn 2 ngày', style: TextStyle(color: Colors.grey, fontSize: 12)),
                secondary: const Icon(Icons.auto_mode_outlined, color: Colors.blueGrey),
                activeColor: AppColors.primaryGreen,
                value: _autoRemindInvoice,
                onChanged: (val) => setState(() => _autoRemindInvoice = val),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('BẢO MẬT & HỆ THỐNG'),
          _buildSettingCard(
            children: [
              _buildListTile(Icons.lock_outline, 'Đổi mật khẩu', '', onTap: () {}),
              const Divider(height: 1, indent: 56),
              _buildListTile(Icons.fingerprint, 'Đăng nhập bằng sinh trắc học', 'Đã bật', onTap: () {}),
              const Divider(height: 1, indent: 56),
              _buildListTile(Icons.info_outline, 'Phiên bản ứng dụng', 'v1.0.0 (Build 24)', onTap: () {}),
            ],
          ),

          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: AppColors.dangerRed,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.dangerRed.withValues(alpha: 0.3))),
            ),
            child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildSettingCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
