import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/streak_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/backup.dart';
import 'package:hydrosen/domain/drink_type.dart';
import 'package:hydrosen/domain/saved_container.dart';
import 'package:hydrosen/domain/streak.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/backup/backup_io.dart';
import 'package:hydrosen/features/backup/backup_section.dart';
import 'package:hydrosen/features/backup/backup_service.dart';
import 'package:hydrosen/features/home/reminder_controller.dart';
import 'package:hydrosen/features/home/water_controller.dart';
import 'package:hydrosen/features/settings/settings_controller.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime(2026, 11, 24, 12);

/// Yazması istenince hata veren su deposu.
class _FailingWaterRepository extends InMemoryWaterRepository {
  _FailingWaterRepository(super.initial);
  bool failSave = false;

  @override
  Future<void> save(List<WaterEntry> entries) async {
    if (failSave) throw StateError('disk dolu');
    return super.save(entries);
  }
}

class _Fixture {
  _Fixture(this.water, this.settings, this.reminder, this.service);

  final WaterController water;
  final SettingsController settings;
  final ReminderController reminder;
  final BackupService service;
}

Future<_Fixture> _build({
  List<WaterEntry> entries = const [],
  AppSettings settings = const AppSettings(),
  WaterRepository? waterRepo,
  StreakRepository? streakRepo,
}) async {
  final water = WaterController(
    repository: waterRepo ?? InMemoryWaterRepository(entries),
    goalMl: settings.goalMl,
    now: () => _now,
    streakRepository: streakRepo ?? InMemoryStreakRepository(),
  );
  await water.load();
  final s = SettingsController(
    repository: InMemorySettingsRepository(settings),
  );
  await s.load();
  final reminder = ReminderController(onDue: () {}, now: () => _now);
  await reminder.load();
  return _Fixture(
    water,
    s,
    reminder,
    BackupService(water: water, settings: s, reminder: reminder),
  );
}

List<WaterEntry> _entries() {
  final d0 = DateTime(2026, 11, 23, 9);
  return [
    WaterEntry(id: 1, amountMl: 250, time: d0),
    WaterEntry(
      id: 2,
      amountMl: 300,
      time: d0.add(const Duration(hours: 3)),
      drink: DrinkType.tea,
    ),
    WaterEntry(id: 3, amountMl: 2200, time: DateTime(2026, 11, 24, 8, 30)),
  ];
}

AppSettings _custom() => AppSettings(
  shape: ThermosShape.slim,
  theme: ThermosTheme.byId('kedi'),
  goalMl: 2400,
  glassMl: 250,
  animatedCelebrations: false,
  containers: const [
    SavedContainer(id: 1, name: 'Şişe', ml: 750),
    SavedContainer(id: 4, name: 'Kupa', ml: 350),
  ],
  bottleNames: const {'kedi': 'Pamuk'},
);

String _json(void Function(Map<String, Object?> m) edit) {
  final m = jsonDecode(
    BackupCodec.encode(
      BackupData(
        entries: _entries(),
        settings: _custom(),
        reminder: const ReminderSettings(enabled: true),
        streak: StreakData(
          start: DateTime(2026, 11, 20),
          through: DateTime(2026, 11, 23),
          goalDays: {DateTime(2026, 11, 22), DateTime(2026, 11, 23)},
          best: 2,
          badges: {'ilk_kayit': DateTime(2026, 11, 20)},
        ),
      ),
      now: _now,
    ),
  ) as Map<String, Object?>;
  edit(m);
  return jsonEncode(m);
}

class _FakeIO implements BackupFileIO {
  _FakeIO({this.pickText});

  String? pickText;
  String? savedName;
  String? savedContent;

  @override
  bool get canSave => true;

  @override
  bool get canPick => true;

  @override
  Future<bool> saveFile({
    required String fileName,
    required String content,
  }) async {
    savedName = fileName;
    savedContent = content;
    return true;
  }

