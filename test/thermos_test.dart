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

  void paintOnce(
    ThermosTheme theme,
    ThermosShape shape,
    double level, {
    bool happy = false,
  }) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    ThermosPainter(
      shape: shape,
      theme: theme,
      level: level,
      goalMl: 2000,
      time: 1.2,
      slosh: 3,
      happy: happy,
    ).paint(canvas, const Size(330, 380));
    recorder.endRecording().dispose();
  }

  group('ThermosPainter', () {
    for (final shape in ThermosShape.values) {
      for (final level in [0.0, 0.5, 1.0, 1.4]) {
        test('${shape.label} biçim, doluluk $level hatasız çizilir', () {
          paintOnce(ThermosTheme.classic, shape, level);
        });
      }
    }
  });

  group('Temalar', () {
    test('kimlikler benzersiz, ASCII küçük harf; byId çalışır', () {
      final ids = ThermosTheme.all.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ThermosTheme.all.length, greaterThanOrEqualTo(8));
      for (final t in ThermosTheme.all) {
        expect(t.id, matches(RegExp(r'^[a-z0-9]+$')), reason: t.id);
        expect(t.name.trim(), isNotEmpty);
        expect(ThermosTheme.byId(t.id), same(t));
      }
      expect(ThermosTheme.byId('panda'), ThermosTheme.panda);
      expect(ThermosTheme.byId('yok-boyle-tema'), ThermosTheme.classic);
    });

    for (final theme in ThermosTheme.all) {
      for (final shape in ThermosShape.values) {
        test('${theme.name} × ${shape.label} (normal ve mutlu) çizilir', () {
          paintOnce(theme, shape, 0.6);
          paintOnce(theme, shape, 1.0, happy: true);
        });
      }
    }
  });
}
