/// Bardak hesabı: ml ile bardak arasındaki saf dönüşümler (Flutter'a bağlı
/// değil, birim testlidir).
class GlassMath {
  const GlassMath({required this.goalMl, required this.glassMl})
    : assert(glassMl > 0);

  final int goalMl;
  final int glassMl;

  /// Hedefteki bardak sayısı: ceil(hedef / bardak). Hedef 2000, bardak 300
  /// ise 7 (son bardak hedefi biraz aşar).
  int get goalGlasses => goalMl <= 0 ? 0 : (goalMl + glassMl - 1) ~/ glassMl;

  /// [totalMl] kaç bardak ediyor (kesirli olabilir).
  double glassesOf(int totalMl) => totalMl / glassMl;

  /// Tamamen dolu bardak sayısı.
  int fullGlasses(int totalMl) => totalMl ~/ glassMl;

  /// [index]. bardağın (0'dan) doluluğu, 0..1.
  double fillOf(int index, int totalMl) =>
      (glassesOf(totalMl) - index).clamp(0.0, 1.0);

  /// Sırada gösterilecek dolu/kısmen dolu bardak sayısı: hedefin üstüne
  /// çıkılınca ek bardaklar da gösterilir.
  int shownGlasses(int totalMl) {
    final partial = (totalMl + glassMl - 1) ~/ glassMl;
    return partial > goalGlasses ? partial : goalGlasses;
  }

  /// Hedefin tüm bardakları doluysa sonda "+" bardağı görünür.
  bool showPlus(int totalMl) => fullGlasses(totalMl) >= goalGlasses;

  /// "5" ya da "6,7" (kesir varsa tek ondalık, virgülle).
  static String format(double glasses) {
    final rounded = (glasses * 10).floor() / 10;
    if (rounded == rounded.roundToDouble()) return rounded.round().toString();
    return rounded.toStringAsFixed(1).replaceAll('.', ',');
  }
}
