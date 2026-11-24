import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../illustrated_artwork.dart';
import 'celebration_context.dart';
import 'celebrations_g1_kit.dart';

// GRUP 1 (devam): robot, korsan, gece, sihirbaz, ejderha, maviejderha.

final Map<String, SignatureCelebration> g1MoreCelebrations = {
  'robot': _robotSparks,
  'korsan': _korsanTreasure,
  'gece': _geceDream,
  'sihirbaz': _sihirbazMagic,
  'ejderha': _ejderhaBreath,
  'maviejderha': _maviEjderhaBreath,
};

final Map<String, CapPoseFn> g1MoreCapPoses = {
  'robot': _robotPose,
  'korsan': _korsanPose,
  'gece': _gecePose,
  'sihirbaz': _sihirbazPose,
  'ejderha': _ejderhaPose,
  'maviejderha': _maviPose,
};

// --- Robot: anten kivilcimi, LED goz kirpma, donen disliler -------------------

CapPose _robotPose(CelebrationContext ctx) {
  final env = window(ctx, 0.04, 0.88);
  return CapPose(
    dx: math.sin(ctx.elapsed * 55) * 0.8 * env,
    rotation: math.sin(ctx.elapsed * 3.2) * 0.022,
    dy: math.sin(ctx.elapsed * 6.4).abs() * -1.4,
  );
}

void _gear(
  Canvas canvas,
  CelebrationContext ctx,
  Offset c,
  double r,
  int teeth,
  double rot,
  int body,
  int edge,
) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  final path = gearPath(r, teeth, rot);
  canvas.drawPath(path, ctx.paintOf(body, 0.96));
  canvas.drawPath(path, strokeOf(ctx.paintOf(edge, 0.95), 1.4));
  canvas.drawCircle(Offset.zero, r * 0.62, ctx.paintOf(edge, 0.55));
  canvas.drawCircle(Offset.zero, r * 0.34, ctx.paintOf(0x1E2A3A));
  canvas.drawCircle(
    Offset(-r * 0.12, -r * 0.14),
    r * 0.1,
    ctx.paintOf(0xFFFFFF, 0.5),
  );
  canvas.restore();
}

