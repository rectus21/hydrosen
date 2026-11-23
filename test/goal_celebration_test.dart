import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart' show MaterialApp, Scaffold, SizedBox;
import 'package:hydrosen/features/thermos/celebration_overlay.dart';

import 'package:flutter/widgets.dart'
    show CustomPaint, Text, TextPainter, TextSpan, TextStyle, FontWeight, TextDirection, StateSetter, StatefulBuilder, MediaQuery, MediaQueryData;
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/home/goal_celebration.dart';
import 'package:hydrosen/features/home/water_controller.dart';
import 'package:hydrosen/features/thermos/celebration_painter.dart';
import 'package:hydrosen/features/thermos/celebration_style.dart';
import 'package:hydrosen/features/thermos/celebrations/celebration_registry.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';

void main() {
  final day = DateTime(2026, 11, 10, 14);
  final nextDay = DateTime(2026, 11, 11, 9);

  group('GoalCelebrationTracker', () {
    bool obs(
      GoalCelebrationTracker g,
      int total, {
      int goal = 2000,
      DateTime? now,
    }) => g.observe(now: now ?? day, totalMl: total, goalMl: goal);

    test('ilk gözlem kutlatmaz (açılışta hedef zaten aşılmış olsa da)', () {
      final g = GoalCelebrationTracker();
      expect(obs(g, 2500), isFalse);
      expect(obs(g, 2750), isFalse); // hedefin üstünde kaldıkça tekrar yok
    });

    test('aşağıdan yukarı geçişte bir kez kutlar', () {
      final g = GoalCelebrationTracker();
      expect(obs(g, 0), isFalse);
      expect(obs(g, 1500), isFalse);
      expect(obs(g, 2000), isTrue); // tam hedef de sayılır
      expect(obs(g, 2000), isFalse); // yeniden çizim / aynı durum
      expect(obs(g, 2250), isFalse);
    });

    test('hedefin altına inip yeniden geçince tekrar kutlar', () {
      final g = GoalCelebrationTracker();
      obs(g, 1800);
      expect(obs(g, 2100), isTrue);
      expect(obs(g, 1850), isFalse); // geri alma
      expect(obs(g, 2100), isTrue);
    });

    test('hedefi ayarlardan düşürmek kutlatmaz', () {
      final g = GoalCelebrationTracker();
      obs(g, 1500);
      expect(obs(g, 1500, goal: 1500), isFalse);
      // Hedef yükseltilip su eklenerek yeniden geçilirse kutlar.
      expect(obs(g, 1500, goal: 2000), isFalse);
      expect(obs(g, 2000, goal: 2000), isTrue);
    });

    test('yeni gün sıfırdan başlar', () {
      final g = GoalCelebrationTracker();
      obs(g, 1000);
      expect(obs(g, 2000), isTrue);
      expect(obs(g, 0, now: nextDay), isFalse);
      expect(obs(g, 2000, now: nextDay), isTrue);
    });

    test('gece yarısını geçen açık uygulamada ilk ekleme hedefi geçerse '
        'kutlar', () {
      final g = GoalCelebrationTracker();
      obs(g, 2500); // dün, hedef aşılmış
      expect(obs(g, 2000, now: nextDay), isTrue);
    });

    test('hedef 0 ise asla kutlamaz', () {
      final g = GoalCelebrationTracker();
      obs(g, 0, goal: 0);
      expect(obs(g, 500, goal: 0), isFalse);
    });
  });

  group('WaterController.celebrations', () {
    test('ekleme hedefi geçince artar, açılışta artmaz, geri alınıp yeniden '
        'geçince yine artar', () async {
      final repo = InMemoryWaterRepository();
      await repo.save([WaterEntry(id: 1, amountMl: 1800, time: day)]);
      final c = WaterController(repository: repo, goalMl: 2000, now: () => day);
      expect(c.celebrations, 0);
      await c.load();
      expect(c.celebrations, 0);

      await c.add(250);
      expect(c.celebrations, 1);
      await c.add(250);
      expect(c.celebrations, 1);

      await c.remove(c.todayEntries.first.id);
      await c.remove(c.todayEntries.first.id); // 1800 ml
      expect(c.celebrations, 1);
      await c.add(500);
      expect(c.celebrations, 2);
    });

    test('açılışta hedef zaten aşılmışsa kutlama sayılmaz', () async {
      final repo = InMemoryWaterRepository();
      await repo.save([WaterEntry(id: 1, amountMl: 2400, time: day)]);
      final c = WaterController(repository: repo, goalMl: 2000, now: () => day);
      await c.load();
      await c.add(100);
      expect(c.celebrations, 0);
    });

    test('hedef düşürülünce kutlama sayılmaz', () async {
      final c = WaterController(
        repository: InMemoryWaterRepository(),
        goalMl: 2000,
        now: () => day,
      );
      await c.load();
      await c.add(1500);
      c.goalMl = 1000;
      expect(c.celebrations, 0);
    });
  });

  group('CelebrationPainter', () {
    for (final theme in ThermosTheme.all) {
      for (final shape in ThermosShape.values) {
        test('${theme.name} × ${shape.label} kutlaması hatasız çizilir', () {
          for (final t in [0.0, 0.05, 0.3, 0.6, 0.9, 1.0]) {
            final recorder = PictureRecorder();
            CelebrationPainter(
              theme: theme,
              shape: shape,
              t: t,
            ).paint(Canvas(recorder), const Size(330, 380));
            recorder.endRecording().dispose();
          }
        });
      }
    }

    for (final kind in CelebrationKind.values) {
      test('genel kutlama türü ${kind.name} (celebration ile) çizilir', () {
        final c = ThermosTheme.classic;
        final theme = ThermosTheme(
          id: 'deneme',
          name: 'Deneme',
          glass: c.glass,
          edge: c.edge,
          water: c.water,
          deepWater: c.deepWater,
          waterSurface: c.waterSurface,
          mark: c.mark,
          label: c.label,
          band: c.band,
          bandLight: c.bandLight,
          background: c.background,
          capChubby: c.capChubby,
          capSlim: c.capSlim,
          celebration: CelebrationStyle(kind, const [0xE24B4A, 0x378ADD]),
        );
        for (final shape in ThermosShape.values) {
          for (final t in [0.0, 0.2, 0.6, 1.0]) {
            final recorder = PictureRecorder();
            CelebrationPainter(
              theme: theme,
              shape: shape,
              t: t,
            ).paint(Canvas(recorder), const Size(330, 380));
            recorder.endRecording().dispose();
          }
        }
      });
    }
  });

  group('Astronot kutlaması', () {
    Future<Uint8List> frame(
      ThermosTheme theme,
      ThermosShape shape,
      double t,
    ) async {
      final recorder = PictureRecorder();
      CelebrationPainter(
        theme: theme,
        shape: shape,
        t: t,
      ).paint(Canvas(recorder), const Size(330, 380));
      final img = await recorder.endRecording().toImage(330, 380);
      final bytes = (await img.toByteData(format: ImageByteFormat.rawRgba))!;
      return bytes.buffer.asUint8List();
    }

    for (final shape in ThermosShape.values) {
      test(
        '${shape.label}: boş değil ve varsayılan damla halkasından farklı',
        () async {
          final astro = await frame(ThermosTheme.astronaut, shape, 0.5);
          expect(
            astro.any((b) => b != 0),
            isTrue,
            reason: 'hiçbir şey çizilmedi',
          );
          final droplet = await frame(ThermosTheme.classic, shape, 0.5);
          expect(astro, isNot(droplet));
        },
      );
    }

    testWidgets('animasyonlar azaltılmış olsa da kutlama çizilir', (
      tester,
    ) async {
      for (final reduce in [false, true]) {
        var trigger = 0;
        late StateSetter set;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduce),
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    set = setState;
                    return SizedBox(
                      width: 330,
                      height: 380,
                      child: CelebrationOverlay(
                        trigger: trigger,
                        theme: ThermosTheme.astronaut,
                        shape: ThermosShape.chubby,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        set(() => trigger++);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        final painted = find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is CelebrationPainter,
        );
        expect(painted, findsOneWidget, reason: 'reduce=$reduce');
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    });
  });

  group('Kutlama yazısı görünürlüğü', () {
    for (final reduce in [false, true]) {
      testWidgets('Astronot banner yazısı görünür (disableAnimations=$reduce)',
          (tester) async {
        var trigger = 0;
        late StateSetter set;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduce),
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    set = setState;
                    return SizedBox(
                      width: 330,
                      height: 380,
                      child: CelebrationOverlay(
                        trigger: trigger,
                        theme: ThermosTheme.astronaut,
                        shape: ThermosShape.chubby,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        set(() => trigger++);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        final text = find.text(CelebrationOverlay.message);
        expect(text, findsOneWidget);
        final style = tester.widget<Text>(text).style!;
        expect(style.color!.computeLuminance(), lessThan(0.3),
            reason: 'beyaz zeminde açık renk yazı okunmaz');
        await tester.pumpAndSettle(const Duration(seconds: 3));
      });
    }

    for (final shape in ThermosShape.values) {
      test('${shape.label}: vizör yazısı ölçülebilir ve çizilir', () {
        final tp = TextPainter(
          text: const TextSpan(
            text: CelebrationPainter.visorStaticText,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        expect(tp.width, greaterThan(0));
        final recorder = PictureRecorder();
        CelebrationPainter(
          theme: ThermosTheme.astronaut,
          shape: shape,
          t: 0.5,
          reduceMotion: true,
        ).paint(Canvas(recorder), const Size(330, 380));
        recorder.endRecording().dispose();
      });
    }
  });

  test('kaldırılan Botanik teması kayıtlı olsa da Klasik e düşer', () {
    expect(ThermosTheme.all.any((t) => t.id == 'botanik'), isFalse);
    expect(ThermosTheme.byId('botanik').id, 'klasik');
    expect(ThermosTheme.byId('botanik'), same(ThermosTheme.classic));
  });

  test('kaldırılan Şeftali teması kayıtlı olsa da Klasik e düşer', () {
    expect(ThermosTheme.all.any((t) => t.id == 'seftali'), isFalse);
    expect(ThermosTheme.byId('seftali'), same(ThermosTheme.classic));
    expect(signatureCelebrations.containsKey('seftali'), isFalse);
    expect(signatureLoops.containsKey('seftali'), isFalse);
  });
}
