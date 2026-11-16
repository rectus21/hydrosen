import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../thermos_painter.dart';
import 'celebration_context.dart';
import 'celebrations_g2.dart';
import 'celebrations_g2_kit.dart';

// GRUP 2 SUREKLI DONGULER
//
// Dongu 3,2 sn'dir ve basa saricidir: tum hareket ctx.loop'un TAM sayida
// periyodu (sin/cos(2π·k·loop), (k·loop+ofset) % 1) ile surulur; boylece
// tur sonunda sicrama ya da solma olmaz. Zarf (ctx.alpha) kullanilmaz.

const Map<String, SignatureCelebration> g2LoopMap = {
  'boga': _bogaLoop,
  'kedi': _kediLoop,
  'kopek': _kopekLoop,
  'tavsan': _tavsanLoop,
  'ayi': _ayiLoop,
  'koala': _koalaLoop,
  'panda': _pandaLoop,
  'inek': _inekLoop,
  'koyun': _koyunLoop,
  'kurbaga': _kurbagaLoop,
  'tilki': _tilkiLoop,
  'kurt': _kurtLoop,
};

const Map<String, CapPoseFn> g2LoopPoseMap = {
  'boga': _bogaPose,
  'kedi': _kediPose,
  'kopek': _kopekPose,
  'tavsan': _tavsanPose,
  'ayi': _ayiPose,
  'koala': _koalaPose,
  'panda': _pandaPose,
  'inek': _inekPose,
  'koyun': _koyunPose,
  'kurbaga': _kurbagaPose,
  'tilki': _tilkiPose,
  'kurt': _kurtPose,
};

/// Zarfsiz (dongude solma yok) G2 kiti; zaman dongu evresine baglidir.
class _L extends G2 {
  _L(super.canvas, super.c);

  double get l => c.loop;

  @override
  double get time => c.loop * 3.2;

  @override
  bool get still => false;

  @override
  double get pop => 1;

  @override
  Paint f(int hex, [double op = 1]) => c.solid(hex, op);

  @override
  Paint s(int hex, double w, [double op = 1]) => c.solid(hex, op)
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// sin, turda [k] tam periyot.
  double w(int k, [double off = 0]) => math.sin(g2Tau * (k * l + off));

  /// 0..1 testere, turda [k] kez tekrarlar.
  double cyc(int k, [double off = 0]) {
    final v = (k * l + off) % 1;
    return v < 0 ? v + 1 : v;
  }

  void leafO(Offset p, double r, double ang, int hex, int vein, double op) =>
      leaf(p, r, ang, hex, vein, op);
}

double _ph(CelebrationContext c, int k, [double off = 0]) =>
    math.sin(g2Tau * (k * c.loop + off));

double _sm(double x) => CelebrationContext.easeInOut(x);

double _fadeIO(double p, [double a = 0.12, double b = 0.2]) =>
    math.min((p / a).clamp(0.0, 1.0), ((1 - p) / b).clamp(0.0, 1.0));

/// Yumusak buhar/toz topu.
void _puff(
  Canvas canvas,
  CelebrationContext c,
  Offset p,
  double r,
  double o, [
  int a = 0xFFFFFF,
  int b = 0xE6EDF2,
]) {
  if (o <= 0.01 || r <= 0.3) return;
  canvas.drawCircle(p, r, c.solid(a, o));
  canvas.drawCircle(
    p + Offset(-r * 0.45, r * 0.25),
    r * 0.6,
    c.solid(0xF3F6F8, o * 0.9),
  );
  canvas.drawCircle(p + Offset(r * 0.5, r * 0.2), r * 0.55, c.solid(b, o * 0.8));
}

void _heart(Canvas canvas, CelebrationContext c, Offset p, double r, int hex,
    double o) {
  if (o <= 0.01) return;
  final path = Path()
    ..moveTo(p.dx, p.dy + r)
    ..cubicTo(p.dx - r * 1.5, p.dy - r * 0.1, p.dx - r * 0.7, p.dy - r * 1.2,
        p.dx, p.dy - r * 0.4)
    ..cubicTo(p.dx + r * 0.7, p.dy - r * 1.2, p.dx + r * 1.5, p.dy - r * 0.1,
        p.dx, p.dy + r)
    ..close();
  canvas.drawPath(path, c.solid(hex, o));
}

// --- Boga: burun buhari + hirlama + toz ---------------------------------------

const _bogaNostrilsChubby = [Offset(322, 160), Offset(358, 160)];
const _bogaNostrilsSlim = [Offset(329, 143), Offset(351, 143)];

/// Turda 2 horultu: 0..1..0 (yarim periyot sessiz).
double _bogaBurst(double loop) {
  final q = (2 * loop) % 1;
  return q < 0.6 ? math.sin(q / 0.6 * math.pi) : 0.0;
}

CapPose _bogaPose(CelebrationContext c) {
  final b = _bogaBurst(c.loop);
  final s = _ph(c, 10);
  return CapPose(
    rotation: s * 0.07 * b,
    dx: s * 2.4 * b,
    dy: b * 3 + _ph(c, 2).abs() * 0.0,
  );
}

