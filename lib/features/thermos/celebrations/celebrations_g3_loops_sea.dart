import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'celebration_context.dart';
import 'celebrations_g3_kit.dart';
import 'celebrations_g3_loops.dart';
import 'celebrations_g3_sea.dart' show tentacle;

// GRUP 3 - SUREKLI DONGULER (kutup ve deniz). Bkz. celebrations_g3_loops.dart.

// --- Penguen -------------------------------------------------------------

CapPose penguenLoopPose(Ctx c) =>
    CapPose(dy: -4 * math.sin(tau * c.loop * 2).abs());

void _penguen(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  for (var i = 0; i < 20; i++) {
    final u = frac(l + c.rand(i, 1));
    final x =
        c.capCenter.dx +
        (c.rand(i, 2) - 0.5) * 330 +
        math.sin(u * tau * 2 + i) * 14;
    final y = 14 + u * 420;
    final op = clamp01(u / 0.08) * (1 - clamp01((u - 0.88) / 0.12));
    snowflake(
      c,
      cv,
      Offset(x, y),
      5.5 + 6.5 * c.rand(i, 3),
      u * tau * (c.rand(i, 4) - 0.5) * 3,
      op * 0.95,
    );
  }
  final th = 0.95 + 0.75 * sn(l, 5);
  final len = (c.chubby ? 84.0 : 56.0) * capK(c);
  for (final side in const [-1.0, 1.0]) {
    final pivot = c.hasIllustratedCap
        ? c.capCenter + Offset(side * c.capWidth * 0.34, c.capWidth * 0.34)
        : side < 0
        ? at(c, 256, 170, 286, 150)
        : at(c, 424, 170, 394, 150);
    final dir = Offset(side * math.sin(th), math.cos(th));
    final ctr = pivot + dir * len * 0.5;
    final ang = math.atan2(dir.dy, dir.dx);
    cv.save();
    cv.translate(ctr.dx, ctr.dy);
    cv.rotate(ang);
    final h = len * 0.4;
    cv.drawOval(
      Rect.fromCenter(center: Offset.zero, width: len, height: h),
      fillP(c, 0x2B3A55),
    );
    cv.drawOval(
      Rect.fromCenter(
        center: Offset(-len * 0.05, -h * 0.12),
        width: len * 0.82,
        height: h * 0.5,
      ),
      fillP(c, 0x4A5C7C, 0.85),
    );
    cv.restore();
    cv.drawCircle(pivot, 5 * k, fillP(c, 0x2B3A55));
  }
}

// --- Fok -----------------------------------------------------------------

const int _fokBounces = 3;

CapPose fokLoopPose(Ctx c) {
  final f = frac(c.loop * _fokBounces + 0.1);
  final contact = f < 0.2 ? bell(f / 0.2) : 0.0;
  return CapPose(dy: 3.2 * contact, rotation: sn(c.loop, 1) * 0.035);
}

