import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../celebration_painter.dart';
import '../illustrated_artwork.dart';
import 'celebration_context.dart';
import 'celebrations_g3_kit.dart';
import 'celebrations_g3_land.dart' show antlerPath;

// GRUP 3 - SUREKLI DONGULER (kara hayvanlari). Hepsi ctx.loop degerinin tam
// sayi katlarinin periyodik fonksiyonlaridir; tur sonunda sicrama/solma olmaz.
// Cizimler zarfsiz (alfa=1) bir vekil baglamla yapilir.

typedef LoopFn = void Function(Canvas cv, Ctx c, double l);

/// [f]'yi tur evresiyle ve alfa zarfi olmayan bir baglamla cagiran imza.
SignatureCelebration loopOf(LoopFn f) => (cv, c) {
  final p = CelebrationPainter(
    theme: c.theme,
    shape: c.shape,
    t: 0.5,
    level: c.level,
    reduceMotion: c.reduceMotion,
  );
  f(cv, CelebrationContext(painter: p, level: c.level, pose: c.pose), c.loop);
};

double sn(double l, num n, [double ph = 0]) => math.sin(tau * (l * n + ph));
double cs(double l, num n, [double ph = 0]) => math.cos(tau * (l * n + ph));

/// 0..1 arasi yumusak salinim (0.5+0.5 sin).
double wv(double l, num n, [double ph = 0]) => 0.5 + 0.5 * sn(l, n, ph);

/// 0 -> 1 -> 0 (uclarda 0).
double bell(double u) => math.sin(clamp01(u) * math.pi);

/// 0 .. 1 .. 0, tur basinda 0 (1-cos)/2.
double hump(double l, num n) => (1 - cs(l, n)) / 2;

// --- Aslan ---------------------------------------------------------------

CapPose aslanLoopPose(Ctx c) {
  final h = hump(c.loop, 2);
  return CapPose(scale: 1 + 0.045 * h, dy: -2 * h);
}

void _aslan(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final rx = c.chubby ? 108.0 : 76.0, ry = c.chubby ? 92.0 : 58.0;
  final cy = c.chubby ? 132.0 : 128.0;
  final n = c.chubby ? 22 : 17;
  const cols = [0xE29A38, 0xC87625, 0xF0B456];
  for (var i = 0; i < n; i++) {
    final a = i / n * tau + 0.12;
    if (math.sin(a) > 0.8) continue;
    final base = c.capPt(340 + rx * math.cos(a), cy + ry * math.sin(a));
    final out = Offset(math.cos(a), math.sin(a));
    // Yele dalgasi yele boyunca dolasir.
    final w = wv(l, 2, -a / tau * 2);
    final len = (10 + 30 * w) * k;
    final r = (8.5 + 4 * c.rand(i, 3)) * k * (0.75 + 0.35 * w);
    final p = base + out * len * 0.5;
    final ang = math.atan2(out.dy, out.dx);
    teardrop(cv, p, r, ang, fillP(c, cols[i % 3]));
    teardrop(cv, p - out * r * 0.2, r * 0.55, ang, fillP(c, 0xFFD58A, 0.7));
  }
  // Kukreme halkalari (2 kez / tur).
  final m = c.mouth + Offset(0, -2 * k);
  for (var j = 0; j < 3; j++) {
    final p = frac(2 * l + j / 3);
    final r = (22 + 118 * p) * k;
    final op = (1 - p) * clamp01(p / 0.1) * 0.95;
    final w = 6.5 * k * (1 - p * 0.5);
    final rect = Rect.fromCircle(center: m, radius: r);
    for (final s in const [0.0, math.pi]) {
      cv.drawArc(
        rect,
        s - 0.62,
        1.24,
        false,
        lineP(c, 0xB8641A, w + 3.4 * k, op * 0.8),
      );
      cv.drawArc(rect, s - 0.62, 1.24, false, lineP(c, 0xFFF1BD, w, op));
    }
  }
  for (var i = 0; i < 6; i++) {
    final a = -math.pi * (0.1 + 0.8 * c.rand(i, 9));
    final ph = frac(2 * l + i / 6);
    final p = c.capPt(
      340 + (rx + 30) * math.cos(a),
      cy + (ry + 26) * math.sin(a),
    );
    sparkle(cv, p, 13 * k * bell(ph) + 0.5, fillP(c, 0xFFE08A));
  }
}

// --- Fil -----------------------------------------------------------------