void _bogaLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final burst = _bogaBurst(c.loop);
  final k = c.chubby ? chubbyCapScale : 1.0;
  final sz = (c.chubby ? 1.0 : 0.85) * (0.8 + k * 0.2);

  // Taban tozu: her horultuda iki yana yayilir.
  final gl = c.glass;
  final ground = gl.bottom - 4;
  for (var side = 0; side < 2; side++) {
    final dir = side == 0 ? -1.0 : 1.0;
    for (var i = 0; i < 4; i++) {
      final p = g.cyc(2, -0.18 - i * 0.012) / 0.55;
      if (p >= 1) continue;
      final e = CelebrationContext.easeOut(p);
      final reach = 14 + 34 * c.rand(i, 21 + side);
      final x = (side == 0 ? gl.left : gl.right) + dir * (6 + reach * e);
      final y = ground - 6 * e - i * 3;
      final r = (10 + 20 * e) * (0.8 + 0.25 * c.rand(i, 25));
      final o = (1 - p) * math.min(p * 10, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        r,
        c.solid(const [0xEBDCC0, 0xD6C09A, 0xFFF3DC][i % 3], o),
      );
      canvas.drawCircle(
        Offset(x + r * 0.35, y - r * 0.25),
        r * 0.55,
        c.solid(0xFFF3DC, o * 0.35),
      );
    }
  }

  // Burun buhari: surekli, horultuda kabarir.
  final nostrils = c.chubby ? _bogaNostrilsChubby : _bogaNostrilsSlim;
  const puffs = 6;
  for (var side = 0; side < 2; side++) {
    final base = c.capPt(nostrils[side].dx, nostrils[side].dy);
    final dir = side == 0 ? -1.0 : 1.0;
    for (var i = 0; i < puffs; i++) {
      final p = g.cyc(3, i / puffs + side * 0.08);
      final e = CelebrationContext.easeOut(p);
      final amp = 0.85 + 0.45 * burst;
      final r = (7 + 22 * e) * sz * amp;
      final pos =
          base +
          Offset(
            dir * (10 + 52 * e * amp) + math.sin(p * 6 + i + side) * 4,
            -2 - 62 * e * amp,
          );
      _puff(canvas, c, pos, r, 0.85 * math.sin(p * math.pi));
    }
  }
}

// --- Kedi: pati sallar + kuyruk + kalpler -----------------------------------------

CapPose _kediPose(CelebrationContext c) => CapPose(
  rotation: _ph(c, 1) * 0.05,
  dy: -_ph(c, 2).abs() * 3,
);

void _kediLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;

  // Yukselen kalpler.
  for (var i = 0; i < 5; i++) {
    final p = g.cyc(1, i / 5);
    final x = c.capCenter.dx + (c.rand(i, 3) - 0.5) * 250 * (0.8 + u * 0.3);
    final y = c.capTop.dy + 10 - p * 120;
    _heart(
      canvas,
      c,
      Offset(x + math.sin(p * 8 + i) * 7, y),
      (6 + 4 * c.rand(i, 4)) * u,
      const [0xED93B1, 0xF08A5D, 0xF4A6B8][i % 3],
      _fadeIO(p, 0.15, 0.4) * 0.9,
    );
  }

  final b = g.at(404, 192, 392, 168);
  final sw = g.w(2);
  final tail = [
    for (var i = 0; i <= 14; i++)
      G2.cubic(
        b,
        b + Offset(34 * u, 12 * u),
        b + Offset((58 + sw * 14) * u, -8 * u),
        b + Offset((54 + sw * 34) * u, -58 * u),
        i / 14,
      ),
  ];
  double half(double f) => (7.5 - 2.5 * f) * u;
  g.taper(tail, half, 0xC9772C, grow: 2.4 * u);
  g.taper(tail, half, 0xEF9F4F);
  g.taper(tail, half, 0xA95F1C, from: 0.55, to: 0.72);
  g.taper(tail, half, 0xFFF4E4, from: 0.84);

  for (final side in const [-1.0, 1.0]) {
    final sh = g.at(side < 0 ? 254 : 426, 176, side < 0 ? 290 : 390, 144);
    // Sirayla sallar: sol/sag yarim periyot farkli.
    final wv = g.w(3, side < 0 ? 0 : 0.5);
    final ang = -1.0 + wv * 0.6;
    final len = 42 * u;
    final d = Offset(side * math.cos(ang), math.sin(ang));
    final hand = sh + d * len;
    g.capsule(sh, hand, 12 * u, 0xEF9F4F, 0xC9772C);
    g.paw(hand, math.atan2(d.dy, d.dx), 0xEF9F4F, 0xC9772C, 0xF4A6B8);
  }
}

// --- Kopek: kuyruk hizla sallar, dil soluk, kemikler ziplar ---------------------

CapPose _kopekPose(CelebrationContext c) => CapPose(
  rotation: _ph(c, 3) * 0.035,
  dy: -_ph(c, 3).abs() * 6,
);

