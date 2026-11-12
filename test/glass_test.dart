import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/glass_math.dart';
import 'package:hydrosen/features/home/water_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder glass(int i) => find.byKey(ValueKey('glass-$i'));
final glassPlus = find.byKey(const ValueKey('glass-plus'));

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
        expect(find.text('0 / 10'), findsOneWidget);

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
        expect(find.text('0 / 4'), findsOneWidget); // ceil(2000 / 500)
        expect((await settings.load()).glassMl, 500);

        await tester.tap(glass(0));
        await tester.pumpAndSettle();
        expect(find.text('500 / 2000 ml'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await openApp(tester, settings: settings);
        expect(find.text('0 / 4'), findsOneWidget); // bardak boyu 500 kaldı
      },
    );
  });

  group('bardak sırası', () {
    testWidgets('sıradaki boş bardağa dokun = ekle, son dolu = çıkar', (
      tester,
    ) async {
      prepare(tester);
      await openApp(tester);
      expect(glass(9), findsOneWidget);
      expect(glass(10), findsNothing);
      expect(glassPlus, findsNothing);

      await tester.tap(glass(0));
      await tester.pumpAndSettle();
      await tester.tap(glass(1));
      await tester.pumpAndSettle();
      expect(find.text('400 / 2000 ml'), findsOneWidget);
      expect(find.text('2 / 10'), findsOneWidget);

      // Dolu ama son olmayan bardak (0) hiçbir şey yapmaz.
      await tester.tap(glass(0));
      await tester.pumpAndSettle();
      expect(find.text('400 / 2000 ml'), findsOneWidget);

      // Son dolu bardak (1) bir bardak çıkarır.
      await tester.tap(glass(1));
      await tester.pumpAndSettle();
      expect(find.text('200 / 2000 ml'), findsOneWidget);
      expect(find.text('1 bardak çıkarıldı'), findsOneWidget);
    });

    testWidgets('hedef tam bardakla dolunca "+" çıkar ve hedef aşılır', (
      tester,
    ) async {
      prepare(tester);
      await openApp(tester);
      for (var i = 0; i < 10; i++) {
        await tester.tap(glass(9));
        await tester.pumpAndSettle();
      }
      expect(find.text('Hedefe ulaştın!'), findsOneWidget);
      expect(glassPlus, findsOneWidget);

      await tester.tap(glassPlus);
      await tester.pumpAndSettle();
      expect(find.text('2200 / 2000 ml'), findsOneWidget);
      expect(find.text('11 / 10'), findsOneWidget);
      expect(glass(10), findsOneWidget); // fazladan dolu bardak
      expect(glassPlus, findsOneWidget);

      // Son dolu bardağa dokun: fazlalık çıkar.
      await tester.tap(glass(10));
      await tester.pumpAndSettle();
      expect(find.text('2000 / 2000 ml'), findsOneWidget);
    });

    testWidgets('hedef bardağın katı değilse son bardak kesirli dolar', (
      tester,
    ) async {
      prepare(tester);
      final settings = InMemorySettingsRepository(
        const AppSettings(goalMl: 2000, glassMl: 300),
      );
      await openApp(tester, settings: settings);
      expect(find.text('0 / 7'), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        await tester.tap(glass(6));
        await tester.pumpAndSettle();
      }
      expect(find.text('1800 / 2000 ml'), findsOneWidget);
      expect(find.text('6 / 7'), findsOneWidget);
      expect(glassPlus, findsNothing);

      // Özel 200 ml: 7. bardak 2/3 dolu, "6,6 / 7" gösterilir.
      await tester.tap(find.text('Özel miktar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '200');
      await tester.tap(find.text('Ekle'));
      await tester.pumpAndSettle();
      expect(find.text('2000 / 2000 ml'), findsOneWidget);
      expect(find.text('6,6 / 7'), findsOneWidget);
      expect(glassPlus, findsNothing);

      // 7. bardak tamamlanınca "+" belirir.
      await tester.tap(glass(6));
      await tester.pumpAndSettle();
      expect(glassPlus, findsOneWidget);
    });

    testWidgets('geri al: ekleme ve çıkarma bilgi çubuğundan geri döner', (
      tester,
    ) async {
      prepare(tester);
      await openApp(tester);

      await tester.tap(glass(0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('1 bardak eklendi'), findsOneWidget);
      await tester.tap(find.text('Geri al'));
      await tester.pumpAndSettle();
      expect(find.text('0 / 2000 ml'), findsOneWidget);

      await tester.tap(glass(0));
      await tester.pumpAndSettle();
      await tester.tap(glass(0)); // son dolu: çıkar
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('1 bardak çıkarıldı'), findsOneWidget);
      expect(find.text('0 / 2000 ml'), findsOneWidget);
      await tester.tap(find.text('Geri al'));
      await tester.pumpAndSettle();
      expect(find.text('200 / 2000 ml'), findsOneWidget);
    });

    testWidgets('dar ekranda 20+ bardak taşmadan sığar', (tester) async {
      prepare(tester, size: const Size(360, 1800));
      final settings = InMemorySettingsRepository(
        const AppSettings(goalMl: 5000, glassMl: 150),
      );
      await openApp(tester, settings: settings);
      expect(find.text('0 / 34'), findsOneWidget);
      expect(glass(33), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
