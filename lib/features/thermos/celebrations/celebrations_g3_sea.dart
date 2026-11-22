import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'celebration_context.dart';
import 'celebrations_g3_kit.dart';

// Grup 3 - kutup ve deniz: penguen, fok, su samuru, balina, okyanus (kopek
// baligi), ahtapot. Konumlar themes/pack_hayvanlar, pack_yeni3 ve pack_doga
// kapak cizimlerinin ham koordinatlarindan (capPt) alinmistir.

// --- Penguen: kanat cirpar, kar taneleri -----------------------------------

CapPose penguenPose(Ctx c) {
  final env = win(c, 0.03, 0.92);
  return CapPose(dy: -5 * math.sin(c.t * tau * 2.5).abs() * env);
}

void penguen(Canvas cv, Ctx c) {
  final k = capK(c);
  // Kar taneleri.
  for (var i = 0; i < 20; i++) {
    final u = frac(c.t * 0.85 + c.rand(i, 1));
    final x =
        c.capCenter.dx +
        (c.rand(i, 2) - 0.5) * 330 +
        math.sin(u * tau * 2 + i) * 14;
    final y = 6 + u * 430;
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
  // Kanatlar: omuzdan acilip cirpar.
  final env = c.reduceMotion
      ? 1.0
      : Ctx.easeOut(c.span(0.03, 0.14)) * (1 - Ctx.easeInOut(c.span(0.88, 1)));
  final th = c.reduceMotion
      ? 1.15
      : 0.95 + 0.75 * math.sin(c.t * tau * 5) * env;
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
      fillP(c, 0x2B3A55, env),
    );
    cv.drawOval(
      Rect.fromCenter(
        center: Offset(-len * 0.05, -h * 0.12),
        width: len * 0.82,
        height: h * 0.5,
      ),
      fillP(c, 0x4A5C7C, 0.85 * env),
    );
    cv.restore();
    cv.drawCircle(pivot, 5 * k, fillP(c, 0x2B3A55, env));
  }
}

// --- Fok: burnunda top sektirir --------------------------------------------

const double _fokRate = 3.2;

CapPose fokPose(Ctx c) {
  final f = frac(c.t * _fokRate);
  final env = win(c, 0.0, 1.0).clamp(0.0, 1.0);
  final contact = 1 - clamp01(f / 0.16);
  return CapPose(
    dy: 3.4 * contact * env,
    rotation: math.sin(c.t * tau * 1.6) * 0.035 * env,
  );
}

void fok(Canvas cv, Ctx c) {
  final k = capK(c);
  final f = c.reduceMotion ? 0.62 : frac(c.t * _fokRate);
  final nose = c.nose;
  final r = 30 * k + 1;
  final h = (c.chubby ? 92.0 : 84.0) * (1 - (2 * f - 1) * (2 * f - 1));
  final xo = c.reduceMotion
      ? 6.0
      : math.sin(c.t * tau * 1.3) * c.capWidth * 0.07;
  final squash = h < 3 ? 1 - 0.16 * (1 - h / 3) : 1.0;
  final ctr = nose + Offset(xo, -(r * 0.92) - h);
  final spin = c.t * tau * 4;
  // Golge.
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
  // Temas yildizlari.
  final hit = c.reduceMotion ? 0.0 : 1 - clamp01(f / 0.22);
  if (hit > 0) {
    for (final d in const [-1.0, 1.0]) {
      sparkle(
        cv,
        nose + Offset(d * r * 1.25, -r * 0.5),
        14 * k * hit + 1,
        fillP(c, 0xFFF1A0),
      );
    }
  }
  if (c.reduceMotion) {
    sparkle(cv, nose + Offset(-r * 1.4, -r * 1.5), 13 * k, fillP(c, 0xFFF1A0));
    sparkle(cv, nose + Offset(r * 1.6, -r * 1.9), 10 * k, fillP(c, 0xFFFFFF));
  }
  // Etrafta kar parcaciklari.
  for (var i = 0; i < 6; i++) {
    final u = frac(c.t * 0.8 + c.rand(i, 1));
    final p = Offset(c.capCenter.dx + (c.rand(i, 2) - 0.5) * 300, 8 + u * 300);
    cv.drawCircle(
      p,
      2 + 1.8 * c.rand(i, 3),
      fillP(c, 0xFFFFFF, 0.85 * clamp01(u / 0.1)),
    );
  }
}

