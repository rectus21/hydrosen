import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'celebration_context.dart';
import 'celebrations_g3_kit.dart';

// Grup 3 - kara hayvanlari: aslan, fil, maymun, geyik, rakun, kirpi, sincap,
// baykus. Konumlar themes/pack_yeni1/2 ve pack_hayvanlar kapak cizimlerinin
// ham koordinatlarindan (capPt) alinmistir.

// --- Aslan: yele kabarir, kukreme ------------------------------------------

CapPose aslanPose(Ctx c) {
  final puff =
      Ctx.easeOut(c.span(0.03, 0.22)) * (1 - Ctx.easeInOut(c.span(0.86, 1)));
  final roar = win(c, 0.2, 0.85);
  return CapPose(
    scale: 1 + 0.07 * puff,
    dy: -3 * roar,
    rotation: math.sin(c.t * tau * 8) * 0.02 * roar,
  );
}

void aslan(Canvas cv, Ctx c) {
  final k = capK(c);
  final puffV = c.reduceMotion ? 1.0 : Ctx.easeOut(c.span(0.03, 0.25));
  final roar = c.reduceMotion ? 1.0 : win(c, 0.2, 0.85);
  final rx = c.chubby ? 108.0 : 76.0, ry = c.chubby ? 92.0 : 58.0;
  final cy = c.chubby ? 132.0 : 128.0;
  final n = c.chubby ? 22 : 17;
  const cols = [0xE29A38, 0xC87625, 0xF0B456];
  for (var i = 0; i < n; i++) {
    final a = i / n * tau + 0.12;
    if (math.sin(a) > 0.8) continue;
    final base = c.capPt(340 + rx * math.cos(a), cy + ry * math.sin(a));
    final out = Offset(math.cos(a), math.sin(a));
    final wob = c.reduceMotion
        ? 0.0
        : math.sin(c.t * tau * 7 + i * 1.7) * 0.18 * roar;
    final len = (4 + 30 * puffV * (1 + wob)) * k;
    final r = (8.5 + 4 * c.rand(i, 3)) * k * (0.35 + 0.65 * puffV);
    final p = base + out * len * 0.5;
    final ang = math.atan2(out.dy, out.dx);
    teardrop(cv, p, r, ang, fillP(c, cols[i % 3]));
    teardrop(cv, p - out * r * 0.2, r * 0.55, ang, fillP(c, 0xFFD58A, 0.7));
  }
  // Kukreme dalgalari: agizdan iki yana acilan yaylar.
  final m = c.mouth + Offset(0, -2 * k);
  for (var j = 0; j < 3; j++) {
    final p = c.reduceMotion
        ? 0.25 + j * 0.28
        : frac(c.span(0.2, 1.0) * 2.4 - j * 0.33);
    if (c.t < 0.2 && !c.reduceMotion) continue;
    final r = (22 + 120 * p) * k;
    final op = (1 - p) * (p < 0.08 ? p / 0.08 : 1) * 0.95;
    final w = 6.5 * k * (1 - p * 0.5);
    final rect = Rect.fromCircle(center: m, radius: r);
    for (final s in const [0.0, math.pi]) {
      cv.drawArc(
        rect,
        s - 0.62,
        1.24,
        false,
        lineP(c, 0x8A4A12, w + 2.4 * k, op * 0.45),
      );
      cv.drawArc(rect, s - 0.62, 1.24, false, lineP(c, 0xFFF1BD, w, op));
    }
  }
  // Yele parıltıları.
  for (var i = 0; i < 6; i++) {
    final a = -math.pi * (0.1 + 0.8 * c.rand(i, 9));
    final ph = frac(c.t * 2.2 + c.rand(i, 4));
    final p = c.capPt(
      340 + (rx + 30) * math.cos(a),
      cy + (ry + 26) * math.sin(a),
    );
    sparkle(cv, p, 13 * k * Ctx.pulse(ph) * puffV + 1, fillP(c, 0xFFE08A));
  }
}

