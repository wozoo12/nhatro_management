/// Model đại diện cho thông tin Khách thuê (Tenant)
/// Map chính xác với bảng 'tenants' trong cơ sở dữ liệu Supabase
class TenantModel {
  final int id;              // ID khách thuê (BIGINT)
  final String fullName;     // Họ và tên đầy đủ
  final String phone;        // Số điện thoại liên lạc
  final String? identityCard;// Số CCCD/CMND
  final String? frontCardUrl;// Đường dẫn ảnh mặt trước CCCD trên Storage
  final String? backCardUrl; // Đường dẫn ảnh mặt sau CCCD trên Storage
  final DateTime createdAt;  // Ngày tạo hồ sơ

  TenantModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.identityCard,
    this.frontCardUrl,
    this.backCardUrl,
    required this.createdAt,
  });

  /// Chuyển đổi từ dữ liệu JSON (Supabase) sang TenantModel
  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      identityCard: json['identity_card'] as String?,
      frontCardUrl: json['front_card_url'] as String?,
      backCardUrl: json['back_card_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Chuyển đổi từ TenantModel sang Map để lưu trữ hoặc cập nhật vào database
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'identity_card': identityCard,
      'front_card_url': frontCardUrl,
      'back_card_url': backCardUrl,
    };
  }

  /// Hàm tạo bản sao mới với các thông tin thay đổi (Immutable pattern)
  TenantModel copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? identityCard,
    String? frontCardUrl,
    String? backCardUrl,
    DateTime? createdAt,
  }) {
    return TenantModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      identityCard: identityCard ?? this.identityCard,
      frontCardUrl: frontCardUrl ?? this.frontCardUrl,
      backCardUrl: backCardUrl ?? this.backCardUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
