import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import '../celebration_style.dart';
import 'celebration_context.dart';

// Yeşil Elma ve spor temalarının (futbol, basketbol, voleybol) kutlamaları.
// Hepsi kodla çizilir; topu/elmayı sahnenin zeminine (y~458) ve hedefe
// (kale, pota, kum) yerleştirir. Giriş ~2.5 sn sürer ve sonunda her şey bir
// yerde durur; döngü evresi sakin, tam periyodiktir (loop 0..1). Hareket
// azaltılmışken sabit, bitmiş bir kare çizilir.

const Map<String, SignatureCelebration> sportsCelebrations = {
  'yesilelma': _elma,
  'futbol': _futbol,
  'basketbol': _basket,
  'voleybol': _voley,
  'eczaci': _eczaci,
  'karaejderha': _kara,
  'yarisarabasi': _yaris,
};

const Map<String, SignatureCelebration> sportsLoops = {
  'yesilelma': _elmaLoop,
  'futbol': _futbolLoop,
  'basketbol': _basketLoop,
  'voleybol': _voleyLoop,
  'eczaci': _eczaciLoop,
  'karaejderha': _karaLoop,
  'yarisarabasi': _yarisLoop,
};

const Map<String, CapPoseFn> sportsCapPoses = {
  'yesilelma': _elmaPose,
  'futbol': _futbolPose,
  'basketbol': _basketPose,
  'voleybol': _voleyPose,
  'eczaci': _eczaciPose,
  'karaejderha': _karaPose,
  'yarisarabasi': _yarisPose,
};

const Map<String, CapPoseFn> sportsLoopPoses = {
  'yesilelma': _elmaLoopPose,
  'futbol': _futbolLoopPose,
  'basketbol': _basketLoopPose,
  'voleybol': _voleyLoopPose,
  'eczaci': _eczaciLoopPose,
  'karaejderha': _karaLoopPose,
  'yarisarabasi': _yarisLoopPose,
};

const _tau = math.pi * 2;

/// Kapak geometrisi: kapağın (poz uygulanmamış) merkezi ve genişliği. Toplar
/// kapak genişliğinin ~0.4'ü kadardır; zemin termosun alt çizgisidir.
class _G {
  _G(CelebrationContext c)
    : head = c.capCenter - Offset(c.pose.dx, c.pose.dy),
      w = c.capWidth / c.pose.scale;
  final Offset head;
  final double w;
  double get r => w * 0.2;
  double get ground => 470 - r;
}

const _minX = 168.0, _maxX = 512.0, _minY = 76.0;

double _sp(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
double _eo(double x) => Curves.easeOutCubic.transform(x.clamp(0.0, 1.0));
double _hump(double x) => math.sin(x.clamp(0.0, 1.0) * math.pi);
double _lerp(double a, double b, double x) => a + (b - a) * x;
double _fract(double x) => x - x.floorToDouble();

/// Giriş ilerlemesi 0..1 (hareket azaltılmışken bitmiş kare).
double _ti(CelebrationContext c) => c.reduceMotion ? 0.72 : c.t;

/// Döngü fazı 0..1 (hareket azaltılmışken sabit).
double _lp(CelebrationContext c) => c.reduceMotion ? 0.25 : c.loop;

Paint _fill(CelebrationContext c, int hex, [double op = 1]) =>
    c.paintOf(hex, op);

Paint _line(CelebrationContext c, int hex, double w, [double op = 1]) =>
    c.paintOf(hex, op)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

// --- Ortak çizimler ----------------------------------------------------------

enum _Ball { soccer, basket, volley, apple }

void _ball(
  Canvas cv,
  CelebrationContext c,
  _Ball kind,
  Offset p,
  double r, {
  double rot = 0,
  double op = 1,
}) {
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  // Gölge yok: top zeminde dururken hafif koyu halka yeterli.
  final base = switch (kind) {
    _Ball.soccer => 0xFFFFFF,
    _Ball.basket => 0xF28A2E,
    _Ball.volley => 0xFFFFFF,
    _Ball.apple => 0x8CCB4E,
  };
  cv.drawCircle(Offset.zero, r, _fill(c, base, op));
  cv.save();
  cv.clipPath(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r)));
  switch (kind) {
    case _Ball.soccer:
      final pent = Path();
      for (var i = 0; i < 5; i++) {
        final a = -math.pi / 2 + i * _tau / 5;
        final q = Offset(math.cos(a), math.sin(a)) * (r * 0.36);
        i == 0 ? pent.moveTo(q.dx, q.dy) : pent.lineTo(q.dx, q.dy);
      }
      pent.close();
      cv.drawPath(pent, _fill(c, 0x2C2C2A, op));
      for (var i = 0; i < 5; i++) {
        final a = -math.pi / 2 + i * _tau / 5;
        final d = Offset(math.cos(a), math.sin(a));
        cv.drawLine(d * (r * 0.4), d * (r * 0.72), _line(c, 0x2C2C2A, r * 0.08, op));
        final a2 = a + _tau / 10;
        cv.drawCircle(
          Offset(math.cos(a2), math.sin(a2)) * (r * 1.0),
          r * 0.26,
          _fill(c, 0x2C2C2A, op),
        );
      }
    case _Ball.basket:
      final s = _line(c, 0x3A2412, r * 0.12, op);
      cv.drawLine(Offset(-r, 0), Offset(r, 0), s);
      cv.drawLine(Offset(0, -r), Offset(0, r), s);
      cv.drawArc(
        Rect.fromCenter(center: Offset(-r * 1.15, 0), width: r * 1.6, height: r * 2.4),
        -1.1,
        2.2,
        false,
        s,
      );
      cv.drawArc(
        Rect.fromCenter(center: Offset(r * 1.15, 0), width: r * 1.6, height: r * 2.4),
        math.pi - 1.1,
        2.2,
        false,
        s,
      );
    case _Ball.volley:
      final blue = _line(c, 0x3DB3E8, r * 0.55, op);
      final yellow = _line(c, 0xF7C93A, r * 0.55, op);
      cv.drawPath(
        Path()
          ..moveTo(-r, -r * 0.45)
          ..quadraticBezierTo(0, -r * 1.25, r, -r * 0.1),
        blue,
      );
      cv.drawPath(
        Path()
          ..moveTo(-r, r * 0.55)
          ..quadraticBezierTo(0, -r * 0.35, r, r * 0.6),
        yellow,
      );
    case _Ball.apple:
      cv.drawCircle(
        Offset(-r * 0.35, -r * 0.4),
        r * 0.28,
        _fill(c, 0xE6F8C4, 0.8 * op),
      );
  }
  cv.restore();
  final edge = kind == _Ball.apple ? 0x4E9A2E : 0x2C2C2A;
  cv.drawCircle(Offset.zero, r, _line(c, edge, r * 0.13, op));
  if (kind == _Ball.apple) {
    cv.drawLine(
      Offset(0, -r * 0.9),
      Offset(r * 0.18, -r * 1.45),
      _line(c, 0x6B4A2B, r * 0.18, op),
    );
    final leaf = Path()
      ..moveTo(r * 0.12, -r * 1.2)
      ..quadraticBezierTo(r * 0.7, -r * 1.85, r * 1.25, -r * 1.35)
      ..quadraticBezierTo(r * 0.7, -r * 0.85, r * 0.12, -r * 1.2);
    cv.drawPath(leaf, _fill(c, 0x4E9A2E, op));
  }
  cv.restore();
}

