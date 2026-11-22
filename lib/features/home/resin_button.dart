import 'package:flutter/material.dart';

import '../../app/app_look.dart';
import '../thermos/thermos_theme.dart';

/// Reçine düğmenin yoğunluk basamağı: [primary] en doygun ve opak,
/// [secondary] aynı paletten açık ton, [glass] sakin ve saydam cam.
enum ResinTone { primary, secondary, glass }

/// Bir düğmenin çözülmüş renkleri.
@immutable
class ResinColors {
  const ResinColors({
    required this.top,
    required this.bottom,
    required this.shadow,
    required this.text,
  });

  final Color top, bottom, shadow, text;

  /// Metin rengi: düğmenin orta rengine (saydamsa [backdrop] üstünde) karşı
  /// WCAG >= 4.5 sağlayan beyaz ya da aynı tonun çok koyu hali.
  static Color readableOn(Color mid, {Color? backdrop}) {
    final base = backdrop == null ? mid : Color.alphaBlend(mid, backdrop);
    final hsl = HSLColor.fromColor(base);
    final dark = hsl
        .withLightness(0.10)
        .withSaturation((hsl.saturation * 0.8).clamp(0.0, 0.6))
        .toColor();
    const light = Color(0xFFFFFFFF);
    return _contrast(light, base) >= _contrast(dark, base) ? light : dark;
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Tema paletinden renk türetir. Birincil = baskın karakter/bant rengi
  /// (gri/soluksa su rengi), ikincil = aynı paletten su/cam tonu.
  static ResinColors derive({
    required ResinTone tone,
    required Color band,
    required Color water,
    required Color glass,
    required Color deep,
    required Color backdrop,
  }) {
    var c = _derive(
      tone: tone,
      band: band,
      water: water,
      glass: glass,
      deep: deep,
      backdrop: backdrop,
      nudge: 0,
    );
    for (var i = 1; i <= 12; i++) {
      final fill = Color.lerp(c.top, c.bottom, 0.5)!;
      final grounds = tone == ResinTone.primary
          ? [const Color(0x00000000)]
          : tone == ResinTone.glass
          ? [backdrop, const Color(0xFFFFFFFF), const Color(0xFF000000)]
          : [backdrop];
      final worst = grounds
          .map((g) => _contrast(c.text, Color.alphaBlend(fill, g)))
          .reduce((a, b) => a < b ? a : b);
      if (worst >= 4.5) break;
      // Beyaz yazı için dolguyu koyulaştır, koyu yazı için aç.
      final whiteText = c.text.computeLuminance() > 0.5;
      c = _derive(
        tone: tone,
        band: band,
        water: water,
        glass: glass,
        deep: deep,
        backdrop: backdrop,
        nudge: (whiteText ? -0.03 : 0.03) * i,
      );
    }
    return c;
  }

  static ResinColors _derive({
    required ResinTone tone,
    required Color band,
    required Color water,
    required Color glass,
    required Color deep,
    required Color backdrop,
    required double nudge,
  }) {
    Color clamp(Color c, double lMin, double lMax, double sMin, double sMax) {
      final h = HSLColor.fromColor(c);
      return h
          .withLightness((h.lightness.clamp(lMin, lMax) + nudge).clamp(0.0, 1.0))
          .withSaturation(h.saturation.clamp(sMin, sMax))
          .toColor();
    }

    final bandHsl = HSLColor.fromColor(band);
    final dominant = bandHsl.saturation < 0.18 ? water : band;
    final shadow = clamp(deep, 0.12, 0.35, 0.2, 0.7);
    switch (tone) {
      case ResinTone.primary:
        final base = clamp(dominant, 0.36, 0.52, 0.45, 0.8);
        final top = _shift(base, 0.14, 0);
        final bottom = _shift(base, -0.1, 0.04);
        final mid = Color.lerp(top, bottom, 0.5)!;
        return ResinColors(
          top: top,
          bottom: bottom,
          shadow: shadow,
          text: readableOn(mid),
        );
      case ResinTone.secondary:
        final seed = dominant == water ? glass : water;
        final base = clamp(seed, 0.55, 0.72, 0.35, 0.75);
        final top = _shift(base, 0.1, 0).withValues(alpha: 0.88);
        final bottom = _shift(base, -0.06, 0.03).withValues(alpha: 0.92);
        final mid = Color.lerp(top, bottom, 0.5)!;
        return ResinColors(
          top: top,
          bottom: bottom,
          shadow: shadow,
          text: readableOn(mid, backdrop: backdrop),
        );
      case ResinTone.glass:
        final base = clamp(glass, 0.62, 0.82, 0.3, 0.7);
        final top = _shift(base, 0.08, 0).withValues(alpha: 0.7);
        final bottom = _shift(base, -0.05, 0.03).withValues(alpha: 0.82);
        final h = HSLColor.fromColor(base);
        final text = h
            .withLightness(0.14)
            .withSaturation(h.saturation.clamp(0.3, 0.7))
            .toColor();
        return ResinColors(
          top: top,
          bottom: bottom,
          shadow: shadow,
          text: text,
        );
    }
  }

  static Color _shift(Color c, double dl, double ds) {
    final h = HSLColor.fromColor(c);
    return h
        .withLightness((h.lightness + dl).clamp(0.0, 1.0))
        .withSaturation((h.saturation + ds).clamp(0.0, 1.0))
        .toColor();
  }

  /// Bağlamdaki geçerli temadan renkleri çözer.
  static ResinColors of(BuildContext context, ResinTone tone) {
    final theme = Theme.of(context);
    final backdropExt = theme.extension<BackdropColors>();
    final ThermosTheme? t = backdropExt?.scene;
    final backdrop =
        backdropExt?.top ?? theme.colorScheme.surface;
    final scheme = theme.colorScheme;
    return derive(
      tone: tone,
      band: t?.band ?? scheme.primary,
      water: t?.water ?? scheme.primary,
      glass: t?.glass ?? scheme.primaryContainer,
      deep: t?.deepWater ?? scheme.onSurface,
      backdrop: backdrop,
    );
  }
}

/// Yarı saydam, parlak "reçine / sıvı cam" düğme. Renkler geçerli temadan
/// türetilir; basınca 0.94'e küçülür, gölge daralır, parlama söner.
class ResinButton extends StatefulWidget {
  const ResinButton({
    super.key,
    required this.tone,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.builder,
    this.circle = false,
    this.radius,
  });

