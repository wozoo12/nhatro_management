import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/core/utils/formatters.dart';
import 'package:nhatro_management/features/finance/presentation/views/finance_view.dart';
import 'package:nhatro_management/features/invoice/presentation/views/invoice_list_view.dart';
import 'package:nhatro_management/features/room/presentation/views/dashboard_view.dart';
import 'package:nhatro_management/features/finance/presentation/views/selectable_booking_rooms_view.dart';
import 'package:nhatro_management/features/tenant/presentation/views/selectable_contract_rooms_view.dart';
import 'package:nhatro_management/features/room/presentation/views/selectable_checkout_rooms_view.dart';
import 'package:nhatro_management/features/room/data/models/property_model.dart';
import 'package:nhatro_management/features/dashboard/presentation/widgets/revenue_chart_widget.dart';
import 'package:nhatro_management/features/settings/presentation/views/settings_view.dart';
import 'package:nhatro_management/features/room/data/repositories/room_repository.dart';
import 'package:nhatro_management/features/property_wizard/presentation/views/property_wizard_view.dart';
import 'package:nhatro_management/features/room/presentation/views/asset_management_view.dart';
import 'package:nhatro_management/features/dashboard/presentation/widgets/occupancy_pie_chart_widget.dart';
import 'package:nhatro_management/features/room/presentation/views/issue_management_view.dart';
import 'package:nhatro_management/features/tasks/presentation/views/tasks_view.dart';
import 'package:nhatro_management/features/tenant_finding/presentation/views/tenant_finding_view.dart';
import 'package:nhatro_management/features/more/presentation/views/more_view.dart';
import 'package:nhatro_management/features/tenant/presentation/views/cccd_scanner_view.dart';
import 'package:nhatro_management/features/tenant/data/models/cccd_qr_model.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_state.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_bloc.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_event.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_state.dart';
import 'package:nhatro_management/features/room/data/models/room_model.dart';

class MainDashboardView extends StatefulWidget {
  const MainDashboardView({super.key});

  @override
  State<MainDashboardView> createState() => _MainDashboardViewState();
}

