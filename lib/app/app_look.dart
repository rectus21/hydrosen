import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/thermos/art.dart';
import '../features/thermos/thermos_theme.dart';
import 'theme_scene.dart';

/// Türkçe karakterleri (ç ğ ı İ ö ş ü) içeren (latin-ext) Google yazı
/// tipleri. Paketin indirdiği dosyaların cmap tablosu tek tek denetlendi
/// (örn. Fredoka'da ğ ş İ yok, bu yüzden alınmadı). Her biri kendi
/// yöntemiyle çağrılır; böylece derleyici kullanılmayan yüzlerce yazı tipini
/// pakete katmaz.
enum AppFont {
  nunito('Nunito', GoogleFonts.nunito),
  baloo2('Baloo 2', GoogleFonts.baloo2),
  grandstander('Grandstander', GoogleFonts.grandstander),
  kalam('Kalam', GoogleFonts.kalam),
  quicksand('Quicksand', GoogleFonts.quicksand),
  chakraPetch('Chakra Petch', GoogleFonts.chakraPetch),
  cinzel('Cinzel', GoogleFonts.cinzel),
  alegreya('Alegreya', GoogleFonts.alegreya),
  pirataOne('Pirata One', GoogleFonts.pirataOne);

  const AppFont(this.family, this._apply);

  /// Google Fonts'taki aile adı.
  final String family;
  final TextStyle Function({TextStyle? textStyle}) _apply;

  /// Yazı tipi yüklenemezse (çevrimdışı ilk açılış, testler) Flutter
  /// [TextStyle.fontFamilyFallback] ile sistem yazı tipine düşer.
  TextStyle style([TextStyle? base]) => _apply(textStyle: base);
}

/// Başlık ve gövde yazı tipi çifti.
class AppTypeface {
  const AppTypeface(this.headline, [AppFont? body]) : body = body ?? headline;

  final AppFont headline, body;
}

/// Tema grubuna göre yazı tipi; listede olmayan (yeni) tema [_defaultFace]
/// alır. Yeni tema eklerken buraya bir satır eklemek yeterli.
const _defaultFace = AppTypeface(AppFont.nunito);
const _playful = AppTypeface(AppFont.baloo2);
const _sweet = AppTypeface(AppFont.grandstander);
const _hand = AppTypeface(AppFont.kalam);
const _calm = AppTypeface(AppFont.quicksand);
const _tech = AppTypeface(AppFont.chakraPetch);
const _fantasy = AppTypeface(AppFont.cinzel, AppFont.alegreya);
const _pirate = AppTypeface(AppFont.pirataOne, AppFont.alegreya);

const Map<String, AppTypeface> themeTypefaces = {
  'klasik': _defaultFace,
  'kamp': _defaultFace,
  'panda': _playful,
  'kaplan': _playful,
  'kedi': _playful,
  'kopek': _playful,
  'tavsan': _playful,
  'penguen': _playful,
  'koala': _playful,
  'baykus': _playful,
  'tilki': _playful,
  'civciv': _playful,
  'deve': _playful,
  'kurt': _playful,
  'ayi': _playful,
  'kurbaga': _playful,
  'cilek': _sweet,
  'tekboynuz': _sweet,
  'karpuz': _sweet,
  'limon': _sweet,
  'yesilelma': _sweet,
  'futbol': _playful,
  'basketbol': _playful,
  'voleybol': _playful,
  'pofuduk': _playful,
  'karaejderha': _fantasy,
  'yarisarabasi': _playful,
  'dondurma': _sweet,
  'sonbahar': _hand,
  'avokado': _hand,
  'kaktus': _hand,
  'okyanus': _calm,
  'ahtapot': _calm,
  'kardanadam': _calm,
  'astronot': _tech,
  'robot': _tech,
  'ejderha': _fantasy,
  'maviejderha': _fantasy,
  'sihirbaz': _fantasy,
  'gece': _fantasy,
  'korsan': _pirate,
  'bulut': _calm,
  'fil': _playful,
  'rakun': _playful,
  'kirpi': _playful,
  'sincap': _playful,
  'aslan': _playful,
  'geyik': _playful,
  'inek': _playful,
  'koyun': _playful,
  'maymun': _playful,
  'boga': _playful,
  'susamuru': _calm,
  'fok': _calm,
  'balina': _calm,
};

