import 'package:flutter/material.dart';

class RadarScannerOverlay extends StatefulWidget {
  final String promptText;
  final bool isChallengePassed;

  const RadarScannerOverlay({
    Key? key,
    required this.promptText,
    this.isChallengePassed = false,
  }) : super(key: key);

  @override
  State<RadarScannerOverlay> createState() => _RadarScannerOverlayState();
}

class _RadarScannerOverlayState extends State<RadarScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _RadarPainter(
            sweepProgress: _animationController.value,
            isPassed: widget.isChallengePassed,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double sweepProgress;
  final bool isPassed;

  _RadarPainter({required this.sweepProgress, required this.isPassed});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2 - 40;
    final double ovalWidth = size.width * 0.75;
    final double ovalHeight = size.height * 0.48;

    final Rect ovalRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: ovalWidth,
      height: ovalHeight,
    );

    // Dark transparent background with cutout oval
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path ovalPath = Path()..addOval(ovalRect);
    final Path cutOut = Path.combine(PathOperation.difference, backgroundPath, ovalPath);

    final Paint dimPaint = Paint()..color = Colors.black.withOpacity(0.65);
    canvas.drawPath(cutOut, dimPaint);

    // Oval Border Frame
    final Color strokeColor = isPassed ? const Color(0xFF05FFA1) : const Color(0xFF00F2FE);
    final Paint borderPaint = Paint()
      ..color = strokeColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(ovalRect, borderPaint);

    // Corner targeting brackets
    final Paint bracketPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final double bracketLen = 30.0;
    // Top-left
    canvas.drawLine(Offset(ovalRect.left, ovalRect.top + bracketLen), Offset(ovalRect.left, ovalRect.top), bracketPaint);
    canvas.drawLine(Offset(ovalRect.left, ovalRect.top), Offset(ovalRect.left + bracketLen, ovalRect.top), bracketPaint);
    // Top-right
    canvas.drawLine(Offset(ovalRect.right - bracketLen, ovalRect.top), Offset(ovalRect.right, ovalRect.top), bracketPaint);
    canvas.drawLine(Offset(ovalRect.right, ovalRect.top), Offset(ovalRect.right, ovalRect.top + bracketLen), bracketPaint);
    // Bottom-left
    canvas.drawLine(Offset(ovalRect.left, ovalRect.bottom - bracketLen), Offset(ovalRect.left, ovalRect.bottom), bracketPaint);
    canvas.drawLine(Offset(ovalRect.left, ovalRect.bottom), Offset(ovalRect.left + bracketLen, ovalRect.bottom), bracketPaint);
    // Bottom-right
    canvas.drawLine(Offset(ovalRect.right - bracketLen, ovalRect.bottom), Offset(ovalRect.right, ovalRect.bottom), bracketPaint);
    canvas.drawLine(Offset(ovalRect.right, ovalRect.bottom), Offset(ovalRect.right, ovalRect.bottom - bracketLen), bracketPaint);

    // Glowing Animated Radar Sweep Line inside the viewport
    canvas.save();
    canvas.clipPath(ovalPath);

    final double scanY = ovalRect.top + (ovalRect.height * sweepProgress);
    final Paint scanLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          strokeColor.withOpacity(0.0),
          strokeColor,
          strokeColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(ovalRect.left, scanY - 2, ovalRect.width, 4))
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(ovalRect.left, scanY),
      Offset(ovalRect.right, scanY),
      scanLinePaint,
    );

    // Glowing gradient trail behind scan line
    final Paint trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          strokeColor.withOpacity(0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(ovalRect.left, scanY - 45, ovalRect.width, 45));

    canvas.drawRect(
      Rect.fromLTWH(ovalRect.left, scanY - 45, ovalRect.width, 45),
      trailPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.sweepProgress != sweepProgress || oldDelegate.isPassed != isPassed;
  }
}
