import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../property_wizard/presentation/views/property_wizard_view.dart';

class EmptyHomeView extends StatelessWidget {
  const EmptyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Illustration Area
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.white,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_city_rounded, size: 100, color: AppColors.primaryGreen),
                  SizedBox(height: 8),
                  Text("LOZIDO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen, letterSpacing: 2)),
                ],
              ),
            ),

            // 2. Main Guidance Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.mintBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Text("Đầu tiên hãy tạo nhà để quản lý", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 8),
                  const Text("Bạn có thể quản lý không giới hạn số tòa nhà & số phòng/giường/căn hộ.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.grayText)),
                  const SizedBox(height: 20),

                  // 3. Excel Import Card (Flow 2 Spec)
                  _buildExcelCard(context),
                ],
              ),
            ),

            // 4. Section Divider
            _buildManualDivider(),

            // 5. Manual Action Row
            _buildManualActions(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildExcelCard(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Bắt đầu tạo nhà từ file excel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Text("Tạo nhanh hơn từ excel sẵn có của bạn", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 24),
              _buildStepItem(1, "Tải xuống file excel mẫu", "Tải file mẫu từ LOZIDO", Icons.file_download_outlined),
              _buildStepItem(2, "Nhập dữ liệu", "Nhập hoặc copy dữ liệu vào file mẫu", Icons.edit_note_rounded),
              _buildStepItem(3, "Tải lên file đã nhập", "Kiểm tra và tải lên để hoàn thành", Icons.cloud_upload_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDownloadTemplate(context),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text("Tải mẫu", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleUploadFile(context),
                      icon: const Icon(Icons.upload, size: 16, color: Colors.white),
                      label: const Text("Tải lên file", style: TextStyle(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, elevation: 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(top: -15, left: 20, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.table_chart_rounded, color: Colors.white, size: 20))),
      ],
    );
  }

  void _handleDownloadTemplate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang tải xuống tệp tin biểu mẫu LOZIDO_Template.xlsx...")));
  }

  void _handleUploadFile(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryGreen),
            const SizedBox(height: 20),
            const Text("Đang phân tích dữ liệu tệp tin...", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Hệ thống đang khởi tạo phòng tự động", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );

    // Giả lập xử lý xong sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pop(context); // Đóng loading
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Khởi tạo thành công 1 nhà trọ và 20 phòng từ file Excel!"), backgroundColor: AppColors.primaryGreen));
    });
  }

  Widget _buildManualDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [const Text("Hoặc tạo thủ công", style: TextStyle(color: Colors.grey, fontSize: 13)), const SizedBox(width: 4), Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.grey[400])]),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildManualActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_fill, color: AppColors.dangerRed),
              label: const Text("Hướng dẫn", style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.dangerRed), padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertyWizardView())),
              icon: const Icon(Icons.add_home_work_rounded, color: Colors.white),
              label: const Text("Tạo mới nhà", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueCTA, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryGreen,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Dịch vụ"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Thông báo"),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Thêm"),
      ],
    );
  }

  Widget _buildStepItem(int step, String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, size: 20, color: Colors.black87)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Bước $step: $title", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11))])),
        ],
      ),
    );
  }
}