final _tpCache = <String, TextPainter>{};

/// Konuşma balonu: [at] merkez, [scale] 0..1.1 (büyüyerek belirir).
void _bubble(
  Canvas cv,
  CelebrationContext c,
  String text,
  Offset at,
  double scale,
  int ink, {
  double tailDx = 0,
  int fillHex = 0xFFFFFF,
}) {
  if (scale <= 0.02) return;
  final bucket = (c.alpha.clamp(0.0, 1.0) * 8).round();
  if (bucket <= 0) return;
  final tp = _tpCache.putIfAbsent('$text|$ink|$bucket|$fillHex', () {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Color(0xFF000000 | ink).withValues(alpha: bucket / 8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  });
  final w = tp.width + 30, h = tp.height + 10;
  at = Offset(
    at.dx.clamp(_minX + w * scale / 2, _maxX - w * scale / 2),
    math.max(at.dy, _minY + h * scale / 2),
  );
  cv.save();
  cv.translate(at.dx, at.dy);
  cv.scale(scale);
  final body = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset.zero, width: w, height: h),
    const Radius.circular(16),
  );
  final tail = Path()
    ..moveTo(-8, h / 2 - 2)
    ..lineTo(tailDx, h / 2 + 16)
    ..lineTo(8, h / 2 - 2)
    ..close();
  cv.drawPath(tail, _fill(c, fillHex));
  cv.drawRRect(body, _fill(c, fillHex));
  cv.drawRRect(body, _line(c, ink, 3));
  cv.drawPath(tail, _line(c, ink, 3));
  // Kuyruğun gövdeyle birleşen çizgisini sil.
  cv.drawLine(
    Offset(-6, h / 2),
    Offset(6, h / 2),
    _line(c, fillHex, 4),
  );
  tp.paint(cv, Offset(-tp.width / 2, -tp.height / 2));
  cv.restore();
}

/// Işın patlaması (vuruş/smaç anı).
void _burst(Canvas cv, CelebrationContext c, Offset at, double k, int a, int b,
    double size) {
  if (k <= 0 || k >= 1) return;
  final e = _eo(k);
  for (var i = 0; i < 12; i++) {
    final ang = i * _tau / 12 + 0.2;
    final d = Offset(math.cos(ang), math.sin(ang));
    cv.drawLine(
      at + d * (size * 0.35 + size * 0.5 * e),
      at + d * (size * 0.35 + size * (0.5 + 0.35 * (1 - k)) * e),
      _line(c, i.isEven ? a : b, 4, 1 - k),
    );
  }
  cv.drawCircle(at, size * 0.6 * e, _line(c, 0xFFFFFF, 4 * (1 - k), 0.9 * (1 - k)));
}

void _glint(Canvas cv, CelebrationContext c, Offset p, double r, int hex,
    double op) {
  if (op <= 0.03 || r <= 0.5) return;
  final q = r * 0.16;
  final path = Path()
    ..moveTo(0, -r)
    ..quadraticBezierTo(q, -q, r, 0)
    ..quadraticBezierTo(q, q, 0, r)
    ..quadraticBezierTo(-q, q, -r, 0)
    ..quadraticBezierTo(-q, -q, 0, -r)
    ..close();
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.drawPath(path, _fill(c, hex, op));
  cv.drawCircle(Offset.zero, r * 0.18, _fill(c, 0xFFFFFF, op));
  cv.restore();
}

/// Tekrarlı zıplama: 0 = yerde, 1 = en yukarıda.
double _bounceH(double x) => math.sin(x * math.pi).abs();

CapPose _loopBounce(CelebrationContext c, double n, double h, double sway) {
  if (c.reduceMotion) return CapPose.identity;
  final b = _bounceH(_lp(c) * n);
  return CapPose(
    dy: -h * b,
    scale: 1 - 0.035 * (1 - b),
    rotation: sway * math.sin(_lp(c) * _tau * (n / 2)),
  );
}

// ============================================================ YEŞİL ELMA ===

const _elmaDrop = <List<double>>[
  // x0, gecikme(sn), yön
  [205, 0.15, -1],
  [250, 0.45, 1],
  [440, 0.3, -1],
  [485, 0.6, 1],
];

CapPose _elmaPose(CelebrationContext c) {
  final t = c.t;
  final a = _hump(_sp(t, 0.12, 0.26));
  final b = _hump(_sp(t, 0.28, 0.4));
  return CapPose(dy: -12 * a - 8 * b, rotation: 0.05 * (a - b));
}

CapPose _elmaLoopPose(CelebrationContext c) => _loopBounce(c, 2, 9, 0.03);

void _leaf(Canvas cv, CelebrationContext c, Offset p, double s, double rot,
    int hex, double op) {
  if (op <= 0.02) return;
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  final path = Path()
    ..moveTo(-s, 0)
    ..quadraticBezierTo(0, -s * 0.8, s, 0)
    ..quadraticBezierTo(0, s * 0.8, -s, 0);
  cv.drawPath(path, _fill(c, hex, op));
  cv.drawLine(Offset(-s, 0), Offset(s * 0.7, 0), _line(c, 0x2F6B1F, 1.8, 0.7 * op));
  cv.restore();
}