// --- Fil: hortumdan su fiskirir --------------------------------------------

CapPose filPose(Ctx c) {
  final env = Ctx.pulse(c.span(0.03, 0.9));
  return CapPose(
    rotation: -0.07 * env + math.sin(c.t * tau * 5) * 0.012 * env,
    dy: -2 * env,
  );
}

void fil(Canvas cv, Ctx c) {
  final tip = at(c, 374, 174, 361, 148);
  final k = capK(c);
  const n = 48;
  const g = 520.0;
  const cols = [0x4BA3E3, 0x9AD8F5, 0xFFFFFF, 0x2A93C9];
  for (var i = 0; i < n; i++) {
    final sweep = i / n;
    final t0 = 0.04 + sweep * 0.68;
    const life = 0.5;
    final u = (c.t - t0) / life;
    if (u <= 0 || u >= 1) continue;
    final tt = u * life * Ctx.duration;
    final vx = 190 * math.cos(sweep * math.pi) * (0.85 + 0.3 * c.rand(i, 1));
    final vy = -(280 + 70 * c.rand(i, 2)) * (0.82 + 0.18 * k);
    final p = tip + Offset(vx * tt, vy * tt + 0.5 * g * tt * tt);
    final ang = math.atan2(vy + g * tt, vx);
    final op = (u < 0.08 ? u / 0.08 : 1.0) * (1 - clamp01((u - 0.75) / 0.25));
    final r = (4.6 + 3.0 * c.rand(i, 5)) * (0.75 + 0.25 * k + 0.2);
    waterDrop(c, cv, p, r, ang, op, base: cols[i % 4]);
  }
  // Hortum ucunda su topu ve halka.
  final burst = c.reduceMotion ? 1.0 : win(c, 0.03, 0.85);
  cv.drawCircle(tip, (5 + 5 * burst) * k, glowP(c, 0xBFE6FA, 3, 0.8 * burst));
  cv.drawCircle(tip, (7 + 6 * burst) * k, lineP(c, 0xFFFFFF, 1.6, 0.7 * burst));
}

// --- Maymun: muz firlatir, sallanir ----------------------------------------

CapPose maymunPose(Ctx c) {
  final env =
      Ctx.easeOut(c.span(0, 0.12)) * (1 - Ctx.easeInOut(c.span(0.85, 1)));
  final s = math.sin(c.t * tau * 2.2);
  return CapPose(rotation: s * 0.1 * env, dx: s * 4 * env);
}

void maymun(Canvas cv, Ctx c) {
  final k = capK(c);
  final earL = at(c, 218, 134, 262, 126);
  final earR = at(c, 462, 134, 418, 126);
  final peak = math.max(40.0, c.capTop.dy - 60 * k);
  void toss(double a, double b, bool ltr, double dir) {
    final u = c.span(a, b);
    if (u <= 0 || u >= 1) return;
    final from = ltr ? earL : earR, to = ltr ? earR : earL;
    final x = Ctx.lerp(from.dx, to.dx, u);
    final y = Ctx.lerp(from.dy, to.dy, u) - 4 * u * (1 - u) * (from.dy - peak);
    final op = math.min(1.0, math.min(u / 0.08, (1 - u) / 0.1));
    banana(c, cv, Offset(x, y), 2.0 + 0.8 * k, u * tau * 2.5 * dir, op);
    // Izli yildizlar.
    for (var j = 1; j <= 3; j++) {
      final uu = u - j * 0.035;
      if (uu <= 0) continue;
      final xx = Ctx.lerp(from.dx, to.dx, uu);
      final yy =
          Ctx.lerp(from.dy, to.dy, uu) - 4 * uu * (1 - uu) * (from.dy - peak);
      cv.drawCircle(
        Offset(xx, yy),
        (5.4 - j * 1.1) * k + 0.8,
        fillP(c, 0xFFE58F, op * 0.6),
      );
    }
  }

  toss(0.07, 0.55, true, 1);
  toss(0.32, 0.8, false, -1);
  // Yakalama yildizlari.
  for (final (a, p) in [(0.55, earR), (0.8, earL)]) {
    final u = (c.t - a) / 0.1;
    if (u > 0 && u < 1) {
      sparkle(
        cv,
        p + Offset(0, -10 * k),
        20 * k * Ctx.pulse(u),
        fillP(c, 0xFFF1A0),
      );
    }
  }
  if (c.reduceMotion) {
    sparkle(cv, earR + Offset(0, -10 * k), 14 * k, fillP(c, 0xFFF1A0));
  }
}

