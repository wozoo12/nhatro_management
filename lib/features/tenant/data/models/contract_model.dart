/// Định nghĩa các trạng thái pháp lý của Hợp đồng
enum ContractStatus {
  ACTIVE,     // Đang còn hiệu lực
  EXPIRED,    // Đã hết hạn theo ngày ký
  TERMINATED  // Đã thanh lý/chấm dứt trước hạn
}

/// Model đại diện cho một Hợp đồng thuê phòng (Contract)
/// Liên kết giữa khách thuê (Tenant) và phòng trọ (Room)
class ContractModel {
  final int id;                      // ID hợp đồng (BIGINT)
  final int roomId;                  // ID phòng được thuê (Khóa ngoại)
  final int representativeTenantId; // ID khách thuê đại diện ký hợp đồng (Khóa ngoại)
  final DateTime startDate;          // Ngày bắt đầu hợp đồng
  final DateTime? endDate;           // Ngày kết thúc dự kiến (nếu có)
  final double actualDeposit;        // Tiền cọc thực tế khách đã đóng
  final ContractStatus status;       // Trạng thái hiện tại của hợp đồng
  final DateTime createdAt;          // Ngày tạo bản ghi hợp đồng

  ContractModel({
    required this.id,
    required this.roomId,
    required this.representativeTenantId,
    required this.startDate,
    this.endDate,
    required this.actualDeposit,
    required this.status,
    required this.createdAt,
  });

  /// Chuyển đổi dữ liệu JSON từ database sang Model Dart
  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as int,
      roomId: json['room_id'] as int,
      representativeTenantId: json['representative_tenant_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      actualDeposit: (json['actual_deposit'] as num).toDouble(),
      status: ContractStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ContractStatus.ACTIVE,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Chuyển đổi từ Model Dart sang JSON để lưu vào database
  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'representative_tenant_id': representativeTenantId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'actual_deposit': actualDeposit,
      'status': status.name,
    };
  }

  /// Hàm sao chép tạo đối tượng mới với các thay đổi nhỏ (Immutable pattern)
  ContractModel copyWith({
    int? id,
    int? roomId,
    int? representativeTenantId,
    DateTime? startDate,
    DateTime? endDate,
    double? actualDeposit,
    ContractStatus? status,
    DateTime? createdAt,
  }) {
    return ContractModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      representativeTenantId: representativeTenantId ?? this.representativeTenantId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      actualDeposit: actualDeposit ?? this.actualDeposit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
