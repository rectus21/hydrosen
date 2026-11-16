import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../svg_path.dart';
import '../thermos_theme.dart';
import 'celebration_context.dart';
import 'celebrations_g1_kit.dart';
import 'celebrations_g1_more.dart';

// GRUP 1 imza kutlamalari (klasik, cilek, kaplan, tekboynuz, astronot, kamp);
// robot..maviejderha celebrations_g1_more.dart dosyasindadir.
//
// Konumlar ctx capalari / ctx.capPt (ham kapak koordinati) ile; tombul
// kucultme ve kapak pozu otomatik. reduceMotion'da emit() sabit, dagilmis kare
// verir (t=0.5); zamana bagli titresim ctx.reduceMotion ile kapatilir.

final Map<String, SignatureCelebration> g1Celebrations = {
  'klasik': _klasikFountain,
  'cilek': _cilekHearts,
  'kaplan': _kaplanRoar,
  'tekboynuz': _tekboynuzRainbow,
  'astronot': _astronotLaunch,
  'kamp': _kampFire,
  ...g1MoreCelebrations,
};

final Map<String, CapPoseFn> g1CapPoses = {
  'klasik': _klasikPose,
  'cilek': _cilekPose,
  'kaplan': _kaplanPose,
  'astronot': _astronotPose,
  'kamp': _kampPose,
  ...g1MoreCapPoses,
};

// --- Klasik: kapaktan firskiye ------------------------------------------------

CapPose _klasikPose(CelebrationContext ctx) {
  final env = window(ctx, 0.04, 0.86);
  return CapPose(
    dy: -1.6 * math.sin(ctx.elapsed * 31) * env,
    scale: 1 + 0.012 * math.sin(ctx.elapsed * 23) * env,
  );
}

void _klasikFountain(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final o = ctx.capPt(340, ctx.chubby ? 62 : 90);
  final env = window(ctx, 0.03, 0.86);
  final e = ctx.reduceMotion ? 0.4 : ctx.elapsed;

  // Dalgalanan su sutunu.
  final jetH = (56 + 10 * math.sin(e * 11)) * sz * env;
  if (jetH > 1) {
    final sway = math.sin(e * 7) * 3 * sz;
    final w = 9 * sz;
    canvas.drawPath(
      Path()
        ..moveTo(o.dx - w, o.dy + 2)
        ..quadraticBezierTo(
            o.dx - w * 0.5 + sway, o.dy - jetH * 0.6, o.dx + sway, o.dy - jetH)
        ..quadraticBezierTo(
            o.dx + w * 0.5 + sway, o.dy - jetH * 0.6, o.dx + w, o.dy + 2)
        ..close(),
      ctx.paintOf(0x85B7EB, 0.9),
    );
    canvas.drawPath(
      Path()
        ..moveTo(o.dx - w * 0.35, o.dy)
        ..quadraticBezierTo(o.dx - w * 0.2 + sway, o.dy - jetH * 0.5,
            o.dx + sway * 0.9, o.dy - jetH * 0.85)
        ..quadraticBezierTo(
            o.dx + w * 0.1 + sway, o.dy - jetH * 0.5, o.dx + w * 0.1, o.dy),
      ctx.paintOf(0xE6F1FB, 0.9),
    );
  }

  // Firlayan damlalar.
  const n = 36;
  const cols = [0x378ADD, 0x85B7EB, 0xB5D4F4, 0x378ADD];
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 0.95, start: 0.02, end: 0.84);
    if (!em.live) continue;
    final a = -math.pi / 2 + (rr(ctx, i, em, 3) - 0.5) * 1.3;
    final v = (185 + 85 * rr(ctx, i, em, 4)) * sz;
    final g = 470 * sz;
    final s = em.p * 1.25;
    final pos = o +
        Offset(math.cos(a) * v * s, math.sin(a) * v * s + 0.5 * g * s * s);
    final vel = Offset(math.cos(a) * v, math.sin(a) * v + g * s);
    final dir = math.atan2(vel.dy, vel.dx);
    final r = (4 + 3 * rr(ctx, i, em, 5)) * sz;
    final fade = (em.p < 0.1 ? em.p / 0.1 : 1.0) *
        (em.p > 0.86 ? (1 - em.p) / 0.14 : 1.0);
    drop(canvas, pos, r * (0.6 + 0.4 * fade), dir,
        ctx.paintOf(cols[i % cols.length], 0.95 * fade));
    canvas.drawCircle(pos + Offset(-r * 0.3, -r * 0.2), r * 0.28,
        ctx.paintOf(0xFFFFFF, 0.8 * fade));
  }

  // Namlu cevresinde halkalar.
  for (var k = 0; k < 2; k++) {
    final p = ctx.reduceMotion ? 0.3 + k * 0.35 : ((ctx.t * 2.4 + k * 0.5) % 1.0);
    canvas.drawOval(
      Rect.fromCenter(
          center: o + Offset(0, 3 * sz),
          width: (18 + 52 * p) * sz,
          height: (6 + 14 * p) * sz),
      strokeOf(ctx.paintOf(0xB5D4F4, 0.85 * (1 - p) * env), 2.2 * sz),
    );
  }
}

