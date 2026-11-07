import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/lead_model.dart';
import 'tenant_finding_state.dart';

class TenantFindingCubit extends Cubit<TenantFindingState> {
  TenantFindingCubit() : super(const TenantFindingState()) {
    loadLeads();
  }

  void loadLeads() {
    emit(state.copyWith(status: TenantFindingStatus.loading));
    try {
      final initialLeads = [
        LeadModel(
          id: 'lead_1',
          name: 'Nguyễn Văn Minh',
          phone: '0912345678',
          preferredRoom: '102',
          budget: 3500000,
          status: LeadStatus.viewingScheduled,
          appointmentDate: DateTime.now().add(const Duration(hours: 4)),
          note: 'Muốn phòng có gác lửng, chuyển vào đầu tuần sau',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        LeadModel(
          id: 'lead_2',
          name: 'Trần Thị Thảo',
          phone: '0987654321',
          preferredRoom: '201',
          budget: 3200000,
          status: LeadStatus.interested,
          appointmentDate: null,
          note: 'Hỏi xem có bãi giữ xe máy và máy giặt chung không',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        LeadModel(
          id: 'lead_3',
          name: 'Lê Hoàng Nam',
          phone: '0903112233',
          preferredRoom: '101',
          budget: 4000000,
          status: LeadStatus.deposited,
          appointmentDate: null,
          note: 'Đã chuyển cọc giữ chỗ 500k, chuẩn bị ký hợp đồng',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      emit(state.copyWith(
        leads: initialLeads,
        status: TenantFindingStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TenantFindingStatus.error,
        errorMessage: 'Lỗi tải danh sách khách: ${e.toString()}',
      ));
    }
  }

  void filterByStatus(LeadStatus? status) {
    if (status == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedFilter: status));
    }
  }

  void addLead(LeadModel lead) {
    final updated = [lead, ...state.leads];
    emit(state.copyWith(leads: updated));
  }

  void updateLeadStatus(String leadId, LeadStatus newStatus) {
    final updated = state.leads.map((l) {
      if (l.id == leadId) {
        return l.copyWith(status: newStatus);
      }
      return l;
    }).toList();
    emit(state.copyWith(leads: updated));
  }

  void deleteLead(String leadId) {
    final updated = state.leads.where((l) => l.id != leadId).toList();
    emit(state.copyWith(leads: updated));
  }
}
