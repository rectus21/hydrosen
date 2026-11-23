import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/features/thermos/celebration_painter.dart';
import 'package:hydrosen/features/thermos/celebrations/celebration_registry.dart';
import 'package:hydrosen/features/thermos/celebrations/fx_sprites.dart';
import 'package:hydrosen/features/thermos/thermos_painter.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const ids = [
    'kopek',
    'penguen',
    'koala',
    'koyun',
    'avokado',
    'kaktus',
    'baykus',
    'civciv',
    'rakun',
    'kamp',
    'okyanus',
  ];

  void paint(CelebrationPainter p) {
    final r = PictureRecorder();
    p.paint(Canvas(r), const Size(330, 380));
    r.endRecording().dispose();
    final pr = PictureRecorder();
    ThermosPainter(
      shape: p.shape,
      theme: p.theme,
      level: 1,
      goalMl: 2000,
      time: 0,
      slosh: 0,
      happy: true,
      capPose: resolveCapPose(p),
    ).paint(Canvas(pr), const Size(330, 380));
    pr.endRecording().dispose();
  }

  test('sprite dosyalari yuklenir', () async {
    await FxSprites.load();
    expect(FxSprites.loaded, isTrue);
  });

  for (final id in ids) {
    final theme = ThermosTheme.all.firstWhere((t) => t.id == id);
    for (final shape in ThermosShape.values) {
      test('$id x ${shape.label}: giris t=0.5, tum t, dongu, hareket azaltilmis',
          () async {
        await FxSprites.load();
        expect(signatureCelebrations, contains(id));
        expect(signatureLoops, contains(id));
        paint(CelebrationPainter(theme: theme, shape: shape, t: 0.5));
        for (var i = 0; i <= 20; i++) {
          paint(CelebrationPainter(theme: theme, shape: shape, t: i / 20));
        }
        for (var i = 0; i < 24; i++) {
          paint(CelebrationPainter.looping(
            theme: theme,
            shape: shape,
            loop: i / 24,
            loopCount: i % 5,
          ));
        }
        paint(CelebrationPainter(
          theme: theme,
          shape: shape,
          t: 0.5,
          reduceMotion: true,
        ));
      });
    }
  }
}
