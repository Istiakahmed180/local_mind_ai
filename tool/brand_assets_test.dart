// Renders the launcher icon and splash images from LogoPainter, so every
// brand asset comes from the same code as the in-app logo.
//
//   flutter test tool/brand_assets_test.dart
//
// Writes PNGs under android/app/src/main/res and assets/brand.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/core/widgets/brand.dart';

const _res = 'android/app/src/main/res';
const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

Future<void> _write(
  String path,
  int px,
  void Function(Canvas c, Size s) paint,
) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec);
  final size = Size.square(px.toDouble());
  paint(canvas, size);
  final image = await rec.endRecording().toImage(px, px);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final f = File(path)..createSync(recursive: true);
  f.writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Draws [painter] at [fraction] of the canvas, centred.
void Function(Canvas, Size) _inset(LogoPainter painter, double fraction) =>
    (c, s) {
      final side = s.width * fraction;
      c.save();
      c.translate((s.width - side) / 2, (s.height - side) / 2);
      painter.paint(c, Size.square(side));
      c.restore();
    };

void main() {
  testWidgets('render brand assets', (tester) async {
    await tester.runAsync(() async {
      for (final MapEntry(key: d, value: k) in _densities.entries) {
        // Legacy icon: full tile with a small margin (48dp).
        await _write(
          '$_res/mipmap-$d/ic_launcher.png',
          (48 * k).round(),
          _inset(const LogoPainter(), 0.92),
        );
        // Adaptive foreground and monochrome: white mark inside the 66dp
        // safe zone of the 108dp layer.
        await _write(
          '$_res/mipmap-$d/ic_launcher_foreground.png',
          (108 * k).round(),
          (c, s) => const LogoPainter(background: false, scale: 0.74)
              .paint(c, s),
        );
        // Splash (Android 12+): tile inside the 192dp circle of a 288dp icon.
        await _write(
          '$_res/drawable-$d/splash_icon.png',
          (288 * k).round(),
          _inset(const LogoPainter(), 0.5),
        );
        // Splash before Android 12: plain tile, drawn at 112dp.
        await _write(
          '$_res/drawable-$d/splash_logo.png',
          (112 * k).round(),
          const LogoPainter().paint,
        );
      }
      // Store listing icon (512 px, full bleed square: Play applies the mask).
      await _write(
        'assets/brand/play_store_icon_512.png',
        512,
        (c, s) {
          c.drawRect(
            Offset.zero & s,
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0E6E66), Color(0xFF3B4FA8)],
              ).createShader(Offset.zero & s),
          );
          const LogoPainter(background: false).paint(c, s);
        },
      );
    });
  });
}
