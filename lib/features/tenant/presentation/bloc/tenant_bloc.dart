import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/tenant_model.dart';
import '../../data/repositories/tenant_repository.dart';
import 'tenant_event.dart';
import 'tenant_state.dart';

/// [TenantBloc] là trung tâm xử lý logic cho Khách thuê và Hợp đồng.
/// Chú thích chi tiết từng hàm để Sang dễ dàng nắm bắt luồng xử lý dữ liệu.
class TenantBloc extends Bloc<TenantEvent, TenantState> {
  final TenantRepository _repository;

  /// Khởi tạo Bloc với trạng thái ban đầu là TenantInitial.
  TenantBloc(this._repository) : super(TenantInitial()) {
    // Đăng ký các hàm xử lý cho từng loại Sự kiện
    on<FetchTenants>(_onFetchTenants);
    on<FetchAvailableRooms>(_onFetchAvailableRooms);
    on<AddTenant>(_onAddTenant);
    on<FetchContractsByRoom>(_onFetchContractsByRoom);
    on<CreateContract>(_onCreateContract);
  }

  /// [Hàm xử lý lấy danh sách khách thuê]: Truy vấn toàn bộ khách từ Database.
  Future<void> _onFetchTenants(
    FetchTenants event,
    Emitter<TenantState> emit,
  ) async {
    emit(TenantLoading()); // Bật vòng xoay đang tải
    try {
      final tenants = await _repository.getTenants();
      emit(TenantLoaded(tenants: tenants)); // Trả về danh sách khách thành công
    } catch (e) {
      emit(TenantError('Lỗi tải danh sách khách: ${e.toString()}'));
    }
  }

  /// [Hàm xử lý lấy danh sách phòng trống]: Phục vụ việc chọn phòng khi ký hợp đồng.
  Future<void> _onFetchAvailableRooms(
    FetchAvailableRooms event,
    Emitter<TenantState> emit,
  ) async {
    final currentState = state;
    List<TenantModel> tenants = [];
    if (currentState is TenantLoaded) tenants = currentState.tenants;

    emit(TenantLoading());
    try {
      final rooms = await _repository.getAvailableRooms();
      // Giữ lại danh sách khách cũ và cập nhật thêm danh sách phòng trống mới lấy về
      emit(TenantLoaded(tenants: tenants, availableRooms: rooms));
    } catch (e) {
      emit(TenantError('Lỗi lấy danh sách phòng trống: ${e.toString()}'));
    }
  }

  /// [Hàm xử lý thêm khách thuê mới]: Bao gồm chụp ảnh và upload lên Storage.
  Future<void> _onAddTenant(
    AddTenant event,
    Emitter<TenantState> emit,
  ) async {
    final currentState = state;
    emit(TenantLoading());

    try {
      String? frontUrl = event.tenant.frontCardUrl;
      String? backUrl = event.tenant.backCardUrl;

      // 1. Upload ảnh mặt trước nếu có chụp
      if (event.frontCard != null) {
        emit(const TenantUploadingImage(0.3)); // Tiến độ 30%
        final fileName =
            'cccd/front_${DateTime.now().millisecondsSinceEpoch}.jpg';
        frontUrl =
            await _repository.uploadCCCDImage(event.frontCard!, fileName);
      }

      // 2. Upload ảnh mặt sau nếu có chụp
      if (event.backCard != null) {
        emit(const TenantUploadingImage(0.6)); // Tiến độ 60%
        final fileName =
            'cccd/back_${DateTime.now().millisecondsSinceEpoch}.jpg';
        backUrl = await _repository.uploadCCCDImage(event.backCard!, fileName);
      }

      // 3. Cập nhật Model với Link ảnh thật từ máy chủ và lưu vào bảng tenants
      final tenantToSave = event.tenant.copyWith(
        frontCardUrl: frontUrl,
        backCardUrl: backUrl,
      );
      await _repository.addTenant(tenantToSave);

      // Màn hình gọi thao tác sẽ tự tải lại danh sách sau khi đóng form.
      emit(const TenantLoaded(message: 'Đã lưu hồ sơ khách thuê thành công!'));
    } catch (e) {
      emit(TenantError('Lỗi xử lý hồ sơ: ${e.toString()}'));
      if (currentState is TenantLoaded) emit(currentState);
    }
  }

  /// [Hàm xử lý lấy lịch sử hợp đồng của một phòng]
  Future<void> _onFetchContractsByRoom(
    FetchContractsByRoom event,
    Emitter<TenantState> emit,
  ) async {
    final currentState = state;
    List<TenantModel> tenants = [];
    if (currentState is TenantLoaded) tenants = currentState.tenants;

    emit(TenantLoading());
    try {
      final contracts = await _repository.getContractsByRoom(event.roomId);
      emit(TenantLoaded(tenants: tenants, contracts: contracts));
    } catch (e) {
      emit(TenantError('Lỗi tải lịch sử hợp đồng: ${e.toString()}'));
    }
  }

  /// [Hàm xử lý Ký Hợp Đồng Mới]:
  /// Thực hiện 2 việc: Lưu hợp đồng + Đổi trạng thái phòng sang ĐÃ THUÊ (OCCUPIED)
  Future<void> _onCreateContract(
    CreateContract event,
    Emitter<TenantState> emit,
  ) async {
    final currentState = state;
    emit(TenantLoading());
    try {
      // Gọi repository thực hiện nghiệp vụ kép (bám sát logic 3NF)
      await _repository.createContract(event.contract);

      // Thông báo thành công cho UI
      emit(const TenantLoaded(
          message: 'Ký hợp đồng thành công! Phòng đã được đưa vào sử dụng.'));

      // Tải lại danh sách khách để đồng bộ trạng thái
      add(FetchTenants());
    } catch (e) {
      emit(TenantError('Lỗi ký hợp đồng: ${e.toString()}'));
      if (currentState is TenantLoaded) emit(currentState);
    }
  }
}
