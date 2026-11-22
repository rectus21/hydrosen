import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/glass_math.dart';
import 'package:hydrosen/features/home/water_controller.dart';
import 'package:hydrosen/features/thermos/thermos_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

final quickAddOne = find.byKey(const ValueKey('quick-add-1'));
final quickRemoveOne = find.byKey(const ValueKey('quick-remove-1'));

int totalMlOf(WidgetTester tester) =>
    tester.widget<ThermosView>(find.byType(ThermosView)).totalMl!;

void prepare(WidgetTester tester, {Size size = const Size(800, 1800)}) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    tester.view.reset();
  });
}

Future<void> openApp(
  WidgetTester tester, {
  WaterRepository? water,
  SettingsRepository? settings,
}) async {
  await tester.pumpWidget(
    HydroSenApp(
      repository: water ?? InMemoryWaterRepository(),
      settingsRepository: settings ?? InMemorySettingsRepository(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('GlassMath', () {
    test('bardak sayısı hedef / bardak, yukarı yuvarlanır', () {
      expect(const GlassMath(goalMl: 2000, glassMl: 200).goalGlasses, 10);
      expect(const GlassMath(goalMl: 2000, glassMl: 300).goalGlasses, 7);
      expect(const GlassMath(goalMl: 2000, glassMl: 150).goalGlasses, 14);
      expect(const GlassMath(goalMl: 500, glassMl: 500).goalGlasses, 1);
      expect(const GlassMath(goalMl: 2100, glassMl: 500).goalGlasses, 5);
    });

    test('doluluk kesirli: kısmi bardak oranı gösterir', () {
      const g = GlassMath(goalMl: 2000, glassMl: 300);
      expect(g.fillOf(0, 450), 1);
      expect(g.fillOf(1, 450), closeTo(0.5, 1e-9));
      expect(g.fillOf(2, 450), 0);
      expect(g.fullGlasses(450), 1);
      expect(GlassMath.format(g.glassesOf(450)), '1,5');
      expect(GlassMath.format(g.glassesOf(600)), '2');
    });

    test('hedefin üstünde ek bardaklar ve "+" bardağı', () {
      const g = GlassMath(goalMl: 2000, glassMl: 200);
      expect(g.showPlus(1800), isFalse);
      expect(g.showPlus(2000), isTrue);
      expect(g.shownGlasses(1000), 10);
      expect(g.shownGlasses(2300), 12); // 11.5 bardak -> 12 simge
      // Hedefi tam tutmayan bardakta son bardak kısmen dolu kalır, "+" yok.
      const odd = GlassMath(goalMl: 2000, glassMl: 300);
      expect(odd.showPlus(1800), isFalse);
      expect(odd.showPlus(2100), isTrue);
    });
  });

  group('WaterController bardak çıkarma ve geri al', () {
    final now = DateTime(2026, 11, 12, 10);
    WaterController make() => WaterController(
      repository: InMemoryWaterRepository(),
      goalMl: 2000,
      now: () => now,
    );

    test('son kayıt bardağa eşitse silinir', () async {
      final c = make();
      await c.load();
      await c.add(500);
      await c.add(200);
      expect(await c.removeAmount(200), 200);
      expect(c.todayEntries.map((e) => e.amountMl), [500]);
    });

    test('son kayıt büyükse yerinde küçülür, kayıt eksiye düşmez', () async {
      final c = make();
      await c.load();
      await c.add(500);
      expect(await c.removeAmount(200), 200);
      expect(c.todayEntries.map((e) => e.amountMl), [300]);
    });

    test('son kayıt küçükse silinir, kalan bir öncekinden düşülür', () async {
      final c = make();
      await c.load();
      await c.add(500);
      await c.add(150);
      expect(await c.removeAmount(200), 200);
      expect(c.todayEntries.map((e) => e.amountMl), [450]);
      expect(c.totalMl, 450);
    });

    test('toplam yetmezse hepsi silinir, boşken bir şey yapmaz', () async {
      final c = make();
      await c.load();
      expect(await c.removeAmount(200), 0);
      expect(c.canUndo, isFalse);
      await c.add(100);
      expect(await c.removeAmount(200), 100);
      expect(c.totalMl, 0);
    });

    test('geri al: ekleme, çıkarma ve silme tek adım geri döner', () async {
      final c = make();
      await c.load();
      await c.add(500);
      await c.add(200);
      await c.removeAmount(200);
      expect(c.totalMl, 500);
      expect(await c.undo(), isTrue);
      expect(c.totalMl, 700);
      expect(c.canUndo, isFalse);
      expect(await c.undo(), isFalse);
      await c.remove(c.todayEntries.first.id);
      await c.undo();
      expect(c.totalMl, 700);
    });
  });

  group('bardak boyu ayarı', () {
    test('varsayılan 200, normalleşir ve kalıcıdır', () async {
      expect(AppSettings.normalizeGlass(10), 150);
      expect(AppSettings.normalizeGlass(9999), 500);
      expect(AppSettings.normalizeGlass(330), 350);
      expect((await SharedPrefsSettingsRepository().load()).glassMl, 200);
      await SharedPrefsSettingsRepository().save(
        const AppSettings(glassMl: 300),
      );
      expect((await SharedPrefsSettingsRepository().load()).glassMl, 300);
    });

    test('bozuk değer varsayılana düşer', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsSettingsRepository.glassKey: 'x',
      });
      expect((await SharedPrefsSettingsRepository().load()).glassMl, 200);
    });

    testWidgets(
      'ayarlardan değişir, ana ekrana yansır, yeniden açılışta kalır',
      (tester) async {
        prepare(tester);
        final settings = InMemorySettingsRepository();
        await openApp(tester, settings: settings);
        expect(
          find.descendant(of: quickAddOne, matching: find.text('200 ml')),
          findsOneWidget,
        );

        await tester.tap(find.byTooltip('Ayarlar'));
        await tester.pumpAndSettle();
        await tester.drag(
          find.byKey(const ValueKey('glass-slider')),
          const Offset(2000, 0),
        );
        await tester.pumpAndSettle();
        expect(find.text('500 ml'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(
          find.descendant(of: quickAddOne, matching: find.text('500 ml')),
          findsOneWidget,
        );
        expect((await settings.load()).glassMl, 500);

        await tester.tap(quickAddOne);
        await tester.pumpAndSettle();
        expect(totalMlOf(tester), 500);

        await tester.pumpWidget(const SizedBox());
        await openApp(tester, settings: settings);
        expect(
          find.descendant(of: quickAddOne, matching: find.text('500 ml')),
          findsOneWidget,
        );
      },
    );
  });

  group('hızlı bardak kontrolleri', () {
    testWidgets('ekleme ve çıkarma düğmeleri toplamı günceller', (
      tester,
    ) async {
      prepare(tester);
      await openApp(tester);

      await tester.tap(quickAddOne);
      await tester.pumpAndSettle();
      await tester.tap(quickAddOne);
      await tester.pumpAndSettle();
      expect(totalMlOf(tester), 400);

      await tester.tap(quickRemoveOne);
      await tester.pumpAndSettle();
      expect(totalMlOf(tester), 200);
      expect(find.text('1 bardak çıkarıldı'), findsOneWidget);
    });

    testWidgets('hedef dolduktan sonra ekleme ve çıkarma sürer', (
      tester,
    ) async {
      prepare(tester);
      await openApp(tester);
      for (var i = 0; i < 10; i++) {
        await tester.tap(quickAddOne);
        await _flush(tester);
      }
      expect(totalMlOf(tester), 2000);
      await tester.tap(quickAddOne);
      await _flush(tester);
      expect(totalMlOf(tester), 2200);

      await tester.tap(quickRemoveOne);
      await _flush(tester);
      expect(totalMlOf(tester), 2000);
    });

    testWidgets('hedef bardak katı değilse miktarlar doğru toplanır', (
      tester,
    ) async {
      prepare(tester);
      final settings = InMemorySettingsRepository(
        const AppSettings(goalMl: 2000, glassMl: 300),
      );
      await openApp(tester, settings: settings);
      for (var i = 0; i < 6; i++) {
        await tester.tap(quickAddOne);
        await _flush(tester);
      }
      expect(totalMlOf(tester), 1800);

      // Özel 200 ml: 7. bardak 2/3 dolu, "6,6 / 7" gösterilir.
      await tester.tap(find.text('Özel miktar'));
      await _flush(tester);
      await tester.enterText(find.byType(TextField), '200');
      await tester.tap(find.text('Ekle'));
      await _flush(tester);
      expect(totalMlOf(tester), 2000);
      await tester.tap(quickAddOne);
      await _flush(tester);
      expect(totalMlOf(tester), 2300);
    });

    testWidgets('geri al: ekleme ve çıkarma bilgi çubuğundan geri döner', (
      tester,
    ) async {
      prepare(tester);
      await openApp(tester);

      await tester.tap(quickAddOne);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('1 bardak eklendi'), findsOneWidget);
      await tester.tap(find.text('Geri al'));
      await tester.pumpAndSettle();
      expect(totalMlOf(tester), 0);

      await tester.tap(quickAddOne);
      await tester.pumpAndSettle();
      await tester.tap(quickRemoveOne);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('1 bardak çıkarıldı'), findsOneWidget);
      expect(totalMlOf(tester), 0);
      await tester.tap(find.text('Geri al'));
      await tester.pumpAndSettle();
      expect(totalMlOf(tester), 200);
    });

    testWidgets('dar ekranda hızlı kontroller taşmadan sığar', (tester) async {
      prepare(tester, size: const Size(360, 1800));
      final settings = InMemorySettingsRepository(
        const AppSettings(goalMl: 5000, glassMl: 150),
      );
      await openApp(tester, settings: settings);
      expect(quickAddOne, findsOneWidget);
      expect(quickRemoveOne, findsOneWidget);
      expect(find.text('Özel miktar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Hedefte kutlama döngüsü sürekli çalıştığından pumpAndSettle bitmez.
Future<void> _flush(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}
