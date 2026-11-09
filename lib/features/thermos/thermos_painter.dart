import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'svg_path.dart';
import 'thermos_theme.dart';

/// Taslaklardaki koordinat sistemi (680x520 tuvalin termosu içeren bölümü).
const designRect = Rect.fromLTWH(200, 20, 300, 480);

class _Geometry {
  const _Geometry({
    required this.body,
    required this.top,
    required this.bottom,
    required this.markRight,
    required this.labelX,
    required this.neck,
    required this.base,
    required this.shadowRx,
    required this.shineLeft,
    required this.shadeRight,
  });

  final String body;
  final double top, bottom, markRight, labelX, shadowRx, shineLeft, shadeRight;
  final Rect neck, base;

  static const chubby = _Geometry(
    body: 'M300 208 Q238 220 236 300 L236 420 Q236 476 300 478 L380 478 Q444 476 444 420 L444 300 Q442 220 380 208 Z',
    top: 230,
    bottom: 450,
    markRight: 418,
    labelX: 452,
    neck: Rect.fromLTRB(300, 190, 380, 212),
    base: Rect.fromLTRB(236, 452, 444, 478),
    shadowRx: 118,
    shineLeft: 250,
    shadeRight: 430,
  );

  static const slim = _Geometry(
    body: 'M296 178 Q290 178 290 190 L290 456 Q290 482 316 482 L364 482 Q390 482 390 456 L390 190 Q390 178 384 178 Z',
    top: 196,
    bottom: 456,
    markRight: 370,
    labelX: 400,
    neck: Rect.fromLTRB(290, 160, 390, 182),
    base: Rect.fromLTRB(290, 458, 390, 482),
    shadowRx: 66,
    shineLeft: 298,
    shadeRight: 382,
  );
}

/// Termosu, suyu, litre çizgilerini ve kapağı çizer.
class ThermosPainter extends CustomPainter {
  ThermosPainter({
    required this.shape,
    required this.theme,
    required this.level,
    required this.goalMl,
    required this.time,
    required this.slosh,
  });

  final ThermosShape shape;
  final ThermosTheme theme;

  /// 0..1 arası doluluk.
  final double level;
  final int goalMl;

  /// Saniye cinsinden dalga zamanı.
  final double time;

  /// Çalkalanma şiddeti; su eklenince artar, zamanla söner.
  final double slosh;

  static final _paths = <String, Path>{};
  static Path _p(String d) => _paths.putIfAbsent(d, () => svgPath(d));