CapPose filLoopPose(Ctx c) =>
    CapPose(rotation: -0.04 * sn(c.loop, 2), dy: -2 * hump(c.loop, 4));

void _fil(Canvas cv, Ctx c, double l) {
  final tip = c.hasIllustratedCap
      ? c.capTop + Offset(0, c.capWidth * 0.3)
      : at(c, 374, 174, 361, 148);
  final k = capK(c);
  const n = 64;
  const life = 0.3, g = 520.0;
  const cols = [0x4BA3E3, 0x9AD8F5, 0xFFFFFF, 0x2A93C9];
  for (var i = 0; i < n; i++) {
    final te = i / n;
    final age = frac(l - te);
    if (age >= life) continue;
    final u = age / life;
    final tt = age * 3.2;
    final vx = (115 + 75 * cs(te, 1)) * (0.88 + 0.24 * c.rand(i, 1));
    final vy = -(300 + 60 * sn(te, 2, 0.1) + 40 * c.rand(i, 2));
    final p = tip + Offset(vx * tt, vy * tt + 0.5 * g * tt * tt);
    final ang = math.atan2(vy + g * tt, vx);
    final op = clamp01(u / 0.08) * (1 - clamp01((u - 0.8) / 0.2));
    final r = (6.2 + 3.6 * c.rand(i, 5)) * (0.95 + 0.25 * k);
    waterDrop(c, cv, p, r, ang, op, base: cols[i % 4]);
  }
  final burst = 0.6 + 0.4 * wv(l, 4);
  cv.drawCircle(tip, (5 + 5 * burst) * k, glowP(c, 0xBFE6FA, 3, 0.8 * burst));
  cv.drawCircle(tip, (7 + 7 * burst) * k, lineP(c, 0xFFFFFF, 1.6, 0.7 * burst));
}

// --- Maymun --------------------------------------------------------------

CapPose maymunLoopPose(Ctx c) {
  final s = sn(c.loop, 1);
  return CapPose(rotation: s * 0.12, dx: s * 6);
}

Offset _arc(Offset a, Offset b, double u, double peakY) => Offset(
  Ctx.lerp(a.dx, b.dx, u),
  Ctx.lerp(a.dy, b.dy, u) - 4 * u * (1 - u) * (a.dy - peakY),
);

void _maymun(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final earL = at(c, 218, 134, 262, 126);
  final earR = at(c, 462, 134, 418, 126);
  final peak = math.max(58.0, c.capTop.dy - 60 * k);
  for (var j = 0; j < 3; j++) {
    final s = frac(2 * l + j / 3) * 2;
    final idx = s.floor();
    final u = s - idx;
    final ltr = idx == 0;
    final from = ltr ? earL : earR, to = ltr ? earR : earL;
    final p = _arc(from, to, u, peak);
    for (var q = 1; q <= 3; q++) {
      final uu = u - q * 0.035;
      if (uu <= 0) continue;
      cv.drawCircle(
        _arc(from, to, uu, peak),
        (5.4 - q * 1.1) * k + 0.8,
        fillP(c, 0xFFE58F, 0.6),
      );
    }
    banana(c, cv, p, 2.0 + 0.8 * k, s * tau, 1);
    final catchU = u > 0.9 ? (u - 0.9) / 0.1 : (u < 0.1 ? 1 - u / 0.1 : 0.0);
    if (catchU > 0) {
      sparkle(
        cv,
        (u > 0.5 ? to : from) + Offset(0, -10 * k),
        18 * k * bell(catchU),
        fillP(c, 0xFFF1A0),
      );
    }
  }
}

// --- Geyik ---------------------------------------------------------------

CapPose geyikLoopPose(Ctx c) => CapPose(dy: -2.5 * hump(c.loop, 2));

