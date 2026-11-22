import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../illustrated_artwork.dart';
import 'celebration_context.dart';
import 'celebrations_g1_kit.dart';
import 'celebrations_g1_loops.dart';

// GRUP 1 surekli dongu kutlamalari (robot..maviejderha). Bkz. celebrations_g1_loops.dart.

final Map<String, SignatureCelebration> g1LoopsB = {
  'robot': _robotLoop,
  'korsan': _korsanLoop,
  'gece': _geceLoop,
  'sihirbaz': _sihirbazLoop,
  'ejderha': _ejderhaLoop,
  'maviejderha': _maviLoop,
};

final Map<String, CapPoseFn> g1LoopPosesB = {
  'robot': _robotLoopPose,
  'korsan': _korsanLoopPose,
  'gece': _geceLoopPose,
  'sihirbaz': _sihirbazLoopPose,
  'ejderha': _ejderhaLoopPose,
  'maviejderha': _maviLoopPose,
};

// --- Robot ---------------------------------------------------------------------

CapPose _robotLoopPose(CelebrationContext ctx) => CapPose(
  rotation: lpSin(ctx, 1) * 0.025,
  dy: -1.8 * lpSin(ctx, 3).abs(),
  dx: lpSin(ctx, 40) * 0.5,
);

void _gearL(
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
  canvas.drawPath(path, lpPaint(ctx, body, 0.96));
  canvas.drawPath(path, strokeOf(lpPaint(ctx, edge, 0.95), 1.4));
  canvas.drawCircle(Offset.zero, r * 0.62, lpPaint(ctx, edge, 0.55));
  canvas.drawCircle(Offset.zero, r * 0.34, lpPaint(ctx, 0x1E2A3A));
  canvas.drawCircle(
    Offset(-r * 0.12, -r * 0.14),
    r * 0.1,
    lpPaint(ctx, 0xFFFFFF, 0.5),
  );
  canvas.restore();
}

void _robotLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final th = lpTheta(ctx);

  final cc = ctx.capCenter;
  for (final side in const [-1.0, 1.0]) {
    final cx = cc.dx + side * (ctx.capWidth / 2 + 34 * sz);
    final cy = cc.dy - 8 * sz;
    final spin = th * side;
    _gearL(canvas, ctx, Offset(cx, cy), 15 * sz, 10, spin, 0xFAD36B, 0xC9951F);
    _gearL(
      canvas,
      ctx,
      Offset(cx + side * 14 * sz, cy + 24 * sz),
      9 * sz,
      6,
      -spin * 2 + 0.3,
      0x8FA1B3,
      0x5F7184,
    );
  }

  final illustratedRobot = IllustratedArtwork.byId.containsKey('robot');
  final ant = illustratedRobot
      ? (ctx.chubby ? const Offset(340, -8) : const Offset(340, 29))
      : (ctx.chubby ? const Offset(340, 22) : const Offset(340, 58));
  final ar = illustratedRobot
      ? (ctx.chubby ? 12.0 : 9.0)
      : (ctx.chubby ? 12.0 : 11.0);
  final ph = (ctx.loop * 3) % 1.0;
  final cyc = (ctx.loop * 3).floor();
  const cx = 340.0;
  final cy = ctx.chubby ? 128.0 : 126.0;
  final ex = ctx.chubby ? 26.0 : 20.0;
  const ey = 120.0;
  final r = ctx.chubby ? 11.0 : 8.0;

  inCap(canvas, ctx, () {
    final flash = math.pow(1 - ph, 2).toDouble();
    canvas.drawCircle(
      ant,
      ar * (1.7 + 1.1 * flash),
      lpPaint(ctx, 0xFAD36B, 0.42 * (0.4 + flash))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    final burst = math.min(ph / 0.08, 1.0);
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
      final a = ((1 - ph * 0.9) * burst).clamp(0.0, 1.0);
      canvas.drawPath(
        path,
        strokeOf(lpPaint(ctx, k.isEven ? 0xFAD36B : 0x7BF0FF, a), 2.4),
      );
      if (k % 3 == 0) {
        sparkle(
          canvas,
          p,
          4 + 3 * ctx.rand(seed, 5),
          lpPaint(ctx, 0xFFFFFF, a),
        );
      }
    }

    if (illustratedRobot) return;

    // LED gozler: aralarda yanar, periyodik kirpar.
    var blink = 0.0;
    for (final t0 in const [0.12, 0.38, 0.62, 0.86]) {
      final x = (ctx.loop - t0) / 0.05;
      if (x > 0 && x < 1) blink = math.max(blink, math.sin(x * math.pi));
    }
    final glow = 0.5 + 0.5 * math.sin(th * 3);
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
          lpPaint(ctx, 0x7BF0FF, 0.2 + 0.18 * glow)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }
    final w2 = ctx.chubby ? 52.0 : 40.0, h2 = ctx.chubby ? 38.0 : 26.0;
    final lc = [
      Offset(cx - w2 + 8, cy + h2 - 8),
      Offset(cx + w2 - 8, cy + h2 - 8),
    ];
    for (var i = 0; i < 2; i++) {
      final on = (ctx.loop * 16).floor() % 2 == i;
      canvas.drawCircle(lc[i], 3.6, ctx.solid(on ? 0xFFFFFF : 0x14202E));
      canvas.drawCircle(
        lc[i],
        3,
        ctx.solid(i == 0 ? 0xE24B4A : 0xFAD36B, on ? 1 : 0.45),
      );
    }
  });
}