void _robotSparks(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final e = ctx.reduceMotion ? 0.0 : ctx.elapsed;

  // Disliller (basin iki yaninda)
  final cc = ctx.capCenter;
  for (final side in const [-1.0, 1.0]) {
    final cx = cc.dx + side * (ctx.capWidth / 2 + 34 * sz);
    final cy = cc.dy - 8 * sz;
    final spin = e * 1.9 * side;
    _gear(canvas, ctx, Offset(cx, cy), 15 * sz, 10, spin, 0xFAD36B, 0xC9951F);
    _gear(
      canvas,
      ctx,
      Offset(cx + side * 14 * sz, cy + 24 * sz),
      9 * sz,
      6,
      -spin * (15 / 9) + 0.3,
      0x8FA1B3,
      0x5F7184,
    );
  }

  // Anten kivilcimlari ve LED gozler kapak uzayinda.
  final illustratedRobot = IllustratedArtwork.byId.containsKey('robot');
  final ant = illustratedRobot
      ? (ctx.chubby ? const Offset(340, -8) : const Offset(340, 29))
      : (ctx.chubby ? const Offset(340, 22) : const Offset(340, 58));
  final ar = illustratedRobot
      ? (ctx.chubby ? 12.0 : 9.0)
      : (ctx.chubby ? 12.0 : 11.0);
  final ph = ctx.reduceMotion ? 0.3 : (ctx.t * 3.4 % 1.0);
  final cyc = (ctx.t * 3.4).floor();
  final cx = 340.0;
  final cy = ctx.chubby ? 128.0 : 126.0;
  final ex = ctx.chubby ? 26.0 : 20.0;
  final ey = 120.0;
  final r = ctx.chubby ? 11.0 : 8.0;

  inCap(canvas, ctx, () {
    // Anten parlamasi
    final flash = math.pow(1 - ph, 2).toDouble();
    canvas.drawCircle(
      ant,
      ar * (1.7 + 1.1 * flash),
      ctx.paintOf(0xFAD36B, 0.42 * (0.4 + flash))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Elektrik kivilcimlari
    for (var k = 0; k < 9; k++) {
      final seed = k + cyc * 11;
      final ang =
          -math.pi / 2 +
          (k / 9 - 0.5) * math.pi * 1.9 +
          (ctx.rand(seed, 2) - 0.5) * 0.3;
      final len = (12 + 22 * ctx.rand(seed, 3)) * (0.35 + ph * 0.85);
      final path = Path();
      var p = ant + Offset(math.cos(ang), math.sin(ang)) * ar;
      path.moveTo(p.dx, p.dy);
      for (var s = 1; s <= 3; s++) {
        final jitter = (ctx.rand(seed + s * 5, 4) - 0.5) * 9;
        p =
            ant +
            Offset(math.cos(ang), math.sin(ang)) * (ar + len * s / 3) +
            Offset(-math.sin(ang), math.cos(ang)) * jitter * (s < 3 ? 1 : 0.5);
        path.lineTo(p.dx, p.dy);
      }
      final a = (1 - ph * 0.9).clamp(0.0, 1.0);
      canvas.drawPath(
        path,
        strokeOf(ctx.paintOf(k.isEven ? 0xFAD36B : 0x7BF0FF, a), 2.4),
      );
      if (k % 3 == 0) {
        sparkle(canvas, p, 4 + 3 * ctx.rand(seed, 5), ctx.paintOf(0xFFFFFF, a));
      }
    }

    // Resimli robotun LED göz ifadesi normal/happy raster geçişindedir.
    // Vektör gözleri tekrar çizmek, gerçek gözlerin altına kayıp yüzü kapatır.
    if (illustratedRobot) return;

    // LED gozler: aralarda glow, kirpma anlarinda kapanir.
    double blink = 0;
    if (ctx.reduceMotion) {
      blink = 0;
    } else {
      for (final t0 in const [0.16, 0.34, 0.52, 0.7]) {
        final x = (ctx.t - t0) / 0.07;
        if (x > 0 && x < 1) blink = math.max(blink, math.sin(x * math.pi));
      }
    }
    final glow = ctx.reduceMotion ? 0.7 : 0.5 + 0.5 * math.sin(e * 9);
    for (final d in const [-1.0, 1.0]) {
      final px = cx + d * ex;
      if (blink > 0.25) {
        canvas.drawRect(
          Rect.fromLTRB(px - r - 6, ey - r * 0.5 - 7, px + r + 6, ey + 10),
          ctx.solid(0x14202E),
        );
        canvas.drawLine(
          Offset(px - r, ey + 2),
          Offset(px + r, ey + 2),
          strokeOf(ctx.solid(0x7BF0FF), ctx.chubby ? 4 : 3),
        );
      } else {
        canvas.drawCircle(
          Offset(px, ey - 1),
          r * 1.5,
          ctx.paintOf(0x7BF0FF, 0.2 + 0.18 * glow)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }
    // Ekranin kose LED'leri sirayla yanar
    final w2 = ctx.chubby ? 52.0 : 40.0, h2 = ctx.chubby ? 38.0 : 26.0;
    final lc = [
      Offset(cx - w2 + 8, cy + h2 - 8),
      Offset(cx + w2 - 8, cy + h2 - 8),
    ];
    for (var i = 0; i < 2; i++) {
      final on = ctx.reduceMotion ? i == 0 : ((e * 5).floor() % 2 == i);
      canvas.drawCircle(lc[i], 3.6, ctx.solid(on ? 0xFFFFFF : 0x14202E));
      canvas.drawCircle(
        lc[i],
        3,
        ctx.solid(i == 0 ? 0xE24B4A : 0xFAD36B, on ? 1 : 0.45),
      );
    }
  });
}

// --- Korsan: dalgalanan bayrak + altin para yagmuru ---------------------------

CapPose _korsanPose(CelebrationContext ctx) => CapPose(
  dy: math.sin(ctx.elapsed * 7) * 2.2,
  rotation: math.sin(ctx.elapsed * 3.6) * 0.035,
);

void _korsanTreasure(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final e = ctx.reduceMotion ? 0.4 : ctx.elapsed;

  // Bayrak
  // Direk şapkanın sağ omzuna saplı: şapka tepesinin üstünde ekranda yer
  // yok (üst çubuk), bu yüzden bayrak başın sağında, ekranın içinde durur.
  final base = IllustratedArtwork.byId.containsKey('korsan')
      ? ctx.capImagePt(0.84, 0.25)
      : ctx.capPt(340, ctx.chubby ? 54 : 90);
  final len = 40 * sz;
  final top = base + Offset(2 * sz, -len);
  canvas.drawLine(base, top, strokeOf(ctx.paintOf(0x6B3E16), 4.2 * sz));
  canvas.drawCircle(top + Offset(0, -2 * sz), 5 * sz, ctx.paintOf(0xFAC775));
  const cols = 12;
  final fw = 67 * sz, fh = 43 * sz;
  final topPts = <Offset>[], botPts = <Offset>[];
  for (var i = 0; i <= cols; i++) {
    final f = i / cols;
    final dy = math.sin(f * 7 - e * 10) * 6.5 * sz * f;
    final dx = f * fw * (1 - 0.04 * math.sin(f * 7 - e * 10) * f);
    topPts.add(top + Offset(2 + dx, 4 * sz + dy));
    botPts.add(top + Offset(2 + dx, 4 * sz + fh + dy));
  }
  final flag = Path()..moveTo(topPts.first.dx, topPts.first.dy);
  for (final p in topPts.skip(1)) {
    flag.lineTo(p.dx, p.dy);
  }
  for (final p in botPts.reversed) {
    flag.lineTo(p.dx, p.dy);
  }
  flag.close();
  canvas.drawPath(flag, ctx.paintOf(0x2C2C2A));
  canvas.drawPath(flag, strokeOf(ctx.paintOf(0x5F5E5A), 1.4 * sz));
  // Kafatasi + capraz kemik, bayragin ortasinda dalga ile birlikte.
  final mi = cols ~/ 2;
  final mid = Offset(
    (topPts[mi].dx + botPts[mi].dx) / 2,
    (topPts[mi].dy + botPts[mi].dy) / 2,
  );
  final slope =
      (topPts[mi + 1].dy - topPts[mi - 1].dy) /
      (topPts[mi + 1].dx - topPts[mi - 1].dx);
  canvas.save();
  canvas.translate(mid.dx, mid.dy);
  canvas.rotate(math.atan(slope));
  canvas.scale(sz * 1.36);
  final bone = strokeOf(ctx.paintOf(0xFFFFFF, 0.95), 2.4);
  canvas.drawLine(const Offset(-10, 8), const Offset(10, -4), bone);
  canvas.drawLine(const Offset(10, 8), const Offset(-10, -4), bone);
  canvas.drawCircle(const Offset(0, -2), 7.6, ctx.paintOf(0xFFFFFF));
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(-4.4, 3, 8.8, 5.6),
      const Radius.circular(2),
    ),
    ctx.paintOf(0xFFFFFF),
  );
  canvas.drawCircle(const Offset(-3, -2.5), 2, ctx.paintOf(0x2C2C2A));
  canvas.drawCircle(const Offset(3, -2.5), 2, ctx.paintOf(0x2C2C2A));
  canvas.drawPath(
    Path()
      ..moveTo(0, 0.6)
      ..lineTo(-1.2, 2.6)
      ..lineTo(1.2, 2.6)
      ..close(),
    ctx.paintOf(0x2C2C2A),
  );
  canvas.restore();

  // Altin paralar
  final origin = ctx.capCenter + Offset(0, -ctx.capWidth * 0.3);
  const n = 16;
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 1.15, start: 0.05, end: 0.84);
    if (!em.live) continue;
    // Paralar yüze düşmesin: kenarlara doğru fırlar.
    final a =
        -math.pi / 2 + (i.isEven ? 1 : -1) * (0.7 + 0.6 * rr(ctx, i, em, 1));
    final v = (150 + 70 * rr(ctx, i, em, 2)) * sz;
    final g = 480 * sz;
    final s = em.p * 1.5;
    final pos =
        origin +
        Offset(math.cos(a) * v * s, math.sin(a) * v * s + 0.5 * g * s * s);
    final spin = ctx.reduceMotion ? i * 1.3 : ctx.elapsed * 11 + i * 1.7;
    final cw = math.cos(spin).abs();
    final rad = (9 + 3 * rr(ctx, i, em, 3)) * sz;
    final fade = em.p > 0.85 ? (1 - em.p) / 0.15 : 1.0;
    final rect = Rect.fromCenter(
      center: pos,
      width: 2 * rad * math.max(0.16, cw),
      height: 2 * rad,
    );
    canvas.drawOval(rect, ctx.paintOf(0xFAC775, fade));
    canvas.drawOval(rect, strokeOf(ctx.paintOf(0xE8A317, fade), 1.6 * sz));
    if (cw > 0.5) {
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: rad * 1.1 * cw, height: rad * 1.1),
        strokeOf(ctx.paintOf(0xE8A317, 0.8 * fade), 1.2 * sz),
      );
    }
    if (cw < 0.3 || i % 4 == 0) {
      sparkle(
        canvas,
        pos + Offset(rad * 0.7, -rad * 0.7),
        5 * sz * (1 - cw * 0.5),
        ctx.paintOf(0xFFFFFF, 0.9 * fade),
        spin,
      );
    }
  }
}