  @override
  Future<String?> pickFileText() async => pickText;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Yedek biçimi', () {
    test('dosya adı tarihli', () {
      expect(
        BackupCodec.fileName(DateTime(2026, 11, 24)),
        'hydrosen-yedek-2026-11-24.json',
      );
    });

    test('kodla-çöz gidiş dönüş: her bölüm aynı kalır', () {
      final streak = StreakData(
        start: DateTime(2026, 11, 20),
        through: DateTime(2026, 11, 23),
        goalDays: {DateTime(2026, 11, 22)},
        throughGoalMl: 2000,
        lastGoalMl: 2000,
        best: 3,
        badges: {
          'ilk_kayit': DateTime(2026, 11, 20),
          's3': DateTime(2026, 11, 22),
        },
        celebrated: {'ilk_kayit'},
      );
      const reminder = ReminderSettings(
        enabled: true,
        startMinute: 7 * 60,
        endMinute: 21 * 60,
        intervalMinute: 90,
        stopAtGoal: false,
        dailyCap: 5,
      );
      final text = BackupCodec.encode(
        BackupData(
          entries: _entries(),
          settings: _custom(),
          reminder: reminder,
          streak: streak,
        ),
        now: _now,
      );
      final back = BackupCodec.decode(text);

      expect(back.entries.length, 3);
      expect(back.entries[1].drink, DrinkType.tea);
      expect(back.entries[2].amountMl, 2200);
      expect(back.entries[0].time, DateTime(2026, 11, 23, 9));
      final s = back.settings!;
      expect(s.shape, ThermosShape.slim);
      expect(s.theme.id, 'kedi');
      expect(s.goalMl, 2400);
      expect(s.glassMl, 250);
      expect(s.animatedCelebrations, isFalse);
      expect(s.containers, _custom().containers);
      expect(s.bottleNames, {'kedi': 'Pamuk'});
      expect(back.reminder, reminder);
      expect(back.streak!.badges.keys, {'ilk_kayit', 's3'});
      expect(back.streak!.celebrated, {'ilk_kayit'});
      expect(back.streak!.best, 3);
      expect(back.streak!.goalDays, {DateTime(2026, 11, 22)});
      // Sürüm ve uygulama etiketi var.
      final m = jsonDecode(text) as Map;
      expect(m['app'], 'hydrosen');
      expect(m['schemaVersion'], BackupCodec.schemaVersion);
    });

    test('özet: kayıt, rozet ve tarih aralığı', () {
      final data = BackupData(
        entries: _entries(),
        streak: StreakData(
          start: DateTime(2026, 11, 20),
          through: DateTime(2026, 11, 23),
          badges: {
            'ilk_kayit': DateTime(2026, 11, 20),
            's3': DateTime(2026, 11, 22),
          },
        ),
      );
      expect(BackupSummary.of(data).text, '3 kayıt, 2 rozet, 23 Kas–24 Kas');
      expect(
        BackupSummary.of(const BackupData(entries: [])).text,
        '0 kayıt, 0 rozet',
      );
      expect(
        BackupSummary.of(BackupData(entries: [_entries().first])).text,
        '1 kayıt, 0 rozet, 23 Kas',
      );
    });

    test('geriye uyum: isteğe bağlı bölümler eksik olabilir', () {
      final text = jsonEncode({
        'app': 'hydrosen',
        'schemaVersion': 1,
        'entries': [
          {'id': 1, 'ml': 200, 't': '2026-11-24T09:00:00.000'},
        ],
      });
      final data = BackupCodec.decode(text);
      expect(data.entries.single.amountMl, 200);
      expect(data.settings, isNull);
      expect(data.reminder, isNull);
      expect(data.streak, isNull);
    });

    test('eksik alanlar (kaplar, matara adları) varsayılana döner', () {
      final data = BackupCodec.decode(
        _json((m) {
          final s = m['settings'] as Map<String, Object?>;
          s.remove('containers');
          s.remove('bottleNames');
        }),
      );
      expect(data.settings!.containers, AppSettings.defaultContainers);
      expect(data.settings!.bottleNames, isEmpty);
    });

