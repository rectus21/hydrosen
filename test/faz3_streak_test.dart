// Faz 3 – Seri ve rozetler: seri motoru, kaçırma hakkı, rozetler, kalıcılık,
// Rozetlerim bölümü ve ana ekran satırı.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/streak_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/badges.dart';
import 'package:hydrosen/domain/drink_type.dart';
import 'package:hydrosen/domain/streak.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/badges/badge_popup.dart';
import 'package:hydrosen/features/badges/badges_section.dart';
import 'package:hydrosen/features/badges/streak_line.dart';
import 'package:hydrosen/features/home/water_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gün gün uygulamayı açıp su içen basit benzetim.
class Sim {
  Sim({this.goal = 2000});

  static final day0 = DateTime(2026, 3, 1);

  int goal;
  StreakData? data;
  late StreakStatus status;
  final ml = <DateTime, int>{};

  DateTime day(int n) => DateTime(day0.year, day0.month, day0.day + n);

  void drink(int dayNo, int amount) {
    final d = day(dayNo);
    ml[d] = (ml[d] ?? 0) + amount;
  }

  /// [dayNo]. günde uygulamayı açar (gün içinde saat 12).
  StreakStatus open(int dayNo) {
    final r = StreakEngine.advance(
      data: data,
      now: day(dayNo).add(const Duration(hours: 12)),
      dailyCountedMl: ml,
      goalMl: goal,
    );
    data = r.data;
    return status = r.status;
  }

