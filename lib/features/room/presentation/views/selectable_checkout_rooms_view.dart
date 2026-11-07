import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/core/utils/formatters.dart';
import 'package:nhatro_management/features/room/data/models/property_model.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_bloc.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_event.dart';
import 'package:nhatro_management/features/room/presentation/bloc/room_state.dart';
import 'package:nhatro_management/features/room/presentation/views/room_checkout_view.dart';

/// Màn hình chọn phòng đang thuê để làm thủ tục Thanh lý / Trả phòng
class SelectableCheckoutRoomsView extends StatefulWidget {
  final PropertyModel property;

  const SelectableCheckoutRoomsView({super.key, required this.property});

  @override
  State<SelectableCheckoutRoomsView> createState() =>
      _SelectableCheckoutRoomsViewState();
}

class _SelectableCheckoutRoomsViewState
    extends State<SelectableCheckoutRoomsView> {
  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(FetchDashboardData(widget.property.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thanh lý / Trả phòng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Chọn phòng đang thuê để kết thúc hợp đồng',
                style: TextStyle(fontSize: 11, color: AppColors.grayText)),
          ],
        ),
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryGreen));
          }

          if (state is RoomLoaded) {
            // Lọc các phòng đang có người thuê / có hợp đồng
            final occupiedRooms =
                state.dashboardRooms.where((r) => r.contract != null).toList();

            if (occupiedRooms.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.vpn_key_off_outlined,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'Hiện không có phòng nào đang thuê để làm thủ tục trả phòng.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 15, color: AppColors.grayText),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Quay lại'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: occupiedRooms.length,
              itemBuilder: (context, index) {
                final data = occupiedRooms[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoomCheckoutView(
                            roomId: data.room.id,
                            contractId: data.contract!.id,
                            propertyId: widget.property.id,
                            roomNumber: data.room.roomNumber,
                            deposit: data.contract?.actualDeposit ??
                                data.room.depositDefault,
                            roomPrice: data.room.basePrice,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.dangerRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.exit_to_app_rounded,
                                  color: AppColors.dangerRed, size: 26),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Phòng ${data.room.roomNumber}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.navyText),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('Đang thuê',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.primaryGreen,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '👤 Khách: ${data.tenant?.fullName ?? "Chưa có thông tin"}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.grayText),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tiền phòng: ${AppFormatters.formatCurrency(data.room.basePrice)} • Cọc: ${AppFormatters.formatCurrency(data.contract?.actualDeposit ?? data.room.depositDefault)}',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.grayText),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
