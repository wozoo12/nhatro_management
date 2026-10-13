import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../home/presentation/views/empty_home_view.dart';
import 'forget_password_view.dart';
import 'sign_up_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _otpController = TextEditingController(); // Tận dụng nhập OTP
  
  String? _emailError;
  String? _otpError;

  int _currentStep = 1;

  Future<void> _handleSendOtp() async {
    setState(() {
      _emailError = _emailController.text.trim().isEmpty ? "Email không được để trống" : null;
    });
    if (_emailError != null) return;

    if (_emailController.text.trim() == 'test@lozido.com') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chế độ TEST: Bỏ qua gửi Email thực! Mã OTP là 123456")));
      setState(() => _currentStep = 2);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase_flutter.Supabase.instance.client.auth.signInWithOtp(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã OTP 6 số đã được gửi đến Email của bạn!")));
      setState(() => _currentStep = 2);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi gửi OTP: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _otpError = _otpController.text.trim().isEmpty ? "Vui lòng nhập OTP" : null;
    });

    if (_otpError != null) return;

    setState(() => _isLoading = true);
    
    try {
      if (_emailController.text.trim() == 'test@lozido.com' && _otpController.text.trim() == '123456') {
        // Tạo sẵn một tài khoản test ngầm nếu chưa có
        try {
          await supabase_flutter.Supabase.instance.client.auth.signUp(email: 'test@lozido.com', password: 'TestPassword123!');
        } catch(_) {}
        await supabase_flutter.Supabase.instance.client.auth.signInWithPassword(email: 'test@lozido.com', password: 'TestPassword123!');
        if (!mounted) return;
        _navigateToHome();
        return;
      }

      await supabase_flutter.Supabase.instance.client.auth.verifyOTP(
        email: _emailController.text.trim(),
        token: _otpController.text.trim(),
        type: supabase_flutter.OtpType.magiclink, // Magiclink là loại mặc định khi SignInWithOtp
      );
      if (!mounted) return;
      _navigateToHome();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const EmptyHomeView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Đăng nhập tài khoản", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildBranding(),
                const SizedBox(height: 48),
                CustomTextField(
                  label: "Email cá nhân",
                  isRequired: true,
                  hintText: "Nhập email của bạn (vd: abc@gmail.com)",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                if (_currentStep == 2) ...[
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: "Mã OTP (6 số từ Email)",
                    isRequired: true,
                    hintText: "Nhập mã xác thực",
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    errorText: _otpError,
                  ),
                ],
                const SizedBox(height: 32),
                _buildLoginButton(),
                const SizedBox(height: 24),
                if (_currentStep == 1) ...[
                  _buildSocialLogins(),
                  const SizedBox(height: 32),
                  _buildActionLinks(),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading) Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.mintBg, shape: BoxShape.circle),
          child: const Text("A", style: TextStyle(color: AppColors.primaryGreen, fontSize: 48, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        const Text("LOZIDO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("Quản lý NHÀ CHO THUÊ", style: TextStyle(color: AppColors.grayText, fontSize: 14)),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: _currentStep == 1 ? _handleSendOtp : _handleLogin,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
        child: Text(_currentStep == 1 ? "Gửi mã OTP" : "Đăng nhập", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSocialLogins() {
    return Column(
      children: [
        _socialButton("Đăng nhập với ZALO", const Color(0xFF4CAF50), Icons.chat_bubble, () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển. Vui lòng dùng Email!")));
        }),
        const SizedBox(height: 12),
        _socialButton("Đăng nhập bằng Apple", Colors.black, Icons.apple, () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển. Vui lòng dùng Email!")));
        }),
      ],
    );
  }

  Widget _socialButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap, 
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildActionLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpView())),
          child: const Text("Tạo tài khoản", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgetPasswordView())),
          child: const Text("Quên tài khoản ?", style: TextStyle(color: AppColors.grayText, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
