import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/features/settings/settings_controller.dart';
import 'package:hydrosen/features/thermos/celebration_overlay.dart';
import 'package:hydrosen/features/thermos/celebration_painter.dart';
import 'package:hydrosen/features/thermos/celebrations/celebration_registry.dart';
import 'package:hydrosen/features/thermos/thermos_painter.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Hareketli kutlamalar ayarı', () {
    test('varsayılan açık', () async {
      expect(const AppSettings().animatedCelebrations, isTrue);
      final s = await SharedPrefsSettingsRepository().load();
      expect(s.animatedCelebrations, isTrue);
    });

    test('kapatılınca kalıcı olur ve yeniden okunur', () async {
      final repo = SharedPrefsSettingsRepository();
      final c = SettingsController(repository: repo);
      await c.load();
      await c.setAnimatedCelebrations(false);
      expect(c.animatedCelebrations, isFalse);
      expect((await SharedPrefsSettingsRepository().load()).animatedCelebrations,
          isFalse);
      await c.setAnimatedCelebrations(true);
      expect((await SharedPrefsSettingsRepository().load()).animatedCelebrations,
          isTrue);
    });
  });

  Widget host({
    required bool looping,
    required bool animated,
    bool reduce = true,
    int trigger = 0,
  }) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduce),
      child: Scaffold(
        body: SizedBox(
          width: 330,
          height: 380,
          child: CelebrationOverlay(
            trigger: trigger,
            theme: ThermosTheme.all.firstWhere((t) => t.id == 'boga'),
            shape: ThermosShape.chubby,
            looping: looping,
            animated: animated,
          ),
        ),
      ),
    ),
  );

  final painted = find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter is CelebrationPainter,
  );
  CelebrationPainter? current(WidgetTester t) => painted.evaluate().isEmpty
      ? null
      : (t.widget<CustomPaint>(painted).painter as CelebrationPainter);

  group('Döngü', () {
    testWidgets('açılışta hedefte: girişsiz döngü, azaltılmış harekette de '
        'ilerler', (tester) async {
      await tester.pumpWidget(host(looping: true, animated: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final a = current(tester);
      expect(a, isNotNull);
      expect(a!.looping, isTrue);
      expect(a.reduceMotion, isFalse);
      expect(find.text(CelebrationOverlay.message), findsNothing);
      await tester.pump(const Duration(milliseconds: 700));
      final b = current(tester)!;
      expect(b.t, isNot(a.t));
      expect(b.loop, isNot(a.loop));
      // Bir tur sonra sayaç artar.
      await tester.pump(const Duration(milliseconds: 3000));
      expect(current(tester)!.loopCount, greaterThanOrEqualTo(1));
    });

    testWidgets('ayar kapalı + azaltılmış hareket: döngü yok', (tester) async {
      await tester.pumpWidget(host(looping: true, animated: false));
      await tester.pump(const Duration(milliseconds: 500));
      expect(current(tester), isNull);
    });

    testWidgets('hedefin altına inince durur, tekrar geçince giriş + döngü',
        (tester) async {
      await tester.pumpWidget(host(looping: true, animated: true));
      await tester.pump(const Duration(milliseconds: 400));
      expect(current(tester), isNotNull);
      await tester.pumpWidget(host(looping: false, animated: true));
      await tester.pump(const Duration(milliseconds: 100));
      expect(current(tester), isNull);
      expect(tester.hasRunningAnimations, isFalse);

      // Yeniden aşılır: giriş (banner) sonra döngü.
      await tester.pumpWidget(host(looping: true, animated: true, trigger: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(current(tester)!.looping, isFalse);
      expect(find.text(CelebrationOverlay.message), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump(const Duration(milliseconds: 300));
      expect(current(tester)!.looping, isTrue);
      expect(find.text(CelebrationOverlay.message), findsNothing);
    });

    testWidgets('azaltılmış hareket + ayar açık: giriş t ilerler',
        (tester) async {
      await tester.pumpWidget(host(looping: false, animated: true));
      await tester.pumpWidget(
        host(looping: false, animated: true, trigger: 1),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final a = current(tester)!;
      await tester.pump(const Duration(milliseconds: 500));
      final b = current(tester)!;
      expect(a.reduceMotion, isFalse);
      expect(b.t, greaterThan(a.t));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });

  group('Tüm imzalar döngü evresinde çizilir', () {
    for (final id in signatureCelebrations.keys) {
      final theme = ThermosTheme.all.firstWhere((t) => t.id == id);
      for (final shape in ThermosShape.values) {
        test('$id x ${shape.label}', () {
          for (final l in [0.0, 0.33, 0.66, 0.99]) {
            final p = CelebrationPainter.looping(
              theme: theme,
              shape: shape,
              loop: l,
              loopCount: 2,
            );
            expect(p.looping, isTrue);
            final r = PictureRecorder();
            p.paint(Canvas(r), const Size(330, 380));
            r.endRecording().dispose();
            final pr = PictureRecorder();
            ThermosPainter(
              shape: shape,
              theme: theme,
              level: 1,
              goalMl: 2000,
              time: 0,
              slosh: 0,
              happy: true,
              capPose: resolveCapPose(p),
            ).paint(Canvas(pr), const Size(330, 380));
            pr.endRecording().dispose();
          }
        });
      }
    }
  });
}