void _geyik(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final pulseV = 0.7 + 0.3 * sn(l, 2);
  final ants = c.chubby
      ? const [(-1, 304.0, 76.0, 1.05), (1, 376.0, 76.0, 1.05)]
      : const [(-1, 292.0, 98.0, 0.78), (1, 388.0, 98.0, 0.78)];
  for (final (d, x, y, s) in ants) {
    final path = antlerPath(c, d, x, y, s);
    cv.drawPath(
      path,
      glowP(c, 0xFFE08A, 9 * k + 2, 0.85 * pulseV)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11 * k
        ..strokeCap = StrokeCap.round,
    );
    cv.drawPath(path, lineP(c, 0xFFF3C4, 3.4 * k, 0.9 * pulseV));
    var idx = 0;
    for (final (tx, ty) in const [
      (2.0, -54.0),
      (24.0, -48.0),
      (-12.0, -66.0),
      (4.0, -76.0),
    ]) {
      final p = c.capPt(x + d * tx * s, y + ty * s);
      final ph = frac(2 * l + idx * 0.25 + (d + 1) * 0.1);
      sparkle(cv, p, 14 * k * bell(ph) + 1, fillP(c, 0xFFFFFF));
      idx++;
    }
  }
  const wings = [
    (0xF2677A, 0xFFB3C1),
    (0xFFC93C, 0xFFE59A),
    (0x7EC8E3, 0xBFE6FA),
    (0xB57BDB, 0xDDBEF0),
    (0xFF9E5B, 0xFFD2AA),
  ];
  final cc = c.capCenter;
  final w = c.capWidth;
  for (var i = 0; i < 5; i++) {
    final a = tau * (l + i / 5);
    final p =
        cc +
        Offset(
          math.cos(a) * w * 0.8,
          math.sin(2 * a + i * 1.7) * w * 0.28 - w * 0.42,
        );
    final flap = cs(l, 10, i * 0.3);
    final (w1, w2) = wings[i];
    butterfly(
      c,
      cv,
      p,
      (15 + 5 * c.rand(i, 2)) * (0.6 + 0.4 * k) + 4,
      flap,
      math.sin(a) * 0.4,
      w1,
      w2,
      1,
    );
  }
}

// --- Rakun ---------------------------------------------------------------

CapPose rakunLoopPose(Ctx c) =>
    CapPose(rotation: sn(c.loop, 2) * 0.05, dy: -1.5 * hump(c.loop, 4));

void _rakun(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  // Maske goz kirpma (2 kez / tur).
  final wf = frac(2 * l + 0.2);
  final wink = wf < 0.16 ? bell(wf / 0.16) : 0.0;
  if (wink > 0.05 && !c.hasIllustratedCap) {
    final ctr = at(c, 378, 125, 363, 117);
    final rxp = (c.chubby ? 21.0 : 14.0) * k;
    final ryp = (c.chubby ? 14.0 : 9.5) * k;
    cv.drawOval(
      Rect.fromCenter(center: ctr, width: rxp * 2, height: ryp * 2),
      c.solid(0x24262C),
    );
    final a = at(c, 363, 128, 352, 118);
    final b = at(c, 393, 128, 374, 118);
    final m = at(c, 378, 133, 363, 121);
    cv.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(m.dx, m.dy, b.dx, b.dy),
      lineP(c, 0xFFFFFF, 4.4 * k, 1),
    );
    sparkle(
      cv,
      ctr + Offset(rxp * 1.2, -ryp * 1.5),
      16 * k * wink,
      c.solid(0xFFF1A0),
    );
  }
  // Paralar kapaktan firlayip geri duser.
  for (var i = 0; i < 7; i++) {
    final u = frac(2 * l + i / 7);
    final side = i.isEven ? -1.0 : 1.0;
    final x =
        c.capCenter.dx +
        side * c.capWidth * (0.1 + 0.34 * c.rand(i, 1)) +
        side * 18 * u;
    final y = c.capTop.dy + 16 * k - 54 * bell(u) * (0.8 + 0.3 * c.rand(i, 3));
    final r = (11 + 3.5 * c.rand(i, 4)) * (0.75 + 0.35 * k);
    final op = clamp01(u / 0.1) * clamp01((1 - u) / 0.1);
    coin(c, cv, Offset(x, y), r, tau * (2 * l + i * 0.37) * 2, op);
    sparkle(
      cv,
      Offset(x + r * 0.6, y - r * 0.7),
      r * 1.4 * bell(frac(4 * l + c.rand(i, 6))) * op,
      fillP(c, 0xFFFFFF),
    );
  }
  // Parlayan cevre kivilcimlari.
  for (var i = 0; i < 8; i++) {
    final a = tau * (i / 8) + 0.4;
    final p =
        c.capCenter +
        Offset(
          math.cos(a) * c.capWidth * 0.7,
          math.sin(a) * c.capWidth * 0.46 - c.capWidth * 0.1,
        );
    final ph = frac(2 * l + c.rand(i, 7));
    sparkle(cv, p, 14 * k * bell(ph) + 0.5, fillP(c, 0xF6E7B0, 0.95));
  }
}

// --- Kirpi ---------------------------------------------------------------