// --- Geyik: boynuzlar parlar, kelebekler -----------------------------------

Path antlerPath(Ctx c, int d, double x, double y, double s) {
  Offset p(double dx, double dy) => c.capPt(x + d * dx * s, y + dy * s);
  void q(Path path, Offset a, Offset b, Offset e) {
    path.moveTo(a.dx, a.dy);
    path.quadraticBezierTo(b.dx, b.dy, e.dx, e.dy);
  }

  final path = Path();
  q(path, p(0, 0), p(6, -26), p(2, -54));
  q(path, p(4, -22), p(18, -30), p(24, -48));
  q(path, p(3, -40), p(-8, -50), p(-12, -66));
  q(path, p(2, -54), p(6, -64), p(4, -76));
  return path;
}

void geyik(Canvas cv, Ctx c) {
  final k = capK(c);
  final env = c.reduceMotion ? 1.0 : Ctx.easeOut(c.span(0.04, 0.2));
  final pulseV = c.reduceMotion ? 1.0 : 0.65 + 0.35 * math.sin(c.t * tau * 3.2);
  final ants = c.chubby
      ? const [(-1, 304.0, 76.0, 1.05), (1, 376.0, 76.0, 1.05)]
      : const [(-1, 292.0, 98.0, 0.78), (1, 388.0, 98.0, 0.78)];
  for (final (d, x, y, s) in ants) {
    final path = antlerPath(c, d, x, y, s);
    cv.drawPath(
      path,
      glowP(c, 0xFFE08A, 9 * k + 2, 0.85 * env * pulseV)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11 * k
        ..strokeCap = StrokeCap.round,
    );
    cv.drawPath(path, lineP(c, 0xFFF3C4, 3.4 * k, 0.9 * env * pulseV));
    // Uc yildizlari.
    var idx = 0;
    for (final (tx, ty) in const [
      (2.0, -54.0),
      (24.0, -48.0),
      (-12.0, -66.0),
      (4.0, -76.0),
    ]) {
      final p = c.capPt(x + d * tx * s, y + ty * s);
      final ph = c.reduceMotion
          ? 0.5
          : frac(c.t * 2.4 + idx * 0.27 + (d + 1) * 0.1);
      sparkle(cv, p, 14 * k * Ctx.pulse(ph) * env + 1, fillP(c, 0xFFFFFF));
      idx++;
    }
  }
  // Kelebekler: kapak cevresinde sekiz cizen yorunge.
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
    final appear = clamp01((c.t - 0.1 - i * 0.04) / 0.1);
    if (appear <= 0) continue;
    final a = (c.reduceMotion ? 0.5 : c.t) * tau * 0.9 + i * tau / 5;
    final p =
        cc +
        Offset(
          math.cos(a + i) * w * 0.78,
          math.sin(a * 1.3 + i * 1.7) * w * 0.4 - w * 0.2,
        );
    final flap = c.reduceMotion ? 0.8 : math.cos(c.t * tau * 9 + i * 2);
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
      appear,
    );
  }
}

// --- Rakun: parlak paralar, maske goz kirpar --------------------------------

CapPose rakunPose(Ctx c) {
  final env = win(c, 0.05, 0.9);
  return CapPose(
    rotation: math.sin(c.t * tau * 2) * 0.045 * env,
    dy: -1.5 * env,
  );
}