// --- Korsan --------------------------------------------------------------------

CapPose _korsanLoopPose(CelebrationContext ctx) =>
    CapPose(dy: lpSin(ctx, 2) * 2.4, rotation: lpSin(ctx, 1) * 0.04);

void _korsanLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final th = lpTheta(ctx);

  final base = IllustratedArtwork.byId.containsKey('korsan')
      ? ctx.capTop
      : ctx.capPt(340, ctx.chubby ? 54 : 90);
  final len = 70 * sz;
  final top = base + Offset(0, -len);
  canvas.drawLine(base, top, strokeOf(lpPaint(ctx, 0x6B3E16), 3.2 * sz));
  canvas.drawCircle(top + Offset(0, -2 * sz), 3.6 * sz, lpPaint(ctx, 0xFAC775));
  const cols = 12;
  final fw = 62 * sz, fh = 40 * sz;
  final topPts = <Offset>[], botPts = <Offset>[];
  for (var i = 0; i <= cols; i++) {
    final f = i / cols;
    final w = math.sin(f * 7 - th * 5);
    final dy = w * 4.6 * sz * f;
    final dx = f * fw * (1 - 0.04 * w * f);
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
  canvas.drawPath(flag, lpPaint(ctx, 0x2C2C2A));
  canvas.drawPath(flag, strokeOf(lpPaint(ctx, 0x5F5E5A), 1.4 * sz));
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
  canvas.scale(sz);
  final bone = strokeOf(lpPaint(ctx, 0xFFFFFF, 0.95), 2.4);
  canvas.drawLine(const Offset(-10, 8), const Offset(10, -4), bone);
  canvas.drawLine(const Offset(10, 8), const Offset(-10, -4), bone);
  canvas.drawCircle(const Offset(0, -2), 7.6, lpPaint(ctx, 0xFFFFFF));
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(-4.4, 3, 8.8, 5.6),
      const Radius.circular(2),
    ),
    lpPaint(ctx, 0xFFFFFF),
  );
  canvas.drawCircle(const Offset(-3, -2.5), 2, lpPaint(ctx, 0x2C2C2A));
  canvas.drawCircle(const Offset(3, -2.5), 2, lpPaint(ctx, 0x2C2C2A));
  canvas.drawPath(
    Path()
      ..moveTo(0, 0.6)
      ..lineTo(-1.2, 2.6)
      ..lineTo(1.2, 2.6)
      ..close(),
    lpPaint(ctx, 0x2C2C2A),
  );
  canvas.restore();

  // Altin paralar: surekli firlayip duser.
  final origin = ctx.capCenter + Offset(0, -ctx.capWidth * 0.2);
  const n = 12;
  for (var i = 0; i < n; i++) {
    final e = lpEmit(ctx, i, n, 2);
    final s = e.seed;
    final a = -math.pi / 2 + (lpRand(ctx, s, 1) - 0.5) * 2.7;
    final v = (190 + 130 * lpRand(ctx, s, 2)) * sz;
    final g = 480 * sz;
    final tt = e.p * 1.5;
    final pos =
        origin +
        Offset(math.cos(a) * v * tt, math.sin(a) * v * tt + 0.5 * g * tt * tt);
    final spin = th * 4 + i * 1.7;
    final cw = math.cos(spin).abs();
    final rad = (9 + 3 * lpRand(ctx, s, 3)) * sz;
    final fade = lpFade(e.p, 0.04, 0.15);
    final rect = Rect.fromCenter(
      center: pos,
      width: 2 * rad * math.max(0.16, cw),
      height: 2 * rad,
    );
    canvas.drawOval(rect, lpPaint(ctx, 0xFAC775, fade));
    canvas.drawOval(rect, strokeOf(lpPaint(ctx, 0xE8A317, fade), 1.6 * sz));
    if (cw > 0.5) {
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: rad * 1.1 * cw, height: rad * 1.1),
        strokeOf(lpPaint(ctx, 0xE8A317, 0.8 * fade), 1.2 * sz),
      );
    }
    if (cw < 0.3 || i % 4 == 0) {
      sparkle(
        canvas,
        pos + Offset(rad * 0.7, -rad * 0.7),
        5 * sz * (1 - cw * 0.5),
        lpPaint(ctx, 0xFFFFFF, 0.9 * fade),
        spin,
      );
    }
  }
}

