import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/app/theme_scene.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/streak_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/badges.dart';
import 'package:hydrosen/domain/bottle_name.dart';
import 'package:hydrosen/domain/saved_container.dart';
import 'package:hydrosen/domain/streak.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/badges/badges_section.dart';
import 'package:hydrosen/features/home/entry_sheet.dart';
import 'package:hydrosen/features/home/records_section.dart';
import 'package:hydrosen/features/home/reminder_controller.dart';
import 'package:hydrosen/features/home/water_controller.dart';
import 'package:hydrosen/features/settings/settings_controller.dart';
import 'package:hydrosen/features/settings/settings_screen.dart';
import 'package:hydrosen/features/thermos/illustrated_artwork.dart';
import 'package:hydrosen/features/thermos/scene_geometry.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:hydrosen/features/thermos/wolf_artwork.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DelayedSettingsRepo implements SettingsRepository {
  _DelayedSettingsRepo(this._loadCompleter);

  final Completer<AppSettings> _loadCompleter;
  AppSettings? saved;
  final List<Completer<void>> saveGates = [];

  @override
  Future<AppSettings> load() => _loadCompleter.future;

  @override
  Future<void> save(AppSettings settings) async {
    if (saveGates.isNotEmpty) {
      await saveGates.removeAt(0).future;
    }
    saved = settings;
  }
}

class _GatedWaterRepo implements WaterRepository {
  List<WaterEntry> saved = const [];
  final List<Completer<void>> saveGates = [];

  @override
  Future<List<WaterEntry>> load() async => [...saved];

  @override
  Future<void> save(List<WaterEntry> entries) async {
    if (saveGates.isNotEmpty) {
      await saveGates.removeAt(0).future;
    }
    saved = [...entries];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('domain mantık düzeltmeleri', () {
    test('parseDayKey geçersiz takvim tarihlerini reddeder', () {
      expect(parseDayKey('2026-02-28'), DateTime(2026, 2, 28));
      expect(parseDayKey('2026-02-30'), isNull);
      expect(parseDayKey('2026-13-01'), isNull);
      expect(parseDayKey('2026-04-31'), isNull);
    });

    test('StreakEngine saat geriye gidince bugünü çift saymaz', () {
      final d1 = DateTime(2026, 11, 20);
      final d2 = DateTime(2026, 11, 21);
      final d3 = DateTime(2026, 11, 22);
      final existing = StreakData(
        start: d1,
        through: d3, // Saat ileriydi, sonra d3 gününe geri alındı.
        goalDays: {d1, d2, d3},
        throughGoalMl: 2000,
        lastGoalMl: 2000,
        best: 3,
      );
      final res = StreakEngine.advance(
        data: existing,
        now: DateTime(2026, 11, 22, 23, 30),
        dailyCountedMl: {d1: 2000, d2: 2000, d3: 2000},
        goalMl: 2000,
      );
      expect(res.status.current, 3);
      expect(res.status.best, 3);
      expect(res.status.goalDaysTotal, 3);
    });

    test('BottleName Nigar/Niğde adlarına izin verir, noktalama-yalnız adları reddeder', () {
      expect(BottleName.validate('Nigar').isOk, isTrue);
      expect(BottleName.validate('Niğde').isOk, isTrue);
      expect(BottleName.validate('nigg').error, BottleNameError.inappropriate);
      expect(BottleName.validate('n1gg4').error, BottleNameError.inappropriate);
      expect(BottleName.validate('...').error, BottleNameError.invalidChars);
      expect(BottleName.validate('---').error, BottleNameError.invalidChars);
    });

    test('SavedContainer.normalizeName emoji/surrogate pair bölmez', () {
      final raw = '${'💧' * 10}${'a' * 10}';
      final normalized = SavedContainer.normalizeName(raw);
      expect(normalized.runes.length, SavedContainer.maxNameLength);
      expect(normalized, '${'💧' * 10}aaaaaa');
    });
  });

  group('depo ve controller dayanıklılığı', () {
    test('SharedPrefsWaterRepository yanlış tipte bozuk veride çökmez', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsWaterRepository.key: 12345,
      });
      expect(await SharedPrefsWaterRepository().load(), isEmpty);
    });

