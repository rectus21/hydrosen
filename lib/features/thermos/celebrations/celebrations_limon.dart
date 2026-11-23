import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'celebration_context.dart';
import 'fx_sprites.dart';

// Limon: Ferahlık Köpüğü (limonata yükselir, köpük, buz, kabarcık) sonra
// Şemsiye Pervanesi (şemsiye üstten bakışla pervane gibi döner, kapak
// yükselir, limon dilimleri yağar). Giriş ~4 sn (bkz. CelebrationOverlay.
// durationFor); süre fraksiyonlarına göre: 0-35 limonata, 35-80 pervane,
// 80-100 iniş. Suyun rengi ve duran şemsiye ThermosPainter'da çizilir
// (lemonade / umbrellaOn parametreleri); bu dosya dalga/duman benzeri
// efektleri ve hareketli şemsiyeyi çizer.

const _tau = math.pi * 2;
const _minX = 168.0, _maxX = 512.0;

double _sp(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
double _eo(double x) => Curves.easeOutCubic.transform(x.clamp(0.0, 1.0));
double _io(double x) => Curves.easeInOut.transform(x.clamp(0.0, 1.0));
double _lerp(double a, double b, double x) => a + (b - a) * x;
double _fract(double x) => x - x.floorToDouble();
double _hump(double x) => math.sin(x.clamp(0.0, 1.0) * math.pi);
double _back(double x) => Curves.easeOutBack.transform(x.clamp(0.0, 1.0));

/// Intro kapak pozu: sip bob, yükselme + sallanma, sonra yumuşak iniş.
CapPose limonPose(CelebrationContext c) {
  final t = c.t;
  if (t < 0.35) {
    final k = t / 0.35;
    return CapPose(
      dy: 4 * math.sin(k * _tau * 2) * _hump(k * 1.0),
      scale: 1 + 0.015 * math.sin(k * _tau * 2),
    );
  }
  final lift = 40 * _eo(_sp(t, 0.35, 0.45)) * (1 - _io(_sp(t, 0.8, 0.95)));
  final wob = (1 - _io(_sp(t, 0.8, 0.95))) * _sp(t, 0.35, 0.42);
  return CapPose(
    dx: 4 * math.sin(t * _tau * 5) * wob,
    dy: -lift,
    rotation: 0.07 * math.sin(t * _tau * 7) * wob,
  );
}

CapPose limonLoopPose(CelebrationContext c) {
  if (c.reduceMotion) return CapPose.identity;
  final l = c.loop * _tau;
  return CapPose(
    dy: -2.5 * (0.5 - 0.5 * math.cos(l)),
    rotation: 0.02 * math.sin(l),
  );
}

void _spr(
  Canvas cv,
  CelebrationContext c,
  String name,
  Offset p,
  double w, {
  double rot = 0,
  double op = 1,
  double squashY = 1,
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
  if (squashY != 1) cv.scale(1, squashY);
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

/// Limonata: yüzeyde köpük, iki buz, yükselen kabarcıklar.
void _lemonade(Canvas cv, CelebrationContext c, double w, double k,
    double phase, {bool still = false}) {
  if (k <= 0.02) return;
  final gl = c.glass;
  final wy = c.waterY;
  final cx = gl.center.dx;
  // Kabarcıklar (suyun içinde).
  for (var i = 0; i < 7; i++) {
    final u = still ? 0.15 + 0.13 * i : _fract(phase + i / 7 + 0.07 * c.rand(i, 1));
    final x = gl.left + 16 + (gl.width - 32) * c.rand(i, 2) +
        4 * math.sin(u * _tau * 2 + i);
    final y = _lerp(gl.bottom - 36, wy + 8, u);
    _spr(cv, c, 'limon_bubble', Offset(x, y), (0.07 + 0.05 * c.rand(i, 3)) * w,
        op: k * (still ? 0.9 : _hump(u) * 0.95));
  }
  // Buzlar.
  final bob = still ? 0.0 : math.sin(phase * _tau);
  _spr(cv, c, 'limon_ice', Offset(cx - 0.17 * w, wy + 20 + 3 * bob), 0.2 * w,
      rot: -0.25 + 0.12 * bob, op: k);
  _spr(cv, c, 'limon_ice', Offset(cx + 0.19 * w, wy + 30 - 3 * bob), 0.17 * w,
      rot: 0.3 - 0.12 * bob, op: k);
  // Köpük kümeleri yüzeyde.
  for (var i = 0; i < 3; i++) {
    final x = cx + (i - 1) * 0.24 * w;
    final bobY = still ? 0.0 : 2 * math.sin(phase * _tau + i * 2);
    _spr(cv, c, 'limon_foam', Offset(x, wy + 12 + bobY),
        (0.3 - 0.04 * (i % 2)) * w * _back(k),
        at: Alignment.bottomCenter, op: k);
  }
}

void _slice(Canvas cv, CelebrationContext c, Offset p, double size, double rot,
    double op) {
  _spr(cv, c, 'limon_slice', Offset(p.dx.clamp(_minX + size / 2, _maxX - size / 2), p.dy),
      size, rot: rot, op: op);
}

void _rotor(Canvas cv, CelebrationContext c, Offset p, double w, double angle,
    double op) {
  final img = FxSprites.get('limon_umbrella_top');
  if (img == null || op <= 0.01) return;
  final o = (op * c.alpha).clamp(0.0, 1.0);
  final h = w * img.height / img.width;
  // Hareket bulanıklığı: birkaç açıda yarı saydam kopyalar.
  const n = 4;
  for (var i = 0; i < n; i++) {
    cv.save();
    cv.translate(p.dx, p.dy);
    cv.rotate(c.pose.rotation);
    cv.scale(1, 0.35);
    cv.rotate(angle + i * 0.11);
    cv.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(-w / 2, -h / 2, w, h),
      Paint()
        ..filterQuality = FilterQuality.medium
        ..color = Color.fromARGB(
          (o * (i == 0 ? 0.5 : 0.32) * 255).round(),
          255,
          255,
          255,
        ),
    );
    cv.restore();
  }
}

void limonCelebration(Canvas cv, CelebrationContext c) {
  final w = c.capWidth / c.pose.scale;
  if (c.reduceMotion) {
    // Sabit kare: mutlu yüz, şemsiye (ThermosPainter), limonata, birkaç dilim.
    _lemonade(cv, c, w, 1, 0.3, still: true);
    _slice(cv, c, const Offset(204, 452), 0.2 * w, 0.4, 1);
    _slice(cv, c, const Offset(476, 456), 0.2 * w, -0.5, 1);
    _slice(cv, c, const Offset(240, 462), 0.17 * w, 1.1, 1);
    return;
  }
  final t = c.t;
  // 1) Limonata: köpük, buz, kabarcık.
  _lemonade(cv, c, w, _eo(_sp(t, 0.06, 0.3)), t * 3);

  // 2) Şemsiye pervanesi (0.35 - 0.84).
  if (t >= 0.35 && t <= 0.84) {
    final m = _io(_sp(t, 0.35, 0.45)) * (1 - _io(_sp(t, 0.76, 0.84)));
    final cw = c.capWidth;
    final side = c.capImagePt(0.66, 0.24);
    final top = c.capImagePt(0.53, 0.17);
    final uw = 0.42 * cw;
    final pos = Offset.lerp(side, top, m)!;
    final rot = _lerp(0.5 + c.pose.rotation, c.pose.rotation, m);
    _spr(cv, c, 'limon_umbrella_side', pos, uw,
        rot: rot, op: 1 - m, at: const Alignment(0, 0.94));
    if (m > 0.02) {
      final hover = Offset(top.dx, top.dy + 0.02 * cw * m);
      _rotor(cv, c, hover, 0.85 * cw, t * _tau * 22, m);
    }
  }

  // 3) Limon dilimleri yağar ve dönerek düşer.
  for (var i = 0; i < 9; i++) {
    final s = 0.38 + 0.3 * c.rand(i, 1);
    final k = _sp(t, s, s + 0.2);
    if (k <= 0 || k >= 1) continue;
    final x = 195 + (_maxX - 195 - 40) * c.rand(i, 2) + 12 * math.sin(k * _tau * 2 + i);
    final y = _lerp(90, 462, k * (0.6 + 0.4 * k));
    final op = math.min(1.0, k * 8) * math.min(1.0, (1 - k) * 6);
    _slice(cv, c, Offset(x, y), (0.17 + 0.07 * c.rand(i, 3)) * w,
        k * _tau * (1.5 + c.rand(i, 4)) + i, op);
  }
}

void limonLoop(Canvas cv, CelebrationContext c) {
  final w = c.capWidth / c.pose.scale;
  final l = c.loop;
  _lemonade(cv, c, w, 1, l);
  for (var j = 0; j < 2; j++) {
    final k = _fract(l + j * 0.5);
    final x = (j == 0 ? 214.0 : 468.0) + 12 * math.sin(k * _tau);
    final y = _lerp(92, 462, k);
    _slice(cv, c, Offset(x, y), (0.18 + 0.03 * j) * w, k * _tau + j * 2,
        _hump(k) * 0.95);
  }
}
