import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../illustrated_artwork.dart';
import '../svg_path.dart';
import '../thermos_theme.dart';
import 'celebration_context.dart';
import 'celebrations_g1_kit.dart';

// GRUP 1 surekli dongu kutlamalari (klasik..kamp). Tum hareket ctx.loop'un
// periyodik fonksiyonudur (tam sayi frekans); tur sonu/basi dikissizdir.
// Zarf (ctx.alpha) kullanilmaz: ctx.solid ile cizilir.

final Map<String, SignatureCelebration> g1LoopsA = {
  'klasik': _klasikLoop,
  'cilek': _cilekLoop,
  'kaplan': _kaplanLoop,
  'tekboynuz': _tekboynuzLoop,
  'astronot': _astronotLoop,
  'kamp': _kampLoop,
};

final Map<String, CapPoseFn> g1LoopPosesA = {
  'klasik': _klasikLoopPose,
  'cilek': _cilekLoopPose,
  'kaplan': _kaplanLoopPose,
  'tekboynuz': _tekboynuzLoopPose,
  'astronot': _astronotLoopPose,
  'kamp': _kampLoopPose,
};

// --- Ortak dongu yardimcilari -------------------------------------------------

/// Dongu evresi radyan (0..tau).
double lpTheta(CelebrationContext c) => tau * c.loop;

/// sin(tau*k*loop + ph): k tam sayi (ya da yari tam sayi) olmali.
double lpSin(CelebrationContext c, num k, [double ph = 0]) =>
    math.sin(tau * k * c.loop + ph);

/// Donguden bagimsiz parcacik: [p] 0..1 omur, [seed] parcacik+tur tohumu.
class LpP {
  const LpP(this.p, this.seed);
  final double p;
  final int seed;
}

/// Dongu basina [k] tur donen, [n] parcacikli surekli yayici (hep canli).
LpP lpEmit(CelebrationContext c, int i, int n, int k) {
  final x = c.loop * k + i / n;
  final cyc = x.floor();
  return LpP(x - cyc, i + 41 * (cyc % k));
}

double lpRand(CelebrationContext c, int seed, int salt) => c.rand(seed, salt);

/// Omur boyunca yumusak belirip sonme.
double lpFade(double p, [double a = 0.12, double b = 0.25]) =>
    math.min(p / a, 1.0).clamp(0.0, 1.0) *
    math.min((1 - p) / b, 1.0).clamp(0.0, 1.0);

Paint lpPaint(CelebrationContext c, int hex, [double op = 1]) =>
    c.solid(hex, op);

/// Kenarlarda yer degistirip parlayan, pirildayan yildizlar.
void lpDriftStars(
  Canvas canvas,
  CelebrationContext ctx,
  int n,
  num fastTw, {
  int xLeft = 132,
  int xRight = 436,
  double yTop = 22,
  double yH = 458,
  double drift = 70,
  int hot = 4,
  int hotCol = 0xFFE58F,
  int col = 0xFFFFFF,
}) {
  for (var i = 0; i < n; i++) {
    final left = ctx.rand(i, 3) < 0.5;
    final x = (left ? xLeft : xRight) + ctx.rand(i, 4) * 112;
    final q = (ctx.loop + ctx.rand(i, 9)) % 1.0;
    final y = yTop + ctx.rand(i, 5) * yH + drift * (q - 0.5);
    final f = math.sin(math.pi * q);
    final tw = 0.55 + 0.45 * lpSin(ctx, fastTw, i * 1.7);
    final a = f * tw;
    if (a < 0.05) continue;
    sparkle(
      canvas,
      Offset(x, y),
      (3 + 9 * a) * (0.7 + 0.5 * ctx.rand(i, 6)),
      lpPaint(ctx, i % hot == 0 ? hotCol : col, a.clamp(0.0, 1.0)),
      i + ctx.loop * 2,
    );
  }
}

// --- Klasik: surekli firskiyan su ---------------------------------------------

