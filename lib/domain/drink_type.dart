/// İçecek türü ve günlük hedefe sayılma oranı (tahmin).
///
/// Kayıtta ham ml saklanır; toplam, ilerleme ve kutlama [countedMl] ile
/// hesaplanır: `round(ml × oran)`.
enum DrinkType {
  water('su', 'Su', 'su', 100),
  mineral('maden', 'Maden suyu', 'maden suyu', 100),
  ayran('ayran', 'Ayran', 'ayran', 90),
  tea('cay', 'Çay', 'çay', 80),
  coffee('kahve', 'Kahve', 'kahve', 60);

  const DrinkType(this.id, this.label, this.lowerLabel, this.percent);

  /// Kalıcı kimlik (JSON); sürümler arası sabit kalır.
  final String id;

  /// Arayüzde görünen ad.
  final String label;

  /// Cümle içinde küçük harfle ad ("200 ml çay").
  final String lowerLabel;

  /// Hedefe sayılma oranı (yüzde).
  final int percent;

  /// Ham [ml] için hedefe sayılan miktar (tam sayıya yuvarlanır, tahmin).
  int countedMl(int ml) => (ml * percent + 50) ~/ 100;

  /// Bilinmeyen/eksik kimlik su sayılır (eski kayıtlar).
  static DrinkType fromId(Object? id) {
    for (final d in values) {
      if (d.id == id) return d;
    }
    return DrinkType.water;
  }
}
