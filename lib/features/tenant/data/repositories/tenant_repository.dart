import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tenant_model.dart';
import '../models/contract_model.dart';
import '../../../room/data/models/room_model.dart';

/// [TenantRepository] quản lý dữ liệu Khách thuê và Hợp đồng trên Supabase.
class TenantRepository {
  final SupabaseClient _client;

  TenantRepository(this._client);

  // ===========================================================================
  // QUẢN LÝ KHÁCH THUÊ (TENANTS)
  // ===========================================================================

  /// Lấy danh sách toàn bộ khách thuê
  Future<List<TenantModel>> getTenants() async {
    try {
      final response = await _client.from('tenants').select().order('created_at', ascending: false);
      return (response as List).map((e) => TenantModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách khách thuê: $e');
    }
  }

  /// Thêm mới một khách thuê
  Future<TenantModel> addTenant(TenantModel tenant) async {
    try {
      final response = await _client.from('tenants').insert(tenant.toJson()).select().single();
      return TenantModel.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi thêm khách thuê: $e');
    }
  }

  // ===========================================================================
  // QUẢN LÝ HÌNH ẢNH (SUPABASE STORAGE)
  // ===========================================================================

  /// Tải ảnh CCCD lên Storage và trả về URL công khai
  Future<String> uploadCCCDImage(File file, String fileName) async {
    try {
      // Tải tệp lên bucket 'tenants-cccd'
      await _client.storage.from('tenants-cccd').upload(fileName, file);
      // Lấy URL để hiển thị ảnh
      return _client.storage.from('tenants-cccd').getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Lỗi upload ảnh: $e');
    }
  }

  // ===========================================================================
  // QUẢN LÝ HỢP ĐỒNG (CONTRACTS)
  // ===========================================================================

  /// Lấy danh sách phòng TRỐNG để chuẩn bị ký hợp đồng mới
  Future<List<RoomModel>> getAvailableRooms() async {
    try {
      final response = await _client.from('rooms').select().eq('status', 'AVAILABLE');
      return (response as List).map((e) => RoomModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách phòng trống: $e');
    }
  }

  /// Tạo hợp đồng mới và cập nhật trạng thái phòng sang 'OCCUPIED' (Đã thuê)
  Future<void> createContract(ContractModel contract) async {
    try {
      // 1. Lưu hợp đồng vào bảng 'contracts'
      await _client.from('contracts').insert(contract.toJson());
      
      // 2. Cập nhật trạng thái phòng tương ứng
      await _client.from('rooms').update({'status': 'OCCUPIED'}).eq('id', contract.roomId);
    } catch (e) {
      throw Exception('Lỗi khi ký hợp đồng: $e');
    }
  }

  /// Lấy danh sách hợp đồng theo phòng (room_id)
  Future<List<ContractModel>> getContractsByRoom(int roomId) async {
    try {
      final response = await _client
          .from('contracts')
          .select()
          .eq('room_id', roomId)
          .order('start_date', ascending: false);
      return (response as List).map((e) => ContractModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách hợp đồng: $e');
    }
  }
}
