import 'package:flutter/material.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/features/room/data/models/property_model.dart';

class AssetManagementView extends StatefulWidget {
  final PropertyModel property;
  
  const AssetManagementView({super.key, required this.property});

  @override
  State<AssetManagementView> createState() => _AssetManagementViewState();
}

class _AssetManagementViewState extends State<AssetManagementView> {
  // Mock data cho danh sách tài sản (thường sẽ fetch từ DB)
  final List<Map<String, dynamic>> _assets = [
    {"name": "Máy lạnh Daikin 1HP", "quantity": 1, "status": "NORMAL", "room": "P101"},
    {"name": "Tủ lạnh Sanyo 90L", "quantity": 1, "status": "BROKEN", "room": "P101"},
    {"name": "Giường gỗ 1m6", "quantity": 1, "status": "NORMAL", "room": "P101"},
    {"name": "Chìa khóa cổng", "quantity": 2, "status": "NORMAL", "room": "P102"},
    {"name": "Tủ quần áo", "quantity": 1, "status": "NORMAL", "room": "P102"},
  ];

  String _searchQuery = '';
  String _filterStatus = 'ALL';

  List<Map<String, dynamic>> get _filteredAssets {
    return _assets.where((asset) {
      final matchesSearch = asset['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            asset['room'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _filterStatus == 'ALL' || asset['status'] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showAddAssetDialog() {
    // Demo dialog thêm tài sản
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng Thêm tài sản sẽ được phát triển sau')),
    );
  }

  void _toggleAssetStatus(int index) {
    setState(() {
      final currentStatus = _assets[index]['status'];
      _assets[index]['status'] = currentStatus == 'NORMAL' ? 'BROKEN' : 'NORMAL';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        title: const Text('Quản lý Tài sản', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddAssetDialog,
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _filteredAssets.isEmpty 
              ? const Center(child: Text("Không tìm thấy tài sản nào", style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredAssets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    // Find actual index in original list for toggling
                    final asset = _filteredAssets[index];
                    final actualIndex = _assets.indexOf(asset);
                    return _buildAssetCard(asset, actualIndex);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm theo tên tài sản hoặc phòng...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: AppColors.lightGrayBg,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('Tất cả', 'ALL'),
            const SizedBox(width: 8),
            _filterChip('Bình thường', 'NORMAL', color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            _filterChip('Hư hỏng/Báo lỗi', 'BROKEN', color: AppColors.dangerRed),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value, {Color? color}) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      )),
      selected: isSelected,
      selectedColor: color ?? AppColors.primaryGreen,
      onSelected: (selected) {
        if (selected) setState(() => _filterStatus = value);
      },
      showCheckmark: false,
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset, int actualIndex) {
    final isBroken = asset['status'] == 'BROKEN';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isBroken ? AppColors.dangerRed.withValues(alpha: 0.3) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isBroken ? AppColors.dangerRed.withValues(alpha: 0.1) : AppColors.blueCTA.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBroken ? Icons.build_circle_outlined : Icons.inventory_2_outlined,
              color: isBroken ? AppColors.dangerRed : AppColors.blueCTA,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                      child: Text(asset['room'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text('SL: ${asset['quantity']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: !isBroken,
            activeColor: AppColors.primaryGreen,
            inactiveThumbColor: AppColors.dangerRed,
            inactiveTrackColor: AppColors.dangerRed.withValues(alpha: 0.3),
            onChanged: (val) => _toggleAssetStatus(actualIndex),
          ),
        ],
      ),
    );
  }
}
