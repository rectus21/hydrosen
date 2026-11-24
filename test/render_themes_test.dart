// Atılabilir görsel doğrulama: ana ekran düzenini (ThemeScene + termos +
// kutlama katmanı, 390x844) kurar ve kareleri PNG olarak kaydeder.
//
// Varsayılan olarak ATLANIR. Çalıştırmak için:
//   RENDER_THEMES=1 flutter test test/render_themes_test.dart
// Çıktı: <vault>/HydroSen/02-Design/yeni-temalar/render/
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hydrosen/app/app.dart' show HydroSenApp;
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/data/streak_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/badges.dart';
import 'package:hydrosen/domain/streak.dart';
import 'package:hydrosen/domain/backup.dart';
import 'package:hydrosen/features/backup/backup_io_base.dart';
import 'package:hydrosen/domain/drink_type.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/features/home/home_sections.dart' show ThemeSection;
import 'package:hydrosen/domain/reminder_messages.dart';
import 'package:hydrosen/features/reminder/reminder_banner.dart';
import 'package:hydrosen/features/reminder/reminder_notifier.dart';
import 'package:hydrosen/features/settings/settings_controller.dart';
import 'package:hydrosen/app/theme_scene.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydrosen/features/home/home_screen.dart'
    show kThermosDrop, kThermosZoom;
import 'package:hydrosen/features/thermos/celebration_overlay.dart';
import 'package:hydrosen/features/thermos/celebrations/fx_sprites.dart';
import 'package:hydrosen/features/thermos/illustrated_artwork.dart';
import 'package:hydrosen/features/thermos/thermos_painter.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:hydrosen/features/thermos/thermos_view.dart';

const _outDir =
    r'C:\Users\PC\Documents\Obsidian Vault\HydroSen\02-Design\yeni-temalar\render';

final _enabled = Platform.environment.containsKey('RENDER_THEMES');

