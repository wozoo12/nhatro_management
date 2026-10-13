import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LozidoCard extends StatelessWidget {
  final Widget child;
  final Color? statusColor; // Vạch màu bên trái nhận diện trạng thái
  final bool isDashed;      // Có dùng viền nét đứt hay không
  final bool isSelected;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const LozidoCard({
    super.key,
    required this.child,
    this.statusColor,
    this.isDashed = false,
    this.isSelected = false,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: isDashed ? _DashedPainter(
          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
          strokeWidth: isSelected ? 1.5 : 1,
        ) : null,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mintBg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: (isDashed || isSelected) ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (statusColor != null)
                Positioned(
                  left: -padding.left,
                  top: -padding.top,
                  bottom: -padding.bottom,
                  child: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _DashedPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    
    final Path dashPath = Path();
    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
