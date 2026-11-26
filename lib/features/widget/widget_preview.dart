import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../../domain/widget_snapshot.dart';
import '../reminder/character_avatar.dart';
import '../thermos/illustrated_artwork.dart';
import '../thermos/thermos_theme.dart';

/// Ana ekran widget'ının boyutu: 2x2 kare, 4x2 geniş.
enum WidgetPreviewSize {
  small2x2('2x2', 132, 132),
  wide4x2('4x2', 276, 132);

  const WidgetPreviewSize(this.label, this.width, this.height);
  final String label;
  final double width, height;
}

/// Sahnenin widget kırpmasında en iyi görünen dikey konumu (Alignment.y).
double _sceneY(String id, bool wide) {
  const small = {'panda': 0.55, 'penguen': -0.3, 'kedi': -0.7};
  const wideY = {'panda': 0.5, 'penguen': -0.4, 'kedi': -0.6};
  return (wide ? wideY : small)[id] ?? (wide ? -0.2 : -0.1);
}

/// Telefonun ana ekranındaki widget'ın nasıl görüneceğinin küçük örneği
/// (yalnız önizleme; gerçek widget yerel kodla gelecek, bkz. WidgetBridge).
/// Karakter resmi, "1200 / 2000 ml", ilerleme halkası ve seri günü gösterir.
class WidgetPreview extends StatelessWidget {
  const WidgetPreview({super.key, required this.snapshot, required this.size});

  final WidgetSnapshot snapshot;
  final WidgetPreviewSize size;

  static const _ink = Color(0xFF10223A);

  /// Alt bölgesi bu değerden koyu olan sahnelerde örtü siyah, yazı beyazdır.
  static const darkSceneLuma = 0.4;

  @override
  Widget build(BuildContext context) {
    final theme = ThermosTheme.byId(snapshot.themeId);
    final wide = size == WidgetPreviewSize.wide4x2;
    final luma = IllustratedArtwork.bottomLuma[theme.id];
    // Parlaklığı örneklenmeyen kurt sahnesi koyudur.
    final dark = (luma ?? (theme.id == 'kurt' ? 0.0 : 1.0)) < darkSceneLuma;
    final fg = dark ? Colors.white : _ink;
    final ring = _Ring(
      fraction: snapshot.ringFraction,
      color: theme.water,
      track: theme.glass,
      diameter: wide ? 84 : 70,
      child: CharacterAvatar(theme: theme, size: wide ? 52 : 44),
    );
    final disc = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.55),
      ),
      child: ring,
    );
    final amount = Text(
      snapshot.amountText,
      maxLines: 1,
      style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 14),
    );
    final streak = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 15,
            color: Color(0xFFD9570F),
          ),
          const SizedBox(width: 2),
          Text(
            snapshot.streakText,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
    return Semantics(
      label:
          'Ana ekran widget önizlemesi, ${size.label}: ${snapshot.characterName}, '
          '${snapshot.amountText}, yüzde ${snapshot.percent}, '
          '${snapshot.streakText}',
      excludeSemantics: true,
      child: Container(
        key: ValueKey('widget-preview-${size.label}'),
        width: size.width,
        height: size.height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Color.lerp(Colors.white, theme.glass, 0.35),
          boxShadow: clayShadows(context, scale: 0.5),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/scenes/${theme.id}.png',
              fit: BoxFit.cover,
              alignment: Alignment(0, _sceneY(theme.id, wide)),
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // Geniş: yazı sağda; kare: yazı altta.
                  begin: wide ? Alignment.centerLeft : Alignment.topCenter,
                  end: wide ? Alignment.centerRight : Alignment.bottomCenter,
                  colors: [
                    for (final a in wide ? [0.0, 0.7, 0.84] : [0.0, 0.8, 0.86])
                      (dark ? Colors.black : Colors.white).withValues(alpha: a),
                  ],
                  stops: wide ? [0.28, 0.5, 1] : [0.35, 0.62, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: wide
                  ? Row(
                      children: [
                        disc,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.characterName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: fg,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              amount,
                              const SizedBox(height: 4),
                              streak,
                              const SizedBox(height: 6),
                              _PlusOnePill(dark: dark),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        disc,
                        const SizedBox(height: 2),
                        FittedBox(fit: BoxFit.scaleDown, child: amount),
                        streak,
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusOnePill extends StatelessWidget {
  const _PlusOnePill({required this.dark});

  /// Koyu sahnede açık renkli hap (koyu örtüde lacivert hap kaybolur).
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: dark ? Colors.white : WidgetPreview._ink,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      '+1 bardak',
      style: TextStyle(
        color: dark ? WidgetPreview._ink : Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
  );
}

/// Dairesel ilerleme halkası; ortada [child].
class _Ring extends StatelessWidget {
  const _Ring({
    required this.fraction,
    required this.color,
    required this.track,
    required this.diameter,
    required this.child,
  });

  final double fraction;
  final Color color, track;
  final double diameter;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: diameter,
    height: diameter,
    child: CustomPaint(
      painter: _RingPainter(fraction, color, track),
      child: Center(child: child),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.fraction, this.color, this.track);

  final double fraction;
  final Color color, track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = track);
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * fraction,
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track;
}