void main() {
  _faz1Tests();
  _faz2Tests();
  _faz3Tests();
  _faz4Tests();
  testWidgets('karaejderha kareleri', (tester) async {
    await _run(tester, 'karaejderha', const [
      ('intro_015', 390),
      ('intro_035', 520),
      ('intro_055', 520),
      ('intro_080', 650),
    ], loopAfter: 'loop');
  }, skip: !_enabled);

  testWidgets('tema ekrani', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      await _loadFonts();
      await IllustratedArtwork.load();
      await FxSprites.load();
    });
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    Directory(_outDir).createSync(recursive: true);
    final shot = GlobalKey();
    final settings = SettingsController(
      repository: InMemorySettingsRepository(),
    );
    await settings.load();
    settings.setTheme(ThermosTheme.byId('panda'));
    await tester.pumpWidget(
      RepaintBoundary(
        key: shot,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: ThemeScene(
              theme: settings.theme,
              child: SafeArea(
                child: ThemeSection(settings: settings, onOpenSettings: () {}),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    // Kapak PNG'lerinin gerçek zamanlı çözülmesi için bekle.
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.runAsync(() async {
      final boundary =
          shot.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_outDir/tema_ekrani.png')
          .writeAsBytesSync(data!.buffer.asUint8List());
    });
  }, skip: !_enabled);

  testWidgets('kedi kareleri', (tester) async {
    await _run(tester, 'kedi', const [], rest: true);
    await _run(tester, 'kedi', const [
      ('intro_030', 780),
      ('intro_060', 780),
    ], loopAfter: 'loop');
  }, skip: !_enabled);

  testWidgets('pofuduk kareleri', (tester) async {
    await _run(tester, 'pofuduk', const [], rest: true);
    await _run(tester, 'pofuduk', const [
      ('intro_030', 780),
      ('intro_060', 780),
    ], loopAfter: 'loop');
  }, skip: !_enabled);

  testWidgets('limon kareleri', (tester) async {
    await _run(tester, 'limon', const [], rest: true);
  }, skip: !_enabled);

  testWidgets('limon intro', (tester) async {
    await _run(tester, 'limon', const [
      ('intro_015', 600),
      ('intro_030', 600),
      ('intro_050', 800),
      ('intro_065', 600),
      ('intro_090', 1000),
    ], loopAfter: 'loop');
  }, skip: !_enabled);

  testWidgets('okyanus kareleri', (tester) async {
    await _run(tester, 'okyanus', const [
      ('intro_010', 400),
      ('intro_030', 800),
      ('intro_045', 600),
      ('intro_065', 800),
      ('intro_080', 600),
    ], loopAfter: 'loop');
  }, skip: !_enabled);

  testWidgets('yarisarabasi kareleri', (tester) async {
    await _run(tester, 'yarisarabasi', const [('intro_050', 1300)]);
  }, skip: !_enabled);
}

// ---- Faz 1 – Kayıt kolaylığı (390x844, 2x) -------------------------------

const _faz1Dir =
    r'C:\Users\PC\Documents\Obsidian Vault\HydroSen\02-Design\faz1';

void _faz1Tests() {
  Future<GlobalKey> setUpApp(
    WidgetTester tester,
    WaterRepository repo, {
    String? themeId,
  }) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      await _loadFazFonts();
      await IllustratedArtwork.load();
      await FxSprites.load();
    });
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });
    Directory(_faz1Dir).createSync(recursive: true);
    final shot = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: shot,
        child: HydroSenApp(
          repository: repo,
          settingsRepository: InMemorySettingsRepository(
            themeId == null
                ? const AppSettings()
                : AppSettings(theme: ThermosTheme.byId(themeId)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return shot;
  }

  Future<void> snap(WidgetTester tester, GlobalKey shot, String name) async {
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final boundary =
          shot.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_faz1Dir\\$name.png').writeAsBytesSync(data!.buffer.asUint8List());
    });
  }

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final lastWeekMonday = todayStart.subtract(
    Duration(days: todayStart.weekday - 1 + 7),
  );

  WaterRepository seeded() => InMemoryWaterRepository([
    WaterEntry(
      id: 1,
      amountMl: 200,
      time: todayStart.add(const Duration(hours: 8, minutes: 10)),
    ),
    WaterEntry(
      id: 2,
      amountMl: 200,
      time: todayStart.add(const Duration(hours: 9, minutes: 30)),
      drink: DrinkType.tea,
    ),
    WaterEntry(
      id: 3,
      amountMl: 300,
      time: todayStart.add(const Duration(hours: 11)),
      drink: DrinkType.coffee,
    ),
    WaterEntry(
      id: 10,
      amountMl: 250,
      time: lastWeekMonday.add(const Duration(hours: 8, minutes: 30)),
      drink: DrinkType.ayran,
    ),
    WaterEntry(
      id: 11,
      amountMl: 500,
      time: lastWeekMonday.add(const Duration(hours: 13)),
    ),
  ]);

  testWidgets('faz1: liste (çay) ve özel miktar penceresi', (tester) async {
    final shot = await setUpApp(tester, seeded());
    await snap(tester, shot, 'ana_ekran');
    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'liste_cay');
    await tester.tap(find.text('Günlük'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Özel miktar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('container-chip-2')));
    await tester.tap(find.byKey(const ValueKey('drink-chip-cay')));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'ozel_miktar');
  }, skip: !_enabled);

  testWidgets('faz1: ana ekran koyu sahne', (tester) async {
    final shot = await setUpApp(tester, seeded(), themeId: 'karaejderha');
    await snap(tester, shot, 'ana_ekran_koyu');
  }, skip: !_enabled);

  testWidgets('faz1: düzenleme sayfası', (tester) async {
    final shot = await setUpApp(tester, seeded());
    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    final tile = find.byKey(const ValueKey('record-2'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await snap(tester, shot, 'duzenle');
  }, skip: !_enabled);

  testWidgets('faz1: Kayıtlar geçmiş gün', (tester) async {
    final shot = await setUpApp(tester, seeded());
    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Önceki dönem'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'kayitlar_gecmis');

    await tester.tap(find.byKey(const ValueKey('records-add')));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'ekle_gecmis');
  }, skip: !_enabled);

  testWidgets('faz1: Kaplarım ayarları', (tester) async {
    final shot = await setUpApp(tester, seeded());
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ayarları düzenle'));
    await tester.pumpAndSettle();
    final section = find.byKey(const ValueKey('containers-section'));
    await tester.ensureVisible(section);
    await tester.pumpAndSettle();
    await snap(tester, shot, 'kaplarim');
  }, skip: !_enabled);
}

