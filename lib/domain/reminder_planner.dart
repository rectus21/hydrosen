/// Akıllı hatırlatma zamanlayıcısı: saf Dart, Flutter'a ve saate bağlı değil.
///
/// Sonraki hatırlatma şu kurallarla hesaplanır:
/// - Yalnız uyanık saatlerde (varsayılan 08:00-22:00) hatırlatır.
/// - Aralık, **son içmeden** sayılır (bugünün son kaydı; yoksa uyanık
///   saatlerin başı). Su kaydetmek sonraki hatırlatmayı öteler.
/// - Hedef tamamsa ve "hedefe ulaşınca sus" açıksa gün boyu susar.
/// - Günlük üst sınıra ulaşınca gün boyu susar.
/// - Hatırlatma yok sayılırsa (bir şey içilmezse) [retryAfterMinutes] sonra
///   tek bir yumuşak hatırlatma gelir; sonra normal aralık beklenir.
/// - Gece yarısı sayaçlar sıfırlanır (durum bugünün tarihine bağlıdır).
library;

enum ReminderKind {
  /// Aralığı dolunca gelen normal hatırlatma.
  normal,

  /// Yok sayılan hatırlatmadan sonra gelen tek, daha yumuşak hatırlatma.
  retry,
}

/// Bugün neden (daha fazla) hatırlatma gelmediğini söyler.
enum ReminderQuiet {
  /// Hatırlatma bugün de sürüyor.
  none,

  /// Hedefe ulaşıldı ve "hedefe ulaşınca sus" açık.
  goalReached,

  /// Günlük üst sınıra ulaşıldı.
  capReached,

  /// Bugünün uyanık saatleri bitti.
  endOfDay,

  /// Uyanık saatler geçersiz ya da aralığa göre çok kısa; hiç hatırlatma yok.
  invalidWindow,
}

/// Bir günün hatırlatma sayaçları. [day] bugünden farklıysa sıfır sayılır.
class ReminderDayState {
  const ReminderDayState({
    required this.day,
    this.sent = 0,
    this.lastNormalAt,
    this.retryUsed = false,
  });

  /// Yalnız tarih kısmı önemlidir.
  final DateTime day;

  /// Bugün gönderilen hatırlatma sayısı (yumuşak olanlar dâhil).
  final int sent;

  /// Bugünün son normal hatırlatmasının zamanı.
  final DateTime? lastNormalAt;

  /// Son normal hatırlatmanın yumuşak tekrarı kullanıldı mı.
  final bool retryUsed;

  /// [now]'un gününe ait değilse boş (sıfırlanmış) durum döner.
  ReminderDayState forDay(DateTime now) => _sameDay(day, now)
      ? this
      : ReminderDayState(day: DateTime(now.year, now.month, now.day));

  /// Bir hatırlatma gönderildikten sonraki durum.
  ReminderDayState afterSent(ReminderKind kind, DateTime at) {
    final base = forDay(at);
    final normal = kind == ReminderKind.normal;
    return ReminderDayState(
      day: base.day,
      sent: base.sent + 1,
      lastNormalAt: normal ? at : base.lastNormalAt,
      retryUsed: !normal,
    );
  }

  Map<String, Object> toJson() => {
    'day': DateTime(day.year, day.month, day.day).toIso8601String(),
    'sent': sent,
    if (lastNormalAt != null) 'normal': lastNormalAt!.toIso8601String(),
    'retry': retryUsed,
  };

