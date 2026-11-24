/// Ana ekran widget'ının göstereceği anlık görüntü: bugünün sayılan ml'si,
/// hedef, yüzde, seri günü, tema ve karakter adı. Saf veri (Flutter'a bağlı
/// değil); gelecekte `home_widget` ile yerel tarafa JSON olarak yazılır.
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.todayMl,
    required this.goalMl,
    required this.streakDay,
    required this.themeId,
    required this.characterName,
  });

  /// Bugün hedefe SAYILAN ml (içecek oranlarıyla).
  final int todayMl;
  final int goalMl;

  /// Seri günü (0: seri yok).
  final int streakDay;
  final String themeId;

  /// Karakterin/matara'nın adı (özel ad ya da tema adı).
  final String characterName;

  /// Gerçek yüzde (hedef aşılırsa 100'ü geçer; halka 100'de durur).
  int get percent => goalMl <= 0 ? 0 : (todayMl * 100 / goalMl).round();

  /// Halka için 0..1.
  double get ringFraction =>
      goalMl <= 0 ? 0 : (todayMl / goalMl).clamp(0.0, 1.0);

  /// "1200 / 2000 ml".
  String get amountText => '$todayMl / $goalMl ml';

  /// "12. gün" ya da seri yoksa "Yeni seri".
  String get streakText => streakDay > 0 ? '$streakDay. gün' : 'Yeni seri';

  Map<String, Object> toJson() => {
    'todayMl': todayMl,
    'goalMl': goalMl,
    'percent': percent,
    'streakDay': streakDay,
    'themeId': themeId,
    'characterName': characterName,
  };

  @override
  bool operator ==(Object other) =>
      other is WidgetSnapshot &&
      other.todayMl == todayMl &&
      other.goalMl == goalMl &&
      other.streakDay == streakDay &&
      other.themeId == themeId &&
      other.characterName == characterName;

  @override
  int get hashCode =>
      Object.hash(todayMl, goalMl, streakDay, themeId, characterName);

  @override
  String toString() => 'WidgetSnapshot(${toJson()})';
}