const _leafColors = [0x7CC243, 0xA8DB6A, 0x4E9A2E, 0x9AD25E];
const _leafY0 = 82.0;

void _elma(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final el = c.reduceMotion ? 2.4 : c.elapsed;
  if (!c.reduceMotion) {
    for (var i = 0; i < 26; i++) {
      final tau = el - 0.05 - c.rand(i, 1) * 1.0;
      if (tau < 0) continue;
      final y = _leafY0 + 170 * tau;
      if (y > g.ground + 20) continue;
      final x = 185 + c.rand(i, 2) * 310 + 16 * math.sin(tau * 3 + i);
      final fade = math.min(
        ((y - _leafY0) / 24).clamp(0.0, 1.0),
        ((g.ground + 20 - y) / 40).clamp(0.0, 1.0),
      );
      _leaf(cv, c, Offset(x, y), 12 + 5 * c.rand(i, 3),
          tau * 2.5 + i + math.sin(tau * 4) * 0.5, _leafColors[i % 4], fade);
    }
  }
  _appleDrop(cv, c, g, el);
}

void _appleDrop(Canvas cv, CelebrationContext c, _G g, double el) {
  final r = g.r * 0.8;
  final gy = 470 - r;
  for (var i = 0; i < _elmaDrop.length; i++) {
    final d = _elmaDrop[i];
    final tau = el - d[1];
    if (tau < 0) continue;
    const fall = 0.6;
    double y;
    if (tau < fall) {
      final u = tau / fall;
      y = _lerp(_leafY0, gy, u * u);
    } else if (tau < 1.0) {
      final v = (tau - fall) / 0.4;
      y = gy - 55 * 4 * v * (1 - v);
    } else if (tau < 1.3) {
      final v = (tau - 1.0) / 0.3;
      y = gy - 18 * 4 * v * (1 - v);
    } else {
      y = gy;
    }
    final roll = _eo((tau - fall) / 1.3) * 18 * d[2];
    final op = (tau / 0.12).clamp(0.0, 1.0);
    _ball(cv, c, _Ball.apple, Offset(d[0] + roll, y), r,
        rot: roll / r + (tau < fall ? tau * 4 * d[2] : 0), op: op);
  }
}

void _elmaLoop(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final l = _lp(c);
  for (var i = 0; i < 10; i++) {
    final k = _fract(l + i / 10);
    final y = _leafY0 + k * (g.ground - _leafY0);
    final x = 190 + (i * 97 % 300) + 16 * math.sin(k * _tau * 2 + i);
    _leaf(cv, c, Offset(x, y), 12 + (i % 3) * 2,
        k * _tau * 1.5 + i + 0.5 * math.sin(k * _tau * 3),
        _leafColors[i % 4], _hump(k) * 0.95);
  }
  final r = g.r * 0.8;
  final wob = math.sin(l * _tau) * 0.06;
  for (var i = 0; i < _elmaDrop.length; i++) {
    final d = _elmaDrop[i];
    _ball(cv, c, _Ball.apple, Offset(d[0] + 18 * d[2], 470 - r), r,
        rot: wob * d[2] * (i.isEven ? 1 : -1));
  }
}

// ================================================================= FUTBOL ===

CapPose _futbolPose(CelebrationContext c) {
  final a = _hump(_sp(c.t, 0.3, 0.46));
  final b = _hump(_sp(c.t, 0.44, 0.6));
  return CapPose(dy: -10 * a - 6 * b, rotation: 0.06 * (a - b), scale: 1 - 0.03 * a);
}

CapPose _futbolLoopPose(CelebrationContext c) => _loopBounce(c, 3, 15, 0.05);

void _futbol(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final t = _ti(c);
  final hitP = Offset(g.head.dx - g.w * 0.5 - g.r * 0.5, g.head.dy + g.w * 0.05);
  const restX = 215.0;
  Offset p;
  var rot = 0.0;
  if (t < 0.3) {
    final u = _sp(t, 0.04, 0.3);
    p = Offset(
      _lerp(200, hitP.dx, u),
      _lerp(g.ground, hitP.dy, _eo(u)) - 40 * 4 * u * (1 - u),
    );
    rot = u * 6;
  } else {
    final u = _sp(t, 0.3, 0.7);
    double y;
    if (u < 0.55) {
      final v = u / 0.55;
      y = _lerp(hitP.dy, g.ground, v * v);
    } else if (u < 0.85) {
      final v = (u - 0.55) / 0.3;
      y = g.ground - 50 * 4 * v * (1 - v);
    } else {
      y = g.ground;
    }
    p = Offset(_lerp(hitP.dx, restX, _eo(u)), y);
    rot = 6 - u * 8;
  }
  _burst(cv, c, hitP, _sp(t, 0.3, 0.45), 0xFFFFFF, 0x3FAE4A, g.r * 2);
  _ball(cv, c, _Ball.soccer, p, g.r, rot: rot);
  _bubble(
    cv,
    c,
    'GOL!',
    Offset(g.head.dx + g.w * 0.62, g.head.dy - g.w * 0.12),
    _back(_sp(t, 0.32, 0.46)),
    0x1F7A2E,
    tailDx: -22,
  );
  if (!c.reduceMotion) {
    c.kind(cv, CelebrationKind.confetti, const [0x3FAE4A, 0xFFFFFF, 0x1F7A2E]);
  }
}

void _futbolLoop(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final b = _bounceH(_lp(c) * 3);
  _ball(cv, c, _Ball.soccer, Offset(215, g.ground - 150 * b), g.r,
      rot: _lp(c) * _tau * 3);
}

double _back(double x) => Curves.easeOutBack.transform(x.clamp(0.0, 1.0));

// =============================================================== BASKETBOL ===

CapPose _basketPose(CelebrationContext c) {
  final a = _hump(_sp(c.t, 0.4, 0.56));
  final b = _hump(_sp(c.t, 0.54, 0.7));
  return CapPose(dy: -10 * a - 6 * b, rotation: -0.05 * (a - b));
}

