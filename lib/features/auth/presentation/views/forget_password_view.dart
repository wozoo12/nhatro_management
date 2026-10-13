import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  int _currentStep = 1; // 1: Nhập SĐT, 2: Đặt mật khẩu, 3: Nhập OTP
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _otpController = TextEditingController();

  void _nextStep() {
    setState(() => _currentStep++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Khôi phục mật khẩu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_currentStep == 1) return _buildPhoneInput();
    if (_currentStep == 2) return _buildNewPasswordInput();
    return _buildOtpInput();
  }

  // BƯỚC 1: Nhập Số điện thoại
  Widget _buildPhoneInput() {
    return Column(
      children: [
        const Icon(Icons.email_rounded, size: 60, color: AppColors.primaryGreen),
        const SizedBox(height: 24),
        const Text("Xác minh Email", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Vui lòng nhập Email để nhận mã OTP", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        CustomTextField(
          label: "Email cá nhân",
          hintText: "Nhập email của bạn",
          controller: _phoneController, // Tái sử dụng biến
          keyboardType: TextInputType.emailAddress,
        ),
        const Spacer(),
        _buildButton("Gửi mã OTP", () async {
          final email = _phoneController.text.trim();
          if (email.isEmpty) return;
          try {
            await supabase_flutter.Supabase.instance.client.auth.resetPasswordForEmail(email);
            if (!mounted) return;
            _nextStep();
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
          }
        }),
      ],
    );
  }

  // BƯỚC 2: Đặt mật khẩu mới
  Widget _buildNewPasswordInput() {
    return Column(
      children: [
        const Icon(Icons.lock_reset_rounded, size: 60, color: AppColors.primaryGreen),
        const SizedBox(height: 24),
        const Text("Thiết lập mật khẩu mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        CustomTextField(label: "Mật khẩu mới", isPassword: true, hintText: "Ít nhất 6 ký tự", controller: _passController),
        const SizedBox(height: 16),
        CustomTextField(label: "Xác nhận mật khẩu", isPassword: true, hintText: "Nhập lại mật khẩu"),
        const Spacer(),
        _buildButton("Tiếp tục", () {
          if (_passController.text.length < 6) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu quá ngắn")));
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã OTP đã được gửi đến Email của bạn")));
          _nextStep();
        }),
      ],
    );
  }

  // BƯỚC 3: Nhập OTP (OTP Sent via Zalo theo spec)
  Widget _buildOtpInput() {
    return Column(
      children: [
        const Icon(Icons.mark_email_read_rounded, size: 60, color: Color(0xFF4CAF50)),
        const SizedBox(height: 24),
        const Text("Xác thực OTP Email", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Mã OTP đã được gửi đến Email của bạn", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        CustomTextField(
          label: "Mã xác thực (6 số)",
          hintText: "______",
          controller: _otpController,
          keyboardType: TextInputType.number,
        ),
        const Spacer(),
        _buildButton("Xác nhận & Đổi mật khẩu", () async {
          try {
            final res = await supabase_flutter.Supabase.instance.client.auth.verifyOTP(
              email: _phoneController.text.trim(),
              token: _otpController.text.trim(),
              type: supabase_flutter.OtpType.recovery,
            );
            if (res.user != null) {
              await supabase_flutter.Supabase.instance.client.auth.updateUser(
                supabase_flutter.UserAttributes(password: _passController.text),
              );
            }
            if (!mounted) return;
            _showSuccessDialog();
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã OTP không chính xác hoặc đã hết hạn!")));
          }
        }),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 60),
        title: const Text("Thành công"),
        content: const Text("Mật khẩu của bạn đã được thay đổi. Vui lòng đăng nhập lại."),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(ctx); // Close dialog
            Navigator.pop(context); // Back to Login
          }, child: const Text("Đăng nhập ngay")),
        ],
      ),
    );
  }
}
