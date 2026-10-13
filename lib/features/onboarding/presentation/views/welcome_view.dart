import 'package:flutter/material.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/features/auth/presentation/views/login_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CustomPaint(
                        size: const Size(double.infinity, 120),
                        painter: WavePainter(),
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildFloatingBadges(),
                        const Spacer(),
                        _buildHeroIllustration(),
                        const Spacer(),
                        _buildWelcomeText(),
                        const SizedBox(height: 32),
                        _buildCTAButton(context),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBadges() {
    final labels = ["Quản lý đa loại hình", "Quản lý không giới hạn", "Tự động hóa", "Đa thiết bị - Linh hoạt"];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: labels.map((l) => _badge(l)).toList(),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mintBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeroIllustration() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            children: [
              const Positioned(top: 0, right: 20, child: Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.apartment_rounded, size: 100, color: Colors.grey.shade200),
                  const Icon(Icons.location_city_rounded, size: 140, color: AppColors.primaryGreen),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -20,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primaryGreen,
              child: Text("A", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      children: [
        Text("Chào mừng đã đến với", style: TextStyle(color: AppColors.grayText, fontSize: 15)),
        SizedBox(height: 4),
        Text("LOZIDO - Chủ nhà!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(height: 8),
        Text("Giải pháp toàn diện để quản lý nhà cho thuê", style: TextStyle(fontSize: 14, color: AppColors.grayText)),
        SizedBox(height: 12),
        Text("Chuyên nghiệp - Tự động hóa - Tiết kiệm - Linh hoạt", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView())),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Bắt đầu quản lý", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text("Phiên bản: 2.0.1 - Copyright @ quanlytro.me", style: TextStyle(color: Colors.white70, fontSize: 11)),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primaryGreen.withOpacity(0.06)..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.5, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.8, size.height * 1.0, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