CapPose _basketLoopPose(CelebrationContext c) => _loopBounce(c, 2, 14, 0.03);

void _basket(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final t = _ti(c);
  const dropX = 470.0;
  final passY = g.head.dy + g.w * 0.4;
  Offset p;
  var rot = 0.0;
  if (t < 0.42) {
    final u = _sp(t, 0.04, 0.42);
    final baseMid = (g.ground + passY) / 2;
    final h = math.max(60.0, baseMid - 112);
    p = Offset(
      _lerp(200, dropX, u),
      _lerp(g.ground, passY, u) - h * 4 * u * (1 - u),
    );
    rot = u * 9;
  } else {
    final u = _sp(t, 0.42, 0.78);
    double y;
    if (u < 0.5) {
      final v = u / 0.5;
      y = _lerp(passY, g.ground, v * v);
    } else if (u < 0.8) {
      final v = (u - 0.5) / 0.3;
      y = g.ground - 36 * 4 * v * (1 - v);
    } else {
      y = g.ground;
    }
    p = Offset(dropX + 4 * u, y);
    rot = 9 + u * 3;
  }
  // Swish halkaları.
  final k = _sp(t, 0.4, 0.7);
  if (k > 0 && k < 1 && !c.reduceMotion) {
    for (var i = 0; i < 3; i++) {
      final kk = (k - i * 0.14).clamp(0.0, 1.0);
      if (kk <= 0 || kk >= 1) continue;
      cv.drawOval(
        Rect.fromCenter(
          center: Offset(dropX, passY + 4),
          width: g.r * 2 + 80 * _eo(kk),
          height: g.r * 0.9 + 28 * _eo(kk),
        ),
        _line(c, i.isEven ? 0xFFC145 : 0xFFFFFF, 4, 1 - kk),
      );
    }
  }
  _ball(cv, c, _Ball.basket, p, g.r, rot: rot);
  _bubble(
    cv,
    c,
    'Smaç!',
    Offset(g.head.dx - g.w * 0.66, g.head.dy - g.w * 0.1),
    _back(_sp(t, 0.44, 0.58)),
    0xC25A12,
    tailDx: 24,
  );
  if (!c.reduceMotion) {
    c.kind(cv, CelebrationKind.embers, const [0xF28A2E, 0xFFC145, 0x26407F]);
  }
}

void _basketLoop(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final l = _lp(c);
  final b = _bounceH(l * 2);
  _ball(cv, c, _Ball.basket, Offset(220, g.ground - 140 * b), g.r * 1.05,
      rot: l * _tau * 2);
}

// =============================================================== VOLEYBOL ===

CapPose _voleyPose(CelebrationContext c) {
  final a = _hump(_sp(c.t, 0.44, 0.6));
  return CapPose(dy: -11 * a, scale: 1 + 0.03 * a, rotation: -0.04 * a);
}

CapPose _voleyLoopPose(CelebrationContext c) => _loopBounce(c, 2, 8, 0.025);

void _voley(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final t = _ti(c);
  const setX = 215.0;
  const landX = 452.0;
  final setY = g.head.dy + g.w * 0.45;
  Offset p;
  var rot = 0.0;
  if (t < 0.26) {
    final u = _sp(t, 0.02, 0.26);
    p = Offset(setX, _lerp(g.ground, setY, _eo(u)));
    rot = u * 5;
  } else if (t < 0.46) {
    final u = _sp(t, 0.26, 0.46);
    p = Offset(_lerp(setX, landX, u), _lerp(setY, g.ground, u * u));
    rot = 5 + u * 14;
  } else {
    final u = _sp(t, 0.46, 0.8);
    double y;
    if (u < 0.45) {
      final v = u / 0.45;
      y = g.ground - 50 * 4 * v * (1 - v);
    } else if (u < 0.75) {
      final v = (u - 0.45) / 0.3;
      y = g.ground - 16 * 4 * v * (1 - v);
    } else {
      y = g.ground;
    }
    p = Offset(landX + 14 * _eo(u), y);
    rot = 19 - 6 * u;
  }
  if (!c.reduceMotion) {
    final k = _sp(t, 0.46, 0.8);
    if (k > 0 && k < 1) {
      for (var i = 0; i < 10; i++) {
        final dir = i.isEven ? -1.0 : 1.0;
        final sp = 20 + 40 * c.rand(i, 2);
        final x = (landX + dir * sp * _eo(k)).clamp(_minX, _maxX);
        final y = 470 - (8 + 28 * c.rand(i, 3)) * _eo(k);
        cv.drawCircle(
          Offset(x, y),
          7 + 9 * c.rand(i, 4) * _eo(k),
          _fill(c, i % 3 == 0 ? 0xE9CF8A : 0xF3DDA0, 0.85 * (1 - k)),
        );
      }
    }
  }
  _burst(cv, c, Offset(landX, g.ground), _sp(t, 0.46, 0.64), 0xF7C93A,
      0x3DB3E8, g.r * 2.4);
  _ball(cv, c, _Ball.volley, p, g.r, rot: rot);
  _bubble(
    cv,
    c,
    'Smaç!',
    Offset(g.head.dx - g.w * 0.66, g.head.dy - g.w * 0.1),
    _back(_sp(t, 0.48, 0.6)),
    0x1A78B5,
    tailDx: 24,
  );
}

void _voleyLoop(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final l = _lp(c);
  _ball(cv, c, _Ball.volley, Offset(466, g.ground), g.r, rot: 0.2);
  const spots = [
    [-0.6, -0.3, 1.0],
    [0.6, -0.36, 0.8],
    [-0.52, 0.3, 0.7],
    [0.56, 0.26, 0.9],
  ];
  for (var i = 0; i < spots.length; i++) {
    final s = spots[i];
    final tw = 0.5 + 0.5 * math.sin(l * _tau + i * 1.7);
    final x = (g.head.dx + s[0] * g.w).clamp(_minX + 10, _maxX - 10);
    final y = math.max(_minY + 14, g.head.dy + s[1] * g.w);
    _glint(cv, c, Offset(x, y), 9 + 6 * s[2] * tw,
        i.isEven ? 0xF7C93A : 0xFFFFFF, 0.35 + 0.65 * tw);
  }
}

// ================================================================ ECZACI ===

