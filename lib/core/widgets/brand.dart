import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The LocalMind mark: a ring (the phone's boundary) holding a core dot (the
/// model on the device), with a spark where the ring opens. Drawn in code so
/// the same shape renders the in-app logo, the launcher icon and the splash.
class LogoPainter extends CustomPainter {
  const LogoPainter({
    this.background = true,
    this.foreground = Colors.white,
    this.gradient = AppPalette.brandGradient,
    this.scale = 1,
  });

  /// Draws the rounded-square gradient tile behind the mark.
  final bool background;
  final Color foreground;
  final List<Color> gradient;

  /// Size of the mark relative to the canvas (adaptive icons need ~0.6).
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & size;
    if (background) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(s * 0.28)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ).createShader(rect),
      );
    }
    final c = rect.center;
    final k = s * scale;
    final paint = Paint()
      ..color = foreground
      ..isAntiAlias = true;

    // Ring, open towards the top right where the spark sits.
    final r = k * 0.27;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 4 + 0.55,
      2 * math.pi - 1.1,
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = k * 0.075
        ..strokeCap = StrokeCap.round,
    );

    // Core.
    canvas.drawCircle(c, k * 0.085, paint..style = PaintingStyle.fill);

    // Four-point spark on the ring's opening.
    final sc = c + Offset(math.cos(-math.pi / 4), math.sin(-math.pi / 4)) * r;
    final a = k * 0.12;
    final b = k * 0.032;
    final spark = Path()
      ..moveTo(sc.dx, sc.dy - a)
      ..quadraticBezierTo(sc.dx + b, sc.dy - b, sc.dx + a, sc.dy)
      ..quadraticBezierTo(sc.dx + b, sc.dy + b, sc.dx, sc.dy + a)
      ..quadraticBezierTo(sc.dx - b, sc.dy + b, sc.dx - a, sc.dy)
      ..quadraticBezierTo(sc.dx - b, sc.dy - b, sc.dx, sc.dy - a)
      ..close();
    canvas.drawPath(spark, paint);
  }

  @override
  bool shouldRepaint(LogoPainter old) =>
      old.background != background ||
      old.foreground != foreground ||
      old.scale != scale ||
      old.gradient != gradient;
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    excludeSemantics: true,
    child: CustomPaint(size: Size.square(size), painter: const LogoPainter()),
  );
}