// --- Cilek: ziplayan kapak, kalpler, tohum parildamasi ----------------------

CapPose _cilekPose(CelebrationContext ctx) {
  final sp = ctx.span(0.04, 0.78);
  final u = sp * 3.2;
  final h = math.sin(math.pi * u).abs();
  final live = sp > 0 && sp < 1 ? 1.0 : 0.0;
  return CapPose(
    dy: -17 * h * live,
    rotation: 0.05 * math.sin(u * math.pi) * live,
    scale: 1 + (0.045 * h - 0.03 * (1 - h) * (1 - h)) * live,
  );
}

void _cilekHearts(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final c = ctx.capCenter;
  const cols = [0xE24B4A, 0xED93B1, 0xD4537E, 0xF09595, 0xFF6F91];
  const n = 16;
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 1.15, start: 0.03, end: 0.82);
    if (!em.live) continue;
    final side = rr(ctx, i, em, 1) < 0.5 ? -1.0 : 1.0;
    final x0 = c.dx + side * ctx.capWidth * (0.2 + 0.3 * rr(ctx, i, em, 6));
    final rise = (55 + 45 * rr(ctx, i, em, 2)) * (0.85 + sz * 0.15);
    final p = em.p;
    final y = c.dy - ctx.capWidth * 0.12 - rise * CelebrationContext.easeOut(p);
    final x = x0 + side * 46 * sz * CelebrationContext.easeOut(p) + math.sin(p * 7 + i) * 7 * sz;
    final grow = CelebrationContext.easeOut(p * 4);
    final r = (8 + 7 * rr(ctx, i, em, 3)) * sz * grow;
    final fade = p > 0.7 ? (1 - p) / 0.3 : 1.0;
    final col = cols[(i + em.cycle) % cols.length];
    heart(canvas, Offset(x, y), r, ctx.paintOf(col, 0.95 * fade),
        math.sin(p * 6 + i) * 0.35);
    canvas.drawCircle(Offset(x - r * 0.38, y - r * 0.42), r * 0.18,
        ctx.paintOf(0xFFFFFF, 0.7 * fade));
  }

  // Tohumlarda parilti.
  const seedsC = [
    [284, 100], [396, 100], [300, 182], [380, 182],
    [340, 90], [268, 140], [412, 140], [340, 192],
  ];
  const seedsS = [
    [300, 124], [320, 112], [340, 128], [360, 112], [380, 124],
    [310, 148], [330, 140], [350, 148], [370, 140],
  ];
  final seeds = ctx.chubby ? seedsC : seedsS;
  for (var i = 0; i < seeds.length; i++) {
    final tw = ctx.reduceMotion
        ? (i.isEven ? 0.95 : 0.35)
        : math
            .pow(math.max(0.0, math.sin(ctx.elapsed * 6.2 + i * 1.9)), 2)
            .toDouble();
    if (tw < 0.05) continue;
    final pt = ctx.capPt(seeds[i][0].toDouble(), seeds[i][1].toDouble());
    sparkle(canvas, pt, (3.5 + 7 * tw) * sz, ctx.paintOf(0xFFF3B0, tw), tw * 0.8);
    canvas.drawCircle(pt, 1.4 * sz, ctx.paintOf(0xFFFFFF, tw));
  }
}

// --- Kaplan: kukreme halkalari + kafa sallama --------------------------------