CapPose kirpiLoopPose(Ctx c) =>
    CapPose(scale: 1 + 0.035 * hump(c.loop, 3), rotation: sn(c.loop, 3) * 0.02);

void _kirpi(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final rx = c.chubby ? 100.0 : 66.0, ry = c.chubby ? 84.0 : 52.0;
  const cy = 126.0;
  final n = c.chubby ? 17 : 12;
  const cols = [0x4A3222, 0x6B4A2E, 0x8A6240];
  for (var i = 0; i < n; i++) {
    final a = (168 + (i + 0.5) / n * 204) * math.pi / 180;
    final base = c.capPt(
      340 + rx * 0.98 * math.cos(a),
      cy + ry * 0.98 * math.sin(a),
    );
    final out = Offset(math.cos(a), math.sin(a));
    final pf = wv(l, 3, i % 2 == 0 ? 0 : 0.25) * 0.7 + 0.3 * wv(l, 6, i * 0.13);
    final len = (8 + 60 * pf * (0.85 + 0.3 * c.rand(i, 2))) * k;
    final hw = 8.5 * k;
    final perp = Offset(-out.dy, out.dx);
    final tipP = base + out * len;
    final path = Path()
      ..moveTo(base.dx + perp.dx * hw, base.dy + perp.dy * hw)
      ..lineTo(tipP.dx, tipP.dy)
      ..lineTo(base.dx - perp.dx * hw, base.dy - perp.dy * hw)
      ..close();
    cv.drawPath(path, fillP(c, cols[i % 3]));
    cv.drawLine(base, tipP, lineP(c, 0xB48A5E, 1.3 * k, 0.55));
  }
  final r = 15 * k + 3;
  const offs = [-0.5, 0.2, 0.62, -0.1];
  for (var i = 0; i < offs.length; i++) {
    final yTopRaw = cy - ry * math.sqrt(1 - offs[i] * offs[i]) - 8;
    final target = c.capPt(340 + offs[i] * rx, yTopRaw);
    final u = wv(l, 3, i * 0.19);
    final ap = target + Offset(0, -2 - (c.chubby ? 22.0 : 9.0) * u);
    apple(c, cv, ap, r, 1);
    sparkle(
      cv,
      ap + Offset(r * 1.2, -r * 1.1),
      12 * k * bell(frac(3 * l + i * 0.25)) + 0.5,
      fillP(c, 0xFFE58F),
    );
  }
}

// --- Sincap --------------------------------------------------------------

CapPose sincapLoopPose(Ctx c) => CapPose(
  dy: -4 * math.sin(tau * c.loop * 2).abs(),
  rotation: sn(c.loop, 2) * 0.03,
);

void _sincap(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final bx = c.chubby ? 420.0 : 392.0, by = c.chubby ? 196.0 : 170.0;
  final s = c.chubby ? 1.0 : 0.62;
  const blobs = [
    (100.0, -40.0, 15.0),
    (94.0, -84.0, 16.0),
    (64.0, -128.0, 16.0),
  ];
  for (var i = 0; i < blobs.length; i++) {
    final (ox, oy, r) = blobs[i];
    final p = c.capPt(bx + ox * s, by + oy * s);
    final pul = wv(l, 3, -i * 0.18);
    final rr = r * s * k * (1.25 + 0.3 * pul);
    cv.drawCircle(p, rr, fillP(c, 0xDE8A3A));
    cv.drawCircle(
      p + Offset(-rr * 0.2, -rr * 0.2),
      rr * 0.6,
      fillP(c, 0xEDA255, 0.9),
    );
  }
  final tip = c.capPt(bx + 46 * s, by - 144 * s);
  final tipR = 25 * s * k * (1.3 + 0.25 * wv(l, 3, 0.1));
  cv.drawCircle(tip, tipR, fillP(c, 0xFBE3C0));
  cv.drawCircle(
    tip + Offset(-tipR * 0.25, -tipR * 0.25),
    tipR * 0.45,
    fillP(c, 0xFFFFFF, 0.55),
  );
  for (var i = 0; i < 9; i++) {
    final a = -math.pi * 0.95 + i / 8 * math.pi * 1.4;
    final d = Offset(math.cos(a), math.sin(a));
    final l1 = tipR * (1.2 + 0.16 * sn(l, 6, i / 9));
    cv.drawLine(
      tip + d * tipR * 0.92,
      tip + d * l1,
      lineP(c, 0xFBE3C0, 2.4 * k + 0.6, 0.9),
    );
  }
  for (var i = 0; i < 6; i++) {
    final u = frac(2 * l + i / 6);
    final a = -math.pi * (0.2 + 0.7 * c.rand(i, 2));
    final p =
        tip +
        Offset(
          math.cos(a) * (tipR + 40 * u),
          math.sin(a) * (tipR + 40 * u) - 8 * u,
        );
    cv.drawCircle(
      p,
      (5 + 2.5 * c.rand(i, 3)) * (1 - u * 0.4),
      fillP(c, 0xFBE3C0, bell(u) * 0.9),
    );
  }
  // Palamut hokkabazligi.
  final peak = math.max(56.0, c.capTop.dy - 50 * k);
  final left = Offset(c.capCenter.dx - c.capWidth * 0.3, c.capTop.dy + 18 * k);
  final right = Offset(c.capCenter.dx + c.capWidth * 0.3, c.capTop.dy + 18 * k);
  for (var j = 0; j < 3; j++) {
    final sx = frac(2 * l + j / 3) * 2;
    final idx = sx.floor();
    final u = sx - idx;
    final ltr = idx == 0;
    final p = _arc(ltr ? left : right, ltr ? right : left, u, peak);
    acorn(c, cv, p, (13 + 3 * c.rand(j, 4)) * (0.75 + 0.3 * k), sx * tau, 1);
  }
}

