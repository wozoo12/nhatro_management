import 'package:equatable/equatable.dart';
import '../../data/models/tenant_model.dart';
import '../../data/models/contract_model.dart';
import '../../../room/data/models/room_model.dart';

/// [TenantState] là lớp cơ sở đại diện cho trạng thái của màn hình quản lý khách thuê.
abstract class TenantState extends Equatable {
  const TenantState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo ban đầu.
class TenantInitial extends TenantState {}

/// Trạng thái đang xử lý (Loading).
class TenantLoading extends TenantState {}

/// Trạng thái thành công: Chứa toàn bộ dữ liệu cần thiết cho Module Khách thuê.
class TenantLoaded extends TenantState {
  final List<TenantModel> tenants;       // Toàn bộ danh sách khách thuê
  final List<ContractModel> contracts;   // Lịch sử hợp đồng (nếu đang xem theo phòng)
  final List<RoomModel> availableRooms;  // Danh sách các phòng TRỐNG để ký hợp đồng mới
  final String? message;                 // Thông báo thành công từ hệ thống

  const TenantLoaded({
    this.tenants = const [],
    this.contracts = const [],
    this.availableRooms = const [],
    this.message,
  });

  @override
  List<Object?> get props => [tenants, contracts, availableRooms, message];

  /// Tạo bản sao mới của trạng thái hiện tại với các thay đổi cụ thể.
  TenantLoaded copyWith({
    List<TenantModel>? tenants,
    List<ContractModel>? contracts,
    List<RoomModel>? availableRooms,
    String? message,
  }) {
    return TenantLoaded(
      tenants: tenants ?? this.tenants,
      contracts: contracts ?? this.contracts,
      availableRooms: availableRooms ?? this.availableRooms,
      message: message,
    );
  }
}

/// Trạng thái đang tải ảnh lên máy chủ.
class TenantUploadingImage extends TenantState {
  final double progress; // Tiến độ tải lên (%)
  const TenantUploadingImage(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Trạng thái xảy ra lỗi.
class TenantError extends TenantState {
  final String message; // Nội dung lỗi tiếng Việt
  const TenantError(this.message);

  @override
  List<Object?> get props => [message];
}
