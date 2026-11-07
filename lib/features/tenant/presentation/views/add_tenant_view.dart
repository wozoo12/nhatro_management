import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/tenant_bloc.dart';
import '../bloc/tenant_event.dart';
import '../bloc/tenant_state.dart';
import '../../data/models/tenant_model.dart';
import '../../data/models/cccd_qr_model.dart';
import 'cccd_scanner_view.dart';

/// [AddTenantView] là màn hình cho phép chủ trọ nhập hồ sơ khách thuê mới.
/// Tính năng nổi bật: Quét mã QR CCCD gắn chip và Chụp ảnh mặt trước/sau CCCD.
class AddTenantView extends StatefulWidget {
  const AddTenantView({super.key});

  @override
  State<AddTenantView> createState() => _AddTenantViewState();
}

class _AddTenantViewState extends State<AddTenantView> {
  // --- QUẢN LÝ TRẠNG THÁI FORM ---
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();

  // Dữ liệu CCCD đã quét được
  CccdQrModel? _scannedCccd;

  // --- QUẢN LÝ HÌNH ẢNH ---
  File? _frontImage; // Lưu file ảnh mặt trước CCCD
  File? _backImage; // Lưu file ảnh mặt sau CCCD
  final ImagePicker _picker = ImagePicker();

  // --- HỆ THỐNG MÀU SẮC ---
  static const Color primaryBlue = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF64748B);

  /// Hàm xử lý chọn ảnh từ Camera hoặc Thư viện
  /// [isFront]: true nếu là mặt trước, false nếu là mặt sau.
  Future<void> _pickImage(bool isFront) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource
            .gallery, // Tạm thời dùng Thư viện thay vì Camera để test trên máy ảo
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          if (isFront) {
            _frontImage = File(pickedFile.path);
          } else {
            _backImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi chụp ảnh: $e');
    }
  }

  /// Mở màn hình quét mã QR thẻ CCCD gắn chip
  Future<void> _scanCccd() async {
    final result = await Navigator.push<CccdQrModel>(
      context,
      MaterialPageRoute(builder: (_) => const CccdScannerView()),
    );

    if (result != null) {
      setState(() {
        _scannedCccd = result;
        _nameController.text = result.fullName;
        _idController.text = result.cccdNumber;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Đã nhận diện: ${result.fullName} (${result.cccdNumber})')),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Hàm thực hiện lưu hồ sơ khách thuê
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 1. Tạo đối tượng Model tạm thời với dữ liệu từ Form
      final newTenant = TenantModel(
        id: 0, // Database tự tạo ID
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        identityCard: _idController.text.trim(),
        createdAt: DateTime.now(),
      );

      // 2. Gửi sự kiện AddTenant tới Bloc kèm theo các file ảnh đã chụp
      context.read<TenantBloc>().add(AddTenant(
            tenant: newTenant,
            frontCard: _frontImage,
            backCard: _backImage,
          ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Thêm khách thuê mới',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<TenantBloc, TenantState>(
        listener: (context, state) {
          // Lắng nghe trạng thái thành công để quay về màn hình trước
          if (state is TenantLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã thêm khách thuê thành công!')));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop(true);
            });
          }
          // Lắng nghe lỗi để thông báo
          if (state is TenantError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScanCccdBanner(),
                const SizedBox(height: 16),
                if (_scannedCccd != null) ...[
                  _buildScannedInfoCard(),
                  const SizedBox(height: 16),
                ],
                _buildSectionTitle('Thông tin cá nhân'),
                _buildInputCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Hình ảnh CCCD / Hộ chiếu'),
                _buildImageSection(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tiêu đề từng phần trong Form
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: mutedText,
              letterSpacing: 0.5)),
    );
  }

  /// Thẻ Card chứa các ô nhập liệu văn bản
  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Họ và tên',
            icon: Icons.person_outline,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Số điện thoại',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.length < 10)
                ? 'Số điện thoại không hợp lệ'
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _idController,
            label: 'Số CCCD / CMND',
            icon: Icons.badge_outlined,
          ),
        ],
      ),
    );
  }

  /// Widget tùy chỉnh cho ô nhập liệu
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22, color: primaryBlue),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  /// Phần xây dựng các khung chụp ảnh mặt trước/sau
  Widget _buildImageSection() {
    return Row(
      children: [
        Expanded(
            child: _buildImagePickerItem(
                'Mặt trước', _frontImage, () => _pickImage(true))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildImagePickerItem(
                'Mặt sau', _backImage, () => _pickImage(false))),
      ],
    );
  }

  /// Từng khung chọn ảnh riêng lẻ
  Widget _buildImagePickerItem(
      String label, File? imageFile, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined,
                          color: primaryBlue, size: 32),
                      const SizedBox(height: 8),
                      Text(label,
                          style:
                              const TextStyle(fontSize: 12, color: mutedText)),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(imageFile, fit: BoxFit.cover),
                  ),
          ),
        ),
        if (imageFile != null)
          TextButton(
              onPressed: onTap,
              child: const Text('Chụp lại', style: TextStyle(fontSize: 12))),
      ],
    );
  }

  /// Banner kêu gọi Quét mã QR CCCD gắn chip
  Widget _buildScanCccdBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00A86B), Color(0xFF00C853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _scanCccd,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Quét mã QR CCCD gắn chip',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.bolt,
                              color: Colors.yellowAccent, size: 16),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tự động điền Họ tên, Số CCCD & Nơi thường trú',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Card hiển thị các thông tin trích xuất từ CCCD (Ngày sinh, Giới tính, Địa chỉ)
  Widget _buildScannedInfoCard() {
    final cccd = _scannedCccd!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mintBg,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: AppColors.primaryGreen, size: 18),
              SizedBox(width: 8),
              Text(
                'Dữ liệu trích xuất từ thẻ CCCD',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                    fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow('Ngày sinh',
              cccd.birthDate.isNotEmpty ? cccd.birthDate : 'Chưa rõ'),
          const SizedBox(height: 6),
          _buildInfoRow(
              'Giới tính', cccd.gender.isNotEmpty ? cccd.gender : 'Chưa rõ'),
          const SizedBox(height: 6),
          _buildInfoRow('Nơi thường trú',
              cccd.address.isNotEmpty ? cccd.address : 'Chưa rõ'),
          if (cccd.cmndNumber != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow('Số CMND cũ', cccd.cmndNumber!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: mutedText)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ),
      ],
    );
  }

  /// Nút bấm lưu hồ sơ khách thuê
  Widget _buildSubmitButton() {
    return BlocBuilder<TenantBloc, TenantState>(
      builder: (context, state) {
        final bool isLoading =
            state is TenantLoading || state is TenantUploadingImage;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Đang xử lý hồ sơ...'),
                    ],
                  )
                : const Text('LƯU HỒ SƠ KHÁCH THUÊ',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
