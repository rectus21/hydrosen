import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/features/thermos/thermos_painter.dart';
import 'package:hydrosen/features/thermos/thermos_view.dart';

/// Termosu çizen ressam (o anki eğim ve dalga ondan okunur).
ThermosPainter painterOf(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(
              find.byWidgetPredicate(
                (w) => w is CustomPaint && w.painter is ThermosPainter,
              ),
            )
            .painter!
        as ThermosPainter;

Future<({double tilt, double wave})> frames(WidgetTester tester, int n) async {
  var tilt = 0.0, wave = 0.0;
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 20));
    final p = painterOf(tester);
    if (p.tilt.abs() > tilt) tilt = p.tilt.abs();
    if (p.wave.abs() > wave) wave = p.wave.abs();
  }
  return (tilt: tilt, wave: wave);
}

Widget view({
  double progress = 0.25,
  int totalMl = 500,
  int goalMl = 2000,
  int celebrations = 0,
}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 330,
        height: 380,
        child: ThermosView(
          progress: progress,
          goalMl: goalMl,
          totalMl: totalMl,
          celebrations: celebrations,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('başlangıçta yüzey durgun; su ekleyince çalkalanır ve durulur', (
    tester,
  ) async {
    await tester.pumpWidget(view());
    expect((await frames(tester, 10)).tilt, 0);

    await tester.pumpWidget(view(progress: 0.5, totalMl: 1000));
    final m = await frames(tester, 30);
    expect(m.tilt, greaterThan(0.02));
    expect(m.wave, greaterThan(1));

    await frames(tester, 250); // ~5 sn
    expect(painterOf(tester).tilt, 0);
    expect(painterOf(tester).wave, 0);
    expect(painterOf(tester).level, closeTo(0.5, 0.01)); // seviye yükseldi
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('büyük miktar küçükten, ekleme silmeden güçlü çalkalar', (
    tester,
  ) async {
    Future<double> waveAfter(int fromMl, int toMl) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(view(totalMl: fromMl, progress: fromMl / 2000));
      await frames(tester, 2);
      await tester.pumpWidget(view(totalMl: toMl, progress: toMl / 2000));
      return (await frames(tester, 40)).wave;
    }

    final small = await waveAfter(500, 650);
    final big = await waveAfter(500, 1500);
    final removed = await waveAfter(650, 500);
    expect(big, greaterThan(small));
    expect(small, greaterThan(removed));
    expect(removed, greaterThan(0));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('yalnız hedef değişirse (toplam aynı) çalkalanmaz', (
    tester,
  ) async {
    await tester.pumpWidget(view());
    await frames(tester, 2);
    await tester.pumpWidget(view(progress: 0.5, goalMl: 1000));
    final m = await frames(tester, 30);
    expect(m.tilt, 0);
    expect(m.wave, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('kutlama sayacı artınca çalkalanır', (tester) async {
    await tester.pumpWidget(view());
    await frames(tester, 2);
    await tester.pumpWidget(view(celebrations: 1));
    expect((await frames(tester, 20)).wave, greaterThan(2));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dokununca sallanır; yatay sürükleme suyu o yöne eğer', (
    tester,
  ) async {
    await tester.pumpWidget(view());
    await frames(tester, 2);

    await tester.tap(find.byType(ThermosView));
    expect((await frames(tester, 20)).tilt, greaterThan(0.02));
    await frames(tester, 250);
    expect(painterOf(tester).tilt, 0);

    final center = tester.getCenter(find.byType(ThermosView));
    final g = await tester.startGesture(center);
    for (var i = 0; i < 10; i++) {
      await g.moveBy(const Offset(8, 0));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await frames(tester, 40);
    expect(painterOf(tester).tilt, greaterThan(0.1)); // sağa: sağ taraf yüksek

    await g.moveBy(const Offset(-200, 0));
    await frames(tester, 40);
    expect(painterOf(tester).tilt, lessThan(-0.1)); // sola eğildi

    await g.up();
    final after = await frames(tester, 30);
    expect(after.wave, greaterThan(0.5));
    await frames(tester, 300);
    expect(painterOf(tester).tilt, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    "animasyonları azalt (web'de tarayıcı bildirir): su yine hareket eder "
    'ama hafif; seviye anında, yüzey titreşimi yok',
    (tester) async {
      Future<({double tilt, double wave})> tapMax(bool reduce) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: reduce);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(view());
        await frames(tester, 2);
        await tester.tap(find.byType(ThermosView));
        return frames(tester, 25);
      }

      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final normal = await tapMax(false);
      final reduced = await tapMax(true);
      expect(reduced.tilt, greaterThan(0.01)); // eskiden 0: hiç hareket yoktu
      expect(reduced.wave, greaterThan(0.5));
      expect(reduced.tilt, lessThan(normal.tilt));
      expect(reduced.wave, lessThan(normal.wave));

      await tester.drag(find.byType(ThermosView), const Offset(120, 0));
      await tester.pumpWidget(view(progress: 0.75, totalMl: 1500));
      await frames(tester, 300);
      final p = painterOf(tester);
      expect(p.tilt, 0); // durulur
      expect(p.time, 0); // sürekli yüzey titreşimi yok
      expect(p.level, 0.75); // seviye anında
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'ana ekranda termosa dokunma/sürükleme düğmeleri ve kaydırmayı bozmaz',
    (tester) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        HydroSenApp(
          repository: InMemoryWaterRepository(),
          settingsRepository: InMemorySettingsRepository(),
        ),
      );
      await frames(tester, 5);

      final thermos = find.byType(ThermosView);
      await tester.tap(thermos);
      await frames(tester, 5);
      await tester.drag(thermos, const Offset(150, 0));
      await frames(tester, 5);
      expect(find.text('0 ml'), findsOneWidget); // dokunma su eklemez

      final button = find.ancestor(
        of: find.text('500 ml'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      );
      await tester.tap(button);
      await frames(tester, 10);
      expect(find.text('%25 tamamlandı'), findsOneWidget);
      // Liste ekrandan taşsın diye birkaç kayıt daha.
      for (var i = 0; i < 4; i++) {
        await tester.tap(button);
        await frames(tester, 3);
      }

      // Termos üstünden dikey sürükleme listeyi kaydırmaya devam eder.
      final list = find.byType(Scrollable).first;
      final before = tester.state<ScrollableState>(list).position.pixels;
      await tester.drag(thermos, const Offset(0, -200));
      await frames(tester, 10);
      final after = tester.state<ScrollableState>(list).position.pixels;
      expect(after, greaterThan(before));

      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