// --- Gece: sallanan ay, z baloncuklari, kayan yildiz --------------------------

CapPose _gecePose(CelebrationContext ctx) {
  final s = math.sin(ctx.elapsed * tau * 0.95);
  return CapPose(
    rotation: s * 0.11,
    dx: s * 4,
    dy: -math.cos(s * 1.4).abs() * 2 + 2,
  );
}

void _geceDream(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);

  // Yildiz parlamalari (kenarlarda)
  for (var i = 0; i < 14; i++) {
    final left = ctx.rand(i, 3) < 0.5;
    final x = left ? 132 + ctx.rand(i, 4) * 112 : 436 + ctx.rand(i, 4) * 112;
    final y = 24 + ctx.rand(i, 5) * 440;
    final tw = ctx.reduceMotion
        ? (i % 3 == 0 ? 0.3 : 0.9)
        : math.max(0.0, math.sin(ctx.elapsed * 3.8 + i * 2.3));
    if (tw < 0.04) continue;
    sparkle(
      canvas,
      Offset(x, y),
      (3 + 8 * tw) * (0.7 + 0.5 * ctx.rand(i, 6)),
      ctx.paintOf(0xFFF1B8, tw),
      i.toDouble(),
    );
  }

  // Kayan yildizlar
  const streaks = [
    [560.0, 16.0, 150.0, 104.0, 0.1, 0.46],
    [330.0, 22.0, 125.0, 90.0, 0.52, 0.86],
  ];
  for (var k = 0; k < streaks.length; k++) {
    final s = streaks[k];
    final p = ctx.reduceMotion
        ? (k == 0 ? 0.55 : -1.0)
        : ((ctx.t - s[4]) / (s[5] - s[4]));
    if (p <= 0 || p >= 1) continue;
    final a = Offset(s[0], s[1]), b = Offset(s[2], s[3]);
    final head = Offset.lerp(a, b, CelebrationContext.easeOut(p))!;
    final dir = (b - a) / (b - a).distance;
    final tail = head - dir * 90 * sz;
    final f = math.sin(p * math.pi);
    canvas.drawLine(
      head,
      tail,
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFF1B8).withValues(alpha: f * ctx.alpha),
            const Color(0x00FFF1B8),
          ],
        ).createShader(Rect.fromPoints(head, tail)),
    );
    sparkle(canvas, head, 10 * sz, ctx.paintOf(0xFFFFFF, f), p * 8);
    canvas.drawCircle(head, 3, ctx.paintOf(0xFFFFFF, f));
  }

  // z baloncuklari
  final start = IllustratedArtwork.byId.containsKey('gece')
      ? ctx.capPt(ctx.chubby ? 400 : 382, ctx.chubby ? 81 : 90)
      : ctx.capCenter + Offset(ctx.capWidth * 0.42, -ctx.capWidth * 0.08);
  const n = 5;
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 1.7, start: 0.03, end: 0.82);
    if (!em.live) continue;
    final p = em.p;
    final grow = CelebrationContext.easeOut(math.min(1.0, p * 3));
    final r = (9 + 13 * p) * sz * grow;
    final c =
        start +
        Offset(
          math.sin(p * 6 + i * 1.4) * 10 * sz + p * 34 * sz,
          -p * 155 * sz,
        );
    final fade = p > 0.82 ? (1 - p) / 0.18 : 1.0;
    canvas.drawCircle(c, r, ctx.paintOf(0xBFD3FF, 0.2 * fade));
    canvas.drawCircle(c, r, strokeOf(ctx.paintOf(0xDCE6FF, 0.85 * fade), 1.8));
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.74),
      -2.6,
      0.9,
      false,
      strokeOf(ctx.paintOf(0xFFFFFF, 0.8 * fade), 1.6),
    );
    textAt(
      canvas,
      i.isEven ? 'Z' : 'z',
      c + Offset(0, r * 0.04),
      r * 1.25,
      ctx.paintOf(0xFFF1B8, fade),
      outline: strokeOf(ctx.paintOf(0x3C4AA8, 0.9 * fade), r * 0.22),
      rot: math.sin(p * 5 + i) * 0.25,
    );
  }
}

