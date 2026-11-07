import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';
import '../models/room_dashboard_model.dart';
// import '../models/utility_reading_model.dart';
// import '../models/invoice_model.dart';

/// Repository quản lý việc truy xuất dữ liệu thật từ Supabase.
/// Đã được tối ưu hóa để lấy dữ liệu theo đúng mối quan hệ Hợp đồng -> Hóa đơn.
class RoomRepository {
  final SupabaseClient _client;

  RoomRepository(this._client);

  // ===========================================================================
  // TRUY VẤN DỮ LIỆU DASHBOARD (JOIN CHUẨN SCHEMA)
  // ===========================================================================

  /// [Lấy Dữ Liệu Dashboard]: Truy vấn lồng nhau để lấy thông tin từ 5 bảng liên quan.
  Future<List<RoomDashboardModel>> getDashboardRooms(int propertyId) async {
    try {
      // Query chuẩn: Lấy Phòng -> Hợp đồng -> (Khách & Hóa đơn) + Chỉ số điện
      final response = await _client
          .from('rooms')
          .select('''
            *,
            contracts (
              *,
              tenants (*),
              invoices (*)
            ),
            utility_readings (*)
          ''')
          .eq('property_id', propertyId)
          .order('room_number', ascending: true);

      return (response as List)
          .map((e) => RoomDashboardModel.fromSupabase(e))
          .toList();
    } catch (e) {
      throw Exception('Lỗi truy vấn Dashboard: $e');
    }
  }

  // ===========================================================================
  // XỬ LÝ NGHIỆP VỤ LƯU CHỈ SỐ VÀ TẠO HÓA ĐƠN
  // ===========================================================================

  /// Thực hiện lưu chỉ số điện và tạo hóa đơn (Đảm bảo bám sát Schema 3NF)
  Future<void> saveElectricityReading({
    required int roomId,
    required int contractId,
    required int oldElec,
    required int newElec,
    required double elecRate,
    required double roomCharge,
    required String monthYear,
  }) async {
    try {
      // 1. Lưu chỉ số mới
      final readingResponse = await _client
          .from('utility_readings')
          .insert({
            'room_id': roomId,
            'month_year': monthYear,
            'old_elec': oldElec,
            'new_elec': newElec,
            'old_water': 0,
            'new_water': 0,
            'reading_date': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final int readingId = readingResponse['id'];

      // 2. Tính tiền điện và tổng cộng (mặc định +100k phí dịch vụ cố định)
      final double elecCharge = (newElec - oldElec) * elecRate;
      final double total = roomCharge + elecCharge + 100000;

      // 3. Tạo hóa đơn liên kết với Hợp đồng và Chỉ số vừa ghi
      await _client.from('invoices').insert({
        'contract_id': contractId,
        'reading_id': readingId,
        'month_year': monthYear,
        'room_charge': roomCharge,
        'elec_charge': elecCharge,
        'total_amount': total,
        'other_fees': 100000,
        'status': 'UNPAID',
      });
    } catch (e) {
      throw Exception('Lỗi xử lý chốt điện: $e');
    }
  }

  // --- CÁC HÀM CRUD KHÁC ---
  Future<List<PropertyModel>> getProperties() async {
    final res = await _client
        .from('properties')
        .select()
        .order('created_at', ascending: false);
    return (res as List).map((e) => PropertyModel.fromJson(e)).toList();
  }

  Future<PropertyModel> addProperty(PropertyModel p) async {
    final res =
        await _client.from('properties').insert(p.toJson()).select().single();
    return PropertyModel.fromJson(res);
  }

  Future<void> updateProperty(int id, String n, String? a) async =>
      await _client
          .from('properties')
          .update({'name': n, 'address': a}).eq('id', id);
  Future<void> deleteProperty(int id) async =>
      await _client.from('properties').delete().eq('id', id);

  // ===========================================================================
  // CRUD PHÒNG TRỌ (ROOMS)
  // ===========================================================================

  /// Lấy danh sách phòng theo khu nhà (property_id)
  Future<List<RoomModel>> getRoomsByProperty(int propertyId) async {
    try {
      final response = await _client
          .from('rooms')
          .select()
          .eq('property_id', propertyId)
          .order('room_number', ascending: true);
      return (response as List).map((e) => RoomModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách phòng: $e');
    }
  }

  /// Thêm phòng mới vào khu nhà
  Future<void> addRoom(RoomModel room) async {
    try {
      await _client.from('rooms').insert(room.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm phòng: $e');
    }
  }

  /// Cập nhật thông tin phòng (giá, trạng thái, ...)
  Future<void> updateRoom(RoomModel room) async {
    try {
      await _client.from('rooms').update(room.toJson()).eq('id', room.id);
    } catch (e) {
      throw Exception('Lỗi cập nhật phòng: $e');
    }
  }

  /// Xóa phòng theo ID
  Future<void> deleteRoom(int roomId) async {
    try {
      await _client.from('rooms').delete().eq('id', roomId);
    } catch (e) {
      throw Exception('Lỗi xóa phòng: $e');
    }
  }

  Future<void> createReservation(
      {required int roomId,
      required String tenantName,
      required String phone,
      required double amount,
      required DateTime moveInDate}) async {
    await _client.rpc('reserve_room', params: {
      'p_room_id': roomId,
      'p_tenant_name': tenantName,
      'p_phone': phone,
      'p_amount_paid': amount,
      'p_move_in_date': moveInDate.toIso8601String().split('T').first,
    });
  }

  Future<Map<String, dynamic>?> getActiveReservation(int roomId) async {
    final rows = await _client
        .from('room_reservations')
        .select()
        .eq('room_id', roomId)
        .eq('status', 'ACTIVE')
        .order('created_at', ascending: false)
        .limit(1);
    return (rows as List).isEmpty
        ? null
        : Map<String, dynamic>.from(rows.first as Map);
  }

  Future<void> markReservationConverted(int roomId) async {
    await _client
        .from('room_reservations')
        .update({'status': 'CONVERTED'})
        .eq('room_id', roomId)
        .eq('status', 'ACTIVE');
  }

  Future<void> finishCheckout(
      {required int roomId,
      required int contractId,
      required DateTime checkoutDate}) async {
    await _client.rpc('finish_room_checkout', params: {
      'p_room_id': roomId,
      'p_contract_id': contractId,
      'p_checkout_date': checkoutDate.toIso8601String().split('T').first,
    });
  }
}
