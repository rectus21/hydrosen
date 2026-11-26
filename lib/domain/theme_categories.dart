import '../features/thermos/thermos_theme.dart';

/// Tema kataloğunun kategorileri (görünme sırasıyla). Eşlenmeyen temalar
/// [kThemeOtherCategory] altında toplanır.
const String kThemeOtherCategory = 'Diğer';
const List<String> kThemeCategories = [
  'Hayvanlar',
  'Meyve ve tatlılar',
  'Spor',
  'Fantastik ve uzay',
  'Doğa ve mevsim',
  kThemeOtherCategory,
];

/// Tema id -> kategori. Yeni temayı eklemek/taşımak için yalnız burayı düzenle.
const Map<String, String> kThemeCategoryOf = {
  // Hayvanlar
  'kedi': 'Hayvanlar',
  'pofuduk': 'Hayvanlar',
  'kopek': 'Hayvanlar',
  'tavsan': 'Hayvanlar',
  'penguen': 'Hayvanlar',
  'koala': 'Hayvanlar',
  'baykus': 'Hayvanlar',
  'tilki': 'Hayvanlar',
  'kurt': 'Hayvanlar',
  'civciv': 'Hayvanlar',
  'deve': 'Hayvanlar',
  'zurafa': 'Hayvanlar',
  'aslan': 'Hayvanlar',
  'geyik': 'Hayvanlar',
  'inek': 'Hayvanlar',
  'koyun': 'Hayvanlar',
  'maymun': 'Hayvanlar',
  'boga': 'Hayvanlar',
  'susamuru': 'Hayvanlar',
  'fok': 'Hayvanlar',
  'balina': 'Hayvanlar',
  'fil': 'Hayvanlar',
  'rakun': 'Hayvanlar',
  'kirpi': 'Hayvanlar',
  'sincap': 'Hayvanlar',
  'kaplan': 'Hayvanlar',
  'panda': 'Hayvanlar',
  'ayi': 'Hayvanlar',
  'ahtapot': 'Hayvanlar',
  'kurbaga': 'Hayvanlar',
  // Meyve ve tatlılar
  'cilek': 'Meyve ve tatlılar',
  'karpuz': 'Meyve ve tatlılar',
  'limon': 'Meyve ve tatlılar',
  'avokado': 'Meyve ve tatlılar',
  'dondurma': 'Meyve ve tatlılar',
  'yesilelma': 'Meyve ve tatlılar',
  // Spor
  'futbol': 'Spor',
  'basketbol': 'Spor',
  'voleybol': 'Spor',
  'yarisarabasi': 'Spor',
  // Fantastik ve uzay
  'tekboynuz': 'Fantastik ve uzay',
  'astronot': 'Fantastik ve uzay',
  'ejderha': 'Fantastik ve uzay',
  'maviejderha': 'Fantastik ve uzay',
  'karaejderha': 'Fantastik ve uzay',
  'robot': 'Fantastik ve uzay',
  'korsan': 'Fantastik ve uzay',
  'sihirbaz': 'Fantastik ve uzay',
  'gece': 'Fantastik ve uzay',
  // Doğa ve mevsim
  'okyanus': 'Doğa ve mevsim',
  'kaktus': 'Doğa ve mevsim',
  'kardanadam': 'Doğa ve mevsim',
  'bulut': 'Doğa ve mevsim',
  'kamp': 'Doğa ve mevsim',
  'sonbahar': 'Doğa ve mevsim',
};

String themeCategoryOf(ThermosTheme t) =>
    kThemeCategoryOf[t.id] ?? kThemeOtherCategory;

/// Kategori -> temalar ([ThermosTheme.all] sırasıyla); boş kategoriler atlanır.
Map<String, List<ThermosTheme>> groupThemesByCategory([
  Iterable<ThermosTheme>? themes,
]) {
  final out = {for (final c in kThemeCategories) c: <ThermosTheme>[]};
  for (final t in themes ?? ThermosTheme.all) {
    out[themeCategoryOf(t)]!.add(t);
  }
  out.removeWhere((_, v) => v.isEmpty);
  return out;
}

