import 'package:intl/intl.dart';
import 'room_model.dart';
import '../../../tenant/data/models/tenant_model.dart';
import '../../../tenant/data/models/contract_model.dart';
import 'invoice_model.dart';
import 'utility_reading_model.dart';

/// [RoomDashboardModel] là Model trung tâm gộp dữ liệu từ nhiều bảng (Rooms, Tenants, Contracts, Invoices).
/// Dùng để hiển thị thông tin đầy đủ nhất của một phòng trên Dashboard.
class RoomDashboardModel {
  final RoomModel room;             // Thông tin phòng
  final TenantModel? tenant;        // Khách đang ở (nếu có)
  final ContractModel? contract;    // Hợp đồng còn hiệu lực
  final InvoiceModel? invoice;      // Hóa đơn tháng hiện tại
  final UtilityReadingModel? lastReading; // Chỉ số điện nước mới nhất

  RoomDashboardModel({
    required this.room,
    this.tenant,
    this.contract,
    this.invoice,
    this.lastReading,
  });

  /// Factory trích xuất dữ liệu từ kết quả JOIN của Supabase
  factory RoomDashboardModel.fromSupabase(Map<String, dynamic> json) {
    final room = RoomModel.fromJson(json);
    final String currentMonthYear = DateFormat('yyyy-MM').format(DateTime.now());

    ContractModel? activeContract;
    TenantModel? currentTenant;
    InvoiceModel? currentInvoice;

    // 1. Xử lý Hợp đồng và Khách thuê (Nested trong 'contracts')
    if (json['contracts'] != null && (json['contracts'] as List).isNotEmpty) {
      final List contractsJson = json['contracts'] as List;
      // Tìm hợp đồng ACTIVE
      final activeContractData = contractsJson.firstWhere(
        (c) => c['status'] == 'ACTIVE',
        orElse: () => null,
      );
      
      if (activeContractData != null) {
        activeContract = ContractModel.fromJson(activeContractData);
        // Lấy khách thuê từ trong hợp đồng
        if (activeContractData['tenants'] != null) {
          currentTenant = TenantModel.fromJson(activeContractData['tenants']);
        }
        // Lấy hóa đơn tháng hiện tại từ trong hợp đồng (Vì invoices tham chiếu contract_id)
        if (activeContractData['invoices'] != null) {
          final List invList = activeContractData['invoices'] as List;
          final currentInvData = invList.firstWhere(
            (inv) => inv['month_year'] == currentMonthYear,
            orElse: () => null,
          );
          if (currentInvData != null) {
            currentInvoice = InvoiceModel.fromJson(currentInvData);
          }
        }
      }
    }

    // 2. Lấy chỉ số điện nước mới nhất (Liên kết trực tiếp với Room)
    UtilityReadingModel? lastReading;
    if (json['utility_readings'] != null && (json['utility_readings'] as List).isNotEmpty) {
      final List readList = json['utility_readings'] as List;
      readList.sort((a, b) => b['reading_date'].compareTo(a['reading_date']));
      lastReading = UtilityReadingModel.fromJson(readList.first);
    }

    return RoomDashboardModel(
      room: room,
      tenant: currentTenant,
      contract: activeContract,
      invoice: currentInvoice,
      lastReading: lastReading,
    );
  }
}