CapPose _klasikLoopPose(CelebrationContext ctx) {
  final s = lpSin(ctx, 2);
  return CapPose(
    dy: -3.2 * s * s,
    scale: 1 + 0.018 * lpSin(ctx, 4),
    rotation: 0.012 * lpSin(ctx, 1),
  );
}

void _klasikLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final o = ctx.capImagePt(0.5, 0.04);
  final th = lpTheta(ctx);

  final jetH = (56 + 10 * math.sin(th * 3)) * sz;
  final sway = math.sin(th * 2) * 3 * sz;
  final w = 9 * sz;
  canvas.drawPath(
    Path()
      ..moveTo(o.dx - w, o.dy + 2)
      ..quadraticBezierTo(
        o.dx - w * 0.5 + sway,
        o.dy - jetH * 0.6,
        o.dx + sway,
        o.dy - jetH,
      )
      ..quadraticBezierTo(
        o.dx + w * 0.5 + sway,
        o.dy - jetH * 0.6,
        o.dx + w,
        o.dy + 2,
      )
      ..close(),
    lpPaint(ctx, 0x85B7EB, 0.9),
  );
  canvas.drawPath(
    Path()
      ..moveTo(o.dx - w * 0.35, o.dy)
      ..quadraticBezierTo(
        o.dx - w * 0.2 + sway,
        o.dy - jetH * 0.5,
        o.dx + sway * 0.9,
        o.dy - jetH * 0.85,
      )
      ..quadraticBezierTo(
        o.dx + w * 0.1 + sway,
        o.dy - jetH * 0.5,
        o.dx + w * 0.1,
        o.dy,
      ),
    lpPaint(ctx, 0xE6F1FB, 0.9),
  );

  const n = 18;
  const cols = [0x378ADD, 0x85B7EB, 0xB5D4F4, 0x378ADD];
  for (var i = 0; i < n; i++) {
    final e = lpEmit(ctx, i, n, 2);
    final a = -math.pi / 2 + (lpRand(ctx, e.seed, 3) - 0.5) * 1.3;
    final v = (185 + 85 * lpRand(ctx, e.seed, 4)) * sz;
    final g = 470 * sz;
    final s = e.p * 1.25;
    final pos =
        o + Offset(math.cos(a) * v * s, math.sin(a) * v * s + 0.5 * g * s * s);
    final vel = Offset(math.cos(a) * v, math.sin(a) * v + g * s);
    final dir = math.atan2(vel.dy, vel.dx);
    final r = (4 + 3 * lpRand(ctx, e.seed, 5)) * sz;
    final fade = lpFade(e.p, 0.1, 0.14);
    drop(
      canvas,
      pos,
      r * (0.6 + 0.4 * fade),
      dir,
      lpPaint(ctx, cols[i % cols.length], 0.95 * fade),
    );
    canvas.drawCircle(
      pos + Offset(-r * 0.3, -r * 0.2),
      r * 0.28,
      lpPaint(ctx, 0xFFFFFF, 0.8 * fade),
    );
  }

  for (var k = 0; k < 2; k++) {
    final p = (ctx.loop * 2 + k * 0.5) % 1.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(0, 3 * sz),
        width: (18 + 52 * p) * sz,
        height: (6 + 14 * p) * sz,
      ),
      strokeOf(lpPaint(ctx, 0xB5D4F4, 0.85 * (1 - p)), 2.2 * sz),
    );
  }
}

// --- Cilek: ziplama + yukselen kalpler ----------------------------------------

CapPose _cilekLoopPose(CelebrationContext ctx) {
  final h = lpSin(ctx, 1.5).abs();
  return CapPose(
    dy: -15 * h,
    rotation: 0.05 * lpSin(ctx, 3),
    scale: 1 + 0.045 * h - 0.03 * (1 - h) * (1 - h),
  );
}