void rakun(Canvas cv, Ctx c) {
  final k = capK(c);
  // Goz kirpma: sag goz duz cizgiye doner, yildiz parlar.
  final winkOn = c.reduceMotion
      ? 1.0
      : math.max(win(c, 0.2, 0.34), win(c, 0.6, 0.74)) > 0.02
      ? 1.0
      : 0.0;
  if (winkOn > 0) {
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
    sparkle(cv, ctr + Offset(rxp * 1.2, -ryp * 1.5), 14 * k, c.solid(0xFFF1A0));
  }
  // Para yagmuru.
  for (var i = 0; i < 13; i++) {
    final t0 = 0.04 + i * 0.05;
    const life = 0.5;
    final u = (c.t - t0) / life;
    if (u <= 0 || u >= 1) continue;
    final tt = u * life * Ctx.duration;
    final x0 = c.capCenter.dx + (c.rand(i, 1) - 0.5) * c.capWidth * 1.1;
    final y0 = c.capTop.dy + 14 * k;
    final vx = (c.rand(i, 2) - 0.5) * 120;
    final vy = -(215 + 90 * c.rand(i, 3)) * (0.8 + 0.2 * k);
    final p = Offset(x0 + vx * tt, y0 + vy * tt + 0.5 * 420 * tt * tt);
    final r = (11 + 3.5 * c.rand(i, 4)) * (0.65 + 0.35 * k + 0.1);
    final op = (u < 0.08 ? u / 0.08 : 1.0) * (1 - clamp01((u - 0.8) / 0.2));
    coin(c, cv, p, r, tt * (6 + 4 * c.rand(i, 5)), op);
    final ph = frac(u * 3 + c.rand(i, 6));
    sparkle(
      cv,
      p + Offset(r * 0.6, -r * 0.7),
      r * 1.5 * Ctx.pulse(ph) * op,
      fillP(c, 0xFFFFFF),
    );
  }
  // Mekan kivilcimlari.
  for (var i = 0; i < 6; i++) {
    final a = tau * (i / 6) + 0.4;
    final p =
        c.capCenter +
        Offset(
          math.cos(a) * c.capWidth * 0.68,
          math.sin(a) * c.capWidth * 0.46 - c.capWidth * 0.1,
        );
    final ph = c.reduceMotion ? 0.5 : frac(c.t * 1.8 + c.rand(i, 7));
    sparkle(cv, p, 12 * k * Ctx.pulse(ph) + 1, fillP(c, 0xF6E7B0, 0.95));
  }
}

// --- Kirpi: dikenler kabarir, elmalar duser --------------------------------

CapPose kirpiPose(Ctx c) {
  final puffV =
      Ctx.easeOut(c.span(0.04, 0.2)) * (1 - Ctx.easeInOut(c.span(0.85, 1)));
  final shake = win(c, 0.04, 0.3);
  return CapPose(
    scale: 1 + 0.05 * puffV,
    rotation: math.sin(c.t * tau * 10) * 0.03 * shake,
  );
}

void kirpi(Canvas cv, Ctx c) {
  final k = capK(c);
  final puffV = c.reduceMotion ? 1.0 : Ctx.easeOut(c.span(0.04, 0.28));
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
    final wob = c.reduceMotion ? 0.0 : math.sin(c.t * tau * 9 + i * 2.1) * 0.15;
    final len = (8 + 42 * puffV * (1 + wob) * (0.8 + 0.4 * c.rand(i, 2))) * k;
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
  // Dusen elmalar dikenlere saplanir.
  final r = 15 * k + 3;
  const offs = [-0.5, 0.2, 0.62, -0.1];
  for (var i = 0; i < offs.length; i++) {
    final dxr = offs[i] * rx;
    final yTopRaw = cy - ry * math.sqrt(1 - offs[i] * offs[i]) - 8;
    final target = c.capPt(340 + dxr, yTopRaw);
    final t0 = 0.1 + i * 0.13;
    var u = c.reduceMotion ? 1.0 : (c.t - t0) / 0.3;
    if (u <= 0) continue;
    u = u.clamp(0.0, 1.0);
    final y0 = -26.0;
    double y;
    if (u < 0.7) {
      final f = u / 0.7;
      y = Ctx.lerp(y0, target.dy, f * f);
    } else {
      final f = (u - 0.7) / 0.3;
      y = target.dy - 11 * math.sin(f * math.pi) * (1 - f * 0.3);
    }
    final ap = Offset(target.dx, y);
    apple(c, cv, ap, r, 1);
    if (u >= 0.7 && u < 0.85 && !c.reduceMotion) {
      sparkle(
        cv,
        ap + Offset(r * 1.2, -r * 1.1),
        12 * k + 2,
        fillP(c, 0xFFE58F),
      );
    }
  }
}