void _kopekLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;

  final pant = 0.5 + 0.5 * g.w(6);
  final m = g.at(340, 192, 340, 158);
  final tw = (g.chubby ? 12.0 : 6.5) * u;
  final tl = g.chubby ? 12 + pant * 18 : 7 + pant * 9;
  final tongue = Path()
    ..moveTo(m.dx - tw, m.dy)
    ..lineTo(m.dx + tw, m.dy)
    ..lineTo(m.dx + tw, m.dy + tl)
    ..quadraticBezierTo(m.dx + tw, m.dy + tl + tw * 1.2, m.dx,
        m.dy + tl + tw * 1.2)
    ..quadraticBezierTo(m.dx - tw, m.dy + tl + tw * 1.2, m.dx - tw, m.dy + tl)
    ..close();
  canvas.drawPath(tongue, g.f(0xE8758F));
  g.line(m + Offset(0, 2 * u), m + Offset(0, tl + tw * 0.7), 1.6 * u, 0xC0455F);

  // Cok hizli kuyruk.
  final b = g.at(402, 190, 392, 170);
  final ang = -0.95 + g.w(12) * 0.6;
  final dir = Offset(math.cos(ang), math.sin(ang));
  final nrm = Offset(-dir.dy, dir.dx);
  final tail = [
    for (var i = 0; i <= 10; i++)
      b + dir * (i / 10 * 54 * u) + nrm * (math.sin(i / 10 * math.pi) * 5 * u),
  ];
  double half(double f) => (8 - 3.5 * f) * u;
  g.taper(tail, half, 0x7A4A22, grow: 2.2 * u);
  g.taper(tail, half, 0xD9A066);
  g.taper(tail, half, 0xF8E8CE, from: 0.78);
  // Hiz cizgileri.
  for (final sgn in const [-1.0, 1.0]) {
    final tip = tail.last;
    final a2 = ang + sgn * 0.5;
    g.line(
      tip + Offset(math.cos(a2), math.sin(a2)) * 6 * u,
      tip + Offset(math.cos(a2), math.sin(a2)) * 16 * u,
      2 * u,
      0xC9A877,
      0.6 + 0.4 * g.w(12).abs(),
    );
  }

  // Soluk "ha ha" damlalari.
  for (var i = 0; i < 3; i++) {
    final p = g.cyc(3, i / 3);
    final side = i.isEven ? 1.0 : -1.0;
    final q = Offset(
      m.dx + side * (22 + p * 22) * u,
      m.dy + (4 - p * 18) * u,
    );
    canvas.drawCircle(q, (3 - p * 1.2) * u, c.solid(0xBFE3F5, _fadeIO(p) * 0.9));
  }

  // Yanlarda zıplayan kemikler.
  for (var i = 0; i < 2; i++) {
    final side = i == 0 ? 1.0 : -1.0;
    final base = g.at(side > 0 ? 452 : 228, 262, side > 0 ? 428 : 252, 232);
    final q = g.cyc(2, i * 0.5);
    final h = math.sin(q * math.pi);
    final p = base + Offset(0, -h * 52 * u);
    g2BoneL(g, p, side * (g2Tau * q), 1);
  }
}

// --- Tavsan: kulaklar sallanir, ziplar, havuc yagar ---------------------------------

double _tavsanHop(double loop) => math.sin(((2 * loop) % 1) * math.pi);

CapPose _tavsanPose(CelebrationContext c) => CapPose(
  dy: -_tavsanHop(c.loop) * 16,
  rotation: _ph(c, 1) * 0.05,
);

void _tavsanLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;

  for (final side in const [-1.0, 1.0]) {
    final hinge = g.at(side < 0 ? 292 : 388, 46, side < 0 ? 308 : 372, 38);
    // Kulak ziplamayi bir tik gec takip eder.
    final flop = 0.15 + 0.55 * math.sin(g2Tau * (2 * g.l - 0.22 + (side < 0 ? 0 : 0.06)));
    final dirA = -math.pi / 2 + side * (0.15 + flop);
    final dir = Offset(math.cos(dirA), math.sin(dirA));
    final len = (g.chubby ? 24 : 17) * u * 1.25;
    final tip = hinge + dir * len;
    g.capsule(hinge, tip, (g.chubby ? 17 : 12) * u, 0xFBF6F8, 0xD9BFCB);
    g.line(hinge, tip, (g.chubby ? 8 : 6) * u, 0xF2A6C0, 0.9);
  }

  // Dusen havuclar.
  const n = 7;
  final top = c.capTop.dy;
  for (var i = 0; i < n; i++) {
    final p = g.cyc(1, i / n);
    final x = c.capCenter.dx + (c.rand(i, 3) - 0.5) * 300 * (0.8 + u * 0.3);
    final y = top - 40 + p * 360;
    canvas.saveLayer(
      null,
      Paint()..color = Color.fromRGBO(0, 0, 0, _fadeIO(p, 0.1, 0.15)),
    );
    g2Carrot(g, Offset(x, y), (c.rand(i, 4) - 0.5) * 1.2 + p * 4 * (c.rand(i, 5) - 0.5), 1);
    canvas.restore();
  }

  // Ziplama toz bulutu (inis).
  final land = ((2 * g.l) % 1);
  if (land < 0.2) {
    final p = land / 0.2;
    final gl = c.glass;
    for (final side in const [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(gl.center.dx + side * (gl.width / 2 + 6 + p * 10), gl.bottom - 8),
        (4 + p * 8) * u,
        c.solid(0xF3EAD8, (1 - p) * 0.8),
      );
    }
  }
}