// --- Su Samuru: balik ziplar, kabarciklar ----------------------------------

CapPose samuruPose(Ctx c) {
  final env = win(c, 0.03, 0.92);
  return CapPose(
    dy: -3 * math.sin(c.t * tau * 2).abs() * env,
    rotation: math.sin(c.t * tau * 2) * 0.03 * env,
  );
}

void susamuru(Canvas cv, Ctx c) {
  final k = capK(c);
  final cc = c.capCenter;
  final L = c.capWidth * 0.8;
  final baseY = c.mouth.dy + 6 * k;
  final peak = math.max(30.0, c.capTop.dy - 60 * k);
  void toss(double a, double b, bool ltr) {
    var u = c.span(a, b);
    if (c.reduceMotion) u = ltr ? 0.42 : 0.7;
    if (u <= 0 || u >= 1) return;
    final fromX = ltr ? cc.dx - L : cc.dx + L;
    final toX = ltr ? cc.dx + L : cc.dx - L;
    final x = Ctx.lerp(fromX, toX, u);
    final y = baseY - 4 * u * (baseY - peak) * (1 - u);
    final op = math.min(1.0, math.min(u / 0.08, (1 - u) / 0.1));
    final rot = (ltr ? 0.0 : math.pi) + u * tau * (ltr ? 1 : -1) * 1.0;
    // Iz damlaciklari.
    for (var j = 1; j <= 4; j++) {
      final uu = u - j * 0.04;
      if (uu <= 0) continue;
      final xx = Ctx.lerp(fromX, toX, uu);
      final yy = baseY - 4 * uu * (baseY - peak) * (1 - uu) + j * 3;
      cv.drawCircle(
        Offset(xx, yy),
        (3.2 - j * 0.5) * k + 0.8,
        fillP(c, 0xBFE6FA, op * 0.8),
      );
    }
    fish(c, cv, Offset(x, y), 1.0 * (0.9 + 0.8 * k) + 0.25, rot, op);
    if (u > 0.9 || u < 0.1) {
      cv.drawCircle(Offset(fromX, baseY), 8 * k, lineP(c, 0xFFFFFF, 1.5, 0.7));
    }
  }

  toss(0.06, 0.52, true);
  toss(0.4, 0.9, false);
  // Kabarciklar.
  for (var i = 0; i < 12; i++) {
    final u = frac(c.t * 0.9 + c.rand(i, 1));
    final side = c.rand(i, 2) < 0.5 ? -1.0 : 1.0;
    final x =
        cc.dx +
        side * c.capWidth * (0.42 + 0.35 * c.rand(i, 3)) +
        math.sin(u * tau * 2 + i) * 7;
    final y = cc.dy + 46 * k - u * 190;
    final r = (5 + 8 * c.rand(i, 4)) * (0.65 + 0.35 * k + 0.1);
    final op = clamp01(u / 0.1) * (1 - clamp01((u - 0.75) / 0.25));
    bubble(c, cv, Offset(x, y), r, op, tint: 0x8FD3F0);
  }
}

// --- Balina: tepeden su fiskiyesi ------------------------------------------

CapPose balinaPose(Ctx c) {
  final env = win(c, 0.03, 0.92);
  return CapPose(
    dy: -3 * math.sin(c.t * tau * 3).abs() * env,
    rotation: math.sin(c.t * tau * 1.5) * 0.025 * env,
  );
}

