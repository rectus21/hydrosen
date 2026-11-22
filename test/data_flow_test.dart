import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/home/reminder_controller.dart';
import 'package:hydrosen/features/home/water_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LoadFailingRepository implements WaterRepository {
  @override
  Future<List<WaterEntry>> load() async => throw StateError('okunamadı');

  @override
  Future<void> save(List<WaterEntry> entries) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'çoklu bardak çıkarma, geri alma ve kalıcılık birlikte çalışır',
    () async {
      final now = DateTime(2026, 11, 20, 12);
      final yesterday = now.subtract(const Duration(days: 1));
      final repo = InMemoryWaterRepository([
        WaterEntry(id: 1, amountMl: 300, time: yesterday),
      ]);
      final controller = WaterController(
        repository: repo,
        goalMl: 2000,
        now: () => now,
      );
      await controller.load();
      await controller.add(150);
      await controller.add(200);

      expect(await controller.removeAmount(250), 250);
      expect(controller.totalMl, 100);
      expect(controller.allEntries.any((entry) => entry.id == 1), isTrue);

      final afterRemove = WaterController(
        repository: repo,
        goalMl: 2000,
        now: () => now,
      );
      await afterRemove.load();
      expect(afterRemove.totalMl, 100);

      expect(await controller.undo(), isTrue);
      final afterUndo = WaterController(
        repository: repo,
        goalMl: 2000,
        now: () => now,
      );
      await afterUndo.load();
      expect(afterUndo.totalMl, 350);
    },
  );

  test('olmayan kayıt silme geri alma geçmişi oluşturmaz', () async {
    final controller = WaterController(
      repository: InMemoryWaterRepository(),
      now: () => DateTime(2026, 11, 20),
    );
    await controller.load();
    await controller.remove(999);
    expect(controller.canUndo, isFalse);
  });

  test(
    'kayıt deposu okunamazsa yükleme tamamlanır ve uygulama çalışır',
    () async {
      final controller = WaterController(
        repository: _LoadFailingRepository(),
        now: () => DateTime(2026, 11, 20),
      );
      await controller.load();
      expect(controller.loaded, isTrue);
      expect(controller.saveFailed, isTrue);
      expect(controller.totalMl, 0);
      await controller.add(250);
      expect(controller.totalMl, 250);
    },
  );

  test('bozuk hatırlatıcı verisi güvenli varsayılanlara döner', () async {
    SharedPreferences.setMockInitialValues({
      'reminder_enabled_v1': true,
      'reminder_start_minute_v1': 'bozuk',
      'reminder_end_minute_v1': 23 * 60,
      'reminder_interval_minute_v1': 30,
    });
    var due = 0;
    final reminder = ReminderController(onDue: () => due++);
    await reminder.load();
    expect(reminder.loaded, isTrue);
    expect(reminder.enabled, isFalse);
    expect(reminder.startMinute, 8 * 60);
    expect(reminder.endMinute, 22 * 60);
    expect(reminder.intervalMinute, 60);
    reminder.checkDue();
    expect(due, 0);
    reminder.dispose();
  });

  testWidgets('kayıtlar haftalık ve aylık görünümde aynı veriyi gösterir', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });
    final today = DateTime.now();
    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository([
          WaterEntry(id: 1, amountMl: 300, time: today),
        ]),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    expect(find.text('Haftalık ilerleme'), findsOneWidget);
    expect(find.text('300 ml'), findsWidgets);

    await tester.tap(find.text('Aylık'));
    await tester.pumpAndSettle();
    expect(find.text('Aylık görünüm'), findsOneWidget);
    expect(find.text('300 ml'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
