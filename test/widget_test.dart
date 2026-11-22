import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/features/thermos/celebration_overlay.dart';
import 'package:hydrosen/features/thermos/celebration_painter.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:hydrosen/features/thermos/thermos_view.dart';

/// Termos sürekli dalgalandığı için pumpAndSettle hiç durulmaz; testlerde
/// "animasyonları azalt" açılır (termos o zaman durağan çizilir). Ekran da
/// termos ve liste birlikte görünsün diye uzatılır.
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

final quickAddOne = find.byKey(const ValueKey('quick-add-1'));

int totalMlOf(WidgetTester tester) =>
    tester.widget<ThermosView>(find.byType(ThermosView)).totalMl!;

void main() {
  quickGlassTests();
  testWidgets('ana ekran: ekleme ve silme toplamı günceller', (tester) async {
    prepare(tester);
    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 0);

    await tester.tap(quickAddOne);
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 200);

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kaydı sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Günlük'));
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 0);
  });

  testWidgets('özel miktar: geçerli sayı eklenir, geçersizde uyarı çıkar', (
    tester,
  ) async {
    prepare(tester);
    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    // Geçersiz giriş: pencere açık kalır, uyarı görünür.
    await tester.tap(find.text('Özel miktar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();
    expect(find.text('1–5000 arasında bir sayı gir'), findsOneWidget);

    // Geçerli giriş: pencere kapanır, toplam güncellenir.
    await tester.enterText(find.byType(TextField), '200');
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(totalMlOf(tester), 200);

    // Vazgeç: hiçbir şey eklenmez.
    await tester.tap(find.text('Özel miktar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '300');
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 200);

    // Klavyeden Enter ile gönderme.
    await tester.tap(find.text('Özel miktar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '100');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 300);
  });

  testWidgets('uygulama yeniden açılınca kayıt ekranda geri gelir', (
    tester,
  ) async {
    prepare(tester);
    final repo = InMemoryWaterRepository();

    await tester.pumpWidget(
      HydroSenApp(
        repository: repo,
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(quickAddOne);
    await tester.pumpAndSettle();
    await tester.tap(quickAddOne);
    await tester.pumpAndSettle();

    // Uygulamayı kapat, aynı depoyla yeniden aç.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      HydroSenApp(
        repository: repo,
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(totalMlOf(tester), 400);
    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Kaydı sil'), findsNWidgets(2));
  });

  testWidgets('termos görünür, varsayılan biçim ve tema tombul/Klasik', (
    tester,
  ) async {
    prepare(tester);
    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ThermosView), findsOneWidget);
    final view = tester.widget<ThermosView>(find.byType(ThermosView));
    expect(view.shape, ThermosShape.chubby);
    expect(view.theme, ThermosTheme.classic);
    expect(tester.takeException(), isNull);
  });

  testWidgets('animasyon açıkken dalga çalışır ve hata vermez', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.tap(quickAddOne);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(totalMlOf(tester), 200);
    expect(tester.takeException(), isNull);
    // Sonsuz ticker'ı durdurmak için ağacı kaldır.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('hedef geçilince kutlama görünür, sonra kaybolur', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final message = find.text(CelebrationOverlay.message);
    final particles = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is CelebrationPainter,
    );
    Future<void> frames(int n) async {
      for (var i = 0; i < n; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await frames(4);
    expect(message, findsNothing);

    // 1800 ml (9 bardak): hedefin (2000) altında, kutlama yok.
    for (var i = 0; i < 9; i++) {
      await tester.tap(quickAddOne);
      await frames(2);
    }
    expect(message, findsNothing);

    // 10. bardakla hedefe ulaşıldı: kutlama oynar.
    await tester.tap(quickAddOne);
    await frames(4);
    expect(message, findsOneWidget);
    expect(particles, findsOneWidget);

    // Kutlama sürerken uygulama kullanılmaya devam eder (katman dokunmaları geçirir).
    await tester.tap(quickAddOne);
    await frames(2);
    expect(totalMlOf(tester), 2200);

    // ~2,6 sn sonra kaybolur; hedefin üstünde kaldıkça tekrar oynamaz.
    await frames(60);
    expect(message, findsNothing);
    // Hedefte sürekli döngü: yazısız, girişsiz hareket sürer.
    expect(particles, findsOneWidget);
    expect(
      (tester.widget<CustomPaint>(particles).painter! as CelebrationPainter)
          .looping,
      isTrue,
    );
    await tester.tap(quickAddOne);
    await frames(4);
    expect(message, findsNothing);

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'animasyonları azalt: hareket yok (sabit kare), kısa tebrik yazısı var',
    (tester) async {
      prepare(tester);
      await tester.pumpWidget(
        HydroSenApp(
          repository: InMemoryWaterRepository(),
          settingsRepository: InMemorySettingsRepository(
            const AppSettings(animatedCelebrations: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final message = find.text(CelebrationOverlay.message);

      await tester.tap(quickAddOne);
      await tester.pumpAndSettle();
      expect(message, findsNothing);

      // Özel miktarla tam hedefe.
      await tester.tap(find.text('Özel miktar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1800');
      await tester.tap(find.text('Ekle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(message, findsOneWidget);
      double frameT() =>
          (tester
                      .widget<CustomPaint>(
                        find.byWidgetPredicate(
                          (w) =>
                              w is CustomPaint &&
                              w.painter is CelebrationPainter,
                        ),
                      )
                      .painter!
                  as CelebrationPainter)
              .t;
      final first = frameT();
      await tester.pump(const Duration(milliseconds: 700));
      expect(frameT(), first); // kare sabit: parçacıklar hareket etmez

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(message, findsNothing);
    },
  );
}

void quickGlassTests() {
  Future<void> boot(WidgetTester tester) async {
    prepare(tester);
    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
  }

  final add1 = find.byKey(const ValueKey('quick-add-1'));
  final add2 = find.byKey(const ValueKey('quick-add-2'));
  final rem1 = find.byKey(const ValueKey('quick-remove-1'));

  testWidgets('hızlı düğmeler: +1, +2 ve −1 bardak, etiketlerde ml var', (
    tester,
  ) async {
    await boot(tester);
    expect(find.text('+2 bardak'), findsOneWidget);
    expect(find.text('400 ml'), findsOneWidget);
    await tester.tap(add1);
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 200);
    expect(find.text('1 bardak eklendi'), findsOneWidget);
    await tester.tap(add2);
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 600);
    expect(find.text('2 bardak eklendi'), findsOneWidget);
    await tester.tap(rem1);
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 400);
    expect(find.text('1 bardak çıkarıldı'), findsOneWidget);
  });

  testWidgets('−1 bardak bugün su yokken pasif', (tester) async {
    await boot(tester);
    expect(
      tester
          .widget<OutlinedButton>(
            find.descendant(of: rem1, matching: find.byType(OutlinedButton)),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(add1);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<OutlinedButton>(
            find.descendant(of: rem1, matching: find.byType(OutlinedButton)),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('hızlı düğmeler: Geri al işlemi geri alır', (tester) async {
    await boot(tester);
    await tester.tap(add2);
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 400);
    await tester.tap(find.text('Geri al'));
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 0);
    await tester.tap(add2);
    await tester.pumpAndSettle();
    await tester.tap(rem1);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Geri al'));
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 400);
  });

  testWidgets('360 px ekranda hızlı kayıt kaydırarak erişilir', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(360, 740);
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
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(add1);
    await tester.pumpAndSettle();
    expect(add1.hitTestable(), findsOneWidget);
    final controls = tester.getRect(
      find.byKey(const ValueKey('daily-control-card')),
    );
    final tabs = tester.getRect(find.byKey(const ValueKey('bottom-tabs')));
    expect(controls.bottom, lessThanOrEqualTo(tabs.top));
    await tester.tap(add1);
    await tester.pumpAndSettle();
    expect(totalMlOf(tester), 200);
    expect(tester.takeException(), isNull);
  });
}