  final ResinTone tone;
  final double width, height;
  final VoidCallback? onPressed;
  final bool circle;
  final double? radius;

  /// İçerik; [textColor] okunabilirlik için seçilen renktir.
  final Widget Function(BuildContext context, Color textColor) builder;

  @override
  State<ResinButton> createState() => _ResinButtonState();
}

class _ResinButtonState extends State<ResinButton> {
  static const _dur = Duration(milliseconds: 120);
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final c = ResinColors.of(context, widget.tone);
    final enabled = widget.onPressed != null;
    final down = _down && enabled;
    final w = widget.width, h = widget.height;
    final r = widget.circle ? w / 2 : (widget.radius ?? h / 2);
    final glassy = widget.tone == ResinTone.glass;
    final radius = BorderRadius.circular(r);
    final shadowAlpha = glassy ? 0.28 : 0.45;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: widget.onPressed,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: AnimatedScale(
          scale: down ? 0.94 : 1,
          duration: _dur,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: _dur,
            width: w,
            height: h,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: c.shadow.withValues(
                    alpha: down ? shadowAlpha * 0.5 : shadowAlpha,
                  ),
                  blurRadius: down ? 4 : 13,
                  offset: Offset(0, down ? 2 : 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ResinPainter(c, r, glassy),
                  ),
                ),
                // Üstte yumuşak parlama.
                Positioned(
                  top: h * 0.07,
                  left: w * 0.14,
                  right: w * 0.14,
                  height: h * (widget.circle ? 0.34 : 0.4),
                  child: AnimatedOpacity(
                    duration: _dur,
                    opacity: down ? 0.55 : 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(r),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: c.text,
                    shadows: [
                      Shadow(
                        color: (c.text.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white)
                            .withValues(alpha: 0.28),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(color: c.text),
                    child: widget.builder(context, c.text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResinPainter extends CustomPainter {
  _ResinPainter(this.c, this.radius, this.glassy);

  final ResinColors c;
  final double radius;
  final bool glassy;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.top, c.bottom],
        ).createShader(rect),
    );
    // İç alt gölge / eğim.
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.shadow.withValues(alpha: 0),
            c.shadow.withValues(alpha: glassy ? 0.10 : 0.22),
          ],
          stops: const [0.6, 1],
        ).createShader(rect),
    );
    canvas.restore();
    // Işıklı kenar: üstte parlak, altta soluk.
    final rim = rr.deflate(0.75);
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.18),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ResinPainter old) =>
      old.c.top != c.top ||
      old.c.bottom != c.bottom ||
      old.c.shadow != c.shadow ||
      old.radius != radius ||
      old.glassy != glassy;
}
