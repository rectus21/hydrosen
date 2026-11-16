import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'art.dart';
import 'celebrations/celebration_context.dart';
import 'svg_path.dart';
import 'thermos_theme.dart';

/// Taslaklardaki koordinat sistemi: 680x520 tuvalin arka plan kartı.
const designRect = Rect.fromLTWH(120, 8, 440, 504);

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
    required this.halfWidth,
  });

  final String body;
  final double top, bottom, markRight, labelX, shadowRx, shineLeft, shadeRight;

  /// Gövdenin yarı genişliği (merkez x = 340); dalga biçimi buna göre ölçeklenir.
  final double halfWidth;
  final Rect neck, base;

  static const chubby = _Geometry(
    body: 'M312 200 Q278 206 274 252 L274 428 Q274 476 316 478 L364 478 Q406 476 406 428 L406 252 Q402 206 368 200 Z',
    top: 222,
    bottom: 450,
    markRight: 386,
    labelX: 416,
    neck: Rect.fromLTRB(306, 182, 374, 204),
    base: Rect.fromLTRB(274, 452, 406, 478),
    shadowRx: 72,
    shineLeft: 284,
    shadeRight: 394,
    halfWidth: 66,
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
    halfWidth: 50,
  );
}

/// Tombul kapakların boyun genişliğine göre ölçeği.
const chubbyCapScale = 0.72;

/// Termosu, suyu, litre çizgilerini ve kapağı çizer.
class ThermosPainter extends CustomPainter {
  ThermosPainter({
    required this.shape,
    required this.theme,
    required this.level,
    required this.goalMl,
    required this.time,
    required this.slosh,
    this.tilt = 0,
    this.wave = 0,
    this.happy = false,
    this.labelStyle,
    this.capPose = CapPose.identity,
  });

  final ThermosShape shape;
  final ThermosTheme theme;

  /// 0..1 arası doluluk.
  final double level;
  final int goalMl;

  /// Saniye cinsinden dalga zamanı.
  final double time;

  /// Yüzeydeki küçük dalgacıkların ek şiddeti (0 = sakin); çalkalanırken artar.
  final double slosh;

  /// Yüzey eğimi (radyan, pozitif: sağ taraf yüksek); bkz. SloshModel.
  final double tilt;

  /// Ortası inip kalkan duran dalganın genliği (tasarım birimi).
  final double wave;

  /// Hedefe ulaşıldı mı (kapak ifadesi; kutlama adımında kullanılacak).
  final bool happy;

  /// Ölçek yazılarının taban stili (temanın yazı tipi); renk ve boyut
  /// termos temasından gelir.
  final TextStyle? labelStyle;

  /// Kutlama sırasında imza animasyonunun kapağa uyguladığı hareket.
  final CapPose capPose;

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

    // Arka plan burada çizilmez: sahne tüm ekranı kaplar (ThemeScene).

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
      // Eğim ve duran dalga merkez etrafında simetrik olduğundan su hacmi
      // korunur; gövdeye kırpıldığı için su hiçbir zaman camdan taşmaz.
      final slope = math.tan(tilt.clamp(-0.5, 0.5));
      final k = math.pi / geo.halfWidth;
      double waveY(double x) {
        final u = (x - 340).clamp(-geo.halfWidth, geo.halfWidth);
        return lvl -
            slope * u +
            wave * math.cos(k * u) +
            math.sin(x / 18 + time * 2.5) * amp;
      }

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
    final cap = shape == ThermosShape.chubby ? theme.capChubby : theme.capSlim;
    final posed = !capPose.isIdentity;
    if (posed) {
      final pivotY = shape == ThermosShape.chubby ? 208.0 : 178.0;
      canvas.save();
      canvas.translate(340 + capPose.dx, pivotY + capPose.dy);
      canvas.rotate(capPose.rotation);
      canvas.scale(capPose.scale);
      canvas.translate(-340, -pivotY);
    }
    if (shape == ThermosShape.chubby) {
      // Kapaklar geniş boyun için çizildi; ince termos boynuna uyması için
      // alt-orta noktası (340, 208) etrafında küçültülür.
      canvas.save();
      canvas.translate(340, 208);
      canvas.scale(chubbyCapScale);
      canvas.translate(-340, -208);
      cap(Art(canvas), happy);
      canvas.restore();
    } else {
      cap(Art(canvas), happy);
    }
    if (posed) canvas.restore();
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
      canvas.drawPath(
        _p('M304 90 Q304 48 340 48'),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = theme.bandLight,
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
            style: (labelStyle ?? const TextStyle()).copyWith(
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

  @override
  bool shouldRepaint(ThermosPainter old) =>
      old.level != level ||
      old.time != time ||
      old.slosh != slosh ||
      old.tilt != tilt ||
      old.wave != wave ||
      old.shape != shape ||
      old.theme != theme ||
      old.happy != happy ||
      old.capPose != capPose ||
      old.goalMl != goalMl ||
      old.labelStyle != labelStyle;
}
