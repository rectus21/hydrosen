import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'svg_path.dart';
import 'thermos_painter.dart';
import 'thermos_theme.dart';

/// Hedefe ulaşınca termos kartının üstünde oynayan, temaya özgü kutlama.
/// [ThermosPainter] ile aynı tasarım koordinatlarını kullanır; böylece
/// parçacıklar kapağa ve arka plana göre doğru yere düşer.
///
/// Temalar (Termos-ve-Temalar.md fikir notundan):
/// - Klasik: termosun çevresinde genişleyen su damlası halkası.
/// - Çilek: yükselen kalpler.
/// - Kaplan: kükreme dalgaları ve turuncu-siyah konfeti.
/// - Panda: süzülen bambu yaprakları (panda kapakta güler).
/// - Tekboynuz: boynuz parlar, gökkuşağı yıldız tozu.
/// - Astronot: kaskın vizöründe kayan "TEBRİKLER!" yazısı ve yıldızlar.
/// - Botanik: süzülen yapraklar ve küçük beyaz çiçekler.
/// - Kamp: pusula iğnesi döner, güneş ışınları parlar, kıvılcımlar yükselir.
class CelebrationPainter extends CustomPainter {
  CelebrationPainter({
    required this.theme,
    required this.shape,
    required this.t,
  });

  final ThermosTheme theme;
  final ThermosShape shape;

  /// Kutlamanın ilerlemesi, 0..1.
  final double t;

  bool get _chubby => shape == ThermosShape.chubby;

  /// Başta hızlı belirir, sonda yumuşakça söner.
  double get _alpha {
    if (t < 0.08) return t / 0.08;
    if (t > 0.8) return ((1 - t) / 0.2).clamp(0.0, 1.0);
    return 1;
  }

  /// Parçacık başına sabit, tekrarlanabilir "rastgele" değer (0..1).
  static double _r(int i, int salt) {
    final v = math.sin(i * 127.1 + salt * 311.7) * 43758.5453;
    return v - v.floorToDouble();
  }

