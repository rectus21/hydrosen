/// Rozet katmanı: renk ve süs seviyesi. Karakterler evrimleşmez; rozetler
/// yalnızca seri ve ilk adımlar için verilen kalıcı ödüllerdir.
enum BadgeTier { milestone, bronze, silver, gold, diamond }

class BadgeDef {
  const BadgeDef._({
    required this.id,
    required this.title,
    required this.tier,
    required this.hint,
    this.days,
  });

  /// Kalıcı kimlik; `assets/badges/<id>.png` varsa çizim yerine o kullanılır.
  final String id;
  final String title;
  final BadgeTier tier;

  /// Kilitliyken gösterilen yönlendirme (seri rozetlerinde kalan gün ayrıca
  /// hesaplanır).
  final String hint;

  /// Seri rozetinin eşiği (gün); dönüm noktası rozetlerinde null.
  final int? days;

  bool get isStreak => days != null;

  /// Yeni rozet penceresinde okunan ad.
  String get popupName => title;
}

abstract final class Badges {
  static const firstEntryId = 'ilk_kayit';
  static const firstGoalId = 'ilk_hedef';

  /// Seri rozet eşikleri (gün).
  static const streakDays = [3, 7, 15, 30, 60, 100, 180, 365];

  static const firstEntry = BadgeDef._(
    id: firstEntryId,
    title: 'İlk kayıt',
    tier: BadgeTier.milestone,
    hint: 'İlk suyunu kaydet',
  );
  static const firstGoal = BadgeDef._(
    id: firstGoalId,
    title: 'İlk hedef',
    tier: BadgeTier.milestone,
    hint: 'Bir gün hedefe ulaş',
  );

  static BadgeTier _tierFor(int days) {
    if (days >= 365) return BadgeTier.diamond;
    if (days >= 60) return BadgeTier.gold;
    if (days >= 15) return BadgeTier.silver;
    return BadgeTier.bronze;
  }

  /// Gösterim sırası: dönüm noktaları, sonra artan seri eşikleri.
  static final List<BadgeDef> all = List.unmodifiable([
    firstEntry,
    firstGoal,
    for (final d in streakDays)
      BadgeDef._(
        id: 's$d',
        title: '$d gün',
        tier: _tierFor(d),
        hint: '$d gün üst üste hedef',
        days: d,
      ),
  ]);

  static BadgeDef? byId(String id) {
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Önem sırası (büyük = daha değerli); toplu rozet kazanımında yalnız
  /// en değerlisi kutlanır.
  static int rank(BadgeDef b) => all.indexOf(b);
}