// --- Gece ------------------------------------------------------------------------

CapPose _geceLoopPose(CelebrationContext ctx) {
  final s = lpSin(ctx, 1);
  return CapPose(rotation: s * 0.11, dx: s * 4, dy: 1 - math.cos(s * 1.4) * 2);
}

void _geceLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final th = lpTheta(ctx);

  for (var i = 0; i < 14; i++) {
    final left = ctx.rand(i, 3) < 0.5;
    final x = left ? 132 + ctx.rand(i, 4) * 112 : 436 + ctx.rand(i, 4) * 112;
    final y = 24 + ctx.rand(i, 5) * 440;
    final tw = math.max(0.0, lpSin(ctx, 2, i * 2.3));
    if (tw < 0.04) continue;
    sparkle(
      canvas,
      Offset(x, y),
      (3 + 8 * tw) * (0.7 + 0.5 * ctx.rand(i, 6)),
      lpPaint(ctx, 0xFFF1B8, tw),
      i.toDouble(),
    );
  }

  // Kayan yildiz: her turda bir, turlar arasi sag/sol degisir.
  const streaks = [
    [560.0, 16.0, 150.0, 104.0],
    [330.0, 22.0, 125.0, 90.0],
  ];
  final s = streaks[ctx.loopCount % 2];
  final sp = (ctx.loop - 0.3) / 0.32;
  if (sp > 0 && sp < 1) {
    final a = Offset(s[0], s[1]), b = Offset(s[2], s[3]);
    final head = Offset.lerp(a, b, CelebrationContext.easeOut(sp))!;
    final dir = (b - a) / (b - a).distance;
    final tail = head - dir * 90 * sz;
    final f = math.sin(sp * math.pi);
    canvas.drawLine(
      head,
      tail,
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFF1B8).withValues(alpha: f),
            const Color(0x00FFF1B8),
          ],
        ).createShader(Rect.fromPoints(head, tail)),
    );
    sparkle(canvas, head, 10 * sz, lpPaint(ctx, 0xFFFFFF, f), sp * 8);
    canvas.drawCircle(head, 3, lpPaint(ctx, 0xFFFFFF, f));
  }

  // z baloncuklari: uykulu, sallana sallana yukselir.
  final start = IllustratedArtwork.byId.containsKey('gece')
      ? ctx.capPt(ctx.chubby ? 400 : 382, ctx.chubby ? 81 : 90)
      : ctx.capCenter + Offset(ctx.capWidth * 0.42, -ctx.capWidth * 0.08);
  const n = 5;
  for (var i = 0; i < n; i++) {
    final e = lpEmit(ctx, i, n, 1);
    final p = e.p;
    final grow = CelebrationContext.easeOut(math.min(1.0, p * 3));
    final r = (9 + 13 * p) * sz * grow;
    final c =
        start +
        Offset(
          math.sin(p * 6 + i * 1.4) * 10 * sz + p * 34 * sz,
          -p * 155 * sz,
        );
    final fade = lpFade(p, 0.05, 0.18);
    canvas.drawCircle(c, r, lpPaint(ctx, 0xBFD3FF, 0.2 * fade));
    canvas.drawCircle(c, r, strokeOf(lpPaint(ctx, 0xDCE6FF, 0.85 * fade), 1.8));
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.74),
      -2.6,
      0.9,
      false,
      strokeOf(lpPaint(ctx, 0xFFFFFF, 0.8 * fade), 1.6),
    );
    textAt(
      canvas,
      i.isEven ? 'Z' : 'z',
      c + Offset(0, r * 0.04),
      r * 1.25,
      lpPaint(ctx, 0xFFF1B8, fade),
      outline: strokeOf(lpPaint(ctx, 0x3C4AA8, 0.9 * fade), r * 0.22),
      rot: math.sin(p * 5 + i) * 0.25 + math.sin(th) * 0.0,
    );
  }
}