void _cilekLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final c = ctx.capCenter;
  const cols = [0xE24B4A, 0xED93B1, 0xD4537E, 0xF09595, 0xFF6F91];
  const n = 10;
  for (var i = 0; i < n; i++) {
    final e = lpEmit(ctx, i, n, 1);
    final s = e.seed;
    final side = lpRand(ctx, s, 1) < 0.5 ? -1.0 : 1.0;
    final x0 = c.dx + side * ctx.capWidth * (0.2 + 0.3 * lpRand(ctx, s, 6));
    final rise = (60 + 50 * lpRand(ctx, s, 2)) * (0.85 + sz * 0.15);
    final p = e.p;
    final eo = CelebrationContext.easeOut(p);
    final y = c.dy - ctx.capWidth * 0.12 - rise * eo;
    final x = x0 + side * 46 * sz * eo + math.sin(p * 7 + i) * 7 * sz;
    final grow = CelebrationContext.easeOut(p * 4);
    final r = (8 + 7 * lpRand(ctx, s, 3)) * sz * grow;
    final fade = lpFade(p, 0.02, 0.3);
    heart(
      canvas,
      Offset(x, y),
      r,
      lpPaint(ctx, cols[i % cols.length], 0.95 * fade),
      math.sin(p * 6 + i) * 0.35,
    );
    canvas.drawCircle(
      Offset(x - r * 0.38, y - r * 0.42),
      r * 0.18,
      lpPaint(ctx, 0xFFFFFF, 0.7 * fade),
    );
  }

  const seedsC = [
    [284, 100],
    [396, 100],
    [300, 182],
    [380, 182],
    [340, 90],
    [268, 140],
    [412, 140],
    [340, 192],
  ];
  const seedsS = [
    [300, 124],
    [320, 112],
    [340, 128],
    [360, 112],
    [380, 124],
    [310, 148],
    [330, 140],
    [350, 148],
    [370, 140],
  ];
  final seeds = ctx.chubby ? seedsC : seedsS;
  for (var i = 0; i < seeds.length; i++) {
    final tw = math.pow(math.max(0.0, lpSin(ctx, 3, i * 1.9)), 2).toDouble();
    if (tw < 0.05) continue;
    final pt = ctx.capPt(seeds[i][0].toDouble(), seeds[i][1].toDouble());
    sparkle(
      canvas,
      pt,
      (3.5 + 7 * tw) * sz,
      lpPaint(ctx, 0xFFF3B0, tw),
      tw * 0.8,
    );
    canvas.drawCircle(pt, 1.4 * sz, lpPaint(ctx, 0xFFFFFF, tw));
  }
}

// --- Kaplan: periyodik kukreme halkalari + kafa sallama ---------------------

/// Dongu basina 2 kukreme; kapi 0..1 (kukreme sirasinda acik).
double _roarU(CelebrationContext ctx) => (ctx.loop * 2) % 1.0;
double _roarG(CelebrationContext ctx) =>
    math.sin(math.pi * (_roarU(ctx) / 0.72).clamp(0.0, 1.0));

CapPose _kaplanLoopPose(CelebrationContext ctx) {
  final g = _roarG(ctx);
  final s = lpSin(ctx, 11);
  return CapPose(
    rotation: s * 0.1 * g,
    dx: s * 3.2 * g,
    scale: 1 + 0.035 * g + 0.012 * lpSin(ctx, 4),
  );
}

