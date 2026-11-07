import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../room/presentation/bloc/room_bloc.dart';
import '../../../room/presentation/bloc/room_event.dart';
import '../../../room/presentation/bloc/room_state.dart';
import '../../../room/data/models/room_model.dart';
import 'package:nhatro_management/features/room/presentation/views/add_room_view.dart';
import 'create_contract_view.dart';

/// Màn hình chọn phòng trống để Lập hợp đồng mới
class SelectableContractRoomsView extends StatefulWidget {
  final int propertyId;

  const SelectableContractRoomsView({super.key, this.propertyId = 1});

  @override
  State<SelectableContractRoomsView> createState() =>
      _SelectableContractRoomsViewState();
}

class _SelectableContractRoomsViewState
    extends State<SelectableContractRoomsView> {
  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(FetchRooms(widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        leading:
            const Icon(Icons.assignment_add, color: AppColors.primaryGreen),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lập hợp đồng mới',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Chọn 1 phòng trống để ký hợp đồng',
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
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          if (state is RoomLoaded) {
            final availableRooms = state.rooms
                .where((r) =>
                    r.status == RoomStatus.AVAILABLE ||
                    r.status == RoomStatus.BOOKED)
                .toList();

            if (availableRooms.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.meeting_room_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Hiện không còn phòng trống nào để ký hợp đồng.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 15, color: AppColors.grayText),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AddRoomView()))
                              .then((_) {
                            if (!mounted) return;
                            context
                                .read<RoomBloc>()
                                .add(FetchRooms(widget.propertyId));
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Tạo phòng trống ngay",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    ],
                  ),
                ),
              );
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
          return const Center(child: Text('Không thể tải danh sách phòng'));
        },
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomModel room) {
    final isBooked = room.status == RoomStatus.BOOKED;
    final statusColor = isBooked ? const Color(0xFF2F80ED) : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isBooked ? const Color(0xFFEAF3FF) : const Color(0xFFFFEEEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isBooked
                ? Icons.bookmark_added_rounded
                : Icons.meeting_room_rounded,
            color: statusColor,
            size: 24,
          ),
        ),
        title: Text(
          'Phòng ${room.roomNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Giá thuê: ${AppFormatters.formatCurrency(room.basePrice)}/tháng',
                    style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isBooked
                        ? const Color(0xFFEAF3FF)
                        : const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isBooked ? 'ĐÃ CỌC' : 'CHƯA CỌC',
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              room.status == RoomStatus.BOOKED
                  ? 'Đã cọc giữ chỗ • ${AppFormatters.formatCurrency(room.depositDefault)} cọc chuẩn'
                  : 'Tiền cọc: ${AppFormatters.formatCurrency(room.depositDefault)}',
              style: const TextStyle(color: AppColors.grayText, fontSize: 12),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreateContractView(room: room)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isBooked ? const Color(0xFF2F80ED) : AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Ký HĐ',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
