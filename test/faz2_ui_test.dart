import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/reminder_planner.dart';
import 'package:hydrosen/features/home/reminder_controller.dart';
import 'package:hydrosen/domain/reminder_messages.dart';
import 'package:hydrosen/features/reminder/reminder_banner.dart';
import 'package:hydrosen/features/reminder/reminder_notifier.dart';
import 'package:hydrosen/features/reminder/reminder_section.dart';
import 'package:hydrosen/features/settings/settings_controller.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeWeb implements ReminderNotifier {
  _FakeWeb([this.permission = ReminderPermission.notAsked]);
  int asked = 0;
  final shown = <ReminderMessage>[];
  @override
  ReminderPermission permission;
  @override
  bool get supported => true;
  @override
  Future<ReminderPermission> requestPermission() async {
    asked++;
    return permission = ReminderPermission.granted;
  }

  @override
  Future<bool> show(ReminderMessage message) async {
    shown.add(message);
    return true;
  }
}

class _Throwing extends _FakeWeb {
  @override
  Future<bool> show(ReminderMessage message) => throw StateError('x');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReminderController', () {
    late DateTime now;
    late DateTime? lastDrink;
    late bool goal;
    late List<ReminderKind> fired;
    late ReminderController c;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      now = DateTime(2026, 11, 16, 9);
      lastDrink = null;
      goal = false;
      fired = [];
      late ReminderController self;
      self = ReminderController(
        onDue: () => fired.add(self.lastKind),
        now: () => now,
        contextProvider: () =>
            ReminderContext(lastDrink: lastDrink, goalReached: goal),
      );
      c = self;
      await c.load();
      await c.configure(active: true);
    });
    tearDown(() => c.dispose());

    test('varsayılanlar', () {
      expect(c.stopAtGoal, isTrue);
      expect(c.dailyCap, 8);
      expect(c.startMinute, 480);
      expect(c.endMinute, 1320);
    });

    test('su kaydı sonraki hatırlatmayı öteler', () {
      now = DateTime(2026, 11, 16, 9, 50);
      lastDrink = DateTime(2026, 11, 16, 9, 45);
      c.checkDue();
      expect(fired, isEmpty);
      expect(c.nextReminder, DateTime(2026, 11, 16, 10, 45));
    });

    test('aynı hatırlatma bir kez gelir, yok sayılırsa yumuşak tekrar', () {
      c.checkDue();
      c.checkDue();
      expect(fired, [ReminderKind.normal]);
      now = DateTime(2026, 11, 16, 9, 30);
      c.checkDue();
      c.checkDue();
      expect(fired, [ReminderKind.normal, ReminderKind.retry]);
      now = DateTime(2026, 11, 16, 9, 59);
      c.checkDue();
      expect(fired.length, 2);
      now = DateTime(2026, 11, 16, 10);
      c.checkDue();
      expect(fired.last, ReminderKind.normal);
      expect(fired.length, 3);
    });

    test('hedef tamamsa sessiz, bitince yarın başlar', () {
      goal = true;
      c.checkDue();
      expect(fired, isEmpty);
      expect(c.nextReminder, DateTime(2026, 11, 17, 9));
      expect(c.plan.reason, ReminderQuiet.goalReached);
    });

    test('günlük üst sınır sayıyı geçmez', () async {
      await c.configure(cap: 3, interval: 30);
      // Her gelen hatırlatmayı su içmeden geçir: 3 sonra sus.
      for (var i = 0; i < 40; i++) {
        now = now.add(const Duration(minutes: 10));
        c.checkDue();
      }
      expect(fired.length, 3);
      expect(c.sentToday, 3);
      expect(c.plan.reason, ReminderQuiet.capReached);
    });

    test('gece yarısı sayaç sıfırlanır', () async {
      await c.configure(cap: 3);
      for (var i = 0; i < 40; i++) {
        now = now.add(const Duration(minutes: 10));
        c.checkDue();
      }
      expect(c.sentToday, 3);
      now = DateTime(2026, 11, 17, 7);
      expect(c.sentToday, 0);
      expect(c.plan.reason, ReminderQuiet.none);
      expect(c.nextReminder, DateTime(2026, 11, 17, 9));
    });

    test('bitiş saatinden sonra eski hatırlatma gelmez', () {
      now = DateTime(2026, 11, 16, 23);
      c.checkDue();
      expect(fired, isEmpty);
    });

    test('geçersiz saat/aralık/sınır değeri reddedilir', () async {
      expect(await c.configure(start: 20 * 60, end: 8 * 60), isFalse);
      expect(await c.configure(interval: 45), isFalse);
      expect(c.startMinute, 480);
      expect(await c.configure(cap: 99), isTrue);
      expect(c.dailyCap, 12);
      expect(await c.configure(cap: 0), isTrue);
      expect(c.dailyCap, 3);
    });

    test('ayarlar ve bugünkü sayaç saklanır', () async {
      await c.configure(stopAtGoalValue: false, cap: 5, interval: 90);
      now = DateTime(2026, 11, 16, 9, 30);
      c.checkDue();
      expect(fired, hasLength(1));
      await pumpEventQueue();
      final again = ReminderController(onDue: () {}, now: () => now);
      await again.load();
      expect(again.stopAtGoal, isFalse);
      expect(again.dailyCap, 5);
      expect(again.intervalMinute, 90);
      expect(again.sentToday, 1);
      again.dispose();
    });
  });

  group('teslimat', () {
    test('bir kanal hata verse de diğeri çalışır', () async {
      final ok = _FakeWeb(ReminderPermission.granted);
      final delivery = ReminderDelivery([_Throwing(), ok]);
      const msg = ReminderMessage(title: 'HydroSen', body: 'x', themeId: 'kedi');
      expect(await delivery.deliver(msg), isTrue);
      expect(ok.shown, hasLength(1));
      expect(msg.capAsset, 'assets/caps/kedi_normal.png');
    });

    test('mobil yer tutucu desteklenmediğini söyler', () async {
      final n = LocalNotificationsReminderNotifier();
      expect(n.supported, isFalse);
      expect(await n.show(const ReminderMessage(
        title: 'a',
        body: 'b',
        themeId: 'kedi',
      )), isFalse);
    });
  });

  group('ayarlar: matara adı', () {
    test('eski kayıtta ad yok: boş liste, tema adı kullanılır', () async {
      SharedPreferences.setMockInitialValues({'settings_goal_ml_v1': 2500});
      final s = await SharedPrefsSettingsRepository().load();
      expect(s.bottleNames, isEmpty);
      expect(s.bottleName(ThermosTheme.byId('kedi')), 'Kedi');
    });

    test('kaydet/oku ve bozuk veriyi atla', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SharedPrefsSettingsRepository();
      await repo.save(
        const AppSettings(bottleNames: {'kedi': 'Pamuk', 'kopek': 'Pamuk'}),
      );
      final back = await repo.load();
      expect(back.customBottleName(ThermosTheme.byId('kedi')), 'Pamuk');

      SharedPreferences.setMockInitialValues({
        'settings_bottle_names_v1':
            '{"kedi":"Pamuk","kopek":"siktir","tavsan":"${'a' * 30}","x":5}',
      });
      final bad = await SharedPrefsSettingsRepository().load();
      expect(bad.bottleNames, {'kedi': 'Pamuk'});
      SharedPreferences.setMockInitialValues({
        'settings_bottle_names_v1': 'bozuk{',
      });
      expect((await SharedPrefsSettingsRepository().load()).bottleNames, isEmpty);
    });

    test('denetleyici: tema başına ad, boş/varsayılan ad siler', () async {
      final repo = InMemorySettingsRepository();
      final c = SettingsController(repository: repo);
      await c.load();
      final kedi = ThermosTheme.byId('kedi');
      final kopek = ThermosTheme.byId('kopek');
      expect((await c.setBottleName(kedi, '  Pamuk ')).isOk, isTrue);
      expect(c.bottleNameOf(kedi), 'Pamuk');
      expect(c.bottleNameOf(kopek), 'Köpek');
      expect((await c.setBottleName(kedi, 'siktir')).isOk, isFalse);
      expect(c.bottleNameOf(kedi), 'Pamuk');
      expect((await c.setBottleName(kedi, 'a' * 17)).isOk, isFalse);
      await c.setBottleName(kedi, '');
      expect(c.bottleNameOf(kedi), 'Kedi');
      expect(c.settings.bottleNames, isEmpty);
      await c.setBottleName(kedi, 'Kedi');
      expect(c.settings.bottleNames, isEmpty);
      c.dispose();
    });
  });

  group('Hatırlatıcı ekranı', () {
    Future<(ReminderController, _FakeWeb)> pump(
      WidgetTester tester, {
      _FakeWeb? web,
    }) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(360, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = ReminderController(
        onDue: () {},
        now: () => DateTime(2026, 11, 16, 8, 10),
      );
      await c.load();
      addTearDown(c.dispose);
      final w = web ?? _FakeWeb();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: c,
              builder: (_, _) => ReminderSection(controller: c, webNotifier: w),
            ),
          ),
        ),
      );
      return (c, w);
    }

    testWidgets('360 px: tüm kontroller taşmadan görünür', (tester) async {
      final (c, _) = await pump(tester);
      await c.configure(active: true);
      await tester.pump();
      expect(find.text('Hatırlatıcı açık'), findsOneWidget);
      expect(find.text('Tekrarlama sıklığı'), findsOneWidget);
      expect(find.text('Hedefe ulaşınca sus'), findsOneWidget);
      expect(find.text('Günlük en fazla'), findsOneWidget);
      expect(find.text('Sonraki hatırlatma: 09:00'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Bildirimlere izin ver'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Bildirimlere izin ver'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final box = tester.getRect(find.byKey(const ValueKey('ask-notification')));
      expect(box.right, lessThanOrEqualTo(360));
      await c.configure(active: false);
    });

    testWidgets('kapalıyken sonraki satır "kapalı" der', (tester) async {
      await pump(tester);
      expect(find.text('Hatırlatıcı kapalı'), findsOneWidget);
    });

    testWidgets('günlük üst sınır 3-12 arasında artar/azalır', (tester) async {
      final (c, _) = await pump(tester);
      expect(c.dailyCap, 8);
      await tester.tap(find.byKey(const ValueKey('daily-cap-plus')));
      await tester.pump();
      expect(c.dailyCap, 9);
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byKey(const ValueKey('daily-cap-plus')),
            warnIfMissed: false);
        await tester.pump();
      }
      expect(c.dailyCap, 12);
      for (var i = 0; i < 12; i++) {
        await tester.tap(find.byKey(const ValueKey('daily-cap-minus')),
            warnIfMissed: false);
        await tester.pump();
      }
      expect(c.dailyCap, 3);
    });

    testWidgets('"Hedefe ulaşınca sus" anahtarı çalışır', (tester) async {
      final (c, _) = await pump(tester);
      expect(c.stopAtGoal, isTrue);
      await tester.tap(find.byKey(const ValueKey('stop-at-goal')));
      await tester.pump();
      expect(c.stopAtGoal, isFalse);
    });

    testWidgets('izin yalnız düğmeye dokununca istenir', (tester) async {
      final (_, web) = await pump(tester);
      expect(web.asked, 0);
      await tester.tap(find.byKey(const ValueKey('ask-notification')));
      await tester.pumpAndSettle();
      expect(web.asked, 1);
      expect(find.text('Bildirimlere izin ver'), findsNothing);
      expect(find.textContaining('Açık.'), findsOneWidget);
    });

    testWidgets('desteklenmeyen kanalda izin satırı gizlenir', (tester) async {
      await pump(
        tester,
        web: _FakeWeb(ReminderPermission.unsupported),
      );
      expect(find.text('Tarayıcı bildirimi'), findsNothing);
    });

    testWidgets('hedef tamam: sonraki satır yarını gösterir', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = ReminderController(
        onDue: () {},
        now: () => DateTime(2026, 11, 16, 12),
        contextProvider: () => const ReminderContext(goalReached: true),
      );
      await c.load();
      await c.configure(active: true);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReminderSection(controller: c)),
        ),
      );
      expect(find.textContaining('Yarın 09:00'), findsOneWidget);
      expect(find.textContaining('sessiz kalıyorum'), findsOneWidget);
      await c.configure(active: false);
    });
  });

  group('uygulama içi banner', () {
    testWidgets('temalı cümleyi ve avatarı gösterir, 360 px taşmaz',
        (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final theme = ThermosTheme.byId('kopek');
      final inApp = InAppReminderNotifier((m) => showReminderBanner(
            tester.element(find.byType(Scaffold)),
            m,
            theme,
          ));
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await ReminderDelivery([inApp]).deliver(ReminderMessage(
        title: 'HydroSen',
        body: ReminderMessages.pick(themeId: 'kopek', name: 'Pamuk'),
        themeId: 'kopek',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('reminder-banner')), findsOneWidget);
      expect(find.textContaining('Pamuk susadı'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Profil: Matara adı', () {
    Future<InMemorySettingsRepository> openProfile(
      WidgetTester tester, {
      AppSettings initial = const AppSettings(),
    }) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
        tester.view.reset();
      });
      final repo = InMemorySettingsRepository(initial);
      await tester.pumpWidget(
        HydroSenApp(
          repository: InMemoryWaterRepository(),
          settingsRepository: repo,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('sıcak başlık, alan ve kaydet; ad kaydolur', (tester) async {
      final repo = await openProfile(
        tester,
        initial: AppSettings(theme: ThermosTheme.byId('kopek')),
      );
      expect(find.text('Karakterine bir isim ver'), findsOneWidget);
      expect(find.text('Matara adı'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('bottle-name-field')),
        '  Pamuk ',
      );
      await tester.tap(find.byKey(const ValueKey('bottle-name-save')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('bottle-name-ok')), findsOneWidget);
      expect(find.textContaining('Güzel isim! Pamuk'), findsOneWidget);
      final saved = await repo.load();
      expect(saved.customBottleName(ThermosTheme.byId('kopek')), 'Pamuk');
      expect(tester.takeException(), isNull);
    });

    testWidgets('uygunsuz ad nazik mesajla reddedilir', (tester) async {
      final repo = await openProfile(tester);
      await tester.enterText(
        find.byKey(const ValueKey('bottle-name-field')),
        's1kt1r',
      );
      await tester.tap(find.byKey(const ValueKey('bottle-name-save')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Bu ismi kullanamıyoruz'), findsOneWidget);
      expect((await repo.load()).bottleNames, isEmpty);
    });

    testWidgets('alan 16 karakterle sınırlıdır', (tester) async {
      await openProfile(tester);
      await tester.enterText(
        find.byKey(const ValueKey('bottle-name-field')),
        'a' * 30,
      );
      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('bottle-name-field')),
      );
      expect(field.controller!.text.length, 16);
    });

    testWidgets('kayıtlı ad alanda görünür ve boşaltınca varsayılana döner',
        (tester) async {
      final repo = await openProfile(
        tester,
        initial: const AppSettings(bottleNames: {'klasik': 'Damla'}),
      );
      expect(find.text('Damla'), findsWidgets);
      await tester.enterText(
        find.byKey(const ValueKey('bottle-name-field')),
        '',
      );
      await tester.tap(find.byKey(const ValueKey('bottle-name-save')));
      await tester.pumpAndSettle();
      expect((await repo.load()).bottleNames, isEmpty);
      expect(find.textContaining('tema adına döndü'), findsOneWidget);
    });
  });
}
