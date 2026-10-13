import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../room/presentation/bloc/room_bloc.dart';
import '../../../room/presentation/bloc/room_state.dart';
import '../../../room/data/models/room_model.dart';
import 'add_deposit_view.dart';

class SelectableBookingRoomsView extends StatelessWidget {
  const SelectableBookingRoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        leading: const Icon(Icons.list_alt_rounded),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Danh sách có thể 'Cọc giữ chỗ'", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Chọn 1 phòng để thực hiện", style: TextStyle(fontSize: 12, color: AppColors.grayText)),
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
            final availableRooms = state.rooms.where((r) => r.status == RoomStatus.AVAILABLE).toList();
            
            if (availableRooms.isEmpty) {
              return const Center(child: Text("Không còn phòng trống để cọc."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableRooms.length,
              itemBuilder: (context, index) {
                final room = availableRooms[index];
                return _buildRoomCard(context, room);
              },
            );
          }
          return const Center(child: Text("Không thể tải danh sách phòng"));
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Đóng thao tác", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomModel room) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddDepositView(roomNumber: room.roomNumber)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: Colors.orange, width: 6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.home_outlined, size: 40, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phòng ${room.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Giá thuê: ${AppFormatters.formatCurrency(room.basePrice)}", style: const TextStyle(color: AppColors.grayText, fontSize: 13)),
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