// --- Sihirbaz: asa, yildiz girdabi, siciyan sapka ---------------------------

CapPose _sihirbazPose(CelebrationContext ctx) {
  final sp = ctx.span(0.06, 0.54);
  final u = sp * 2;
  final h = math.sin(math.pi * u).abs();
  final live = sp > 0 && sp < 1 ? 1.0 : 0.0;
  final wig = window(ctx, 0.54, 0.9) * math.sin(ctx.elapsed * 9) * 0.035;
  return CapPose(
    dy: -14 * h * live,
    rotation: 0.07 * math.sin(math.pi * u) * live + wig,
    scale: 1 + (0.05 * h - 0.03 * (1 - h) * (1 - h)) * live,
  );
}

void _sihirbazMagic(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final e = ctx.reduceMotion ? 0.35 : ctx.elapsed;
  final illustratedWizard = IllustratedArtwork.byId.containsKey('sihirbaz');
  final c0 = Offset(
    340,
    illustratedWizard ? (ctx.chubby ? 106 : 112) : (ctx.chubby ? 152 : 127),
  );
  final halfW = illustratedWizard
      ? (ctx.chubby ? 105.0 : 76.0)
      : (ctx.chubby ? 69.0 : 56.0);
  final handle = c0 + Offset(halfW + 62 * sz, 48 * sz);
  final tip0 = c0 + Offset(halfW + 28 * sz, -6 * sz);
  final w = math.sin(e * 8) * 0.22;
  final v = tip0 - handle;
  final tip =
      handle +
      Offset(
        v.dx * math.cos(w) - v.dy * math.sin(w),
        v.dx * math.sin(w) + v.dy * math.cos(w),
      );

  // Girdap
  const n = 30;
  const cols = [0xFFDB70, 0xD9B8F5, 0xFFFFFF, 0xF59BC0, 0xA77BEC];
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 1.1, start: 0.05, end: 0.86);
    if (!em.live) continue;
    final p = em.p;
    final phi = rr(ctx, i, em, 1) * tau + p * tau * 1.6;
    final rad = (6 + 62 * CelebrationContext.easeOut(p)) * sz;
    final pos =
        tip +
        Offset(math.cos(phi) * rad, math.sin(phi) * rad * 0.8 - 26 * sz * p);
    final fade = p > 0.7 ? (1 - p) / 0.3 : 1.0;
    final sr = (3.2 + 3.6 * rr(ctx, i, em, 2)) * sz * (1 - p * 0.35);
    final col = cols[(i + em.cycle) % cols.length];
    if (i % 3 == 0) {
      ctx.star(canvas, pos, sr * 1.15, col, fade);
    } else {
      sparkle(canvas, pos, sr * 1.5, ctx.paintOf(col, fade), phi);
    }
  }

  // Asa
  canvas.drawLine(handle, tip, strokeOf(ctx.paintOf(0x2C2C2A), 5 * sz));
  canvas.drawLine(
    handle,
    Offset.lerp(handle, tip, 0.14)!,
    strokeOf(ctx.paintOf(0xFFDB70), 5.6 * sz),
  );
  canvas.drawLine(
    Offset.lerp(handle, tip, 0.86)!,
    tip,
    strokeOf(ctx.paintOf(0xFFFFFF), 5.6 * sz),
  );
  canvas.drawCircle(
    tip,
    15 * sz,
    ctx.paintOf(0xFFDB70, 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
  );
  ctx.star(canvas, tip, 11 * sz, 0xFFDB70);
  ctx.star(canvas, tip, 6 * sz, 0xFFFFFF);
  final tw = ctx.reduceMotion ? 1.0 : 0.6 + 0.4 * math.sin(e * 14);
  sparkle(canvas, tip, 19 * sz * tw, ctx.paintOf(0xFFFFFF, 0.9), e * 2);
}

