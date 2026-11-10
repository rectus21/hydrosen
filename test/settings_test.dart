import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/features/settings/settings_controller.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:hydrosen/features/thermos/thermos_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SharedPrefsSettingsRepository', () {
    test('veri yokken varsayılanlar döner', () async {
      final s = await SharedPrefsSettingsRepository().load();
      expect(s.shape, ThermosShape.chubby);
      expect(s.theme, ThermosTheme.classic);
      expect(s.goalMl, 2000);
    });

    test('kaydedilen ayarlar yeniden okunur', () async {
      await SharedPrefsSettingsRepository().save(
        const AppSettings(
          shape: ThermosShape.slim,
          theme: ThermosTheme.panda,
          goalMl: 2600,
        ),
      );
      final s = await SharedPrefsSettingsRepository().load();
      expect(s.shape, ThermosShape.slim);
      expect(s.theme, ThermosTheme.panda);
      expect(s.goalMl, 2600);
    });

    test(
      'bozuk değerler çökmeden varsayılana düşer, hedef sınırlanır',
      () async {
        SharedPreferences.setMockInitialValues({
          SharedPrefsSettingsRepository.shapeKey: 'bilinmeyen',
          SharedPrefsSettingsRepository.themeKey: 42,
          SharedPrefsSettingsRepository.goalKey: 99999,
        });
        final s = await SharedPrefsSettingsRepository().load();
        expect(s.shape, ThermosShape.chubby);
        expect(s.theme, ThermosTheme.classic);
        expect(s.goalMl, AppSettings.maxGoalMl);
      },
    );

    test('bilinmeyen tema kimliği Klasik olur', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsSettingsRepository.themeKey: 'yok',
        SharedPrefsSettingsRepository.goalKey: 100,
      });
      final s = await SharedPrefsSettingsRepository().load();
      expect(s.theme, ThermosTheme.classic);
      expect(s.goalMl, AppSettings.minGoalMl);
    });
  });

  group('SettingsController', () {
    test(
      'yükleme öncesi loaded false, sonrası true ve değerler gelir',
      () async {
        final c = SettingsController(
          repository: InMemorySettingsRepository(
            const AppSettings(shape: ThermosShape.slim, goalMl: 3000),
          ),
        );
        expect(c.loaded, isFalse);
        await c.load();
        expect(c.loaded, isTrue);
        expect(c.shape, ThermosShape.slim);
        expect(c.goalMl, 3000);
      },
    );

    test('değişiklik dinleyicileri bilgilendirir ve depoya yazılır', () async {
      final repo = InMemorySettingsRepository();
      final c = SettingsController(repository: repo);
      await c.load();
      var notified = 0;
      c.addListener(() => notified++);

      await c.setShape(ThermosShape.slim);
      await c.setTheme(ThermosTheme.tiger);
      await c.setGoalMl(2500);

      expect(notified, greaterThanOrEqualTo(3));
      final saved = await repo.load();
      expect(saved.shape, ThermosShape.slim);
      expect(saved.theme, ThermosTheme.tiger);
      expect(saved.goalMl, 2500);
    });

    test('hedef adıma yuvarlanır ve sınırlara çekilir', () async {
      final c = SettingsController(repository: InMemorySettingsRepository());
      await c.load();
      await c.setGoalMl(1);
      expect(c.goalMl, 500);
      await c.setGoalMl(100000);
      expect(c.goalMl, 5000);
      await c.setGoalMl(2140);
      expect(c.goalMl, 2100);
    });

    test(
      'saklama başarısızsa saveFailed işaretlenir, değer bellekte kalır',
      () async {
        final c = SettingsController(repository: _FailingSettingsRepository());
        await c.load();
        await c.setGoalMl(3000);
        expect(c.saveFailed, isTrue);
        expect(c.goalMl, 3000);
      },
    );

    test('okuma başarısızsa varsayılanlarla açılır', () async {
      final c = SettingsController(repository: _FailingSettingsRepository());
      await c.load();
      expect(c.loaded, isTrue);
      expect(c.goalMl, 2000);
    });
  });

  group('Ayarlar ekranı', () {
    void prepare(WidgetTester tester) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
        tester.view.reset();
      });
    }

    ThermosView thermos(WidgetTester tester) =>
        tester.widget<ThermosView>(find.byType(ThermosView));

    testWidgets('tema seçici 360 px genişlikte taşmaz, tüm temalar erişilir', (
      tester,
    ) async {
      prepare(tester);
      tester.view.physicalSize = const Size(360, 700);
      await tester.pumpWidget(
        HydroSenApp(
          repository: InMemoryWaterRepository(),
          settingsRepository: InMemorySettingsRepository(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Ayarlar'));
      await tester.pumpAndSettle();
      for (final t in ThermosTheme.all) {
        await tester.scrollUntilVisible(
          find.byKey(ValueKey('theme-${t.id}')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
      }
      expect(tester.takeException(), isNull); // RenderFlex taşması yok
    });

    testWidgets('hızlı tema rafı (geçici): dokununca tema ve biçim değişir', (
      tester,
    ) async {
      prepare(tester);
      tester.view.physicalSize = const Size(360, 800);
      await tester.pumpWidget(
        HydroSenApp(
          repository: InMemoryWaterRepository(),
          settingsRepository: InMemorySettingsRepository(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('quick-theme-panda')),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('quick-theme-panda')));
      await tester.pumpAndSettle();
      expect(thermos(tester).theme, ThermosTheme.panda);
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('quick-shape')),
          matching: find.text('İnce'),
        ),
      );
      await tester.pumpAndSettle();
      expect(thermos(tester).shape, ThermosShape.slim);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'ayarlar değişir, ana ekrana yansır ve yeniden açılışta kalır',
      (tester) async {
        prepare(tester);
        final settingsRepo = InMemorySettingsRepository();
        final waterRepo = InMemoryWaterRepository();

        await tester.pumpWidget(
          HydroSenApp(repository: waterRepo, settingsRepository: settingsRepo),
        );
        await tester.pumpAndSettle();
        expect(find.text('hedef 2000 ml'), findsOneWidget);

        await tester.tap(find.byTooltip('Ayarlar'));
        await tester.pumpAndSettle();
        expect(find.text('Ayarlar'), findsOneWidget);

        await tester.tap(find.text('İnce'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('theme-panda')));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(Slider), const Offset(-2000, 0));
        await tester.pumpAndSettle();
        expect(find.text('500 ml'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(thermos(tester).shape, ThermosShape.slim);
        expect(thermos(tester).theme, ThermosTheme.panda);
        expect(find.text('hedef 500 ml'), findsOneWidget);

        // Uygulamayı kapat, aynı depolarla yeniden aç.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          HydroSenApp(repository: waterRepo, settingsRepository: settingsRepo),
        );
        await tester.pumpAndSettle();
        expect(thermos(tester).shape, ThermosShape.slim);
        expect(thermos(tester).theme, ThermosTheme.panda);
        expect(find.text('hedef 500 ml'), findsOneWidget);
      },
    );
  });
}

class _FailingSettingsRepository implements SettingsRepository {
  @override
  Future<AppSettings> load() async => throw StateError('okunamadı');

  @override
  Future<void> save(AppSettings settings) async =>
      throw StateError('yazılamadı');
}