// --- Sihirbaz --------------------------------------------------------------------

CapPose _sihirbazLoopPose(CelebrationContext ctx) {
  final h = lpSin(ctx, 2).abs();
  return CapPose(
    dy: -10 * h,
    rotation: 0.05 * lpSin(ctx, 2),
    scale: 1 + 0.04 * h - 0.02 * (1 - h) * (1 - h),
  );
}

void _sihirbazLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final th = lpTheta(ctx);
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
  final w = math.sin(th * 4) * 0.22;
  final v = tip0 - handle;
  final tip =
      handle +
      Offset(
        v.dx * math.cos(w) - v.dy * math.sin(w),
        v.dx * math.sin(w) + v.dy * math.cos(w),
      );

  const n = 30;
  const cols = [0xFFDB70, 0xD9B8F5, 0xFFFFFF, 0xF59BC0, 0xA77BEC];
  for (var i = 0; i < n; i++) {
    final e = lpEmit(ctx, i, n, 2);
    final p = e.p;
    final phi = lpRand(ctx, e.seed, 1) * tau + p * tau * 1.6;
    final rad = (6 + 62 * CelebrationContext.easeOut(p)) * sz;
    final pos =
        tip +
        Offset(math.cos(phi) * rad, math.sin(phi) * rad * 0.8 - 26 * sz * p);
    final fade = lpFade(p, 0.06, 0.3);
    final sr = (3.2 + 3.6 * lpRand(ctx, e.seed, 2)) * sz * (1 - p * 0.35);
    final col = cols[i % cols.length];
    if (i % 3 == 0) {
      ctx.star(canvas, pos, sr * 1.15, col, fade);
    } else {
      sparkle(canvas, pos, sr * 1.5, lpPaint(ctx, col, fade), phi);
    }
  }

  canvas.drawLine(handle, tip, strokeOf(lpPaint(ctx, 0x2C2C2A), 5 * sz));
  canvas.drawLine(
    handle,
    Offset.lerp(handle, tip, 0.14)!,
    strokeOf(lpPaint(ctx, 0xFFDB70), 5.6 * sz),
  );
  canvas.drawLine(
    Offset.lerp(handle, tip, 0.86)!,
    tip,
    strokeOf(lpPaint(ctx, 0xFFFFFF), 5.6 * sz),
  );
  canvas.drawCircle(
    tip,
    15 * sz,
    lpPaint(ctx, 0xFFDB70, 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
  );
  ctx.star(canvas, tip, 11 * sz, 0xFFDB70);
  ctx.star(canvas, tip, 6 * sz, 0xFFFFFF);
  final tw = 0.6 + 0.4 * math.sin(th * 7);
  sparkle(canvas, tip, 19 * sz * tw, lpPaint(ctx, 0xFFFFFF, 0.9), th * 2);

  // Sapkada sureli parlayan yildizlar.
  for (var i = 0; i < 4; i++) {
    final a = tau * (i / 4) + th * 0;
    final tw2 = math.max(0.0, lpSin(ctx, 3, i * 1.6));
    final pt = ctx.capPt(
      340 + math.cos(a) * 70,
      (ctx.chubby ? 40.0 : 80.0) + (i % 2) * 40 + math.sin(a) * 6,
    );
    sparkle(
      canvas,
      pt,
      (3 + 6 * tw2) * sz,
      lpPaint(ctx, 0xFFDB70, tw2),
      i.toDouble(),
    );
  }
}