  Paint _paint(int hex, [double op = 1]) =>
      Paint()
        ..color = Color(0xFF000000 | hex)
            .withValues(alpha: (op * _alpha).clamp(0.0, 1.0));

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
    canvas.clipRRect(
      RRect.fromRectAndRadius(designRect, const Radius.circular(24)),
    );
    switch (theme.id) {
      case 'cilek':
        _hearts(canvas);
      case 'kaplan':
        _roar(canvas);
        _confetti(canvas, const [0xEF9F27, 0xBA7517, 0x2C2C2A, 0xFAC775]);
      case 'panda':
        _falling(canvas, const [0x1D9E75, 0x97C459, 0x639922], flowers: false);
      case 'tekboynuz':
        _hornGlow(canvas);
        _stardust(canvas);
      case 'astronot':
        _twinkles(canvas);
        _visorText(canvas);
      case 'botanik':
        _falling(canvas, const [0x3B6D11, 0x639922, 0x97C459], flowers: true);
      case 'kamp':
        _sunRays(canvas);
        _embers(canvas);
        _compassSpin(canvas);
      default:
        _dropletRing(canvas);
    }
    canvas.restore();
  }

  // --- Klasik ---------------------------------------------------------------

  void _dropletRing(Canvas canvas) {
    const n = 14;
    final e = Curves.easeOutCubic.transform(t);
    for (var ring = 0; ring < 2; ring++) {
      final radius = 40 + e * (170 + ring * 50);
      for (var i = 0; i < n; i++) {
        final a = (i + ring * 0.5) / n * 2 * math.pi + t * 0.6;
        final c = Offset(
          340 + math.cos(a) * radius,
          320 + math.sin(a) * radius,
        );
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(a + math.pi / 2);
        // Damla: sivri ucu dışarı bakar.
        final s = 1.0 - ring * 0.25;
        canvas.drawPath(
          Path()
            ..moveTo(0, -12 * s)
            ..quadraticBezierTo(8 * s, 0, 0, 6 * s)
            ..quadraticBezierTo(-8 * s, 0, 0, -12 * s)
            ..close(),
          _paint(ring == 0 ? 0x378ADD : 0x85B7EB, 0.9),
        );
        canvas.restore();
      }
    }
  }

  // --- Çilek ----------------------------------------------------------------

  void _hearts(Canvas canvas) {
    const colors = [0xE24B4A, 0xED93B1, 0xD4537E, 0xF09595];
    for (var i = 0; i < 16; i++) {
      final delay = _r(i, 1) * 0.35;
      final p = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final x = 140 + _r(i, 2) * 400 + math.sin(p * 6 + i) * 14;
      final y = 520 - p * (300 + _r(i, 3) * 200);
      final s = 8 + _r(i, 4) * 8;
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(s / 10);
      canvas.drawPath(
        Path()
          ..moveTo(0, 8)
          ..cubicTo(-12, 0, -10, -10, 0, -4)
          ..cubicTo(10, -10, 12, 0, 0, 8)
          ..close(),
        _paint(colors[i % colors.length], 0.9),
      );
      canvas.restore();
    }
  }

  // --- Kaplan ---------------------------------------------------------------

  void _roar(Canvas canvas) {
    final cy = _chubby ? 170.0 : 140.0;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final p = ((t * 2.2 - i * 0.25) % 1.0).clamp(0.0, 1.0);
      if (t > 0.7) break;
      final r = 30 + p * 70;
      final op = (1 - p) * 0.8;
      for (final side in const [-1, 1]) {
        final cx = 340.0 + side * (_chubby ? 100 : 56);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          side > 0 ? -0.6 : math.pi - 0.6,
          1.2,
          false,
          stroke
            ..strokeWidth = 4
            ..color = _paint(0xBA7517, op).color,
        );
      }
    }
  }

  void _confetti(Canvas canvas, List<int> colors) {
    final origin = Offset(340, _chubby ? 110 : 120);
    for (var i = 0; i < 30; i++) {
      final ang = -math.pi / 2 + (_r(i, 5) - 0.5) * 2.4;
      final speed = 240 + _r(i, 6) * 220;
      final x = origin.dx + math.cos(ang) * speed * t;
      final y = origin.dy + math.sin(ang) * speed * t + 520 * t * t;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 12 * (_r(i, 7) - 0.5));
      canvas.drawRect(
        const Rect.fromLTWH(-5, -3, 10, 6),
        _paint(colors[i % colors.length]),
      );
      canvas.restore();
    }
  }

  // --- Panda, Botanik --------------------------------------------------------

  void _falling(Canvas canvas, List<int> colors, {required bool flowers}) {
    for (var i = 0; i < 18; i++) {
      final delay = _r(i, 8) * 0.3;
      final p = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final x = 130 + _r(i, 9) * 420 + math.sin(p * 7 + i) * 22;
      final y = -10 + p * (380 + _r(i, 10) * 140);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(math.sin(p * 5 + i) * 0.9);
      if (flowers && i % 4 == 0) {
        for (var k = 0; k < 5; k++) {
          final a = k * 2 * math.pi / 5;
          canvas.drawCircle(
            Offset(math.cos(a) * 5, math.sin(a) * 5),
            4,
            _paint(0xFFFFFF),
          );
        }
        canvas.drawCircle(Offset.zero, 3, _paint(0xFAC775));
      } else {
        canvas.drawOval(
          const Rect.fromLTWH(-12, -4, 24, 8),
          _paint(colors[i % colors.length], 0.95),
        );
      }
      canvas.restore();
    }
  }

  // --- Tekboynuz -------------------------------------------------------------

  void _hornGlow(Canvas canvas) {
    final tip = Offset(340, _chubby ? 30 : 60);
    final pulse = 0.6 + 0.4 * math.sin(t * math.pi * 6);
    canvas.drawCircle(
      tip,
      26 + pulse * 10,
      _paint(0xFAC775, 0.35 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(tip, 6, _paint(0xFFFFFF, 0.9 * pulse));
  }

  static const _rainbow = [
    0xE24B4A,
    0xEF9F27,
    0xFAC775,
    0x97C459,
    0x85B7EB,
    0xAFA9EC,
  ];

  void _stardust(Canvas canvas) {
    final origin = Offset(340, _chubby ? 30 : 60);
    for (var i = 0; i < 26; i++) {
      final delay = _r(i, 11) * 0.3;
      final p = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final ang = math.pi * (0.1 + _r(i, 12) * 0.8);
      final dist = p * (140 + _r(i, 13) * 160);
      final x = origin.dx + math.cos(ang) * dist * (i.isEven ? 1 : -1);
      final y = origin.dy + math.sin(ang) * dist * 0.9 + p * p * 120;
      final twinkle = 0.6 + 0.4 * math.sin(p * 20 + i);
      _star(
        canvas,
        Offset(x, y),
        (5 + _r(i, 14) * 5) * twinkle,
        _rainbow[i % _rainbow.length],
      );
    }
  }

  void _star(Canvas canvas, Offset c, double r, int hex, [double op = 1]) {
    final path = Path();
    for (var k = 0; k < 8; k++) {
      final a = k * math.pi / 4 - math.pi / 2;
      final rr = k.isEven ? r : r * 0.35;
      final pt = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      k == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path..close(), _paint(hex, op));
  }

  // --- Astronot --------------------------------------------------------------

  void _twinkles(Canvas canvas) {
    for (var i = 0; i < 14; i++) {
      final x = 140 + _r(i, 15) * 400;
      final y = 20 + _r(i, 16) * 460;
      final tw = math.max(0.0, math.sin(t * math.pi * 4 + i * 1.3));
      _star(canvas, Offset(x, y), 4 + tw * 6, 0xFFFFFF, tw);
    }
  }

  void _visorText(Canvas canvas) {
    final visor = _chubby ? _visorChubby : _visorSlim;
    final b = visor.getBounds();
    final tp = TextPainter(
      text: TextSpan(
        text: 'TEBRİKLER! HEDEFE ULAŞTIN!',
        style: TextStyle(
          color: const Color(0xFF5DCAA5).withValues(alpha: _alpha),
          fontSize: _chubby ? 22 : 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.clipPath(visor);
    // Kayan yazı: sağdan girer, sola doğru akar.
    final x = b.right - t * (b.width + tp.width) * 1.05;
    tp.paint(canvas, Offset(x, b.center.dy - tp.height / 2));
    canvas.restore();
  }

  static final _visorChubby = svgPath(visorChubby);
  static final _visorSlim = svgPath(visorSlim);

  // --- Kamp ------------------------------------------------------------------

  void _sunRays(Canvas canvas) {
    const c = Offset(440, 150); // arka plandaki güneş
    final grow = Curves.easeOutBack.transform(math.min(1, t * 2.5));
    final ray = Paint()
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = _paint(0xEF9F27, 0.8).color;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6 + t * 1.5;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * 56,
        c + Offset(math.cos(a), math.sin(a)) * (56 + 26 * grow),
        ray,
      );
    }
    canvas.drawCircle(c, 50, _paint(0xFAC775, 0.35));
  }

  void _embers(Canvas canvas) {
    const colors = [0xEF9F27, 0xE24B4A, 0xFAC775];
    for (var i = 0; i < 18; i++) {
      final delay = _r(i, 17) * 0.4;
      final p = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final x = 160 + _r(i, 18) * 360 + math.sin(p * 9 + i) * 10;
      final y = 500 - p * (260 + _r(i, 19) * 120);
      canvas.drawCircle(
        Offset(x, y),
        2.5 + _r(i, 20) * 2.5,
        _paint(colors[i % colors.length], 1 - p * 0.6),
      );
    }
  }

  void _compassSpin(Canvas canvas) {
    final c = Offset(340, _chubby ? 118 : 122);
    final r = _chubby ? 30.0 : 16.0;
    // İğne hızla döner, sonunda kuzeyi gösterip durur.
    final angle = Curves.easeOutCubic.transform(t) * math.pi * 6;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.drawCircle(
      Offset.zero,
      r * 0.8,
      Paint()..color = const Color(0xFF2C2C2A),
    );
    canvas.rotate(angle);
    canvas.drawPath(
      Path()
        ..moveTo(0, -r * 0.67)
        ..lineTo(r * 0.2, 0)
        ..lineTo(0, r * 0.67)
        ..lineTo(-r * 0.2, 0)
        ..close(),
      Paint()..color = const Color(0xFFE24B4A),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(r * 0.2, 0)
        ..lineTo(0, r * 0.67)
        ..lineTo(-r * 0.2, 0)
        ..close(),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(CelebrationPainter old) =>
      old.t != t || old.theme != theme || old.shape != shape;
}
