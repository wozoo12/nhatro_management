/// Model đại diện cho Chỉ số Điện Nước hàng tháng (UtilityReading)
/// Dùng để tính toán lượng tiêu thụ và thành tiền trong hóa đơn
class UtilityReadingModel {
  final int id;
  final int roomId;
  final String monthYear; // Định dạng "YYYY-MM"
  final int oldElec;      // Chỉ số điện cũ
  final int newElec;      // Chỉ số điện mới
  final int oldWater;     // Chỉ số nước cũ
  final int newWater;     // Chỉ số nước mới
  final DateTime readingDate; // Ngày ghi chỉ số
  final DateTime createdAt;

  UtilityReadingModel({
    required this.id,
    required this.roomId,
    required this.monthYear,
    required this.oldElec,
    required this.newElec,
    required this.oldWater,
    required this.newWater,
    required this.readingDate,
    required this.createdAt,
  });

  /// Chuyển đổi từ dữ liệu JSON của Supabase sang Model
  factory UtilityReadingModel.fromJson(Map<String, dynamic> json) {
    return UtilityReadingModel(
      id: json['id'] as int,
      roomId: json['room_id'] as int,
      monthYear: json['month_year'] as String,
      oldElec: json['old_elec'] as int,
      newElec: json['new_elec'] as int,
      oldWater: json['old_water'] as int,
      newWater: json['new_water'] as int,
      readingDate: DateTime.parse(json['reading_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Chuyển đổi từ Model sang JSON để lưu trữ
  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'month_year': monthYear,
      'old_elec': oldElec,
      'new_elec': newElec,
      'old_water': oldWater,
      'new_water': newWater,
      'reading_date': readingDate.toIso8601String(),
    };
  }
}