// --- Ayi: bal damlar, arilar daire cizer ----------------------------------------------

CapPose _ayiPose(CelebrationContext c) =>
    CapPose(rotation: _ph(c, 2) * 0.04, dx: _ph(c, 1) * 2);

void _ayiLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;
  const honey = 0xF2B632, honeyDark = 0xC98A12, honeyLight = 0xFFDE8C;

  final cy = g.chubby ? 64.0 : 96.0;
  final blob = g.at(340, cy, 340, cy);
  final wob = g.w(2) * 0.5;
  g.oval(blob + Offset(0, 1.5 * u), (g.chubby ? 56 : 40) * u, 13 * u, g.f(honeyDark));
  g.oval(blob, (g.chubby ? 54 : 38) * u, (11.5 + wob) * u, g.f(honey));
  g.oval(blob + Offset(-10 * u, -3.5 * u), 16 * u, 3 * u, g.f(honeyLight, 0.9));
  const drips = [
    [-0.62, 0.0],
    [-0.12, 0.5],
    [0.42, 0.25],
    [0.78, 0.75],
  ];
  for (var i = 0; i < drips.length; i++) {
    final x0 = blob.dx + drips[i][0] * (g.chubby ? 52 : 36) * u;
    final cycle = g.cyc(1, drips[i][1]);
    // Uzar (0..0.8), kopunca ince bir uca geri cekilir (basa dikissiz doner).
    final len = (cycle < 0.8
            ? 6 + 32 * _sm(cycle / 0.8)
            : 6 + 32 * (1 - CelebrationContext.easeOut((cycle - 0.8) / 0.2))) *
        u;
    final top = blob.dy + 3 * u;
    g.line(Offset(x0, top), Offset(x0, top + len), 8.5 * u, honeyDark);
    g.line(Offset(x0, top), Offset(x0, top + len), 6.2 * u, honey);
    g.circle(Offset(x0, top + len), 4.8 * u, honey);
    g.circle(Offset(x0 - 1.4 * u, top + len - 1.2 * u), 1.4 * u, 0xFFF3C4, 0.9);
    if (cycle > 0.8) {
      final fp = (cycle - 0.8) / 0.2;
      final y = top + 38 * u + fp * fp * 130 * u;
      g.oval(
        Offset(x0, y),
        3.8 * u,
        5.4 * u,
        g.f(honey, (1 - fp * fp).clamp(0.0, 1.0)),
      );
    }
  }

  // Arilar kafanin etrafinda sekiz cizer.
  final ctr = c.capCenter + Offset(0, -6 * u);
  for (var i = 0; i < 4; i++) {
    Offset pos(double a) =>
        ctr +
        Offset(
          math.sin(a) * ((g.chubby ? 128 : 96) + i * 6),
          math.sin(a * 2 + i) * (g.chubby ? 50 : 40) - 18 * u,
        );
    final a = g2Tau * (2 * g.l) + i * g2Tau / 4;
    for (var k = 1; k <= 3; k++) {
      g.circle(pos(a - k * 0.16), (2.0 - k * 0.3) * u, 0x8B5A2B, 0.4 - k * 0.1);
    }
    g2Bee(g, pos(a), math.cos(a) >= 0 ? 1.0 : -1.0, 1);
  }
}

// --- Koala: sallanir, sarilir, yapraklar suzulur --------------------------------------

CapPose _koalaPose(CelebrationContext c) =>
    CapPose(rotation: _ph(c, 1) * 0.075, dx: _ph(c, 1) * 3.5);