double _roarGate(CelebrationContext ctx) {
  if (ctx.reduceMotion) return 1;
  final t = ctx.t;
  double w(double a, double b) =>
      math.sin(((t - a) / (b - a)).clamp(0.0, 1.0) * math.pi);
  return math.max(w(0.06, 0.48), w(0.5, 0.9));
}

CapPose _kaplanPose(CelebrationContext ctx) {
  final g = _roarGate(ctx);
  final s = math.sin(ctx.elapsed * tau * 4.2);
  return CapPose(
    rotation: s * 0.1 * g,
    dx: s * 3.2 * g,
    scale: 1 + 0.035 * g * math.sin(ctx.elapsed * tau * 2.1).abs(),
  );
}

void _kaplanRoar(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final m = ctx.mouth + Offset(0, 2 * sz);
  final g = _roarGate(ctx);

  // Genisleyen kukreme halkalari (turuncu / siyah donusumlu).
  for (var k = 0; k < 8; k++) {
    double p;
    if (ctx.reduceMotion) {
      if (k > 3) continue;
      p = 0.15 + k * 0.22;
    } else {
      final t0 = (k < 4 ? 0.07 : 0.5) + (k % 4) * 0.085;
      p = (ctx.t - t0) / 0.3;
      if (p <= 0 || p >= 1) continue;
    }
    final e = CelebrationContext.easeOut(p);
    final r = (16 + 120 * e) * sz;
    final col = k.isEven ? 0xEF9F27 : 0x2C2C2A;
    final rect = Rect.fromCircle(center: m, radius: r);
    final paint =
        strokeOf(ctx.paintOf(col, 0.9 * (1 - p)), (6.5 - 4.5 * p) * sz);
    canvas.drawArc(rect, -math.pi * 0.95, math.pi * 0.62, false, paint);
    canvas.drawArc(rect, -math.pi * 0.33, math.pi * 0.62, false, paint);
    canvas.drawArc(rect, math.pi * 0.1, math.pi * 0.8, false, paint);
  }

  // Hiz cizgileri.
  for (var i = 0; i < 10; i++) {
    final a = -math.pi + i * tau / 10 + 0.15;
    final p = ctx.reduceMotion ? 0.5 : ((ctx.t * 5 + i * 0.37) % 1.0);
    final r0 = (50 + 70 * p) * sz, r1 = r0 + 16 * sz;
    canvas.drawLine(
      m + Offset(math.cos(a), math.sin(a)) * r0,
      m + Offset(math.cos(a), math.sin(a)) * r1,
      strokeOf(ctx.paintOf(0xBA7517, 0.55 * g * (1 - p)), 3 * sz),
    );
  }

  // "GRRR!" yazisi.
  final tp =
      ctx.reduceMotion ? 0.6 : CelebrationContext.easeOut(ctx.span(0.06, 0.16));
  final ga = g.clamp(0.0, 1.0);
  if (tp > 0.02 && ga > 0.05) {
    final c = ctx.capCenter +
        Offset(ctx.capWidth * 0.5 + 40 * sz, -ctx.capWidth * 0.42);
    final shake = ctx.reduceMotion ? 0.0 : math.sin(ctx.elapsed * 40) * 0.05;
    textAt(
      canvas,
      'GRRR!',
      c,
      27 * sz,
      ctx.paintOf(0xFAC775, ga),
      outline: strokeOf(ctx.paintOf(0x2C2C2A, ga), 6 * sz),
      rot: -0.2 + shake,
      scale: 0.6 + 0.4 * tp + 0.12 * g,
    );
  }
}

// --- Tekboynuz: kendini cizen gokkusagi + boynuz isigi ----------------------

const _rainbowCols = [
  0xE24B4A, 0xEF9F27, 0xFAD36B, 0x97C459, 0x85B7EB, 0xAFA9EC,
];