void _fok(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final f = frac(l * _fokBounces + 0.1);
  final nose = c.nose;
  final r = 30 * k + 1;
  final h = (c.chubby ? 80.0 : 62.0) * (1 - (2 * f - 1) * (2 * f - 1));
  final xo = sn(l, 1) * c.capWidth * 0.08;
  final squash = h < 3 ? 1 - 0.16 * (1 - h / 3) : 1.0;
  final ctr = nose + Offset(xo, -(r * 0.92) - h);
  final spin = tau * l * 4;
  cv.drawOval(
    Rect.fromCenter(
      center: nose + Offset(xo, -2 * k),
      width: r * (1.3 - 0.4 * h / 70),
      height: r * 0.28,
    ),
    fillP(c, 0x2A3540, 0.18),
  );
  cv.save();
  cv.translate(ctr.dx, ctr.dy + r * (1 - squash));
  cv.scale(1 + (1 - squash) * 0.8, squash);
  cv.clipPath(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r)));
  const cols = [0xF2677A, 0xFFFFFF, 0x4BA3E3, 0xFFC93C, 0xFFFFFF, 0x6FCF97];
  for (var i = 0; i < cols.length; i++) {
    final a0 = spin + i * tau / cols.length;
    cv.drawPath(
      Path()
        ..moveTo(0, 0)
        ..arcTo(
          Rect.fromCircle(center: Offset.zero, radius: r * 1.2),
          a0,
          tau / cols.length + 0.01,
          false,
        )
        ..close(),
      fillP(c, cols[i]),
    );
  }
  cv.drawCircle(Offset.zero, r * 0.17, fillP(c, 0xFFFFFF));
  cv.drawCircle(Offset(-r * 0.35, -r * 0.4), r * 0.28, fillP(c, 0xFFFFFF, 0.5));
  cv.restore();
  cv.drawCircle(ctr, r, lineP(c, 0x2A3540, 1.3, 0.5));
  final hit = 1 - clamp01(f / 0.22);
  if (hit > 0 && f < 0.22) {
    for (final d in const [-1.0, 1.0]) {
      sparkle(
        cv,
        nose + Offset(d * r * 1.25, -r * 0.5),
        14 * k * hit + 1,
        fillP(c, 0xFFF1A0),
      );
    }
  }
  for (var i = 0; i < 6; i++) {
    final u = frac(l + c.rand(i, 1));
    final p = Offset(c.capCenter.dx + (c.rand(i, 2) - 0.5) * 300, 20 + u * 300);
    cv.drawCircle(
      p,
      2 + 1.8 * c.rand(i, 3),
      fillP(c, 0xFFFFFF, 0.85 * bell(u)),
    );
  }
}

// --- Su Samuru -----------------------------------------------------------

CapPose samuruLoopPose(Ctx c) => CapPose(
  dy: -3 * math.sin(tau * c.loop * 2).abs(),
  rotation: sn(c.loop, 2) * 0.03,
);

void _susamuru(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final cc = c.capCenter;
  final L = c.capWidth * 0.8;
  final baseY = c.mouth.dy + 6 * k;
  final peak = math.max(60.0, c.capTop.dy - 60 * k);
  for (var j = 0; j < 2; j++) {
    final s = frac(2 * l + j / 2) * 2;
    final idx = s.floor();
    final u = s - idx;
    final ltr = idx == 0;
    final fromX = ltr ? cc.dx - L : cc.dx + L;
    final toX = ltr ? cc.dx + L : cc.dx - L;
    Offset pos(double uu) => Offset(
      Ctx.lerp(fromX, toX, uu),
      baseY - 4 * uu * (baseY - peak) * (1 - uu),
    );
    for (var q = 1; q <= 4; q++) {
      final uu = u - q * 0.04;
      if (uu <= 0) continue;
      cv.drawCircle(
        pos(uu) + Offset(0, q * 3.0),
        (3.2 - q * 0.5) * k + 0.8,
        fillP(c, 0xBFE6FA, 0.8),
      );
    }
    final rot = s * math.pi;
    fish(c, cv, pos(u), 1.0 * (0.9 + 0.8 * k) + 0.25, rot, 1);
    final sp = u < 0.2 ? u / 0.2 : (u > 0.85 ? (1 - u) / 0.15 : 1.0);
    if (u < 0.2 || u > 0.85) {
      final edge = u < 0.5 ? fromX : toX;
      cv.drawOval(
        Rect.fromCenter(
          center: Offset(edge, baseY),
          width: (24 - 14 * sp) * k + 6,
          height: (8 - 4 * sp) * k + 2,
        ),
        lineP(c, 0xFFFFFF, 1.6, 0.4 + 0.5 * (1 - sp)),
      );
    }
  }
  for (var i = 0; i < 12; i++) {
    final u = frac(2 * l + c.rand(i, 1));
    final side = c.rand(i, 2) < 0.5 ? -1.0 : 1.0;
    final x =
        cc.dx +
        side * c.capWidth * (0.52 + 0.3 * c.rand(i, 3)) +
        math.sin(u * tau * 2 + i) * 7;
    final y = cc.dy + 46 * k - u * 150;
    final r = (5 + 8 * c.rand(i, 4)) * (0.65 + 0.35 * k + 0.1);
    final op = clamp01(u / 0.1) * (1 - clamp01((u - 0.75) / 0.25));
    bubble(c, cv, Offset(x, y), r, op, tint: 0x8FD3F0);
  }
}

