import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_bloc.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_event.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_state.dart';
import 'package:nhatro_management/features/room/data/models/property_model.dart';
import 'package:nhatro_management/features/room/data/models/room_model.dart';
import 'package:nhatro_management/features/room/data/models/room_dashboard_model.dart';
import 'package:nhatro_management/features/room/presentation/widgets/electricity_reading_dialog.dart';
import 'package:nhatro_management/features/room/presentation/widgets/invoice_preview_dialog.dart';
import 'package:nhatro_management/features/tenant/presentation/views/tenant_list_view.dart';
import 'package:nhatro_management/features/tenant/presentation/views/create_contract_view.dart';

/// [DashboardView] hiển thị dữ liệu thực tế từ Database thông qua RoomBloc.
class DashboardView extends StatefulWidget {
  final PropertyModel property;

  const DashboardView({super.key, required this.property});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  static const Color primaryBlue = Color(0xFF2E7D32);
  static const Color accentBlue = Color(0xFF4CAF50);
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color mutedText = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color successGreenBg = Color(0xFFDCFCE7);
  static const Color successGreenText = Color(0xFF15803D);
  static const Color alertRed = Color(0xFFDC2626);
  static const Color alertRedBg = Color(0xFFFEF2F2);
  static const Color alertRedText = Color(0xFFB91C1C);

