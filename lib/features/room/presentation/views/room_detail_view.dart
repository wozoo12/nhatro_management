import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/room_model.dart';
import 'room_checkout_view.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/models/room_dashboard_model.dart';

class RoomDetailView extends StatefulWidget {
  final RoomModel room;
  const RoomDetailView({super.key, required this.room});

  @override
  State<RoomDetailView> createState() => _RoomDetailViewState();
}

class _RoomDetailViewState extends State<RoomDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Chi tiết phòng",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Phòng ${widget.room.roomNumber} - #${widget.room.id}",
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "THÔNG TIN"),
            Tab(text: "HÓA ĐƠN"),
            Tab(text: "VIỆC CẦN LÀM"),
            Tab(text: "LỊCH SỬ"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildInvoiceTab(),
          _buildTasksTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 1. Mã kết nối App khách
          _buildConnectionCard(),
          const SizedBox(height: 16),

          // 2. Trạng thái nợ
          _buildStatusCard(
            color: AppColors.alertOrange,
            icon: Icons.notifications_active_outlined,
            title: "Tổng số tiền khách thuê đang nợ là:",
            content: AppFormatters.formatCurrency(3924000),
            actionLabel: "Xem hợp đồng",
            textColor: Colors.black,
          ),
          const SizedBox(height: 16),

          // 3. Thông tin phòng
          _buildGeneralInfoCard(),
          const SizedBox(height: 16),

          // 4. Dịch vụ đang dùng
          _buildServicesCard(),
          const SizedBox(height: 16),

          // 5. Danh sách khách thuê
          _buildTenantSection(),
          const SizedBox(height: 16),

          // 6. Quản lý phương tiện
          _buildVehicleSection(),

          const SizedBox(height: 32),
          // Danger Zone
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showCheckoutMenu(context),
              icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white),
              label: const Text("Thanh lý / Trả phòng",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.mintBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text("Mã kết nối phòng - Dành cho app khách",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Spacer(),
              Icon(Icons.help_outline, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text("C5067P22961",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text("Sao chép",
                          style: TextStyle(fontSize: 12))),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share, size: 14),
                      label: const Text("Chia sẻ",
                          style: TextStyle(fontSize: 12))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      {required Color color,
      required IconData icon,
      required String title,
      required String content,
      String? actionLabel,
      Color? textColor}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4))),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.grayText)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.assignment_outlined, size: 18),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGrayBg,
                    foregroundColor: Colors.black87,
                    elevation: 0),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildGeneralInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Thông tin phòng",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: AppColors.blueCTA),
                  onPressed: () {}),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(
              "Tên phòng", "Phòng ${widget.room.roomNumber}", "Nhóm", "Khu A"),
          const Divider(height: 24),
          _infoRow(
              "Giá thuê",
              AppFormatters.formatCurrency(widget.room.basePrice),
              "Diện tích",
              "${widget.room.area} m2"),
          const Divider(height: 24),
          _infoRow("Giới tính", "Tất cả", "Lập hóa đơn", "Ngày 1"),
        ],
      ),
    );
  }

  Widget _infoRow(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l1, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(v1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
        ])),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l2, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(v2,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.orange))
        ])),
      ],
    );
  }

  Widget _buildServicesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Dịch vụ của phòng đang sử dụng",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _serviceItem("Tiền điện", "3.500 đ/KWh", "Số hiện tại: 25170799"),
          const Divider(),
          _serviceItem("Tiền nước", "18.000 đ/Khối", "Số hiện tại: 21459"),
          const Divider(),
          _serviceItem("Tiền wifi", "50.000 đ/Tháng", "1 Tháng"),
          const Divider(),
          _serviceItem("Tiền rác", "20.000 đ/Tháng", "1 Tháng"),
        ],
      ),
    );
  }

  Widget _serviceItem(String name, String price, String current) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(price,
                style: const TextStyle(color: Colors.grey, fontSize: 11))
          ]),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.mintBg,
                  borderRadius: BorderRadius.circular(4)),
              child: Text(current,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTenantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DANH SÁCH KHÁCH THUÊ",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.grayText,
                fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
                backgroundColor: AppColors.mintBg,
                child: Icon(Icons.person, color: AppColors.primaryGreen)),
            title: const Text("Nguyễn Minh Thư",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text("#SĐT: 0349-494-642 • #ID: 987412580",
                style: TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.more_vert, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("QUẢN LÝ PHƯƠNG TIỆN",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.grayText,
                fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              const Icon(Icons.directions_bike_rounded,
                  size: 48, color: AppColors.mintBg),
              const SizedBox(height: 8),
              const Text("Chưa có phương tiện nào được thêm",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Thêm phương tiện")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text("T.${3 - i}/2023",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text("Phòng ${widget.room.roomNumber} (07/03/2023)",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text("Thu tiền hàng tháng",
                          style: TextStyle(color: Colors.grey, fontSize: 11))
                    ])),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _invoiceSum("Tổng số", "3.924.000 đ"),
                _invoiceSum("Đã trả", "0 đ"),
                _invoiceSum("Còn lại", "3.924.000 đ", isRed: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceSum(String label, String value, {bool isRed = false}) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isRed ? Colors.red : Colors.black))
    ]);
  }

  Widget _buildTasksTab() {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _taskItem("Sửa bóng đèn", "07/03/2023", false),
          _taskItem("Thông cống nghẹt", "05/03/2023", true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primaryGreen,
          child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  Widget _taskItem(String title, String date, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
              left: BorderSide(
                  color: isDone ? AppColors.primaryGreen : AppColors.dangerRed,
                  width: 4))),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(children: [
          const Icon(Icons.access_time, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(date, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 8),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: isDone ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4)),
              child: Text(isDone ? "Đã xong" : "Chưa xong",
                  style: TextStyle(
                      fontSize: 10,
                      color: isDone ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold)))
        ]),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded,
              size: 80, color: AppColors.primaryGreen),
          const SizedBox(height: 16),
          const Text("Hiện tại chưa có lịch sử nào được ghi nhận",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 32),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                Text("Bạn có thể khám phá được gì ở chức năng này ?",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    "Hệ thống sẽ ghi lại mọi biến động như: Lập hợp đồng, chốt điện nước, thay đổi giá, đổi trạng thái phòng...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showCheckoutMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Thanh lý / Kết thúc hợp đồng",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ListTile(
            leading: const Icon(Icons.notification_important_outlined,
                color: Colors.orange),
            title: const Text("Báo rời đi (Khách báo trước)"),
            onTap: () => Navigator.pop(ctx),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app_rounded,
                color: AppColors.dangerRed),
            title: const Text("Kết thúc hợp đồng ngay"),
            onTap: () {
              Navigator.pop(ctx);
              _openCheckout(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _openCheckout(BuildContext context) async {
    try {
      final data = await context
          .read<RoomRepository>()
          .getDashboardRooms(widget.room.propertyId);
      RoomDashboardModel? room;
      for (final item in data) {
        if (item.room.id == widget.room.id) {
          room = item;
          break;
        }
      }
      if (!context.mounted) return;
      if (room?.contract == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Phòng này chưa có hợp đồng đang thuê.')));
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RoomCheckoutView(
                    roomId: widget.room.id,
                    contractId: room!.contract!.id,
                    propertyId: widget.room.propertyId,
                    roomNumber: widget.room.roomNumber,
                    deposit: room.contract!.actualDeposit,
                    roomPrice: widget.room.basePrice,
                  )));
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tải được hợp đồng: $e')));
    }
  }
}