    test('SettingsController eşzamanlı kayıtlarda son değeri korur ve dispose sonrası çökmez', () async {
      final firstGate = Completer<void>();
      final repo = _DelayedSettingsRepo(Completer<AppSettings>()..complete(const AppSettings()));
      repo.saveGates.add(firstGate);
      final c = SettingsController(repository: repo);
      await c.load();

      final f1 = c.setGoalMl(2500);
      final f2 = c.setGoalMl(3000);
      final f3 = c.setGoalMl(3500);
      firstGate.complete();
      await Future.wait([f1, f2, f3]);
      expect(repo.saved?.goalMl, 3500);

      final disposeGate = Completer<void>();
      repo.saveGates.add(disposeGate);
      final f4 = c.setGoalMl(4000);
      c.dispose();
      disposeGate.complete();
      await f4;
    });

    test('WaterController eşzamanlı kayıtlarda son durumu korur ve dispose sonrası çökmez', () async {
      final repo = _GatedWaterRepo();
      final c = WaterController(
        repository: repo,
        now: () => DateTime(2026, 11, 24, 10),
      );
      await c.load();

      final gate = Completer<void>();
      repo.saveGates.add(gate);
      final f1 = c.add(200);
      final f2 = c.add(300);
      gate.complete();
      await Future.wait([f1, f2]);
      expect(repo.saved.length, 2);

      final gate2 = Completer<void>();
      repo.saveGates.add(gate2);
      final f3 = c.add(100);
      c.dispose();
      gate2.complete();
      await f3;
    });