// --- Sincap: palamutlar firlar, kuyruk kabarir -----------------------------

CapPose sincapPose(Ctx c) {
  final env = win(c, 0.03, 0.9);
  return CapPose(
    dy: -6 * math.sin(c.t * tau * 2.5).abs() * env,
    rotation: math.sin(c.t * tau * 2.5) * 0.03 * env,
  );
}

void sincap(Canvas cv, Ctx c) {
  final k = capK(c);
  // Kuyruk kabarmasi.
  final bx = c.chubby ? 420.0 : 392.0, by = c.chubby ? 196.0 : 170.0;
  final s = c.chubby ? 1.0 : 0.62;
  final fl = c.reduceMotion ? 0.8 : Ctx.easeOut(c.span(0.06, 0.25));
  const blobs = [
    (100.0, -40.0, 15.0),
    (94.0, -84.0, 16.0),
    (64.0, -128.0, 16.0),
  ];
  for (var i = 0; i < blobs.length; i++) {
    final (ox, oy, r) = blobs[i];
    final p = c.capPt(bx + ox * s, by + oy * s);
    final pul = c.reduceMotion
        ? 0.5
        : 0.5 + 0.5 * math.sin(c.t * tau * 4 - i * 1.2);
    final rr = r * s * k * (1 + 0.4 * fl + 0.15 * pul * fl);
    cv.drawCircle(p, rr, fillP(c, 0xDE8A3A));
    cv.drawCircle(
      p + Offset(-rr * 0.2, -rr * 0.2),
      rr * 0.6,
      fillP(c, 0xEDA255, 0.9),
    );
  }
  final tip = c.capPt(bx + 46 * s, by - 144 * s);
  final pulT = c.reduceMotion ? 0.5 : 0.5 + 0.5 * math.sin(c.t * tau * 4);
  final tipR = 25 * s * k * (1 + 0.4 * fl + 0.12 * pulT * fl);
  cv.drawCircle(tip, tipR, fillP(c, 0xFBE3C0));
  cv.drawCircle(
    tip + Offset(-tipR * 0.25, -tipR * 0.25),
    tipR * 0.45,
    fillP(c, 0xFFFFFF, 0.55),
  );
  // Tuy telleri.
  for (var i = 0; i < 9; i++) {
    final a = -math.pi * 0.95 + i / 8 * math.pi * 1.4;
    final dirv = Offset(math.cos(a), math.sin(a));
    final l0 = tipR * 0.92,
        l1 = tipR * (1.18 + 0.12 * math.sin(c.t * tau * 5 + i) * fl);
    cv.drawLine(
      tip + dirv * l0,
      tip + dirv * l1,
      lineP(c, 0xFBE3C0, 2.4 * k + 0.6, 0.9 * fl),
    );
  }
  // Ucusan tuy puflari.
  for (var i = 0; i < 6; i++) {
    final u = frac(c.t * 1.6 + c.rand(i, 1));
    final a = -math.pi * (0.2 + 0.7 * c.rand(i, 2));
    final p =
        tip +
        Offset(
          math.cos(a) * (tipR + 44 * u),
          math.sin(a) * (tipR + 44 * u) - 8 * u,
        );
    cv.drawCircle(
      p,
      (5 + 2.5 * c.rand(i, 3)) * (1 - u * 0.4),
      fillP(c, 0xFBE3C0, (1 - u) * 0.9 * fl),
    );
  }
  // Palamutlar firlar.
  for (var i = 0; i < 6; i++) {
    final t0 = 0.05 + i * 0.09;
    const life = 0.46;
    final u = (c.t - t0) / life;
    if (u <= 0 || u >= 1) continue;
    final tt = u * life * Ctx.duration;
    final side = i.isEven ? -1.0 : 1.0;
    final x0 = c.capCenter.dx + side * c.capWidth * (0.12 + 0.2 * c.rand(i, 1));
    final y0 = c.capTop.dy + 16 * k;
    final vx = side * (40 + 90 * c.rand(i, 2));
    final vy = -(262 + 90 * c.rand(i, 3)) * (0.82 + 0.18 * k);
    final p = Offset(x0 + vx * tt, y0 + vy * tt + 0.5 * 560 * tt * tt);
    final op = (u < 0.06 ? u / 0.06 : 1.0) * (1 - clamp01((u - 0.82) / 0.18));
    acorn(
      c,
      cv,
      p,
      (12 + 3 * c.rand(i, 4)) * (0.65 + 0.35 * k + 0.1),
      tt * (3 + 3 * c.rand(i, 5)) * side,
      op,
    );
  }
}

