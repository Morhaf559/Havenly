// Widget: Custom Ticket Icon Painter
import 'package:flutter/material.dart';

class TicketIconPainter extends CustomPainter {
  final Color color;

  TicketIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw ticket shape - rectangle with rounded corners
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(3),
    );

    // Draw outer rectangle
    canvas.drawRRect(rect, paint);

    // Draw vertical dashed line in the middle
    final dashPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final dashLength = 3.0;
    final dashSpace = 2.0;
    double currentY = size.height * 0.15;
    final bottomY = size.height * 0.85;

    while (currentY < bottomY) {
      final endY = (currentY + dashLength).clamp(0.0, bottomY);
      canvas.drawLine(
        Offset(centerX, currentY),
        Offset(centerX, endY),
        dashPaint,
      );
      currentY += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