void _kaplanLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final m = ctx.mouth + Offset(0, 2 * sz);
  final g = _roarG(ctx);
  final u = _roarU(ctx);

  for (var k = 0; k < 4; k++) {
    final p = (u - 0.03 - k * 0.09) / 0.44;
    if (p <= 0 || p >= 1) continue;
    final e = CelebrationContext.easeOut(p);
    final r = (16 + 120 * e) * sz;
    final col = k.isEven ? 0xEF9F27 : 0x2C2C2A;
    final rect = Rect.fromCircle(center: m, radius: r);
    final paint = strokeOf(
      lpPaint(ctx, col, 0.9 * (1 - p)),
      (6.5 - 4.5 * p) * sz,
    );
    canvas.drawArc(rect, -math.pi * 0.95, math.pi * 0.62, false, paint);
    canvas.drawArc(rect, -math.pi * 0.33, math.pi * 0.62, false, paint);
    canvas.drawArc(rect, math.pi * 0.1, math.pi * 0.8, false, paint);
  }

  for (var i = 0; i < 10; i++) {
    final a = -math.pi + i * tau / 10 + 0.15;
    final p = (u * 2 + i * 0.37) % 1.0;
    final r0 = (50 + 70 * p) * sz, r1 = r0 + 16 * sz;
    canvas.drawLine(
      m + Offset(math.cos(a), math.sin(a)) * r0,
      m + Offset(math.cos(a), math.sin(a)) * r1,
      strokeOf(lpPaint(ctx, 0xBA7517, 0.6 * g * (1 - p)), 3 * sz),
    );
  }

  final tp = CelebrationContext.easeOut((u / 0.1).clamp(0.0, 1.0));
  if (g > 0.05) {
    final c =
        ctx.capCenter +
        Offset(ctx.capWidth * 0.5 + 40 * sz, -ctx.capWidth * 0.42);
    textAt(
      canvas,
      'GRRR!',
      c,
      27 * sz,
      lpPaint(ctx, 0xFAC775, g.clamp(0.0, 1.0)),
      outline: strokeOf(lpPaint(ctx, 0x2C2C2A, g.clamp(0.0, 1.0)), 6 * sz),
      rot: -0.2 + lpSin(ctx, 20) * 0.05,
      scale: (0.6 + 0.4 * tp + 0.12 * g) * (0.5 + 0.5 * math.sqrt(g)),
    );
  }
}

// --- Tekboynuz: kalici gokkusagi + parlayan boynuz ---------------------------

CapPose _tekboynuzLoopPose(CelebrationContext ctx) =>
    CapPose(rotation: 0.03 * lpSin(ctx, 1), dy: -2.4 * lpSin(ctx, 2).abs());

const _rbCols = [0xE24B4A, 0xEF9F27, 0xFAD36B, 0x97C459, 0x85B7EB, 0xAFA9EC];