void _koalaLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;

  // Suzulen yapraklar.
  const cols = [0x8FBF9B, 0x6FA085, 0x97C459, 0xA6CDB0];
  for (var i = 0; i < 7; i++) {
    final p = g.cyc(1, i / 7);
    final x0 = c.capCenter.dx + (c.rand(i, 3) - 0.5) * 290 * (0.8 + u * 0.3);
    final x = x0 + math.sin(g2Tau * (2 * p) + i * 1.3) * 22;
    final y = c.capTop.dy - 30 + p * 330;
    final rot = math.sin(g2Tau * (2 * p) + i * 1.3 + 1.2) * 0.9 + i;
    g.leafO(Offset(x, y), (15 + c.rand(i, 5) * 5) * u, rot, cols[i % 4],
        0x4A6B45, _fadeIO(p, 0.1, 0.2));
  }

  // Okaliptus dallari.
  const lc = [0x8FBF9B, 0x6FA085, 0xA6CDB0];
  for (var s = 0; s < 2; s++) {
    final sgn = s == 0 ? 1.0 : -1.0;
    final base = g.at(s == 0 ? 404 : 276, 70, s == 0 ? 392 : 288, 90);
    final sw = g.w(1, s * 0.37) * 0.25;
    final stem = [
      for (var i = 0; i <= 8; i++)
        base +
            Offset(
              sgn * (i * 6.5 * u) + math.sin(sw + i * 0.2) * i * 1.2 * u,
              -i * 8.5 * u,
            ),
    ];
    for (var i = 0; i < stem.length - 1; i++) {
      g.line(stem[i], stem[i + 1], 2.2 * u, 0x5F7F55);
    }
    for (var i = 2; i < stem.length; i++) {
      final side = i.isEven ? -1.0 : 1.0;
      final p = stem[i] + Offset(side * 7 * u, 2 * u);
      g.oval(p, 8.5 * u, 5.4 * u, g.f(lc[i % 3]), side * 0.6 + sw);
      g.oval(p - Offset(side * 1.5 * u, 1.2 * u), 4 * u, 1.6 * u,
          g.f(0xE6F2E6, 0.6), side * 0.6 + sw);
    }
  }

  // Sarilma: kollar nabiz gibi sikar.
  final squeeze = 0.5 + 0.5 * g.w(2, -0.25);
  for (final side in const [-1.0, 1.0]) {
    final sh = g.at(side < 0 ? 248 : 432, 178, side < 0 ? 287 : 393, 144);
    final hand = g.at(
      340 + side * (30 - squeeze * 14),
      216,
      340 + side * (16 - squeeze * 6),
      182,
    );
    final elbow = Offset(
      (sh.dx + hand.dx) / 2 + side * 6 * u,
      math.max(sh.dy, hand.dy) + 10 * u,
    );
    final arm = [
      for (var i = 0; i <= 10; i++)
        Offset.lerp(
          Offset.lerp(sh, elbow, i / 10),
          Offset.lerp(elbow, hand, i / 10),
          i / 10,
        )!,
    ];
    g.taper(arm, (f) => (8.5 - 1.2 * f) * u, 0x818A97, grow: 2.2 * u);
    g.taper(arm, (f) => (8.5 - 1.2 * f) * u, 0xAEB6C0);
    g.circle(hand, 8 * u, 0x818A97);
    g.circle(hand, 6.2 * u, 0xAEB6C0);
    for (var k = -1; k <= 1; k++) {
      g.circle(hand + Offset(k * 3 * u - side * 2 * u, 5 * u), 1.6 * u, 0x3C3F46);
    }
  }
}

// --- Panda: bambu cirpar, kirintilar ucar -----------------------------------------------

CapPose _pandaPose(CelebrationContext c) => CapPose(
  dy: _ph(c, 3).abs() * 4.5,
  rotation: _ph(c, 3) * 0.035,
);

void _pandaLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;

  final chew = g.w(6);
  final mouth = g.at(340, 176, 340, 152);
  final tip = mouth + Offset(-3 * u, 3 * u + chew * 1.8 * u);
  final end = mouth + Offset(88 * u, 66 * u);
  const stalk = 0x7CC15A, node = 0x4F8F3A, lite = 0xB4E08C;
  g.line(tip, end, 13 * u, node);
  g.line(tip, end, 10.4 * u, stalk);
  g.line(tip + Offset(0, -2.5 * u), end + Offset(0, -2.5 * u), 2.4 * u, lite);
  final d = (end - tip) / (end - tip).distance;
  final nrm = Offset(-d.dy, d.dx);
  for (final fr in const [0.3, 0.62, 0.9]) {
    final p = tip + (end - tip) * fr;
    g.line(p - nrm * 6.2 * u, p + nrm * 6.2 * u, 2.3 * u, node);
  }
  g.circle(tip, 5.4 * u, 0xD9EDB8);
  for (var i = 0; i < 3; i++) {
    final a = -0.9 + i * 0.75 + g.w(2, i / 3) * 0.16;
    g.leaf(end + Offset.fromDirection(a, 15 * u), 13 * u, a,
        i == 1 ? 0x639922 : 0x97C459, 0x3D6B1A);
  }
  for (final fr in const [0.45, 0.78]) {
    final p = tip + (end - tip) * fr + Offset(0, g.w(6, fr) * 1.4 * u);
    g.oval(p, 9.4 * u, 7.4 * u, g.f(0x2C2C2A), 0.55);
    g.oval(p + Offset(-2.2 * u, -2.5 * u), 3 * u, 1.8 * u,
        g.f(0xFFFFFF, 0.25), 0.55);
  }

  // Cirpilan kirintilar ve yaprak parcalari: her ısırıkta saçılır.
  for (var i = 0; i < 12; i++) {
    final cy = g.cyc(3, i / 12);
    final dirX = i.isEven ? -1.0 : 0.6;
    final p = tip +
        Offset(
          -6 * u + dirX * cy * (14 + c.rand(i, 2) * 30) * u,
          cy * -10 * u + cy * cy * 60 * u,
        );
    final o = _fadeIO(cy, 0.05, 0.4);
    if (i % 3 == 0) {
      g.leafO(p, 8 * u, cy * 6 + i, 0x97C459, 0x3D6B1A, o);
    } else {
      g.circle(p, (4.6 - cy * 2.0) * u, i.isEven ? 0xB4E08C : 0x7CC15A, o);
    }
  }
}

// --- Inek: can sallanir, "Moo!" baloncugu periyodik acilir -------------------------------

double _inekQ(double loop) => (2 * loop) % 1;

CapPose _inekPose(CelebrationContext c) {
  final q = _inekQ(c.loop);
  final m = q < 0.3 ? CelebrationContext.pulse(q / 0.3) : 0.0;
  return CapPose(dy: m * 4, rotation: _ph(c, 2) * 0.025 - m * 0.04);
}

