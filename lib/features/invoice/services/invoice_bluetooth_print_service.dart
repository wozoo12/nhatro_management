import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:intl/intl.dart';

class InvoiceBluetoothPrintService {
  static final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  /// Lấy danh sách các thiết bị Bluetooth đã ghép nối
  static Future<List<BluetoothInfo>> getPairedDevices() async {
    return await PrintBluetoothThermal.pairedBluetooths;
  }

  /// Trạng thái kết nối
  static Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  /// Khởi tạo kết nối
  static Future<bool> connect(String macAddress) async {
    return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  /// Ngắt kết nối
  static Future<bool> disconnect() async {
    return await PrintBluetoothThermal.disconnect;
  }

  /// In hóa đơn khổ 58mm
  static Future<bool> printInvoice({
    required String roomNumber,
    required String tenantName,
    required String phoneNumber,
    required String monthYear,
    required String dueDate,
    required double roomRent,
    required double serviceFee,
    required int elecUsage,
    required double elecRate,
    required int elecBefore,
    required int elecAfter,
  }) async {
    bool connected = await isConnected();
    if (!connected) return false;

    List<int> bytes = [];

    // Các lệnh ESC/POS cơ bản
    const int esc = 27;
    // const int gs = 29;
    
    // Khởi tạo máy in
    bytes += [esc, 64]; 
    
    // Căn giữa
    bytes += [esc, 97, 1]; 
    
    // Tiêu đề to
    bytes += _encode('HOA DON TIEN TRO\n');
    bytes += [esc, 97, 1]; // Giữ căn giữa
    
    final displayMonth = _formatMonthYear(monthYear);
    bytes += _encode('Thang $displayMonth\n\n');
    
    // Căn trái
    bytes += [esc, 97, 0];
    
    bytes += _encode('Phong:       $roomNumber\n');
    bytes += _encode('Nguoi thue:  $tenantName\n');
    bytes += _encode('Dien thoai:  $phoneNumber\n');
    bytes += _encode('Han dong:    $dueDate\n');
    
    bytes += _encode('--------------------------------\n');
    
    // Chi tiết phí
    final elecTotal = elecUsage * elecRate;
    final grandTotal = roomRent + serviceFee + elecTotal;
    
    bytes += _encode('Tien phong: ${_formatMoney(roomRent)}\n');
    bytes += _encode('Dich vu:    ${_formatMoney(serviceFee)}\n');
    bytes += _encode('Tien dien:  ${_formatMoney(elecTotal)}\n');
    bytes += _encode('(So cu: $elecBefore, So moi: $elecAfter)\n');
    
    bytes += _encode('--------------------------------\n');
    
    // In đậm và phóng to nhẹ tổng tiền (nếu máy in hỗ trợ)
    bytes += [esc, 69, 1]; // Bật in đậm
    bytes += _encode('TONG CONG:  ${_formatMoney(grandTotal)}\n');
    bytes += [esc, 69, 0]; // Tắt in đậm
    
    bytes += _encode('\n\n'); // Kéo giấy
    bytes += _encode('Cam on ban da su dung dich vu!\n');
    bytes += _encode('\n\n\n\n'); // Cắt giấy hoặc kéo khoảng trắng thêm
    
    return await PrintBluetoothThermal.writeBytes(bytes);
  }

  static String _formatMonthYear(String my) {
    try {
      final parts = my.split('-');
      if (parts.length == 2) return '${parts[1]}/${parts[0]}';
    } catch (_) {}
    return my;
  }

  static String _formatMoney(double amount) {
    return _currencyFormat.format(amount);
  }
  
  // Convert string to bytes (without accents for thermal printer compatibility)
  static List<int> _encode(String text) {
    // Để an toàn với máy in 58mm thông thường (thường chỉ hỗ trợ ASCII), 
    // chúng ta chuyển về không dấu nếu cần, hoặc dùng UTF8 (nếu máy in hỗ trợ)
    return text.codeUnits;
  }
}