// --- Balina --------------------------------------------------------------

CapPose balinaLoopPose(Ctx c) =>
    CapPose(dy: -2.5 * math.sin(tau * c.loop * 2).abs());

void _balina(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final o = c.hasIllustratedCap
      ? c.capTop + Offset(0, c.capWidth * 0.1)
      : at(c, 340, 58, 340, 92);
  const g = 560.0;
  const cols = [0x7FC4EA, 0xFFFFFF, 0x4D9BD0, 0xFFFFFF];
  final pulse = 0.5 + 0.5 * sn(l, 2, -0.25);
  final hCol = (c.chubby ? 66.0 : 50.0) * (0.45 + 0.55 * pulse);
  final colTop = o + Offset(0, -hCol);
  cv.drawLine(o, colTop, lineP(c, 0x8FCDEE, 14 * k + 3, 0.95));
  cv.drawLine(o, colTop, lineP(c, 0xFFFFFF, 6 * k + 1.5, 0.95));
  puff(c, cv, colTop + Offset(0, -2), (7 + 5 * pulse) * k + 3, 0xFFFFFF, 0.9);
  const n = 72;
  const life = 0.2;
  for (var i = 0; i < n; i++) {
    final te = i / n;
    final age = frac(l - te);
    if (age >= life) continue;
    final u = age / life;
    final tt = age * 3.2;
    final str = 0.55 + 0.45 * (0.5 + 0.5 * sn(te, 2, -0.25));
    final vx = (c.rand(i, 1) - 0.5) * 2 * 120 * str;
    final vy = -(150 + 60 * c.rand(i, 2)) * str;
    final p = o + Offset(vx * tt, -hCol * 0.7 + vy * tt + 0.5 * g * tt * tt);
    final ang = math.atan2(vy + g * tt, vx);
    final op = clamp01(u / 0.07) * (1 - clamp01((u - 0.78) / 0.22));
    waterDrop(
      c,
      cv,
      p,
      (5.6 + 3.6 * c.rand(i, 3)) * (0.9 + 0.2 * k),
      ang,
      op,
      base: cols[i % 4],
    );
  }
  for (var j = 0; j < 2; j++) {
    final p = frac(2 * l + j * 0.5);
    cv.drawOval(
      Rect.fromCenter(
        center: o,
        width: (16 + 50 * p) * k,
        height: (6 + 13 * p) * k,
      ),
      lineP(c, 0xFFFFFF, 2 * k + 0.5, (1 - p) * clamp01(p / 0.1) * 0.9),
    );
  }
}

// --- Okyanus (kopek baligi) ----------------------------------------------

CapPose okyanusLoopPose(Ctx c) =>
    CapPose(dy: -2 * hump(c.loop, 2), rotation: sn(c.loop, 1) * 0.04);

void _okyanus(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final w = c.capWidth;
  final center = c.capCenter + Offset(0, w * 0.28);
  final rx = w * 0.8, ry = w * 0.3;
  Offset orbit(double th) =>
      center + Offset(math.cos(th) * rx, math.sin(th) * ry);
  double theta(double lp) => tau * lp + 0.7;
  final th = theta(l);
  final p = orbit(th);
  final sgn = -math.sin(th) >= 0 ? 1.0 : -1.0;
  for (var j = 1; j <= 11; j++) {
    final q = orbit(th - j * 0.13);
    cv.drawOval(
      Rect.fromCenter(
        center: q,
        width: (28 + j * 2.6) * k + 6,
        height: (8 + j * 0.7) * k + 2,
      ),
      lineP(c, 0xFFFFFF, 2.6, 1 - j / 12),
    );
  }
  cv.drawOval(
    Rect.fromCenter(
      center: p + const Offset(0, 1),
      width: 52 * k + 8,
      height: 13 * k + 3,
    ),
    fillP(c, 0xFFFFFF, 0.65),
  );
  final fs = 1.0 + 0.7 * k;
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.scale(sgn * fs, fs);
  final fin = Path()
    ..moveTo(13, 0)
    ..quadraticBezierTo(4, -11, -6, -30)
    ..quadraticBezierTo(-6, -9, -15, 0)
    ..close();
  cv.drawPath(fin, fillP(c, 0x5C7C94));
  cv.drawPath(
    Path()
      ..moveTo(3, -3)
      ..quadraticBezierTo(-1, -10, -5, -22)
      ..quadraticBezierTo(-4, -9, -8, -3)
      ..close(),
    fillP(c, 0xA9C4D6, 0.75),
  );
  cv.drawPath(fin, lineP(c, 0x4F6F88, 2.0));
  cv.restore();
  for (var i = 0; i < 9; i++) {
    final age = frac(2 * l + c.rand(i, 1)) * 0.3;
    final q = orbit(theta(l - age));
    final y = q.dy - age / 0.3 * 64 * (0.8 + 0.2 * k);
    final x = q.dx + math.sin(age * 40 + i) * 5;
    final op = (1 - age / 0.3) * clamp01(age / 0.03);
    bubble(
      c,
      cv,
      Offset(x, y),
      (5 + 5 * c.rand(i, 2)) * (0.7 + 0.3 * k + 0.1),
      op,
    );
  }
}

