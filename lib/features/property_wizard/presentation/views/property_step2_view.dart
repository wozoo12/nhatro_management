import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/property_wizard_cubit.dart';
import '../cubit/property_wizard_state.dart';
import 'map_picker_view.dart';

class PropertyStep2View extends StatelessWidget {
  const PropertyStep2View({super.key});

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
              // I. CÀI ĐẶT DỊCH VỤ
              _buildSectionHeader("Cài đặt dịch vụ", "Thiết lập cách tính phí điện, nước..."),
              const SizedBox(height: 12),
              _buildServiceTile(
                "Tiền điện", 
                state.electricityType, 
                Icons.flash_on_rounded, 
                Colors.orange,
                () => _showServiceModal(context, "Tính tiền điện", ["Đồng hồ", "Theo người", "Theo phòng", "Miễn phí"], (v) => cubit.updateElectricityType(v)),
              ),
              _buildServiceTile(
                "Tiền nước", 
                state.waterType, 
                Icons.opacity_rounded, 
                Colors.blue,
                () => _showServiceModal(context, "Tính tiền nước", ["Đồng hồ/Khối", "Theo người", "Theo phòng", "Miễn phí"], (v) => cubit.updateWaterType(v)),
              ),

              const SizedBox(height: 24),
              
              // II. CÀI ĐẶT TÍNH NĂNG (Đối soát 100% Spec)
              _buildSectionHeader("Cài đặt tính năng", "Bật/Tắt các tiện ích quản lý thông minh"),
              const SizedBox(height: 8),
              _buildFeatureSwitch(
                "App cho khách thuê", 
                "Khách tự xem hóa đơn, báo cáo sự cố", 
                state.hasGuestApp, 
                isFree: true,
                onChanged: cubit.toggleGuestApp
              ),
              _buildFeatureSwitch(
                "Gửi hóa đơn qua Zalo", 
                "Tự động gửi tin nhắn báo tiền hàng tháng", 
                state.sendZaloInvoice, 
                onChanged: (val) {
                  if (val) {
                    _showZaloWarning(context, cubit);
                  } else {
                    cubit.toggleZaloInvoice(false);
                  }
                }
              ),
              _buildFeatureSwitch(
                "Quản lý tài sản", 
                "Theo dõi danh mục đồ đạc trong phòng", 
                state.manageAssets, 
                onChanged: cubit.toggleAssets
              ),
              _buildFeatureSwitch(
                "Quản lý xe", 
                "Ghi nhận biển số, thẻ gửi xe khách thuê", 
                state.manageVehicles, 
                onChanged: cubit.toggleVehicles
              ),
              _buildFeatureSwitch(
                "Quản lý công việc", 
                "Giao việc bảo trì cho nhân viên", 
                state.findTenants, 
                onChanged: cubit.toggleJobManagement
              ),
              _buildFeatureSwitch(
                "Gửi SMS tự động", 
                "Nhắc nợ qua tin nhắn nhà mạng", 
                state.autoSms, 
                onChanged: cubit.toggleSms
              ),

              const SizedBox(height: 24),

              // III. ĐỊA CHỈ & BẢN ĐỒ
              _buildSectionHeader("Địa chỉ & Bản đồ", "Vị trí chính xác để khách dễ dàng tìm thấy"),
              const SizedBox(height: 16),
              
              if (state.address.isEmpty)
                _buildLocationButton(
                  "+ Thêm địa chỉ & vị trí trên bản đồ", 
                  Icons.map_outlined, 
                  AppColors.blueCTA,
                  () => _navigateToMapPicker(context, cubit),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mintBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                          const SizedBox(width: 8),
                          const Text("Vị trí đã chọn", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _navigateToMapPicker(context, cubit),
                            child: const Text("Chỉnh sửa", style: TextStyle(decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                      Text(state.address, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                ),
              
              if (state.addressError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(state.addressError!, style: const TextStyle(color: AppColors.dangerRed, fontSize: 12)),
                ),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(4)),
              child: const Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildServiceTile(String label, String value, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildFeatureSwitch(String title, String subtitle, bool value, {bool isFree = false, required Function(bool) onChanged}) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primaryGreen,
      title: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (isFree)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
              child: const Text("Miễn phí", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildLocationButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showServiceModal(BuildContext context, String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(),
          ...options.map((opt) => ListTile(
            title: Text(opt),
            onTap: () {
              onSelect(opt);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showZaloWarning(BuildContext context, PropertyWizardCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận phí Zalo ZNS"),
        content: const Text("Tính năng gửi hóa đơn qua Zalo sẽ phát sinh chi phí theo gói tin nhắn ZNS của nhà mạng. Bạn có đồng ý bật?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy bỏ")),
          ElevatedButton(
            onPressed: () {
              cubit.toggleZaloInvoice(true);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text("Đồng ý"),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToMapPicker(BuildContext context, PropertyWizardCubit cubit) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerView()),
    );

    if (result != null) {
      cubit.updateLocation(
        result['lat'] as double,
        result['lng'] as double,
        result['address'] as String,
      );
    }
  }
}