CapPose _eczaciPose(CelebrationContext c) {
  final a = _hump(_sp(c.t, 0.14, 0.3));
  final b = _hump(_sp(c.t, 0.3, 0.44));
  return CapPose(dy: -11 * a - 6 * b, rotation: 0.05 * (a - b), scale: 1 + 0.03 * a);
}

CapPose _eczaciLoopPose(CelebrationContext c) {
  if (c.reduceMotion) return CapPose.identity;
  final l = _lp(c) * _tau;
  return CapPose(
    dy: -5 * (0.5 - 0.5 * math.cos(l)),
    rotation: 0.025 * math.sin(l),
  );
}

/// Artı (sağlık haçı) parıltısı; [s] kol uzunluğu (merkezden uca).
void _plus(Canvas cv, CelebrationContext c, Offset p, double s, int hex,
    double op, double rot) {
  if (op <= 0.03 || s <= 1) return;
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  final t = s * 0.36;
  final path = Path()
    ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 2, height: t * 2),
        Radius.circular(t * 0.8)))
    ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: t * 2, height: s * 2),
        Radius.circular(t * 0.8)));
  cv.drawPath(path, _fill(c, hex, op));
  cv.drawPath(path, _line(c, 0x1F7A6B, 1.6, 0.55 * op));
  cv.restore();
}

/// Sarı-kırmızı vitamin kapsülü; [len] uzunluk.
void _capsule(Canvas cv, CelebrationContext c, Offset p, double len,
    double rot, double op) {
  if (op <= 0.03) return;
  final th = len * 0.5;
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  final rr = Radius.circular(th / 2);
  cv.drawRRect(
    RRect.fromRectAndCorners(Rect.fromLTWH(-len / 2, -th / 2, len / 2, th),
        topLeft: rr, bottomLeft: rr),
    _fill(c, 0xF7C93A, op),
  );
  cv.drawRRect(
    RRect.fromRectAndCorners(Rect.fromLTWH(0, -th / 2, len / 2, th),
        topRight: rr, bottomRight: rr),
    _fill(c, 0xE8553A, op),
  );
  cv.drawRRect(
    RRect.fromRectAndRadius(
        Rect.fromLTWH(-len / 2, -th / 2, len, th), rr),
    _line(c, 0x8A5A12, 2, op),
  );
  cv.drawLine(Offset(-len * 0.34, -th * 0.2), Offset(-len * 0.1, -th * 0.2),
      _line(c, 0xFFFFFF, 2.4, 0.8 * op));
  cv.restore();
}

// Yerde duracak kapsüller: x, gecikme, dönüş, yatış açısı.
const _eczCaps = <List<double>>[
  [200, 0.10, 5, 0.12],
  [244, 0.22, -6, -0.1],
  [440, 0.16, 6, -0.12],
  [484, 0.30, -5, 0.1],
  [222, 0.40, 4, -0.2],
  [462, 0.46, -4, 0.2],
];

void _eczaci(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final t = _ti(c);
  final el = c.reduceMotion ? 2.4 : c.elapsed;
  final len = g.w * 0.3;
  final restY = 470 - len * 0.25;
  // Artı parıltıları kapaktan dışarı yayılıp solar.
  if (!c.reduceMotion) {
    for (var i = 0; i < 9; i++) {
      final k = ((el - 0.1 - 0.09 * i) / 1.4);
      if (k <= 0 || k >= 1) continue;
      final ang = -math.pi * (0.1 + 0.8 * (i / 8)) - 0.0;
      final dir = Offset(math.cos(ang) * 1.25, math.sin(ang) * 0.9 + 0.35);
      final d = g.w * (0.42 + 0.55 * _eo(k));
      final p = g.head + dir * d;
      _plus(
        cv, c,
        Offset(p.dx.clamp(_minX + 14, _maxX - 14), math.max(_minY + 14, p.dy)),
        g.w * (0.12 + 0.05 * c.rand(i, 1)),
        i.isEven ? 0x3FB58F : 0xFFFFFF,
        _hump(k) * 0.95,
        k * 2 + i,
      );
    }
  }
  // Kapsüller: kapaktan fırlar, yumuşakça yere düşer ve yatar.
  for (var i = 0; i < _eczCaps.length; i++) {
    final d = _eczCaps[i];
    final tau = el - d[1];
    if (tau < 0) continue;
    const dur = 1.0;
    final u = (tau / dur).clamp(0.0, 1.0);
    final x = _lerp(g.head.dx, d[0], _eo(u));
    double y;
    if (u < 1) {
      y = _lerp(g.head.dy + g.w * 0.2, restY, u * u) - 90 * 4 * u * (1 - u);
    } else {
      final v = ((tau - dur) / 0.3).clamp(0.0, 1.0);
      y = restY - 10 * 4 * v * (1 - v);
    }
    final rot = (1 - _eo(u)) * d[2] * 2 + d[3];
    _capsule(cv, c, Offset(x, math.max(_minY + len * 0.25, y)), len, rot,
        (tau / 0.1).clamp(0.0, 1.0));
  }
  _bubble(
    cv,
    c,
    'Sağlığına!',
    Offset(g.head.dx + g.w * 0.62, g.head.dy - g.w * 0.18),
    _back(_sp(t, 0.14, 0.28)),
    0x1F7A6B,
    tailDx: -26,
  );
}

void _eczaciLoop(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final l = _lp(c);
  final len = g.w * 0.3;
  final restY = 470 - len * 0.25;
  for (final d in _eczCaps) {
    _capsule(cv, c, Offset(d[0], restY), len, d[3], 1);
  }
  const spots = [
    [-0.62, -0.28, 1.0],
    [0.62, -0.34, 0.8],
    [-0.5, 0.3, 0.7],
    [0.54, 0.28, 0.9],
  ];
  for (var i = 0; i < spots.length; i++) {
    final s = spots[i];
    final tw = 0.5 + 0.5 * math.sin(l * _tau + i * 1.6);
    final x = (g.head.dx + s[0] * g.w).clamp(_minX + 16, _maxX - 16);
    final y = math.max(_minY + 16, g.head.dy + s[1] * g.w);
    _plus(cv, c, Offset(x, y), g.w * (0.09 + 0.05 * tw * s[2]),
        i.isEven ? 0x3FB58F : 0xFFFFFF, 0.4 + 0.6 * tw, 0);
  }
}

