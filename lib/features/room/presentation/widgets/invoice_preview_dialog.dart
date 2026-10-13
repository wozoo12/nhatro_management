import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhatro_management/core/utils/zalo_service.dart';
import 'package:nhatro_management/features/invoice/services/vietqr_service.dart';
import 'package:nhatro_management/features/invoice/services/invoice_pdf_service.dart';
import 'package:nhatro_management/features/invoice/presentation/widgets/bluetooth_printer_dialog.dart';

class InvoicePreviewDialog extends StatelessWidget {
  final String roomNumber;
  final String tenantName;
  final String phoneNumber;
  final String monthYear;
  final String dueDate;
  final double roomRent;
  final double serviceFee;
  final int elecUsage;
  final double elecRate;
  final int elecBefore;
  final int elecAfter;
  
  // Các trường mới được thêm vào để khớp với Dashboard
  final int? invoiceId;
  final int? propertyId;
  final String? status;

  static const Color accentBlue = Color(0xFF4CAF50);
  static const Color primaryBlue = Color(0xFF2E7D32);
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color mutedText = Color(0xFF64748B);
  static const Color alertRed = Color(0xFFDC2626);

  const InvoicePreviewDialog({
    super.key,
    required this.roomNumber,
    required this.tenantName,
    required this.phoneNumber,
    required this.monthYear,
    required this.dueDate,
    required this.roomRent,
    required this.serviceFee,
    required this.elecUsage,
    required this.elecRate,
    required this.elecBefore,
    required this.elecAfter,
    this.invoiceId,
    this.propertyId,
    this.status,
  });

  String _formatMonthYear(String my) {
    try {
      final parts = my.split('-');
      if (parts.length == 2) return '${parts[1]}/${parts[0]}';
    } catch (_) {}
    return my;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final double elecTotal = elecUsage * elecRate;
    final double grandTotal = roomRent + serviceFee + elecTotal;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Text('HÓA ĐƠN THÁNG ${_formatMonthYear(monthYear)}', 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
            const Divider(),
            _buildRow('Phòng', roomNumber),
            _buildRow('Khách thuê', tenantName),
            _buildRow('Hạn đóng', dueDate),
            const Divider(),
            _buildRow('Tiền phòng', currencyFormat.format(roomRent)),
            _buildRow('Dịch vụ', currencyFormat.format(serviceFee)),
            _buildRow('Tiền điện', currencyFormat.format(elecTotal)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TỔNG CỘNG', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(currencyFormat.format(grandTotal), 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: alertRed)),
              ],
            ),
            const SizedBox(height: 16),
            // Mã QR Thanh toán
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Quét mã để thanh toán', style: TextStyle(fontSize: 12, color: mutedText, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Image.network(
                    VietQRService.generateQrImageUrl(
                      amount: grandTotal, 
                      transferContent: VietQRService.buildTransferContent(roomNumber: roomNumber, monthYear: monthYear),
                    ),
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      height: 120, width: 120,
                      child: Center(child: Icon(Icons.qr_code, color: Colors.grey, size: 50)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      InvoicePdfService.exportAndShare(
                        roomNumber: roomNumber,
                        tenantName: tenantName,
                        phoneNumber: phoneNumber,
                        monthYear: monthYear,
                        dueDate: dueDate,
                        roomRent: roomRent,
                        serviceFee: serviceFee,
                        elecUsage: elecUsage,
                        elecRate: elecRate,
                        elecBefore: elecBefore,
                        elecAfter: elecAfter,
                        grandTotal: grandTotal,
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Chia sẻ PDF'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => BluetoothPrinterDialog(
                          invoiceData: {
                            'roomNumber': roomNumber,
                            'tenantName': tenantName,
                            'phoneNumber': phoneNumber,
                            'monthYear': monthYear,
                            'dueDate': dueDate,
                            'roomRent': roomRent,
                            'serviceFee': serviceFee,
                            'elecUsage': elecUsage,
                            'elecRate': elecRate,
                            'elecBefore': elecBefore,
                            'elecAfter': elecAfter,
                            'grandTotal': grandTotal,
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('In Hóa đơn'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ZaloService.openZaloChat(
                    phoneNumber, 
                    message: ZaloService.buildInvoiceMessage(
                      roomNumber: roomNumber, 
                      monthYear: monthYear, 
                      totalAmount: grandTotal, 
                      dueDate: dueDate
                    )
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0068FF), foregroundColor: Colors.white),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Gửi Zalo cho khách'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
              ),
            )
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: mutedText)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