void _inekLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;

  final pivot = g.at(340, 208, 340, 176);
  final swing = g.w(3) * 0.55;
  g.line(pivot + Offset(-17 * u, 0), pivot + Offset(17 * u, 0), 6 * u, 0xC0392B);
  g.local(pivot + Offset(0, 4 * u), swing, u, () {
    final bell = Path()
      ..moveTo(-12, 20)
      ..quadraticBezierTo(-13, 2, 0, 1)
      ..quadraticBezierTo(13, 2, 12, 20)
      ..close();
    canvas.drawPath(bell, g.f(0xB07A22));
    final inner = Path()
      ..moveTo(-10, 18.5)
      ..quadraticBezierTo(-11, 4, 0, 3)
      ..quadraticBezierTo(11, 4, 10, 18.5)
      ..close();
    canvas.drawPath(inner, g.f(0xFAC775));
    canvas.drawOval(Rect.fromLTWH(-6.5, 5, 4, 8), g.f(0xFFF0C4, 0.8));
    canvas.drawLine(const Offset(-12, 19.5), const Offset(12, 19.5), g.s(0xB07A22, 3));
    canvas.drawCircle(Offset(-swing * 8, 23), 3.4, g.f(0x8A5A12));
  });
  // Can sesi cizgileri: salinimin uclarinda.
  final sw = g.w(3);
  if (sw.abs() > 0.7) {
    final sgn = sw > 0 ? 1.0 : -1.0;
    final o = ((sw.abs() - 0.7) / 0.3).clamp(0.0, 1.0);
    for (var i = 0; i < 2; i++) {
      canvas.drawArc(
        Rect.fromCircle(
          center: pivot + Offset(0, 16 * u),
          radius: (22 + i * 7) * u,
        ),
        sgn > 0 ? -0.5 : math.pi - 0.9,
        0.4,
        false,
        g.s(0xFAC775, 2.2 * u, o),
      );
    }
  }

  // "Moo!" baloncugu: turda iki kez acilir, patlar.
  final q = _inekQ(c.loop);
  final inP = CelebrationContext.easeOut((q / 0.18).clamp(0.0, 1.0));
  final outP = ((q - 0.72) / 0.12).clamp(0.0, 1.0);
  final pop = inP * (1 + 0.14 * math.sin(((q / 0.18).clamp(0.0, 1.0)) * math.pi)) *
      (1 - outP);
  final top = c.capTop;
  final ctr =
      Offset(top.dx + (g.chubby ? 98 : 88), top.dy - (g.chubby ? 34 : 38)) +
      Offset(0, g.w(2) * 2);
  if (pop > 0.02) {
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 116, height: 56),
      const Radius.circular(28),
    );
    g.local(ctr, g.w(2) * 0.04, pop, () {
      canvas.drawRRect(r.inflate(3), g.f(0x2C3A44));
      canvas.drawPath(
        Path()
          ..moveTo(-34, 18)
          ..lineTo(-52, 46)
          ..lineTo(-14, 24)
          ..close(),
        g.f(0x2C3A44),
      );
      canvas.drawRRect(r, g.f(0xFFFFFF));
      canvas.drawPath(
        Path()
          ..moveTo(-33, 15)
          ..lineTo(-47, 40)
          ..lineTo(-16, 21)
          ..close(),
        g.f(0xFFFFFF),
      );
      final tp = TextPainter(
        text: const TextSpan(
          text: 'Möö!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C3A44),
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      tp.dispose();
    });
  }
  // Patlama kıvılcımları.
  if (outP > 0 && outP < 1) {
    for (var i = 0; i < 8; i++) {
      final a = i / 8 * g2Tau;
      final r0 = 30 + 40 * outP;
      g.line(
        ctr + Offset(math.cos(a) * r0, math.sin(a) * r0 * 0.6),
        ctr + Offset(math.cos(a) * (r0 + 10), math.sin(a) * (r0 + 10) * 0.6),
        2.6 * u,
        0xFAC775,
        1 - outP,
      );
    }
  }
}

// --- Koyun: yun pufleri ziplar ---------------------------------------------------------------

CapPose _koyunPose(CelebrationContext c) => CapPose(
  dy: -math.sin(((2 * c.loop) % 1) * math.pi) * 8,
  rotation: _ph(c, 1) * 0.03,
);

void _koyunLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;

  const n = 11;
  final rx = g.chubby ? 92.0 : 62.0, ry = g.chubby ? 62.0 : 38.0;
  final cy = g.chubby ? 118.0 : 122.0;
  for (var i = 0; i < n; i++) {
    final ang = math.pi * (1.02 + 0.96 * i / (n - 1));
    final base = c.capPt(340 + math.cos(ang) * rx, cy + math.sin(ang) * ry);
    final cyc = g.cyc(i.isEven ? 2 : 3, c.rand(i, 7));
    final h = math.sin(cyc * math.pi);
    final out = Offset(math.cos(ang), math.sin(ang));
    final lift = h * (36 + c.rand(i, 8) * 34) * u;
    final p = base + out * (h * 12 * u) + Offset(0, -lift);
    final r = (11 + c.rand(i, 9) * 5) * u * (1 + 0.12 * (1 - h));
    g.oval(base + Offset(0, 4 * u), r * (1 - h * 0.3), r * 0.28,
        g.f(0x3A5A32, 0.12 * (1 - h)));
    g.circle(p + Offset(0, 1.6 * u), r + 1.8 * u, 0xD9C9A8);
    g.circle(p, r, 0xFFFFFF);
    g.circle(p + Offset(-r * 0.3, -r * 0.3), r * 0.4, 0xFFFFFF);
    g.circle(p + Offset(r * 0.25, r * 0.35), r * 0.55, 0xF3EAD8, 0.7);
  }
  for (var i = 0; i < 6; i++) {
    final cyc = g.cyc(1, i / 6);
    final x = c.capCenter.dx + (c.rand(i, 11) - 0.5) * 230 + math.sin(cyc * 6 + i) * 8;
    final y = c.capTop.dy - 6 - cyc * 90;
    g.circle(Offset(x, y), (5 + c.rand(i, 12) * 4) * u * 1.2, 0xFFFFFF,
        0.9 * math.sin(cyc * math.pi));
  }
}

