import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MapPickerView extends StatefulWidget {
  const MapPickerView({super.key});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  // Giả lập tọa độ ban đầu (Thủ Đức, TP. HCM)
  double lat = 10.8231;
  double lng = 106.6297;
  String currentAddress = "Đang xác định vị trí...";

  @override
  void initState() {
    super.initState();
    // Giả lập việc lấy địa chỉ từ tọa độ (Reverse Geocoding) sau 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          currentAddress = "Số 1, Võ Văn Ngân, Linh Trung, Thủ Đức, TP. HCM";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Xác định vị trí trên bản đồ", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Map Area Placeholder (Vị trí dành cho Google Maps SDK sau này)
          Container(
            color: Colors.grey.shade100,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("Bản đồ đang tải...", style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text("(Tọa độ hiện tại: $lat, $lng)", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
          
          // 2. Center Pin (Static - Bản đồ sẽ trượt phía dưới)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40), // Đã sửa lỗi EdgeInsets.bottom thành EdgeInsets.only
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("Di chuyển bản đồ để chọn", 
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.location_on_rounded, size: 48, color: AppColors.dangerRed),
                ],
              ),
            ),
          ),

          // 3. Search Bar Area (Dùng để tìm kiếm địa chỉ nhanh)
          Positioned(
            top: 100, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm địa chỉ nhà trọ...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Bottom Information Card (Hiển thị địa chỉ đã chọn)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ĐỊA CHỈ ĐÃ CHỌN", 
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_pin, color: AppColors.primaryGreen, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            currentAddress,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Logic lấy GPS thật sẽ dùng package geolocator
                            },
                            icon: const Icon(Icons.gps_fixed, size: 18),
                            label: const Text("Hiện tại"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.blueCTA,
                              side: const BorderSide(color: AppColors.blueCTA),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, {"lat": lat, "lng": lng, "address": currentAddress}),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text("Xác định vị trí", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