void balina(Canvas cv, Ctx c) {
  final k = capK(c);
  final o = c.hasIllustratedCap
      ? c.capTop + Offset(0, c.capWidth * 0.1)
      : at(c, 340, 58, 340, 92);
  const g = 560.0;
  const cols = [0x7FC4EA, 0xFFFFFF, 0x4D9BD0, 0xFFFFFF];
  // Gokkusagi yay (hafif).
  final env = c.reduceMotion ? 1.0 : win(c, 0.05, 0.9);
  // Fiskiye kolonu.
  final hCol =
      (c.chubby ? 52.0 : 60.0) * (0.85 + 0.15 * math.sin(c.t * tau * 5)) * env;
  final colTop = o + Offset(0, -hCol);
  cv.drawLine(o, colTop, lineP(c, 0x8FCDEE, 14 * k + 3, 0.95));
  cv.drawLine(o, colTop, lineP(c, 0xFFFFFF, 6 * k + 1.5, 0.95));
  puff(c, cv, colTop + Offset(0, -2), 10 * k + 3, 0xFFFFFF, 0.85 * env);
  // Damlalar.
  const n = 48;
  for (var i = 0; i < n; i++) {
    final t0 = 0.03 + i / n * 0.76;
    const life = 0.36;
    final u = (c.t - t0) / life;
    if (u <= 0 || u >= 1) continue;
    final tt = u * life * Ctx.duration;
    final vx = (c.rand(i, 1) - 0.5) * 2 * 130 * (0.8 + 0.2 * k);
    final vy = -(200 + 90 * c.rand(i, 2)) * (0.85 + 0.15 * k);
    final p = o + Offset(vx * tt, -hCol * 0.5 + vy * tt + 0.5 * g * tt * tt);
    final ang = math.atan2(vy + g * tt, vx);
    final op = clamp01(u / 0.07) * (1 - clamp01((u - 0.78) / 0.22));
    waterDrop(
      c,
      cv,
      p,
      (4.6 + 3.2 * c.rand(i, 3)) * (0.75 + 0.25 * k + 0.15),
      ang,
      op,
      base: cols[i % 4],
      light: 0xFFFFFF,
    );
  }
  // Su yuzeyi halkalari tepede.
  for (var j = 0; j < 2; j++) {
    final p = c.reduceMotion ? 0.3 + j * 0.4 : frac(c.t * 1.8 + j * 0.5);
    cv.drawOval(
      Rect.fromCenter(
        center: o,
        width: (16 + 46 * p) * k,
        height: (6 + 12 * p) * k,
      ),
      lineP(c, 0xFFFFFF, 2 * k + 0.5, (1 - p) * 0.85 * env),
    );
  }
}

// --- Okyanus (kopek baligi): yuzgec daire cizer, kabarciklar ---------------

CapPose okyanusPose(Ctx c) {
  final env = win(c, 0.03, 0.92);
  return CapPose(
    dy: -2 * math.cos(c.t * tau * 3) * env,
    rotation: math.sin(c.t * tau * 1.5) * 0.04 * env,
  );
}

void okyanus(Canvas cv, Ctx c) {
  final k = capK(c);
  final W = c.capWidth;
  final center = c.capCenter + Offset(0, W * 0.28);
  final rx = W * 0.8, ry = W * 0.3;
  final tNow = c.reduceMotion ? 0.5 : c.t;
  Offset orbit(double th) =>
      center + Offset(math.cos(th) * rx, math.sin(th) * ry);
  double theta(double t) => t * tau * 1.5 + 0.7;
  final th = theta(tNow);
  final p = orbit(th);
  final sgn = -math.sin(th) >= 0 ? 1.0 : -1.0;
  final appear = c.reduceMotion ? 1.0 : clamp01(c.t / 0.07);
  // Izi: halkalar.
  for (var j = 1; j <= 11; j++) {
    final q = orbit(th - j * 0.13 * sgn.sign * (sgn > 0 ? 1 : 1));
    final op = (1 - j / 12) * appear;
    cv.drawOval(
      Rect.fromCenter(
        center: q,
        width: (28 + j * 2.6) * k + 6,
        height: (8 + j * 0.7) * k + 2,
      ),
      lineP(c, 0xFFFFFF, 2.6, op),
    );
  }
  // Su cizgisi fin altinda.
  cv.drawOval(
    Rect.fromCenter(
      center: p + Offset(0, 1),
      width: 52 * k + 8,
      height: 13 * k + 3,
    ),
    fillP(c, 0xFFFFFF, 0.65 * appear),
  );
  // Yuzgec.
  final fs = 1.0 + 0.7 * k;
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.scale(sgn * fs, fs);
  final fin = Path()
    ..moveTo(13, 0)
    ..quadraticBezierTo(4, -11, -6, -30)
    ..quadraticBezierTo(-6, -9, -15, 0)
    ..close();
  cv.drawPath(fin, fillP(c, 0x5C7C94, appear));
  cv.drawPath(
    Path()
      ..moveTo(3, -3)
      ..quadraticBezierTo(-1, -10, -5, -22)
      ..quadraticBezierTo(-4, -9, -8, -3)
      ..close(),
    fillP(c, 0xA9C4D6, 0.75 * appear),
  );
  cv.drawPath(fin, lineP(c, 0x4F6F88, 2.0, appear));
  cv.restore();
  // Kabarciklar: yorungeden ayrilip yukselir.
  for (var i = 0; i < 9; i++) {
    final age = frac(tNow * 1.4 + c.rand(i, 1)) * 0.3;
    final q = orbit(theta(tNow - age));
    final y = q.dy - age / 0.3 * 70 * (0.8 + 0.2 * k);
    final x = q.dx + math.sin(age * 40 + i) * 5;
    final op = (1 - age / 0.3) * clamp01(appear);
    bubble(
      c,
      cv,
      Offset(x, y),
      (5 + 5 * c.rand(i, 2)) * (0.7 + 0.3 * k + 0.1),
      op,
    );
  }
}

