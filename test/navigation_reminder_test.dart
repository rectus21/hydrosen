import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/home/reminder_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('alt çubuk beş bölümü dar ekranda açar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository([
          WaterEntry(id: 1, amountMl: 250, time: yesterday),
        ]),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bottom-tabs')), findsOneWidget);
    expect(find.text('Günlük'), findsOneWidget);
    expect(find.text('Kayıtlar'), findsOneWidget);
    expect(find.text('Hatırlatıcı'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    expect(find.text('Su kayıtları'), findsOneWidget);
    expect(find.text('250 ml'), findsOneWidget);

    await tester.tap(find.text('Hatırlatıcı'));
    await tester.pumpAndSettle();
    expect(find.text('Su hatırlatıcısı'), findsOneWidget);
    expect(find.text('Tekrarlama sıklığı'), findsOneWidget);

    await tester.tap(find.text('Tema'));
    await tester.pumpAndSettle();
    expect(find.text('Tema seç'), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-theme-tekboynuz')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-theme-balina')), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Ayarları düzenle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'hatırlatıcı saati geldiğinde bir kez uyarır ve ayarları saklar',
    () async {
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 11, 16, 10);
      var count = 0;
      final reminder = ReminderController(onDue: () => count++, now: () => now);
      await reminder.load();
      await reminder.configure(
        active: true,
        start: 9 * 60,
        end: 18 * 60,
        interval: 60,
      );
      reminder.checkDue();
      reminder.checkDue();
      expect(count, 1);
      now = DateTime(2026, 11, 16, 11);
      reminder.checkDue();
      expect(count, 2);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('reminder_enabled_v1'), isTrue);
      expect(prefs.getInt('reminder_interval_minute_v1'), 60);
      reminder.dispose();
    },
  );
}