    test('ReminderController: bozuk state ayarları silmez; load sırasında dispose güvenli', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_enabled_v1': true,
        'reminder_start_minute_v1': 9 * 60,
        'reminder_end_minute_v1': 21 * 60,
        'reminder_interval_minute_v1': 90,
        'reminder_day_state_v1': '{bozuk json',
      });
      final r = ReminderController(onDue: () {});
      await r.load();
      expect(r.enabled, isTrue);
      expect(r.startMinute, 9 * 60);
      expect(r.endMinute, 21 * 60);
      expect(r.intervalMinute, 90);
      expect(r.sentToday, 0);
      r.dispose();

      // Yükleme bitmeden dispose: hata veya timer sızıntısı olmamalı.
      final r2 = ReminderController(onDue: () {});
      final loadFuture = r2.load();
      r2.dispose();
      await loadFuture;
    });
  });

  group('arayüz düzeltmeleri', () {
    testWidgets('BadgesPanel kilitli rozette kalan günü mevcut seriden hesaplar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BadgesPanel(
                status: const StreakStatus(
                  current: 2,
                  best: 14,
                  rights: 0,
                  todayDone: false,
                  goalDaysTotal: 16,
                  protectedDays: {},
                  yesterdayProtected: false,
                ),
                earned: {
                  Badges.firstEntryId: DateTime(2026, 3, 1),
                  Badges.firstGoalId: DateTime(2026, 3, 1),
                  's3': DateTime(2026, 3, 3),
                  's7': DateTime(2026, 3, 7),
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // s15 için 15 - 2 = 13 gün kaldı (best=14 yüzünden 1 gün değil).
      expect(find.text('13 gün kaldı'), findsOneWidget);
      expect(find.text('1 gün kaldı'), findsNothing);
    });

    testWidgets('açılışta gecikmeli ayarlar yanlış hedefle rozet vermez', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
        tester.view.reset();
      });

      final settingsLoad = Completer<AppSettings>();
      final streakRepo = InMemoryStreakRepository();
      final today = DateTime.now();
      await tester.pumpWidget(
        HydroSenApp(
          repository: InMemoryWaterRepository([
            WaterEntry(
              id: 1,
              amountMl: 2100,
              time: DateTime(today.year, today.month, today.day, 10),
            ),
          ]),
          settingsRepository: _DelayedSettingsRepo(settingsLoad),
          streakRepository: streakRepo,
        ),
      );
      await tester.pump();
      // Ayarlar henüz yüklenmedi: seri/rozet yanlış 2000 ml hedefle yazılmamış olmalı.
      expect(streakRepo.data, isNull);

      settingsLoad.complete(const AppSettings(goalMl: 3000));
      await tester.pumpAndSettle();

      // Gerçek hedef 3000 ml olduğundan 2100 ml ile ilk_hedef kazanılmamalı.
      expect(streakRepo.data, isNotNull);
      expect(streakRepo.data!.badges.containsKey(Badges.firstGoalId), isFalse);
      expect(streakRepo.data!.best, 0);
    });

    testWidgets('RecordsSection gelecek günde Kayıt ekle düğmesini pasif yapar ve >%100 gösterir', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(420, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // 2026-11-24 Salı: Çarşamba (25) gelecek gün.
      final now = DateTime(2026, 11, 24, 12);
      final c = WaterController(
        repository: InMemoryWaterRepository([
          WaterEntry(id: 1, amountMl: 2400, time: DateTime(2026, 11, 24, 10)),
        ]),
        goalMl: 2000,
        now: () => now,
      );
      await c.load();
      addTearDown(c.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordsSection(controller: c, onDelete: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Hedefin üstü gerçek yüzde olarak görünür.
      expect(find.text('%120'), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(find.byKey(const ValueKey('records-add'))).onPressed,
        isNotNull,
      );

      // Gelecek güne (Çarşamba 25) dokun: Kayıt ekle pasif olur.
      await tester.tap(find.text('Çar'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<OutlinedButton>(find.byKey(const ValueKey('records-add'))).onPressed,
        isNull,
      );
    });

    testWidgets('EntrySheet açıkken zaman ilerleyince canlı saati kabul eder', (
      tester,
    ) async {
      var currentNow = DateTime(2026, 11, 24, 10, 0);
      EntrySheetResult? result;
      final entryAt1001 = WaterEntry(
        id: 1,
        amountMl: 250,
        time: DateTime(2026, 11, 24, 10, 1),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showEntrySheet(
                    context,
                    entry: entryAt1001,
                    nowProvider: () => currentNow,
                  );
                },
                child: const Text('Ac'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ac'));
      await tester.pumpAndSettle();

      // 10:00 iken 10:01 gelecek sayılır.
      await tester.tap(find.byKey(const ValueKey('entry-save')));
      await tester.pumpAndSettle();
      expect(find.text('Gelecek bir saat seçemezsin'), findsOneWidget);
      expect(result, isNull);

      // Sayfa açıkken saat 10:02 oldu; aynı 10:01 kaydı artık kabul edilmeli.
      currentNow = DateTime(2026, 11, 24, 10, 2);
      await tester.tap(find.byKey(const ValueKey('entry-save')));
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.amountMl, 250);
    });

    testWidgets('Ayarlar ekranı açılıp kapanınca SceneGeometryScope bozulmaz', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
        tester.view.reset();
      });

      final settings = SettingsController(
        repository: InMemorySettingsRepository(),
      );
      await settings.load();
      addTearDown(settings.dispose);

      GlobalKey? homeKey;
      final thermosKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: ThemeScene(
            theme: ThermosTheme.classic,
            thermosKey: thermosKey,
            child: Builder(
              builder: (context) {
                homeKey = SceneGeometryScope.maybeKeyOf(context);
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SettingsScreen(controller: settings),
                      ),
                    ),
                    child: const Text('Ayarlar'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(homeKey, isNotNull);
      expect(SceneGeometry.sceneKey, homeKey);

      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(SceneGeometry.sceneKey, homeKey);
      expect(homeKey!.currentContext, isNotNull);
    });

    test('WolfArtwork.load kurt sahne parlaklıklarını doldurur', () async {
      final art = await WolfArtwork.load();
      expect(art, isNotNull);
      expect(IllustratedArtwork.topLuma['kurt'], isNotNull);
      expect(IllustratedArtwork.bottomLuma['kurt'], isNotNull);
      expect(IllustratedArtwork.midLuma['kurt'], isNotNull);
    });
  });
}
