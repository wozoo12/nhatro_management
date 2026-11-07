import 'package:equatable/equatable.dart';
import '../../data/models/lead_model.dart';

enum TenantFindingStatus { initial, loading, success, error }

class TenantFindingState extends Equatable {
  final List<LeadModel> leads;
  final LeadStatus? selectedFilter;
  final TenantFindingStatus status;
  final String? errorMessage;

  const TenantFindingState({
    this.leads = const [],
    this.selectedFilter,
    this.status = TenantFindingStatus.initial,
    this.errorMessage,
  });

  TenantFindingState copyWith({
    List<LeadModel>? leads,
    LeadStatus? selectedFilter,
    bool clearFilter = false,
    TenantFindingStatus? status,
    String? errorMessage,
  }) {
    return TenantFindingState(
      leads: leads ?? this.leads,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<LeadModel> get filteredLeads {
    if (selectedFilter == null) return leads;
    return leads.where((l) => l.status == selectedFilter).toList();
  }

  int get interestedCount => leads.where((l) => l.status == LeadStatus.interested).length;
  int get scheduledCount => leads.where((l) => l.status == LeadStatus.viewingScheduled).length;

  @override
  List<Object?> get props => [leads, selectedFilter, status, errorMessage];
}
