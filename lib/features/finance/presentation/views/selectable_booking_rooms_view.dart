import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../room/presentation/bloc/room_bloc.dart';
import '../../../room/presentation/bloc/room_event.dart';
import '../../../room/presentation/bloc/room_state.dart';
import '../../../room/data/models/room_dashboard_model.dart';
import '../../../room/data/models/room_model.dart';
import 'add_deposit_view.dart';

/// [SelectableBookingRoomsView] hiển thị danh sách phòng TRỐNG có thể "Cọc giữ chỗ".
/// Fix Bug: Đọc từ dashboardRooms (dữ liệu thật từ Supabase) thay vì rooms (luôn rỗng).
class SelectableBookingRoomsView extends StatefulWidget {
  final int propertyId;
  const SelectableBookingRoomsView({super.key, required this.propertyId});

  @override
  State<SelectableBookingRoomsView> createState() =>
      _SelectableBookingRoomsViewState();
}

class _SelectableBookingRoomsViewState
    extends State<SelectableBookingRoomsView> {
  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(FetchDashboardData(widget.propertyId));
  }

  Future<void> _openDeposit(RoomDashboardModel data) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AddDepositView(
              roomNumber: data.room.roomNumber, roomId: data.room.id)),
    );
    if (mounted)
      context.read<RoomBloc>().add(FetchDashboardData(widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        leading: const Icon(Icons.list_alt_rounded),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Danh sách có thể 'Cọc giữ chỗ'",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Chọn 1 phòng để thực hiện",
                style: TextStyle(fontSize: 12, color: AppColors.grayText)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RoomLoaded) {
            // FIX: Lọc từ dashboardRooms (dữ liệu thật) — phòng trống = contract == null
            final availableRooms = state.dashboardRooms
                .where((d) =>
                    d.contract == null && d.room.status == RoomStatus.AVAILABLE)
                .toList();

            if (availableRooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      "Không còn phòng trống để cọc.",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tất cả phòng đang có khách thuê.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableRooms.length,
              itemBuilder: (context, index) {
                final data = availableRooms[index];
                return _buildRoomCard(context, data);
              },
            );
          }

          // State is RoomInitial hoặc RoomError → hiển thị thông báo phù hợp
          if (state is RoomError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return const Center(child: Text("Đang tải dữ liệu..."));
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Đóng thao tác",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomDashboardModel data) {
    final room = data.room;
    return GestureDetector(
      onTap: () => _openDeposit(data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: const Border(
              left: BorderSide(color: AppColors.blueCTA, width: 6)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.blueCTA.withValues(alpha: 0.08),
                  shape: BoxShape.circle),
              child: const Icon(Icons.home_outlined,
                  size: 28, color: AppColors.blueCTA),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phòng ${room.roomNumber}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                      "Giá thuê: ${AppFormatters.formatCurrency(room.basePrice)}/tháng",
                      style: const TextStyle(
                          color: AppColors.grayText, fontSize: 13)),
                  Text(
                      "Cọc mặc định: ${AppFormatters.formatCurrency(room.depositDefault)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