    test('bilinmeyen alanlar yok sayılır', () {
      final data = BackupCodec.decode(_json((m) => m['gelecek'] = {'x': 1}));
      expect(data.entries.length, 3);
    });

    final bad = <String, String Function()>{
      'JSON değil': () => 'bu bir yedek değil {',
      'boş metin': () => '',
      'dizi': () => '[1,2,3]',
      'başka uygulama': () => _json((m) => m['app'] = 'baskasi'),
      'sürüm yok': () => _json((m) => m.remove('schemaVersion')),
      'sürüm yazı': () => _json((m) => m['schemaVersion'] = '1'),
      'sürüm 0': () => _json((m) => m['schemaVersion'] = 0),
      'gelecek sürüm': () => _json((m) => m['schemaVersion'] = 99),
      'kayıtlar yok': () => _json((m) => m.remove('entries')),
      'kayıtlar liste değil': () => _json((m) => m['entries'] = 'x'),
      'kayıt negatif ml': () =>
          _json((m) => (m['entries'] as List)[0]['ml'] = -5),
      'kayıt çok büyük ml': () =>
          _json((m) => (m['entries'] as List)[0]['ml'] = 99999),
      'kayıt ml yazı': () =>
          _json((m) => (m['entries'] as List)[0]['ml'] = '250'),
      'kayıt bozuk tarih': () =>
          _json((m) => (m['entries'] as List)[0]['t'] = 'dün'),
      'kayıt imkansız yıl': () =>
          _json((m) => (m['entries'] as List)[0]['t'] = '1850-01-01T00:00:00'),
      'kayıt kimliği yinelenir': () =>
          _json((m) => (m['entries'] as List)[1]['id'] = 1),
      'bilinmeyen içecek': () =>
          _json((m) => (m['entries'] as List)[1]['d'] = 'viski'),
      'kayıt harita değil': () => _json((m) => (m['entries'] as List)[0] = 7),
      'ayar şekli bozuk': () =>
          _json((m) => (m['settings'] as Map)['shape'] = 'kare'),
      'hedef aralık dışı': () =>
          _json((m) => (m['settings'] as Map)['goalMl'] = 99999),
      'bardak aralık dışı': () =>
          _json((m) => (m['settings'] as Map)['glassMl'] = 5),
      'animasyon bayrağı yazı': () =>
          _json((m) => (m['settings'] as Map)['animatedCelebrations'] = 'evet'),
      'kap listesi boş': () =>
          _json((m) => (m['settings'] as Map)['containers'] = []),
      'kap çok': () => _json(
        (m) => (m['settings'] as Map)['containers'] = [
          for (var i = 1; i <= 9; i++) {'id': i, 'name': 'K$i', 'ml': 100},
        ],
      ),
      'kap ml aralık dışı': () => _json(
        (m) => ((m['settings'] as Map)['containers'] as List)[0]['ml'] = 0,
      ),
      'uygunsuz matara adı': () => _json(
        (m) => (m['settings'] as Map)['bottleNames'] = {'kedi': 's1kt1r'},
      ),
      'matara adı yazı değil': () =>
          _json((m) => (m['settings'] as Map)['bottleNames'] = {'kedi': 5}),
      'hatırlatıcı pencere ters': () => _json(
        (m) => m['reminder'] = {
          'enabled': true,
          'startMinute': 1200,
          'endMinute': 480,
          'intervalMinute': 60,
          'stopAtGoal': true,
          'dailyCap': 8,
        },
      ),
      'hatırlatıcı aralık geçersiz': () =>
          _json((m) => (m['reminder'] as Map)['intervalMinute'] = 7),
      'hatırlatıcı bayrak yazı': () =>
          _json((m) => (m['reminder'] as Map)['enabled'] = 1),
      'seri harita değil': () => _json((m) => m['streak'] = 'x'),
      'seri tarihi bozuk': () =>
          _json((m) => (m['streak'] as Map)['start'] = 'dün'),
      'bilinmeyen rozet': () => _json(
        (m) => (m['streak'] as Map)['badges'] = {'sahte': '2026-11-20'},
      ),
      'rozet tarihi bozuk': () =>
          _json((m) => (m['streak'] as Map)['badges'] = {'s3': 'x'}),
    };
    for (final e in bad.entries) {
      test('bozuk girdi reddedilir: ${e.key}', () {
        expect(
          () => BackupCodec.decode(e.value()),
          throwsA(
            isA<BackupException>().having(
              (x) => x.message,
              'ileti',
              contains('Hiçbir şey değişmedi'),
            ),
          ),
        );
      });
    }

