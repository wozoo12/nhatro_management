import 'package:flutter/material.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
// import 'package:nhatro_management/features/room/presentation/views/room_grid_view.dart';
import 'package:nhatro_management/features/finance/presentation/views/finance_view.dart';
// import 'package:nhatro_management/features/room/presentation/views/room_group_management_view.dart';
import 'package:nhatro_management/features/invoice/presentation/views/invoice_list_view.dart';
import 'package:nhatro_management/features/room/presentation/views/dashboard_view.dart';
import 'package:nhatro_management/features/finance/presentation/views/selectable_booking_rooms_view.dart';
import 'package:nhatro_management/features/tenant/presentation/views/selectable_contract_rooms_view.dart';
import 'package:nhatro_management/features/room/data/models/property_model.dart';
import 'package:nhatro_management/features/dashboard/presentation/widgets/revenue_chart_widget.dart';
import 'package:nhatro_management/features/settings/presentation/views/settings_view.dart';
import 'package:nhatro_management/features/room/presentation/views/room_checkout_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhatro_management/features/room/data/repositories/room_repository.dart';
import 'package:nhatro_management/features/property_wizard/presentation/views/property_wizard_view.dart';
import 'package:nhatro_management/features/room/presentation/views/asset_management_view.dart';
import 'package:nhatro_management/features/dashboard/presentation/widgets/occupancy_pie_chart_widget.dart';
import 'package:nhatro_management/features/room/presentation/views/issue_management_view.dart';

class MainDashboardView extends StatefulWidget {
  const MainDashboardView({super.key});

  @override
  State<MainDashboardView> createState() => _MainDashboardViewState();
}

class _MainDashboardViewState extends State<MainDashboardView> {
  int _selectedTabIndex = 0;
  PropertyModel? _currentProperty;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final properties = await context.read<RoomRepository>().getProperties();
      if (properties.isEmpty) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PropertyWizardView()));
        }
      } else {
        setState(() {
          _currentProperty = properties.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_currentProperty == null) {
      return const Scaffold(body: Center(child: Text("Lỗi tải dữ liệu nhà trọ")));
    }

    return Scaffold(
      body: Column(
        children: [
          _buildTopHeader(),
          _buildSegmentedControl(),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildManagementTab(),
                _buildOverviewTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 8),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.home_work, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text("Nhà trọ: ${_currentProperty!.name}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)), const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18)]),
                Text(_currentProperty!.address ?? "Chưa có địa chỉ", style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 44,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          _segmentItem("Quản Lý", 0, Icons.assignment_turned_in_outlined),
          _segmentItem("Tổng Quan", 1, Icons.trending_up),
        ],
      ),
    );
  }

  Widget _segmentItem(String title, int index, IconData icon) {
    bool active = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: active ? AppColors.primaryGreen : Colors.transparent, borderRadius: BorderRadius.circular(25)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: active ? Colors.white : Colors.grey), const SizedBox(width: 8), Text(title, style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))]),
        ),
      ),
    );
  }

  Widget _buildManagementTab() {
    // ĐÚNG 8 MODULE NGHIỆP VỤ THEO SPEC LOZIDO (FLOW 4)
    final List<Map<String, dynamic>> modules = [
      {"t": "Quản lý phòng", "i": Icons.meeting_room, "c": Colors.green, "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardView(property: _currentProperty!)))},
      {"t": "Cọc giữ chỗ", "i": Icons.handshake, "c": Colors.orange, "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectableBookingRoomsView()))},
      {"t": "Lập hợp đồng mới", "i": Icons.assignment_add, "c": AppColors.primaryGreen, "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => SelectableContractRoomsView(propertyId: _currentProperty!.id)))},
      {"t": "Hóa đơn / Thu tiền", "i": Icons.receipt_long, "c": Colors.teal, "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceListView(property: _currentProperty!)))},
      {"t": "Thanh lý / Trả phòng", "i": Icons.exit_to_app, "c": Colors.red, "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomCheckoutView(roomId: "1", roomNumber: "101")))},
      {"t": "Quản lý tài sản", "i": Icons.inventory_2, "c": Colors.brown, "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetManagementView(property: _currentProperty!)))},
      {"t": "Quản lý sự cố", "i": Icons.build_circle, "c": AppColors.dangerRed, "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IssueManagementView()))},
      {"t": "Sổ quỹ / Thu chi", "i": Icons.account_balance_wallet, "c": Colors.purple, "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceView()))},
      {"t": "Cài đặt & Zalo", "i": Icons.settings_suggest, "c": Colors.blueGrey, "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsView()))},
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5),
      itemCount: modules.length,
      itemBuilder: (ctx, i) => _buildModuleCard(modules[i]),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> mod) {
    return GestureDetector(
      onTap: mod['onTap'],
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(mod['i'], color: mod['c'], size: 32),
            const SizedBox(height: 8),
            Text(mod['t'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSmartReminders(),
        const SizedBox(height: 16),
        const OccupancyPieChartWidget(),
        const SizedBox(height: 16),
        const RevenueChartWidget(),
        const SizedBox(height: 16),
        _buildStatCard("Nợ tiền cần thu", "15.500.000đ", AppColors.primaryGreen),
      ],
    );
  }

  Widget _buildSmartReminders() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildReminderCard("3", "Hóa đơn quá hạn", AppColors.dangerRed),
          const SizedBox(width: 12),
          _buildReminderCard("1", "Hợp đồng sắp hết", Colors.orange),
          const SizedBox(width: 12),
          _buildReminderCard("5", "Yêu cầu sửa chữa", AppColors.primaryGreen),
        ],
      ),
    );
  }

  Widget _buildReminderCard(String count, String label, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryGreen,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Công việc"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm khách"),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Thêm"),
      ],
    );
  }
}
