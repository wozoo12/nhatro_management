import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/room_model.dart';
import '../bloc/room_bloc.dart';
import '../bloc/room_event.dart';
import '../bloc/room_state.dart';
import 'room_detail_view.dart';
import 'room_group_management_view.dart';
import 'add_room_view.dart';

class RoomGridView extends StatefulWidget {
  final int propertyId;
  const RoomGridView({super.key, required this.propertyId});

  @override
  State<RoomGridView> createState() => _RoomGridViewState();
}

class _RoomGridViewState extends State<RoomGridView> with SingleTickerProviderStateMixin {
  late TabController _floorTabController;
  RoomStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _floorTabController = TabController(length: 3, vsync: this);
    context.read<RoomBloc>().add(FetchRooms(widget.propertyId));
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Lọc trạng thái phòng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _filterOption("Tất cả phòng", null),
            _filterOption("Phòng trống", RoomStatus.AVAILABLE),
            _filterOption("Đang ở", RoomStatus.OCCUPIED),
            _filterOption("Đang cọc", RoomStatus.BOOKED),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _filterOption(String title, RoomStatus? status) {
    return ListTile(
      title: Text(title),
      trailing: _filterStatus == status ? const Icon(Icons.check_circle, color: AppColors.primaryGreen) : null,
      onTap: () {
        setState(() => _filterStatus = status);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("Danh sách phòng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          // KẾT NỐI MÀN HÌNH QUẢN LÝ NHÓM TẦNG/KHU
          IconButton(
            icon: const Icon(Icons.settings_outlined), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomGroupManagementView()))
          ),
          IconButton(icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryGreen), onPressed: _showFilterBottomSheet),
        ],
        bottom: TabBar(
          controller: _floorTabController,
          isScrollable: true,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Tất cả"),
            Tab(text: "Tầng trệt"),
            Tab(text: "Tầng 1"),
          ],
        ),
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) return const Center(child: CircularProgressIndicator());
          if (state is RoomLoaded) {
            final rooms = _filterStatus == null 
                ? state.rooms 
                : state.rooms.where((r) => r.status == _filterStatus).toList();

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) => _buildRoomCard(context, rooms[index]),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRoomView())),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomModel room) {
    Color statusColor;
    String statusText;
    
    switch (room.status) {
      case RoomStatus.OCCUPIED:
        statusColor = AppColors.primaryGreen;
        statusText = "Đang ở";
        break;
      case RoomStatus.BOOKED:
        statusColor = Colors.orange;
        statusText = "Đang cọc";
        break;
      default:
        statusColor = AppColors.alertOrange;
        statusText = "Phòng trống";
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailView(room: room))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("P.${room.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Icon(room.status == RoomStatus.OCCUPIED ? Icons.person : Icons.meeting_room_outlined, size: 18, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppFormatters.formatCurrency(room.basePrice),
                    style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("${room.area} m2", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
