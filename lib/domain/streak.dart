import 'badges.dart';

/// Seri (art arda hedef günü) ve kaçırma hakkı mantığı. Flutter'a bağlı
/// değildir; birim testlidir.
///
/// Kurallar (Rectus kararı, 2026-11-24):
/// - Seri, günlük hedefin tutturulduğu ardışık günlerin sayısıdır. Tüm
///   temalar için tek ve küreseldir.
/// - Bugün hedefe ulaşılınca bugün sayılır. Bugün henüz bitmediyse seri
///   dünkü değerini gösterir ve bozulmaz.
/// - Her 7 hedef gününde (kümülatif) 1 kaçırma hakkı kazanılır; en çok 2
///   hak tutulur.
/// - Hedefsiz biten bir günde hak varsa otomatik harcanır: gün "korundu"
///   olur, seriyi ne artırır ne bozar. Hak yoksa seri 0'a düşer. Uygulama
///   günlerce açılmasa bile açılışta kaçırılan her gün sırayla işlenir.
/// - Biten günün sonucu kaydedilir ve donar. Tek istisna dünkü gündür:
///   unutulan bir kaydı geriye dönük girince yalnız dün yeniden
///   değerlendirilir; daha eski günler seri için değişmez.
/// - Hedef gün içinde değişirse bugün güncel hedefle ölçülür; biten günler
///   o gün geçerli olan hedefle kaydedilir.
///
/// NOT: Uygulama tamamen ücretsizdir (sahip kararı, 2026-11-25); seri için
/// satın alma ya da ek hak yoktur.
DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);
DateTime nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);
DateTime prevDay(DateTime d) => DateTime(d.year, d.month, d.day - 1);

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime? parseDayKey(Object? v) {
  if (v is! String) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(v);
  if (m == null) return null;
  return DateTime(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
}

/// Kalıcı seri verisi. Biten günlerin sonucu: [start]..[through] arasında
/// [goalDays] içindeki günler hedef günü, dışındakiler kaçırılmış gündür
/// (hak, korunma, seri bu kayıttan yeniden hesaplanır).
class StreakData {
  const StreakData({
    required this.start,
    required this.through,
    this.goalDays = const {},
    this.throughGoalMl = 0,
    this.lastGoalMl = 0,
    this.best = 0,
    this.badges = const {},
    this.celebrated = const {},
  });

  /// İzlemenin başladığı ilk gün.
  final DateTime start;

  /// Sonucu kaydedilmiş (biten) son gün.
  final DateTime through;

  /// Hedefin tutturulduğu biten günler.
  final Set<DateTime> goalDays;

  /// [through] gününde geçerli olan hedef (dünü yeniden değerlendirmek için).
  final int throughGoalMl;

  /// Son bilinen günlük hedef (uygulama kapalıyken hedef değişemez).
  final int lastGoalMl;

  /// En uzun seri; yalnız artar.
  final int best;

  /// Kazanılan rozetler ve tarihleri (kalıcı).
  final Map<String, DateTime> badges;

  /// Kutlama penceresi gösterilmiş rozetler.
  final Set<String> celebrated;

  StreakData copyWith({
    DateTime? through,
    Set<DateTime>? goalDays,
    int? throughGoalMl,
    int? lastGoalMl,
    int? best,
    Map<String, DateTime>? badges,
    Set<String>? celebrated,
  }) => StreakData(
    start: start,
    through: through ?? this.through,
    goalDays: goalDays ?? this.goalDays,
    throughGoalMl: throughGoalMl ?? this.throughGoalMl,
    lastGoalMl: lastGoalMl ?? this.lastGoalMl,
    best: best ?? this.best,
    badges: badges ?? this.badges,
    celebrated: celebrated ?? this.celebrated,
  );

  Map<String, Object> toJson() {
    final days = goalDays.map(dayKey).toList()..sort();
    final b = {for (final e in badges.entries) e.key: dayKey(e.value)};
    return {
      'v': 1,
      'start': dayKey(start),
      'through': dayKey(through),
      'goalDays': days,
      'throughGoalMl': throughGoalMl,
      'lastGoalMl': lastGoalMl,
      'best': best,
      'badges': b,
      'celebrated': celebrated.toList()..sort(),
    };
  }

  /// Bozuk/eksik veride null döner (seri kayıtlardan yeniden kurulur).
  static StreakData? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final start = parseDayKey(raw['start']);
    final through = parseDayKey(raw['through']);
    if (start == null || through == null) return null;
    final days = <DateTime>{};
    final rawDays = raw['goalDays'];
    if (rawDays is List) {
      for (final d in rawDays) {
        final p = parseDayKey(d);
        if (p != null) days.add(p);
      }
    }
    final badges = <String, DateTime>{};
    final rawBadges = raw['badges'];
    if (rawBadges is Map) {
      rawBadges.forEach((k, v) {
        final p = parseDayKey(v);
        if (k is String && p != null && Badges.byId(k) != null) badges[k] = p;
      });
    }
    final celebrated = <String>{};
    final rawCel = raw['celebrated'];
    if (rawCel is List) {
      for (final c in rawCel) {
        if (c is String && badges.containsKey(c)) celebrated.add(c);
      }
    }
    int intOf(Object? v) => v is int && v >= 0 ? v : 0;
    return StreakData(
      start: start,
      through: through,
      goalDays: days,
      throughGoalMl: intOf(raw['throughGoalMl']),
      lastGoalMl: intOf(raw['lastGoalMl']),
      best: intOf(raw['best']),
      badges: badges,
      celebrated: celebrated,
    );
  }
}

