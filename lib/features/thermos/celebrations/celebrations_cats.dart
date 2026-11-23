import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'celebration_context.dart';
import 'fx_sprites.dart';

// Kedi (iki pati sallar + kuyruk + kalpler) ve Pofuduk Kedi (yumak oyunu).
// Patiler/kuyruk kafanın ve şişenin ARKASINDAN çıkar: önce patiler, sonra
// kapak yeniden çizilir (drawCapOver); kuyruk şişe camının dışında kalan
// kısmıyla çizilir (kök camın içinde kırpılır).

const Map<String, SignatureCelebration> catsCelebrations = {
  'kedi': _kedi,
  'pofuduk': _pofuduk,
};
const Map<String, SignatureCelebration> catsLoops = {
  'kedi': _kediLoop,
  'pofuduk': _pofudukLoop,
};
const Map<String, CapPoseFn> catsCapPoses = {
  'kedi': _kediPose,
  'pofuduk': _pofudukPose,
};
const Map<String, CapPoseFn> catsLoopPoses = {
  'kedi': _loopPose,
  'pofuduk': _loopPose,
};

const _tau = math.pi * 2;
const _minX = 168.0, _maxX = 512.0, _minY = 76.0;

double _sp(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
double _eo(double x) => Curves.easeOutCubic.transform(x.clamp(0.0, 1.0));
double _lerp(double a, double b, double x) => a + (b - a) * x;
double _fract(double x) => x - x.floorToDouble();
double _hump(double x) => math.sin(x.clamp(0.0, 1.0) * math.pi);
double _back(double x) => Curves.easeOutBack.transform(x.clamp(0.0, 1.0));

class _G {
  _G(CelebrationContext c)
    : w = c.capWidth / c.pose.scale,
      head = c.capCenter - Offset(c.pose.dx, c.pose.dy);
  final double w;
  final Offset head;
}

void _spr(
  Canvas cv,
  CelebrationContext c,
  String name,
  Offset p,
  double w, {
  double rot = 0,
  double op = 1,
  bool flip = false,
  Alignment at = Alignment.center,
}) {
  final img = FxSprites.get(name);
  if (img == null) return;
  final o = (op * c.alpha).clamp(0.0, 1.0);
  if (o <= 0.01 || w <= 0.5) return;
  final h = w * img.height / img.width;
  cv.save();
  cv.translate(p.dx, p.dy);
  if (rot != 0) cv.rotate(rot);
  if (flip) cv.scale(-1, 1);
  cv.drawImageRect(
    img,
    Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
    Rect.fromLTWH(-w * (0.5 + at.x / 2), -h * (0.5 + at.y / 2), w, h),
    Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Color.fromARGB((o * 255).round(), 255, 255, 255),
  );
  cv.restore();
}

CapPose _loopPose(CelebrationContext c) {
  if (c.reduceMotion) return CapPose.identity;
  final l = c.loop * _tau;
  return CapPose(
    dy: -2 * (0.5 - 0.5 * math.cos(l * 2)),
    rotation: 0.025 * math.sin(l),
  );
}

/// Pati: dipten (kafanın arkasındaki pivot) yukarı uzanır, pivot etrafında
/// döner. [side] -1 sol (aynalı), 1 sağ.
void _paw(Canvas cv, CelebrationContext c, String name, _G g, int side,
    double grow, double rot) {
  if (grow <= 0.02) return;
  final pivot = c.capImagePt(side < 0 ? 0.15 : 0.85, 0.93);
  final w = 0.32 * g.w * grow;
  // Kapağın ÜSTÜNE çizilir: yüzün alt yanlarında, çene/yanak hizasında.
  _spr(cv, c, name, pivot, w,
      rot: rot * side + side * 0.35, flip: side < 0,
      at: const Alignment(0, 0.97), op: grow.clamp(0.0, 1.0));
}

/// Kuyruk: kafanın ARKASINDA, sağ üstten (kulağın yanından) çıkar; kök kafayla
/// örtülür (kapak sonradan üstüne çizilir).
void _tail(Canvas cv, CelebrationContext c, String name, _G g, double grow,
    double rot) {
  if (grow <= 0.02) return;
  final root = c.capImagePt(0.78, 0.5);
  _spr(cv, c, name, root, 0.34 * g.w * grow,
      rot: rot + 0.85, at: const Alignment(0, 0.97), op: grow.clamp(0.0, 1.0));
}

void _heart(Canvas cv, CelebrationContext c, Offset p, double size, double op) {
  _spr(cv, c, 'kedi_heart',
      Offset(p.dx.clamp(_minX + size, _maxX - size), math.max(_minY + size, p.dy)),
      size, op: op);
}

// ================================================================= KEDİ ====

CapPose _kediPose(CelebrationContext c) {
  final a = _hump(_sp(c.t, 0.1, 0.3));
  return CapPose(dy: -6 * a, rotation: 0.04 * math.sin(c.t * _tau * 3) * _sp(c.t, 0.1, 0.2));
}

void _catScene(Canvas cv, CelebrationContext c, String pawName, String tailName,
    {required double grow, required double wave, required double tailGrow,
    required double tailWag, required double phaseL, required double phaseR}) {
  final g = _G(c);
  _tail(cv, c, tailName, g, tailGrow, tailWag);
  c.drawCapOver(cv);
  _paw(cv, c, pawName, g, -1, grow, 0.3 * math.sin(wave + phaseL));
  _paw(cv, c, pawName, g, 1, grow, 0.3 * math.sin(wave + phaseR));
}

void _kedi(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final t = c.reduceMotion ? 0.5 : c.t;
  final grow = c.reduceMotion ? 1.0 : _back(_sp(t, 0.06, 0.2));
  final tg = c.reduceMotion ? 1.0 : _back(_sp(t, 0.14, 0.3));
  _catScene(
    cv, c, 'kedi_paw', 'kedi_tail',
    grow: grow,
    wave: c.reduceMotion ? 0 : t * _tau * 4,
    tailGrow: tg,
    tailWag: c.reduceMotion ? 0 : 0.2 * math.sin(t * _tau * 3.5),
    phaseL: 0,
    phaseR: math.pi,
  );
  // Yükselen kalpler.
  if (c.reduceMotion) {
    _heart(cv, c, c.capCenter + Offset(0.62 * g.w, -0.3 * g.w), 0.14 * g.w, 1);
    _heart(cv, c, c.capCenter + Offset(-0.66 * g.w, -0.1 * g.w), 0.11 * g.w, 1);
    return;
  }
  for (var i = 0; i < 6; i++) {
    final s = 0.22 + 0.08 * i;
    final k = _sp(t, s, s + 0.3);
    if (k <= 0 || k >= 1) continue;
    final side = i.isEven ? -1.0 : 1.0;
    final p = Offset(
      g.head.dx + side * (0.62 + 0.1 * (i % 3)) * g.w + 6 * math.sin(k * _tau * 2 + i),
      g.head.dy + 0.3 * g.w - k * 0.9 * g.w,
    );
    _heart(cv, c, p, (0.1 + 0.05 * c.rand(i, 1)) * g.w,
        math.min(1.0, k * 6) * math.min(1.0, (1 - k) * 4));
  }
}

void _kediLoop(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final l = c.loop;
  // Sakin, sırayla sallanan patiler; hafif kuyruk; ara sıra kalp.
  final a = math.sin(l * _tau * 2);
  _tail(cv, c, 'kedi_tail', g, 1, 0.16 * math.sin(l * _tau));
  c.drawCapOver(cv);
  _paw(cv, c, 'kedi_paw', g, -1, 1, 0.26 * a);
  _paw(cv, c, 'kedi_paw', g, 1, 1, -0.26 * a);
  final k = _fract(l * 1.0);
  _heart(
    cv, c,
    Offset(g.head.dx + 0.66 * g.w + 6 * math.sin(k * _tau * 2), g.head.dy + 0.3 * g.w - k * 0.9 * g.w),
    0.12 * g.w, _hump(k) * 0.95,
  );
}

// ============================================================== POFUDUK ====

CapPose _pofudukPose(CelebrationContext c) {
  final a = _hump(_sp(c.t, 0.34, 0.5));
  return CapPose(dy: -5 * a, rotation: 0.05 * a * math.sin(c.t * _tau * 4));
}

/// Yumak yolu; (konum, dönüş). Zemin: şişenin sol yanı.
({Offset p, double rot, double trailTo}) _yarn(
    _G g, double groundY, double r, double t, Offset hit) {
  const x0 = 186.0, xRoll = 240.0, xRest = 222.0;
  if (t < 0.22) {
    final k = _sp(t, 0.02, 0.22);
    final x = _lerp(x0, xRoll, k);
    return (p: Offset(x, groundY), rot: (x - x0) / r, trailTo: x);
  }
  if (t < 0.38) {
    final k = _sp(t, 0.22, 0.38);
    final x = _lerp(xRoll, hit.dx, k);
    final y = _lerp(groundY, hit.dy, _eo(k)) - 40 * 4 * k * (1 - k);
    return (p: Offset(x, y), rot: (xRoll - x0) / r + k * 2, trailTo: xRoll);
  }
  final k = _sp(t, 0.38, 0.8);
  final x = _lerp(hit.dx, xRest, _eo(k));
  double y;
  if (k < 0.5) {
    final v = k / 0.5;
    y = _lerp(hit.dy, groundY, v * v);
  } else if (k < 0.8) {
    final v = (k - 0.5) / 0.3;
    y = groundY - 26 * 4 * v * (1 - v);
  } else {
    y = groundY;
  }
  return (p: Offset(x, y), rot: 2 + (hit.dx - x) / r * -1.2, trailTo: _lerp(xRoll, xRest, _eo(k)));
}

void _trail(Canvas cv, CelebrationContext c, double groundY, double r,
    double toX, Offset ball, double w) {
  if (toX <= 190) return;
  final path = Path()..moveTo(182, groundY + r - 2);
  const n = 18;
  for (var i = 1; i <= n; i++) {
    final x = _lerp(182, toX, i / n);
    path.lineTo(x, groundY + r - 2 + 3 * math.sin(i * 0.9));
  }
  path.lineTo(ball.dx + 0.3 * r, ball.dy + 0.75 * r);
  cv.drawPath(
    path,
    c.paintOf(0xF2C21B, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.5, w * 0.03)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
}

void _pofuduk(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final t = c.reduceMotion ? 0.85 : c.t;
  final r = 0.17 * g.w;
  final groundY = 470 - r;
  final pivot = c.capImagePt(0.15, 0.93);
  final ph = 0.32 * g.w * 379 / 254; // pati yüksekliği
  // Vuruş anında patinin ucu.
  const hitAngle = -0.95;
  final hit = pivot +
      Offset(math.sin(hitAngle) * ph * 0.95, -math.cos(hitAngle) * ph * 0.95);
  final y = _yarn(g, groundY, r, t, hit);

  // Kuyruk (şişenin arkasından) ve pati (kafanın arkasından).
  final tg = c.reduceMotion ? 1.0 : _back(_sp(t, 0.4, 0.55));
  _tail(cv, c, 'pofuduk_tail', g, tg,
      c.reduceMotion ? 0 : 0.22 * math.sin(t * _tau * 3.5));
  final grow = c.reduceMotion ? 0.0 : _back(_sp(t, 0.26, 0.36));
  final swat = _sp(t, 0.36, 0.42) * (1 - _sp(t, 0.5, 0.65));
  c.drawCapOver(cv);
  _paw(cv, c, 'pofuduk_paw', g, -1, grow, 0.1 + 0.5 * swat);

  // İp izi ve yumak.
  _trail(cv, c, groundY, r, y.trailTo, y.p, g.w);
  _spr(cv, c, 'pofuduk_yarn', y.p, 2 * r, rot: y.rot,
      op: c.reduceMotion ? 1 : _sp(t, 0.0, 0.05));

  // Kalpler (kuyruk çevresinde).
  if (c.reduceMotion) {
    _heart(cv, c, c.capCenter + Offset(0.62 * g.w, -0.25 * g.w), 0.13 * g.w, 1);
    return;
  }
  for (var i = 0; i < 5; i++) {
    final s = 0.45 + 0.07 * i;
    final k = _sp(t, s, s + 0.28);
    if (k <= 0 || k >= 1) continue;
    final p = Offset(
      g.head.dx + (0.62 + 0.1 * (i % 3)) * g.w + 6 * math.sin(k * _tau * 2 + i),
      g.head.dy + 0.4 * g.w - k * 0.9 * g.w,
    );
    _heart(cv, c, p, (0.1 + 0.04 * c.rand(i, 2)) * g.w,
        math.min(1.0, k * 6) * math.min(1.0, (1 - k) * 4));
  }
}

void _pofudukLoop(Canvas cv, CelebrationContext c) {
  final g = _G(c);
  final l = c.loop;
  final r = 0.17 * g.w;
  final groundY = 470 - r;
  const rest = Offset(222, 0);
  // Yumağa pati vurur (tur başına bir kez): top sallanır.
  final bat = _hump(_sp(l, 0.3, 0.5));
  _tail(cv, c, 'pofuduk_tail', g, 1, 0.2 * math.sin(l * _tau));
  c.drawCapOver(cv);
  _paw(cv, c, 'pofuduk_paw', g, -1, 1, 0.1 + 0.5 * bat);
  final wob = bat * math.sin(l * _tau * 6);
  final ball = Offset(rest.dx + 3 * wob, groundY - 4 * bat);
  _trail(cv, c, groundY, r, rest.dx, ball, g.w);
  _spr(cv, c, 'pofuduk_yarn', ball, 2 * r, rot: 2 + 0.25 * wob);
  final k = _fract(l);
  _heart(
    cv, c,
    Offset(g.head.dx + 0.66 * g.w, g.head.dy + 0.4 * g.w - k * 0.9 * g.w),
    0.11 * g.w, _hump(k) * 0.9,
  );
}
