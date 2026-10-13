import 'package:equatable/equatable.dart';
import '../../data/models/room_model.dart';

/// [RoomEvent] định nghĩa các hành động người dùng tương tác với Module Phòng & Dashboard.
abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

/// Sự kiện: Tải toàn bộ dữ liệu cần thiết cho Dashboard.
class FetchDashboardData extends RoomEvent {
  final int propertyId;
  const FetchDashboardData(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

/// Sự kiện: Lưu chỉ số điện và tự động tạo hóa đơn tháng.
class SaveElectricityReading extends RoomEvent {
  final int roomId;
  final int contractId;
  final int oldElec;
  final int newElec;
  final double elecRate;
  final double roomCharge;
  final String monthYear;
  final int propertyId;

  const SaveElectricityReading({
    required this.roomId,
    required this.contractId,
    required this.oldElec,
    required this.newElec,
    required this.elecRate,
    required this.roomCharge,
    required this.monthYear,
    required this.propertyId,
  });

  @override
  List<Object?> get props => [roomId, contractId, oldElec, newElec, monthYear];
}

/// Sự kiện: Yêu cầu lấy danh sách tất cả các khu nhà trọ.
class FetchProperties extends RoomEvent {}

/// Sự kiện: Thêm một khu nhà trọ mới.
class AddProperty extends RoomEvent {
  final String name;
  final String? address;
  final String? userId; // Đã đổi thành String? để có thể null khi chưa login

  const AddProperty({required this.name, this.address, this.userId});

  @override
  List<Object?> get props => [name, address, userId];
}

/// Sự kiện: Cập nhật thông tin khu nhà.
class UpdateProperty extends RoomEvent {
  final int id;
  final String name;
  final String? address;
  const UpdateProperty({required this.id, required this.name, this.address});

  @override
  List<Object?> get props => [id, name, address];
}

/// Sự kiện: Xóa một khu nhà.
class DeleteProperty extends RoomEvent {
  final int id;
  const DeleteProperty(this.id);

  @override
  List<Object?> get props => [id];
}

// ... Các sự kiện Room khác giữ nguyên ...
class FetchRooms extends RoomEvent {
  final int propertyId;
  const FetchRooms(this.propertyId);
}

class AddRoom extends RoomEvent {
  final RoomModel room;
  const AddRoom(this.room);
}

class UpdateRoom extends RoomEvent {
  final RoomModel room;
  const UpdateRoom(this.room);
}

class DeleteRoom extends RoomEvent {
  final int roomId;
  final int propertyId;
  const DeleteRoom({required this.roomId, required this.propertyId});
}