// --- Kurbaga: sinek daire cizer, dil yakalar -----------------------------------------------------

const _flickA = 0.30, _flickB = 0.50, _flyBack = 0.64;

Offset _flyAt(_L g, double l) {
  final c = g.c;
  final ctr = c.capCenter + Offset(0, -(g.chubby ? 30.0 : 30.0));
  final a = g2Tau * l;
  return ctr +
      Offset(
        math.cos(a) * (g.chubby ? 124.0 : 100.0) + math.sin(g2Tau * 7 * l) * 7,
        math.sin(a) * (g.chubby ? 48.0 : 42.0) - 6 + math.sin(g2Tau * 9 * l) * 6,
      );
}

CapPose _kurbagaPose(CelebrationContext c) {
  final gulp = c.loop > _flickB - 0.05 && c.loop < _flickB + 0.07
      ? CelebrationContext.pulse((c.loop - (_flickB - 0.05)) / 0.12)
      : 0.0;
  return CapPose(dy: -gulp * 7, rotation: _ph(c, 1) * 0.015, scale: 1 + gulp * 0.03);
}

void _kurbagaLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;
  final l = g.l;
  final mouth = g.at(340, 190, 340, 148);

  // Bekleyen yildizcik: yakalama bittikten sonra sinek yeniden belirir.
  final hidden = l >= _flickB && l < _flyBack;
  final appear = l >= _flyBack
      ? CelebrationContext.easeOut(((l - _flyBack) / 0.08).clamp(0.0, 1.0))
      : 1.0;
  final fp = _flyAt(g, l);
  if (!hidden && (l < _flickA + (_flickB - _flickA) * 0.4 || l >= _flyBack)) {
    // Uzayan dilin ucunda degilken ucar.
    g2DrawFly(g, fp, appear);
  }

  if (l >= _flickA && l < _flickB) {
    final s = (l - _flickA) / (_flickB - _flickA);
    final ext = s < 0.4
        ? CelebrationContext.easeOut(s / 0.4)
        : 1 - CelebrationContext.easeInOut((s - 0.4) / 0.6);
    final caught = s >= 0.4;
    final target = _flyAt(g, _flickA + (_flickB - _flickA) * 0.4);
    final tip = Offset.lerp(mouth, caught ? target : fp, ext)!;
    g2DrawTongue(g, mouth, tip, fly: caught ? tip : null, extent: ext);
    if (caught) {
      g2DrawFly(g, tip, 1);
      final k = (s - 0.4) / 0.6;
      if (k < 0.6) {
        final f = k / 0.6;
        g.sparkle(target, (6 + f * 8) * u, 0xFFF3C4, 1 - f);
        g.sparkle(target + Offset(12 * u, -8 * u), 4 * u * (1 - f), 0xFFFFFF, 1 - f);
      }
    }
  }
}

// --- Tilki: kuyruk savrulur, yaprak girdabi ----------------------------------------------------------

CapPose _tilkiPose(CelebrationContext c) => CapPose(
  rotation: _ph(c, 3, 0.1) * 0.06,
  dy: -_ph(c, 3).abs() * 2,
);

void _tilkiLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;
  const leafCols = [0xE8782A, 0xC9381F, 0xF2A03D, 0xB5551A];
  final ctr = c.capCenter + Offset(0, g.chubby ? 6 : 0);
  final rx = g.chubby ? 150.0 : 122.0, ry = g.chubby ? 52.0 : 44.0;

  void whirl(bool front) {
    for (var i = 0; i < 11; i++) {
      final a = g2Tau * g.l + i * g2Tau / 11;
      final depth = math.sin(a);
      if ((depth >= 0) != front) continue;
      final lift = math.sin(a * 2 + i) * 10 * u + math.sin(g2Tau * 3 * g.l + i) * 3;
      final p = ctr + Offset(math.cos(a) * rx, depth * ry - 8 * u + lift);
      final r = (16 + c.rand(i, 31) * 6) * u * (front ? 1.2 : 0.9);
      g.leaf(p, r, a * 2 + i, leafCols[i % 4], 0x5A2C0A, front ? 1 : 0.7);
    }
  }

  whirl(false);

  final b = g.at(402, 194, 392, 170);
  final sw = g.w(3);
  final spine = [
    for (var i = 0; i <= 16; i++)
      G2.cubic(
        b,
        b + Offset(30 * u, 18 * u),
        b + Offset((54 + sw * 12) * u, -6 * u),
        b + Offset((48 + sw * 40) * u, -66 * u),
        i / 16,
      ),
  ];
  double half(double f) =>
      (7 + 14 * math.sin(math.pow(f, 0.7) * math.pi * 0.9 + 0.1)) *
      u *
      (f > 0.93 ? (1 - f) / 0.07 * 0.6 + 0.4 : 1);
  g.taper(spine, half, 0xB5551A, grow: 2.4 * u);
  g.taper(spine, half, 0xE8782A);
  g.taper(spine, (f) => half(f) * 0.6, 0xF4A25E, to: 0.6, op: 0.6);
  g.taper(spine, half, 0xFFF6EA, from: 0.72);

  whirl(true);
}

