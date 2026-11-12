import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_look.dart';
import '../../domain/glass_math.dart';
import '../thermos/thermos_theme.dart';

/// Bardak sırası: hedef kadar bardak simgesi. Sıradaki boş bardağa dokun =
/// bir bardak ekle, son dolu bardağa dokun = bir bardak çıkar. Hedefin
/// üstünde sonda "+" bardağı kalır.
class GlassRow extends StatelessWidget {
  const GlassRow({
    super.key,
    required this.glass,
    required this.totalMl,
    required this.theme,
    required this.onAdd,
    required this.onRemove,
  });

  final GlassMath glass;
  final int totalMl;
  final ThermosTheme theme;
  final VoidCallback onAdd, onRemove;

  static const _gap = 6.0;
  static const _compactSize = 26.0;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final look = AppLook.of(theme);
    final full = glass.fullGlasses(totalMl);
    final shown = glass.shownGlasses(totalMl);
    final plus = glass.showPlus(totalMl);
    final cells = shown + (plus ? 1 : 0);

    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        // Az bardakta tek sıra; 8'den fazlasında iki sıra; 20'den fazlasında
        // küçük sabit boyutla sarılır.
        final int perRow;
        final double size;
        if (cells > 20) {
          size = _compactSize;
          perRow = math.max(1, ((w + _gap) / (size + _gap)).floor());
        } else {
          perRow = cells <= 8 ? cells : (cells / 2).ceil();
          size = ((w - (perRow - 1) * _gap) / perRow).clamp(20.0, 56.0);
        }
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (var i = 0; i < shown; i++)
              _GlassCell(
                key: ValueKey('glass-$i'),
                size: size,
                look: look,
                fill: glass.fillOf(i, totalMl),
                reduceMotion: reduce,
                label: i == full - 1
                    ? 'Bardak ${i + 1}, dolu. Son bardağı çıkarmak için dokun'
                    : i < full
                    ? 'Bardak ${i + 1}, dolu'
                    : 'Bardak ${i + 1}, boş. Bir bardak eklemek için dokun',
                onTap: i >= full ? onAdd : (i == full - 1 ? onRemove : null),
              ),
            if (plus)
              _GlassCell(
                key: const ValueKey('glass-plus'),
                size: size,
                look: look,
                fill: 0,
                plus: true,
                reduceMotion: reduce,
                label: 'Hedefin üstüne bir bardak daha ekle',
                onTap: onAdd,
              ),
          ],
        );
      },
    );
  }
}

class _GlassCell extends StatelessWidget {
  const _GlassCell({
    super.key,
    required this.size,
    required this.look,
    required this.fill,
    required this.reduceMotion,
    required this.label,
    required this.onTap,
    this.plus = false,
  });

  final double size;
  final AppLook look;
  final double fill;
  final bool reduceMotion, plus;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: size,
          // Dokunma alanı bardaktan yüksek olabilir (en az 44 px).
          height: math.max(size * 1.2, 44.0),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: fill),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, f, _) => CustomPaint(
                size: Size(size, size * 1.2),
                painter: _GlassPainter(
                  fill: f,
                  plus: plus,
                  outline: look.scheme.primary,
                  water: look.theme.water,
                  deep: look.theme.deepWater,
                  empty: look.scheme.surface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.fill,
    required this.plus,
    required this.outline,
    required this.water,
    required this.deep,
    required this.empty,
  });

  final double fill;
  final bool plus;
  final Color outline, water, deep, empty;

  @override
  void paint(Canvas canvas, Size s) {
    final top = s.width * 0.04, inset = s.width * 0.16;
    final body = Path()
      ..moveTo(top, 0)
      ..lineTo(s.width - top, 0)
      ..lineTo(s.width - inset, s.height)
      ..lineTo(inset, s.height)
      ..close();

    canvas.drawPath(body, Paint()..color = empty.withValues(alpha: 0.55));
    if (fill > 0) {
      canvas.save();
      canvas.clipPath(body);
      final y = s.height * (1 - fill);
      canvas.drawRect(
        Rect.fromLTWH(0, y, s.width, s.height - y),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [water, deep],
          ).createShader(Rect.fromLTWH(0, y, s.width, s.height - y + 0.1)),
      );
      canvas.restore();
    }
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, s.width * 0.07)
        ..strokeJoin = StrokeJoin.round
        ..color = outline,
    );
    if (plus) {
      final c = Offset(s.width / 2, s.height * 0.55);
      final r = s.width * 0.2;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(2, s.width * 0.09)
        ..color = outline;
      canvas.drawLine(c - Offset(r, 0), c + Offset(r, 0), p);
      canvas.drawLine(c - Offset(0, r), c + Offset(0, r), p);
    }
  }

  @override
  bool shouldRepaint(_GlassPainter o) =>
      o.fill != fill ||
      o.outline != outline ||
      o.water != water ||
      o.deep != deep ||
      o.empty != empty ||
      o.plus != plus;
}