// ---- Faz 2 - Akıllı hatırlatma (390x844, 2x) -----------------------------

const _faz2Dir =
    r'C:\Users\PC\Documents\Obsidian Vault\HydroSen\02-Design\faz2';

void _faz2Tests() {
  Future<GlobalKey> setUpApp(
    WidgetTester tester,
    String themeId, {
    Map<String, String> names = const {},
    List<WaterEntry> entries = const [],
  }) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      await _loadFazFonts();
      await IllustratedArtwork.load();
      await FxSprites.load();
    });
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });
    Directory(_faz2Dir).createSync(recursive: true);
    final shot = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: shot,
        child: HydroSenApp(
          repository: InMemoryWaterRepository(entries),
          settingsRepository: InMemorySettingsRepository(
            AppSettings(theme: ThermosTheme.byId(themeId), bottleNames: names),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return shot;
  }

  Future<void> snap(WidgetTester tester, GlobalKey shot, String name) async {
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final boundary =
          shot.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_faz2Dir\\$name.png').writeAsBytesSync(data!.buffer.asUint8List());
    });
  }

  testWidgets('faz2: hatırlatıcı ekranı', (tester) async {
    final shot = await setUpApp(
      tester,
      'kopek',
      names: {'kopek': 'Pamuk'},
      entries: [
        WaterEntry(
          id: 1,
          amountMl: 200,
          time: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ],
    );
    await tester.tap(find.text('Hatırlatıcı'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await snap(tester, shot, 'hatirlatici_ekrani');
    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'hatirlatici_ekrani_alt');
    // Zamanlayıcıyı kapat.
    await tester.drag(find.byType(ListView).first, const Offset(0, 1200));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
  }, skip: !_enabled);

  testWidgets('faz2: uygulama içi temalı hatırlatma', (tester) async {
    final shot = await setUpApp(tester, 'kopek', names: {'kopek': 'Pamuk'});
    final theme = ThermosTheme.byId('kopek');
    showReminderBanner(
      tester.element(find.byType(Scaffold).first),
      ReminderMessage(
        title: 'HydroSen',
        body: ReminderMessages.pick(themeId: 'kopek', name: 'Pamuk'),
        themeId: 'kopek',
      ),
      theme,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await snap(tester, shot, 'hatirlatma_banner_kopek');
  }, skip: !_enabled);

  testWidgets('faz2: Profil matara adı', (tester) async {
    final shot = await setUpApp(tester, 'kedi');
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'profil_matara_adi');
    await tester.enterText(
      find.byKey(const ValueKey('bottle-name-field')),
      'Pamuk',
    );
    await tester.tap(find.byKey(const ValueKey('bottle-name-save')));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'profil_matara_adi_kayitli');
    await tester.enterText(
      find.byKey(const ValueKey('bottle-name-field')),
      's1kt1r',
    );
    await tester.tap(find.byKey(const ValueKey('bottle-name-save')));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'profil_matara_adi_hata');
  }, skip: !_enabled);
}

// ---- Faz 3 - Seri ve rozetler (390x844, 2x) -------------------------------

const _faz3Dir =
    r'C:\Users\PC\Documents\Obsidian Vault\HydroSen\02-Design\faz3';

