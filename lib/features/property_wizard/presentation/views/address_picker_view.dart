import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'map_picker_view.dart';

class AddressPickerView extends StatefulWidget {
  const AddressPickerView({super.key});

  @override
  State<AddressPickerView> createState() => _AddressPickerViewState();
}

class _AddressPickerViewState extends State<AddressPickerView> {
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  final TextEditingController _detailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Địa chỉ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown("Tỉnh/Thành phố", selectedProvince, (val) {
                    setState(() {
                      selectedProvince = val;
                      selectedDistrict = null;
                      selectedWard = null;
                    });
                  }, ["TP. Hồ Chí Minh", "Hà Nội", "Đà Nẵng"]),
                  const SizedBox(height: 16),
                  _buildDropdown("Quận/Huyện", selectedDistrict, (val) {
                    setState(() {
                      selectedDistrict = val;
                      selectedWard = null;
                    });
                  }, selectedProvince == null ? [] : ["Quận Bình Thạnh", "Quận 1", "Quận Thủ Đức"]),
                  const SizedBox(height: 16),
                  _buildDropdown("Phường/Xã", selectedWard, (val) {
                    setState(() => selectedWard = val);
                  }, selectedDistrict == null ? [] : ["Phường 26", "Phường 25", "Phường Linh Trung"]),
                  const SizedBox(height: 16),
                  const Text("Địa chỉ chi tiết (Số nhà, đường) *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _detailController,
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Ví dụ: 22, Đường số 7",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // NÚT LẤY VỊ TRÍ TỪ BẢN ĐỒ (Theo Spec Flow 3)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(builder: (_) => const MapPickerView()),
                      );
                      if (result != null && result['address'] != null) {
                         // Nếu chọn từ bản đồ, điền tự động vào ô địa chỉ chi tiết
                         setState(() {
                            _detailController.text = result['address'];
                         });
                      }
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text("Lấy vị trí trên bản đồ"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blueCTA,
                      side: const BorderSide(color: AppColors.blueCTA),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, Function(String?) onChanged, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text("Chọn $label"),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    bool isReady = selectedProvince != null && selectedDistrict != null && selectedWard != null && _detailController.text.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isReady ? () {
            Navigator.pop(context, "${_detailController.text}, $selectedWard, $selectedDistrict, $selectedProvince");
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Xác nhận địa chỉ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
