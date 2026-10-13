/// Model đại diện cho một Khu nhà trọ (Property)
class PropertyModel {
  final int id;
  final String? userId; // Đổi sang String? để có thể null khi chưa đăng nhập
  final String name;
  final String? address;
  final DateTime createdAt;

  PropertyModel({
    required this.id,
    this.userId,
    required this.name,
    this.address,
    required this.createdAt,
  });

  /// Chuyển đổi từ dữ liệu JSON (Supabase) sang Model
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as int,
      userId: json['user_id'] as String?, // Xử lý null an toàn
      name: json['name'] as String,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Chuyển đổi từ Model sang JSON để gửi lên Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'user_id': userId, // Gửi null lên nếu chưa đăng nhập
    };
  }

  PropertyModel copyWith({
    int? id,
    String? userId,
    String? name,
    String? address,
    DateTime? createdAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
