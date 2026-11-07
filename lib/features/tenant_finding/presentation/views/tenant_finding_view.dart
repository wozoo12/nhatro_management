import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/core/utils/formatters.dart';
import 'package:nhatro_management/core/utils/zalo_service.dart';
import 'package:nhatro_management/features/tenant_finding/data/models/lead_model.dart';
import '../cubit/tenant_finding_cubit.dart';
import '../cubit/tenant_finding_state.dart';
import 'widgets/add_lead_bottom_sheet.dart';

class TenantFindingView extends StatelessWidget {
  const TenantFindingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TenantFindingCubit(),
      child: const _TenantFindingContent(),
    );
  }
}

class _TenantFindingContent extends StatelessWidget {
  const _TenantFindingContent();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBg,
        appBar: AppBar(
          title: const Text('Tìm khách & Lấp đầy phòng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: AppColors.grayText,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.campaign_rounded), text: 'Đăng tin phòng trống'),
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'Khách tiềm năng'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListingMarketingTab(),
            _LeadsManagementTab(),
          ],
        ),
      ),
    );
  }
}

/// TAB 1: ĐĂNG TIN PHÒNG TRỐNG & MARKETING
class _ListingMarketingTab extends StatelessWidget {
  const _ListingMarketingTab();

  @override
  Widget build(BuildContext context) {
    // Dữ liệu phòng trống thực tế
    final vacantRooms = [
      {
        'room': '102',
        'area': '25 m²',
        'price': 3500000.0,
        'features': ['Gác lửng cao', 'Máy lạnh', 'Kệ bếp', 'Giờ giấc tự do'],
      },
      {
        'room': '204',
        'area': '22 m²',
        'price': 3200000.0,
        'features': ['Ban công thoáng', 'Cửa sổ lớn', 'Wifi riêng', 'Camera an ninh'],
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildVacancyBanner(vacantRooms.length),
        const SizedBox(height: 16),
        const Text(
          'Danh sách phòng trống có thể cho thuê',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navyText),
        ),
        const SizedBox(height: 12),
        ...vacantRooms.map((r) => _buildRoomListingCard(context, r)),
      ],
    );
  }

  Widget _buildVacancyBanner(int vacantCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.meeting_room_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$vacantCount phòng trống chờ khách',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tạo và chia sẻ bài đăng để tìm khách thuê nhanh chóng.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomListingCard(BuildContext context, Map<String, dynamic> room) {
    final roomNum = room['room'] as String;
    final area = room['area'] as String;
    final price = room['price'] as double;
    final features = room['features'] as List<String>;

    final samplePost = '🏠 CHO THUÊ PHÒNG TRỌ P.$roomNum - GIỜ GIẤC TỰ DO\n'
        '• Diện tích: $area - Sạch đẹp, thoáng mát\n'
        '• Giá thuê: ${AppFormatters.formatCurrency(price)}/tháng\n'
        '• Tiện ích: ${features.join(', ')}\n'
        '• Vị trí thuận tiện, an ninh tốt, camera 24/7\n'
        '📞 Liên hệ xem phòng ngay: 0909 123 456';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Phòng $roomNum',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.navyText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppFormatters.formatCurrency(price),
                  style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Diện tích: $area • Đang sẵn sàng vào ở', style: const TextStyle(fontSize: 12, color: AppColors.grayText)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: features.map((f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(f, style: const TextStyle(fontSize: 11, color: AppColors.navyText)),
            )).toList(),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: samplePost));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép nội dung bài đăng cho thuê!')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Sao chép tin', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Mở Zalo để chủ nhà gửi tin tới bạn bè/nhóm tìm trọ
                    ZaloService.openZaloChat('');
                  },
                  icon: const Icon(Icons.share_rounded, size: 16, color: Colors.white),
                  label: const Text('Đăng Zalo', style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueCTA,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// TAB 2: QUẢN LÝ KHÁCH THUÊ TIỀM NĂNG (LEADS CRM)
class _LeadsManagementTab extends StatelessWidget {
  const _LeadsManagementTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<TenantFindingCubit, TenantFindingState>(
        builder: (context, state) {
          if (state.status == TenantFindingStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }

          if (state.status == TenantFindingStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Đã xảy ra lỗi'));
          }

          return Column(
            children: [
              _buildFilterChips(context, state),
              Expanded(
                child: state.filteredLeads.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filteredLeads.length,
                        itemBuilder: (context, index) {
                          final lead = state.filteredLeads[index];
                          return _buildLeadCard(context, lead);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLeadBottomSheet(context),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('Thêm khách', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, TenantFindingState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      child: Row(
        children: [
          _buildChip(
            context: context,
            label: 'Tất cả (${state.leads.length})',
            isSelected: state.selectedFilter == null,
            onTap: () => context.read<TenantFindingCubit>().filterByStatus(null),
          ),
          ...LeadStatus.values.map((status) {
            final isSelected = state.selectedFilter == status;
            return _buildChip(
              context: context,
              label: status.name == 'interested' ? 'Quan tâm' : status.name == 'viewingScheduled' ? 'Hẹn xem' : status.name == 'deposited' ? 'Đã cọc' : 'Đã hủy',
              isSelected: isSelected,
              onTap: () => context.read<TenantFindingCubit>().filterByStatus(status),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primaryGreen,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryGreen : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, LeadModel lead) {
    final statusColor = _getStatusColor(lead.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                child: Text(
                  lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navyText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AppFormatters.formatPhone(lead.phone),
                      style: const TextStyle(fontSize: 12, color: AppColors.grayText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lead.statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lead.preferredRoom != null || lead.budget != null) ...[
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (lead.preferredRoom != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.meeting_room_outlined, size: 15, color: AppColors.grayText),
                      const SizedBox(width: 4),
                      Text('Phòng quan tâm: P.${lead.preferredRoom}', style: const TextStyle(fontSize: 12, color: AppColors.navyText)),
                    ],
                  ),
                if (lead.budget != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_money_rounded, size: 15, color: AppColors.grayText),
                      const SizedBox(width: 2),
                      Text('Ngân sách: ${AppFormatters.formatCurrency(lead.budget!)}', style: const TextStyle(fontSize: 12, color: AppColors.navyText)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          if (lead.appointmentDate != null) ...[
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 15, color: AppColors.blueCTA),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Lịch hẹn xem: ${AppFormatters.formatDate(lead.appointmentDate!)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.blueCTA),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          if (lead.note != null) ...[
            Text('Ghi chú: ${lead.note}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.grayText)),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.phone_rounded, color: AppColors.primaryGreen, size: 22),
                tooltip: 'Gọi điện',
                onPressed: () async {
                  final uri = Uri.parse('tel:${lead.phone}');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.blueCTA, size: 22),
                tooltip: 'Nhắn Zalo',
                onPressed: () => ZaloService.openZaloChat(lead.phone),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 22),
                tooltip: 'Xóa',
                onPressed: () => context.read<TenantFindingCubit>().deleteLead(lead.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.blueCTA.withValues(alpha: 0.1),
            child: const Icon(Icons.person_search_rounded, color: AppColors.blueCTA, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có khách thuê nào!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyText),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bấm "Thêm khách" để lưu lại thông tin người hỏi phòng.',
            style: TextStyle(fontSize: 13, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }

  void _showAddLeadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => AddLeadBottomSheet(
        onLeadAdded: (lead) {
          context.read<TenantFindingCubit>().addLead(lead);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã lưu thông tin khách thuê tiềm năng!')),
          );
        },
      ),
    );
  }

  Color _getStatusColor(LeadStatus status) {
    switch (status) {
      case LeadStatus.interested:
        return AppColors.warningOrange;
      case LeadStatus.viewingScheduled:
        return AppColors.blueCTA;
      case LeadStatus.deposited:
        return AppColors.primaryGreen;
      case LeadStatus.cancelled:
        return AppColors.dangerRed;
    }
  }
}
