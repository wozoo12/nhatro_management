import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/models/tenant_model.dart';
import '../../data/models/contract_model.dart';

/// [TenantEvent] định nghĩa các hành động liên quan đến Khách thuê và Hợp đồng.
abstract class TenantEvent extends Equatable {
  const TenantEvent();

  @override
  List<Object?> get props => [];
}

/// Sự kiện: Lấy toàn bộ danh sách khách thuê.
class FetchTenants extends TenantEvent {}

/// [SỰ KIỆN MỚI]: Lấy danh sách các phòng đang còn trống để chuẩn bị ký hợp đồng.
class FetchAvailableRooms extends TenantEvent {}

/// Sự kiện: Thêm khách thuê mới và upload ảnh CCCD.
class AddTenant extends TenantEvent {
  final TenantModel tenant;
  final File? frontCard;
  final File? backCard;

  const AddTenant({required this.tenant, this.frontCard, this.backCard});

  @override
  List<Object?> get props => [tenant, frontCard, backCard];
}

/// Sự kiện: Tải lịch sử hợp đồng của một phòng.
class FetchContractsByRoom extends TenantEvent {
  final int roomId;
  const FetchContractsByRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Sự kiện: Thực hiện ký hợp đồng mới.
class CreateContract extends TenantEvent {
  final ContractModel contract;
  const CreateContract(this.contract);

  @override
  List<Object?> get props => [contract];
}