// --- Baykus --------------------------------------------------------------

CapPose baykusLoopPose(Ctx c) {
  final s = sn(c.loop, 1);
  return CapPose(rotation: 0.16 * s, dx: 3 * s);
}

void _baykus(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final bf = frac(2 * l + 0.3);
  final closing = bf < 0.14 ? bell(bf / 0.14) : 0.0;
  if (closing > 0.02 && !IllustratedArtwork.byId.containsKey('baykus')) {
    final eye = at(c, 302, 134, 316, 124);
    final rr = (c.chubby ? 30.5 : 18.0) * k;
    cv.save();
    cv.clipPath(Path()..addOval(Rect.fromCircle(center: eye, radius: rr)));
    final bottom = eye.dy - rr + closing * rr * 2.02;
    cv.drawRect(
      Rect.fromLTRB(eye.dx - rr, eye.dy - rr, eye.dx + rr, bottom),
      c.solid(0xFFF3D6),
    );
    cv.restore();
    cv.drawPath(
      Path()
        ..moveTo(eye.dx - rr * 0.8, bottom)
        ..quadraticBezierTo(
          eye.dx,
          bottom + rr * 0.3 * closing,
          eye.dx + rr * 0.8,
          bottom,
        ),
      c.solid(0x3A2412)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.2 * k,
    );
  }
  const cols = [0x8B6240, 0xB38A5E, 0xF3E3C4, 0xA67A50, 0xD9BD92];
  for (var i = 0; i < 8; i++) {
    final u = frac(l + i / 8);
    final side = i.isEven ? -1.0 : 1.0;
    final x0 = c.capCenter.dx + side * c.capWidth * (0.66 + 0.2 * c.rand(i, 1));
    final y0 = c.capTop.dy + 20 * k;
    final x = x0 + math.sin(u * tau * 2 + i) * 16 * k + side * 20 * u;
    final y = y0 - 14 * k * bell(u) + u * (140 + 30 * c.rand(i, 2));
    final op = clamp01(u / 0.1) * (1 - clamp01((u - 0.78) / 0.22));
    feather(
      c,
      cv,
      Offset(x, y),
      (26 + 8 * c.rand(i, 3)) * (0.7 + 0.3 * k),
      math.sin(u * tau * 2 + i) * 1.0 + 0.6,
      cols[i % 5],
      op,
    );
  }
}

final Map<String, SignatureCelebration> g3LandLoops = {
  'aslan': loopOf(_aslan),
  'fil': loopOf(_fil),
  'maymun': loopOf(_maymun),
  'geyik': loopOf(_geyik),
  'rakun': loopOf(_rakun),
  'kirpi': loopOf(_kirpi),
  'sincap': loopOf(_sincap),
  'baykus': loopOf(_baykus),
};

const Map<String, CapPoseFn> g3LandLoopPoses = {
  'aslan': aslanLoopPose,
  'fil': filLoopPose,
  'maymun': maymunLoopPose,
  'geyik': geyikLoopPose,
  'rakun': rakunLoopPose,
  'kirpi': kirpiLoopPose,
  'sincap': sincapLoopPose,
  'baykus': baykusLoopPose,
};