// --- Ahtapot -------------------------------------------------------------

CapPose ahtapotLoopPose(Ctx c) =>
    CapPose(rotation: sn(c.loop, 2) * 0.05, dy: -2 * hump(c.loop, 4));

void _ahtapot(Canvas cv, Ctx c, double l) {
  final k = capK(c);
  final ph = tau * l * 5;
  final len = (c.chubby ? 105.0 : 72.0) * k;
  final amp = 15.0 * k;
  const angs = [-0.95, -0.15, 0.6];
  for (final side in const [-1.0, 1.0]) {
    final root = c.hasIllustratedCap
        ? c.capCenter + Offset(side * c.capWidth * 0.3, c.capWidth * 0.38)
        : side < 0
        ? at(c, 262, 186, 292, 162)
        : at(c, 418, 186, 388, 162);
    for (var j = 0; j < angs.length; j++) {
      final a = angs[j];
      final dir = Offset(side * math.cos(a), math.sin(a));
      tentacle(
        c,
        cv,
        root,
        dir,
        len * (1 - j * 0.07),
        amp,
        ph + j * 1.1 + (side + 1) * 0.8,
        11 * k + 2,
      );
    }
  }
  const cols = [0x5B2A6B, 0x7A1F44, 0x6B3380];
  for (var i = 0; i < 8; i++) {
    final u = frac(2 * l + i / 8 * 2);
    final side = i.isEven ? -1.0 : 1.0;
    final x =
        c.capCenter.dx +
        side *
            (c.capWidth * 0.14 + u * c.capWidth * 0.34 * (0.5 + c.rand(i, 1))) +
        math.sin(u * tau + i) * 6;
    final y = c.capTop.dy + 24 * k - u * 84;
    final s = (7 + 8 * Ctx.easeOut(u)) * (0.7 + 0.35 * k);
    final op = clamp01(u / 0.12) * (1 - clamp01((u - 0.7) / 0.3));
    final hc = Offset(x, y);
    cv.drawCircle(hc, s * 1.5, glowP(c, cols[i % 3], s * 0.8, 0.28 * op));
    heart(
      c,
      cv,
      hc,
      s,
      cols[i % 3],
      0.92 * op,
      rot: math.sin(u * tau + i) * 0.35,
    );
    cv.drawCircle(
      hc + Offset(-s * 0.5, -s * 0.35),
      s * 0.2,
      fillP(c, 0xFFFFFF, 0.55 * op),
    );
  }
}

final Map<String, SignatureCelebration> g3SeaLoops = {
  'penguen': loopOf(_penguen),
  'fok': loopOf(_fok),
  'susamuru': loopOf(_susamuru),
  'balina': loopOf(_balina),
  'okyanus': loopOf(_okyanus),
  'ahtapot': loopOf(_ahtapot),
};

const Map<String, CapPoseFn> g3SeaLoopPoses = {
  'penguen': penguenLoopPose,
  'fok': fokLoopPose,
  'susamuru': samuruLoopPose,
  'balina': balinaLoopPose,
  'okyanus': okyanusLoopPose,
  'ahtapot': ahtapotLoopPose,
};
