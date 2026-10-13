enum RoomStatus { AVAILABLE, OCCUPIED, MAINTENANCE, BOOKED }

class RoomModel {
  final int id;
  final int propertyId;
  final String roomNumber;
  final double basePrice;
  final double area;
  final double depositDefault;
  final double elecRate;
  final double waterRate;
  final RoomStatus status;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.propertyId,
    required this.roomNumber,
    required this.basePrice,
    required this.area,
    required this.depositDefault,
    required this.elecRate,
    required this.waterRate,
    required this.status,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      roomNumber: json['room_number'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
      area: (json['area'] as num? ?? 0).toDouble(),
      depositDefault: (json['deposit_default'] as num? ?? 0).toDouble(),
      elecRate: (json['elec_rate'] as num? ?? 0).toDouble(),
      waterRate: (json['water_rate'] as num? ?? 0).toDouble(),
      status: RoomStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => RoomStatus.AVAILABLE,
      ),
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'room_number': roomNumber,
      'base_price': basePrice,
      'area': area,
      'deposit_default': depositDefault,
      'elec_rate': elecRate,
      'water_rate': waterRate,
      'status': status.name,
    };
  }

  RoomModel copyWith({
    int? id,
    int? propertyId,
    String? roomNumber,
    double? basePrice,
    double? area,
    double? depositDefault,
    double? elecRate,
    double? waterRate,
    RoomStatus? status,
    DateTime? createdAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      roomNumber: roomNumber ?? this.roomNumber,
      basePrice: basePrice ?? this.basePrice,
      area: area ?? this.area,
      depositDefault: depositDefault ?? this.depositDefault,
      elecRate: elecRate ?? this.elecRate,
      waterRate: waterRate ?? this.waterRate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