void _faz3Tests() {
  final today = DateTime.now();
  final d0 = DateTime(today.year, today.month, today.day);
  DateTime ago(int n) => DateTime(d0.year, d0.month, d0.day - n);

  /// [goalDays] kadar hedef günü + bugüne kadar uzanan hazır seri verisi.
  StreakData seed({
    required int streakDays,
    required Set<String> earned,
    required Set<String> celebrated,
    int best = 0,
  }) {
    // Dün biten ardışık günler.
    final goal = {for (var i = 1; i <= streakDays; i++) ago(i)};
    return StreakData(
      start: ago(streakDays),
      through: ago(1),
      goalDays: goal,
      throughGoalMl: 2000,
      lastGoalMl: 2000,
      best: best > streakDays ? best : streakDays,
      badges: {for (final id in earned) id: ago(streakDays - 2)},
      celebrated: celebrated,
    );
  }

  Future<GlobalKey> setUpApp(
    WidgetTester tester,
    String themeId, {
    required List<WaterEntry> entries,
    required StreakRepository streak,
    bool settle = true,
  }) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      await _loadFazFonts();
      await IllustratedArtwork.load();
      await FxSprites.load();
    });
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });
    Directory(_faz3Dir).createSync(recursive: true);
    final shot = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: shot,
        child: HydroSenApp(
          repository: InMemoryWaterRepository(entries),
          settingsRepository: InMemorySettingsRepository(
            AppSettings(
              theme: ThermosTheme.byId(themeId),
              animatedCelebrations: false,
            ),
          ),
          streakRepository: streak,
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return shot;
  }

  /// [settle] false: animasyon sürerken (ör. popup) olduğu gibi çek.
  Future<void> snap(
    WidgetTester tester,
    GlobalKey shot,
    String name, {
    bool settle = true,
  }) async {
    if (settle) await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final boundary =
          shot.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_faz3Dir\\$name.png').writeAsBytesSync(data!.buffer.asUint8List());
    });
  }

  List<WaterEntry> entriesFor(Iterable<int> daysAgo, {int ml = 2000}) => [
    for (final n in daysAgo)
      WaterEntry(
        id: 100 + n,
        amountMl: ml,
        time: ago(n).add(const Duration(hours: 12)),
      ),
  ];

  const allCelebrated = {
    Badges.firstEntryId,
    Badges.firstGoalId,
    's3',
    's7',
    's15',
    's30',
  };

  testWidgets('faz3: ana ekran seri satırı (açık sahne)', (tester) async {
    final shot = await setUpApp(
      tester,
      'kedi',
      entries: [
        ...entriesFor([for (var n = 1; n <= 15; n++) n]),
        WaterEntry(
          id: 1,
          amountMl: 1200,
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ],
      streak: InMemoryStreakRepository(
        seed(
          streakDays: 15,
          earned: {Badges.firstEntryId, Badges.firstGoalId, 's3', 's7', 's15'},
          celebrated: allCelebrated,
        ),
      ),
    );
    // ignore: avoid_print
    print(
      'bottomLuma kedi=${IllustratedArtwork.bottomLuma['kedi']} '
      'karaejderha=${IllustratedArtwork.bottomLuma['karaejderha']}',
    );
    await snap(tester, shot, 'ana_ekran_seri_acik');
  }, skip: !_enabled);

  testWidgets('faz3: ana ekran seri satırı (koyu sahne)', (tester) async {
    final shot = await setUpApp(
      tester,
      'karaejderha',
      settle: false,
      entries: [
        ...entriesFor([for (var n = 1; n <= 11; n++) n]),
        WaterEntry(
          id: 1,
          amountMl: 2000,
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ],
      streak: InMemoryStreakRepository(
        seed(
          streakDays: 11,
          earned: {Badges.firstEntryId, Badges.firstGoalId, 's3', 's7'},
          celebrated: allCelebrated,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 8));
    await snap(tester, shot, 'ana_ekran_seri_koyu', settle: false);
  }, skip: !_enabled);

  testWidgets('faz3: Rozetlerim', (tester) async {
    final shot = await setUpApp(
      tester,
      'panda',
      entries: entriesFor([for (var n = 1; n <= 8; n++) n]),
      streak: InMemoryStreakRepository(
        seed(
          streakDays: 8,
          best: 41,
          earned: {
            Badges.firstEntryId,
            Badges.firstGoalId,
            's3',
            's7',
            's15',
            's30',
          },
          celebrated: allCelebrated,
        ),
      ),
    );
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    final section = find.byKey(const ValueKey('badges-section'));
    await tester.dragUntilVisible(
      section,
      find.byType(ListView).first,
      const Offset(0, -150),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'rozetlerim_alt');
    await tester.drag(find.byType(ListView).first, const Offset(0, 330));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'rozetlerim_ust');
  }, skip: !_enabled);

  testWidgets('faz3: tüm rozetler kazanılmış', (tester) async {
    final shot = await setUpApp(
      tester,
      'kopek',
      entries: entriesFor([for (var n = 1; n <= 8; n++) n]),
      streak: InMemoryStreakRepository(
        seed(
          streakDays: 8,
          best: 400,
          earned: {for (final b in Badges.all) b.id},
          celebrated: {for (final b in Badges.all) b.id},
        ),
      ),
    );
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'rozetlerim_hepsi');
  }, skip: !_enabled);

  testWidgets('faz3: yeni rozet kutlaması', (tester) async {
    final shot = await setUpApp(
      tester,
      'tilki',
      settle: false,
      entries: [
        ...entriesFor([for (var n = 1; n <= 6; n++) n]),
        WaterEntry(
          id: 1,
          amountMl: 2000,
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ],
      streak: InMemoryStreakRepository(
        seed(
          streakDays: 6,
          earned: {Badges.firstEntryId, Badges.firstGoalId, 's3', 's7'},
          celebrated: {Badges.firstEntryId, Badges.firstGoalId, 's3'},
        ),
      ),
    );
    // Kutlama gecikmesi (2.4 sn) + birkaç yüz ms: madalyon yeni belirmiş.
    await tester.pump(const Duration(milliseconds: 2400 + 650));
    await snap(tester, shot, 'yeni_rozet_belirme', settle: false);
    await tester.pump(const Duration(milliseconds: 900));
    await snap(tester, shot, 'yeni_rozet_konfeti', settle: false);
    await tester.pump(const Duration(seconds: 6));
  }, skip: !_enabled);

  testWidgets('faz3: Kayıtlar korundu günü', (tester) async {
    // Geçmişten kurulur: 21, 8 ve 1 gün önce kaçırılmış (hak ile korunur).
    final missed = {21, 8, 1};
    final entries = [
      ...entriesFor([
        for (var n = 28; n >= 1; n--)
          if (!missed.contains(n)) n,
      ]),
      ...entriesFor(missed, ml: 900),
    ];
    final shot = await setUpApp(
      tester,
      'kedi',
      entries: entries,
      streak: InMemoryStreakRepository(),
    );
    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    final yesterday = find.byKey(ValueKey('protected-${ago(1).day}'));
    // ignore: avoid_print
    print('korundu gun bulundu: ${yesterday.evaluate().length}');
    await tester.tap(yesterday);
    await tester.pumpAndSettle();
    await snap(tester, shot, 'kayitlar_haftalik_korundu');
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'kayitlar_haftalik_korundu_detay');
    await tester.drag(find.byType(ListView).first, const Offset(0, 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aylık'));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'kayitlar_aylik_korundu');
  }, skip: !_enabled);
}

/// Faz 1 görüntüleri için okunur metin ve simgeler: Flutter'ın Roboto'su tüm
/// tema yazı tipi adlarının yerine, MaterialIcons simge yazı tipi olarak.
Future<void> _loadFazFonts() async {
  const dir = r'C:\src\flutter\bin\cache\artifacts\material_fonts';
  final regular = File('$dir\\roboto-regular.ttf');
  final bold = File('$dir\\roboto-bold.ttf');
  final icons = File('$dir\\materialicons-regular.otf');
  if (!regular.existsSync() || !icons.existsSync()) return;
  final families = <String>['Roboto'];
  for (final f in const [
    'Nunito',
    'Baloo2',
    'Grandstander',
    'Kalam',
    'Quicksand',
    'ChakraPetch',
    'Cinzel',
    'Alegreya',
    'PirataOne',
  ]) {
    families.add(f);
    for (final w in const [
      'regular',
      '300',
      '400',
      '500',
      '600',
      '700',
      '800',
      '900',
    ]) {
      families.add('${f}_$w');
    }
  }
  for (final family in families) {
    final l = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(regular.readAsBytesSync())));
    if (bold.existsSync()) {
      l.addFont(Future.value(ByteData.sublistView(bold.readAsBytesSync())));
    }
    await l.load();
  }
  final il = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
  await il.load();
}