void _tekboynuzLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final th = lpTheta(ctx);
  final rb = UnicornRainbow(ctx);
  final tip = rb.tip;
  final bw = rb.bw, rIn = rb.rIn;
  final center = rb.center;
  final mid = rb.mid;

  for (var j = 0; j < 6; j++) {
    final radius = rIn + bw * (6 - j - 0.5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      strokeOf(lpPaint(ctx, _rbCols[j], 0.95), bw + 0.6),
    );
  }
  // Yayin uzerinden gecen parilti seridi (turda bir kez).
  final sweep = -0.25 + 1.5 * ctx.loop;
  for (var j = 0; j < 6; j++) {
    final radius = rIn + bw * (6 - j - 0.5);
    final a0 = (sweep - 0.1).clamp(0.0, 1.0);
    final a1 = (sweep + 0.1).clamp(0.0, 1.0);
    if (a1 <= a0) continue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi + math.pi * a0,
      math.pi * (a1 - a0),
      false,
      strokeOf(lpPaint(ctx, 0xFFFFFF, 0.5), bw + 0.6),
    );
  }
  for (final side in const [-1, 1]) {
    final cx = 340 + side * (mid + 2);
    final bob = math.sin(th * 2 + side) * 2.5 * sz;
    final cc = Offset(cx, center.dy + 2 + bob);
    for (final b in const [
      [-14.0, 4.0, 13.0],
      [0.0, -4.0, 17.0],
      [15.0, 5.0, 12.0],
      [-3.0, 8.0, 14.0],
    ]) {
      canvas.drawCircle(
        cc + Offset(b[0] * side, b[1]) * (sz * 0.9),
        b[2] * sz * 0.9,
        lpPaint(ctx, 0xFFFFFF, 0.95),
      );
    }
  }
  for (var i = 0; i < 12; i++) {
    final a = math.pi + math.pi * (0.04 + 0.92 * ctx.rand(i, 7));
    final rad = rIn + bw * (6 * ctx.rand(i, 8));
    final tw = math.max(0.0, lpSin(ctx, 3, i * 2.1));
    sparkle(
      canvas,
      center + Offset(math.cos(a), math.sin(a)) * rad,
      (3 + 6 * tw) * sz,
      lpPaint(ctx, 0xFFFFFF, tw),
      i.toDouble(),
    );
  }

  // Gökkuşağı başın arkasında kalsın.
  ctx.drawCapOver(canvas);

  // Boynuz isigi
  final pulse = 0.55 + 0.45 * math.sin(th * 3);
  canvas.drawCircle(
    tip,
    (20 + 14 * pulse) * sz,
    lpPaint(ctx, 0xFFD66B, 0.38 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
  );
  for (var i = 0; i < 8; i++) {
    final a = i * tau / 8 + th / 8;
    final r0 = (9 + 2 * pulse) * sz, r1 = (17 + 9 * pulse) * sz;
    canvas.drawLine(
      tip + Offset(math.cos(a), math.sin(a)) * r0,
      tip + Offset(math.cos(a), math.sin(a)) * r1,
      strokeOf(lpPaint(ctx, 0xFFF1B8, 0.8 * pulse), 2 * sz),
    );
  }
  sparkle(canvas, tip, (13 + 8 * pulse) * sz, lpPaint(ctx, 0xFFFFFF, 0.95), 0);
  sparkle(
    canvas,
    tip,
    (8 + 5 * pulse) * sz,
    lpPaint(ctx, 0xFFE58F, 0.9),
    math.pi / 4,
  );
  // Boynuz cevresinde donen, pirildayan yildizlar
  for (var i = 0; i < 5; i++) {
    final a = i * tau / 5 + th;
    final rad = (26 + 8 * math.sin(th * 2 + i)) * sz;
    final tw = math.max(0.0, lpSin(ctx, 4, i * 1.3));
    sparkle(
      canvas,
      tip + Offset(math.cos(a), math.sin(a) * 0.8) * rad,
      (3 + 5 * tw) * sz,
      lpPaint(ctx, _rbCols[i % 6], 0.4 + 0.6 * tw),
      a,
    );
  }
  const n = 12;
  for (var i = 0; i < n; i++) {
    final e = lpEmit(ctx, i, n, 2);
    final dir = (lpRand(ctx, e.seed, 1) - 0.5) * 2.0;
    final p = e.p;
    final pos =
        tip +
        Offset(
          dir * 56 * sz * CelebrationContext.easeOut(p),
          -6 * sz + 70 * sz * p * p + 12 * sz * p,
        );
    sparkle(
      canvas,
      pos,
      (2.5 + 4 * lpRand(ctx, e.seed, 2)) * sz * (1 - p * 0.5),
      lpPaint(ctx, _rbCols[i % 6], lpFade(p, 0.1, 0.5)),
      p * 6,
    );
  }
}

// --- Astronot: anten, roket, kayan yildiz, vizor yazisi ----------------------

CapPose _astronotLoopPose(CelebrationContext ctx) =>
    CapPose(dy: lpSin(ctx, 2) * 2.6, rotation: lpSin(ctx, 1) * 0.025);

final Path _visorChubbyL = svgPath(visorChubby);
final Path _visorSlimL = svgPath(visorSlim);