/// Arayüzün okuduğu anlık seri durumu.
class StreakStatus {
  const StreakStatus({
    required this.current,
    required this.best,
    required this.rights,
    required this.todayDone,
    required this.goalDaysTotal,
    required this.protectedDays,
    required this.yesterdayProtected,
  });

  static const empty = StreakStatus(
    current: 0,
    best: 0,
    rights: 0,
    todayDone: false,
    goalDaysTotal: 0,
    protectedDays: {},
    yesterdayProtected: false,
  );

  /// Seri: bugün bittiyse bugün dahil, bitmediyse dünkü değer.
  final int current;
  final int best;

  /// Tutulan kaçırma hakkı (0..[StreakEngine.maxRights]).
  final int rights;
  final bool todayDone;

  /// Toplam hedef günü (haklar bunun her 7'sinde kazanılır).
  final int goalDaysTotal;

  /// Hak harcanarak "korundu" sayılan günler.
  final Set<DateTime> protectedDays;
  final bool yesterdayProtected;

  /// Sonraki hakka kalan hedef günü; haklar doluysa null.
  int? get goalDaysToNextRight => rights >= StreakEngine.maxRights
      ? null
      : StreakEngine.goalDaysPerRight -
            goalDaysTotal % StreakEngine.goalDaysPerRight;
}

class StreakResult {
  const StreakResult(this.data, this.status);
  final StreakData data;
  final StreakStatus status;
}

abstract final class StreakEngine {
  static const maxRights = 2;
  static const goalDaysPerRight = 7;

