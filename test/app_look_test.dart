import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/app/app_look.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/features/home/home_screen.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';

String _id(AppFont f) => f.family.replaceAll(' ', '');

void main() {
  group('AppLook', () {
    test('her temanın küratörlü bir yazı tipi var', () {
      for (final t in ThermosTheme.all) {
        expect(themeTypefaces.containsKey(t.id), isTrue, reason: t.id);
      }
      expect(themeTypefaces['panda']!.headline, AppFont.baloo2);
      expect(themeTypefaces['robot']!.headline, AppFont.chakraPetch);
      expect(themeTypefaces['sihirbaz']!.body, AppFont.alegreya);
    });

    test('koyu temalar koyu, açık temalar açık şema alır', () {
      for (final id in [
        'robot',
        'gece',
        'sihirbaz',
        'kardanadam',
        'astronot',
      ]) {
        expect(AppLook.of(ThermosTheme.byId(id)).isDark, isTrue, reason: id);
      }
      for (final id in ['klasik', 'panda', 'kaplan', 'karpuz', 'botanik']) {
        expect(AppLook.of(ThermosTheme.byId(id)).isDark, isFalse, reason: id);
      }
    });

    test('arka plan rengi temanın çiziminden gelir', () {
      final klasik = AppLook.of(ThermosTheme.classic).backdrop.top;
      // Klasik gök 0xE6F1FB, beyaza %30 yumuşatılmış.
      expect(
        klasik.toARGB32(),
        Color.lerp(const Color(0xFFE6F1FB), Colors.white, 0.3)!.toARGB32(),
      );
      final robot = AppLook.of(ThermosTheme.byId('robot')).backdrop.top;
      expect(robot.toARGB32(), 0xFF1E2A3A);
    });

    test('her temada metin her arka planda okunur (kontrast >= 4.5)', () {
      const min = AppLook.minContrast;
      for (final t in ThermosTheme.all) {
        final look = AppLook.of(t);
        final s = look.scheme;
        final grounds = [
          ...look.backdrop.surfaces,
          s.surface,
          // Kartlar yarı saydam: arka planla karışmış hâli.
          for (final g in look.backdrop.surfaces)
            Color.alphaBlend(s.surface.withValues(alpha: 0.82), g),
        ];
        for (final g in grounds) {
          expect(
            AppLook.contrast(s.onSurface, g),
            greaterThanOrEqualTo(min),
            reason: '${t.id} metin',
          );
          expect(
            AppLook.contrast(s.onSurfaceVariant, g),
            greaterThanOrEqualTo(min),
            reason: '${t.id} ikincil metin',
          );
        }
        for (final g in look.backdrop.surfaces) {
          expect(
            AppLook.contrast(s.primary, g),
            greaterThanOrEqualTo(3),
            reason: '${t.id} ana renk arka planda',
          );
        }
        expect(
          AppLook.contrast(s.onPrimary, s.primary),
          greaterThanOrEqualTo(min),
          reason: '${t.id} düğme yazısı',
        );
        expect(
          AppLook.contrast(s.onSecondaryContainer, s.secondaryContainer),
          greaterThanOrEqualTo(min),
          reason: '${t.id} hızlı ekleme düğmesi',
        );
      }
    });

    testWidgets('ThemeData yazı tiplerini taşır', (tester) async {
      final data = AppLook.of(ThermosTheme.byId('korsan')).themeData;
      expect(data.textTheme.headlineMedium!.fontFamily, contains('PirataOne'));
      expect(data.textTheme.bodyMedium!.fontFamily, contains('Alegreya'));
      expect(data.extension<BackdropColors>(), isNotNull);
    });
  });

  testWidgets('tema değişince uygulamanın rengi ve yazı tipi değişir', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });

    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    ThemeData home() => Theme.of(tester.element(find.byType(HomeScreen)));

    expect(home().textTheme.bodyMedium!.fontFamily, contains('Nunito'));
    expect(home().brightness, Brightness.light);

    await tester.tap(find.byTooltip('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('theme-robot')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('theme-robot')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    final robot = AppLook.of(ThermosTheme.byId('robot'));
    expect(home().brightness, Brightness.dark);
    expect(home().colorScheme.primary, robot.scheme.primary);
    expect(
      home().textTheme.bodyMedium!.fontFamily,
      contains(_id(AppFont.chakraPetch)),
    );
    expect(home().extension<BackdropColors>()!.top, robot.backdrop.top);
  });
}