/// Bir temanın tüm uygulama görünümü: renk şeması, tam ekran arka plan ve
/// yazı tipleri. Termos renklerinden ve arka plan çiziminden otomatik
/// türetilir; 28 temanın hiçbiri ayrıca ayar gerektirmez.
class AppLook {
  AppLook._(
    this.theme,
    this.typeface,
    this.backdrop,
    this.scheme,
    this.panelScheme,
  );

  /// Kabartma yüzeyin gölge rengi: panel renginin çok koyu hali.
  Color get shade => Color.lerp(panelScheme.surface, Colors.black, 0.68)!;

  final ThermosTheme theme;
  final AppTypeface typeface;
  final BackdropColors backdrop;

  /// Çıplak arka plan (sahne) üstündeki metin için renk şeması.
  final ColorScheme scheme;

  /// Kabartma panelin (koyu, yumuşatılmış tema rengi) üstündeki açık metin
  /// ve düğme renkleri. Uygulamanın varsayılan teması bunu kullanır.
  final ColorScheme panelScheme;

  /// Kabartma panel rengi.
  Color get panel => panelScheme.surface;

  bool get isDark => scheme.brightness == Brightness.dark;

  static final _cache = <String, AppLook>{};

  static AppLook of(ThermosTheme theme) =>
      _cache.putIfAbsent(theme.id, () => _derive(theme));

  /// Gövde metni için hedef kontrast (WCAG AA 4.5; biz daha rahat okunsun
  /// diye ana metinde 7 hedefliyoruz).
  static const bodyContrast = 7.0;
  static const minContrast = 4.5;