void _tekboynuzRainbow(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final tip = ctx.capPt(340, ctx.chubby ? 10 : 34);
  final bw = ctx.chubby ? 6.5 : 4.4;
  const rIn = 172.0;
  final cy = tip.dy - 8 + rIn;
  final center = Offset(340, cy);

  final prog = ctx.reduceMotion
      ? 1.0
      : CelebrationContext.easeInOut(ctx.span(0.04, 0.52));
  if (prog > 0) {
    for (var j = 0; j < 6; j++) {
      final radius = rIn + bw * (6 - j - 0.5);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi * prog,
        false,
        strokeOf(ctx.paintOf(_rainbowCols[j], 0.95), bw + 0.6),
      );
    }
    final ang = math.pi + math.pi * prog;
    final mid = rIn + bw * 3;
    final head = center + Offset(math.cos(ang), math.sin(ang)) * mid;
    if (prog < 1) {
      sparkle(canvas, head, 15 * sz, ctx.paintOf(0xFFFFFF, 0.95), ctx.elapsed * 4);
      canvas.drawCircle(head, 8 * sz, ctx.paintOf(0xFFF1B8, 0.5));
    }
    // Bulutlar (yayin iki ucunda)
    for (final side in const [-1, 1]) {
      if (side > 0 && prog < 0.98) continue;
      final cx = 340 + side * (mid + 2);
      final pop = side < 0 ? CelebrationContext.easeOut(prog * 6) : 1.0;
      final cc = Offset(cx, cy + 2);
      for (final b in const [
        [-14.0, 4.0, 13.0],
        [0.0, -4.0, 17.0],
        [15.0, 5.0, 12.0],
        [-3.0, 8.0, 14.0],
      ]) {
        canvas.drawCircle(cc + Offset(b[0] * side, b[1]) * (sz * 0.9),
            b[2] * sz * pop * 0.9, ctx.paintOf(0xFFFFFF, 0.95));
      }
    }
    // Yayda yildiz tozu
    for (var i = 0; i < 12; i++) {
      final a = math.pi + math.pi * (0.04 + 0.92 * ctx.rand(i, 7)) * prog;
      final rad = rIn + bw * (6 * ctx.rand(i, 8));
      final tw = ctx.reduceMotion
          ? 0.8
          : math.max(0.0, math.sin(ctx.elapsed * 7 + i * 2.1));
      sparkle(
        canvas,
        center + Offset(math.cos(a), math.sin(a)) * rad,
        (3 + 5 * tw) * sz,
        ctx.paintOf(0xFFFFFF, tw),
        i.toDouble(),
      );
    }
  }

  // Boynuz isigi
  final pulse = ctx.reduceMotion ? 0.9 : 0.55 + 0.45 * math.sin(ctx.elapsed * 9);
  canvas.drawCircle(
    tip,
    (20 + 14 * pulse) * sz,
    ctx.paintOf(0xFFD66B, 0.38 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
  );
  for (var i = 0; i < 8; i++) {
    final a = ctx.reduceMotion ? i * tau / 8 : i * tau / 8 + ctx.elapsed * 1.6;
    final r0 = (9 + 2 * pulse) * sz, r1 = (17 + 9 * pulse) * sz;
    canvas.drawLine(
      tip + Offset(math.cos(a), math.sin(a)) * r0,
      tip + Offset(math.cos(a), math.sin(a)) * r1,
      strokeOf(ctx.paintOf(0xFFF1B8, 0.8 * pulse), 2 * sz),
    );
  }
  sparkle(canvas, tip, (13 + 8 * pulse) * sz, ctx.paintOf(0xFFFFFF, 0.95), 0);
  sparkle(canvas, tip, (8 + 5 * pulse) * sz, ctx.paintOf(0xFFE58F, 0.9),
      math.pi / 4);

  // Boynuzdan dokulen parlak toz
  const n = 10;
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 0.9, start: 0.1, end: 0.86);
    if (!em.live) continue;
    final dir = (rr(ctx, i, em, 1) - 0.5) * 2.0;
    final p = em.p;
    final pos = tip +
        Offset(dir * 56 * sz * CelebrationContext.easeOut(p),
            -6 * sz + 70 * sz * p * p + 12 * sz * p);
    sparkle(canvas, pos, (2.5 + 4 * rr(ctx, i, em, 2)) * sz * (1 - p * 0.5),
        ctx.paintOf(_rainbowCols[(i + em.cycle) % 6], 1 - p), p * 6);
  }
}

// --- Astronot: anten, roket alevi, vizor yazisi -------------------------------

