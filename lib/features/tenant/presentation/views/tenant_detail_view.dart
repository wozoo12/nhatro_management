import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/tenant_model.dart';

/// [TenantDetailView] hiển thị chi tiết hồ sơ của một khách thuê.
/// Đặc biệt cho phép xem lại ảnh CCCD mặt trước/sau đã lưu trên hệ thống.
class TenantDetailView extends StatelessWidget {
  final TenantModel tenant;

  const TenantDetailView({super.key, required this.tenant});

  // --- HỆ THỐNG MÀU SẮC ---
  static const Color primaryBlue = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF64748B);

  /// Hàm hiển thị ảnh toàn màn hình khi người dùng nhấn vào ảnh CCCD
  void _viewFullScreenImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer( // Cho phép zoom ảnh bằng tay
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ khách thuê', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () {
              // Logic chỉnh sửa khách thuê sẽ cập nhật sau
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(), // Phần 1: Avatar và thông tin chính
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionButtons(context), // Phần 2: Nút Gọi/Zalo
                  const SizedBox(height: 24),
                  _buildInfoCard(), // Phần 3: Thẻ thông tin định danh
                  const SizedBox(height: 24),
                  _buildImageSection(context), // Phần 4: Khu vực ảnh CCCD
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PHẦN 1: Header hồ sơ
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: primaryBlue.withValues(alpha: 0.1),
            child: const Icon(Icons.person_rounded, size: 60, color: primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(tenant.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tenant.phone, style: const TextStyle(fontSize: 16, color: mutedText)),
        ],
      ),
    );
  }

  /// PHẦN 2: Hàng nút hành động liên lạc nhanh
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAction(
            icon: Icons.phone_in_talk_rounded,
            label: 'Gọi điện',
            color: Colors.green,
            onTap: () {
              // TODO: Tích hợp url_launcher để thực hiện cuộc gọi thật
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickAction(
            icon: Icons.chat_bubble_rounded,
            label: 'Zalo',
            color: Colors.blue,
            onTap: () {
              // TODO: Mở link Zalo chat
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// PHẦN 3: Thẻ chứa thông tin CCCD
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THÔNG TIN ĐỊNH DANH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedText)),
          const SizedBox(height: 16),
          _buildInfoRow('Số CCCD/CMND', tenant.identityCard ?? 'Chưa cập nhật'),
          const Divider(height: 24),
          _buildInfoRow('Ngày tham gia', DateFormat('dd/MM/yyyy').format(tenant.createdAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: mutedText)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  /// PHẦN 4: Khu vực hiển thị ảnh CCCD (Dữ liệu từ Supabase Storage)
  Widget _buildImageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('HÌNH ẢNH HỒ SƠ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedText)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildCCCDImage(context, 'Mặt trước', tenant.frontCardUrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildCCCDImage(context, 'Mặt sau', tenant.backCardUrl)),
          ],
        ),
      ],
    );
  }

  Widget _buildCCCDImage(BuildContext context, String label, String? imageUrl) {
    return Column(
      children: [
        GestureDetector(
          onTap: imageUrl != null ? () => _viewFullScreenImage(context, imageUrl, label) : null,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined, color: Colors.red),
                    ),
                  )
                : const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: mutedText)),
      ],
    );
  }
}