  /// Seriyi bugüne getirir: biten günleri işler (günlerce ara dahil), dünü
  /// yeniden değerlendirir, rozetleri verir.
  ///
  /// [dailyCountedMl]: gün -> hedefe sayılan ml (içecek oranlarıyla); kaydı
  /// olan her gün anahtardır. [data] null ise (eski kurulum ya da ilk açılış)
  /// seri mevcut kayıt geçmişinden bir kez kurulur; geçmiş günler için o günkü
  /// hedef bilinmediğinden güncel [goalMl] kullanılır.
  static StreakResult advance({
    required StreakData? data,
    required DateTime now,
    required Map<DateTime, int> dailyCountedMl,
    required int goalMl,
  }) {
    final today = dayOf(now);
    final yesterday = prevDay(today);
    final init = data == null;
    var d = data ?? _fresh(today, dailyCountedMl, goalMl);

    // Biten günleri işle. Uygulama kapalıyken hedef değişemez: son bilinen
    // hedef o günlerin hedefidir.
    final dayGoal = d.lastGoalMl > 0 ? d.lastGoalMl : goalMl;
    final goalSet = {...d.goalDays};
    var through = d.through;
    var throughGoal = d.throughGoalMl;
    if (through.isBefore(yesterday)) {
      for (
        var day = nextDay(through);
        !day.isAfter(yesterday);
        day = nextDay(day)
      ) {
        if (dayGoal > 0 && (dailyCountedMl[day] ?? 0) >= dayGoal) {
          goalSet.add(day);
        } else {
          goalSet.remove(day);
        }
        through = day;
        throughGoal = dayGoal;
      }
    } else if (through == yesterday && !yesterday.isBefore(d.start)) {
      // Geç kayıt: yalnız dün yeniden değerlendirilir.
      final g = throughGoal > 0 ? throughGoal : dayGoal;
      if (g > 0 && (dailyCountedMl[yesterday] ?? 0) >= g) {
        goalSet.add(yesterday);
      } else {
        goalSet.remove(yesterday);
      }
    }

    final todayMet = goalMl > 0 && (dailyCountedMl[today] ?? 0) >= goalMl;
    final r = _replay(d.start, through, goalSet, todayMet ? today : null);
    final best = r.best > d.best ? r.best : d.best;

    // Rozetler: bir kez kazanılınca kalıcıdır (en uzun seri sayılır).
    final badges = {...d.badges};
    if (dailyCountedMl.isNotEmpty && !badges.containsKey(Badges.firstEntryId)) {
      var first = today;
      for (final k in dailyCountedMl.keys) {
        if (k.isBefore(first)) first = k;
      }
      badges[Badges.firstEntryId] = first;
    }
    if (r.firstGoalDay != null && !badges.containsKey(Badges.firstGoalId)) {
      badges[Badges.firstGoalId] = r.firstGoalDay!;
    }
    for (final t in Badges.streakDays) {
      final id = 's$t';
      if (best >= t && !badges.containsKey(id)) {
        badges[id] = r.reachedOn[t] ?? today;
      }
    }

    var celebrated = d.celebrated;
    if (init && badges.isNotEmpty) {
      // Geçmişten kurulumda rozet yağmuru olmasın: yalnız en değerlisi kutlanır.
      BadgeDef? top;
      for (final id in badges.keys) {
        final b = Badges.byId(id);
        if (b != null && (top == null || Badges.rank(b) > Badges.rank(top))) {
          top = b;
        }
      }
      celebrated = {
        for (final id in badges.keys)
          if (id != top?.id) id,
      };
    }

    d = d.copyWith(
      through: through,
      goalDays: goalSet,
      throughGoalMl: throughGoal,
      lastGoalMl: goalMl,
      best: best,
      badges: badges,
      celebrated: celebrated,
    );
    return StreakResult(
      d,
      StreakStatus(
        current: r.streak,
        best: best,
        rights: r.rights,
        todayDone: todayMet,
        goalDaysTotal: r.goalDays,
        protectedDays: r.protectedDays,
        yesterdayProtected: r.protectedDays.contains(yesterday),
      ),
    );
  }

  static StreakData _fresh(
    DateTime today,
    Map<DateTime, int> dailyCountedMl,
    int goalMl,
  ) {
    var start = today;
    for (final k in dailyCountedMl.keys) {
      if (k.isBefore(start)) start = k;
    }
    return StreakData(
      start: start,
      through: prevDay(start),
      throughGoalMl: goalMl,
      lastGoalMl: goalMl,
    );
  }

  static _Replay _replay(
    DateTime start,
    DateTime through,
    Set<DateTime> goalSet,
    DateTime? provisionalToday,
  ) {
    final r = _Replay();
    for (var day = start; !day.isAfter(through); day = nextDay(day)) {
      if (goalSet.contains(day)) {
        r.goal(day);
      } else {
        r.miss(day);
      }
    }
    if (provisionalToday != null) r.goal(provisionalToday);
    return r;
  }
}

class _Replay {
  int streak = 0;
  int rights = 0;
  int goalDays = 0;
  int best = 0;
  DateTime? firstGoalDay;
  final protectedDays = <DateTime>{};
  final reachedOn = <int, DateTime>{};

  void goal(DateTime day) {
    firstGoalDay ??= day;
    streak++;
    goalDays++;
    if (goalDays % StreakEngine.goalDaysPerRight == 0 &&
        rights < StreakEngine.maxRights) {
      rights++;
    }
    if (streak > best) best = streak;
    for (final t in Badges.streakDays) {
      if (streak >= t) reachedOn.putIfAbsent(t, () => day);
    }
  }

  void miss(DateTime day) {
    if (rights > 0) {
      rights--;
      protectedDays.add(day);
    } else {
      streak = 0;
    }
  }
}
