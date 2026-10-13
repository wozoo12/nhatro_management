import 'package:equatable/equatable.dart';
import '../../data/models/property_model.dart';
import '../../data/models/room_model.dart';
import '../../data/models/room_dashboard_model.dart';

/// [RoomState] đại diện cho trạng thái của giao diện quản lý phòng và Dashboard.
/// Nó chứa các dữ liệu cần thiết để hiển thị lên màn hình.
abstract class RoomState extends Equatable {
  const RoomState();
  
  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo ban đầu.
class RoomInitial extends RoomState {}

/// Trạng thái đang tải dữ liệu (hiển thị vòng xoay loading).
class RoomLoading extends RoomState {}

/// Trạng thái đã tải dữ liệu thành công.
class RoomLoaded extends RoomState {
  final List<PropertyModel> properties;      // Danh sách các khu nhà trọ
  final List<RoomModel> rooms;                // Danh sách phòng (đơn giản)
  final List<RoomDashboardModel> dashboardRooms; // Dữ liệu tổng hợp cho Dashboard (Phòng + Khách + HĐ + HĐ)
  final String? message;                     // Thông báo thành công nếu có

  const RoomLoaded({
    this.properties = const [],
    this.rooms = const [],
    this.dashboardRooms = const [],
    this.message,
  });

  @override
  List<Object?> get props => [properties, rooms, dashboardRooms, message];

  /// Hàm tạo bản sao trạng thái mới với một số thay đổi.
  RoomLoaded copyWith({
    List<PropertyModel>? properties,
    List<RoomModel>? rooms,
    List<RoomDashboardModel>? dashboardRooms,
    String? message,
  }) {
    return RoomLoaded(
      properties: properties ?? this.properties,
      rooms: rooms ?? this.rooms,
      dashboardRooms: dashboardRooms ?? this.dashboardRooms,
      message: message,
    );
  }
}

/// Trạng thái xảy ra lỗi.
class RoomError extends RoomState {
  final String message; // Nội dung thông báo lỗi
  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}
