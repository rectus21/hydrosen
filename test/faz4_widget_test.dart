// Faz 4 – Widget hazırlığı: WidgetSnapshot, köprü güncellemeleri, önizleme.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/streak_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/streak.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/domain/widget_snapshot.dart';
import 'package:hydrosen/features/home/water_controller.dart';
import 'package:hydrosen/features/settings/settings_controller.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:hydrosen/features/widget/widget_preview.dart';
import 'package:hydrosen/services/widget_bridge.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingBridge implements WidgetBridge {
  final updates = <WidgetSnapshot>[];

  @override
  Future<void> update(WidgetSnapshot snapshot) async => updates.add(snapshot);
}

final _now = DateTime(2026, 11, 24, 12);

/// 11 günlük seri (13–23 Kas) + bugün hedef = 12. gün için hazır veri.
({InMemoryWaterRepository water, InMemoryStreakRepository streak})
_twelveDaySeed() {
  final days = [for (var d = 13; d <= 23; d++) DateTime(2026, 11, d)];
  return (
    water: InMemoryWaterRepository([
      for (var i = 0; i < days.length; i++)
        WaterEntry(
          id: i + 1,
          amountMl: 2000,
          time: days[i].add(const Duration(hours: 9)),
        ),
    ]),
    streak: InMemoryStreakRepository(
      StreakData(
        start: days.first,
        through: days.last,
        goalDays: days.toSet(),
        throughGoalMl: 2000,
        lastGoalMl: 2000,
        best: 11,
      ),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('WidgetSnapshot', () {
    const s = WidgetSnapshot(
      todayMl: 1200,
      goalMl: 2000,
      streakDay: 12,
      themeId: 'kedi',
      characterName: 'Pamuk',
    );

    test('yüzde, metinler ve JSON', () {
      expect(s.percent, 60);
      expect(s.ringFraction, closeTo(0.6, 1e-9));
      expect(s.amountText, '1200 / 2000 ml');
      expect(s.streakText, '12. gün');
      expect(s.toJson(), {
        'todayMl': 1200,
        'goalMl': 2000,
        'percent': 60,
        'streakDay': 12,
        'themeId': 'kedi',
        'characterName': 'Pamuk',
      });
    });

    test(
      'hedef aşılırsa yüzde 100 üstü, halka 1.0; seri yoksa "Yeni seri"',
      () {
        const over = WidgetSnapshot(
          todayMl: 2600,
          goalMl: 2000,
          streakDay: 0,
          themeId: 'klasik',
          characterName: 'Klasik',
        );
        expect(over.percent, 130);
        expect(over.ringFraction, 1.0);
        expect(over.streakText, 'Yeni seri');
        expect(
          const WidgetSnapshot(
            todayMl: 5,
            goalMl: 0,
            streakDay: 0,
            themeId: 'a',
            characterName: 'a',
          ).percent,
          0,
        );
      },
    );

    test('eşitlik değere göre', () {
      expect(
        s,
        const WidgetSnapshot(
          todayMl: 1200,
          goalMl: 2000,
          streakDay: 12,
          themeId: 'kedi',
          characterName: 'Pamuk',
        ),
      );
      expect(
        s ==
            const WidgetSnapshot(
              todayMl: 1300,
              goalMl: 2000,
              streakDay: 12,
              themeId: 'kedi',
              characterName: 'Pamuk',
            ),
        isFalse,
      );
    });
  });

  group('WidgetSnapshotPublisher', () {
    Future<(WaterController, SettingsController, _RecordingBridge)> setUp0({
      InMemoryWaterRepository? water,
      InMemoryStreakRepository? streak,
    }) async {
      final w = WaterController(
        repository: water ?? InMemoryWaterRepository(),
        now: () => _now,
        streakRepository: streak ?? InMemoryStreakRepository(),
      );
      final s = SettingsController(
        repository: InMemorySettingsRepository(
          AppSettings(theme: ThermosTheme.byId('kedi')),
        ),
      );
      return (w, s, _RecordingBridge());
    }

    test(
      'yüklenmeden önce göndermez; yüklenince ilk görüntüyü gönderir',
      () async {
        final (w, s, bridge) = await setUp0();
        final p = WidgetSnapshotPublisher(
          water: w,
          settings: s,
          bridge: bridge,
        );
        expect(bridge.updates, isEmpty);
        await w.load();
        expect(bridge.updates, isEmpty); // ayarlar henüz yüklenmedi
        await s.load();
        expect(bridge.updates.length, 1);
        expect(bridge.updates.single.themeId, 'kedi');
        expect(bridge.updates.single.characterName, 'Kedi');
        expect(bridge.updates.single.todayMl, 0);
        p.dispose();
      },
    );

    test(
      'su eklenince, tema/ad/hedef değişince güncellenir; aynısı tekrar gitmez',
      () async {
        final (w, s, bridge) = await setUp0();
        final p = WidgetSnapshotPublisher(
          water: w,
          settings: s,
          bridge: bridge,
        );
        await w.load();
        await s.load();
        final base = bridge.updates.length;

        await w.add(250);
        expect(bridge.updates.last.todayMl, 250);
        expect(bridge.updates.last.percent, 13);
        expect(bridge.updates.length, base + 1);

        // Değişmeyen bildirim yeni güncelleme üretmez.
        w.notifyListeners();
        s.notifyListeners();
        expect(bridge.updates.length, base + 1);

        await s.setBottleName(ThermosTheme.byId('kedi'), 'Pamuk');
        expect(bridge.updates.last.characterName, 'Pamuk');

        await s.setTheme(ThermosTheme.byId('panda'));
        expect(bridge.updates.last.themeId, 'panda');
        expect(bridge.updates.last.characterName, 'Panda');

        w.goalMl = 2500;
        expect(bridge.updates.last.goalMl, 2500);
        expect(bridge.updates.last.percent, 10);

        final n = bridge.updates.length;
        await w.removeAmount(250);
        expect(bridge.updates.length, n + 1);
        expect(bridge.updates.last.todayMl, 0);
        p.dispose();
      },
    );

    test('seri günü görüntüye yansır', () async {
      final seed = _twelveDaySeed();
      final (w, s, bridge) = await setUp0(
        water: seed.water,
        streak: seed.streak,
      );
      final p = WidgetSnapshotPublisher(water: w, settings: s, bridge: bridge);
      await w.load();
      await s.load();
      expect(bridge.updates.last.streakDay, 11);
      await w.add(2000); // bugün de hedef
      expect(bridge.updates.last.streakDay, 12);
      expect(bridge.updates.last.streakText, '12. gün');
      p.dispose();
    });

    test('dispose sonrası güncelleme gitmez', () async {
      final (w, s, bridge) = await setUp0();
      final p = WidgetSnapshotPublisher(water: w, settings: s, bridge: bridge);
      await w.load();
      await s.load();
      p.dispose();
      final n = bridge.updates.length;
      await w.add(200);
      expect(bridge.updates.length, n);
    });

    test('boş köprü hata vermez', () async {
      const bridge = NoopWidgetBridge();
      await bridge.update(
        const WidgetSnapshot(
          todayMl: 1,
          goalMl: 2,
          streakDay: 0,
          themeId: 'klasik',
          characterName: 'Klasik',
        ),
      );
    });

    test('köprü hata verirse uygulama etkilenmez', () async {
      final (w, s, _) = await setUp0();
      final p = WidgetSnapshotPublisher(
        water: w,
        settings: s,
        bridge: _ThrowingBridge(),
      );
      await w.load();
      await s.load();
      await w.add(200);
      expect(w.totalMl, 200);
      p.dispose();
    });
  });

  group('WidgetPreview ve Profil', () {
    const snap = WidgetSnapshot(
      todayMl: 1200,
      goalMl: 2000,
      streakDay: 12,
      themeId: 'kedi',
      characterName: 'Pamuk',
    );

    testWidgets('2x2 ve 4x2 boyutları: tutar, halka, seri günü', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WidgetPreview(snapshot: snap, size: WidgetPreviewSize.small2x2),
                WidgetPreview(snapshot: snap, size: WidgetPreviewSize.wide4x2),
              ],
            ),
          ),
        ),
      );
      expect(find.text('1200 / 2000 ml'), findsNWidgets(2));
      expect(find.text('12. gün'), findsNWidgets(2));
      expect(find.text('+1 bardak'), findsOneWidget); // yalnız 4x2
      expect(find.text('Pamuk'), findsOneWidget); // yalnız 4x2
      expect(
        tester.getSize(find.byKey(const ValueKey('widget-preview-2x2'))),
        const Size(132, 132),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('widget-preview-4x2'))),
        const Size(276, 132),
      );
      expect(
        find.bySemanticsLabel(
          'Ana ekran widget önizlemesi, 2x2: Pamuk, 1200 / 2000 ml, yüzde 60, 12. gün',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('Profil: "Ana ekran widget\'ı (yakında)" ve kısa not', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
        tester.view.reset();
      });
      final bridge = _RecordingBridge();
      await tester.pumpWidget(
        HydroSenApp(
          repository: InMemoryWaterRepository(),
          settingsRepository: InMemorySettingsRepository(
            AppSettings(theme: ThermosTheme.byId('kedi')),
          ),
          widgetBridge: bridge,
        ),
      );
      await tester.pumpAndSettle();
      // Uygulama açılışında köprü bir görüntü almış olmalı.
      expect(bridge.updates, isNotEmpty);
      expect(bridge.updates.last.themeId, 'kedi');

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text("Ana ekran widget'ı (yakında)"),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text("Ana ekran widget'ı (yakında)"), findsOneWidget);
      expect(find.textContaining('telefon sürümüyle gelecek'), findsOneWidget);
      expect(find.byKey(const ValueKey('widget-preview-2x2')), findsOneWidget);
      expect(find.byKey(const ValueKey('widget-preview-4x2')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

class _ThrowingBridge implements WidgetBridge {
  @override
  Future<void> update(WidgetSnapshot snapshot) async =>
      throw StateError('yerel taraf yok');
}