// =========================================================== KARA EJDERHA ===

CapPose _karaPose(CelebrationContext c) {
  final t = c.t;
  // Kısa ağır sarsıntı, sonra kükreme: hafif öne eğilip büyür.
  final shake = (1 - _sp(t, 0.0, 0.2)) * (t < 0.2 ? 1 : 0);
  final roar = _hump(_sp(t, 0.18, 0.5));
  return CapPose(
    dx: 4 * shake * math.sin(t * 90),
    dy: 2 * shake * math.sin(t * 70) - 5 * roar,
    scale: 1 + 0.06 * roar,
    rotation: 0.02 * shake * math.sin(t * 60),
  );
}

CapPose _karaLoopPose(CelebrationContext c) {
  if (c.reduceMotion) return CapPose.identity;
  final b = 0.5 - 0.5 * math.cos(_lp(c) * _tau);
  return CapPose(scale: 1 + 0.025 * b, dy: -2 * b);
}

Offset _clampP(Offset p, [double m = 6]) => Offset(
  p.dx.clamp(_minX + m, _maxX - m),
  math.max(_minY + m, p.dy),
);

void _glow(Canvas cv, CelebrationContext c, Offset p, double r, int hex,
    double op) {
  if (op <= 0.02 || r <= 1) return;
  final o = (op * c.alpha).clamp(0.0, 1.0);
  cv.drawCircle(
    p,
    r,
    Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF000000 | hex).withValues(alpha: o),
          Color(0xFF000000 | hex).withValues(alpha: o * 0.4),
          Color(0xFF000000 | hex).withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromCircle(center: p, radius: r)),
  );
}

void _kara(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final t = _ti(c);
  final el = c.reduceMotion ? 1.0 : c.elapsed;
  final mouth = c.capImagePt(0.5, 0.78);

  // Ateş nefesi ~1.2 sn: hızlı uzar, tutar, söner; hafifçe yana süpürür.
  final env = _eo(_sp(t, 0.16, 0.25)) * (1 - _sp(t, 0.54, 0.64));
  final life = c.reduceMotion ? 1.0 : env;
  final theta = c.reduceMotion
      ? 2.25
      : _lerp(2.4, 2.05, Curves.easeInOut.transform(_sp(t, 0.16, 0.62)));
  if (life > 0.02) {
    // Sıcak ekran tonu (yanıp söner).
    final flick = c.reduceMotion ? 0.8 : 0.75 + 0.25 * math.sin(el * 38);
    cv.drawRect(
      designRectBig,
      _fill(c, 0xF07A2A, 0.2 * life * flick),
    );
    _flameJet(cv, c, mouth, theta, 270 * life, el, 1.0);
  }

  _volcano(cv, c, el, intro: true);

  if (!c.reduceMotion) {
    // Çenedeki ışık ve konideki kıvılcımlar.
    final dir = Offset(math.cos(theta), math.sin(theta));
    final perp = Offset(-dir.dy, dir.dx);
    for (var i = 0; i < 34 && life > 0.05; i++) {
      final k = _fract(el * 2.4 + c.rand(i, 1));
      final d = k * 280 * life;
      final lat = (c.rand(i, 2) - 0.5) * (16 + d * 0.7);
      final p = _clampP(mouth + dir * d + perp * lat, 4);
      cv.drawCircle(p, (2.5 + 3 * c.rand(i, 3)) * (1 - 0.5 * k),
          _fill(c, i % 3 == 0 ? 0xFFF3B0 : 0xFFC145, (1 - k) * 0.95));
    }
  }

  _bubble(
    cv,
    c,
    'GRAAH!',
    Offset(g.head.dx + g.w * 0.62, g.head.dy - g.w * 0.2),
    _back(_sp(t, 0.2, 0.34)),
    0xF0B83A,
    tailDx: -26,
    fillHex: 0x1E1A1A,
  );
}

/// Tasarım alanından taşan (yalnız ekran tonu için) büyük dikdörtgen.
const designRectBig = Rect.fromLTRB(-200, -200, 900, 900);

/// Katmanlı alev konisi: koyu kırmızı kenar, turuncu, sarı, beyaz-sarı çekirdek.
void _flameJet(Canvas cv, CelebrationContext c, Offset m, double th,
    double len, double time, double k) {
  if (len < 6) return;
  // Ağız ışıması.
  _glow(cv, c, m, len * 0.55, 0xF07A2A, 0.55);
  _glow(cv, c, m, len * 0.28, 0xFFE08A, 0.7);
  const layers = [
    [1.0, 0x8E1C12, 0.78, 1.0],
    [0.78, 0xE8531F, 0.9, 0.95],
    [0.55, 0xFFA928, 0.95, 0.88],
    [0.32, 0xFFE67A, 1.0, 0.76],
    [0.15, 0xFFFBE0, 1.0, 0.6],
  ];
  for (var li = 0; li < layers.length; li++) {
    final l = layers[li];
    _flameLayer(cv, c, m, th, len * l[3].toDouble(), l[0].toDouble(), time, l[1].toInt(), l[2].toDouble(),
        li * 1.7);
  }
}