  /// [dayNo]. günde açılır, hedefe ulaşır, tekrar sync olur.
  StreakStatus goalDay(int dayNo) {
    open(dayNo);
    drink(dayNo, goal);
    return open(dayNo);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('seri motoru', () {
    test('ardışık hedef günleri seriyi artırır', () {
      final s = Sim();
      for (var i = 0; i < 5; i++) {
        expect(s.goalDay(i).current, i + 1);
      }
      expect(s.status.todayDone, isTrue);
      expect(s.status.best, 5);
    });

    test('bugün bitmediyse seri dünkü değeri gösterir ve bozulmaz', () {
      final s = Sim();
      s.goalDay(0);
      s.goalDay(1);
      s.goalDay(2);
      final st = s.open(3);
      expect(st.todayDone, isFalse);
      expect(st.current, 3);
      // Gün içinde yarım su içmek de bozmaz.
      s.drink(3, 900);
      expect(s.open(3).current, 3);
      s.drink(3, 1100);
      expect(s.open(3).current, 4);
    });

    test('hak yokken kaçırılan gün seriyi sıfırlar', () {
      final s = Sim();
      s.goalDay(0);
      s.goalDay(1);
      // 2. gün hiç içilmedi.
      final st = s.open(3);
      expect(st.current, 0);
      expect(st.protectedDays, isEmpty);
      expect(st.best, 2);
      // Yeni seri sıfırdan, "en uzun seri" korunur.
      expect(s.goalDay(3).current, 1);
      expect(s.status.best, 2);
    });

    test('hak varken kaçırılan gün korunur: seri artmaz ve bozulmaz', () {
      final s = Sim();
      for (var i = 0; i < 7; i++) {
        s.goalDay(i);
      }
      expect(s.status.rights, 1);
      // 7. gün kaçırıldı, 8. günde açılış.
      var st = s.open(8);
      expect(st.protectedDays, {s.day(7)});
      expect(st.rights, 0);
      expect(st.current, 7); // artmadı, bozulmadı
      expect(st.yesterdayProtected, isTrue);
      st = s.goalDay(8);
      expect(st.current, 8);
      expect(st.goalDaysTotal, 8);
    });

    test('her 7 hedef gününde 1 hak, en fazla 2', () {
      final s = Sim();
      for (var i = 0; i < 6; i++) {
        s.goalDay(i);
      }
      expect(s.status.rights, 0);
      expect(s.status.goalDaysToNextRight, 1);
      s.goalDay(6);
      expect(s.status.rights, 1);
      for (var i = 7; i < 14; i++) {
        s.goalDay(i);
      }
      expect(s.status.rights, 2);
      expect(s.status.goalDaysToNextRight, isNull);
      for (var i = 14; i < 21; i++) {
        s.goalDay(i);
      }
      expect(s.status.rights, 2); // tavan
      expect(s.status.current, 21);
    });

    test('günlerce ara: her kaçırılan gün sırayla hak harcar', () {
      final s = Sim();
      for (var i = 0; i < 14; i++) {
        s.goalDay(i);
      }
      expect(s.status.rights, 2);
      // 14, 15 kaçırıldı; 16'da açılış: iki hak harcanır, seri durur.
      var st = s.open(16);
      expect(st.protectedDays, {s.day(14), s.day(15)});
      expect(st.rights, 0);
      expect(st.current, 14);
      // Üç gün ara (14, 15, 16): ilk ikisi korunur, üçüncüsü seriyi bozar.
      final t = Sim();
      for (var i = 0; i < 14; i++) {
        t.goalDay(i);
      }
      st = t.open(17);
      expect(st.protectedDays, {t.day(14), t.day(15)});
      expect(st.current, 0);
      expect(st.best, 14);
    });

    test('geç kayıt yalnız dünü yeniden değerlendirir', () {
      final s = Sim();
      s.goalDay(0);
      // 1. gün unutuldu; 2. günde açılış: seri sıfırlandı.
      expect(s.open(2).current, 0);
      // Dünkü (1.) su geriye dönük girildi: dün hedefe ulaşır.
      s.drink(1, 2000);
      var st = s.open(2);
      expect(st.current, 2);
      expect(st.goalDaysTotal, 2);
      // 3. günde açılış: 1. gün artık "dün" değil; 2. gün (dün) hedefsiz.
      st = s.open(3);
      expect(st.current, 0);
      // Daha eski bir güne (0.) kayıt eklemek hiçbir şeyi değiştirmez.
      s.drink(0, 5000);
      s.drink(1, 5000);
      expect(s.open(3).current, 0);
      expect(s.status.goalDaysTotal, 2);
    });

    test('dünü geç kayıtla düzeltmek bugünün seri hesabını da düzeltir', () {
      final s = Sim();
      for (var i = 0; i < 3; i++) {
        s.goalDay(i);
      }
      expect(s.open(4).current, 0); // 3. gün unutuldu
      s.drink(3, 2000); // geç kayıt
      final st = s.open(4);
      expect(st.current, 4);
      expect(st.todayDone, isFalse);
    });

    test(
      'hedef değişimi: bugün güncel hedefle, biten günler kendi hedefiyle',
      () {
        final s = Sim(goal: 1500);
        s.drink(0, 1500);
        expect(s.open(0).todayDone, isTrue);
        // Ertesi gün hedef 2500 yapılır; dün 1500 hedefiyle kayıtlıydı.
        s.open(1);
        s.goal = 2500;
        var st = s.open(1);
        expect(st.todayDone, isFalse);
        expect(st.current, 1); // dün 1500 hedefiyle başarılı sayılı kalır
        // Gün içinde hedef düşürülürse bugün hemen sayılır.
        s.drink(1, 1600);
        expect(s.open(1).todayDone, isFalse);
        s.goal = 1600;
        st = s.open(1);
        expect(st.todayDone, isTrue);
        expect(st.current, 2);
        // Hedef yeniden yükselirse bugün yeniden bekler; en uzun seri düşmez.
        s.goal = 3000;
        st = s.open(1);
        expect(st.todayDone, isFalse);
        expect(st.current, 1);
        expect(st.best, 2);
      },
    );

    test('en uzun seri yalnız artar', () {
      final s = Sim();
      for (var i = 0; i < 5; i++) {
        s.goalDay(i);
      }
      expect(s.open(7).current, 0);
      s.goalDay(7);
      s.goalDay(8);
      expect(s.status.current, 2);
      expect(s.status.best, 5);
    });

    test('içecek oranıyla sayılan ml hedefe bakar (kahve 0,6)', () {
      final s = Sim();
      s.drink(0, DrinkType.coffee.countedMl(3000)); // 1800 < 2000
      expect(s.open(0).todayDone, isFalse);
      s.drink(0, 200);
      expect(s.open(0).todayDone, isTrue);
    });
  });

  group('rozetler', () {
    test('ilk kayıt, ilk hedef ve seri eşikleri kalıcı olarak verilir', () {
      final s = Sim();
      s.drink(0, 100);
      s.open(0);
      expect(s.data!.badges.keys, [Badges.firstEntryId]);
      s.drink(0, 1900);
      s.open(0);
      expect(s.data!.badges.containsKey(Badges.firstGoalId), isTrue);
      s.goalDay(1);
      expect(s.data!.badges.containsKey('s3'), isFalse);
      s.goalDay(2);
      expect(s.data!.badges['s3'], s.day(2));
      // Seri bozulsa da rozet kalır.
      s.open(10);
      expect(s.status.current, 0);
      expect(s.data!.badges.containsKey('s3'), isTrue);
    });

    test('tüm eşikler: 3, 7, 15, 30, 60, 100, 180, 365', () {
      expect(Badges.streakDays, [3, 7, 15, 30, 60, 100, 180, 365]);
      final s = Sim();
      for (var i = 0; i < 365; i++) {
        s.goalDay(i);
      }
      for (final t in Badges.streakDays) {
        expect(s.data!.badges['s$t'], s.day(t - 1), reason: 's$t');
      }
      expect(Badges.byId('s365')!.tier, BadgeTier.diamond);
    });

    test('rozetler ve tarihleri JSON gidiş-dönüşünde korunur', () {
      final s = Sim();
      for (var i = 0; i < 7; i++) {
        s.goalDay(i);
      }
      s.open(9);
      final back = StreakData.fromJson(s.data!.toJson())!;
      expect(back.badges, s.data!.badges);
      expect(back.best, 7);
      expect(back.goalDays, s.data!.goalDays);
      expect(back.start, s.data!.start);
      expect(back.through, s.data!.through);
      // Aynı veriyle yeniden hesap aynı sonucu verir.
      final again = StreakEngine.advance(
        data: back,
        now: s.day(9).add(const Duration(hours: 12)),
        dailyCountedMl: s.ml,
        goalMl: 2000,
      );
      expect(again.status.current, s.status.current);
      expect(again.status.rights, s.status.rights);
    });

    test('bozuk veri null döner', () {
      expect(StreakData.fromJson('x'), isNull);
      expect(StreakData.fromJson({'start': 'bozuk'}), isNull);
    });
  });

  group('eski kurulumdan başlangıç', () {
    test('seri bir kez mevcut kayıt geçmişinden hesaplanır', () {
      final s = Sim();
      // Veri yok; geçmişte 3 hedef günü (0,1,2), sonra boş, 5. gün hedef.
      for (final d in [0, 1, 2, 5]) {
        s.drink(d, 2000);
      }
      final st = s.open(6); // data == null: geçmişten kurulur
      expect(s.data!.start, s.day(0));
      expect(st.goalDaysTotal, 4);
      expect(st.best, 3);
      expect(st.current, 1); // 3-4 kaçırıldı (hak yok), 5 hedef, 6 bekliyor
      expect(s.data!.badges.keys.toSet(), {
        Badges.firstEntryId,
        Badges.firstGoalId,
        's3',
      });
      // Toplu rozet yağmuru olmaz: yalnız en değerlisi kutlanmayı bekler.
      final pending = s.data!.badges.keys.toSet().difference(
        s.data!.celebrated,
      );
      expect(pending, {'s3'});
    });

    test('kaydı olmayan yeni kullanıcı bugünden başlar, rozet yok', () {
      final s = Sim();
      final st = s.open(0);
      expect(s.data!.start, s.day(0));
      expect(st.current, 0);
      expect(s.data!.badges, isEmpty);
    });
  });

  group('WaterController', () {
    late DateTime now;
    late InMemoryStreakRepository streakRepo;
    late InMemoryWaterRepository waterRepo;

    WaterController make({List<WaterEntry> entries = const []}) {
      waterRepo = InMemoryWaterRepository(entries);
      return WaterController(
        repository: waterRepo,
        streakRepository: streakRepo,
        now: () => now,
      );
    }

    setUp(() {
      now = DateTime(2026, 5, 10, 9);
      streakRepo = InMemoryStreakRepository();
    });

    test('hedefe ulaşınca seri ve rozetler işlenir, kalıcı olur', () async {
      final c = make();
      await c.load();
      expect(c.streak.current, 0);
      expect(c.pendingBadges, isEmpty);
      await c.add(500);
      expect(c.pendingBadges.map((b) => b.id), [Badges.firstEntryId]);
      await c.add(1500);
      expect(c.streak.todayDone, isTrue);
      expect(c.streak.current, 1);
      expect(c.pendingBadges.map((b) => b.id), [
        Badges.firstEntryId,
        Badges.firstGoalId,
      ]);
      await c.markBadgeCelebrated(Badges.firstEntryId);
      expect(streakRepo.data!.celebrated, {Badges.firstEntryId});

      // Uygulama yeniden açılır: durum ve kutlanmamış rozet geri gelir.
      final c2 = make(entries: await waterRepo.load());
      await c2.load();
      expect(c2.streak.current, 1);
      expect(c2.pendingBadges.map((b) => b.id), [Badges.firstGoalId]);
    });

    test('gece yarısını geçen açılışta kaçırılan gün işlenir', () async {
      final c = make();
      await c.load();
      await c.add(2000);
      expect(c.streak.current, 1);
      now = DateTime(2026, 5, 12, 8); // iki gün sonra (11. gün kaçırıldı)
      await c.refresh();
      expect(c.streak.todayDone, isFalse);
      expect(c.streak.current, 0);
      expect(c.streak.best, 1);
    });

    test(
      'geç kayıt yalnız dünü etkiler; kayıt silinince bugün geri alınır',
      () async {
        final c = make();
        await c.load();
        await c.add(2000);
        now = DateTime(2026, 5, 11, 8);
        await c.refresh();
        expect(c.streak.current, 1);
        await c.add(2000, time: DateTime(2026, 5, 10, 22)); // dün, fazla
        expect(c.streak.current, 1);
        await c.add(2000);
        expect(c.streak.current, 2);
        await c.undo();
        expect(c.streak.current, 1);
      },
    );

    test('eski kurulum: seri kayıtlardan bir kez kurulup saklanır', () async {
      final entries = [
        for (var d = 5; d >= 1; d--)
          WaterEntry(
            id: 6 - d,
            amountMl: 2000,
            time: DateTime(2026, 5, 10 - d, 10),
          ),
      ];
      final c = make(entries: entries);
      expect(streakRepo.data, isNull);
      await c.load();
      expect(c.streak.current, 5);
      expect(c.streak.rights, 0);
      expect(streakRepo.data, isNotNull);
      expect(streakRepo.data!.badges.containsKey('s3'), isTrue);
      expect(c.pendingBadges.map((b) => b.id), ['s3']);
    });
  });

  group('arayüz', () {
    void narrow(WidgetTester tester, {double h = 1600}) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      tester.view.physicalSize = Size(360, h);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
        tester.view.reset();
      });
    }