void _astronotLoop(Canvas canvas, CelebrationContext ctx) {
  final th = lpTheta(ctx);
  lpDriftStars(canvas, ctx, 20, 3, xLeft: 168, xRight: 400, yTop: 100, yH: 370);

  // Kayan yildiz (turda bir kez).
  final ss = ((ctx.loop - 0.12) / 0.3).clamp(0.0, 1.0);
  if (ss > 0 && ss < 1) {
    final head = Offset.lerp(
      const Offset(512, 86),
      const Offset(392, 134),
      ss,
    )!;
    const dir = Offset(-120, 48);
    final tail = head - dir / dir.distance * 74;
    final f = math.sin(ss * math.pi);
    canvas.drawLine(
      head,
      tail,
      Paint()
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: 0.95 * f),
            const Color(0x00FFFFFF),
          ],
        ).createShader(Rect.fromPoints(head, tail)),
    );
    sparkle(canvas, head, 7, lpPaint(ctx, 0xFFFFFF, f), ss * 5);
  }

  // Havada asili duran roket: salinir, alevi titrer, duman birakir.
  final rx = 206 + math.sin(th * 2) * 7;
  final ry = 300 + math.sin(th * 2 + 1.2) * 12;
  final tilt = math.cos(th * 2) * 0.08;
  final flick = math.sin(th * 15);
  canvas.save();
  canvas.translate(rx, ry);
  canvas.rotate(tilt);
  for (var i = 0; i < 8; i++) {
    final e = lpEmit(ctx, i, 8, 3);
    final p = e.p;
    puff(
      canvas,
      ctx,
      Offset(math.sin(p * 5 + i) * 6, 38 + p * 80),
      4 + 9 * p,
      0xF1EFE8,
      0.7 * lpFade(p, 0.1, 0.6),
      0xB4B2A9,
    );
  }
  final fl = 28 + 8 * flick + 3 * math.sin(th * 23);
  canvas.drawPath(
    Path()
      ..moveTo(-8, 25)
      ..quadraticBezierTo(-12, 25 + fl * 0.6, 0, 25 + fl)
      ..quadraticBezierTo(12, 25 + fl * 0.6, 8, 25)
      ..close(),
    lpPaint(ctx, 0xEF9F27, 0.95),
  );
  canvas.drawPath(
    Path()
      ..moveTo(-4.5, 25)
      ..quadraticBezierTo(-6, 25 + fl * 0.45, 0, 25 + fl * 0.7)
      ..quadraticBezierTo(6, 25 + fl * 0.45, 4.5, 25)
      ..close(),
    lpPaint(ctx, 0xFFF1B8, 0.95),
  );
  for (final s in const [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(s * 9, 6)
        ..quadraticBezierTo(s * 22, 14, s * 20, 29)
        ..lineTo(s * 9, 24)
        ..close(),
      lpPaint(ctx, 0xE24B4A),
    );
  }
  canvas.drawPath(
    Path()
      ..moveTo(0, -34)
      ..quadraticBezierTo(15, -14, 11, 25)
      ..lineTo(-11, 25)
      ..quadraticBezierTo(-15, -14, 0, -34)
      ..close(),
    lpPaint(ctx, 0xF1EFE8),
  );
  canvas.drawPath(
    Path()
      ..moveTo(0, -34)
      ..quadraticBezierTo(8, -24, 10, -12)
      ..lineTo(-10, -12)
      ..quadraticBezierTo(-8, -24, 0, -34)
      ..close(),
    lpPaint(ctx, 0xE24B4A),
  );
  canvas.drawCircle(const Offset(0, 2), 6.5, lpPaint(ctx, 0x185FA5));
  canvas.drawCircle(const Offset(0, 2), 4.2, lpPaint(ctx, 0x9CCBF5));
  canvas.drawCircle(const Offset(-1.4, 0.6), 1.4, lpPaint(ctx, 0xFFFFFF, 0.9));
  canvas.restore();

  // Anten: yanip soner isik + radyo dalgalari.
  // Resimli kaskta anten ışığı kubbenin tepesine oturur (eski vektör kapakta
  // ham koordinat).
  final illus = IllustratedArtwork.byId['astronot'] != null;
  final ant = illus
      ? ctx.capImagePt(0.5, 0.175)
      : (ctx.chubby ? const Offset(340, 22) : const Offset(368, 68));
  final ar = illus ? 4.4 : (ctx.chubby ? 7.0 : 5.0);
  final on = (ctx.loop * 3) % 1.0 < 0.5;
  (illus ? inPlace : inCap)(canvas, ctx, () {
    if (on) {
      canvas.drawCircle(
        ant,
        ar * 2.6,
        lpPaint(ctx, 0xE24B4A, 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(ant, ar * 1.15, lpPaint(ctx, 0xFF6B6A));
      canvas.drawCircle(
        ant + Offset(-ar * 0.3, -ar * 0.3),
        ar * 0.35,
        lpPaint(ctx, 0xFFFFFF, 0.9),
      );
    } else {
      canvas.drawCircle(ant, ar, lpPaint(ctx, 0x7A1F1F));
    }
    for (var k = 0; k < 3; k++) {
      final p = (ctx.loop * 3 + k / 3) % 1.0;
      final r = ar * 1.6 + p * 26;
      canvas.drawArc(
        Rect.fromCircle(center: ant, radius: r),
        -math.pi * 0.85,
        math.pi * 0.7,
        false,
        strokeOf(lpPaint(ctx, 0xFFB4B2, 0.8 * (1 - p)), 2.2),
      );
    }
  });

  // Resimli astronotun yuzunu eski vizor yazisiyla kapatma.
  if (IllustratedArtwork.byId['astronot'] == null) {
    inCap(canvas, ctx, () {
      final visor = ctx.chubby ? _visorChubbyL : _visorSlimL;
      final b = visor.getBounds();
      canvas.drawPath(
        visor,
        lpPaint(ctx, 0x5DCAA5, 0.28 + 0.14 * math.sin(th * 4)),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: 'TEBRİKLER!  ',
          style: TextStyle(
            color: const Color(0xFFB8F5E0),
            fontSize: ctx.chubby ? 24 : 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.clipPath(visor);
      final unit = tp.width;
      var x = b.right - ctx.loop * unit * 2;
      x -= unit * ((x - b.left) / unit).ceil();
      for (; x < b.right; x += unit) {
        tp.paint(canvas, Offset(x, b.center.dy - tp.height / 2));
      }
      canvas.restore();
    });
  }
}

// --- Kamp: atesin titremesi, yukselen duman, donen pusula --------------------

CapPose _kampLoopPose(CelebrationContext ctx) =>
    CapPose(rotation: lpSin(ctx, 1) * 0.03, dy: -1.6 * lpSin(ctx, 4).abs());

void _kampLoop(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final th = lpTheta(ctx);
  const base = Offset(212, 470);

  canvas.drawCircle(
    base + const Offset(0, -26),
    58 + 5 * math.sin(th * 8),
    lpPaint(ctx, 0xFAC775, 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
  );

  const n = 9;
  for (var i = 0; i < n; i++) {
    final e = lpEmit(ctx, i, n, 2);
    final p = e.p;
    final x = base.dx + math.sin(p * 5 + i * 1.3) * 14 + p * 26;
    final y = base.dy - 54 - p * 215;
    puff(
      canvas,
      ctx,
      Offset(x, y),
      6 + 17 * p,
      0xD3D1C7,
      0.62 * math.sin(math.pi * math.min(1.0, p * 1.1 + 0.02)),
      0xB4B2A9,
    );
  }

  void log(double ang, int col, int hi) {
    canvas.save();
    canvas.translate(base.dx, base.dy - 5);
    canvas.rotate(ang);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-34, -6, 68, 12),
        const Radius.circular(6),
      ),
      lpPaint(ctx, col),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-32, -4, 64, 4),
        const Radius.circular(3),
      ),
      lpPaint(ctx, hi, 0.7),
    );
    canvas.drawCircle(const Offset(34, 0), 5.5, lpPaint(ctx, 0xC49A6C));
    canvas.drawCircle(const Offset(-34, 0), 5.5, lpPaint(ctx, 0xC49A6C));
    canvas.restore();
  }

  log(0.28, 0x5A3418, 0x8B5A2B);

  void flame(double w, double h, int col, double ph, double dx) {
    final fl =
        1 + 0.16 * math.sin(th * 8 + ph) + 0.07 * math.sin(th * 15 + ph * 2);
    final sw = math.sin(th * 5 + ph) * 3.8;
    final hh = h * fl;
    final b = base + Offset(dx, -9);
    canvas.drawPath(
      Path()
        ..moveTo(b.dx - w, b.dy)
        ..cubicTo(
          b.dx - w * 1.25,
          b.dy - hh * 0.35,
          b.dx - w * 0.2 + sw,
          b.dy - hh * 0.6,
          b.dx + sw * 1.3,
          b.dy - hh,
        )
        ..cubicTo(
          b.dx + w * 0.3 + sw,
          b.dy - hh * 0.55,
          b.dx + w * 1.25,
          b.dy - hh * 0.3,
          b.dx + w,
          b.dy,
        )
        ..quadraticBezierTo(b.dx, b.dy + w * 0.5, b.dx - w, b.dy)
        ..close(),
      lpPaint(ctx, col, 0.96),
    );
  }

  flame(24, 62, 0xE24B4A, 0, 0);
  flame(18, 70, 0xEF9F27, 1.7, -9);
  flame(16, 56, 0xEF9F27, 3.1, 11);
  flame(11, 46, 0xFAC775, 0.8, 0);
  flame(6, 30, 0xFFF1B8, 2.3, 0);
  log(-0.28, 0x6B3E16, 0x9A6B3A);

  for (var i = 0; i < 10; i++) {
    final e = lpEmit(ctx, i, 10, 3);
    final p = e.p;
    final pos =
        base +
        Offset(
          math.sin(p * 8 + i * 2) * 16 + (lpRand(ctx, e.seed, 1) - 0.5) * 30,
          -30 - p * (70 + 60 * lpRand(ctx, e.seed, 2)),
        );
    canvas.drawCircle(
      pos,
      (2.6 - p * 1.4).clamp(0.6, 3.0),
      lpPaint(ctx, i.isEven ? 0xFAC775 : 0xEF9F27, lpFade(p, 0.05, 0.5)),
    );
  }

  // Resimli Kamp kapağı kendi normal/happy pusula yönlerini taşır.
  if (IllustratedArtwork.byId.containsKey('kamp')) return;

  // Pusula: tur basina bir tam donus + titreme.
  final cr = ctx.chubby ? 30.0 : 16.0;
  final cpt = ctx.chubby ? const Offset(340, 118) : const Offset(340, 122);
  final ang = th + 0.28 * math.sin(th * 6);
  inCap(canvas, ctx, () {
    canvas.drawCircle(cpt, cr * 1.04, ctx.solid(0xF1EFE8));
    canvas.drawCircle(cpt, cr * 0.8, ctx.solid(0x2C2C2A));
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final major = i.isEven;
      canvas.drawLine(
        cpt + Offset(math.cos(a), math.sin(a)) * cr * (major ? 0.58 : 0.64),
        cpt + Offset(math.cos(a), math.sin(a)) * cr * 0.76,
        strokeOf(Paint()..color = const Color(0xFFB4B2A9), cr * 0.05),
      );
    }
    canvas.save();
    canvas.translate(cpt.dx, cpt.dy);
    canvas.rotate(ang);
    canvas.drawPath(
      Path()
        ..moveTo(0, -cr * 0.67)
        ..lineTo(cr * 0.2, 0)
        ..lineTo(-cr * 0.2, 0)
        ..close(),
      Paint()..color = const Color(0xFFE24B4A),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, cr * 0.67)
        ..lineTo(cr * 0.2, 0)
        ..lineTo(-cr * 0.2, 0)
        ..close(),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawCircle(
      Offset.zero,
      cr * 0.1,
      Paint()..color = const Color(0xFF888780),
    );
    canvas.restore();
  });
  final glint = math.max(0.0, lpSin(ctx, 3));
  sparkle(
    canvas,
    ctx.capPt(cpt.dx + cr * 0.7, cpt.dy - cr * 0.7),
    (4 + 6 * glint) * sz,
    lpPaint(ctx, 0xFFFFFF, glint),
  );
}
