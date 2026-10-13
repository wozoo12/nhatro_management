import 'package:intl/intl.dart';

class AppFormatters {
  static final vnCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  
  static String formatCurrency(double amount) => vnCurrency.format(amount);
  
  static String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  
  static String formatPhone(String phone) {
    if (phone.length == 10) {
      return "${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}";
    }
    return phone;
  }

  // Hậu tố đơn vị nghiệp vụ
  static String area(double value) => "${value.toStringAsFixed(1)} m2";
  static String electricity(int value) => "$value KWh";
  static String water(int value) => "$value Khối";
  static String price(double value) => "${formatCurrency(value)}/tháng";
}