// --- Ahtapot: dokunaclar dalgalanir, kalp murekkep -------------------------

CapPose ahtapotPose(Ctx c) {
  final env = win(c, 0.03, 0.92);
  return CapPose(rotation: math.sin(c.t * tau * 4) * 0.05 * env, dy: -2 * env);
}

void tentacle(
  Ctx c,
  Canvas cv,
  Offset root,
  Offset dir,
  double len,
  double amp,
  double phase,
  double w0,
) {
  final perp = Offset(-dir.dy, dir.dx);
  const seg = 16;
  Offset pt(double s) {
    final wave = math.sin(s * math.pi * 2.2 - phase) * amp * s;
    return root + dir * (len * s) + perp * wave;
  }

  var prev = pt(0);
  final pts = <Offset>[prev];
  for (var i = 1; i <= seg; i++) {
    final q = pt(i / seg);
    final w = w0 * (1 - 0.72 * i / seg);
    cv.drawLine(prev, q, lineP(c, 0xB03A6B, w + 2.2));
    pts.add(q);
    prev = q;
  }
  prev = pts.first;
  for (var i = 1; i <= seg; i++) {
    final w = w0 * (1 - 0.72 * i / seg);
    cv.drawLine(prev, pts[i], lineP(c, 0xE4638F, w));
    prev = pts[i];
  }
  for (var i = 3; i <= seg; i += 3) {
    final w = w0 * (1 - 0.72 * i / seg);
    cv.drawCircle(
      pts[i] + perp * (w * 0.1),
      math.max(0.9, w * 0.2),
      fillP(c, 0xF9C2D6),
    );
  }
}

void ahtapot(Canvas cv, Ctx c) {
  final k = capK(c);
  final env = c.reduceMotion ? 1.0 : Ctx.easeOut(c.span(0.02, 0.14));
  final ph = c.reduceMotion ? 1.3 : c.t * tau * 5;
  final len = (c.chubby ? 105.0 : 72.0) * k * env;
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
  // Kalp seklinde murekkep puflari.
  const cols = [0x5B2A6B, 0x7A1F44, 0x6B3380];
  for (var i = 0; i < 8; i++) {
    final t0 = 0.05 + i * 0.085;
    const life = 0.5;
    final u = (c.t - t0) / life;
    if (u <= 0 || u >= 1) continue;
    final side = i.isEven ? -1.0 : 1.0;
    final x =
        c.mouth.dx +
        side *
            (c.capWidth * 0.12 + u * c.capWidth * 0.5 * (0.5 + c.rand(i, 1))) +
        math.sin(u * tau * 2 + i) * 6;
    final y = c.mouth.dy + 6 * k - u * 210 * (0.8 + 0.2 * k);
    final s = (7 + 11 * Ctx.easeOut(u)) * (0.65 + 0.35 * k + 0.1);
    final op = clamp01(u / 0.1) * (1 - clamp01((u - 0.7) / 0.3));
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
