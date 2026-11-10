import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/thermos/art.dart';
import '../features/thermos/thermos_theme.dart';

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
  'kurt': _playful,
  'ayi': _playful,
  'kurbaga': _playful,
  'cilek': _sweet,
  'tekboynuz': _sweet,
  'karpuz': _sweet,
  'limon': _sweet,
  'dondurma': _sweet,
  'seftali': _sweet,
  'botanik': _hand,
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
};

/// Bir temanın tüm uygulama görünümü: renk şeması, tam ekran arka plan ve
/// yazı tipleri. Termos renklerinden ve arka plan çiziminden otomatik
/// türetilir; 28 temanın hiçbiri ayrıca ayar gerektirmez.
class AppLook {
  AppLook._(this.theme, this.typeface, this.backdrop, this.scheme);

  final ThermosTheme theme;
  final AppTypeface typeface;
  final BackdropColors backdrop;
  final ColorScheme scheme;

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
    );
    final grounds = backdrop.surfaces;

    final surface = dark
        ? Color.lerp(top, Colors.white, 0.08)!
        : Color.lerp(top, Colors.white, 0.75)!;
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
      primary = _push(t.glass, grounds, Colors.white, minContrast);
      onPrimary = _push(top, [primary], Colors.black, minContrast);
    } else {
      primary = _push(
        t.edge,
        [Colors.white, ...grounds],
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
      outline: _push(Color.lerp(primary, top, 0.35)!, grounds, toward, 3),
      outlineVariant: Color.lerp(top, onSurface, 0.2),
      error: _push(seeded.error, [...grounds, surface], toward, minContrast),
    );
    return AppLook._(t, themeTypefaces[t.id] ?? _defaultFace, backdrop, scheme);
  }

  ThemeData? _themeData;

  ThemeData get themeData => _themeData ??= _buildTheme();

  ThemeData _buildTheme() {
    final s = scheme;
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
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    final scrolled = backdrop.top.withValues(alpha: 0.94);

    return ThemeData(
      useMaterial3: true,
      colorScheme: s,
      textTheme: text,
      scaffoldBackgroundColor: backdrop.top,
      extensions: [backdrop],
      appBarTheme: AppBarTheme(
        backgroundColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.scrolledUnder)
              ? scrolled
              : Colors.transparent,
        ),
        foregroundColor: s.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: s.surface.withValues(alpha: isDark ? 0.82 : 0.86),
        elevation: 0,
        shape: shape.copyWith(side: BorderSide(color: s.outlineVariant)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: text.labelLarge,
          foregroundColor: s.primary,
          backgroundColor: s.surface.withValues(alpha: 0.6),
          side: BorderSide(color: s.outline),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: text.labelLarge),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          textStyle: text.labelLarge,
          backgroundColor: s.surface.withValues(alpha: 0.6),
          selectedBackgroundColor: s.secondaryContainer,
          selectedForegroundColor: s.onSecondaryContainer,
          side: BorderSide(color: s.outline),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: s.primary,
        inactiveTrackColor: Color.lerp(s.primary, backdrop.top, 0.7),
        thumbColor: s.primary,
        valueIndicatorColor: s.primary,
        valueIndicatorTextStyle: text.labelLarge?.copyWith(color: s.onPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: s.primary),
      iconTheme: IconThemeData(color: s.onSurface),
    );
  }

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

/// Tam ekran arka planın renkleri; tema geçişinde yumuşakça karışsın diye
/// [ThemeExtension] olarak taşınır.
@immutable
class BackdropColors extends ThemeExtension<BackdropColors> {
  const BackdropColors({
    required this.top,
    required this.bottom,
    required this.bubble,
    required this.wave,
  });

  final Color top, bottom, bubble, wave;

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
  }) => BackdropColors(
    top: top ?? this.top,
    bottom: bottom ?? this.bottom,
    bubble: bubble ?? this.bubble,
    wave: wave ?? this.wave,
  );

  @override
  BackdropColors lerp(BackdropColors? other, double t) {
    if (other == null) return this;
    return BackdropColors(
      top: Color.lerp(top, other.top, t)!,
      bottom: Color.lerp(bottom, other.bottom, t)!,
      bubble: Color.lerp(bubble, other.bubble, t)!,
      wave: Color.lerp(wave, other.wave, t)!,
    );
  }
}

/// Ekranın tamamını kaplayan tema arka planı: dikey renk geçişi, alt kısımda
/// iki yumuşak dalga ve birkaç saydam kabarcık. Sayfalar Scaffold'u şeffaf
/// yapıp bunun içine koyar.
class ThemeBackdrop extends StatelessWidget {
  const ThemeBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<BackdropColors>();
    if (c == null) return child;
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
