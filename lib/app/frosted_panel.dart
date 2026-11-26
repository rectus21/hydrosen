import 'package:flutter/material.dart';

import 'app_look.dart';

/// Sahnenin üstünde duran yumuşak kabartma (kil) panel: opak pastel yüzey,
/// ekstra yuvarlak köşeler, dışarıda çift yönlü yumuşak gölge, içeride hafif
/// iç gölge. Yüzey rengi temanın [ColorScheme.surface]'idir; metin kontrastı
/// bu renge göre hesaplandığı için okunurluk korunur.
class FrostedPanel extends StatelessWidget {
  const FrostedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Temel köşe yarıçapı; kabartma biçimi bunu [ClaySurface.extraRadius]
  /// kadar büyütür.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClaySurface(
      radius: radius,
      child: Padding(
        padding: padding,
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
  }
}

/// Sahnenin üstünde duran sayfa başlığı: küçük kabartma hap içinde durur; böylece
/// başlık, altındaki resim ne olursa olsun yüzey renginde okunur.
class SceneTitle extends StatelessWidget {
  const SceneTitle(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ClaySurface(
        radius: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          // Panel temasında çözülsün diye Builder: yazı rengi krem olur.
          child: Builder(
            builder: (context) => Text(
              text,
              style: style ?? Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kabartma yüzey: panel, alt çubuk ve günlük kontrol kartı bunu kullanır.
/// Yüzey, temanın ana tonunun koyu ve yumuşatılmış hâlidir; içeriği panel
/// temasına (açık metin) sarılır. [inset] true ise yüzey içeri basılmış
/// görünür (seçili sekme).
class ClaySurface extends StatelessWidget {
  const ClaySurface({
    super.key,
    required this.child,
    this.radius = 24,
    this.inset = false,
    this.color,
  });

  /// Tombul görünüm için köşelere eklenen yarıçap.
  static const extraRadius = 8.0;

  final Widget child;
  final double radius;
  final bool inset;

  /// Verilmezse temanın panel rengi.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clay = theme.extension<ClayColors>();
    final panel = color ?? clay?.panel ?? theme.colorScheme.surface;
    final shade = clay?.shade ?? Color.lerp(panel, Colors.black, 0.68)!;
    final r = radius + extraRadius;
    final shape = BorderRadius.circular(r);
    final content = CustomPaint(
      painter: InnerShadowPainter(
        radius: r,
        // Derin iç gölge (sağ-alt) ve parlak ışık kenarı (sol-üst).
        shadow: shade.withValues(alpha: inset ? 0.9 : 0.55),
        light: Colors.white.withValues(alpha: inset ? 0.12 : 0.34),
        blur: inset ? 12 : 22,
        offset: inset ? 5 : 9,
      ),
      child: clay == null
          ? child
          : Theme(data: clay.look.themeData, child: child),
    );
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          color: inset ? null : panel,
          // Tombul hacim: üst belirgin açık, alt koyu (inset'te tersi: içeri
          // basılmış çukur).
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: inset
                ? [
                    Color.lerp(panel, Colors.black, 0.34)!,
                    Color.lerp(panel, Colors.black, 0.12)!,
                  ]
                : [
                    Color.lerp(panel, Colors.white, 0.14)!,
                    Color.lerp(panel, Colors.black, 0.06)!,
                  ],
          ),
          boxShadow: inset ? null : clayShadows(context, panel: panel),
        ),
        child: content,
      ),
    );
  }
}

/// Kabartma dış gölgesi: sağ-altta koyu, sol-üstte açık. Küçük kutular
/// (tema kutucukları, takvim günleri) [scale] ile küçültür.
List<BoxShadow> clayShadows(
  BuildContext context, {
  double scale = 1,
  Color? panel,
}) {
  final theme = Theme.of(context);
  final clay = theme.extension<ClayColors>();
  final dark = clay?.look.isDark ?? theme.brightness == Brightness.dark;
  final shade =
      clay?.shade ??
      Color.lerp(panel ?? theme.colorScheme.surface, Colors.black, 0.68)!;
  return [
    BoxShadow(
      color: shade.withValues(alpha: dark ? 0.95 : 0.6),
      blurRadius: 30 * scale,
      offset: Offset(11, 14) * scale,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: dark ? 0.16 : 0.55),
      blurRadius: 18 * scale,
      offset: Offset(-6, -6) * scale,
    ),
  ];
}

/// İçe doğru gölge: kenarlardan içeri yumuşak koyu ve açık halka.
class InnerShadowPainter extends CustomPainter {
  InnerShadowPainter({
    required this.radius,
    required this.shadow,
    required this.light,
    this.blur = 10,
    this.offset = 5,
  });

  final double radius, blur, offset;
  final Color shadow, light;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.save();
    canvas.clipRRect(rr);
    final outer = RRect.fromRectAndRadius(
      rect.inflate(80),
      Radius.circular(radius + 80),
    );
    void ring(Color c, Offset o) {
      canvas.drawDRRect(
        outer,
        rr.shift(o),
        Paint()
          ..color = c
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur / 2),
      );
    }

    ring(shadow, Offset(offset, offset));
    ring(light, Offset(-offset, -offset));
    canvas.restore();
  }

  @override
  bool shouldRepaint(InnerShadowPainter old) =>
      old.radius != radius ||
      old.shadow != shadow ||
      old.light != light ||
      old.blur != blur ||
      old.offset != offset;
}

/// Çıplak sahne (panel dışı) üstüne metin dizen ekranlar için: koyu "mürekkep"
/// temasına geçer. İçindeki [ClaySurface]'ler yine panel temasını kullanır.
class InkTheme extends StatelessWidget {
  const InkTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clay = Theme.of(context).extension<ClayColors>();
    if (clay == null) return child;
    return Theme(data: clay.look.inkThemeData, child: child);
  }
}
