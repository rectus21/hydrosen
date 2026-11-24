import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/widget_snapshot.dart';
import '../reminder/character_avatar.dart';
import '../thermos/thermos_theme.dart';

/// Ana ekran widget'ının boyutu: 2x2 kare, 4x2 geniş.
enum WidgetPreviewSize {
  small2x2('2x2', 132, 132),
  wide4x2('4x2', 276, 132);

  const WidgetPreviewSize(this.label, this.width, this.height);
  final String label;
  final double width, height;
}

/// Telefonun ana ekranındaki widget'ın nasıl görüneceğinin küçük örneği
/// (yalnız önizleme; gerçek widget yerel kodla gelecek, bkz. WidgetBridge).
/// Karakter resmi, "1200 / 2000 ml", ilerleme halkası ve seri günü gösterir.
class WidgetPreview extends StatelessWidget {
  const WidgetPreview({super.key, required this.snapshot, required this.size});

  final WidgetSnapshot snapshot;
  final WidgetPreviewSize size;

  static const _ink = Color(0xFF10223A);

  @override
  Widget build(BuildContext context) {
    final theme = ThermosTheme.byId(snapshot.themeId);
    final wide = size == WidgetPreviewSize.wide4x2;
    final ring = _Ring(
      fraction: snapshot.ringFraction,
      color: theme.water,
      track: theme.glass,
      diameter: wide ? 84 : 70,
      child: CharacterAvatar(theme: theme, size: wide ? 52 : 44),
    );
    final amount = Text(
      snapshot.amountText,
      maxLines: 1,
      style: const TextStyle(
        color: _ink,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
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
            style: const TextStyle(
              color: _ink,
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(Colors.white, theme.glass, 0.35)!,
              Color.lerp(Colors.white, theme.glass, 0.8)!,
            ],
          ),
          border: Border.all(color: theme.edge.withValues(alpha: 0.35)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: wide
            ? Row(
                children: [
                  ring,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.characterName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        amount,
                        const SizedBox(height: 4),
                        streak,
                        const SizedBox(height: 6),
                        const _PlusOnePill(),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ring,
                  const SizedBox(height: 2),
                  FittedBox(fit: BoxFit.scaleDown, child: amount),
                  streak,
                ],
              ),
      ),
    );
  }
}

class _PlusOnePill extends StatelessWidget {
  const _PlusOnePill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFF10223A),
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Text(
      '+1 bardak',
      style: TextStyle(
        color: Colors.white,
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
