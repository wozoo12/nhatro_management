import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/dashed_container.dart';
import '../cubit/property_wizard_cubit.dart';
import '../cubit/property_wizard_state.dart';

class PropertyStep1View extends StatelessWidget {
  const PropertyStep1View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyWizardCubit, PropertyWizardState>(
      builder: (context, state) {
        final cubit = context.read<PropertyWizardCubit>();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: Thông tin nhà cho thuê
              _buildHeader("#", "Thông tin nhà cho thuê",
                  "Thông tin cơ bản tên, loại hình..."),
              const SizedBox(height: 16),

              _buildCategorySelector(context, state, cubit),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: DashedContainer(
                      isSelected: state.rentalModel == RentalModel.theoPhong,
                      color: AppColors.primaryGreen,
                      onTap: () =>
                          cubit.updateRentalModel(RentalModel.theoPhong),
                      child: _buildRentalCardContent(
                        "Thuê theo phòng",
                        "Tính tiền thuê theo phòng",
                        Icons.meeting_room_outlined,
                        state.rentalModel == RentalModel.theoPhong,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashedContainer(
                      isSelected: state.rentalModel == RentalModel.theoGiuong,
                      color: AppColors.primaryGreen,
                      onTap: () =>
                          cubit.updateRentalModel(RentalModel.theoGiuong),
                      child: _buildRentalCardContent(
                        "Thuê theo giường",
                        "Tính tiền theo giường",
                        Icons.bed_outlined,
                        state.rentalModel == RentalModel.theoGiuong,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              CustomTextField(
                label: "Tên Nhà trọ",
                isRequired: true,
                hintText: "Ví dụ: Nguyễn Thanh",
                errorText: state.propertyNameError,
                onChanged: cubit.updatePropertyName,
              ),

              const SizedBox(height: 20),

              // Ảnh đại diện nhà trọ
              _buildImageUploadSection(context, state, cubit),

              const SizedBox(height: 32),

              // SECTION 2: Cấu hình dữ liệu
              _buildHeader("#", "Khởi tạo dữ liệu", "Theo mẫu hoặc thủ công"),
              const SizedBox(height: 12),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Tự động theo mẫu",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                value: state.autoCreateRooms,
                activeColor: AppColors.primaryGreen,
                onChanged: (val) {
                  if (!val) {
                    _showDisableWarning(context, cubit);
                  } else {
                    cubit.toggleAutoCreate(true);
                  }
                },
              ),

              if (state.autoCreateRooms) ...[
                const SizedBox(height: 8),
                _buildSelectorField(
                    "Số tầng",
                    state.floorCount == 0
                        ? "Tầng trệt"
                        : "${state.floorCount} tầng",
                    () => _showFloorPicker(context, cubit)),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Số lượng phòng",
                  hintText: "10",
                  errorText: state.roomCountError,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) => cubit.updateRoomCount(int.tryParse(v) ?? 0),
                  suffixWidget: const Text("phòng",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "Diện tích (m²)",
                        hintText: "15",
                        errorText: state.areaError,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        suffixWidget: const Text("m2",
                            style: TextStyle(color: Colors.grey)),
                        onChanged: (v) =>
                            cubit.updateArea(double.tryParse(v) ?? 0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: "Giá thuê mẫu",
                        hintText: "2.000.000",
                        isCurrency: true,
                        suffixWidget: const Text("đ/tháng",
                            style: TextStyle(color: Colors.grey)),
                        onChanged: (v) => cubit.updateBasePrice(
                            double.tryParse(v.replaceAll('.', '')) ?? 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSelectorField(
                          "Ngày chốt tiền",
                          "Ngày ${state.billingDate}",
                          () => _showBillingDatePicker(context, cubit)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: "Số khách tối đa",
                        hintText: "4",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (v) =>
                            cubit.updateMaxTenants(int.tryParse(v) ?? 1),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageUploadSection(BuildContext context,
      PropertyWizardState state, PropertyWizardCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text("Ảnh đại diện nhà trọ",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(" (Tùy chọn)",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 10),
        if (state.coverImagePath != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(state.coverImagePath!),
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => cubit.clearImage(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _pickImage(context, cubit),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text("Đổi ảnh",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: () => _pickImage(context, cubit),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text("Thêm ảnh nhà trọ",
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500)),
                  Text("Chụp ảnh hoặc chọn từ thư viện",
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage(
      BuildContext context, PropertyWizardCubit cubit) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text("Chụp ảnh"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text("Chọn từ thư viện"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: source, imageQuality: 80, maxWidth: 1280);
    if (picked != null) {
      cubit.updateCoverImage(picked.path);
    }
  }

  Widget _buildHeader(String icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(4)),
          child: Text(icon,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context, PropertyWizardState state,
      PropertyWizardCubit cubit) {
    return InkWell(
      onTap: () => _showTypePicker(context, cubit),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text("Loại hình cho thuê",
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text(" *", style: TextStyle(color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_propertyTypeToString(state.propertyType),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalCardContent(
      String title, String subtitle, IconData icon, bool isSelected) {
    return Column(
      children: [
        Icon(icon,
            color: isSelected ? AppColors.primaryGreen : Colors.grey, size: 32),
        const SizedBox(height: 8),
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? AppColors.primaryGreen : Colors.black87)),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSelectorField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _propertyTypeToString(PropertyType type) {
    switch (type) {
      case PropertyType.nhaTro:
        return "Nhà trọ";
      case PropertyType.ktx:
        return "Ký túc xá / Sleepbox";
      case PropertyType.chungCuMini:
        return "Chung cư mini";
      case PropertyType.nhaNguyenCan:
        return "Nhà nguyên căn";
      case PropertyType.vanPhong:
        return "Văn phòng";
    }
  }

  void _showTypePicker(BuildContext context, PropertyWizardCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      // Dùng StatefulBuilder để dấu ✓ cập nhật ngay khi chọn
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => FractionallySizedBox(
          heightFactor: 0.55,
          child: Column(children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Chọn loại hình",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const Divider(height: 1),
            Expanded(
                child: ListView(
                    children: PropertyType.values
                        .map((t) => ListTile(
                              title: Text(_propertyTypeToString(t)),
                              trailing: cubit.state.propertyType == t
                                  ? const Icon(Icons.check_circle,
                                      color: AppColors.primaryGreen)
                                  : null,
                              onTap: () {
                                cubit.updatePropertyType(t);
                                setModalState(
                                    () {}); // rebuild dấu check bên trong modal
                                Navigator.pop(context);
                              },
                            ))
                        .toList())),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  void _showFloorPicker(BuildContext context, PropertyWizardCubit cubit) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        shrinkWrap: true,
        itemCount: 9,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(i == 0 ? "Tầng trệt" : "$i tầng"),
          onTap: () {
            cubit.updateFloorCount(i);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showBillingDatePicker(BuildContext context, PropertyWizardCubit cubit) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Chọn ngày chốt tiền hàng tháng",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: ListView.builder(
              itemCount: 31,
              itemBuilder: (ctx, i) => ListTile(
                title: Text("Ngày ${i + 1}"),
                onTap: () {
                  cubit.updateBillingDate(i + 1);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisableWarning(BuildContext context, PropertyWizardCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thông báo xác nhận"),
        content:
            const Text("Bạn muốn tắt chế độ khởi tạo phòng tự động theo mẫu?"),
        actions: [
          TextButton(
            onPressed: () {
              cubit.toggleAutoCreate(false);
              Navigator.pop(ctx);
            },
            child: const Text("Xác nhận",
                style: TextStyle(color: AppColors.dangerRed)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen),
            child: const Text("Hủy bỏ"),
          ),
        ],
      ),
    );
  }
}
