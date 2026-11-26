import 'reminder_planner.dart';

/// Temalı "susadım" metinleri: seçili karakter konuşur. Metinler sıcak ve
/// kısa tutulur; suçlama, baskı ya da "unuttun" dili kullanılmaz.
///
/// Her satırda `{ad}` yer tutucusu vardır; mataranın adıyla (varsayılan tema
/// adı) doldurulur. Ada ek getirilmez (Türkçe ünlü uyumu bozulmasın diye).
class ReminderMessages {
  const ReminderMessages._();

  /// Temaya özel satırı olmayan temalar için.
  static const fallback = [
    '{ad} susadı! Bir yudum su ister misin?',
    '{ad} küçük bir su molası istiyor.',
    'Su vakti! {ad} seninle içmek istiyor.',
  ];

  /// Yok sayılan hatırlatmadan sonraki tek, daha yumuşak mesajlar.
  static const retry = [
    'Acele yok! {ad} hazır olunca bir yudum bekliyor.',
    '{ad} hâlâ biraz susamış. Küçük bir yudum yeter!',
    'Müsait olunca {ad} için bir yudum, olur mu?',
  ];

  /// Tema kimliği -> 2-3 kısa satır.
  static const byTheme = <String, List<String>>{
    'klasik': [
      '{ad} susadı! Bir yudum su ister misin?',
      '{ad}: "Serin bir yudum çok iyi gelir!"',
    ],
    'cilek': [
      '{ad} susadı! Tatlı bir yudum su ister misin?',
      '{ad}: "Bir yudum su, bir de gülücük!"',
    ],
    'kaplan': [
      '{ad} susadı! Gürrr, bir yudum su lazım.',
      '{ad}: "Güçlü kalmak için küçük bir yudum!"',
    ],
    'panda': [
      '{ad} susadı! Bambu yemeden önce bir yudum su?',
      '{ad}: "Bir yudum su, sonra mışıl mışıl!"',
    ],
    'tekboynuz': [
      '{ad} susadı! Sihirli bir yudum su ister misin?',
      '{ad}: "Pırıl pırıl bir yudum zamanı!"',
    ],
    'astronot': [
      '{ad} susadı! Uzay yolculuğuna bir yudum su?',
      '{ad}: "Roketi doldurmadan önce su molası!"',
    ],
    'kamp': [
      '{ad} susadı! Kamp ateşinin başında bir yudum su?',
      '{ad}: "Macera öncesi serin bir yudum!"',
    ],
    'okyanus': [
      '{ad} susadı! Dalgalar kadar ferah bir yudum?',
      '{ad}: "Su benim evim, bir yudum da sen iç!"',
    ],
    'ahtapot': [
      '{ad} susadı! Sekiz kolum da su istiyor!',
      '{ad}: "Bir yudum su, kollar kıpır kıpır!"',
    ],
    'kaktus': [
      '{ad} susadı! Çöldeki en tatlı şey bir yudum su.',
      '{ad}: "Dikenlerim var ama kalbim yumuşak, su ister misin?"',
    ],
    'kardanadam': [
      '{ad} susadı! Soğuk bir yudum su ister misin?',
      '{ad}: "Erimeden önce bir yudum su!"',
    ],
    'ayi': [
      '{ad} susadı! Hmm, bir yudum su iyi gider.',
      '{ad}: "Kış uykusundan önce küçük bir yudum!"',
    ],
    'ejderha': [
      '{ad} susadı! Ateşi söndürmeye bir yudum su?',
      '{ad}: "Vaktini ayır, bir yudum su içelim!"',
    ],
    'maviejderha': [
      '{ad} susadı! Serin bir yudum su ister misin?',
      '{ad}: "Gökyüzünde uçmadan önce bir yudum!"',
    ],
    'karaejderha': [
      '{ad} susadı! Gece uçuşu için bir yudum su?',
      '{ad}: "Küçük bir yudum, büyük bir güç!"',
    ],
    'robot': [
      '{ad} susadı! Bip bop, su molası zamanı.',
      '{ad}: "Pilleri doldurmak için bir yudum su!"',
    ],
    'korsan': [
      '{ad} susadı! Yoho, bir yudum su ister misin?',
      '{ad}: "Gemiyi yüzdürmek için tatlı su lazım!"',
    ],
    'gece': [
      '{ad} susadı! Yıldızlar altında bir yudum su?',
      '{ad}: "Sessiz bir yudum, tatlı bir mola."',
    ],
    'sihirbaz': [
      '{ad} susadı! Sihirli bir yudum su ister misin?',
      '{ad}: "Abrakadabra! Bir yudum su zamanı."',
    ],
    'kedi': [
      '{ad} susadı! Miyav, bir yudum su ister misin?',
      '{ad}: "Mırrr, taze su çok güzel olur!"',
    ],
    'pofuduk': [
      '{ad} susadı! Miyav, bir yudum su ister misin?',
      '{ad}: "Mırıl mırıl, küçük bir su molası?"',
    ],
    'kopek': [
      '{ad} susadı! Hav hav, bir yudum su ister misin?',
      '{ad}: "Kuyruğum sallanıyor, su vakti!"',
    ],
    'tavsan': [
      '{ad} susadı! Havuçtan önce bir yudum su?',
      '{ad}: "Zıp zıp, bir yudum su molası!"',
    ],
    'penguen': [
      '{ad} susadı! Buz gibi bir yudum su ister misin?',
      '{ad}: "Pat pat yürüdüm, şimdi su molası!"',
    ],
    'koala': [
      '{ad} susadı! Uykudan önce bir yudum su?',
      '{ad}: "Sarılırken küçük bir su molası verelim."',
    ],
    'baykus': [
      '{ad} susadı! Hu hu, bir yudum su ister misin?',
      '{ad}: "Bilge baykuş der ki: bir yudum su iç."',
    ],
    'deve': [
      '{ad} susadı! Çöl yolunda bir yudum su molası?',
      '{ad}: "Yavaş yavaş gidelim, ama su içmeyi unutmayalım."',
    ],
    'zurafa': [
      '{ad} susadı! Boynum uzun ama su çok uzakta kalmasın.',
      '{ad}: "Yukarıdan bakınca bir yudum su zamanı görünüyor!"',
    ],
    'tilki': [
      '{ad} susadı! Kurnaz tilki bir yudum su istiyor.',
      '{ad}: "Küçük bir yudum, büyük bir ferahlık!"',
    ],
    'kurt': [
      '{ad} susadı! Auuu, bir yudum su ister misin?',
      '{ad}: "Sürüyle birlikte su molası!"',
    ],
    'civciv': [
      '{ad} susadı! Cik cik, bir yudum su ister misin?',
      '{ad}: "Minik gagamla bir yudum su içeyim mi?"',
    ],
    'yesilelma': [
      '{ad} susadı! Çıtır çıtır bir su molası?',
      '{ad}: "Bir yudum su, bir de gülümseme!"',
    ],
    'futbol': [
      '{ad} susadı! Maç arasında bir yudum su?',
      '{ad}: "Devre arası! Bir yudum su iç."',
    ],
    'basketbol': [
      '{ad} susadı! Smaçtan önce bir yudum su?',
      '{ad}: "Süre durdu, su molası zamanı!"',
    ],
    'voleybol': [
      '{ad} susadı! Servisten önce bir yudum su?',
      '{ad}: "Küçük bir mola, sonra tekrar oynarız!"',
    ],
    'yarisarabasi': [
      '{ad} susadı! Pit stop zamanı: bir yudum su?',
      '{ad}: "Vrum vrum! Yakıt yerine bir yudum su."',
    ],
    'bulut': [
      '{ad} susadı! Yağmur yağdırmadan önce bir yudum su?',
      '{ad}: "Hafif bir yudum, pamuk gibi bir mola."',
    ],
    'fil': [
      '{ad} susadı! Hortumum su istiyor!',
      '{ad}: "Hortumla bir yudum, ferah bir mola!"',
    ],
    'rakun': [
      '{ad} susadı! Maskeli rakun bir yudum su istiyor.',
      '{ad}: "Küçük elimle bir yudum su alayım mı?"',
    ],
    'kirpi': [
      '{ad} susadı! Dikenlerim yumuşadı, su ister misin?',
      '{ad}: "Küçük bir yudum, kocaman bir mutluluk!"',
    ],
    'sincap': [
      '{ad} susadı! Fındıktan önce bir yudum su?',
      '{ad}: "Ağaca tırmanmadan küçük bir su molası!"',
    ],
    'aslan': [
      '{ad} susadı! Kükremeden önce bir yudum su?',
      '{ad}: "Cesur aslan serin bir yudum istiyor!"',
    ],
    'geyik': [
      '{ad} susadı! Ormanda serin bir yudum su?',
      '{ad}: "Dere kenarında küçük bir mola verelim."',
    ],
    'inek': [
      '{ad} susadı! Möö, bir yudum su ister misin?',
      '{ad}: "Çayırda yürüdüm, şimdi su molası!"',
    ],
    'koyun': [
      '{ad} susadı! Mee, bir yudum su ister misin?',
      '{ad}: "Pamuk gibi bir mola, bir yudum su!"',
    ],
    'maymun': [
      '{ad} susadı! Ooh ooh, bir yudum su ister misin?',
      '{ad}: "Muzdan önce küçük bir su molası!"',
    ],
    'boga': [
      '{ad} susadı! Güçlü kalmak için bir yudum su?',
      '{ad}: "Küçük bir yudum, koca bir enerji!"',
    ],
    'susamuru': [
      '{ad} susadı! Suda yüzerken bir yudum da içsek?',
      '{ad}: "Su benim en iyi arkadaşım, sen de iç!"',
    ],
    'fok': [
      '{ad} susadı! Buzun üstünde bir yudum su?',
      '{ad}: "Küçük bir mola, ferah bir yudum!"',
    ],
    'balina': [
      '{ad} susadı! Büyük denizde minik bir yudum?',
      '{ad}: "Fışşş! Bir yudum su zamanı."',
    ],
    'karpuz': [
      '{ad} susadı! Serin, sulu bir yudum ister misin?',
      '{ad}: "Yaz tadında bir su molası!"',
    ],
    'limon': [
      '{ad} susadı! Ferah bir yudum su ister misin?',
      '{ad}: "Bir yudum su, bir de gülücük!"',
    ],
    'avokado': [
      '{ad} susadı! Bir yudum su ister misin?',
      '{ad}: "Kremsi bir mola, serin bir yudum!"',
    ],
    'dondurma': [
      '{ad} susadı! Erimeden önce bir yudum su?',
      '{ad}: "Dondurmadan sonra su da çok güzel!"',
    ],
    'sonbahar': [
      '{ad} susadı! Yapraklar arasında bir yudum su?',
      '{ad}: "Sıcak bir gün, serin bir yudum!"',
    ],
    'kurbaga': [
      '{ad} susadı! Vıraak, bir yudum su ister misin?',
      '{ad}: "Zıplamadan önce küçük bir su molası!"',
    ],
  };

  /// Sıradaki satırı seçer ve `{ad}` yerine [name]'i koyar. [index] her
  /// hatırlatmada artarak satırları sırayla döndürür (aynı metin üst üste
  /// gelmesin). Tema için satır yoksa [fallback] kullanılır.
  static String pick({
    required String themeId,
    required String name,
    ReminderKind kind = ReminderKind.normal,
    int index = 0,
  }) {
    final lines = kind == ReminderKind.retry
        ? retry
        : (byTheme[themeId] ?? fallback);
    final line = lines[index.abs() % lines.length];
    return line.replaceAll('{ad}', name);
  }

  /// Kutlama yazısı: yalnız kullanıcı bir ad verdiyse adı kullanır.
  static String celebration(String? customName) => customName == null
      ? defaultCelebration
      : 'Tebrikler! $customName hedefe ulaştı!';

  static const defaultCelebration = 'Tebrikler! Günlük hedefe ulaştın.';
}