  static AppLook _derive(ThermosTheme t) {
    final art = _ArtColors.probe(t);
    final dark = art.sky.computeLuminance() < 0.2;
    final toward = dark ? Colors.white : Colors.black;

    // Arka plan: açık temalarda çizimin göğü biraz yumuşatılır, altta zemin
    // rengine doğru hafif bir geçiş. Zemin çok farklıysa (Kardan Adam'ın
    // karı gibi) geçiş, metin rengi tarafında bol kontrast kalacak kadar
    // kısılır.
    final top = dark ? art.sky : Color.lerp(art.sky, Colors.white, 0.3)!;
    var mix = dark ? 0.3 : 0.22;
    while (mix > 0 &&
        contrast(toward, Color.lerp(top, art.ground, mix)!) < 10) {
      mix -= 0.02;
    }
    final bottom = Color.lerp(top, art.ground, mix.clamp(0.0, 1.0))!;
    final bubble = (dark ? t.glass : t.water).withValues(
      alpha: dark ? 0.10 : 0.12,
    );
    final wave = (dark ? t.water : t.glass).withValues(
      alpha: dark ? 0.14 : 0.35,
    );
    final backdrop = BackdropColors(
      top: top,
      bottom: bottom,
      bubble: bubble,
      wave: wave,
      scene: t,
    );
    final grounds = backdrop.surfaces;

    // Yumuşak kabartma: panel opak ve pastel. Açık temada kenar renginin
    // pastel tonu, koyu temada sahne gökünün cam rengine hafif kayması.
    // Panel opak olduğu için metin kontrastı yalnız bu renge ve sahneye göre
    // hesaplanır.
    final surface = dark
        ? Color.lerp(top, t.glass, 0.22)!
        : _pastel(t.edge, 0.93, 0.5);
    final onSurface = _push(
      t.label,
      [...grounds, surface],
      toward,
      bodyContrast,
    );
    final onSurfaceVariant = _push(
      Color.lerp(onSurface, top, 0.25)!,
      [...grounds, surface],
      toward,
      minContrast,
    );

    // Ana renk: açık temada kenar rengi (beyaz yazı üzerinde), koyu temada
    // cam rengi (koyu yazı üzerinde).
    final Color primary, onPrimary;
    if (dark) {
      primary = _push(
        t.glass,
        [...grounds, surface],
        Colors.white,
        minContrast,
      );
      onPrimary = _push(top, [primary], Colors.black, minContrast);
    } else {
      primary = _push(
        t.edge,
        [Colors.white, ...grounds, surface],
        Colors.black,
        minContrast,
      );
      onPrimary = Colors.white;
    }

    // Hızlı ekleme düğmeleri: suyun renginden bir ton.
    final container = dark
        ? Color.lerp(top, t.water, 0.35)!
        : Color.lerp(Colors.white, t.water, 0.30)!;
    final onContainer = _push(onSurface, [container], toward, minContrast);
    final primaryContainer = dark
        ? Color.lerp(top, t.glass, 0.25)!
        : Color.lerp(Colors.white, t.edge, 0.18)!;

    final seeded = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: dark ? Brightness.dark : Brightness.light,
    );
    final scheme = seeded.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: _push(
        onSurface,
        [primaryContainer],
        toward,
        minContrast,
      ),
      secondaryContainer: container,
      onSecondaryContainer: onContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainerLowest: Color.lerp(surface, top, 0.1),
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surface,
      surfaceContainerHighest: Color.lerp(surface, primary, 0.08),
      surfaceTint: Colors.transparent,
      outline: _push(
        Color.lerp(primary, top, 0.35)!,
        [...grounds, surface],
        toward,
        3,
      ),
      outlineVariant: Color.lerp(top, onSurface, 0.2),
      error: _push(seeded.error, [...grounds, surface], toward, minContrast),
    );
    final panelScheme = _panelScheme(t, art.sky, dark);
    return AppLook._(
      t,
      themeTypefaces[t.id] ?? _defaultFace,
      backdrop,
      scheme,
      panelScheme,
    );
  }

  /// Kabartma panel rengi: temanın ana tonu (sahne göğünün tonu) koyulaştırılıp
  /// yumuşatılır (orta-koyu açıklık, ılımlı doygunluk); üstüne krem metin
  /// konur. Metin kontrastı en az 6.5 olana dek panel koyulaştırılır.
  static ColorScheme _panelScheme(ThermosTheme t, Color sky, bool darkScene) {
    final skyHsl = HSLColor.fromColor(sky);
    // Gökte renk yoksa (gri/beyaz) suyun rengine düş.
    final src = skyHsl.saturation < 0.18 ? HSLColor.fromColor(t.water) : skyHsl;
    var hue = src.hue;
    // Sarı-hardal aralığı koyulaşınca çamurlaşır; bal-kehribara çekilir.
    if (hue > 38 && hue < 70) hue = 40 + (hue - 38) * 0.2;
    final sat = (src.saturation * 0.7).clamp(0.34, 0.5);
    var light = darkScene ? 0.36 : 0.37;
    HSLColor at(double l) => HSLColor.fromAHSL(1, hue, sat, l);
    var panel = at(light).toColor();
    final cream = HSLColor.fromAHSL(1, hue, 0.55, 0.95).toColor();
    while (light > 0.2 && contrast(cream, panel) < 6.5) {
      light -= 0.01;
      panel = at(light).toColor();
    }

    // Düğme vurgusu: baskın karakter/bant tonunun pastel hali.
    final bandWeak = HSLColor.fromColor(t.band).saturation < 0.18;
    final accentSrc = bandWeak ? t.water : t.band;
    final ah = HSLColor.fromColor(accentSrc);
    final primary = HSLColor.fromAHSL(
      1,
      ah.hue,
      ah.saturation.clamp(0.5, 0.8),
      0.78,
    ).toColor();
    final onPrimary = _push(
      HSLColor.fromAHSL(1, ah.hue, 0.5, 0.12).toColor(),
      [primary],
      Colors.black,
      minContrast,
    );
    final sh = HSLColor.fromColor(bandWeak ? t.glass : t.water);
    final container = HSLColor.fromAHSL(
      1,
      sh.hue,
      sh.saturation.clamp(0.35, 0.7),
      0.88,
    ).toColor();
    final onContainer = _push(
      HSLColor.fromAHSL(1, sh.hue, 0.5, 0.14).toColor(),
      [container],
      Colors.black,
      minContrast,
    );
    final onVariant = _push(
      Color.lerp(cream, panel, 0.2)!,
      [panel],
      Colors.white,
      minContrast,
    );
    final primaryContainer = Color.lerp(panel, primary, 0.28)!;
    final base = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: _push(cream, [primaryContainer], Colors.white, 6),
      secondary: container,
      onSecondary: onContainer,
      secondaryContainer: container,
      onSecondaryContainer: onContainer,
      surface: panel,
      onSurface: cream,
      onSurfaceVariant: onVariant,
      surfaceContainerLowest: Color.lerp(panel, Colors.black, 0.15),
      surfaceContainerLow: panel,
      surfaceContainer: panel,
      surfaceContainerHigh: Color.lerp(panel, Colors.white, 0.05),
      surfaceContainerHighest: Color.lerp(panel, Colors.white, 0.1),
      surfaceTint: Colors.transparent,
      outline: _push(
        Color.lerp(primary, panel, 0.3)!,
        [panel],
        Colors.white,
        3,
      ),
      outlineVariant: Color.lerp(panel, cream, 0.25),
      error: const Color(0xFFFFB4A8),
      onError: const Color(0xFF4A0A00),
    );
  }

  ThemeData? _themeData, _inkThemeData;

  /// Uygulamanın varsayılan teması: koyu kabartma panel şeması. Çıplak sahne
  /// üstüne düşen metinler [inkThemeData] ile okunur.
  ThemeData get themeData => _themeData ??= _buildTheme(panelScheme);

  /// Çıplak sahne (panel dışı) üstündeki metin için tema.
  ThemeData get inkThemeData => _inkThemeData ??= _buildTheme(scheme);

  ThemeData _buildTheme(ColorScheme s) {
    final isPanel = identical(s, panelScheme);
    final ink = scheme;
    final isDark = s.brightness == Brightness.dark;
    final base =
        (isDark
                ? Typography.material2021().white
                : Typography.material2021().black)
            .merge(Typography.material2021().englishLike)
            .apply(bodyColor: s.onSurface, displayColor: s.onSurface);
    final head = typeface.headline, body = typeface.body;
    TextStyle? h(TextStyle? x) => head.style(x);
    TextStyle? b(TextStyle? x) => body.style(x);
    final text = TextTheme(
      displayLarge: h(base.displayLarge),
      displayMedium: h(base.displayMedium),
      displaySmall: h(base.displaySmall),
      headlineLarge: h(base.headlineLarge),
      headlineMedium: h(
        base.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      headlineSmall: h(
        base.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      titleLarge: h(base.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      titleMedium: b(base.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      titleSmall: b(base.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      bodyLarge: b(base.bodyLarge),
      bodyMedium: b(base.bodyMedium),
      bodySmall: b(base.bodySmall),
      labelLarge: b(base.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
      labelMedium: b(base.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      labelSmall: b(base.labelSmall),
    );
    final clayShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(26),
    );
    final scrolled = backdrop.top.withValues(alpha: 0.94);

    return ThemeData(
      useMaterial3: true,
      colorScheme: s,
      textTheme: text,
      scaffoldBackgroundColor: backdrop.top,
      extensions: [backdrop, ClayColors(this)],
      // Alan altı yardım yazısı küçük ve ince; en koyu metin rengi + yarı kalın
      // yazıyla silikleşmeden okunur (WCAG AA).
      inputDecorationTheme: InputDecorationThemeData(
        helperStyle: text.bodySmall?.copyWith(
          color: s.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.scrolledUnder)
              ? scrolled
              : Colors.transparent,
        ),
        // Uygulama çubuğu çıplak sahne üstündedir: her zaman "mürekkep" rengi.
        foregroundColor: ink.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(color: ink.onSurface),
      ),
      cardTheme: CardThemeData(
        color: s.surface,
        elevation: 9,
        shadowColor: shade.withValues(alpha: 0.7),
        shape: clayShape,
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: s.primary,
        textColor: s.onSurface,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodyMedium?.copyWith(color: s.onSurfaceVariant),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.surface,
        elevation: 12,
        shadowColor: shade.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.surface,
        modalBackgroundColor: s.surface,
        elevation: 12,
        shadowColor: shade.withValues(alpha: 0.7),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      // Şişkin düğmeler: yumuşak, çift yönlü gölge ve tam yuvarlak uçlar.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: text.labelLarge,
          shadowColor: shade.withValues(alpha: 0.6),
          elevation: 4,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: text.labelLarge,
          foregroundColor: isPanel ? s.onSecondaryContainer : s.primary,
          backgroundColor: isPanel ? s.secondaryContainer : s.surface,
          side: BorderSide.none,
          shadowColor: shade.withValues(alpha: 0.6),
          elevation: 4,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: text.labelLarge),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          textStyle: text.labelLarge,
          backgroundColor: s.surface,
          selectedBackgroundColor: s.secondaryContainer,
          selectedForegroundColor: s.onSecondaryContainer,
          side: BorderSide.none,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: s.primary,
        inactiveTrackColor: Color.lerp(
          s.primary,
          isPanel ? s.surface : backdrop.top,
          0.7,
        ),
        thumbColor: s.primary,
        valueIndicatorColor: s.primary,
        valueIndicatorTextStyle: text.labelLarge?.copyWith(color: s.onPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: s.primary),
      iconTheme: IconThemeData(color: s.onSurface),
    );
  }

  /// Tonu [c]'den, verilen açıklık/doygunlukta pastel renk.
  static Color _pastel(Color c, double lightness, double saturation) =>
      HSLColor.fromColor(c)
          .withLightness(lightness)
          .withSaturation(saturation)
          .toColor();

  /// [fg]'yi [toward] yönüne (siyah/beyaz) kaydırarak her [bgs] üzerinde en
  /// az [min] kontrasta ulaştırır; rengin tonu olabildiğince korunur.
  static Color _push(Color fg, List<Color> bgs, Color toward, double min) {
    for (var i = 0; i <= 20; i++) {
      final c = Color.lerp(fg, toward, i / 20)!;
      if (bgs.every((b) => contrast(c, b) >= min)) return c;
    }
    return toward;
  }

  /// WCAG kontrast oranı (1–21). Yarı saydam renkler önce beyaza/arka plana
  /// karıştırılmalıdır.
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }
}

/// Kabartma yüzeylerin renkleri ve iki tema yüzü (panel / çıplak sahne).
/// [ClaySurface] içeriğini panel temasına sarar; çıplak sahne için
/// [AppLook.inkThemeData] kullanılır.
@immutable
class ClayColors extends ThemeExtension<ClayColors> {
  const ClayColors(this.look, [this._panel, this._shade]);

  final AppLook look;
  final Color? _panel, _shade;

  Color get panel => _panel ?? look.panel;
  Color get shade => _shade ?? look.shade;

  @override
  ClayColors copyWith() => this;

  @override
  ClayColors lerp(ClayColors? other, double t) {
    if (other == null) return this;
    return ClayColors(
      t < 0.5 ? look : other.look,
      Color.lerp(panel, other.panel, t),
      Color.lerp(shade, other.shade, t),
    );
  }
}

/// Tam ekran arka planın renkleri; tema geçişinde yumuşakça karışsın diye
/// [ThemeExtension] olarak taşınır.
@immutable
class BackdropColors extends ThemeExtension<BackdropColors> {
  const BackdropColors({
    required this.top,
    required this.bottom,
    required this.bubble,
    required this.wave,
    this.scene,
  });

  final Color top, bottom, bubble, wave;

  /// Tam ekran sahne olarak çizilecek tema (null ise düz geçiş çizilir).
  final ThermosTheme? scene;

  /// Metnin üzerine düşebileceği tüm opak renkler (kabarcık ve dalga
  /// karışımları dahil); kontrast bunların hepsine karşı sağlanır.
  List<Color> get surfaces => [
    top,
    bottom,
    for (final g in [top, bottom]) ...[
      Color.alphaBlend(bubble, g),
      Color.alphaBlend(wave, g),
      Color.alphaBlend(bubble, Color.alphaBlend(wave, g)),
    ],
  ];

  @override
  BackdropColors copyWith({
    Color? top,
    Color? bottom,
    Color? bubble,
    Color? wave,
    ThermosTheme? scene,
  }) => BackdropColors(
    top: top ?? this.top,
    bottom: bottom ?? this.bottom,
    bubble: bubble ?? this.bubble,
    wave: wave ?? this.wave,
    scene: scene ?? this.scene,
  );

  @override
  BackdropColors lerp(BackdropColors? other, double t) {
    if (other == null) return this;
    return BackdropColors(
      top: Color.lerp(top, other.top, t)!,
      bottom: Color.lerp(bottom, other.bottom, t)!,
      bubble: Color.lerp(bubble, other.bubble, t)!,
      wave: Color.lerp(wave, other.wave, t)!,
      scene: t < 0.5 ? scene : other.scene,
    );
  }
}

/// Ekranın tamamını kaplayan tema arka planı: dikey renk geçişi, alt kısımda
/// iki yumuşak dalga ve birkaç saydam kabarcık. Sayfalar Scaffold'u şeffaf
/// yapıp bunun içine koyar.
class ThemeBackdrop extends StatelessWidget {
  const ThemeBackdrop({
    super.key,
    required this.child,
    this.thermosKey,
    this.scroll,
  });

  final Widget child;

  /// Termosun bulunduğu widget; sahne zeminini termosun durduğu yere hizalar.
  /// Verilmezse sahne sabit bir konuma oturur (ayarlar ekranı).
  final GlobalKey? thermosKey;

  /// Sahne içerikle birlikte kayıyorsa kaydırma denetleyicisi.
  final Listenable? scroll;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<BackdropColors>();
    if (c == null) return child;
    final scene = c.scene;
    if (scene != null) {
      return ThemeScene(
        theme: scene,
        thermosKey: thermosKey,
        scroll: scroll,
        child: child,
      );
    }
    return CustomPaint(painter: _BackdropPainter(c), child: child);
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.c);

  final BackdropColors c;

  // Göreli konum (x, y) ve yarıçap (kısa kenara oranla).
  static const _bubbles = [
    (0.08, 0.10, 0.10),
    (0.92, 0.18, 0.14),
    (0.15, 0.42, 0.05),
    (0.88, 0.55, 0.08),
    (0.05, 0.70, 0.12),
    (0.70, 0.82, 0.06),
    (0.40, 0.06, 0.04),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          c.top,
          c.bottom,
        ]),
    );
    final r = size.shortestSide;
    final bubble = Paint()..color = c.bubble;
    for (final (x, y, s) in _bubbles) {
      canvas.drawCircle(Offset(size.width * x, size.height * y), r * s, bubble);
    }
    final wave = Paint()..color = c.wave;
    final w = size.width, h = size.height;
    for (final (top, amp) in const [(0.86, 0.025), (0.92, 0.02)]) {
      final y = h * top;
      canvas.drawPath(
        Path()
          ..moveTo(0, y)
          ..quadraticBezierTo(w * 0.25, y - h * amp, w * 0.5, y)
          ..quadraticBezierTo(w * 0.75, y + h * amp, w, y - h * amp * 0.5)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close(),
        wave,
      );
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.c != c;
}

/// Temanın arka plan çiziminden gök (ilk tam dolgu) ve zemin (alttaki son
/// tam genişlikte dolgu) renklerini çıkarır; çizim yapılmaz, yalnız
/// çağrılar dinlenir.
class _ArtColors {
  _ArtColors(this.sky, this.ground);

  final Color sky, ground;

  static _ArtColors probe(ThermosTheme t) {
    final canvas = _ProbeCanvas();
    try {
      t.background(Art(canvas));
    } catch (_) {
      // Dinlenmeyen bir çağrı varsa ilk bulunanlarla yetinilir.
    }
    final sky = canvas.sky ?? t.glass;
    return _ArtColors(sky, canvas.ground ?? sky);
  }
}

class _ProbeCanvas implements Canvas {
  Color? sky, ground;

  @override
  void drawPath(Path path, Paint paint) {
    if (paint.style != PaintingStyle.fill || paint.color.a < 0.5) return;
    final b = path.getBounds();
    if (b.width < 400) return;
    final color = paint.color.withValues(alpha: 1);
    if (sky == null && b.height > 450) {
      sky = color;
    } else if (b.top > 250 && b.bottom > 490) {
      ground = color;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