// --- Ejderha ve Mavi Ejderha: agizdan alev ------------------------------------

double _breathGate(CelebrationContext ctx) {
  if (ctx.reduceMotion) return 1;
  final t = ctx.t;
  double w(double a, double b) =>
      math.sin(((t - a) / (b - a)).clamp(0.0, 1.0) * math.pi);
  return 0.3 + 0.7 * math.max(w(0.05, 0.5), w(0.5, 0.92));
}

CapPose _ejderhaPose(CelebrationContext ctx) {
  final g = _breathGate(ctx);
  return CapPose(
    dx: -2.4 * g + math.sin(ctx.elapsed * 38) * 0.7 * g,
    rotation: -0.04 * g + math.sin(ctx.elapsed * 5) * 0.015,
  );
}

CapPose _maviPose(CelebrationContext ctx) {
  final g = _breathGate(ctx);
  return CapPose(
    dx: 2.4 * g + math.sin(ctx.elapsed * 38) * 0.6 * g,
    rotation: 0.04 * g + math.sin(ctx.elapsed * 5) * 0.015,
  );
}

class _Blob {
  _Blob(this.p, this.pos, this.r);
  final double p, r;
  final Offset pos;
}

/// Alev akisi: [dir] x yonu (+1 sag, -1 sol), [ramp] sicaktan soguga renkler.
void _flameStream(
  Canvas canvas,
  CelebrationContext ctx,
  Offset start,
  double dir,
  List<int> ramp,
) {
  final sz = szOf(ctx);
  final g = _breathGate(ctx);
  const n = 36;
  final blobs = <_Blob>[];
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 0.46, start: 0.05, end: 0.9);
    if (!em.live) continue;
    final p = em.p;
    final reach = (105 + 50 * rr(ctx, i, em, 1)) * sz * (0.5 + 0.5 * g);
    final ang = 0.0 + (rr(ctx, i, em, 2) - 0.5) * 0.26 - p * 0.05;
    final d = CelebrationContext.easeOut(p) * reach;
    final pos =
        start +
        Offset(
          dir * math.cos(ang) * d,
          math.sin(ang) * d - p * p * 8 * sz + math.sin(p * 11 + i) * 2.5 * sz,
        );
    final r = (4 + 20 * math.pow(p, 0.8)) * sz * (0.75 + 0.3 * g);
    blobs.add(_Blob(p, pos, r));
  }
  blobs.sort((a, b) => b.p.compareTo(a.p));
  for (final b in blobs) {
    final op =
        math.min(1.0, b.p * 9) * (1 - math.pow(b.p, 1.6).toDouble()) * 0.95;
    canvas.drawCircle(b.pos, b.r, ctx.paintOf(rampColor(ramp, b.p), op));
    if (b.p < 0.7) {
      canvas.drawCircle(
        b.pos + Offset(-dir * b.r * 0.12, 0),
        b.r * 0.55,
        ctx.paintOf(rampColor(ramp, b.p * 0.55), op * 0.9),
      );
    }
  }
  // Agiz cevresinde isik
  canvas.drawCircle(
    start,
    (14 + 6 * g) * sz,
    ctx.paintOf(ramp[1], 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  );
}

