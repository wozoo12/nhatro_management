import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController(); 
  int _currentStep = 1;
  bool _isLoading = false;

  Future<void> _handleSendOtp() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
      return;
    }

    if (_emailController.text.trim() == 'test@lozido.com') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chế độ TEST: Bỏ qua gửi Email thực! Mã OTP là 123456")));
      setState(() => _currentStep = 2);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      await supabase_flutter.Supabase.instance.client.auth.signUp(
        email: email,
        password: 'Lozido@User123!', // Mật khẩu giả để dùng OTP
        data: {'name': _nameController.text.trim()},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã OTP 6 số đã được gửi đến Email của bạn!")));
      setState(() => _currentStep = 2);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đăng ký tài khoản", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.person_add_alt_1_rounded, size: 80, color: AppColors.primaryGreen),
            const SizedBox(height: 32),
            CustomTextField(
              label: "Họ và tên",
              isRequired: true,
              hintText: "Nhập tên của bạn",
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Email cá nhân",
              isRequired: true,
              hintText: "Dùng để nhận mã OTP",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            if (_currentStep == 2) ...[
              const SizedBox(height: 20),
              CustomTextField(
                label: "Mã OTP (6 số từ Email)",
                isRequired: true,
                hintText: "Nhập mã xác thực",
                controller: _otpController,
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_currentStep == 1 ? _handleSendOtp : () async {
                  setState(() => _isLoading = true);
                  try {
                    final email = _emailController.text.trim();

                    if (email == 'test@lozido.com' && _otpController.text.trim() == '123456') {
                        // Tự động vượt qua bước xác thực
                    } else {
                        // Xác thực OTP đăng ký thực tế
                        await supabase_flutter.Supabase.instance.client.auth.verifyOTP(
                          email: email,
                          token: _otpController.text.trim(),
                          type: supabase_flutter.OtpType.signup,
                        );
                        await supabase_flutter.Supabase.instance.client.auth.signOut();
                    }

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đăng ký thành công! Vui lòng đăng nhập.")),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mã OTP không chính xác hoặc đã hết hạn!")),
                    );
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                }),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_currentStep == 1 ? "Gửi mã OTP" : "Tạo tài khoản", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
