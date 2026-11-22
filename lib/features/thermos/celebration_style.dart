/// Hedef kutlamasında oynayacak genel parçacık efekti türleri.
/// Yeni temalar özel çizim yazmadan bunlardan birini seçer.
enum CelebrationKind {
  /// Termosun çevresinde genişleyen damla halkası.
  droplets,

  /// Aşağıdan yükselen kalpler.
  hearts,

  /// Kapaktan fışkıran dikdörtgen konfeti.
  confetti,

  /// Yukarıdan süzülen yapraklar (oval).
  fallingLeaves,

  /// Süzülen yapraklar + arada beyaz çiçekler.
  fallingFlowers,

  /// Kapağın tepesinden saçılan yıldız tozu (8 köşeli yıldızlar).
  stardust,

  /// Arka planda yanıp sönen küçük yıldızlar.
  twinkles,

  /// Aşağıdan yükselen kıvılcımlar.
  embers,

  /// Yukarıdan yavaşça düşen kar taneleri / yuvarlak parçacıklar.
  snow,

  /// Aşağıdan yükselen içi boş baloncuklar.
  bubbles,
}

/// Bir temanın kutlaması: efekt türü + renk paleti (0xRRGGBB, alfa yok).
/// Örn: `CelebrationStyle(CelebrationKind.hearts, [0xE24B4A, 0xED93B1])`
class CelebrationStyle {
  const CelebrationStyle(this.kind, this.colors);

  final CelebrationKind kind;

  /// En az bir renk; parçacıklar sırayla bu renklerden alır.
  final List<int> colors;
}
