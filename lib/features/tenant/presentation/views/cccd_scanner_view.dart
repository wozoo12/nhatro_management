import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cccd_parser.dart';
import '../../data/models/cccd_qr_model.dart';

/// Màn hình quét mã QR Căn cước công dân gắn chip
/// Trả về đối tượng [CccdQrModel] khi quét thành công
class CccdScannerView extends StatefulWidget {
  const CccdScannerView({super.key});

  @override
  State<CccdScannerView> createState() => _CccdScannerViewState();
}

class _CccdScannerViewState extends State<CccdScannerView> with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animController;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _handleQrContent(rawValue);
        break;
      }
    }
  }

  void _handleQrContent(String rawValue) {
    try {
      setState(() => _isProcessing = true);
      final cccdModel = CccdParser.parse(rawValue);

      if (mounted) {
        Navigator.pop(context, cccdModel);
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.dangerRed,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isProcessing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không thể nhận diện mã QR CCCD này'),
            backgroundColor: AppColors.dangerRed,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final BarcodeCapture? capture = await _scannerController.analyzeImage(file.path);
        if (capture != null && capture.barcodes.isNotEmpty) {
          final raw = capture.barcodes.first.rawValue;
          if (raw != null) {
            _handleQrContent(raw);
            return;
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy mã QR hợp lệ trong ảnh đã chọn'),
              backgroundColor: AppColors.dangerRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi quét ảnh từ thư viện: $e');
    }
  }

  /// Hỗ trợ nạp dữ liệu mẫu nhanh cho môi trường test / máy ảo không có camera
  void _useMockDataDialog() {
    final mockSamples = [
      {
        'title': 'Nguyễn Hoàng Sang (TP.HCM)',
        'raw': '079095012345|025812345|NGUYỄN HOÀNG SANG|23081996|Nam|Phường Linh Trung, TP. Thủ Đức, TP. Hồ Chí Minh|10052021',
      },
      {
        'title': 'Trần Thị Mai (Hà Nội)',
        'raw': '001201012345||TRẦN THỊ MAI|05012000|Nữ|Ba Đình, Hà Nội|15122022',
      },
      {
        'title': 'Lê Văn An (Đà Nẵng)',
        'raw': '048098007788|201889977|LÊ VĂN AN|12101998|Nam|Hải Châu, Đà Nẵng|20032023',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.developer_mode, color: AppColors.primaryGreen),
                SizedBox(width: 8),
                Text('Chọn mẫu thử nghiệm (Test Mock)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Dành cho môi trường Máy ảo / Desktop test nhanh mà không cần thẻ CCCD thật:',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...mockSamples.map(
              (m) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.mintBg,
                  child: Icon(Icons.badge, color: AppColors.primaryGreen),
                ),
                title: Text(m['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(m['raw']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleQrContent(m['raw']!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera MobileScanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // 2. Viewfinder Overlay (Khung ngắm quét CCCD)
          _buildScannerOverlay(context),

          // 3. Thanh điều hướng trên cùng (Top bar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      'Quét mã QR CCCD',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(Icons.flash_on, color: Colors.white),
                            onPressed: () => _scannerController.toggleTorch(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(Icons.cameraswitch, color: Colors.white),
                            onPressed: () => _scannerController.switchCamera(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Thanh công cụ phía dưới (Bottom Actions)
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Căn mã QR ở góc phải thẻ CCCD vào ô vuông ngắm',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text('Từ thư viện'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _useMockDataDialog,
                        icon: const Icon(Icons.play_circle_fill, size: 18, color: AppColors.primaryGreen),
                        label: const Text('Dữ liệu mẫu Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanBoxSize = size.width * 0.72;

    return Stack(
      children: [
        // Lớp mờ xung quanh
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.65), BlendMode.srcOut),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: scanBoxSize,
                  height: scanBoxSize,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Viền và hiệu ứng laser quét
        Align(
          alignment: Alignment.center,
          child: Container(
            width: scanBoxSize,
            height: scanBoxSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryGreen, width: 2.5),
            ),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (ctx, child) {
                return CustomPaint(
                  painter: _ScannerLaserPainter(
                    progress: _animController.value,
                    color: AppColors.primaryGreen,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerLaserPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScannerLaserPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.0), color, color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, size.height * progress, size.width, 3))
      ..strokeWidth = 3;

    final y = size.height * progress;
    canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerLaserPainter oldDelegate) => true;
}
