/// Mataraya/karaktere verilen ad: kırpma, uzunluk sınırı ve çocuklar için
/// küçük bir uygunsuz kelime süzgeci. Saf Dart, birim testlidir.
enum BottleNameError { tooLong, inappropriate, invalidChars }

class BottleNameResult {
  const BottleNameResult.ok(this.name) : error = null;
  const BottleNameResult.fail(this.error) : name = null;

  /// Kabul edilen, kırpılmış ad. Boş ad "varsayılana dön" demektir ('').
  final String? name;
  final BottleNameError? error;

  bool get isOk => error == null;

  /// Çocuğa gösterilecek nazik Türkçe mesaj (başarıda null).
  String? get message => switch (error) {
    BottleNameError.tooLong =>
      'Bu isim biraz uzun oldu. En fazla ${BottleName.maxLength} harf olabilir.',
    BottleNameError.inappropriate =>
      'Bu ismi kullanamıyoruz. Başka güzel bir isim bulalım mı?',
    BottleNameError.invalidChars =>
      'İsimde sadece harf, rakam ve boşluk olabilir.',
    null => null,
  };
}

class BottleName {
  const BottleName._();

  static const maxLength = 16;

  /// Baştaki/sondaki boşlukları atar, aradaki boşlukları teke indirir.
  static String clean(String raw) => raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Adı doğrular. Boş ad geçerlidir ve '' döner (varsayılan tema adı).
  static BottleNameResult validate(String raw) {
    final name = clean(raw);
    if (name.isEmpty) return const BottleNameResult.ok('');
    if (name.runes.length > maxLength) {
      return const BottleNameResult.fail(BottleNameError.tooLong);
    }
    if (!_allowed.hasMatch(name) || !_hasLetterOrDigit.hasMatch(name)) {
      return const BottleNameResult.fail(BottleNameError.invalidChars);
    }
    if (isInappropriate(name)) {
      return const BottleNameResult.fail(BottleNameError.inappropriate);
    }
    return BottleNameResult.ok(name);
  }

  // Harf (her dil), rakam, boşluk ve birkaç sakin noktalama.
  static final _allowed = RegExp(r"^[\p{L}\p{N} .'\-]+$", unicode: true);
  static final _hasLetterOrDigit = RegExp(r'[\p{L}\p{N}]', unicode: true);

  /// Türkçe harfleri ASCII'ye indirir, yaygın "leet" yazımlarını çözer ve
  /// harf olmayanları atar (tekrar eden harfleri korur).
  static String _foldLetters(String input) {
    final b = StringBuffer();
    for (final r in input.runes) {
      final c = String.fromCharCode(r);
      final mapped = _fold[c] ?? c.toLowerCase();
      for (final u in mapped.runes) {
        final ch = String.fromCharCode(u);
        final leet = _leet[ch] ?? ch;
        if (RegExp(r'[a-z]').hasMatch(leet)) b.write(leet);
      }
    }
    return b.toString();
  }

  /// Türkçe harfleri ASCII'ye indirir, yaygın "leet" yazımlarını çözer,
  /// harf olmayanları atar ve tekrar eden harfleri teke düşürür.
  /// Örn. "S.İ.K" ve "s1kt1r" aynı biçime gelir.
  static String normalize(String input) {
    final folded = _foldLetters(input);
    final out = StringBuffer();
    String? prev;
    for (final ch in folded.split('')) {
      if (ch != prev) out.write(ch);
      prev = ch;
    }
    return out.toString();
  }

  static const _fold = {
    'ç': 'c',
    'Ç': 'c',
    'ğ': 'g',
    'Ğ': 'g',
    'ı': 'i',
    'I': 'i',
    'İ': 'i',
    'ö': 'o',
    'Ö': 'o',
    'ş': 's',
    'Ş': 's',
    'ü': 'u',
    'Ü': 'u',
    'â': 'a',
    'Â': 'a',
    'î': 'i',
    'û': 'u',
  };
  static const _leet = {
    '0': 'o',
    '1': 'i',
    '3': 'e',
    '4': 'a',
    '5': 's',
    '7': 't',
    '@': 'a',
    r'$': 's',
    '!': 'i',
  };

  // Her ad için iki görünüm bakılır: sözcük sözcük (kısa/riskli kelimeler
  // yalnız tam sözcük olarak eşleşir; "Sıkı", "Kayarak" gibi masum adlar
  // takılmasın) ve boşluksuz birleşik (uzun kelimeler her yerde eşleşir).

  /// Tam sözcük olarak eşleşenler (normalize edilmiş).
  static final Set<String> _exactWords = {
    'sik',
    'sikim',
    'siker',
    'sikti',
    'sikerim',
    'siktim',
    'amk',
    'aq',
    'mk',
    'am',
    'got',
    'oc',
    'pic',
    'bok',
    'boku',
    'bokum',
    'ibne',
    'ibneler',
    'pust',
    'yarak',
    'dalyarak',
    'aptal',
    'salak',
    'gerizekali',
    'dangalak',
    'serefsiz',
    'ahmak',
    'penis',
    'seks',
    'sex',
    'porno',
    'fuck',
    'shit',
    'dick',
    'bitch',
    'cunt',
  }.map(normalize).toSet();

  /// Başka sözcüklerin içinde pek geçmeyen, her yerde aranan kelimeler.
  static final List<String> _substrings = [
    'orospu',
    'pezevenk',
    'amcik',
    'siktir',
    'sikeyim',
    'sikik',
    'kahpe',
    'gavat',
    'gotveren',
    'fuck',
    'bitch',
    'pussy',
    'porno',
  ].map(normalize).toList();

  /// Tekrar harf sıkıştırılırsa masum Türkçe adlarla (örn. "Nigar", "Niğde")
  /// çakışacak kalıplar; sıkıştırma öncesi katlanmış metinde aranır.
  static const List<String> _foldedSubstrings = ['nigg'];

  /// Ad uygunsuz bir kelime içeriyor mu.
  static bool isInappropriate(String name) {
    final words = name.split(RegExp(r'\s+'));
    for (final w in words) {
      final n = normalize(w);
      if (n.isNotEmpty && _exactWords.contains(n)) return true;
    }
    final folded = _foldLetters(name);
    for (final bad in _foldedSubstrings) {
      if (folded.contains(bad)) return true;
    }
    final joined = normalize(name);
    for (final bad in _substrings) {
      if (joined.contains(bad)) return true;
    }
    // Sözcük sözcük ayrı yazılan harfler ("s i k"): birleşik hâl tam eşleşirse.
    return _exactWords.contains(joined);
  }
}
