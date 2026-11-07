/// Model đại diện cho một Khu nhà trọ (Property)
class PropertyModel {
  final int id;
  final String? userId; // Đổi sang String? để có thể null khi chưa đăng nhập
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  PropertyModel({
    required this.id,
    this.userId,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  /// Chuyển đổi từ dữ liệu JSON (Supabase) sang Model
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as int,
      userId: json['user_id'] as String?, // Xử lý null an toàn
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Chuyển đổi từ Model sang JSON để gửi lên Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId, // Gửi null lên nếu chưa đăng nhập
    };
  }

  PropertyModel copyWith({
    int? id,
    String? userId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
