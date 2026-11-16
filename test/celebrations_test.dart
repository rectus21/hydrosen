import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/features/thermos/celebration_painter.dart';
import 'package:hydrosen/features/thermos/celebrations/celebration_registry.dart';
import 'package:hydrosen/features/thermos/celebrations/celebrations_g1.dart';
import 'package:hydrosen/features/thermos/celebrations/celebrations_g2.dart';
import 'package:hydrosen/features/thermos/celebrations/celebrations_g3.dart';
import 'package:hydrosen/features/thermos/celebrations/celebrations_g4.dart';
import 'package:hydrosen/features/thermos/thermos_painter.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';

void main() {
  final all = <String, SignatureCelebration>{
    ...g1Celebrations,
    ...g2Celebrations,
    ...g3Celebrations,
    ...g4Celebrations,
  };

  test('kayit tum grup haritalarini birlestirir ve temalar gecerli', () {
    expect(signatureCelebrations.keys.toSet(), all.keys.toSet());
    final ids = ThermosTheme.all.map((t) => t.id).toSet();
    for (final id in [...all.keys, ...signatureCapPoses.keys]) {
      expect(ids, contains(id), reason: 'bilinmeyen tema id: $id');
    }
  });

  for (final id in all.keys) {
    final theme = ThermosTheme.all.firstWhere((t) => t.id == id);
    for (final shape in ThermosShape.values) {
      for (final reduce in [false, true]) {
        test('$id x ${shape.label} reduceMotion=$reduce hatasiz cizilir', () {
          for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
            final painter = CelebrationPainter(
              theme: theme,
              shape: shape,
              t: t,
              reduceMotion: reduce,
            );
            final r = PictureRecorder();
            painter.paint(Canvas(r), const Size(330, 380));
            r.endRecording().dispose();

            // Kapak pozu ile termos da cizilir.
            final pr = PictureRecorder();
            ThermosPainter(
              shape: shape,
              theme: theme,
              level: 1,
              goalMl: 2000,
              time: 0,
              slosh: 0,
              happy: true,
              capPose: resolveCapPose(painter),
            ).paint(Canvas(pr), const Size(330, 380));
            pr.endRecording().dispose();
          }
        });
      }
    }
  }
}
