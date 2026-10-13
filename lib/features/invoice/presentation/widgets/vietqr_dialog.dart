import 'package:flutter/material.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../services/vietqr_service.dart';

/// Dialog hiển thị mã VietQR động để khách quét chuyển khoản.
class VietQRDialog extends StatelessWidget {
  final String roomNumber;
  final String monthYear;
  final double amount;
  final String tenantName;

  static const Color primaryBlue = Color(0xFF2E7D32);
  static const Color mutedText = Color(0xFF64748B);

  const VietQRDialog({
    super.key,
    required this.roomNumber,
    required this.monthYear,
    required this.amount,
    required this.tenantName,
  });

  @override
  Widget build(BuildContext context) {
    final transferContent = VietQRService.buildTransferContent(
      roomNumber: roomNumber,
      monthYear: monthYear,
    );
    final qrUrl = VietQRService.generateQrImageUrl(
      amount: amount,
      transferContent: transferContent,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quét mã VietQR để thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Phòng $roomNumber — $tenantName',
              style: const TextStyle(fontSize: 13, color: mutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                qrUrl,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(child: CircularProgressIndicator(color: primaryBlue)),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 220,
                  height: 220,
                  color: const Color(0xFFF1F5F9),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 48, color: mutedText),
                      SizedBox(height: 8),
                      Text('Không tải được QR', style: TextStyle(color: mutedText, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _infoTile('Ngân hàng', PaymentConstants.bankName),
            _infoTile('Số TK', PaymentConstants.accountNumber),
            _infoTile('Chủ TK', PaymentConstants.accountName),
            _infoTile('Nội dung CK', transferContent),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: mutedText)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