void _ejderhaBreath(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final start = IllustratedArtwork.byId.containsKey('ejderha')
      ? ctx.mouth
      : ctx.mouth + Offset(22 * sz, 2 * sz);
  const ramp = [0xFFF8D6, 0xFFD25A, 0xEF9F27, 0xE8684A, 0x8A3A2A];
  _flameStream(canvas, ctx, start, 1, ramp);

  // Firlayan kivilcimlar
  const n = 14;
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 0.8, start: 0.06, end: 0.9);
    if (!em.live) continue;
    final a = -0.25 + (rr(ctx, i, em, 3) - 0.5) * 1.0;
    final v = (170 + 120 * rr(ctx, i, em, 4)) * sz;
    final s = em.p * 0.9;
    final pos =
        start +
        Offset(
          math.cos(a) * v * s,
          math.sin(a) * v * s + 0.5 * 320 * sz * s * s,
        );
    canvas.drawCircle(
      pos,
      (2.6 - em.p * 1.6).clamp(0.6, 3.0) * sz,
      ctx.paintOf(i.isEven ? 0xFFD25A : 0xEF9F27, 1 - em.p),
    );
  }
}

void _maviEjderhaBreath(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final start = IllustratedArtwork.byId.containsKey('maviejderha')
      ? ctx.mouth
      : ctx.mouth + Offset(-22 * sz, 2 * sz);
  const ramp = [0xFFFFFF, 0xBFF1FF, 0x6DD6F5, 0x38B6E8, 0x2F66C8];
  _flameStream(canvas, ctx, start, -1, ramp);

  // Buz parildamalari: kristal ve parilti
  const n = 16;
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 1.2, start: 0.08, end: 0.86);
    if (!em.live) continue;
    final p = em.p;
    final along = 28 + 130 * rr(ctx, i, em, 1);
    final pos =
        start +
        Offset(
          -along * sz + math.sin(p * 4 + i) * 6 * sz,
          (rr(ctx, i, em, 2) - 0.5) * 70 * sz + p * 46 * sz,
        );
    final fade = math.sin(math.pi * p);
    final r = (6 + 6 * rr(ctx, i, em, 3)) * sz;
    if (i % 3 == 0) {
      sparkle(canvas, pos, r * 1.5, ctx.paintOf(0xFFFFFF, fade), p * 3);
    } else {
      final paint = strokeOf(
        ctx.paintOf(i % 2 == 0 ? 0xE6F6FF : 0x9BE7FF, 0.95 * fade),
        1.7 * sz,
      );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p * 4 + i);
      for (var k = 0; k < 3; k++) {
        final a = k * math.pi / 3;
        final d = Offset(math.cos(a), math.sin(a)) * r * 1.4;
        canvas.drawLine(-d, d, paint);
        // Minik dallar
        for (final s in const [-1.0, 1.0]) {
          final tipP = d * s * 0.62;
          final perp = Offset(-d.dy, d.dx) / d.distance * r * 0.38;
          canvas.drawLine(tipP, tipP + (d * s * 0.32) + perp, paint);
          canvas.drawLine(tipP, tipP + (d * s * 0.32) - perp, paint);
        }
      }
      canvas.restore();
    }
  }
}