class _MainDashboardViewState extends State<MainDashboardView> {
  int _selectedTabIndex = 0;
  int _selectedBottomIndex = 0;
  List<PropertyModel> _properties = [];
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
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const PropertyWizardView()));
        }
      } else {
        setState(() {
          _properties = properties;
          _currentProperty = properties.first;
          _isLoading = false;
        });
        // Tải dữ liệu phòng và hóa đơn thật cho nhà hiện tại
        if (mounted) {
          context
              .read<RoomBloc>()
              .add(FetchDashboardData(_currentProperty!.id));
          context.read<InvoiceBloc>().add(FetchInvoices(_currentProperty!.id));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _switchProperty(PropertyModel prop) {
    setState(() {
      _currentProperty = prop;
    });
    context.read<RoomBloc>().add(FetchDashboardData(prop.id));
    context.read<InvoiceBloc>().add(FetchInvoices(prop.id));
  }

  Future<void> _handleScanQr(BuildContext context) async {
    final result = await Navigator.push<CccdQrModel>(
      context,
      MaterialPageRoute(builder: (_) => const CccdScannerView()),
    );
    if (result != null && mounted) {
      _showScannedCccdDialog(context, result);
    }
  }

  void _showScannedCccdDialog(BuildContext context, CccdQrModel cccd) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.badge_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('Thông tin CCCD',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogInfoRow('Họ và tên:', cccd.fullName, isBold: true),
            _dialogInfoRow('Số CCCD:', cccd.cccdNumber),
            _dialogInfoRow('Ngày sinh:', cccd.birthDate),
            _dialogInfoRow('Giới tính:', cccd.gender),
            _dialogInfoRow('Địa chỉ:', cccd.address),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectableContractRoomsView(
                      propertyId: _currentProperty!.id),
                ),
              );
            },
            icon:
                const Icon(Icons.assignment_add, size: 16, color: Colors.white),
            label: const Text('Lập hợp đồng ngay',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _dialogInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(label,
                style:
                    const TextStyle(color: AppColors.grayText, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: AppColors.navyText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPropertySwitchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chọn nhà trọ quản lý',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _properties.length,
                  itemBuilder: (ctx, i) {
                    final prop = _properties[i];
                    final isSelected = prop.id == _currentProperty?.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? AppColors.primaryGreen
                            : Colors.grey.shade200,
                        child: Icon(Icons.home_work,
                            color: isSelected ? Colors.white : Colors.grey),
                      ),
                      title: Text(prop.name,
                          style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      subtitle: Text(prop.address ?? 'Chưa có địa chỉ',
                          style: const TextStyle(fontSize: 12)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primaryGreen)
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        if (!isSelected) {
                          _switchProperty(prop);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PropertyWizardView()))
                        .then((_) => _loadData());
                  },
                  icon: const Icon(Icons.add_home_rounded,
                      color: AppColors.primaryGreen),
                  label: const Text('Thêm nhà trọ mới',
                      style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_currentProperty == null) {
      return const Scaffold(
          body: Center(child: Text("Lỗi tải dữ liệu nhà trọ")));
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedBottomIndex,
        children: [
          _buildHomeContent(),
          const TasksView(),
          const TenantFindingView(),
          MoreView(property: _currentProperty),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return Column(
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
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 8),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.home_work, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _showPropertySwitchSheet(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Nhà trọ: ${_currentProperty!.name}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 18),
                    ],
                  ),
                  Text(_currentProperty!.address ?? "Chưa có địa chỉ",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: 'Quét CCCD',
            onPressed: () => _handleScanQr(context),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            tooltip: 'Đổi nhà trọ',
            onPressed: () => _showPropertySwitchSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 48,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
          decoration: BoxDecoration(
              color: active ? AppColors.primaryGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: active ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    color: active ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13))
          ]),
        ),
      ),
    );
  }

  Widget _buildManagementTab() {
    final List<Map<String, dynamic>> modules = [
      {
        "t": "Quản lý phòng",
        "i": Icons.meeting_room,
        "c": AppColors.bookedBlue,
        "onTap": () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DashboardView(property: _currentProperty!)))
      },
      {
        "t": "Cọc giữ chỗ",
        "i": Icons.handshake,
        "c": AppColors.accentAmber,
        "onTap": () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SelectableBookingRoomsView(
                    propertyId: _currentProperty!.id)))
      },
      {
        "t": "Lập hợp đồng mới",
        "i": Icons.assignment_add,
        "c": AppColors.primaryGreen,
        "onTap": () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SelectableContractRoomsView(
                    propertyId: _currentProperty!.id)))
      },
      {
        "t": "Hóa đơn / Thu tiền",
        "i": Icons.receipt_long,
        "c": AppColors.paidGreen,
        "onTap": () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => InvoiceListView(property: _currentProperty!)))
      },
      {
        "t": "Thanh lý / Trả phòng",
        "i": Icons.exit_to_app,
        "c": AppColors.unpaidRed,
        "onTap": () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    SelectableCheckoutRoomsView(property: _currentProperty!)))
      },
      {
        "t": "Quản lý tài sản",
        "i": Icons.inventory_2,
        "c": AppColors.muted,
        "onTap": () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    AssetManagementView(property: _currentProperty!)))
      },
      {
        "t": "Quản lý sự cố",
        "i": Icons.build_circle,
        "c": AppColors.maintenanceGray,
        "onTap": () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const IssueManagementView()))
      },
      {
        "t": "Sổ quỹ / Thu chi",
        "i": Icons.account_balance_wallet,
        "c": AppColors.primaryGreen,
        "onTap": () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FinanceView()))
      },
      {
        "t": "Cài đặt & Zalo",
        "i": Icons.settings_suggest,
        "c": AppColors.muted,
        "onTap": () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SettingsView()))
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35),
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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.muted.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (mod['c'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(mod['i'], color: mod['c'], size: 25),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(mod['t'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return BlocBuilder<InvoiceBloc, InvoiceState>(
      builder: (context, invoiceState) {
        return BlocBuilder<RoomBloc, RoomState>(
          builder: (context, roomState) {
            int unpaidCount = 0;
            double unpaidTotal = 0;
            if (invoiceState is InvoiceLoaded) {
              final unpaidInvoices = invoiceState.invoices
                  .where((i) => i.invoice.status == 'UNPAID')
                  .toList();
              unpaidCount = unpaidInvoices.length;
              unpaidTotal = unpaidInvoices.fold<double>(
                  0, (sum, i) => sum + i.invoice.totalAmount);
            }

            int occupiedCount = 0;
            int vacantCount = 0;
            if (roomState is RoomLoaded) {
              occupiedCount = roomState.rooms
                  .where((r) => r.status != RoomStatus.AVAILABLE)
                  .length;
              vacantCount = roomState.rooms
                  .where((r) => r.status == RoomStatus.AVAILABLE)
                  .length;
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (_currentProperty != null) {
                  context
                      .read<RoomBloc>()
                      .add(FetchDashboardData(_currentProperty!.id));
                  context
                      .read<InvoiceBloc>()
                      .add(FetchInvoices(_currentProperty!.id));
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSmartReminders(unpaidCount),
                  const SizedBox(height: 16),
                  OccupancyPieChartWidget(
                    occupiedCount: occupiedCount > 0 || vacantCount > 0
                        ? occupiedCount
                        : null,
                    vacantCount: occupiedCount > 0 || vacantCount > 0
                        ? vacantCount
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const RevenueChartWidget(),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    "Nợ tiền cần thu",
                    unpaidTotal > 0
                        ? AppFormatters.formatCurrency(unpaidTotal)
                        : "0 đ (Đã thu đủ)",
                    AppColors.primaryGreen,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                InvoiceListView(property: _currentProperty!))),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSmartReminders(int unpaidCount) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildReminderCard(
            "$unpaidCount",
            "Hóa đơn chưa thu",
            unpaidCount > 0 ? AppColors.unpaidRed : AppColors.muted,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        InvoiceListView(property: _currentProperty!))),
          ),
          const SizedBox(width: 12),
          _buildReminderCard(
            "1",
            "Hợp đồng sắp hết",
            AppColors.accentAmber,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DashboardView(property: _currentProperty!))),
          ),
          const SizedBox(width: 12),
          _buildReminderCard(
            "3",
            "Yêu cầu sửa chữa",
            AppColors.primaryGreen,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const IssueManagementView())),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(String count, String label, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
          ],
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            Row(
              children: [
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color)),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: color, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedBottomIndex,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.grayText,
      onTap: (index) => setState(() => _selectedBottomIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined), label: "Công việc"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm khách"),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Thêm"),
      ],
    );
  }
}