  /// Bozuk veride null döner.
  static ReminderDayState? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    try {
      final day = DateTime.parse(raw['day'] as String);
      final sent = raw['sent'] as int;
      final normal = raw['normal'];
      return ReminderDayState(
        day: day,
        sent: sent < 0 ? 0 : sent,
        lastNormalAt: normal is String ? DateTime.parse(normal) : null,
        retryUsed: raw['retry'] == true,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Planlayıcının sonucu.
class ReminderPlan {
  const ReminderPlan({this.at, this.kind = ReminderKind.normal, this.quiet});

  /// Sonraki hatırlatmanın zamanı; hiç yoksa null. Şimdiden önceyse zamanı
  /// gelmiştir (hemen gösterilmeli).
  final DateTime? at;
  final ReminderKind kind;

  /// Bugünün hatırlatması bittiyse nedeni (o zaman [at] yarının ilk
  /// hatırlatmasıdır); sürüyorsa null.
  final ReminderQuiet? quiet;

  ReminderQuiet get reason => quiet ?? ReminderQuiet.none;

  bool isDue(DateTime now) => at != null && !at!.isAfter(now);
}

class ReminderPlanner {
  const ReminderPlanner({
    this.startMinute = defaultStartMinute,
    this.endMinute = defaultEndMinute,
    this.intervalMinutes = 60,
    this.dailyCap = defaultDailyCap,
    this.stopAtGoal = true,
    this.retryAfterMinutes = defaultRetryMinutes,
  });

  static const defaultStartMinute = 8 * 60;
  static const defaultEndMinute = 22 * 60;
  static const defaultDailyCap = 8;
  static const minDailyCap = 3;
  static const maxDailyCap = 12;
  static const defaultRetryMinutes = 30;

  /// Uyanık saatlerin en az uzunluğu (dakika).
  static const minWindowMinutes = 30;

  /// Seçilebilir aralıklar (dakika).
  static const intervals = [30, 60, 90, 120, 180];

  final int startMinute;
  final int endMinute;
  final int intervalMinutes;
  final int dailyCap;
  final bool stopAtGoal;
  final int retryAfterMinutes;

  /// Uyanık saatler geçerli mi: 00:00-23:59 içinde, bitiş başlangıçtan sonra
  /// ve aralık en az [minWindowMinutes]. Geçerliyse null, değilse Türkçe
  /// kullanıcı mesajı.
  static String? validateWindow(int start, int end) {
    if (start < 0 || start > 1439 || end < 0 || end > 1439) {
      return 'Saat 00:00 ile 23:59 arasında olmalı.';
    }
    if (end <= start) return 'Bitiş saati başlangıçtan sonra olmalı.';
    if (end - start < minWindowMinutes) {
      return 'Uyanık saatler en az 30 dakika olmalı.';
    }
    return null;
  }

  static int clampCap(int value) => value.clamp(minDailyCap, maxDailyCap);

  /// [now] anına göre sonraki hatırlatmayı hesaplar.
  ///
  /// [lastDrink]: bugünün son kaydının zamanı (başka günün kaydı yok sayılır).
  /// [goalReached]: bugünkü hedef tamam mı. [state]: bugünün sayaçları
  /// (başka güne aitse sıfırlanır).
  ReminderPlan plan({
    required DateTime now,
    DateTime? lastDrink,
    bool goalReached = false,
    ReminderDayState? state,
  }) {
    if (validateWindow(startMinute, endMinute) != null ||
        intervalMinutes <= 0 ||
        endMinute - startMinute <= intervalMinutes) {
      return const ReminderPlan(quiet: ReminderQuiet.invalidWindow);
    }
    final today = DateTime(now.year, now.month, now.day);
    final start = _at(today, startMinute);
    final end = _at(today, endMinute);
    final tomorrow = _at(
      DateTime(now.year, now.month, now.day + 1),
      startMinute,
    ).add(Duration(minutes: intervalMinutes));

    ReminderPlan quietUntilTomorrow(ReminderQuiet why) =>
        ReminderPlan(at: tomorrow, quiet: why);

    if (!now.isBefore(end)) return quietUntilTomorrow(ReminderQuiet.endOfDay);
    if (stopAtGoal && goalReached) {
      return quietUntilTomorrow(ReminderQuiet.goalReached);
    }
    final day = (state ?? ReminderDayState(day: today)).forDay(now);
    if (day.sent >= clampCap(dailyCap)) {
      return quietUntilTomorrow(ReminderQuiet.capReached);
    }

    final drink = lastDrink != null && _sameDay(lastDrink, now)
        ? lastDrink
        : null;
    var anchor = start;
    if (drink != null && drink.isAfter(anchor)) anchor = drink;
    final lastNormal = day.lastNormalAt;
    if (lastNormal != null && lastNormal.isAfter(anchor)) anchor = lastNormal;
    final normal = anchor.add(Duration(minutes: intervalMinutes));

    // Yumuşak tekrar: son normal hatırlatmadan beri hiçbir şey içilmediyse,
    // normal aralık dolmadan, yalnızca bir kez.
    if (lastNormal != null && !day.retryUsed && retryAfterMinutes > 0) {
      final drankSince = drink != null && drink.isAfter(lastNormal);
      final retryAt = lastNormal.add(Duration(minutes: retryAfterMinutes));
      if (!drankSince &&
          retryAt.isBefore(normal) &&
          now.isBefore(normal) &&
          retryAt.isBefore(end)) {
        return ReminderPlan(at: retryAt, kind: ReminderKind.retry);
      }
    }
    if (!normal.isBefore(end)) {
      return quietUntilTomorrow(ReminderQuiet.endOfDay);
    }
    return ReminderPlan(at: normal);
  }

  static DateTime _at(DateTime day, int minute) =>
      DateTime(day.year, day.month, day.day, minute ~/ 60, minute % 60);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
