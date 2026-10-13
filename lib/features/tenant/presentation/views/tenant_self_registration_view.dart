import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class TenantSelfRegistrationView extends StatefulWidget {
  final String roomNumber;
  const TenantSelfRegistrationView({super.key, required this.roomNumber});

  @override
  State<TenantSelfRegistrationView> createState() => _TenantSelfRegistrationViewState();
}

class _TenantSelfRegistrationViewState extends State<TenantSelfRegistrationView> {
  bool _isLinkActive = false;
  final String _registrationUrl = "https://lozido.vn/reg/C5067P22961";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Tự nhập thông tin P.${widget.roomNumber}"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Illustration
            const Icon(Icons.contact_mail_rounded, size: 80, color: AppColors.primaryGreen),
            const SizedBox(height: 24),
            
            Text(
              "(Phòng ${widget.roomNumber}) Đã ghi nhận 0/1 thành viên",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              "Bật tính năng này để khách thuê tự nhập thông tin cá nhân và ảnh CCCD. Thông tin sẽ tự động đổ vào hợp đồng.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grayText, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Toggle Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGrayBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Bật/tắt đường dẫn", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_isLinkActive ? "Đường dẫn đang hoạt động" : "Đường dẫn đang bị khóa"),
                value: _isLinkActive,
                activeColor: AppColors.primaryGreen,
                onChanged: (val) => setState(() => _isLinkActive = val),
              ),
            ),
            
            if (!_isLinkActive) ...[
              const SizedBox(height: 32),
              const Text(
                "⚠️ Vui lòng bật liên kết để khách có thể truy cập.",
                style: TextStyle(color: AppColors.alertOrange, fontWeight: FontWeight.bold),
              ),
            ],

            if (_isLinkActive) ...[
              const SizedBox(height: 32),
              _buildLinkBox(),
              const SizedBox(height: 16),
              const Text(
                "💡 Đường dẫn chỉ có giá trị trong 12 giờ kể từ khi bật.",
                style: TextStyle(color: AppColors.alertOrange, fontSize: 12),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logic Share
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text("Chia sẻ đường dẫn", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 40),
            const Text(
              "LOZIDO cam kết bảo mật thông tin cá nhân của khách thuê theo tiêu chuẩn mã hóa AES-256.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.link, color: AppColors.blueCTA),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _registrationUrl,
              style: const TextStyle(color: AppColors.blueCTA, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _registrationUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã sao chép liên kết")),
              );
            },
          ),
        ],
      ),
    );
  }
}
