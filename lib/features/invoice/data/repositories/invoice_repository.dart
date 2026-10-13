import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nhatro_management/features/invoice/data/models/invoice_detail_model.dart';

/// Repository quản lý truy vấn và cập nhật hóa đơn trên Supabase.
class InvoiceRepository {
  final SupabaseClient _client;

  InvoiceRepository(this._client);

  /// Lấy toàn bộ lịch sử hóa đơn của một khu nhà (theo property_id).
  Future<List<InvoiceDetailModel>> getInvoicesByProperty(int propertyId) async {
    try {
      final roomsRes = await _client.from('rooms').select('id').eq('property_id', propertyId);
      final roomIds = (roomsRes as List).map((r) => r['id'] as int).toList();
      if (roomIds.isEmpty) return [];

      final contractsRes = await _client.from('contracts').select('id').inFilter('room_id', roomIds);
      final contractIds = (contractsRes as List).map((c) => c['id'] as int).toList();
      if (contractIds.isEmpty) return [];

      final response = await _client
          .from('invoices')
          .select('''
            *,
            utility_readings (*),
            contracts (
              *,
              tenants (*),
              rooms (*)
            )
          ''')
          .inFilter('contract_id', contractIds)
          .order('created_at', ascending: false);

      return (response as List).map((e) => InvoiceDetailModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy lịch sử hóa đơn: $e');
    }
  }

  /// Tạo hóa đơn mới (Dùng cho luồng Lập hóa đơn thủ công)
  Future<void> createInvoice({
    required int contractId,
    required String monthYear,
    required double roomCharge,
    required double otherFees,
    required String status,
  }) async {
    try {
      await _client.from('invoices').insert({
        'contract_id': contractId,
        'month_year': monthYear,
        'room_charge': roomCharge,
        'elec_charge': 0,
        'water_charge': 0,
        'other_fees': otherFees,
        'total_amount': roomCharge + otherFees,
        'status': status,
      });
    } catch (e) {
      throw Exception('Lỗi tạo hóa đơn: $e');
    }
  }

  /// Cập nhật trạng thái thanh toán hóa đơn (UNPAID / PAID).
  Future<void> updateInvoiceStatus(int invoiceId, String status) async {
    try {
      final updateData = <String, dynamic>{'status': status};
      if (status == 'PAID') {
        updateData['paid_at'] = DateTime.now().toIso8601String();
      } else {
        updateData['paid_at'] = null;
      }
      await _client.from('invoices').update(updateData).eq('id', invoiceId);
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái hóa đơn: $e');
    }
  }
}