// --- Ejderha ve Mavi Ejderha ------------------------------------------------------

/// Dongu basina 2 nefes; u: tur ici ilerleme.
double _bu(CelebrationContext ctx) => (ctx.loop * 2) % 1.0;
double _bg(CelebrationContext ctx) =>
    math.sin(math.pi * (_bu(ctx) / 0.6).clamp(0.0, 1.0));

CapPose _ejderhaLoopPose(CelebrationContext ctx) {
  final g = _bg(ctx);
  return CapPose(
    dx: -2.6 * g + lpSin(ctx, 38) * 0.7 * g,
    rotation: -0.05 * g + lpSin(ctx, 2) * 0.012,
    dy: -1.2 * lpSin(ctx, 4).abs(),
  );
}

CapPose _maviLoopPose(CelebrationContext ctx) {
  final g = _bg(ctx);
  return CapPose(
    dx: 2.6 * g + lpSin(ctx, 38) * 0.6 * g,
    rotation: 0.05 * g + lpSin(ctx, 2) * 0.012,
    dy: -1.2 * lpSin(ctx, 4).abs(),
  );
}

class _Blob {
  _Blob(this.p, this.pos, this.r);
  final double p, r;
  final Offset pos;
}

void _flameBurst(
  Canvas canvas,
  CelebrationContext ctx,
  Offset start,
  double dir,
  List<int> ramp,
) {
  final sz = szOf(ctx);
  final g = _bg(ctx);
  final u = _bu(ctx);
  final burst = ctx.loop * 2 ~/ 1;
  const n = 22;
  final blobs = <_Blob>[];
  for (var i = 0; i < n; i++) {
    final ti = 0.02 + 0.4 * i / n;
    final p = (u - ti) / 0.56;
    if (p <= 0 || p >= 1) continue;
    final s = i + burst * 37;
    final reach = (110 + 50 * lpRand(ctx, s, 1)) * sz;
    final ang = (lpRand(ctx, s, 2) - 0.5) * 0.26 - p * 0.05;
    final d = CelebrationContext.easeOut(p) * reach;
    final pos =
        start +
        Offset(
          dir * math.cos(ang) * d,
          math.sin(ang) * d - p * p * 8 * sz + math.sin(p * 11 + i) * 2.5 * sz,
        );
    final r = (4 + 20 * math.pow(p, 0.8)) * sz;
    blobs.add(_Blob(p, pos, r));
  }
  blobs.sort((a, b) => b.p.compareTo(a.p));
  for (final b in blobs) {
    final op =
        math.min(1.0, b.p * 9) * (1 - math.pow(b.p, 1.6).toDouble()) * 0.95;
    canvas.drawCircle(b.pos, b.r, lpPaint(ctx, rampColor(ramp, b.p), op));
    if (b.p < 0.7) {
      canvas.drawCircle(
        b.pos + Offset(-dir * b.r * 0.12, 0),
        b.r * 0.55,
        lpPaint(ctx, rampColor(ramp, b.p * 0.55), op * 0.9),
      );
    }
  }
  canvas.drawCircle(
    start,
    (10 + 12 * g) * sz,
    lpPaint(ctx, ramp[1], 0.15 + 0.4 * g)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  );
}

