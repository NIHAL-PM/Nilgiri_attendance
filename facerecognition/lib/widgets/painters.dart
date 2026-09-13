import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Animated face mesh + corner brackets + sweeping radar line.
class FaceScannerPainter extends CustomPainter {
  final double scanValue;
  final Color accentColor;

  const FaceScannerPainter({required this.scanValue, this.accentColor = AppTheme.cyan});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 30);
    final rectW = size.width * 0.72;
    final rectH = size.height * 0.5;
    final rect = Rect.fromCenter(center: center, width: rectW, height: rectH);
    const cornerLen = 32.0;

    // Corner brackets
    final bp = Paint()..color = Colors.white.withValues(alpha: 0.85)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    void corner(Offset o, double dx, double dy) {
      canvas.drawLine(o, o + Offset(dx, 0), bp);
      canvas.drawLine(o, o + Offset(0, dy), bp);
    }
    corner(rect.topLeft,    cornerLen,  cornerLen);
    corner(rect.topRight,  -cornerLen,  cornerLen);
    corner(rect.bottomLeft, cornerLen, -cornerLen);
    corner(rect.bottomRight,-cornerLen,-cornerLen);

    // Facial landmark nodes
    final np = Paint()..color = accentColor..style = PaintingStyle.fill;
    final lp = Paint()..color = accentColor.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 1;
    final nodes = [
      center + const Offset(-45, -35),
      center + const Offset(45, -35),
      center + const Offset(0, 18),
      center + const Offset(-32, 62),
      center + const Offset(32, 62),
      center + const Offset(0, 96),
    ];
    for (final pair in [[0,2],[1,2],[2,3],[2,4],[3,5],[4,5],[3,4]]) {
      canvas.drawLine(nodes[pair[0]], nodes[pair[1]], lp);
    }
    for (final n in nodes) {
      canvas.drawCircle(n, 4, np);
      canvas.drawCircle(n, 10, Paint()..color = accentColor.withValues(alpha: 0.18)..style = PaintingStyle.fill);
    }

    // Sweeping radar line
    final scanY = rect.top + rect.height * scanValue;
    final rp = Paint()
      ..shader = LinearGradient(colors: [
        accentColor.withValues(alpha: 0.0), accentColor,
        AppTheme.red, AppTheme.gold, AppTheme.gold.withValues(alpha: 0.0),
      ], stops: const [0, 0.2, 0.5, 0.8, 1]).createShader(
          Rect.fromLTWH(rect.left, scanY, rectW, 4))
      ..style = PaintingStyle.stroke..strokeWidth = 2.5;
    canvas.drawLine(Offset(rect.left - 20, scanY), Offset(rect.right + 20, scanY), rp);
    canvas.drawLine(Offset(rect.left, scanY), Offset(rect.right, scanY),
      Paint()..color = accentColor.withValues(alpha: 0.4)..strokeWidth = 10
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
  }

  @override
  bool shouldRepaint(covariant FaceScannerPainter old) => old.scanValue != scanValue;
}

/// Gradient arc progress ring.
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  const CircularProgressPainter({required this.progress, this.color = AppTheme.cyan});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(c, r, Paint()..color = AppTheme.bgCard.withValues(alpha: 0.9)..style = PaintingStyle.fill);
    canvas.drawCircle(c, r, Paint()..color = Colors.white.withValues(alpha: 0.06)..style = PaintingStyle.stroke..strokeWidth = 4);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..shader = SweepGradient(
            colors: [color, AppTheme.green],
            startAngle: -math.pi / 2,
            endAngle: 3 * math.pi / 2,
          ).createShader(Rect.fromCircle(center: c, radius: r))
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter old) => old.progress != progress;
}

/// Subtle grid for the geofence map background.
class MapGridPainter extends CustomPainter {
  const MapGridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.04)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 7-day attendance bar chart.
class WeeklyBarPainter extends CustomPainter {
  final List<bool> days; // true = present
  const WeeklyBarPainter({required this.days});

  @override
  void paint(Canvas canvas, Size size) {
    final count = days.length;
    final barW = (size.width - (count - 1) * 8) / count;
    for (int i = 0; i < count; i++) {
      final present = days[i];
      final color = present ? AppTheme.green : AppTheme.red.withValues(alpha: 0.5);
      final h = present ? size.height : size.height * 0.35;
      final x = i * (barW + 8);
      final y = size.height - h;
      final rr = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, h), const Radius.circular(4));
      canvas.drawRRect(rr, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyBarPainter old) => old.days != days;
}