    testWidgets('Rozetlerim 360 px: taşma yok, hak ve kilitli rozetler', (
      tester,
    ) async {
      narrow(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: BadgesPanel(
                status: const StreakStatus(
                  current: 12,
                  best: 16,
                  rights: 1,
                  todayDone: true,
                  goalDaysTotal: 20,
                  protectedDays: {},
                  yesterdayProtected: false,
                ),
                earned: {
                  Badges.firstEntryId: DateTime(2026, 3, 1),
                  Badges.firstGoalId: DateTime(2026, 3, 1),
                  's3': DateTime(2026, 3, 3),
                  's7': DateTime(2026, 3, 7),
                  's15': DateTime(2026, 3, 22),
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Rozetlerim'), findsOneWidget);
      expect(find.text('Şu anki seri'), findsOneWidget);
      expect(find.text('En uzun seri'), findsOneWidget);
      expect(find.text('Kaçırma hakkı'), findsOneWidget);
      expect(
        find.textContaining(
          'Her 7 hedef gününde 1 hak kazanırsın, en fazla 2. '
          'Bir günü kaçırırsan hak kendiliğinden kullanılır.',
        ),
        findsOneWidget,
      );
      // 1 dolu, 1 boş kalkan.
      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      // 10 rozet; 5'i kilitli (kilit simgesi).
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(5));
      // Kilitli rozetlerde kalan gün: mevcut seri 12 -> 30 için 18, 365 için 353 gün.
      expect(find.text('18 gün kaldı'), findsOneWidget);
      expect(find.text('353 gün kaldı'), findsOneWidget);
      expect(find.text('İlk hedef'), findsOneWidget);
    });

    testWidgets('ana ekran satırı 360 px: tüm hâller taşmadan tek satır', (
      tester,
    ) async {
      narrow(tester, h: 400);
      const base = StreakStatus.empty;
      final cases = <StreakStatus>[
        base,
        const StreakStatus(
          current: 12,
          best: 12,
          rights: 2,
          todayDone: false,
          goalDaysTotal: 14,
          protectedDays: {},
          yesterdayProtected: false,
        ),
        const StreakStatus(
          current: 123,
          best: 123,
          rights: 2,
          todayDone: true,
          goalDaysTotal: 130,
          protectedDays: {},
          yesterdayProtected: false,
        ),
        const StreakStatus(
          current: 7,
          best: 9,
          rights: 1,
          todayDone: false,
          goalDaysTotal: 9,
          protectedDays: {},
          yesterdayProtected: true,
        ),
      ];
      final texts = <String>[];
      for (final st in cases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  child: StreakLine(
                    status: st,
                    fg: Colors.black,
                    shadows: const [],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(StreakLine)).width,
          lessThanOrEqualTo(360),
        );
        texts.add(streakLineText(st));
      }
      expect(texts, [
        'Yeni bir seri başlıyor! Bugün ilk gün.',
        'Bugün hedefe ulaşırsan 13. gün olur · 2 hak',
        '123. gün devam ediyor · 2 hak',
        'Hakkın kullanıldı, seri devam ediyor · 1 hak',
      ]);
    });

    testWidgets('uygulama: ana ekranda seri satırı, Profil\'de Rozetlerim', (
      tester,
    ) async {
      narrow(tester, h: 800);
      final today = DateTime.now();
      final d0 = DateTime(today.year, today.month, today.day);
      final streakRepo = InMemoryStreakRepository(
        StreakData(
          start: DateTime(d0.year, d0.month, d0.day - 3),
          through: DateTime(d0.year, d0.month, d0.day - 1),
          goalDays: {
            for (var i = 1; i <= 3; i++)
              DateTime(d0.year, d0.month, d0.day - i),
          },
          throughGoalMl: 2000,
          lastGoalMl: 2000,
          best: 3,
          badges: {
            Badges.firstEntryId: DateTime(d0.year, d0.month, d0.day - 3),
            Badges.firstGoalId: DateTime(d0.year, d0.month, d0.day - 3),
            's3': DateTime(d0.year, d0.month, d0.day - 1),
          },
          celebrated: {Badges.firstEntryId, Badges.firstGoalId, 's3'},
        ),
      );
      await tester.pumpWidget(
        HydroSenApp(
          repository: InMemoryWaterRepository([
            for (var i = 1; i <= 3; i++)
              WaterEntry(
                id: i,
                amountMl: 2000,
                time: DateTime(d0.year, d0.month, d0.day - i, 10),
              ),
          ]),
          settingsRepository: InMemorySettingsRepository(),
          streakRepository: streakRepo,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Bugün hedefe ulaşırsan 4. gün olur'), findsOneWidget);
      expect(find.text('Günlük hedefin %0’i'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.byKey(const ValueKey('badges-section')),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rozetlerim'), findsOneWidget);
      expect(find.byKey(const ValueKey('badge-s3')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('yeni rozet kutlaması: ilk kayıtta metin görünür ve kapanır', (
      tester,
    ) async {
      narrow(tester, h: 800);
      await tester.pumpWidget(
        HydroSenApp(
          repository: InMemoryWaterRepository(),
          settingsRepository: InMemorySettingsRepository(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NewBadgeCelebration), findsNothing);
      await tester.tap(find.byKey(const ValueKey('quick-add-1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('Yeni rozet: İlk kayıt!'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(NewBadgeCelebration), findsNothing);
    });
  });
}
