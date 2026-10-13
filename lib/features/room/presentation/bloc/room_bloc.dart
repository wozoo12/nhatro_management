import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/room_repository.dart';
import 'room_event.dart';
import 'room_state.dart';

/// [RoomBloc] chịu trách nhiệm quản lý logic nghiệp vụ cho Module quản lý phòng.
/// Chú thích tiếng Việt chi tiết cho Sang dễ kiểm soát luồng dữ liệu.
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository _repository;

  RoomBloc(this._repository) : super(RoomInitial()) {
    // Đăng ký xử lý các sự kiện
    on<FetchDashboardData>(_onFetchDashboardData);
    on<SaveElectricityReading>(_onSaveElectricityReading);
    on<FetchProperties>(_onFetchProperties);
    on<AddProperty>(_onAddProperty);
    on<UpdateProperty>(_onUpdateProperty);
    on<DeleteProperty>(_onDeleteProperty);
    on<FetchRooms>(_onFetchRooms);
    on<AddRoom>(_onAddRoom);
    on<UpdateRoom>(_onUpdateRoom);
    on<DeleteRoom>(_onDeleteRoom);
  }

  /// [Hàm xử lý thêm khu nhà mới]
  Future<void> _onAddProperty(
    AddProperty event,
    Emitter<RoomState> emit,
  ) async {
    final currentState = state;
    emit(RoomLoading());
    try {
      // Khởi tạo Model với userId có thể null (phục vụ việc test khi chưa login)
      final newProperty = PropertyModel(
        id: 0, 
        userId: event.userId, // Lấy từ event (có thể null hoặc string rỗng)
        name: event.name,
        address: event.address,
        createdAt: DateTime.now(),
      );
      
      // Gọi repository để lưu vào Supabase
      await _repository.addProperty(newProperty);
      
      // Sau khi thêm thành công, tự động tải lại danh sách mới
      add(FetchProperties());
    } catch (e) {
      emit(RoomError('Không thể thêm khu nhà: ${e.toString()}'));
      if (currentState is RoomLoaded) emit(currentState);
    }
  }

  /// [Hàm lấy dữ liệu Dashboard tổng hợp]
  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<RoomState> emit,
  ) async {
    final currentState = state;
    List<PropertyModel> properties = [];
    if (currentState is RoomLoaded) {
      properties = currentState.properties;
    }

    emit(RoomLoading());
    try {
      final dashboardRooms = await _repository.getDashboardRooms(event.propertyId);
      emit(RoomLoaded(
        properties: properties,
        dashboardRooms: dashboardRooms,
      ));
    } catch (e) {
      emit(RoomError('Lỗi tải Dashboard: ${e.toString()}'));
      if (currentState is RoomLoaded) emit(currentState);
    }
  }

  // --- CÁC HÀM XỬ LÝ KHÁC (GIỮ NGUYÊN GHI CHÚ) ---

  Future<void> _onFetchProperties(FetchProperties event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      final properties = await _repository.getProperties();
      emit(RoomLoaded(properties: properties));
    } catch (e) {
      emit(RoomError('Lỗi lấy danh sách khu nhà: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProperty(UpdateProperty event, Emitter<RoomState> emit) async {
    final currentState = state;
    emit(RoomLoading());
    try {
      await _repository.updateProperty(event.id, event.name, event.address);
      add(FetchProperties());
    } catch (e) {
      emit(RoomError(e.toString()));
      if (currentState is RoomLoaded) emit(currentState);
    }
  }

  Future<void> _onDeleteProperty(DeleteProperty event, Emitter<RoomState> emit) async {
    final currentState = state;
    emit(RoomLoading());
    try {
      await _repository.deleteProperty(event.id);
      add(FetchProperties());
    } catch (e) {
      emit(RoomError(e.toString()));
      if (currentState is RoomLoaded) emit(currentState);
    }
  }

  Future<void> _onFetchRooms(FetchRooms event, Emitter<RoomState> emit) async {
    final currentState = state;
    List<PropertyModel> properties = [];
    if (currentState is RoomLoaded) properties = currentState.properties;
    emit(RoomLoading());
    try {
      final rooms = await _repository.getRoomsByProperty(event.propertyId);
      emit(RoomLoaded(properties: properties, rooms: rooms));
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<void> _onAddRoom(AddRoom event, Emitter<RoomState> emit) async {
    final currentState = state;
    emit(RoomLoading());
    try {
      await _repository.addRoom(event.room);
      add(FetchRooms(event.room.propertyId));
    } catch (e) {
      emit(RoomError(e.toString()));
      if (currentState is RoomLoaded) emit(currentState);
    }
  }

  Future<void> _onUpdateRoom(UpdateRoom event, Emitter<RoomState> emit) async {
    final currentState = state;
    emit(RoomLoading());
    try {
      await _repository.updateRoom(event.room);
      add(FetchRooms(event.room.propertyId));
    } catch (e) {
      emit(RoomError(e.toString()));
      if (currentState is RoomLoaded) emit(currentState);
    }
  }

  Future<void> _onDeleteRoom(DeleteRoom event, Emitter<RoomState> emit) async {
    final currentState = state;
    emit(RoomLoading());
    try {
      await _repository.deleteRoom(event.roomId);
      add(FetchRooms(event.propertyId));
    } catch (e) {
      emit(RoomError(e.toString()));
      if (currentState is RoomLoaded) emit(currentState);
    }
  }

  Future<void> _onSaveElectricityReading(SaveElectricityReading event, Emitter<RoomState> emit) async {
    final currentState = state;
    emit(RoomLoading());
    try {
      await _repository.saveElectricityReading(
        roomId: event.roomId,
        contractId: event.contractId,
        oldElec: event.oldElec,
        newElec: event.newElec,
        elecRate: event.elecRate,
        roomCharge: event.roomCharge,
        monthYear: event.monthYear,
      );
      add(FetchDashboardData(event.propertyId));
    } catch (e) {
      emit(RoomError('Lỗi chốt điện: ${e.toString()}'));
      if (currentState is RoomLoaded) emit(currentState);
    }
  }
}