CapPose _astronotPose(CelebrationContext ctx) => CapPose(
      dy: math.sin(ctx.elapsed * 4.6) * 2.4,
      rotation: math.sin(ctx.elapsed * 3.1) * 0.025,
    );

final Path _visorChubbyPath = svgPath(visorChubby);
final Path _visorSlimPath = svgPath(visorSlim);

void _astronotLaunch(Canvas canvas, CelebrationContext ctx) {
  // Yildizlar (kenarlarda).
  for (var i = 0; i < 18; i++) {
    final left = ctx.rand(i, 3) < 0.5;
    final x = left ? 132 + ctx.rand(i, 4) * 112 : 436 + ctx.rand(i, 4) * 112;
    final y = 22 + ctx.rand(i, 5) * 458;
    final tw = ctx.reduceMotion
        ? (i % 3 == 0 ? 0.3 : 0.9)
        : math.max(0.0, math.sin(ctx.elapsed * 4.4 + i * 1.7));
    if (tw < 0.04) continue;
    sparkle(canvas, Offset(x, y), (3 + 8 * tw) * (0.7 + 0.5 * ctx.rand(i, 6)),
        ctx.paintOf(i % 4 == 0 ? 0xFFE58F : 0xFFFFFF, tw));
  }

  // Kayan yildiz.
  final ss = ctx.reduceMotion ? 0.5 : ctx.span(0.12, 0.42);
  if (ss > 0 && ss < 1) {
    final head = Offset.lerp(const Offset(548, 40), const Offset(380, 118), ss)!;
    const dir = Offset(-168, 78);
    final tail = head - dir / dir.distance * 74;
    final f = math.sin(ss * math.pi);
    canvas.drawLine(
      head,
      tail,
      Paint()
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.95 * f * ctx.alpha),
          const Color(0x00FFFFFF),
        ]).createShader(Rect.fromPoints(head, tail)),
    );
    sparkle(canvas, head, 7, ctx.paintOf(0xFFFFFF, f), ss * 5);
  }

  // Roket (soldan yukari ucar), alevi titrer.
  final rp = ctx.reduceMotion
      ? 0.5
      : CelebrationContext.easeInOut(ctx.span(0.06, 0.8));
  final ry = 470 - rp * 430;
  final rx = 190 + math.sin(rp * 9) * 9;
  final tilt = math.cos(rp * 9) * 0.1;
  final flick = ctx.reduceMotion ? 0.0 : math.sin(ctx.elapsed * 47);
  canvas.save();
  canvas.translate(rx, ry);
  canvas.rotate(tilt);
  for (var i = 0; i < 9; i++) {
    final em = emit(ctx, i, 9, period: 0.5, start: 0.06, end: 0.8);
    if (!em.live) continue;
    final p = em.p;
    puff(canvas, ctx, Offset(math.sin(p * 5 + i) * 6, 36 + p * 80), 4 + 9 * p,
        0xF1EFE8, 0.7 * (1 - p), 0xB4B2A9);
  }
  final fl = 26 + 8 * flick;
  canvas.drawPath(
    Path()
      ..moveTo(-8, 25)
      ..quadraticBezierTo(-12, 25 + fl * 0.6, 0, 25 + fl)
      ..quadraticBezierTo(12, 25 + fl * 0.6, 8, 25)
      ..close(),
    ctx.paintOf(0xEF9F27, 0.95),
  );
  canvas.drawPath(
    Path()
      ..moveTo(-4.5, 25)
      ..quadraticBezierTo(-6, 25 + fl * 0.45, 0, 25 + fl * 0.7)
      ..quadraticBezierTo(6, 25 + fl * 0.45, 4.5, 25)
      ..close(),
    ctx.paintOf(0xFFF1B8, 0.95),
  );
  for (final s in const [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(s * 9, 6)
        ..quadraticBezierTo(s * 22, 14, s * 20, 29)
        ..lineTo(s * 9, 24)
        ..close(),
      ctx.paintOf(0xE24B4A),
    );
  }
  canvas.drawPath(
    Path()
      ..moveTo(0, -34)
      ..quadraticBezierTo(15, -14, 11, 25)
      ..lineTo(-11, 25)
      ..quadraticBezierTo(-15, -14, 0, -34)
      ..close(),
    ctx.paintOf(0xF1EFE8),
  );
  canvas.drawPath(
    Path()
      ..moveTo(0, -34)
      ..quadraticBezierTo(8, -24, 10, -12)
      ..lineTo(-10, -12)
      ..quadraticBezierTo(-8, -24, 0, -34)
      ..close(),
    ctx.paintOf(0xE24B4A),
  );
  canvas.drawCircle(const Offset(0, 2), 6.5, ctx.paintOf(0x185FA5));
  canvas.drawCircle(const Offset(0, 2), 4.2, ctx.paintOf(0x9CCBF5));
  canvas.drawCircle(const Offset(-1.4, 0.6), 1.4, ctx.paintOf(0xFFFFFF, 0.9));
  canvas.restore();

  // Anten: yanip soner kirmizi isik + radyo dalgalari.
  final ant = ctx.chubby ? const Offset(340, 22) : const Offset(368, 68);
  final ar = ctx.chubby ? 7.0 : 5.0;
  final beat = ctx.reduceMotion ? 0.0 : (ctx.elapsed * 2.6 % 1.0);
  final on = beat < 0.5;
  inCap(canvas, ctx, () {
    if (on) {
      canvas.drawCircle(
          ant,
          ar * 2.6,
          ctx.paintOf(0xE24B4A, 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawCircle(ant, ar * 1.15, ctx.paintOf(0xFF6B6A));
      canvas.drawCircle(ant + Offset(-ar * 0.3, -ar * 0.3), ar * 0.35,
          ctx.paintOf(0xFFFFFF, 0.9));
    } else {
      canvas.drawCircle(ant, ar, ctx.paintOf(0x7A1F1F));
    }
    for (var k = 0; k < 3; k++) {
      final p =
          ctx.reduceMotion ? (k + 0.5) / 3 : ((ctx.elapsed * 1.3 + k / 3) % 1.0);
      final r = ar * 1.6 + p * 26;
      canvas.drawArc(
          Rect.fromCircle(center: ant, radius: r),
          -math.pi * 0.85,
          math.pi * 0.7,
          false,
          strokeOf(ctx.paintOf(0xFFB4B2, 0.8 * (1 - p)), 2.2));
    }
  });

  // Vizor yazisi (kayan "TEBRIKLER!").
  inCap(canvas, ctx, () {
    final visor = ctx.chubby ? _visorChubbyPath : _visorSlimPath;
    final b = visor.getBounds();
    final glow =
        0.25 + 0.15 * (ctx.reduceMotion ? 0 : math.sin(ctx.t * math.pi * 8));
    canvas.drawPath(visor, ctx.paintOf(0x5DCAA5, glow));
    final tp = TextPainter(
      text: TextSpan(
        text: ctx.reduceMotion ? 'TEBRİKLER!' : 'TEBRİKLER! HEDEFE ULAŞTIN!',
        style: TextStyle(
          color: const Color(0xFFB8F5E0).withValues(alpha: ctx.alpha),
          fontSize: ctx.chubby ? 24 : 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.clipPath(visor);
    if (ctx.reduceMotion) {
      final k = math.min(1.0, (b.width - 8) / tp.width);
      canvas.translate(b.center.dx, b.center.dy);
      canvas.scale(k);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    } else {
      final x = b.right - ctx.t * (b.width + tp.width) * 1.05;
      tp.paint(canvas, Offset(x, b.center.dy - tp.height / 2));
    }
    canvas.restore();
  });
}

// --- Kamp: kamp atesi, duman, donen pusula ------------------------------------

CapPose _kampPose(CelebrationContext ctx) => CapPose(
      rotation: math.sin(ctx.elapsed * 3.4) * 0.03,
      dy: -1.5 * math.sin(ctx.elapsed * 6.8).abs(),
    );

void _kampFire(Canvas canvas, CelebrationContext ctx) {
  final sz = szOf(ctx);
  final e = ctx.reduceMotion ? 0.3 : ctx.elapsed;
  const base = Offset(212, 470);

  // Sicak isik
  canvas.drawCircle(
      base + const Offset(0, -26),
      58,
      ctx.paintOf(0xFAC775, 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));

  // Duman
  const n = 9;
  for (var i = 0; i < n; i++) {
    final em = emit(ctx, i, n, period: 1.5, start: 0.02, end: 0.84);
    if (!em.live) continue;
    final p = em.p;
    final x = base.dx + math.sin(p * 5 + i * 1.3) * 14 + p * 26;
    final y = base.dy - 54 - p * 215;
    final r = 6 + 17 * p;
    final fade = math.sin(math.pi * math.min(1.0, p * 1.1 + 0.02));
    puff(canvas, ctx, Offset(x, y), r, 0xD3D1C7, 0.62 * fade, 0xB4B2A9);
  }

  void log(double ang, int col, int hi) {
    canvas.save();
    canvas.translate(base.dx, base.dy - 5);
    canvas.rotate(ang);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-34, -6, 68, 12), const Radius.circular(6)),
        ctx.paintOf(col));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-32, -4, 64, 4), const Radius.circular(3)),
        ctx.paintOf(hi, 0.7));
    canvas.drawCircle(const Offset(34, 0), 5.5, ctx.paintOf(0xC49A6C));
    canvas.drawCircle(const Offset(-34, 0), 5.5, ctx.paintOf(0xC49A6C));
    canvas.restore();
  }

  log(0.28, 0x5A3418, 0x8B5A2B);

  void flame(double w, double h, int col, double ph, double dx) {
    final fl =
        1 + 0.14 * math.sin(e * 16 + ph) + 0.06 * math.sin(e * 29 + ph * 2);
    final sw = math.sin(e * 9 + ph) * 3.5;
    final hh = h * fl;
    final b = base + Offset(dx, -9);
    canvas.drawPath(
      Path()
        ..moveTo(b.dx - w, b.dy)
        ..cubicTo(b.dx - w * 1.25, b.dy - hh * 0.35, b.dx - w * 0.2 + sw,
            b.dy - hh * 0.6, b.dx + sw * 1.3, b.dy - hh)
        ..cubicTo(b.dx + w * 0.3 + sw, b.dy - hh * 0.55, b.dx + w * 1.25,
            b.dy - hh * 0.3, b.dx + w, b.dy)
        ..quadraticBezierTo(b.dx, b.dy + w * 0.5, b.dx - w, b.dy)
        ..close(),
      ctx.paintOf(col, 0.96),
    );
  }

  flame(24, 62, 0xE24B4A, 0, 0);
  flame(18, 70, 0xEF9F27, 1.7, -9);
  flame(16, 56, 0xEF9F27, 3.1, 11);
  flame(11, 46, 0xFAC775, 0.8, 0);
  flame(6, 30, 0xFFF1B8, 2.3, 0);
  log(-0.28, 0x6B3E16, 0x9A6B3A);

  // Kivilcimlar
  for (var i = 0; i < 8; i++) {
    final em = emit(ctx, i, 8, period: 0.8, start: 0.03, end: 0.86);
    if (!em.live) continue;
    final p = em.p;
    final pos = base +
        Offset(
            math.sin(p * 8 + i * 2) * 16 + (rr(ctx, i, em, 1) - 0.5) * 30,
            -30 - p * (70 + 60 * rr(ctx, i, em, 2)));
    canvas.drawCircle(pos, (2.4 - p * 1.4).clamp(0.6, 3.0),
        ctx.paintOf(i.isEven ? 0xFAC775 : 0xEF9F27, 1 - p));
  }

  // Donen pusula (kapaktaki pusulanin ustune).
  final cr = ctx.chubby ? 30.0 : 16.0;
  final cpt = ctx.chubby ? const Offset(340, 118) : const Offset(340, 122);
  double ang;
  if (ctx.reduceMotion) {
    ang = 0.55;
  } else {
    final p = ctx.span(0.04, 0.86);
    final decay = 1 - CelebrationContext.easeOut(p);
    ang = decay * tau * 5 + math.sin(p * 38) * 0.22 * decay * decay * decay;
  }
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
        Offset.zero, cr * 0.1, Paint()..color = const Color(0xFF888780));
    canvas.restore();
  });
  final glint =
      ctx.reduceMotion ? 0.8 : math.max(0.0, math.sin(ctx.elapsed * 8));
  sparkle(canvas, ctx.capPt(cpt.dx + cr * 0.7, cpt.dy - cr * 0.7),
      (4 + 6 * glint) * sz, ctx.paintOf(0xFFFFFF, glint));
}
