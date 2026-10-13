import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Dịch vụ xuất hóa đơn ra file PDF và chia sẻ.
class InvoicePdfService {
  static final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'd', decimalDigits: 0);

  /// Tạo PDF hóa đơn, lưu tạm và mở dialog chia sẻ.
  static Future<void> exportAndShare({
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
    required double grandTotal,
  }) async {
    final pdf = pw.Document();
    final displayMonth = _formatMonthYear(monthYear);
    final elecTotal = elecUsage * elecRate;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                color: PdfColors.blue800,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('HOA DON TIEN TRO', style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('Thang $displayMonth', style: pw.TextStyle(color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              _pdfRow('Phong', 'Phong $roomNumber'),
              _pdfRow('Nguoi thue', tenantName),
              _pdfRow('Dien thoai', phoneNumber),
              _pdfRow('Han dong tien', dueDate, highlight: true),
              pw.Divider(),
              _pdfRow('Tien thue phong', _currencyFormat.format(roomRent)),
              _pdfRow('Rac + Nuoc', _currencyFormat.format(serviceFee)),
              _pdfRow('Dien ($elecUsage so x ${_currencyFormat.format(elecRate)})', _currencyFormat.format(elecTotal)),
              pw.Text('Chi so: $elecBefore -> $elecAfter', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TONG CONG', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text(_currencyFormat.format(grandTotal), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ],
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/hoa_don_p${roomNumber}_$monthYear.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Hoa don tien tro - Phong $roomNumber - Thang $displayMonth',
    );
  }

  static pw.Widget _pdfRow(String label, String value, {bool highlight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: highlight ? PdfColors.red : PdfColors.black)),
        ],
      ),
    );
  }

  static String _formatMonthYear(String my) {
    try {
      final parts = my.split('-');
      if (parts.length == 2) return '${int.parse(parts[1])}/${parts[0]}';
    } catch (_) {}
    return my;
  }
}
