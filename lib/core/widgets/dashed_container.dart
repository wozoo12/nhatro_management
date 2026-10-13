import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DashedContainer extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;
  final double borderRadius;

  const DashedContainer({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
    this.borderRadius = 12, required Color color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedPainter(
          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
          strokeWidth: isSelected ? 1.5 : 1,
          radius: borderRadius,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mintBg : Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  _DashedPainter({required this.color, required this.strokeWidth, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
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
