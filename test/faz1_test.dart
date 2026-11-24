// Faz 1 – Kayıt kolaylığı: içecek türü, kayıtlı kaplar, kaydı düzenleme,
// geçmiş güne kayıt.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/drink_type.dart';
import 'package:hydrosen/domain/saved_container.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/home/water_controller.dart';
import 'package:hydrosen/features/settings/settings_controller.dart';
import 'package:hydrosen/features/settings/settings_screen.dart';
import 'package:hydrosen/features/thermos/thermos_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void prepare(WidgetTester tester, {Size size = const Size(360, 800)}) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    tester.view.reset();
  });
}

int totalMlOf(WidgetTester tester) =>
    tester.widget<ThermosView>(find.byType(ThermosView)).totalMl!;

Future<void> pumpApp(
  WidgetTester tester, {
  WaterRepository? repo,
  SettingsRepository? settings,
}) async {
  await tester.pumpWidget(
    HydroSenApp(
      repository: repo ?? InMemoryWaterRepository(),
      settingsRepository: settings ?? InMemorySettingsRepository(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('içecek oranları', () {
    test('oranlar: su/maden 100, ayran 90, çay 80, kahve 60', () {
      expect(DrinkType.water.percent, 100);
      expect(DrinkType.mineral.percent, 100);
      expect(DrinkType.ayran.percent, 90);
      expect(DrinkType.tea.percent, 80);
      expect(DrinkType.coffee.percent, 60);
    });

    test('sayılan ml = round(ml × oran)', () {
      expect(DrinkType.water.countedMl(200), 200);
      expect(DrinkType.mineral.countedMl(333), 333);
      expect(DrinkType.ayran.countedMl(250), 225);
      expect(DrinkType.tea.countedMl(200), 160);
      expect(DrinkType.coffee.countedMl(90), 54);
      // Yarım değerler yukarı yuvarlanır: 125 × 0,6 = 75; 15 × 0,9 = 13,5 → 14.
      expect(DrinkType.ayran.countedMl(15), 14);
      expect(DrinkType.coffee.countedMl(1), 1);
    });

    test('kayıtta ham ml kalır, sayılan ayrı hesaplanır', () {
      final e = WaterEntry(
        id: 1,
        amountMl: 200,
        time: DateTime(2026, 11, 10, 9),
        drink: DrinkType.tea,
      );
      expect(e.amountMl, 200);
      expect(e.countedMl, 160);
    });
  });

  group('JSON geriye uyumluluk', () {
    test('eski kayıt (içecek alanı yok) su olarak yüklenir', () {
      final e = WaterEntry.fromJson({
        'id': 3,
        'ml': 250,
        't': DateTime(2026, 11, 10, 8).toIso8601String(),
      });
      expect(e.drink, DrinkType.water);
      expect(e.countedMl, 250);
    });

    test('bilinmeyen içecek kimliği su sayılır', () {
      final e = WaterEntry.fromJson({
        'id': 3,
        'ml': 250,
        't': DateTime(2026, 11, 10, 8).toIso8601String(),
        'd': 'yok',
      });
      expect(e.drink, DrinkType.water);
    });

    test('su kaydı eski biçimle yazılır; çay kaydı gidiş-dönüş yapar', () {
      final t = DateTime(2026, 11, 10, 8);
      expect(
        WaterEntry(id: 1, amountMl: 200, time: t).toJson().containsKey('d'),
        isFalse,
      );
      final tea = WaterEntry(
        id: 2,
        amountMl: 200,
        time: t,
        drink: DrinkType.tea,
      );
      final back = WaterEntry.fromJson(
        (jsonDecode(jsonEncode(tea.toJson())) as Map).cast<String, Object?>(),
      );
      expect(back.drink, DrinkType.tea);
      expect(back.amountMl, 200);
    });

    test('depo eski JSON dizisini okur', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsWaterRepository.key: jsonEncode([
          {
            'id': 1,
            'ml': 200,
            't': DateTime(2026, 11, 10, 8).toIso8601String(),
          },
          {
            'id': 2,
            'ml': 300,
            't': DateTime(2026, 11, 10, 9).toIso8601String(),
            'd': 'kahve',
          },
        ]),
      });
      final list = await SharedPrefsWaterRepository().load();
      expect(list.map((e) => e.drink), [DrinkType.water, DrinkType.coffee]);
    });
  });

  group('WaterController', () {
    final today = DateTime(2026, 11, 10, 14);
    WaterController make([WaterRepository? repo]) => WaterController(
      repository: repo ?? InMemoryWaterRepository(),
      goalMl: 2000,
      now: () => today,
    );

    test('toplam sayılan ml ile hesaplanır; hızlı ekleme su kalır', () async {
      final c = make();
      await c.load();
      await c.add(200); // su
      await c.add(200, drink: DrinkType.tea); // 160
      await c.add(100, drink: DrinkType.coffee); // 60
      expect(c.totalMl, 420);
      expect(c.todayEntries.first.drink, DrinkType.coffee);
      expect(c.todayEntries.last.drink, DrinkType.water);
    });

    test('hedef kutlaması sayılan ml ile tetiklenir', () async {
      final c = make();
      await c.load();
      await c.add(1500, drink: DrinkType.coffee); // 900 sayılır
      await c.add(1000, drink: DrinkType.tea); // +800 → 1700
      expect(c.totalMl, 1700);
      expect(c.celebrations, 0);
      await c.add(300); // 2000
      expect(c.celebrations, 1);
    });

    test('bardak çıkarma sayılan ml üzerinden çalışır', () async {
      final c = make();
      await c.load();
      await c.add(500, drink: DrinkType.tea); // 400 sayılır
      final removed = await c.removeAmount(200);
      expect(removed, 200);
      expect(c.totalMl, 200);
      expect(c.todayEntries.single.amountMl, 250); // ham miktar küçüldü
    });

    test('düzenleme kaydı yerinde günceller, kimlik korunur', () async {
      final c = make();
      await c.load();
      await c.add(200);
      await c.add(300);
      final target = c.todayEntries.last;
      final ok = await c.update(
        target.id,
        amountMl: 250,
        drink: DrinkType.ayran,
        time: DateTime(2026, 11, 10, 7, 30),
      );
      expect(ok, isTrue);
      final all = c.allEntries;
      expect(all.length, 2);
      final edited = all.firstWhere((e) => e.id == target.id);
      expect(edited.amountMl, 250);
      expect(edited.drink, DrinkType.ayran);
      expect(edited.time, DateTime(2026, 11, 10, 7, 30));
      expect(c.totalMl, 225 + 300);
      // Diğer kayıt değişmedi.
      expect(all.firstWhere((e) => e.id != target.id).amountMl, 300);
      // Geri al düzenlemeyi geri alır.
      await c.undo();
      expect(c.totalMl, 500);
      expect(await c.update(999, amountMl: 5), isFalse);
      expect(await c.update(target.id, amountMl: 0), isFalse);
    });

    test('geçmiş güne kayıt bugünün toplamını etkilemez', () async {
      final repo = InMemoryWaterRepository();
      final c = make(repo);
      await c.load();
      await c.add(200);
      await c.add(400, drink: DrinkType.tea, time: DateTime(2026, 11, 8, 12));
      expect(c.totalMl, 200);
      expect(c.todayEntries.length, 1);
      expect(c.allEntries.length, 2);
      expect((await repo.load()).length, 2);
      // Bugüne özel saatle kayıt toplama girer.
      await c.add(100, time: DateTime(2026, 11, 10, 6, 15));
      expect(c.totalMl, 300);
      expect(c.todayEntries.last.time, DateTime(2026, 11, 10, 6, 15));
    });
  });

  group('kayıtlı kaplar', () {
    test('varsayılanlar Bardak 200, Kupa 300, Matara 500', () {
      final list = const AppSettings().containers;
      expect(list.map((c) => '${c.name} ${c.ml}'), [
        'Bardak 200',
        'Kupa 300',
        'Matara 500',
      ]);
    });

    test('ekle, düzenle, sil ve kalıcılık', () async {
      final repo = SharedPrefsSettingsRepository();
      final c = SettingsController(repository: repo);
      await c.load();
      expect(c.containers.length, 3);

      expect(await c.addContainer('Şişe', 750), isTrue);
      expect(await c.addContainer('  ', 100), isFalse);
      expect(await c.addContainer('Kötü', 0), isFalse);
      expect(await c.updateContainer(2, name: 'Büyük kupa', ml: 400), isTrue);
      expect(await c.removeContainer(1), isTrue);

      final reloaded = await SharedPrefsSettingsRepository().load();
      expect(reloaded.containers.map((e) => '${e.name} ${e.ml}'), [
        'Büyük kupa 400',
        'Matara 500',
        'Şişe 750',
      ]);
      // Kimlikler korunur; yeni kap çakışmayan kimlik alır.
      expect(reloaded.containers.map((e) => e.id), [2, 3, 4]);
    });

    test('en az bir kap kalır', () async {
      final c = SettingsController(repository: InMemorySettingsRepository());
      await c.load();
      expect(await c.removeContainer(1), isTrue);
      expect(await c.removeContainer(2), isTrue);
      expect(await c.removeContainer(3), isFalse);
      expect(c.containers.length, 1);
    });

    test('en çok sekiz kap', () async {
      final c = SettingsController(repository: InMemorySettingsRepository());
      await c.load();
      for (var i = 0; i < 5; i++) {
        expect(await c.addContainer('Kap $i', 100 + i), isTrue);
      }
      expect(c.containers.length, AppSettings.maxContainers);
      expect(await c.addContainer('Fazla', 100), isFalse);
    });

    test(
      'eski ayarlar (kap anahtarı yok) varsayılan kaplarla açılır',
      () async {
        SharedPreferences.setMockInitialValues({
          SharedPrefsSettingsRepository.goalKey: 2400,
        });
        final s = await SharedPrefsSettingsRepository().load();
        expect(s.goalMl, 2400);
        expect(s.containers, AppSettings.defaultContainers);
      },
    );

    test('bozuk kap verisi çökmez; geçerli kaplar kalır', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsSettingsRepository.containersKey: jsonEncode([
          {'id': 1, 'name': 'Tamam', 'ml': 250},
          {'id': 2, 'name': 'Eksi', 'ml': -5},
          'çöp',
        ]),
      });
      final s = await SharedPrefsSettingsRepository().load();
      expect(s.containers, [
        const SavedContainer(id: 1, name: 'Tamam', ml: 250),
      ]);

      SharedPreferences.setMockInitialValues({
        SharedPrefsSettingsRepository.containersKey: '{bozuk',
      });
      expect(
        (await SharedPrefsSettingsRepository().load()).containers,
        AppSettings.defaultContainers,
      );
    });
  });

  group('arayüz (360 px)', () {
    testWidgets('özel miktar: kap düğmesi doldurur, çay oranla sayılır', (
      tester,
    ) async {
      prepare(tester);
      await pumpApp(tester);

      await tester.tap(find.text('Özel miktar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('container-chip-2')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '300',
      );
      await tester.tap(find.byKey(const ValueKey('drink-chip-cay')));
      await tester.pumpAndSettle();
      expect(find.text('300 ml çay · 240 ml sayılır'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Ekle'));
      await tester.pumpAndSettle();
      expect(totalMlOf(tester), 240);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hızlı düğmeler su eklemeye devam eder', (tester) async {
      prepare(tester);
      final repo = InMemoryWaterRepository();
      await pumpApp(tester, repo: repo);
      await tester.tap(find.byKey(const ValueKey('quick-add-1')));
      await tester.pumpAndSettle();
      expect((await repo.load()).single.drink, DrinkType.water);
    });

    testWidgets('Kayıtlar listesinde çay kaydı; dokununca düzenlenir ve silinir', (
      tester,
    ) async {
      prepare(tester);
      final now = DateTime.now();
      // Gün ortasına denk gelmeyen saatlerde de bugün kalsın.
      final t = DateTime(now.year, now.month, now.day);
      final repo = InMemoryWaterRepository([
        WaterEntry(id: 1, amountMl: 200, time: t, drink: DrinkType.tea),
      ]);
      await pumpApp(tester, repo: repo);
      expect(totalMlOf(tester), 160);
      // Ana ekran yalnız termos ve düğmeler: kayıt listesi yok.
      expect(find.textContaining('sayıldı'), findsNothing);

      await tester.tap(find.text('Kayıtlar'));
      await tester.pumpAndSettle();
      final tile = find.byKey(const ValueKey('record-1'));
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      expect(find.text('200 ml çay · 160 ml sayıldı'), findsOneWidget);

      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.text('Kaydı düzenle'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byKey(const ValueKey('entry-amount')), '300');
      await tester.tap(find.byKey(const ValueKey('drink-chip-kahve')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('entry-save')));
      await tester.pumpAndSettle();
      final saved = (await repo.load()).single;
      expect(saved.id, 1);
      expect(saved.amountMl, 300);
      expect(saved.drink, DrinkType.coffee);
      expect(saved.time, t);

      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('entry-delete')));
      await tester.pumpAndSettle();
      expect(await repo.load(), isEmpty);
      await tester.tap(find.text('Günlük'));
      await tester.pumpAndSettle();
      expect(totalMlOf(tester), 0);
    });

    testWidgets(
      'Kayıtlar: geçmiş güne kayıt 12:00 ile eklenir, bugünü etkilemez',
      (tester) async {
        prepare(tester);
        final repo = InMemoryWaterRepository();
        await pumpApp(tester, repo: repo);
        await tester.tap(
          find.byKey(const ValueKey('quick-add-1')),
        ); // 200 bugün
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kayıtlar'));
        await tester.pumpAndSettle();
        // Önceki haftaya geç: seçili gün geçmiş bir gün olur.
        await tester.tap(find.byTooltip('Önceki dönem'));
        await tester.pumpAndSettle();
        final add = find.byKey(const ValueKey('records-add'));
        await tester.ensureVisible(add);
        await tester.pumpAndSettle();
        await tester.tap(add);
        await tester.pumpAndSettle();
        expect(find.text('Kayıt ekle'), findsWidgets);
        expect(find.text('12:00'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.enterText(
          find.byKey(const ValueKey('entry-amount')),
          '250',
        );
        await tester.tap(find.byKey(const ValueKey('drink-chip-ayran')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('entry-save')));
        await tester.pumpAndSettle();

        final entries = await repo.load();
        expect(entries.length, 2);
        final past = entries.firstWhere((e) => e.amountMl == 250);
        final now = DateTime.now();
        expect(past.time.hour, 12);
        expect(past.time.minute, 0);
        expect(
          past.time.isBefore(DateTime(now.year, now.month, now.day)),
          isTrue,
        );
        expect(past.drink, DrinkType.ayran);

        await tester.tap(find.text('Günlük'));
        await tester.pumpAndSettle();
        expect(totalMlOf(tester), 200);
      },
    );

    testWidgets(
      'Kayıtlar: bugüne kayıt boş miktarda uyarır, şimdiki saatle eklenir',
      (tester) async {
        prepare(tester);
        final repo = InMemoryWaterRepository();
        await pumpApp(tester, repo: repo);
        await tester.tap(find.text('Kayıtlar'));
        await tester.pumpAndSettle();
        // Bugün seçili: 'Kayıt ekle' şimdiki saati önerir ve kaydeder.
        final add = find.byKey(const ValueKey('records-add'));
        await tester.ensureVisible(add);
        await tester.pumpAndSettle();
        await tester.tap(add);
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('entry-save')),
        ); // boş miktar
        await tester.pumpAndSettle();
        expect(find.text('1–5000 arasında bir sayı gir'), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('entry-amount')),
          '150',
        );
        await tester.tap(find.byKey(const ValueKey('entry-save')));
        await tester.pumpAndSettle();
        expect((await repo.load()).single.amountMl, 150);
      },
    );

    testWidgets('Kaplarım: ekle, düzenle, sil; son kap silinemez', (
      tester,
    ) async {
      prepare(tester);
      final c = SettingsController(repository: InMemorySettingsRepository());
      await c.load();
      await tester.pumpWidget(MaterialApp(home: SettingsScreen(controller: c)));
      await tester.pumpAndSettle();
      final section = find.byKey(const ValueKey('containers-section'));
      await tester.ensureVisible(section);
      await tester.pumpAndSettle();
      expect(find.text('Kaplarım'), findsOneWidget);
      expect(find.text('Kupa · 300 ml'), findsOneWidget);

      // Düzenle.
      await tester.tap(find.byKey(const ValueKey('container-edit-2')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('container-name')),
        'Çaylık',
      );
      await tester.enterText(find.byKey(const ValueKey('container-ml')), '120');
      await tester.tap(find.byKey(const ValueKey('container-save')));
      await tester.pumpAndSettle();
      expect(find.text('Çaylık · 120 ml'), findsOneWidget);
      expect(c.containers[1].ml, 120);

      // Ekle.
      final addBtn = find.byKey(const ValueKey('container-add'));
      await tester.ensureVisible(addBtn);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('container-save'))); // boş
      await tester.pumpAndSettle();
      expect(find.text('Bir ad yaz'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('container-name')),
        'Şişe',
      );
      await tester.enterText(find.byKey(const ValueKey('container-ml')), '750');
      await tester.tap(find.byKey(const ValueKey('container-save')));
      await tester.pumpAndSettle();
      expect(c.containers.last.name, 'Şişe');

      // Sil, ta ki bir tane kalana dek.
      while (c.containers.length > 1) {
        final id = c.containers.first.id;
        final del = find.byKey(ValueKey('container-delete-$id'));
        await tester.ensureVisible(del);
        await tester.pumpAndSettle();
        await tester.tap(del);
        await tester.pumpAndSettle();
      }
      final lastId = c.containers.single.id;
      expect(
        tester
            .widget<IconButton>(
              find.byKey(ValueKey('container-delete-$lastId')),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