// --- Kurt: uluma, ses dalgalari tekrar tekrar ---------------------------------------------------------

double _howl(double l) =>
    CelebrationContext.easeInOut(((l - 0.04) / 0.2).clamp(0.0, 1.0)) *
    (1 - CelebrationContext.easeInOut(((l - 0.8) / 0.16).clamp(0.0, 1.0)));

CapPose _kurtPose(CelebrationContext c) {
  final up = _howl(c.loop);
  return CapPose(
    rotation: -0.17 * up + _ph(c, 9) * 0.008 * up,
    dy: -4 * up,
    scale: 1 + 0.03 * up,
  );
}

void _kurtLoop(Canvas canvas, CelebrationContext c) {
  final g = _L(canvas, c);
  final u = g.u;
  final open = _howl(g.l);

  // Ay: parlar, yildizlar yanip soner.
  const moon = Offset(190, 96);
  final glow = 1 + 0.07 * g.w(3);
  for (var i = 3; i >= 1; i--) {
    canvas.drawCircle(
      moon,
      36.0 * (1 + i * 0.3) * glow,
      c.solid(0xFFF3C4, 0.09 * (4 - i) * (0.6 + 0.4 * open)),
    );
  }
  canvas.drawCircle(moon, 36, c.solid(0xFFF1B8, 0.9));
  canvas.drawCircle(moon + const Offset(-4, -3), 31, c.solid(0xFFF8D8, 0.7));
  canvas.drawCircle(moon + const Offset(-10, -8), 7, c.solid(0xE9D68E, 0.7));
  canvas.drawCircle(moon + const Offset(12, 12), 5, c.solid(0xE9D68E, 0.7));
  for (var i = 0; i < 6; i++) {
    final tw = 0.5 + 0.5 * g.w(2 + i % 2, i * 0.17);
    g.sparkle(
      moon + Offset.fromDirection(i * 1.1 + 0.5, 62 + (i % 2) * 10),
      (3 + tw * 3.5) * 1.4,
      0xFFFFFF,
      0.4 + tw * 0.6,
    );
  }

  final mouth = g.at(340, 190, 340, 152);
  if (open > 0.02) {
    final ry = (g.chubby ? 5 + 13 * open : 4 + 9 * open) * u + g.w(9) * 0.6 * open;
    final rx = (g.chubby ? 13 : 10) * u * (0.7 + 0.3 * open);
    g.oval(mouth + Offset(0, ry * 0.3), rx + 1.6 * u, ry + 1.6 * u, g.f(0x3E3C58));
    g.oval(mouth + Offset(0, ry * 0.3), rx, ry, g.f(0x3A1A28));
    g.oval(mouth + Offset(0, ry * 0.75), rx * 0.62, ry * 0.5, g.f(0xE8758F));
  }

  // Ses dalgalari: ay yonune dogru genisleyen yaylar.
  final to = moon - mouth;
  final base = math.atan2(to.dy, to.dx);
  final dist = to.distance;
  for (var i = 0; i < 5; i++) {
    final cy = g.cyc(3, i / 5);
    final r = 18 + cy * (dist - 12);
    final fade = math.sin(cy * math.pi).clamp(0.0, 1.0) * open;
    if (fade <= 0.02) continue;
    canvas.drawArc(
      Rect.fromCircle(center: mouth, radius: r),
      base - 0.42,
      0.84,
      false,
      g.s(0xDCE6FF, (3.6 - cy * 1.4) * u * 1.2, 0.9 * fade),
    );
  }
}

/// Kemik (g2 iç yardımcısı kopyası): [G2] ile yerel döndürülmüş kemik.
void g2BoneL(G2 g, Offset p, double rot, double sc) {
  g.local(p, rot, g.u * sc, () {
    const w = 0xFFF8E8, dark = 0xC9B18A;
    for (var pass = 0; pass < 2; pass++) {
      final col = pass == 0 ? dark : w;
      final grow = pass == 0 ? 2.2 : 0.0;
      g.canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 28 + grow * 2,
            height: 10 + grow * 2,
          ),
          const Radius.circular(5),
        ),
        g.f(col),
      );
      for (final sx in const [-1.0, 1.0]) {
        for (final sy in const [-1.0, 1.0]) {
          g.canvas.drawCircle(Offset(sx * 16, sy * 5.5), 6.4 + grow, g.f(col));
        }
      }
    }
  });
}