Future<void> _loadFonts() async {
  for (final f in const ['arialbd.ttf']) {
    final file = File('C:\\Windows\\Fonts\\$f');
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    for (final family in const ['Roboto', 'Ahem', '.SF UI Text']) {
      final l = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await l.load();
    }
  }
}

Future<void> _run(
  WidgetTester tester,
  String id,
  List<(String, int)> frames, {
  String? loopAfter,
  bool rest = false,
}) async {
  await tester.runAsync(() async {
    await _loadFonts();
    await IllustratedArtwork.load();
    await FxSprites.load();
  });
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  Directory(_outDir).createSync(recursive: true);

  final theme = ThermosTheme.byId(id);
  final trigger = ValueNotifier<int>(0);
  final tKey = GlobalKey();
  final shot = GlobalKey();
  final celebrationT = ValueNotifier<double?>(null);
  final celebrationLoop = ValueNotifier<double?>(null);

  await tester.pumpWidget(
    RepaintBoundary(
      key: shot,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: ThemeScene(
            theme: theme,
            thermosKey: tKey,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 56),
                  ValueListenableBuilder<int>(
                    valueListenable: trigger,
                    builder: (context, n, _) => LayoutBuilder(
                      builder: (context, constraints) {
                        final natural =
                            constraints.maxWidth *
                            designRect.height /
                            designRect.width;
                        final baseH = natural.clamp(0.0, 600.0);
                        return SizedBox(
                          height: baseH,
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(0, baseH * kThermosDrop),
                              child: Transform.scale(
                                scale: kThermosZoom,
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height: baseH,
                                  width: constraints.maxWidth,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      ThermosView(
                                        key: tKey,
                                        progress: rest ? 0.6 : 1,
                                        goalMl: 2000,
                                        totalMl: rest ? 1200 : 2000,
                                        celebrations: n,
                                        theme: theme,
                                        happy: !rest,
                                        celebrationT: celebrationT,
                                        celebrationLoop: celebrationLoop,
                                        animatedCelebrations: true,
                                      ),
                                      Positioned.fill(
                                        child: CelebrationOverlay(
                                          trigger: n,
                                          theme: theme,
                                          shape: ThermosShape.chubby,
                                          progress: celebrationT,
                                          looping: n > 0,
                                          loopProgress: celebrationLoop,
                                          animated: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));

  Future<void> snap(String name) async {
    await tester.runAsync(() async {
      final boundary =
          shot.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_outDir\\${id}_$name.png')
          .writeAsBytesSync(data!.buffer.asUint8List());
    });
  }

  if (rest) {
    await snap('rest');
    return;
  }
  trigger.value = 1;
  await tester.pump();
  for (final (name, ms) in frames) {
    await tester.pump(Duration(milliseconds: ms));
    await snap(name);
  }
  if (loopAfter != null) {
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1500));
    await snap(loopAfter);
  }
}

// ---- Faz 4 - Yedek, tema ızgarası, widget (390x844, 2x) --------

const _faz4Dir =
    r'C:\Users\PC\Documents\Obsidian Vault\HydroSen\02-Design\faz4';

class _RenderIO implements BackupFileIO {
  _RenderIO(this.text);
  final String? text;

  @override
  bool get canSave => true;
  @override
  bool get canPick => true;
  @override
  Future<bool> saveFile({
    required String fileName,
    required String content,
  }) async => true;
  @override
  Future<String?> pickFileText() async => text;
}

void _faz4Tests() {
  final today = DateTime.now();
  final d0 = DateTime(today.year, today.month, today.day);

  Future<GlobalKey> setUpApp(
    WidgetTester tester,
    String themeId, {
    BackupFileIO? io,
  }) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      await _loadFazFonts();
      await IllustratedArtwork.load();
      await FxSprites.load();
    });
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });
    Directory(_faz4Dir).createSync(recursive: true);
    final shot = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: shot,
        child: HydroSenApp(
          repository: InMemoryWaterRepository([
            WaterEntry(
              id: 1,
              amountMl: 600,
              time: d0.add(const Duration(hours: 8)),
            ),
            WaterEntry(
              id: 2,
              amountMl: 600,
              time: d0.add(const Duration(hours: 10)),
            ),
          ]),
          settingsRepository: InMemorySettingsRepository(
            AppSettings(
              theme: ThermosTheme.byId(themeId),
              animatedCelebrations: false,
            ),
          ),
          streakRepository: InMemoryStreakRepository(
            StreakData(
              start: DateTime(d0.year, d0.month, d0.day - 12),
              through: DateTime(d0.year, d0.month, d0.day - 1),
              goalDays: {
                for (var i = 1; i <= 12; i++)
                  DateTime(d0.year, d0.month, d0.day - i),
              },
              throughGoalMl: 2000,
              lastGoalMl: 2000,
              best: 12,
              badges: {'ilk_kayit': d0, 'ilk_hedef': d0, 's3': d0, 's7': d0},
              celebrated: {'ilk_kayit', 'ilk_hedef', 's3', 's7'},
            ),
          ),
          backupIo: io,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return shot;
  }

  /// Kapak resimleri gerçek zamanlı çözülür; bekle, sonra çek.
  Future<void> snap(WidgetTester tester, GlobalKey shot, String name) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.runAsync(() async {
      final boundary =
          shot.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_faz4Dir\\$name.png').writeAsBytesSync(data!.buffer.asUint8List());
    });
    // Başlamış kapak yüklemeleri test bitmeden tamamlansın (önbellekte asılı kalmasın).
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1500)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  String bigBackup() {
    final entries = [
      for (var i = 0; i < 142; i++)
        WaterEntry(
          id: i + 1,
          amountMl: 200,
          time: DateTime(2026, 11, i < 71 ? 23 : 24, 7 + i % 14),
        ),
    ];
    return BackupCodec.encode(
      BackupData(
        entries: entries,
        settings: const AppSettings(),
        streak: StreakData(
          start: DateTime(2026, 11, 16),
          through: DateTime(2026, 11, 23),
          goalDays: {DateTime(2026, 11, 22), DateTime(2026, 11, 23)},
          best: 7,
          badges: {
            for (final id in [
              'ilk_kayit',
              'ilk_hedef',
              's3',
              's7',
              's15',
              's30',
              's60',
              's100',
            ])
              id: DateTime(2026, 11, 20),
          },
        ),
      ),
    );
  }

  Future<void> scrollProfileTo(WidgetTester tester, Finder target) async {
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      target,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('faz4: yedek bölümü ve geri yükleme onayı', (tester) async {
    final shot = await setUpApp(tester, 'kedi', io: _RenderIO(bigBackup()));
    await scrollProfileTo(tester, find.byKey(const ValueKey('backup-section')));
    await snap(tester, shot, 'profil_yedek');
    await tester.tap(find.byKey(const ValueKey('backup-restore')));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'yedek_onay');
  }, skip: !_enabled);

  testWidgets('faz4: bozuk yedek dosyası', (tester) async {
    final shot = await setUpApp(tester, 'kedi', io: _RenderIO('{ bozuk'));
    await scrollProfileTo(tester, find.byKey(const ValueKey('backup-section')));
    await tester.tap(find.byKey(const ValueKey('backup-restore')));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'yedek_hata');
  }, skip: !_enabled);

  testWidgets('faz4: widget önizlemeleri (Profil)', (tester) async {
    final shot = await setUpApp(tester, 'kedi');
    await scrollProfileTo(tester, find.byKey(const ValueKey('widget-soon')));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'widget_onizleme');
  }, skip: !_enabled);

  testWidgets('faz4: tema ızgarası', (tester) async {
    final shot = await setUpApp(tester, 'panda');
    await tester.tap(find.text('Tema'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-chip-Hayvanlar')));
    await tester.pumpAndSettle();
    await snap(tester, shot, 'tema_izgara');
  }, skip: !_enabled);
}
