import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/domain/bottle_name.dart';
import 'package:hydrosen/domain/reminder_messages.dart';
import 'package:hydrosen/domain/reminder_planner.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';

DateTime t(int h, [int m = 0, int day = 16]) => DateTime(2026, 11, day, h, m);

void main() {
  const planner = ReminderPlanner(); // 08:00-22:00, 60 dk, üst sınır 8

  group('uyanık saatler', () {
    test('varsayılan 08:00-22:00; ilk hatırlatma başlangıç + aralık', () {
      final p = planner.plan(now: t(7));
      expect(p.at, t(9));
      expect(p.kind, ReminderKind.normal);
      expect(p.reason, ReminderQuiet.none);
    });

    test('bitişten sonra bugün sessiz, sıradaki yarının ilkidir', () {
      final p = planner.plan(now: t(22, 30));
      expect(p.at, t(9, 0, 17));
      expect(p.reason, ReminderQuiet.endOfDay);
    });

    test('son aralık bitişe sığmıyorsa gün biter', () {
      final p = planner.plan(now: t(21, 10), lastDrink: t(21));
      expect(p.at, t(9, 0, 17));
      expect(p.reason, ReminderQuiet.endOfDay);
    });

    test('bitiş başlangıçtan önce/eşit ya da çok kısa pencere geçersiz', () {
      expect(ReminderPlanner.validateWindow(22 * 60, 8 * 60), isNotNull);
      expect(ReminderPlanner.validateWindow(600, 600), isNotNull);
      expect(ReminderPlanner.validateWindow(600, 620), isNotNull);
      expect(ReminderPlanner.validateWindow(-1, 600), isNotNull);
      expect(ReminderPlanner.validateWindow(600, 1440), isNotNull);
      expect(ReminderPlanner.validateWindow(480, 1320), isNull);
      const bad = ReminderPlanner(startMinute: 1320, endMinute: 480);
      final p = bad.plan(now: t(12));
      expect(p.at, isNull);
      expect(p.reason, ReminderQuiet.invalidWindow);
    });

    test('pencere aralıktan kısaysa hiç hatırlatma yok', () {
      const p = ReminderPlanner(
        startMinute: 600,
        endMinute: 640,
        intervalMinutes: 60,
      );
      expect(p.plan(now: t(9)).at, isNull);
    });
  });

  group('son içmeden itibaren aralık', () {
    test('kayıt yoksa uyanık saatlerin başından sayar', () {
      expect(planner.plan(now: t(10)).at, t(9));
    });

    test('su kaydı sonraki hatırlatmayı öteler', () {
      final p = planner.plan(now: t(10, 5), lastDrink: t(10));
      expect(p.at, t(11));
      expect(p.isDue(t(10, 5)), isFalse);
      expect(p.isDue(t(11)), isTrue);
    });

    test('uyanık saatlerden önceki kayıt başlangıcı etkilemez', () {
      expect(planner.plan(now: t(7), lastDrink: t(6, 30)).at, t(9));
    });

    test('dünkü kayıt yok sayılır', () {
      final p = planner.plan(now: t(8, 30), lastDrink: t(21, 0, 15));
      expect(p.at, t(9));
    });

    test('farklı aralık seçimi', () {
      const p = ReminderPlanner(intervalMinutes: 120);
      expect(p.plan(now: t(12), lastDrink: t(11)).at, t(13));
    });
  });

  group('hedef ve günlük üst sınır', () {
    test('hedef tamamsa o gün hatırlatma yok', () {
      final p = planner.plan(now: t(12), goalReached: true);
      expect(p.reason, ReminderQuiet.goalReached);
      expect(p.at, t(9, 0, 17));
    });

    test('"hedefe ulaşınca sus" kapalıysa hedef tamam olsa da sürer', () {
      const p = ReminderPlanner(stopAtGoal: false);
      expect(p.plan(now: t(12), goalReached: true).reason, ReminderQuiet.none);
    });

    test('günlük üst sınıra ulaşınca susar', () {
      final state = ReminderDayState(day: t(0), sent: 8);
      final p = planner.plan(now: t(15), state: state);
      expect(p.reason, ReminderQuiet.capReached);
      expect(p.at, t(9, 0, 17));
    });

    test('üst sınır 3-12 aralığına çekilir', () {
      expect(ReminderPlanner.clampCap(1), 3);
      expect(ReminderPlanner.clampCap(20), 12);
      const low = ReminderPlanner(dailyCap: 1);
      final s3 = ReminderDayState(day: t(0), sent: 3);
      expect(low.plan(now: t(15), state: s3).reason, ReminderQuiet.capReached);
      final s2 = ReminderDayState(day: t(0), sent: 2);
      expect(low.plan(now: t(15), state: s2).reason, ReminderQuiet.none);
    });
  });

  group('yumuşak tekrar', () {
    final afterNormal = ReminderDayState(
      day: t(0),
      sent: 1,
      lastNormalAt: t(10),
    );

    test('yok sayılırsa 30 dk sonra tek yumuşak hatırlatma gelir', () {
      final p = planner.plan(now: t(10, 5), state: afterNormal);
      expect(p.at, t(10, 30));
      expect(p.kind, ReminderKind.retry);
    });

    test('tekrar kullanıldıktan sonra normal aralık beklenir', () {
      final used = afterNormal.afterSent(ReminderKind.retry, t(10, 30));
      expect(used.sent, 2);
      final p = planner.plan(now: t(10, 31), state: used);
      expect(p.at, t(11));
      expect(p.kind, ReminderKind.normal);
    });

    test('arada su içildiyse tekrar gelmez', () {
      final p = planner.plan(
        now: t(10, 20),
        lastDrink: t(10, 15),
        state: afterNormal,
      );
      expect(p.kind, ReminderKind.normal);
      expect(p.at, t(11, 15));
    });

    test('normal zaman gelmişse eski tekrar atlanır', () {
      final p = planner.plan(now: t(11), state: afterNormal);
      expect(p.kind, ReminderKind.normal);
      expect(p.at, t(11));
    });

    test('yeni normal hatırlatma tekrar hakkını yeniler', () {
      final used = afterNormal.afterSent(ReminderKind.retry, t(10, 30));
      final next = used.afterSent(ReminderKind.normal, t(11));
      expect(next.retryUsed, isFalse);
      expect(planner.plan(now: t(11, 1), state: next).kind, ReminderKind.retry);
    });
  });

  group('gece yarısı', () {
    test('dünün sayaçları sıfırlanır', () {
      final yesterday = ReminderDayState(
        day: t(0, 0, 15),
        sent: 8,
        lastNormalAt: t(21, 0, 15),
        retryUsed: true,
      );
      final p = planner.plan(now: t(8, 5), state: yesterday);
      expect(p.reason, ReminderQuiet.none);
      expect(p.at, t(9));
      expect(yesterday.forDay(t(8)).sent, 0);
    });

    test('durum JSON gidiş-dönüş yapar, bozuk veri null verir', () {
      final s = ReminderDayState(
        day: t(0),
        sent: 3,
        lastNormalAt: t(10, 15),
        retryUsed: true,
      );
      final back = ReminderDayState.tryFromJson(s.toJson())!;
      expect(back.sent, 3);
      expect(back.lastNormalAt, t(10, 15));
      expect(back.retryUsed, isTrue);
      expect(ReminderDayState.tryFromJson('x'), isNull);
      expect(ReminderDayState.tryFromJson({'day': 5}), isNull);
    });
  });

  group('matara adı', () {
    test('kırpılır ve boşluklar teke iner', () {
      final r = BottleName.validate('  Pamuk   Şeker ');
      expect(r.isOk, isTrue);
      expect(r.name, 'Pamuk Şeker');
    });

    test('boş ad geçerli: varsayılana dön', () {
      expect(BottleName.validate('   ').name, '');
    });

    test('en fazla 16 karakter', () {
      expect(BottleName.validate('a' * 16).isOk, isTrue);
      final r = BottleName.validate('a' * 17);
      expect(r.error, BottleNameError.tooLong);
      expect(r.message, contains('16'));
      // Kırpmadan sonra 16 ise kabul.
      expect(BottleName.validate('  ${'b' * 16}  ').isOk, isTrue);
    });

    test('Türkçe harfli masum adlar geçer', () {
      for (final n in [
        'Pamuk',
        'Şeker',
        'Çiko',
        'Ğ Bulut',
        'Sıcak',
        'Kayarak',
        'Sıkı',
        'Amasya',
        'Karamel',
        'Fındık',
        'Mırmır 2',
        'Ay-Çiçeği',
      ]) {
        expect(BottleName.validate(n).isOk, isTrue, reason: n);
      }
    });

    test('uygunsuz kelimeler yazım numaralarına rağmen reddedilir', () {
      for (final n in [
        'siktir',
        'SİKTİR',
        'S1kt1r',
        's.i.k.t.i.r',
        's i k',
        'siiiik',
        'amk',
        'Oç',
        'Piç',
        'orospu',
        'OROSPU çocuğu',
        'pezevenk',
        'f u c k',
        'fvck'.replaceAll('v', 'u'),
        'b1tch',
        'yarrak',
        'ib\$ne'.replaceAll('\$', 'n'),
        'salak',
      ]) {
        final r = BottleName.validate(n);
        expect(r.error, BottleNameError.inappropriate, reason: n);
        expect(r.message, contains('Başka'));
      }
    });

    test('tuhaf karakterler reddedilir', () {
      expect(BottleName.validate('<b>x').error, BottleNameError.invalidChars);
    });
  });

  group('temalı mesajlar', () {
    test('her temanın kendi satırları var ve ad geçiyor', () {
      for (final theme in ThermosTheme.all) {
        final lines = ReminderMessages.byTheme[theme.id];
        expect(lines, isNotNull, reason: 'satır yok: ${theme.id}');
        expect(lines!.length, inInclusiveRange(2, 3), reason: theme.id);
        for (final l in lines) {
          expect(l, contains('{ad}'), reason: '${theme.id}: $l');
          expect(l.length, lessThan(70), reason: '${theme.id}: $l');
        }
      }
    });

    test('tema ve ad kullanılır, sırayla döner', () {
      final a = ReminderMessages.pick(
        themeId: 'kopek',
        name: 'Pamuk',
        index: 0,
      );
      expect(a, contains('Pamuk'));
      expect(a, isNot(contains('{ad}')));
      final b = ReminderMessages.pick(themeId: 'kopek', name: 'Pamuk', index: 1);
      expect(b, isNot(a));
      final c = ReminderMessages.pick(themeId: 'kopek', name: 'Pamuk', index: 2);
      expect(c, a);
    });

    test('bilinmeyen tema için genel satır', () {
      final m = ReminderMessages.pick(themeId: 'yok', name: 'Dolu');
      expect(m, contains('Dolu'));
      expect(ReminderMessages.fallback.map((l) => l.replaceAll('{ad}', 'Dolu')),
          contains(m));
    });

    test('yumuşak tekrar ayrı, baskısız metin', () {
      final m = ReminderMessages.pick(
        themeId: 'kedi',
        name: 'Pamuk',
        kind: ReminderKind.retry,
      );
      expect(m, contains('Pamuk'));
      expect(ReminderMessages.retry.map((l) => l.replaceAll('{ad}', 'Pamuk')),
          contains(m));
    });

    test('suçlama ya da baskı sözcüğü yok', () {
      const banned = [
        'unuttun',
        'hâlâ içmedin',
        'neden içmedin',
        'kötü',
        'üzgün',
        'mecbur',
        'hemen iç',
        'yine',
        'ceza',
        'kaybet',
      ];
      final all = [
        ...ReminderMessages.fallback,
        ...ReminderMessages.retry,
        for (final l in ReminderMessages.byTheme.values) ...l,
      ];
      for (final l in all) {
        for (final w in banned) {
          expect(l.toLowerCase(), isNot(contains(w)), reason: l);
        }
      }
    });

    test('kutlama yazısı yalnız özel ad varsa adı kullanır', () {
      expect(ReminderMessages.celebration(null), 'Tebrikler! Günlük hedefe ulaştın.');
      expect(ReminderMessages.celebration('Pamuk'), 'Tebrikler! Pamuk hedefe ulaştı!');
    });
  });
}