    test('çok büyük dosya reddedilir', () {
      expect(
        () => BackupCodec.decode('x' * (BackupCodec.maxFileChars + 1)),
        throwsA(isA<BackupException>()),
      );
    });
  });

  group('Yedek servisi', () {
    test('gidiş dönüş: dışa aktar, başka kuruluma geri yükle', () async {
      final a = await _build(entries: _entries(), settings: _custom());
      await a.reminder.configure(active: true, start: 7 * 60, end: 22 * 60);
      final text = a.service.export(now: _now);

      final b = await _build();
      expect(b.water.allEntries, isEmpty);
      await b.service.restore(BackupCodec.decode(text));

      expect(
        [for (final e in b.water.allEntries) e.toJson()],
        [for (final e in a.water.allEntries) e.toJson()],
      );
      expect(b.settings.settings.goalMl, 2400);
      expect(b.settings.theme.id, 'kedi');
      expect(b.settings.settings.containers, _custom().containers);
      expect(b.settings.settings.bottleNames, {'kedi': 'Pamuk'});
      expect(b.settings.shape, ThermosShape.slim);
      expect(b.water.goalMl, 2400);
      expect(b.reminder.enabled, isTrue);
      expect(b.reminder.startMinute, 7 * 60);
      expect(b.reminder.endMinute, 22 * 60);
      expect(b.water.earnedBadges, a.water.earnedBadges);
      expect(b.water.earnedBadges, isNotEmpty);
      expect(b.water.streak.current, a.water.streak.current);
      // Geri yüklenen veri kalıcı depoda da var.
      expect(b.water.totalMl, 2200);
    });

    test('geri yükleme mevcut verinin YERİNE geçer', () async {
      final b = await _build(
        entries: [
          WaterEntry(id: 77, amountMl: 123, time: DateTime(2026, 11, 1, 8)),
        ],
      );
      await b.service.restore(
        BackupCodec.decode(
          BackupCodec.encode(
            BackupData(entries: _entries(), settings: _custom()),
            now: _now,
          ),
        ),
      );
      expect(b.water.allEntries.map((e) => e.id).toSet(), {1, 2, 3});
    });

    test('eksik isteğe bağlı bölümler mevcut değerleri korur', () async {
      final b = await _build(
        entries: [
          WaterEntry(id: 5, amountMl: 500, time: DateTime(2026, 11, 24, 7)),
        ],
        settings: _custom(),
      );
      await b.reminder.configure(active: true);
      final data = BackupCodec.decode(
        jsonEncode({
          'app': 'hydrosen',
          'schemaVersion': 1,
          'entries': [
            {'id': 1, 'ml': 400, 't': '2026-11-24T09:00:00.000'},
          ],
        }),
      );
      await b.service.restore(data);
      expect(b.water.allEntries.single.amountMl, 400);
      expect(b.settings.settings.goalMl, 2400); // ayar korundu
      expect(b.settings.settings.bottleNames, {'kedi': 'Pamuk'});
      expect(b.reminder.enabled, isTrue); // hatırlatıcı korundu
    });

    test('yazım hatasında hiçbir şey değişmez', () async {
      final repo = _FailingWaterRepository([
        WaterEntry(id: 9, amountMl: 321, time: DateTime(2026, 11, 24, 10)),
      ]);
      final b = await _build(waterRepo: repo, settings: _custom());
      repo.failSave = true;
      await expectLater(
        b.service.restore(
          BackupCodec.decode(
            BackupCodec.encode(
              BackupData(
                entries: _entries(),
                settings: const AppSettings(goalMl: 3000),
              ),
              now: _now,
            ),
          ),
        ),
        throwsA(isA<BackupException>()),
      );
      expect(b.water.allEntries.single.id, 9);
      expect(b.settings.settings.goalMl, 2400);
      expect((await repo.load()).single.id, 9);
    });
  });

  group('Yedek bölümü (arayüz)', () {
    Future<(_Fixture, _FakeIO)> pump(
      WidgetTester tester, {
      String? file,
      _Fixture? fixture,
    }) async {
      final f =
          fixture ??
          await _build(
            entries: [
              WaterEntry(id: 5, amountMl: 500, time: DateTime(2026, 11, 24, 7)),
            ],
            settings: _custom(),
          );
      final io = _FakeIO(pickText: file);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                BackupSection(service: f.service, io: io, now: () => _now),
              ],
            ),
          ),
        ),
      );
      return (f, io);
    }

    testWidgets('yedek dosyası oluşturur', (tester) async {
      final (f, io) = await pump(tester);
      expect(find.text('Yedekle ve geri yükle'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('backup-export')));
      await tester.pumpAndSettle();
      expect(io.savedName, 'hydrosen-yedek-2026-11-24.json');
      final back = BackupCodec.decode(io.savedContent!);
      expect(back.entries.single.amountMl, 500);
      expect(back.settings!.goalMl, f.settings.goalMl);
      expect(find.textContaining('Yedek dosyası hazır'), findsOneWidget);
    });

    testWidgets('geri yükleme: özet + onay, sonra veri değişir', (
      tester,
    ) async {
      final file = BackupCodec.encode(
        BackupData(
          entries: _entries(),
          settings: const AppSettings(goalMl: 3000),
          streak: StreakData(
            start: DateTime(2026, 11, 20),
            through: DateTime(2026, 11, 23),
            badges: {'ilk_kayit': DateTime(2026, 11, 20)},
          ),
        ),
        now: _now,
      );
      final (f, _) = await pump(tester, file: file);
      await tester.tap(find.byKey(const ValueKey('backup-restore')));
      await tester.pumpAndSettle();
      expect(find.text('3 kayıt, 1 rozet, 23 Kas–24 Kas'), findsOneWidget);
      expect(find.text('Mevcut verilerin yerini alır.'), findsOneWidget);
      // Onaydan önce hiçbir şey değişmez.
      expect(f.water.allEntries.single.id, 5);

      await tester.tap(find.byKey(const ValueKey('backup-confirm-ok')));
      await tester.pumpAndSettle();
      expect(f.water.allEntries.length, 3);
      expect(f.settings.goalMl, 3000);
      expect(find.text('Yedek geri yüklendi.'), findsOneWidget);
    });

    testWidgets('vazgeçilirse veri değişmez', (tester) async {
      final file = BackupCodec.encode(
        BackupData(entries: _entries(), settings: _custom()),
        now: _now,
      );
      final (f, _) = await pump(tester, file: file);
      await tester.tap(find.byKey(const ValueKey('backup-restore')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('backup-confirm-cancel')));
      await tester.pumpAndSettle();
      expect(f.water.allEntries.single.id, 5);
    });

    testWidgets('bozuk dosya: dostça hata, hiçbir şey değişmez', (
      tester,
    ) async {
      final (f, _) = await pump(tester, file: '{ bozuk');
      await tester.tap(find.byKey(const ValueKey('backup-restore')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup-confirm')), findsNothing);
      expect(
        find.textContaining('HydroSen yedeği gibi görünmüyor'),
        findsOneWidget,
      );
      expect(f.water.allEntries.single.id, 5);
      expect(f.settings.goalMl, 2400);
    });

    testWidgets('dosya seçimi iptal: sessizce döner', (tester) async {
      final (f, _) = await pump(tester);
      await tester.tap(find.byKey(const ValueKey('backup-restore')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup-error')), findsNothing);
      expect(f.water.allEntries.single.id, 5);
    });
  });
}
