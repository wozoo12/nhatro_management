import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';

class AddRoomView extends StatefulWidget {
  const AddRoomView({super.key});

  @override
  State<AddRoomView> createState() => _AddRoomViewState();
}

class _AddRoomViewState extends State<AddRoomView> {
  final List<Map<String, dynamic>> _selectedServices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        title: const Text("Thêm phòng mới", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card 1: Thông tin định danh
            _buildCard(
              child: Column(
                children: [
                  const CustomTextField(label: "Tên phòng trọ *", hintText: "Ví dụ: Phòng số 1"),
                  const SizedBox(height: 16),
                  _buildDropdown("Nhóm (Tầng/dãy/khu) *", "Chọn tầng"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Thông số tài chính
            _buildCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(child: CustomTextField(label: "Diện tích", hintText: "15", suffixWidget: Text("m2"))),
                      const SizedBox(width: 12),
                      Expanded(child: CustomTextField(label: "Giá thuê", hintText: "3.500.000", suffixWidget: Text("đ/tháng"))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const CustomTextField(label: "Ngày lập hóa đơn", hintText: "1", suffixWidget: Text("Ngày")),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Dịch vụ sử dụng
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Dịch vụ sử dụng", style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => _openServicePicker(context),
                        icon: const Icon(Icons.add_circle, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                  if (_selectedServices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text("Chưa có dịch vụ nào được áp dụng", style: TextStyle(color: Colors.grey, fontSize: 13))),
                    )
                  else
                    ..._selectedServices.map((s) => _buildServiceItem(s)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(value), const Icon(Icons.keyboard_arrow_down, color: Colors.grey)],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(service['icon'], color: AppColors.primaryGreen),
      title: Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text("Chỉ số: ${service['value']} • Đơn giá: ${service['price']}"),
      trailing: const Icon(Icons.check_circle, color: AppColors.primaryGreen),
    );
  }

  void _openServicePicker(BuildContext context) {
    // Luồng gán dịch vụ (Màn hình 8.1 - image_f0a5c3)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Gán dịch vụ phòng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            _servicePickerTile("Tiền điện", Icons.flash_on, "3.500 đ/KWh"),
            _servicePickerTile("Tiền nước", Icons.opacity, "18.000 đ/Khối"),
            _servicePickerTile("Tiền Wifi", Icons.wifi, "50.000 đ/Tháng"),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedServices.add({'name': 'Tiền điện', 'icon': Icons.flash_on, 'value': '0', 'price': '3.500'});
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Áp dụng dịch vụ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _servicePickerTile(String name, IconData icon, String price) {
    return CheckboxListTile(
      value: true,
      onChanged: (v) {},
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(price),
      secondary: Icon(icon, color: AppColors.primaryGreen),
      activeColor: AppColors.primaryGreen,
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng"))),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: const Text("+ Thêm phòng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
