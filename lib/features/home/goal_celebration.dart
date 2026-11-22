/// Günlük hedefin "aşağıdan yukarı" geçildiği anı yakalar; kutlama yalnızca
/// o anda bir kez oynar. Saf mantıktır (Flutter'a bağlı değil), birim testlidir.
///
/// Kurallar:
/// - İlk gözlem (uygulama açılışı, kayıtlar yüklenince) yalnızca başlangıç
///   durumunu kaydeder; hedef zaten aşılmışsa kutlama oynamaz.
/// - Kutlama, aynı gün içinde toplam hedefin altındayken su eklenip
///   hedefe ulaşıldığında (toplam >= hedef) oynar.
/// - Hedefin üstünde kaldıkça tekrar oynamaz; toplam (ör. silmeyle) hedefin
///   altına inip yeniden geçerse tekrar oynar.
/// - Yalnızca su eklemek tetikler: ayarlardan hedefi düşürmek kutlatmaz.
/// - Yeni gün sıfırdan başlar (dünkü "ulaşıldı" durumu taşınmaz).
class GoalCelebrationTracker {
  DateTime? _day;
  int _totalMl = 0;
  bool _reached = false;

  /// Güncel durumu bildirir; hedef az önce geçildiyse true döner.
  bool observe({
    required DateTime now,
    required int totalMl,
    required int goalMl,
  }) {
    final day = DateTime(now.year, now.month, now.day);
    final reached = goalMl > 0 && totalMl >= goalMl;
    final first = _day == null;
    final sameDay = _day == day;
    final wasReached = sameDay && _reached;
    final previousTotal = sameDay ? _totalMl : 0;

    _day = day;
    _totalMl = totalMl;
    _reached = reached;

    return !first && reached && !wasReached && totalMl > previousTotal;
  }
}
