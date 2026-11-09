import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/features/thermos/svg_path.dart';
import 'package:hydrosen/features/thermos/thermos_painter.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';

void main() {
  group('svgPath', () {
    test('mutlak komutlar doğru sınırları verir', () {
      final p = svgPath('M10 20 L110 20 L110 70 H10 Z');
      expect(p.getBounds(), const Rect.fromLTRB(10, 20, 110, 70));
    });

    test('göreli komutlar ve Q eğrisi', () {
      final p = svgPath('M0 0 l10 0 v10 h-10 z M50 50 Q60 40 70 50');
      final b = p.getBounds();
      expect(b.left, 0);
      expect(b.top, 0);
      expect(b.right, 70);
      expect(b.bottom, 50);
    });

    test('termos gövde yolları ayrıştırılır', () {
      final chubby = svgPath(
        'M300 208 Q238 220 236 300 L236 420 Q236 476 300 478 L380 478 Q444 476 444 420 L444 300 Q442 220 380 208 Z',
      );
      expect(chubby.getBounds().width, closeTo(208, 1));
      expect(chubby.contains(const Offset(340, 400)), isTrue);
    });

    test('bozuk veri anlaşılır hata verir', () {
      expect(() => svgPath('M10'), throwsFormatException);
      expect(() => svgPath('10 20'), throwsFormatException);
      expect(() => svgPath('M0 0 A1 1 0 0 1 5 5'), throwsFormatException);
    });
  });

  group('ThermosPainter', () {
    for (final shape in ThermosShape.values) {
      for (final level in [0.0, 0.5, 1.0, 1.4]) {
        test('${shape.label} biçim, doluluk $level hatasız çizilir', () {
          final recorder = PictureRecorder();
          final canvas = Canvas(recorder);
          ThermosPainter(
            shape: shape,
            theme: ThermosTheme.classic,
            level: level,
            goalMl: 2000,
            time: 1.2,
            slosh: 3,
          ).paint(canvas, const Size(220, 340));
          recorder.endRecording().dispose();
        });
      }
    }
  });
}
