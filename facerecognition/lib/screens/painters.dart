import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Draws the face bounding box brackets, facial landmark mesh,
/// and the animated radar sweep line used in the scanner screen.
class FaceScannerPainter extends CustomPainter {
  final double scanValue;

  FaceScannerPainter({required this.scanValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 50);
    final rectWidth = size.width * 0.7;
    final rectHeight = size.height * 0.45;
    final rect = Rect.fromCenter(center: center, width: rectWidth, height: rectHeight);

    // 1. Draw Corner Brackets (Target Face Boundary)
    final bracketPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const double length = 30.0;

    // Top Left
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(length, 0), bracketPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, length), bracketPaint);
    // Top Right
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-length, 0), bracketPaint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, length), bracketPaint);
    // Bottom Left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(length, 0), bracketPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -length), bracketPaint);
    // Bottom Right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-length, 0), bracketPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -length), bracketPaint);

    // 2. Mock Facial Landmarks inside the box
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final nodes = [
      center + const Offset(-40, -30), // Left Eye
      center + const Offset(40, -30),  // Right Eye
      center + const Offset(0, 20),    // Nose
      center + const Offset(-30, 60),  // Left Mouth
      center + const Offset(30, 60),   // Right Mouth
      center + const Offset(0, 100),   // Chin
    ];

    // Connect landmark nodes
    canvas.drawLine(nodes[0], nodes[2], linePaint);
    canvas.drawLine(nodes[1], nodes[2], linePaint);
    canvas.drawLine(nodes[2], nodes[3], linePaint);
    canvas.drawLine(nodes[2], nodes[4], linePaint);
    canvas.drawLine(nodes[3], nodes[5], linePaint);
    canvas.drawLine(nodes[4], nodes[5], linePaint);
    canvas.drawLine(nodes[3], nodes[4], linePaint);

    for (var node in nodes) {
      canvas.drawCircle(node, 4.0, nodePaint);
      canvas.drawCircle(
        node,
        10.0,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill,
      );
    }

    // 3. Sweeping Radar Line
    final scanY = rect.top + (rect.height * scanValue);

    final radarPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00F2FE).withValues(alpha: 0.0),
          const Color(0xFF00F2FE),
          const Color(0xFFFF0844),
          const Color(0xFFFEE140),
          const Color(0xFFFEE140).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(rect.left, scanY, rectWidth, 4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(rect.left - 20, scanY),
      Offset(rect.right + 20, scanY),
      radarPaint,
    );

    // Glowing shadow behind the scan line
    canvas.drawLine(
      Offset(rect.left, scanY),
      Offset(rect.right, scanY),
      Paint()
        ..color = const Color(0xFF00F2FE).withValues(alpha: 0.5)
        ..strokeWidth = 10.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(covariant FaceScannerPainter oldDelegate) {
    return oldDelegate.scanValue != scanValue;
  }
}

/// Draws the circular progress ring shown below the scanner viewport.
class CircularProgressPainter extends CustomPainter {
  final double progress;

  CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background dark circle
    final bgPaint = Paint()
      ..color = const Color(0xFF141722).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Track ring
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress gradient ring
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF00F2FE), Color(0xFF00FF87)],
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