  final currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    context.read<RoomBloc>().add(FetchDashboardData(widget.property.id));
  }

  void _showAddRoomDialog() {
    final numberController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm phòng mới',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: numberController,
                decoration:
                    const InputDecoration(labelText: 'Số phòng (VD: 101)'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập số phòng' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration:
                    const InputDecoration(labelText: 'Giá thuê / tháng'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter()
                ],
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập giá thuê' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newRoom = RoomModel(
                  id: 0,
                  propertyId: widget.property.id,
                  roomNumber: numberController.text,
                  basePrice: double.parse(
                      priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
                  area: 0,
                  depositDefault: 0,
                  elecRate: 4000,
                  waterRate: 15000,
                  status: RoomStatus.AVAILABLE,
                  createdAt: DateTime.now(),
                );
                context.read<RoomBloc>().add(AddRoom(newRoom));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Thêm phòng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.property.name,
            style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const Center(
                child: CircularProgressIndicator(color: primaryBlue));
          }

          if (state is RoomError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.message}', textAlign: TextAlign.center),
                  ElevatedButton(
                      onPressed: _refreshData, child: const Text('Thử lại')),
                ],
              ),
            );
          }

          if (state is RoomLoaded) {
            final rooms = state.dashboardRooms;
            final filteredRooms = _getFilteredRooms(rooms);

            return RefreshIndicator(
              color: primaryBlue,
              onRefresh: () async => _refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildStatsGrid(rooms),
                          const SizedBox(height: 20),
                          _buildFormulaBanner(),
                          const SizedBox(height: 16),
                          _buildUrgentAlert(rooms),
                          const SizedBox(height: 20),
                          _buildFilterTabs(rooms),
                          const SizedBox(height: 16),
                          ...filteredRooms
                              .map((data) => _buildRoomCard(context, data)),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<RoomDashboardModel> _getFilteredRooms(
      List<RoomDashboardModel> allRooms) {
    if (_selectedTabIndex == 1)
      return allRooms.where((r) => r.contract != null).toList();
    if (_selectedTabIndex == 2)
      return allRooms.where((r) => r.invoice?.status == 'UNPAID').toList();
    if (_selectedTabIndex == 3)
      return allRooms.where((r) => r.contract == null).toList();
    return allRooms;
  }

  void _handleElectricityReading(
      BuildContext context, RoomDashboardModel data) async {
    final int? newReading = await showDialog<int>(
      context: context,
      builder: (context) => ElectricityReadingDialog(
        roomNumber: data.room.roomNumber,
        tenantName: data.tenant?.fullName ?? 'Phòng trống',
        previousReading: data.lastReading?.newElec ?? 0,
        elecRate: data.room.elecRate,
        roomPrice: data.room.basePrice,
      ),
    );

    if (newReading == null || data.contract == null) return;
    if (!mounted) return;

    context.read<RoomBloc>().add(SaveElectricityReading(
          roomId: data.room.id,
          contractId: data.contract!.id,
          oldElec: data.lastReading?.newElec ?? 0,
          newElec: newReading,
          elecRate: data.room.elecRate,
          roomCharge: data.room.basePrice,
          monthYear: DateFormat('yyyy-MM').format(DateTime.now()),
          propertyId: widget.property.id,
        ));
  }

  void _openInvoiceDialog(BuildContext context, RoomDashboardModel data) {
    if (data.invoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Chưa có hóa đơn! Hãy chốt điện trước.')));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => InvoicePreviewDialog(
        roomNumber: data.room.roomNumber,
        tenantName: data.tenant?.fullName ?? '---',
        phoneNumber: data.tenant?.phone ?? '---',
        monthYear: data.invoice!.monthYear,
        dueDate: 'Ngày 5 hàng tháng',
        roomRent: data.invoice!.roomCharge,
        serviceFee: 100000,
        elecUsage: (data.invoice!.elecCharge / data.room.elecRate).round(),
        elecRate: data.room.elecRate,
        elecBefore: data.lastReading?.oldElec ?? 0,
        elecAfter: data.lastReading?.newElec ?? 0,
        invoiceId: data.invoice!.id,
        propertyId: widget.property.id,
        status: data.invoice!.status,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: primaryBlue),
            currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: primaryBlue, size: 40)),
            accountName: const Text('Quản Trị Viên',
                style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(widget.property.name),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: primaryBlue),
            title: const Text('Bảng điều khiển',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_rounded),
            title: const Text('Quản lý Khách thuê'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TenantListView()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          IconButton(
              icon:
                  const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer()),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.property.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(widget.property.address ?? 'Chưa cập nhật địa chỉ',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white, size: 28),
              onPressed: _showAddRoomDialog),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(List<RoomDashboardModel> rooms) {
    final int total = rooms.length;
    final int occupied = rooms.where((r) => r.contract != null).length;
    double paid = 0;
    double unpaid = 0;
    for (var r in rooms) {
      if (r.invoice != null) {
        if (r.invoice!.status == 'PAID') {
          paid += r.invoice!.totalAmount;
        } else {
          unpaid += r.invoice!.totalAmount;
        }
      }
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _statCard('Tổng phòng', '$occupied/$total', 'phòng đang ở',
            Icons.home_rounded, Colors.grey.shade100),
        _statCard('Đã thu', currencyFormat.format(paid), 'Tháng này',
            Icons.check_circle_outline, successGreenBg,
            iconColor: successGreen),
        _statCard('Chưa thu', currencyFormat.format(unpaid), 'Tiền nợ',
            Icons.warning_amber_rounded, alertRedBg,
            iconColor: alertRed),
        _statCard('Phòng trống', '${total - occupied}', 'sẵn sàng thuê',
            Icons.vpn_key_outlined, const Color(0xFFFEF9C3),
            iconColor: Colors.orange),
      ],
    );
  }

  Widget _statCard(String t, String v, String s, IconData i, Color b,
      {Color iconColor = primaryBlue}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: b, borderRadius: BorderRadius.circular(8)),
              child: Icon(i, size: 16, color: iconColor)),
          const SizedBox(width: 8),
          Text(t,
              style: const TextStyle(
                  fontSize: 11, color: mutedText, fontWeight: FontWeight.w500))
        ]),
        const Spacer(),
        Text(v,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(s, style: const TextStyle(fontSize: 9, color: mutedText)),
      ]),
    );
  }

  Widget _buildFormulaBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16)),
      child:
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📋 CÔNG THỨC TÍNH TIỀN MỖI PHÒNG',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: mutedText)),
        SizedBox(height: 8),
        Text('Tiền phòng + Rác/Nước (100k) + Số điện x 4.000đ',
            style: TextStyle(fontSize: 12, color: Colors.black87)),
      ]),
    );
  }

  Widget _buildUrgentAlert(List<RoomDashboardModel> rooms) {
    final unpaid = rooms.where((r) => r.invoice?.status == 'UNPAID').toList();
    if (unpaid.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: alertRedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA))),
      child: Row(children: [
        const Icon(Icons.campaign_rounded, color: alertRed, size: 28),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Có phòng chưa đóng tiền!',
              style: TextStyle(
                  color: alertRed, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(
              'P.${unpaid.map((e) => e.room.roomNumber).join(", ")} — Vui lòng nhắc khách.',
              style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 11))
        ]))
      ]),
    );
  }

  Widget _buildFilterTabs(List<RoomDashboardModel> rooms) {
    final tabs = [
      {'label': 'Tất cả', 'count': rooms.length},
      {
        'label': 'Đang ở',
        'count': rooms.where((r) => r.contract != null).length
      },
      {'label': 'Trống', 'count': rooms.where((r) => r.contract == null).length}
    ];
    return SizedBox(
        height: 38,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = index),
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: _selectedTabIndex == index
                            ? primaryBlue
                            : cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: _selectedTabIndex == index
                            ? null
                            : Border.all(color: Colors.grey.shade200)),
                    child: Text(
                        '${tabs[index]['label']} ${tabs[index]['count']}',
                        style: TextStyle(
                            color: _selectedTabIndex == index
                                ? Colors.white
                                : mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.bold))))));
  }

  Widget _buildRoomCard(BuildContext context, RoomDashboardModel data) {
    final bool hasTenant = data.tenant != null;
    final bool isPaid = data.invoice?.status == 'PAID';
    final bool isUnpaid = data.invoice?.status == 'UNPAID';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Phòng ${data.room.roomNumber}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('👤 ${data.tenant?.fullName ?? "Chưa có người thuê"}',
                style: const TextStyle(color: mutedText, fontSize: 13))
          ]),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: isUnpaid
                      ? alertRedBg
                      : (hasTenant
                          ? const Color(0xFFF0F9FF)
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                  isUnpaid
                      ? '🔴 Còn nợ tiền'
                      : (hasTenant ? '🔵 Đang ở' : '⚪ Trống'),
                  style: TextStyle(
                      color: isUnpaid
                          ? alertRed
                          : (hasTenant ? const Color(0xFF1D4ED8) : mutedText),
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
        ]),
        const Divider(height: 24, thickness: 0.5),
        _detailRow(
            'Tiền thuê phòng', currencyFormat.format(data.room.basePrice)),
        _detailRow('🗑️ Rác + 💧 Nước', currencyFormat.format(100000)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('⚡ Điện',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            if (hasTenant)
              Text(
                  '${data.lastReading?.newElec ?? 0} số (Số cũ: ${data.lastReading?.oldElec ?? 0})',
                  style: const TextStyle(fontSize: 10, color: mutedText))
          ]),
          Text(currencyFormat.format(data.invoice?.elecCharge ?? 0),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: accentBlue, borderRadius: BorderRadius.circular(8)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng cộng tháng này',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text(currencyFormat.format(data.invoice?.totalAmount ?? 0),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))
                ])),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (hasTenant && data.invoice != null) _paymentBadge(isPaid),
          Text('📝 HĐ: ${data.contract?.status ?? "---"}',
              style: const TextStyle(
                  color: mutedText, fontSize: 11, fontStyle: FontStyle.italic))
        ]),
        const SizedBox(height: 16),
        Row(children: [
          if (hasTenant) ...[
            Expanded(
                child: _actionBtn(
                    Icons.flash_on_rounded,
                    'Chốt điện',
                    accentBlue,
                    () => _handleElectricityReading(context, data))),
            const SizedBox(width: 12),
            Expanded(
                child: _actionBtn(Icons.description_outlined, 'Xem hóa đơn',
                    darkNavy, () => _openInvoiceDialog(context, data))),
          ] else ...[
            Expanded(
                child: _actionBtn(
                    Icons.add_task_rounded, 'Cho thuê / Ký HĐ', primaryBlue,
                    () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CreateContractView(room: data.room)));
            })),
          ],
        ]),
      ]),
    );
  }

  Widget _paymentBadge(bool isPaid) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: isPaid ? successGreenBg : alertRedBg,
            borderRadius: BorderRadius.circular(6)),
        child: Row(children: [
          Icon(isPaid ? Icons.check_rounded : Icons.close_rounded,
              size: 14, color: isPaid ? successGreenText : alertRedText),
          const SizedBox(width: 4),
          Text(isPaid ? 'Đã thanh toán' : 'Chưa thanh toán',
              style: TextStyle(
                  color: isPaid ? successGreenText : alertRedText,
                  fontSize: 11,
                  fontWeight: FontWeight.bold))
        ]));
  }

  Widget _detailRow(String l, String v) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l, style: const TextStyle(fontSize: 14)),
          Text(v,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
        ]));
  }

  Widget _actionBtn(IconData i, String l, Color c, VoidCallback onTap) {
    return ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: c,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0),
        icon: Icon(i, size: 18),
        label: Text(l,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)));
  }
}