  _Geometry get _g =>
      shape == ThermosShape.chubby ? _Geometry.chubby : _Geometry.slim;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / designRect.width,
      size.height / designRect.height,
    );
    canvas.save();
    canvas.translate(
      (size.width - designRect.width * scale) / 2,
      (size.height - designRect.height * scale) / 2,
    );
    canvas.scale(scale);
    canvas.translate(-designRect.left, -designRect.top);

    final geo = _g;
    final body = _p(geo.body);
    final fill = Paint()..style = PaintingStyle.fill;

    // Gölge ve cam.
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(340, 490),
        width: geo.shadowRx * 2,
        height: 22,
      ),
      fill..color = const Color(0x26000000),
    );
    canvas.drawPath(body, fill..color = theme.glass.withValues(alpha: 0.35));

    // Su (gövdeye kırpılmış).
    canvas.save();
    canvas.clipPath(body);
    if (level > 0) {
      final lvl = geo.bottom - level.clamp(0.0, 1.0) * (geo.bottom - geo.top);
      final amp = 2 + slosh * 0.8;
      double waveY(double x) => lvl + math.sin(x / 18 + time * 2.5) * amp;
      final water = Path()..moveTo(220, waveY(220));
      final surfTop = <Offset>[];
      final deep = Path()..moveTo(220, 500);
      for (double x = 220; x <= 460; x += 6) {
        final y = waveY(x);
        water.lineTo(x, y);
        surfTop.add(Offset(x, y));
        deep.lineTo(x, math.max(y, geo.bottom - 40));
      }
      water
        ..lineTo(460, 500)
        ..lineTo(220, 500)
        ..close();
      deep
        ..lineTo(460, 500)
        ..close();
      final surf = Path()
        ..addPolygon([
          ...surfTop,
          for (final o in surfTop.reversed)
            Offset(o.dx, o.dy + 7 + math.sin(o.dx / 11 + time * 3.3) * 1.5),
        ], true);
      canvas.drawPath(water, fill..color = theme.water);
      canvas.drawPath(
        deep,
        fill..color = theme.deepWater.withValues(alpha: 0.35),
      );
      canvas.drawPath(
        surf,
        fill..color = theme.waterSurface.withValues(alpha: 0.55),
      );
    }
    // Cam parlaması ve gölgesi.
    final h = geo.bottom - geo.top;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(geo.shineLeft, geo.top - 20, 10, h),
        const Radius.circular(5),
      ),
      fill..color = const Color(0x8CFFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(geo.shineLeft + 16, geo.top, 4, h * 0.8),
        const Radius.circular(2),
      ),
      fill..color = const Color(0x59FFFFFF),
    );
    canvas.drawRect(
      Rect.fromLTWH(geo.shadeRight - 14, geo.top - 30, 22, h + 60),
      fill..color = const Color(0x1A000000),
    );
    canvas.restore();

    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = theme.edge,
    );

    _bands(canvas, geo);
    _marks(canvas, geo);
    _classicCap(canvas);
    canvas.restore();
  }

  void _bands(Canvas canvas, _Geometry geo) {
    final band = Paint()..color = theme.band;
    final light = Paint()..color = theme.bandLight;
    final n = geo.neck;
    canvas.drawRect(n, band);
    for (var x = n.left + 8; x < n.right - 6; x += 14) {
      canvas.drawRect(Rect.fromLTWH(x, n.top + 3, 4, n.height - 6), light);
    }
    final b = geo.base;
    canvas.drawPath(
      svgPath(
        'M${b.left} ${b.top} H${b.right} V${b.bottom - 24} Q${b.right} ${b.bottom} ${b.right - 26} ${b.bottom} '
        'H${b.left + 26} Q${b.left} ${b.bottom} ${b.left} ${b.bottom - 24} Z',
      ),
      band,
    );
    canvas.drawRect(Rect.fromLTWH(b.left, b.top, b.width, 5), light);
    if (shape == ThermosShape.slim) {
      canvas.drawPath(
        _p('M300 92 Q300 40 340 40 Q380 40 380 92'),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..color = theme.band,
      );
    }
  }

  void _marks(Canvas canvas, _Geometry geo) {
    final line = Paint()..color = theme.mark;
    for (var ml = 250; ml <= goalMl; ml += 250) {
      final y = geo.bottom - (ml / goalMl) * (geo.bottom - geo.top);
      final big = ml % 500 == 0;
      canvas.drawLine(
        Offset(geo.markRight - (big ? 26 : 14), y),
        Offset(geo.markRight, y),
        line..strokeWidth = big ? 2 : 1.2,
      );
      if (big) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${_liters(ml)} L',
            style: TextStyle(
              color: theme.label,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(geo.labelX, y - tp.height / 2));
      }
    }
  }

  static String _liters(int ml) {
    final l = ml / 1000;
    final s = l == l.roundToDouble() ? l.toStringAsFixed(0) : l.toString();
    return s.replaceAll('.', ',');
  }

  void _classicCap(Canvas canvas) {
    final base = Paint()..color = const Color(0xFF888780);
    final hi = Paint()..color = const Color(0xFFD3D1C7);
    final lo = Paint()..color = const Color(0xFF5F5E5A);
    final ridge = Paint()..color = const Color(0xFFB4B2A9);
    if (shape == ThermosShape.chubby) {
      canvas.drawPath(
        _p(
          'M262 204 L262 110 Q262 66 306 62 L374 62 Q418 66 418 110 L418 204 Z',
        ),
        base,
      );
      canvas.drawPath(
        _p('M262 204 L262 110 Q262 70 296 63 Q280 84 280 114 L280 204 Z'),
        hi,
      );
      canvas.drawPath(_p('M394 66 Q418 76 418 110 L418 204 L400 204 Z'), lo);
      for (var i = 0; i < 11; i++) {
        canvas.drawRect(Rect.fromLTWH(290 + i * 10.0, 70, 3, 130), ridge);
      }
    } else {
      canvas.drawPath(
        _p(
          'M284 164 L284 116 Q284 92 310 90 L370 90 Q396 92 396 116 L396 164 Z',
        ),
        base,
      );
      canvas.drawPath(
        _p('M284 164 L284 116 Q284 94 302 91 Q296 104 296 120 L296 164 Z'),
        hi,
      );
      canvas.drawPath(_p('M380 92 Q396 96 396 116 L396 164 L384 164 Z'), lo);
      for (var i = 0; i < 8; i++) {
        canvas.drawRect(Rect.fromLTWH(304 + i * 10.0, 98, 3, 62), ridge);
      }
    }
  }

  @override
  bool shouldRepaint(ThermosPainter old) =>
      old.level != level ||
      old.time != time ||
      old.slosh != slosh ||
      old.shape != shape ||
      old.theme != theme ||
      old.goalMl != goalMl;
}
