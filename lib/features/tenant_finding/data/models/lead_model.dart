enum LeadStatus {
  interested,       // Quan tâm / Đang hỏi
  viewingScheduled, // Đã hẹn xem phòng
  deposited,        // Đã cọc giữ chỗ
  cancelled,        // Hủy / Không thuê
}

class LeadModel {
  final String id;
  final String name;
  final String phone;
  final String? preferredRoom;
  final double? budget;
  final LeadStatus status;
  final DateTime? appointmentDate;
  final String? note;
  final DateTime createdAt;

  const LeadModel({
    required this.id,
    required this.name,
    required this.phone,
    this.preferredRoom,
    this.budget,
    this.status = LeadStatus.interested,
    this.appointmentDate,
    this.note,
    required this.createdAt,
  });

  LeadModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? preferredRoom,
    double? budget,
    LeadStatus? status,
    DateTime? appointmentDate,
    String? note,
    DateTime? createdAt,
  }) {
    return LeadModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      preferredRoom: preferredRoom ?? this.preferredRoom,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get statusLabel {
    switch (status) {
      case LeadStatus.interested:
        return 'Đang quan tâm';
      case LeadStatus.viewingScheduled:
        return 'Đã hẹn xem phòng';
      case LeadStatus.deposited:
        return 'Đã đặt cọc';
      case LeadStatus.cancelled:
        return 'Đã hủy hẹn';
    }
  }
}