/// Burun deliginden yukselen kucuk duman/buz nefesi.
void _nostrilPuffs(Canvas canvas, CelebrationContext ctx, int hex, int shade) {
  final sz = szOf(ctx);
  // Resimli başlar yenilendikçe sabit tasarım koordinatları burun hizasından
  // kopuyordu. Bağlam gerçek hedef dikdörtgenden burun merkezini türetir.
  final nose = ctx.nose;
  for (var i = 0; i < 6; i++) {
    final e = lpEmit(ctx, i, 6, 3);
    final p = e.p;
    final side = i.isEven ? -1.0 : 1.0;
    final c =
        nose +
        Offset(
          side * (6 + 14 * p) * sz + math.sin(p * 5 + i) * 3 * sz,
          -4 * sz - p * 38 * sz,
        );
    puff(
      canvas,
      ctx,
      c,
      (2.5 + 6 * p) * sz,
      hex,
      0.65 * lpFade(p, 0.1, 0.55),
      shade,
    );
  }
}

void _ejderhaLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final start = IllustratedArtwork.byId.containsKey('ejderha')
      ? ctx.mouth
      : ctx.mouth + Offset(22 * sz, 2 * sz);
  const ramp = [0xFFF8D6, 0xFFD25A, 0xEF9F27, 0xE8684A, 0x8A3A2A];
  _nostrilPuffs(canvas, ctx, 0xB9B4AC, 0x8E8A84);
  _flameBurst(canvas, ctx, start, 1, ramp);

  final u = _bu(ctx);
  final burst = ctx.loop * 2 ~/ 1;
  for (var i = 0; i < 14; i++) {
    final p = (u - 0.04 - 0.34 * i / 14) / 0.5;
    if (p <= 0 || p >= 1) continue;
    final s = i + burst * 37;
    final a = -0.25 + (lpRand(ctx, s, 3) - 0.5) * 1.0;
    final v = (170 + 120 * lpRand(ctx, s, 4)) * sz;
    final tt = p * 0.9;
    final pos =
        start +
        Offset(
          math.cos(a) * v * tt,
          math.sin(a) * v * tt + 0.5 * 320 * sz * tt * tt,
        );
    canvas.drawCircle(
      pos,
      (2.6 - p * 1.6).clamp(0.6, 3.0) * sz,
      lpPaint(ctx, i.isEven ? 0xFFD25A : 0xEF9F27, 1 - p),
    );
  }
}

void _maviLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final start = IllustratedArtwork.byId.containsKey('maviejderha')
      ? ctx.mouth
      : ctx.mouth + Offset(-22 * sz, 2 * sz);
  const ramp = [0xFFFFFF, 0xBFF1FF, 0x6DD6F5, 0x38B6E8, 0x2F66C8];
  _nostrilPuffs(canvas, ctx, 0xDDF3FF, 0xA9D9F0);
  _flameBurst(canvas, ctx, start, -1, ramp);

  const n = 16;
  for (var i = 0; i < n; i++) {
    final e = lpEmit(ctx, i, n, 1);
    final p = e.p;
    final along = 28 + 130 * lpRand(ctx, e.seed, 1);
    final pos =
        start +
        Offset(
          -along * sz + math.sin(p * 4 + i) * 6 * sz,
          (lpRand(ctx, e.seed, 2) - 0.5) * 70 * sz + p * 46 * sz,
        );
    final fade = math.sin(math.pi * p);
    final r = (6 + 6 * lpRand(ctx, e.seed, 3)) * sz;
    if (i % 3 == 0) {
      sparkle(canvas, pos, r * 1.5, lpPaint(ctx, 0xFFFFFF, fade), p * 3);
    } else {
      final paint = strokeOf(
        lpPaint(ctx, i % 2 == 0 ? 0xE6F6FF : 0x9BE7FF, 0.95 * fade),
        1.7 * sz,
      );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p * 4 + i);
      for (var k = 0; k < 3; k++) {
        final a = k * math.pi / 3;
        final d = Offset(math.cos(a), math.sin(a)) * r * 1.4;
        canvas.drawLine(-d, d, paint);
        for (final sgn in const [-1.0, 1.0]) {
          final tipP = d * sgn * 0.62;
          final perp = Offset(-d.dy, d.dx) / d.distance * r * 0.38;
          canvas.drawLine(tipP, tipP + (d * sgn * 0.32) + perp, paint);
          canvas.drawLine(tipP, tipP + (d * sgn * 0.32) - perp, paint);
        }
      }
      canvas.restore();
    }
  }
}