// --- Baykus: kafa yatar, goz kirpar, tuyler suzulur ------------------------

CapPose baykusPose(Ctx c) {
  final tilt =
      Ctx.easeOut(c.span(0.06, 0.28)) * (1 - Ctx.easeInOut(c.span(0.74, 0.94)));
  return CapPose(rotation: 0.17 * tilt, dx: 2 * tilt);
}

void baykus(Canvas cv, Ctx c) {
  final k = capK(c);
  // Goz kirpma (sol goz acik cizilir, sag goz zaten kapali).
  final closing = c.reduceMotion
      ? 0.0
      : math.max(win(c, 0.34, 0.46), win(c, 0.6, 0.7));
  if (closing > 0.02) {
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
    final edge = Path()
      ..moveTo(eye.dx - rr * 0.8, bottom)
      ..quadraticBezierTo(
        eye.dx,
        bottom + rr * 0.3 * closing,
        eye.dx + rr * 0.8,
        bottom,
      );
    cv.drawPath(
      edge,
      c.solid(0x3A2412)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.2 * k,
    );
  }
  // Suzulen tuyler.
  const cols = [0x8B6240, 0xB38A5E, 0xF3E3C4, 0xA67A50, 0xD9BD92];
  for (var i = 0; i < 8; i++) {
    final t0 = 0.04 + i * 0.08;
    const life = 0.62;
    var u = (c.t - t0) / life;
    if (c.reduceMotion) u = 0.12 + i * 0.1;
    if (u <= 0 || u >= 1) continue;
    final side = i.isEven ? -1.0 : 1.0;
    final x0 = c.capCenter.dx + side * c.capWidth * (0.3 + 0.2 * c.rand(i, 1));
    final y0 = c.capTop.dy + 14 * k;
    final x = x0 + math.sin(u * tau * 1.4 + i) * 18 * k + side * 22 * u;
    final y =
        y0 - 18 * k * math.sin(u * math.pi) + u * (170 + 40 * c.rand(i, 2));
    final op = (u < 0.1 ? u / 0.1 : 1.0) * (1 - clamp01((u - 0.78) / 0.22));
    feather(
      c,
      cv,
      Offset(x, y),
      (26 + 8 * c.rand(i, 3)) * (0.7 + 0.3 * k),
      math.sin(u * tau * 1.7 + i) * 1.0 + 0.6,
      cols[i % 5],
      op,
    );
  }
}