void _flameLayer(Canvas cv, CelebrationContext c, Offset m, double th,
    double len, double widthK, double time, int hex, double op, double seed) {
  final dir = Offset(math.cos(th), math.sin(th));
  final perp = Offset(-dir.dy, dir.dx);
  const n = 30;
  final up = <Offset>[];
  final dn = <Offset>[];
  for (var i = 0; i <= n; i++) {
    final f = i / n;
    final d = f * len;
    final taper = 1 - f * f * f * f;
    final hw = (12 + d * 0.38) * widthK * taper;
    final nz = math.sin(f * 13 - time * 26 + seed) * 0.22 +
        math.sin(f * 29 - time * 41 + seed * 2) * 0.14;
    final wave = math.sin(f * 5 - time * 9 + seed) * len * 0.03 * f;
    final base = m + dir * d + perp * wave;
    up.add(_clampP(base + perp * (hw * (1 + nz)), 0));
    dn.add(_clampP(base - perp * (hw * (1 - nz)), 0));
  }
  final path = Path()..moveTo(up.first.dx, up.first.dy);
  for (final p in up.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  for (final p in dn.reversed) {
    path.lineTo(p.dx, p.dy);
  }
  path.close();
  cv.drawPath(path, _fill(c, hex, op));
}

/// Arka plandaki yanardağ (sahne sol kenarında): krater ışıması, lav
/// blokları, duman/kül sütunu, düşen közler. [intro] false ise sakin döngü.
void _volcano(Canvas cv, CelebrationContext c, double el,
    {required bool intro, double loop = 0}) {
  // Kraterin sahne konumu (941x1672 görselde ~ (95, 1000)).
  final raw = c.sceneUv(130 / 941, 618 / 1672) ?? const Offset(190, 300);
  final cr = Offset(raw.dx.clamp(_minX + 6, _maxX - 40), raw.dy.clamp(_minY + 40, 500.0));
  final reduce = c.reduceMotion;
  if (intro) {
    final t = _ti(c);
    final burst = reduce ? 1.0 : _hump(_sp(t, 0.16, 0.8));
    _glow(cv, c, cr, 70 + 40 * burst, 0xF07A2A, 0.75 * (0.4 + 0.6 * burst));
    _glow(cv, c, cr, 34 + 16 * burst, 0xFFE08A, 0.85 * burst);
    if (reduce) {
      // Sabit kare: kraterde birkaç lav blob + duman.
      for (var i = 0; i < 4; i++) {
        final p = cr + Offset(18.0 * i - 8, -46.0 - 22 * (i % 2) - 6 * i);
        _lava(cv, c, _clampP(p, 8), 8 - i * 0.8, 1);
      }
      cv.drawCircle(_clampP(cr + const Offset(14, -120), 16), 26,
          _fill(c, 0x3A3338, 0.5));
      return;
    }
    // Duman ve kül sütunu.
    for (var i = 0; i < 8; i++) {
      final k = (el - 0.45 - i * 0.17) / 1.8;
      if (k <= 0 || k >= 1) continue;
      final p = cr + Offset(14 + 26 * k + 8 * math.sin(k * 6 + i), -10 - 190 * _eo(k));
      cv.drawCircle(_clampP(p, 12), 14 + 34 * k,
          _fill(c, i.isEven ? 0x3A3338 : 0x57505A, 0.62 * math.min(1.0, k * 6) * (1 - k)));
    }
    // Lav blokları.
    for (var i = 0; i < 16; i++) {
      final tau = el - 0.42 - c.rand(i, 1) * 0.55;
      if (tau <= 0) continue;
      final v0 = 230 + 170 * c.rand(i, 2);
      final vx = (-0.15 + c.rand(i, 3)) * 130;
      final y = -v0 * tau + 0.5 * 560 * tau * tau;
      if (y > 26) continue;
      final p = cr + Offset(vx * tau, y);
      _lava(cv, c, _clampP(p, 8), 6 + 5 * c.rand(i, 4), 1);
    }
    // Küçük közler.
    for (var i = 0; i < 26; i++) {
      final tau = el - 0.5 - c.rand(i, 5) * 0.9;
      if (tau <= 0 || tau > 1.5) continue;
      final vx = (c.rand(i, 6) - 0.2) * 190;
      final v0 = 120 + 220 * c.rand(i, 7);
      final y = -v0 * tau + 0.5 * 240 * tau * tau;
      final p = cr + Offset(vx * tau, y);
      final op = (1 - tau / 1.5);
      cv.drawCircle(_clampP(p, 3), 2.4 + 2 * c.rand(i, 8),
          _fill(c, i.isEven ? 0xFFC145 : 0xF07A2A, op));
    }
  } else {
    final pulse = 0.5 + 0.5 * math.sin(loop * _tau);
    _glow(cv, c, cr, 56 + 8 * pulse, 0xF07A2A, 0.45 + 0.2 * pulse);
    _glow(cv, c, cr, 26 + 4 * pulse, 0xFFE08A, 0.5 + 0.2 * pulse);
    if (reduce) return;
    // İnce duman.
    for (var i = 0; i < 3; i++) {
      final k = _fract(loop + i / 3);
      final p = cr + Offset(12 + 14 * k, -10 - 110 * k);
      cv.drawCircle(_clampP(p, 10), 10 + 18 * k,
          _fill(c, 0x57505A, 0.45 * _hump(k)));
    }
    // Ara sıra küçük lav fışkırması (tur başına 2).
    for (var j = 0; j < 2; j++) {
      final u = _fract(loop * 2 + j * 0.0) ;
      if (u > 0.55) continue;
      final tau = u / 0.55;
      for (var i = 0; i < 3; i++) {
        final h = 70 + 40 * c.rand(i + j * 3, 11);
        final vx = (0.1 + c.rand(i + j * 3, 12)) * 60;
        final y = -h * 4 * tau * (1 - tau);
        _lava(cv, c, _clampP(cr + Offset(vx * tau * 1.4, y), 6), 5 + 2.5 * i % 3, 1);
      }
    }
  }
}

/// Parlayan lav parçası.
void _lava(Canvas cv, CelebrationContext c, Offset p, double r, double op) {
  cv.drawCircle(p, r * 2.2, _fill(c, 0xF07A2A, 0.28 * op));
  cv.drawCircle(p, r, _fill(c, 0xE8531F, op));
  cv.drawCircle(p, r * 0.6, _fill(c, 0xFFC145, op));
  cv.drawCircle(p + Offset(-r * 0.15, -r * 0.2), r * 0.25, _fill(c, 0xFFF3B0, op));
}

void _karaLoop(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final l = _lp(c);
  _volcano(cv, c, 0, intro: false, loop: l);
  // Her turda küçük bir alev solukları.
  final puff = _hump(_sp(l, 0.22, 0.5));
  if (puff > 0.03) {
    _flameJet(cv, c, c.capImagePt(0.5, 0.78), 2.2, 150 * puff, l * 3.2, 1);
  }
  for (final u in const [0.42, 0.58]) {
    final base = c.capImagePt(u, 0.75);
    final dir = u < 0.5 ? -1.0 : 1.0;
    for (var j = 0; j < 3; j++) {
      final k = _fract(l + j / 3);
      final p = base + Offset(dir * (6 + 10 * k) + 7 * math.sin(k * _tau * 1.5), -k * g.w * 0.55);
      cv.drawCircle(_clampP(p, 8), 5 + 13 * k,
          _fill(c, 0x9A9AA4, 0.5 * _hump(k)));
    }
  }
  for (var i = 0; i < 9; i++) {
    final k = _fract(l + i / 9);
    final x = g.head.dx + (c.rand(i, 5) - 0.5) * g.w * 1.5 + 8 * math.sin(k * _tau + i);
    final y = g.head.dy + g.w * 0.75 - k * g.w * 0.9;
    final op = _hump(k) * 0.9;
    final q = _clampP(Offset(x, y), 5);
    cv.drawCircle(q, 7, _fill(c, 0xF07A2A, 0.25 * op));
    cv.drawCircle(q, 3.2, _fill(c, i.isEven ? 0xFFC145 : 0xF07A2A, op));
  }
}

// ========================================================= YARIŞ ARABASI ===

CapPose _yarisPose(CelebrationContext c) {
  final t = c.t;
  final rev = math.sin(t * 120) * (1 - _sp(t, 0.0, 0.14)) * (t < 0.14 ? 1 : 0);
  final hop = _hump(_sp(t, 0.16, 0.34));
  return CapPose(dx: 2 * rev, dy: -10 * hop + 1.5 * rev, scale: 1 + 0.03 * hop);
}

CapPose _yarisLoopPose(CelebrationContext c) => _loopBounce(c, 6, 3.5, 0.01);

void _speedLines(Canvas cv, CelebrationContext c, _G g, double phase,
    double op) {
  final top = c.capImagePt(0.5, 0.4).dy;
  final bot = c.capImagePt(0.5, 0.92).dy;
  for (var i = 0; i < 12; i++) {
    final side = i.isEven;
    final k = _fract(phase + c.rand(i, 1));
    final y = _lerp(top, bot, (i % 6) / 5 + 0.0) + (c.rand(i, 2) - 0.5) * 8;
    final len = 34 + 30 * c.rand(i, 3);
    final lo = side ? _minX + 4 : 428.0;
    final hi = side ? 262.0 : _maxX - 4;
    // Çizgiler arabanın gittiği yönün tersine akar (kenara doğru).
    final x0 = side ? _lerp(hi, lo, k) : _lerp(lo, hi, k);
    final x1 = side ? x0 + len : x0 - len;
    final a = math.min(x0, x1).clamp(lo, hi), b = math.max(x0, x1).clamp(lo, hi);
    cv.drawLine(Offset(a, math.max(_minY, y)), Offset(b, math.max(_minY, y)),
        _line(c, i % 3 == 0 ? 0xD8282A : 0xFFFFFF, 3.5, op * _hump(k)));
  }
}

void _tyreSmoke(Canvas cv, CelebrationContext c, double secs, double life,
    double n) {
  for (var s = 0; s < 2; s++) {
    final base = c.capImagePt(s == 0 ? 0.14 : 0.86, 0.94);
    for (var i = 0; i < n; i++) {
      final k = (secs - 0.1 - i * 0.18) / life;
      if (k <= 0 || k >= 1) continue;
      final dir = s == 0 ? -1.0 : 1.0;
      final p = base + Offset(dir * (6 + 22 * _eo(k)), -26 * _eo(k) + 6);
      cv.drawCircle(_clampP(p, 10), 7 + 14 * k,
          _fill(c, 0xE4E4EA, 0.75 * (1 - k)));
    }
  }
}

void _flag(Canvas cv, CelebrationContext c, Offset pole, double top,
    double pop, double phase) {
  if (pop <= 0.02) return;
  const cols = 5, rows = 3;
  const cell = 12.0;
  final base = _lerp(470, top, _eo(pop));
  cv.drawLine(Offset(pole.dx, 470), Offset(pole.dx, base), _line(c, 0x3A3A40, 5));
  if (pop < 0.6) return;
  final fo = ((pop - 0.6) / 0.4).clamp(0.0, 1.0);
  for (var j = 0; j < cols; j++) {
    final wy = 3.5 * math.sin(phase - j * 0.9) * (j / cols + 0.2);
    for (var r = 0; r < rows; r++) {
      final x = pole.dx - (j + 1) * cell * fo;
      final y = base + r * cell + wy;
      cv.drawRect(Rect.fromLTWH(x, y, cell * fo + 0.6, cell + 0.6),
          _fill(c, (j + r).isEven ? 0x2A2A30 : 0xFFFFFF));
    }
  }
  cv.drawRect(
    Rect.fromLTWH(pole.dx - cols * cell * fo, base, cols * cell * fo, rows * cell),
    _line(c, 0x2A2A30, 1.5, 0.0),
  );
}

void _yaris(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final t = _ti(c);
  final el = c.reduceMotion ? 2.4 : c.elapsed;
  if (!c.reduceMotion) {
    _speedLines(cv, c, g, el * 1.1, 0.85 * _sp(t, 0.02, 0.1));
    _tyreSmoke(cv, c, el, 1.1, 4);
    c.kind(cv, CelebrationKind.confetti, const [0xD8282A, 0xFFFFFF, 0x2A2A30]);
  }
  final poleX = math.max(_minX + 84, g.head.dx - g.w * 0.62);
  final top = math.max(_minY + 6, c.capImagePt(0.5, 0.4).dy - 4);
  _flag(cv, c, Offset(poleX, 0), top, _sp(t, 0.04, 0.22), el * 9);
  _bubble(
    cv,
    c,
    'VINN!',
    Offset(g.head.dx + g.w * 0.42, c.capImagePt(0.5, 0.36).dy - 8),
    _back(_sp(t, 0.2, 0.34)),
    0xD8282A,
    tailDx: -22,
  );
}

void _yarisLoop(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final l = _lp(c);
  _speedLines(cv, c, g, l * 2, 0.8);
  final poleX = math.max(_minX + 84, g.head.dx - g.w * 0.62);
  final top = math.max(_minY + 6, c.capImagePt(0.5, 0.4).dy - 4);
  _flag(cv, c, Offset(poleX, 0), top, 1, l * _tau * 3);
}
