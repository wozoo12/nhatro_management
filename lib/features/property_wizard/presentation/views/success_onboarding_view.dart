import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/views/main_dashboard_view.dart';

class SuccessOnboardingView extends StatelessWidget {
  const SuccessOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            const Text(
              "Chúc mừng Sang!",
              style: TextStyle(fontSize: 18, color: AppColors.grayText),
            ),
            const Text(
              "Tạo nhà cho thuê thành công!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 24),

            // THÊM: Thẻ thông tin kết nối App khách thuê (Theo Spec)
            _buildCredentialsCard(context),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrayBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Các nghiệp vụ cốt lõi bạn nên biết:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildTutorialItem(1, "Thiết lập dịch vụ", "Chỉnh sửa đơn giá điện nước", Icons.settings_suggest_rounded),
                          _buildTutorialItem(2, "Tạo mới hợp đồng", "Ghi nhận khách thuê mới vào ở", Icons.assignment_turned_in_rounded),
                          _buildTutorialItem(3, "Lập hóa đơn", "Lập phiếu thu tiền hàng tháng", Icons.receipt_long_rounded),
                          _buildTutorialItem(4, "Thu tiền hóa đơn", "Xác nhận khách đã đóng tiền", Icons.payments_rounded),
                          _buildTutorialItem(5, "Kết thúc hợp đồng", "Thanh lý phòng & trả cọc", Icons.exit_to_app_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_circle_fill, color: AppColors.dangerRed),
                      label: const Text("Hướng dẫn", style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.dangerRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainDashboardView()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
                      label: const Text("Bắt đầu quản lý", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueCTA.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueCTA.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.phonelink_setup_rounded, color: AppColors.blueCTA, size: 20),
              SizedBox(width: 8),
              Text("Thông tin kết nối App khách thuê", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blueCTA)),
            ],
          ),
          const SizedBox(height: 12),
          _buildCredRow("Tên đăng nhập:", "SĐT của khách thuê"),
          _buildCredRow("Mật khẩu mặc định:", "123456"),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: "Tải App LOZIDO Khách Thuê và đăng nhập bằng SĐT của bạn, mật khẩu mặc định là 123456"));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã sao chép thông tin gửi khách")));
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text("Sao chép thông tin gửi khách", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueCTA, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTutorialItem(int step, String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.mintBg, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$step. $title", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.play_circle_outline, color: AppColors.blueCTA, size: 20),
        ],
      ),
    );
  }
}
