import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../celebration_style.dart';
import '../thermos_painter.dart';
import 'celebration_context.dart';
import 'celebrations_g2_kit.dart';

// TEMA IMZA KUTLAMASI NASIL EKLENIR (grup 2)
//
// 1. Asagidaki g2Celebrations haritasina tema id'siyle bir giris ekle:
//      'boga': _bogaSteam,
//    ve `void _bogaSteam(Canvas canvas, CelebrationContext ctx)` yaz.
// 2. Konumlar icin ctx capalarini kullan: ctx.capCenter, ctx.capTop,
//    ctx.capWidth, ctx.eyeLeft/eyeRight/eyeLine, ctx.nose, ctx.mouth,
//    ctx.glass, ctx.waterY. Temaya ozgu bir nokta gerekiyorsa ctx.capPt(hamX,
//    hamY) ile kapak cizimindeki (themes/pack_*.dart) ham koordinati ver;
//    tombul kucultme ve kapak pozu otomatik uygulanir.
// 3. Sure ~2,6 sn: ctx.t (0..1) ve ctx.elapsed (sn) ile ilerle. Yardimcilar:
//    CelebrationContext.easeOut/easeInOut/pulse/lerp, ctx.span(a, b),
//    ctx.rand(i, salt), ctx.paintOf(hex, op) (ctx.alpha zarfi uygulanir),
//    ctx.solid, ctx.star, ctx.kind(canvas, CelebrationKind.x, renkler).
// 4. Hem tombul hem ince termosta iyi gorunmeli (ctx.chubby); kart disina
//    tasan cizim kirpilir. Kutlama kapagin USTUNDE cizilir.
// 5. ctx.reduceMotion true ise hareket yok: tek, duragan, temsili bir kare
//    ciz (t sabit 0.5 gelir; zamana bagli titresim/kayma kullanma).
// 6. Istersen kapaga ziplama/sallanma ekle: g2CapPoses haritasina ayni id ile
//    `CapPose Function(CelebrationContext)` ver (reduceMotion'da cagrilmaz).
// 7. test/celebrations_test.dart haritalari otomatik dolasir (iki sekil,
//    t=0..1, reduceMotion); ayrica test gerekmez.


const Map<String, SignatureCelebration> g2Celebrations = {
  'kedi': _kedi,
  'kopek': _kopek,
  'tavsan': _tavsan,
  'ayi': _ayi,
  'koala': _koala,
  'panda': _panda,
  'inek': _inek,
  'koyun': _koyun,
  'boga': _bogaSteam,
  'kurbaga': _kurbaga,
  'tilki': _tilki,
  'kurt': _kurt,
};

const Map<String, CapPoseFn> g2CapPoses = {
  'kedi': _kediPose,
  'kopek': _kopekPose,
  'tavsan': _tavsanPose,
  'ayi': _ayiPose,
  'koala': _koalaPose,
  'panda': _pandaPose,
  'inek': _inekPose,
  'koyun': _koyunPose,
  'boga': _bogaShake,
  'kurbaga': _kurbagaPose,
  'tilki': _tilkiPose,
  'kurt': _kurtPose,
};

// --- Ortak kapak hareketi ---------------------------------------------------

/// Kutlamanin basinda ve sonunda hareketi yumusakca acip kapatan zarf.
double _env(CelebrationContext c) => c.span(0, 0.1) * (1 - c.span(0.9, 1));

double _sin(CelebrationContext c, double hz, [double ph = 0]) =>
    math.sin(c.elapsed * g2Tau * hz + ph);

// --- Kedi: iki pati sallar + kuyruk ------------------------------------------

CapPose _kediPose(CelebrationContext c) {
  final e = _env(c);
  return CapPose(
    rotation: _sin(c, 1.2) * 0.05 * e,
    dy: -_sin(c, 2.4).abs() * 2.5 * e,
  );
}

void _kedi(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.hearts, const [0xF08A5D, 0xED93B1, 0xFAC775]);

  // Kuyruk: sag alttan yukari kivrilir, ucu savrulur.
  final b = g.at(404, 192, 392, 168);
  final sw = g.wave(1.7);
  final tail = [
    for (var i = 0; i <= 14; i++)
      G2.cubic(
        b,
        b + Offset(34 * u, 12 * u),
        b + Offset((58 + sw * 10) * u, -8 * u),
        b + Offset((54 + sw * 30) * u, -58 * u),
        i / 14,
      ),
  ];
  g.taper(tail, (f) => (7.5 - 2.5 * f) * u, 0xC9772C, grow: 2.4 * u);
  g.taper(tail, (f) => (7.5 - 2.5 * f) * u, 0xEF9F4F);
  g.taper(tail, (f) => (7.5 - 2.5 * f) * u, 0xA95F1C, from: 0.55, to: 0.72);
  g.taper(tail, (f) => (7.5 - 2.5 * f) * u, 0xFFF4E4, from: 0.84);

  // Iki pati: yanlarda yukari kalkip sallanir.
  for (final side in const [-1.0, 1.0]) {
    final sh = g.at(side < 0 ? 254 : 426, 176, side < 0 ? 290 : 390, 144);
    final w = g.wave(2.4, side < 0 ? 0 : 1.6);
    final ang = -1.0 + w * 0.5;
    final len = 40 * u * g.pop;
    final d = Offset(side * math.cos(ang), math.sin(ang));
    final hand = sh + d * len;
    g.capsule(sh, hand, 12 * u, 0xEF9F4F, 0xC9772C);
    g.paw(hand, math.atan2(d.dy, d.dx), 0xEF9F4F, 0xC9772C, 0xF4A6B8);
  }
}

// --- Kopek: kuyruk sallar, dil cikarir, kemik ziplar ---------------------------

CapPose _kopekPose(CelebrationContext c) {
  final e = _env(c);
  return CapPose(
    rotation: _sin(c, 1.2) * 0.035 * e,
    dy: -_sin(c, 1.2).abs() * 6 * e,
  );
}

void _bone(G2 g, Offset p, double rot, double sc) {
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
          g.canvas.drawCircle(
            Offset(sx * 16, sy * 5.5),
            6.4 + grow,
            g.f(col),
          );
        }
      }
    }
  });
}

void _kopek(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.confetti, const [
    0xF2B84B,
    0xE2574C,
    0x4BA3E3,
    0x6DBE5B,
  ]);

  // Dil: soluk alirken inip cikar.
  final pant = 0.5 + 0.5 * g.wave(3.2);
  final m = g.at(340, 192, 340, 158);
  final tw = (g.chubby ? 12.0 : 6.5) * u;
  final tl = (g.chubby ? 12 + pant * 16 : 7 + pant * 8) * g.pop;
  final tongue = Path()
    ..moveTo(m.dx - tw, m.dy)
    ..lineTo(m.dx + tw, m.dy)
    ..lineTo(m.dx + tw, m.dy + tl)
    ..quadraticBezierTo(m.dx + tw, m.dy + tl + tw * 1.2, m.dx, m.dy + tl + tw * 1.2)
    ..quadraticBezierTo(m.dx - tw, m.dy + tl + tw * 1.2, m.dx - tw, m.dy + tl)
    ..close();
  canvas.drawPath(tongue, g.f(0xE8758F));
  g.line(
    m + Offset(0, 2 * u),
    m + Offset(0, tl + tw * 0.7),
    1.6 * u,
    0xC0455F,
  );

  // Kuyruk (sag yanda), cok hizli sallanir.
  final b = g.at(402, 190, 392, 170);
  final ang = -0.95 + g.wave(4.5) * 0.55;
  final dir = Offset(math.cos(ang), math.sin(ang));
  final nrm = Offset(-dir.dy, dir.dx);
  final tail = [
    for (var i = 0; i <= 10; i++)
      b + dir * (i / 10 * 52 * u) + nrm * (math.sin(i / 10 * math.pi) * 5 * u),
  ];
  g.taper(tail, (f) => (8 - 3.5 * f) * u, 0x7A4A22, grow: 2.2 * u);
  g.taper(tail, (f) => (8 - 3.5 * f) * u, 0xD9A066);
  g.taper(tail, (f) => (8 - 3.5 * f) * u, 0xF8E8CE, from: 0.78);

  // Iki kemik: yanlarda zipliyor ve donuyor.
  for (var i = 0; i < 2; i++) {
    final side = i == 0 ? 1.0 : -1.0;
    final base = g.at(side > 0 ? 452 : 228, 262, side > 0 ? 428 : 252, 232);
    final ph = i * 1.1;
    final h = g.still ? 0.7 : _hop(g.time * 1.15 + ph);
    final p = base + Offset(0, -h * 46 * u * g.pop);
    final shadow = Offset(base.dx, base.dy + 8 * u);
    g.oval(shadow, (13 - h * 5) * u, 3.2 * u, g.f(0x2C2C2A, 0.18));
    _bone(g, p, side * (h * 0.9 - 0.3) + g.wave(1.15, ph) * 0.2, 1);
  }
  g.sparkle(g.at(452, 214, 428, 190), 6 * u, 0xFFF4C0, 0.9);
}

/// 0..1 ziplama egrisi (|sin|).
double _hop(double x) => math.sin(x * math.pi).abs();

// --- Tavsan: kulaklar sallanir, hoplar, havuc duser ------------------------------

CapPose _tavsanPose(CelebrationContext c) {
  final e = _env(c);
  final h = _hop(c.elapsed * 1.7);
  return CapPose(
    dy: -h * 16 * e,
    rotation: _sin(c, 0.85) * 0.06 * e,
    scale: 1 + (h < 0.12 ? (0.12 - h) * 0.25 : 0) * e,
  );
}

void _carrot(G2 g, Offset p, double rot, double sc) {
  g.local(p, rot, g.u * sc * 1.15, () {
    final body = Path()
      ..moveTo(-6, -10)
      ..quadraticBezierTo(0, -13, 6, -10)
      ..quadraticBezierTo(6, 4, 0, 18)
      ..quadraticBezierTo(-6, 4, -6, -10)
      ..close();
    g.canvas.drawPath(body, g.f(0xF0883A));
    g.canvas.drawPath(
      Path()
        ..moveTo(3, -9)
        ..quadraticBezierTo(5, 2, 1, 12)
        ..lineTo(0, 12)
        ..quadraticBezierTo(3, 2, 1, -9)
        ..close(),
      g.f(0xF8A85E),
    );
    for (final y in const [-4.0, 3.0, 9.0]) {
      g.canvas.drawLine(
        Offset(-3.6 + y * 0.12, y),
        Offset(0.5, y + 0.4),
        g.s(0xC8641F, 1.1),
      );
    }
    for (final a in const [-0.5, 0.0, 0.5]) {
      final tip = Offset(math.sin(a) * 9, -10 - math.cos(a) * 9);
      g.canvas.drawLine(const Offset(0, -10), tip, g.s(0x4C9A3A, 3.2));
    }
  });
}

void _tavsan(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.fallingFlowers, const [0xF4A6C0, 0xFFFFFF, 0xFAC775]);

  // Kulaklar: ucu one arkaya yatar (kapak gorselinin ustune kivrik uc).
  for (final side in const [-1.0, 1.0]) {
    final hinge = g.at(side < 0 ? 292 : 388, 46, side < 0 ? 308 : 372, 38);
    final flop = g.wave(1.9, side < 0 ? 0 : 1.2) * 0.5 + 0.1;
    final dirA = -math.pi / 2 + side * (0.15 + flop);
    final dir = Offset(math.cos(dirA), math.sin(dirA));
    final len = (g.chubby ? 24 : 17) * u * 1.25;
    final tip = hinge + dir * len;
    g.capsule(hinge, tip, (g.chubby ? 17 : 12) * u, 0xFBF6F8, 0xD9BFCB);
    g.line(hinge, tip, (g.chubby ? 8 : 6) * u, 0xF2A6C0, 0.9);
  }

  // Dusen havuclar.
  const n = 9;
  final top = c.capTop.dy;
  for (var i = 0; i < n; i++) {
    final delay = i / n * 0.58;
    final p = g.still ? (i + 1) / (n + 1) * 0.85 : ((g.t - delay) / 0.38).clamp(0.0, 1.0);
    if (p <= 0 || p >= 1) continue;
    final x = c.capCenter.dx + (c.rand(i, 3) - 0.5) * 300 * (0.8 + u * 0.3);
    final y = top - 40 + p * p * 360;
    final fade = p > 0.85 ? (1 - p) / 0.15 : 1.0;
    canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, fade));
    _carrot(g, Offset(x, y), (c.rand(i, 4) - 0.5) * 1.2 + p * 5 * (c.rand(i, 5) - 0.5), 1);
    canvas.restore();
  }
}

// --- Ayi: bal damlar, arilar ucar ---------------------------------------------------

CapPose _ayiPose(CelebrationContext c) {
  final e = _env(c);
  return CapPose(rotation: _sin(c, 1.6) * 0.04 * e, dx: _sin(c, 0.8) * 2 * e);
}

void _bee(G2 g, Offset p, double dir, double sc) {
  final u = g.u * sc * 1.25;
  final flap = 0.45 + 0.55 * math.sin(g.time * 70 + p.dx).abs();
  g.oval(p + Offset(-2 * u * dir, -6 * u), 5 * u, 7.5 * u * flap, g.f(0xFFFFFF, 0.8), -0.5 * dir);
  g.oval(p + Offset(2 * u * dir, -6.5 * u), 4 * u, 6.5 * u * flap, g.f(0xE8F4FF, 0.75), 0.5 * dir);
  g.oval(p, 9 * u, 6.2 * u, g.f(0x2C2C2A));
  g.oval(p, 8.2 * u, 5.4 * u, g.f(0xFFD23F));
  for (final x in const [-3.2, 1.0]) {
    g.oval(p + Offset(x * u * dir, 0), 1.7 * u, 5.0 * u, g.f(0x2C2C2A));
  }
  g.circle(p + Offset(6.4 * u * dir, -0.8 * u), 1.7 * u, 0x2C2C2A);
  g.circle(p + Offset(-9 * u * dir, 0.5 * u), 1.2 * u, 0x2C2C2A);
}

void _ayi(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.confetti, const [0xF2B632, 0xE39A14, 0xFFDE8C, 0x8B5A2B]);
  const honey = 0xF2B632, honeyDark = 0xC98A12, honeyLight = 0xFFDE8C;

  // Kafanin tepesinde bal: damlalar uzar, kopar, duser.
  final cy = g.chubby ? 64.0 : 96.0;
  final blob = g.at(340, cy, 340, cy);
  final grow = g.pop;
  g.oval(blob + Offset(0, 1.5 * u), (g.chubby ? 56 : 40) * u * grow, 13 * u * grow, g.f(honeyDark));
  g.oval(blob, (g.chubby ? 54 : 38) * u * grow, 11.5 * u * grow, g.f(honey));
  g.oval(blob + Offset(-10 * u, -3.5 * u), 16 * u * grow, 3 * u, g.f(honeyLight, 0.9));
  const drips = [
    [-0.62, 0.0],
    [-0.12, 0.45],
    [0.42, 0.2],
    [0.78, 0.7],
  ];
  for (var i = 0; i < drips.length; i++) {
    final dx = drips[i][0] * (g.chubby ? 52 : 36) * u;
    final x0 = blob.dx + dx;
    final cycle = g.still ? 0.55 : ((g.time * 0.5 + drips[i][1]) % 1);
    final len = (6 + 30 * CelebrationContext.easeInOut((cycle / 0.8).clamp(0.0, 1.0))) * u * grow;
    final top = blob.dy + 3 * u;
    g.line(Offset(x0, top), Offset(x0, top + len), 8.5 * u, honeyDark);
    g.line(Offset(x0, top), Offset(x0, top + len), 6.2 * u, honey);
    g.circle(Offset(x0, top + len), 4.8 * u, honey);
    g.circle(Offset(x0 - 1.4 * u, top + len - 1.2 * u), 1.4 * u, 0xFFF3C4, 0.9);
    if (cycle > 0.8) {
      // Kopan damla duser.
      final fp = (cycle - 0.8) / 0.2;
      final y = top + len + fp * fp * 120 * u;
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, 1 - fp));
      g.oval(Offset(x0, y), 3.8 * u, 5.4 * u, g.f(honey));
      canvas.restore();
    }
  }

  // Arilar: kapagin etrafinda sekiz cizerek vizildar.
  final ctr = c.capCenter + Offset(0, -6 * u);
  for (var i = 0; i < 4; i++) {
    final a = g.time * 2.4 + i * g2Tau / 4 + (g.still ? i * 0.9 : 0);
    final rx = (g.chubby ? 128 : 96) + i * 6;
    final p = ctr + Offset(math.sin(a) * rx, math.sin(a * 2 + i) * (g.chubby ? 50 : 40) - 18 * u);
    final dir = math.cos(a) >= 0 ? 1.0 : -1.0;
    // Kesikli ucus izi.
    for (var k = 1; k <= 3; k++) {
      final a2 = a - k * 0.16;
      final q = ctr + Offset(math.sin(a2) * rx, math.sin(a2 * 2 + i) * (g.chubby ? 50 : 40) - 18 * u);
      g.circle(q, (2.0 - k * 0.3) * u, 0x8B5A2B, 0.4 - k * 0.1);
    }
    _bee(g, p, dir, g.pop);
  }
}

// --- Koala: okaliptus yapraklari, sarilma sallantisi ----------------------------------

CapPose _koalaPose(CelebrationContext c) {
  final e = _env(c);
  return CapPose(rotation: _sin(c, 0.9) * 0.075 * e, dx: _sin(c, 0.9) * 3.5 * e);
}

void _koala(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.fallingLeaves, const [0x6FA85A, 0x97C459, 0xB5D4A0]);

  // Okaliptus dali: sag ustten sallanan yuvarlak yapraklar.
  const cols = [0x8FBF9B, 0x6FA085, 0xA6CDB0];
  for (var s = 0; s < 2; s++) {
    final sgn = s == 0 ? 1.0 : -1.0;
    final base = g.at(s == 0 ? 404 : 276, 70, s == 0 ? 392 : 288, 90);
    final sw = g.wave(1.3, s * 1.7) * 0.22;
    final stem = [
      for (var i = 0; i <= 8; i++)
        base +
            Offset(sgn * (i * 6.5 * u) + math.sin(sw + i * 0.2) * i * 1.2 * u,
                -i * 8.5 * u * g.pop),
    ];
    for (var i = 0; i < stem.length - 1; i++) {
      g.line(stem[i], stem[i + 1], 2.2 * u, 0x5F7F55);
    }
    for (var i = 2; i < stem.length; i += 1) {
      final side = i.isEven ? -1.0 : 1.0;
      final p = stem[i] + Offset(side * 7 * u, 2 * u);
      g.oval(p, 8.5 * u, 5.4 * u, g.f(cols[i % 3]), side * 0.6 + sw);
      g.oval(p - Offset(side * 1.5 * u, 1.2 * u), 4 * u, 1.6 * u, g.f(0xE6F2E6, 0.6), side * 0.6 + sw);
    }
  }

  // Sarilma: iki kol kapagin altindan cam govdeye dolanir, nabiz gibi sikar.
  final squeeze = 0.5 + 0.5 * g.wave(0.9, -1.4);
  for (final side in const [-1.0, 1.0]) {
    final sh = g.at(side < 0 ? 248 : 432, 178, side < 0 ? 287 : 393, 144);
    final hand = g.at(340 + side * (30 - squeeze * 14), 216, 340 + side * (16 - squeeze * 6), 182);
    final elbow = Offset(
      (sh.dx + hand.dx) / 2 + side * 6 * u,
      math.max(sh.dy, hand.dy) + 10 * u,
    );
    final arm = [
      for (var i = 0; i <= 10; i++)
        Offset.lerp(Offset.lerp(sh, elbow, i / 10), Offset.lerp(elbow, hand, i / 10), i / 10)!,
    ];
    g.taper(arm, (f) => (8.5 - 1.2 * f) * u, 0x818A97, grow: 2.2 * u);
    g.taper(arm, (f) => (8.5 - 1.2 * f) * u, 0xAEB6C0);
    g.circle(hand, 8 * u, 0x818A97);
    g.circle(hand, 6.2 * u, 0xAEB6C0);
    for (var k = -1; k <= 1; k++) {
      g.circle(hand + Offset(k * 3 * u - side * 2 * u, 5 * u), 1.6 * u, 0x3C3F46);
    }
  }
  g.sparkle(g.at(250, 90, 296, 106), 5 * u, 0xFFFFFF, 0.8);
}

// --- Panda: bambu cirner, yapraklar ----------------------------------------------------

CapPose _pandaPose(CelebrationContext c) {
  final e = _env(c);
  return CapPose(dy: _sin(c, 3).abs() * 2.6 * e, rotation: _sin(c, 1.5) * 0.03 * e);
}

void _panda(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.fallingLeaves, const [0x1D9E75, 0x97C459, 0x639922]);

  final chew = g.still ? 0.6 : g.wave(3);
  final mouth = g.at(340, 176, 340, 152);
  // Bambu govdesi agizdan sag alta uzanir.
  final tip = mouth + Offset(-3 * u, 3 * u + chew * 1.5 * u);
  final end = mouth + Offset(88 * u, 66 * u);
  const stalk = 0x7CC15A, node = 0x4F8F3A, lite = 0xB4E08C;
  g.line(tip, end, 13 * u, node);
  g.line(tip, end, 10.4 * u, stalk);
  g.line(tip + Offset(0, -2.5 * u), end + Offset(0, -2.5 * u), 2.4 * u, lite);
  final d = (end - tip) / (end - tip).distance;
  final nrm = Offset(-d.dy, d.dx);
  for (final f in const [0.3, 0.62, 0.9]) {
    final p = tip + (end - tip) * f;
    g.line(p - nrm * 6.2 * u, p + nrm * 6.2 * u, 2.3 * u, node);
  }
  // Isirik izi (agiz tarafinda taze kesik).
  g.circle(tip, 5.4 * u, 0xD9EDB8);
  // Yapraklar bambunun ucunda sallanir.
  for (var i = 0; i < 3; i++) {
    final a = -0.9 + i * 0.75 + g.wave(1.4, i.toDouble()) * 0.12;
    g.leaf(end + Offset.fromDirection(a, 15 * u), 13 * u, a, i == 1 ? 0x639922 : 0x97C459, 0x3D6B1A);
  }
  // Siyah patiler bambuyu tutar.
  for (final f in const [0.45, 0.78]) {
    final p = tip + (end - tip) * f + Offset(0, g.wave(3, f * 3) * 0.8 * u);
    g.oval(p, 9.4 * u, 7.4 * u, g.f(0x2C2C2A), 0.55);
    g.oval(p + Offset(-2.2 * u, -2.5 * u), 3 * u, 1.8 * u, g.f(0xFFFFFF, 0.25), 0.55);
  }
  // Cirpilan kirintilar.
  for (var i = 0; i < 6; i++) {
    final cyc = g.still ? i / 6 : ((g.time * 1.5 + i / 6) % 1);
    final p = tip + Offset(-6 * u - cyc * (12 + c.rand(i, 2) * 26) * u, cyc * -8 * u + cyc * cyc * 50 * u);
    g.circle(p, (3 - cyc * 1.6) * u, i.isEven ? 0xB4E08C : 0x7CC15A, 1 - cyc);
  }
}

// --- Inek: "Moo!" baloncugu + can sallanir -----------------------------------------------

CapPose _inekPose(CelebrationContext c) {
  final e = _env(c);
  final m = CelebrationContext.pulse(((c.t - 0.12) / 0.2).clamp(0.0, 1.0));
  return CapPose(dy: m * 4 * e, rotation: _sin(c, 1.4) * 0.025 * e - m * 0.04);
}

void _inek(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.hearts, const [0xF4A6C0, 0xED93B1, 0xFFFFFF]);

  // Can: boyunda asili, sallanir.
  final pivot = g.at(340, 208, 340, 176);
  final swing = g.still ? 0.3 : g.wave(2.6) * 0.55 * (1 - g.t * 0.35);
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
    canvas.drawCircle(Offset(-swing * 6, 23), 3.4, g.f(0x8A5A12));
  });
  // Can sesi cizgileri.
  if (!g.still && g.wave(2.6).abs() > 0.8) {
    final sgn = g.wave(2.6) > 0 ? 1.0 : -1.0;
    for (var i = 0; i < 2; i++) {
      final r = (20 + i * 6) * u;
      canvas.drawArc(
        Rect.fromCircle(center: pivot + Offset(0, 16 * u), radius: r),
        sgn > 0 ? -0.5 : math.pi - 0.9,
        0.4,
        false,
        g.s(0xFAC775, 2 * u, 0.9),
      );
    }
  }

  // "Moo!" baloncugu.
  final show = c.span(0.1, 0.22);
  final out = 1 - c.span(0.88, 1);
  final pop = g.still
      ? 1.0
      : (CelebrationContext.easeOut(show) * (1 + 0.14 * math.sin(show * math.pi))) * out;
  if (pop > 0.02) {
    final top = c.capTop;
    final ctr = Offset(top.dx + (g.chubby ? 98 : 88), top.dy - (g.chubby ? 34 : 38)) +
        Offset(0, g.still ? 0 : g.wave(1.6) * 2);
    final w = 116.0, h = 56.0;
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      const Radius.circular(28),
    );
    g.local(ctr, g.still ? 0 : g.wave(1.1) * 0.04, pop, () {
      final tailPath = Path()
        ..moveTo(-34, 18)
        ..lineTo(-52, 46)
        ..lineTo(-14, 24)
        ..close();
      canvas.drawRRect(r.inflate(3), g.f(0x2C3A44));
      canvas.drawPath(tailPath, g.f(0x2C3A44));
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
        text: TextSpan(
          text: 'Möö!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C3A44).withValues(alpha: c.alpha),
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      tp.dispose();
    });
  }
}

// --- Koyun: yun pufleri ziplar ----------------------------------------------------------

CapPose _koyunPose(CelebrationContext c) {
  final e = _env(c);
  return CapPose(dy: -_hop(c.elapsed * 1.1) * 7 * e, rotation: _sin(c, 1.1) * 0.03 * e);
}

void _koyun(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.bubbles, const [0xFFFFFF, 0xDDEFFB, 0xBFE0F5]);

  const n = 11;
  final rx = g.chubby ? 92.0 : 62.0, ry = g.chubby ? 62.0 : 38.0;
  final cy = g.chubby ? 118.0 : 122.0;
  for (var i = 0; i < n; i++) {
    // Halka uzerindeki konumdan baslar; her pof kendi ritminde ziplar.
    final ang = math.pi * (1.02 + 0.96 * i / (n - 1));
    final base = c.capPt(340 + math.cos(ang) * rx, cy + math.sin(ang) * ry);
    final ph = c.rand(i, 7) * 1.4;
    final cyc = g.still ? 0.4 + 0.1 * (i % 3) : ((g.time * 0.85 + ph) % 1);
    final h = math.sin(cyc * math.pi);
    final out = Offset(math.cos(ang), math.sin(ang));
    final lift = h * (30 + c.rand(i, 8) * 30) * u;
    final p = base + out * (h * 12 * u) + Offset(0, -lift * 0.9);
    final r = (11 + c.rand(i, 9) * 5) * u * g.pop;
    // Golge ve yumusak pof.
    g.oval(base + Offset(0, 4 * u), r * (1 - h * 0.3), r * 0.28, g.f(0x3A5A32, 0.12 * (1 - h)));
    g.circle(p + Offset(0, 1.6 * u), r + 1.8 * u, 0xD9C9A8);
    g.circle(p, r, 0xFFFFFF);
    g.circle(p + Offset(-r * 0.3, -r * 0.3), r * 0.4, 0xFFFFFF);
    g.circle(p + Offset(r * 0.25, r * 0.35), r * 0.55, 0xF3EAD8, 0.7);
  }
  // Havada suzulen kucuk pufler ve parilti.
  for (var i = 0; i < 5; i++) {
    final cyc = g.still ? 0.2 + i * 0.15 : ((g.time * 0.45 + i / 5) % 1);
    final x = c.capCenter.dx + (c.rand(i, 11) - 0.5) * 230 + math.sin(cyc * 6 + i) * 8;
    final y = c.capTop.dy - 6 - cyc * 90;
    final fade = math.sin(cyc * math.pi);
    g.circle(Offset(x, y), (5 + c.rand(i, 12) * 4) * u * 1.2, 0xFFFFFF, 0.9 * fade);
  }
}

// --- Boga: burun buhari + kafa sallama + taban tozu -----------------------------------------

/// Boga kapaginin burun delikleri, ham kapak koordinatinda (tombul, ince).
const _bogaNostrilsChubby = [Offset(322, 160), Offset(358, 160)];
const _bogaNostrilsSlim = [Offset(329, 143), Offset(351, 143)];

/// Kafa sallama: hizli yatay-donus titresimi, sona dogru sonumlenir.
CapPose _bogaShake(CelebrationContext ctx) {
  final t = ctx.t;
  final env = CelebrationContext.pulse(CelebrationContext.easeOut(t * 1.1)) *
      (1 - t * 0.5);
  final s = math.sin(t * math.pi * 2 * 6);
  return CapPose(rotation: s * 0.07 * env, dx: s * 2.2 * env);
}

void _bogaSteam(Canvas canvas, CelebrationContext ctx) {
  _bogaDust(canvas, ctx);
  final nostrils = ctx.chubby ? _bogaNostrilsChubby : _bogaNostrilsSlim;
  final k = ctx.chubby ? chubbyCapScale : 1.0;
  const puffs = 5;
  for (var side = 0; side < 2; side++) {
    final base = ctx.capPt(nostrils[side].dx, nostrils[side].dy);
    final dir = side == 0 ? -1.0 : 1.0;
    for (var i = 0; i < puffs; i++) {
      // Her buhar topu kendi gecikmesiyle baslar; hareketsizde sabit kare.
      final delay = (i / puffs) * 0.55 + side * 0.04;
      final p = ctx.reduceMotion
          ? (i + 1) / (puffs + 1) * 0.9
          : ((ctx.t - delay) / 0.4).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      final e = CelebrationContext.easeOut(p);
      final r = (5 + 17 * e) * (ctx.chubby ? 1.0 : 0.85) * (0.8 + k * 0.2);
      final c = base +
          Offset(
            dir * (6 + 26 * e) + math.sin(p * 5 + i + side) * 5,
            -4 - 78 * e,
          );
      final fade = math.sin(p * math.pi).clamp(0.0, 1.0);
      final o = 0.75 * fade;
      canvas.drawCircle(c, r, ctx.solid(0xFFFFFF, o));
      canvas.drawCircle(
        c + Offset(-r * 0.45, r * 0.25),
        r * 0.6,
        ctx.solid(0xF3F6F8, o * 0.9),
      );
      canvas.drawCircle(
        c + Offset(r * 0.5, r * 0.2),
        r * 0.55,
        ctx.solid(0xE6EDF2, o * 0.8),
      );
    }
  }
}

/// Termos tabaninda her kafa sallayista kopan toz bulutu.
void _bogaDust(Canvas canvas, CelebrationContext ctx) {
  final gl = ctx.glass;
  final ground = gl.bottom - 4;
  const stomps = [0.1, 0.3, 0.5, 0.7];
  const cols = [0xEBDCC0, 0xD6C09A, 0xFFF3DC];
  for (var s = 0; s < stomps.length; s++) {
    for (var side = 0; side < 2; side++) {
      for (var i = 0; i < 4; i++) {
        final p = ctx.reduceMotion
            ? (s == 1 ? (0.25 + i * 0.12) : -1.0)
            : ((ctx.t - stomps[s] - i * 0.012) / 0.2);
        if (p <= 0 || p >= 1) continue;
        final dir = side == 0 ? -1.0 : 1.0;
        final e = CelebrationContext.easeOut(p);
        final reach = 14 + 34 * ctx.rand(s * 8 + i, 21 + side);
        final x = (side == 0 ? gl.left : gl.right) + dir * (6 + reach * e);
        final y = ground - 6 * e - i * 3 + (1 - e) * 2;
        final r = (10 + 20 * e) * (0.8 + 0.25 * ctx.rand(s * 8 + i, 25));
        final o = (1 - p) * 1.0;
        canvas.drawCircle(Offset(x, y), r, ctx.paintOf(cols[(i + s) % 3], o));
        canvas.drawCircle(
          Offset(x + r * 0.35, y - r * 0.25),
          r * 0.55,
          ctx.paintOf(0xFFF3DC, o * 0.35),
        );
      }
    }
  }
}

// --- Kurbaga: dil cikar, sinek yakalar -----------------------------------------------------

/// Iki sinek: (baslangic zamani, yakalama penceresi baslangici, taraf).
const _flyWindows = [
  [0.0, 0.30, 0.46, 1.0],
  [0.46, 0.66, 0.82, -1.0],
];

Offset _flyPos(G2 g, int i, double time) {
  final side = _flyWindows[i][3];
  final mid = g.c.capCenter + Offset(side * (g.chubby ? 128.0 : 104.0), -(g.chubby ? 36.0 : 40.0));
  return mid +
      Offset(
        math.sin(time * 6.5 + i * 2) * 24 + math.sin(time * 2.1) * 10,
        math.sin(time * 9 + i) * 16 + math.cos(time * 3.1) * 6,
      );
}

CapPose _kurbagaPose(CelebrationContext c) {
  final e = _env(c);
  var gulp = 0.0;
  for (final w in _flyWindows) {
    gulp += CelebrationContext.pulse(((c.t - w[2]) / 0.1).clamp(0.0, 1.0));
  }
  final lean = c.t < 0.56 ? 1.0 : -1.0;
  final inWin = _flyWindows.any((w) => c.t > w[1] && c.t < w[2]) ? 1.0 : 0.0;
  return CapPose(
    dy: -gulp * 7 * e,
    rotation: lean * 0.05 * inWin * e + _sin(c, 1.3) * 0.015 * e,
    scale: 1 + gulp * 0.03,
  );
}

void _kurbaga(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.bubbles, const [0x8FE3B0, 0xC6F0CC, 0xFFFFFF]);
  final mouth = g.at(340, 190, 340, 148);

  for (var i = 0; i < _flyWindows.length; i++) {
    final w = _flyWindows[i];
    final start = w[0], hit = w[1], done = w[2];
    // Sinek: pencereden once ucar, dil uzandiginda donar, yakalaninca kaybolur.
    if (g.still) {
      if (i != 0) continue;
      final fp = _flyPos(g, 0, 0.9);
      _drawFly(g, fp, 1.0);
      final tipP = Offset.lerp(mouth, fp, 0.82)!;
      _drawTongue(g, mouth, tipP);
      continue;
    }
    if (g.t < start || g.t > done + 0.04) continue;
    final inFlick = g.t >= hit;
    final fp = _flyPos(g, i, inFlick ? hit * 2.6 : g.t * 2.6);
    final span = ((g.t - hit) / (done - hit)).clamp(0.0, 1.0);
    // Uzat (0..0.45) ve geri cek (0.45..1).
    final ext = span < 0.45
        ? CelebrationContext.easeOut(span / 0.45)
        : 1 - CelebrationContext.easeInOut((span - 0.45) / 0.55);
    final caught = span >= 0.45;
    if (!caught) {
      final appear = ((g.t - start) / 0.06).clamp(0.0, 1.0);
      _drawFly(g, fp, appear);
    }
    if (inFlick && ext > 0.01) {
      final tip = Offset.lerp(mouth, fp, ext)!;
      _drawTongue(g, mouth, tip, fly: caught ? fp : null, extent: ext);
    }
    if (caught && span < 0.8) {
      final k = (span - 0.45) / 0.35;
      g.sparkle(fp, (6 + k * 8) * u, 0xFFF3C4, 1 - k);
      g.sparkle(fp + Offset(12 * u, -8 * u), 4 * u * (1 - k), 0xFFFFFF, 1 - k);
    }
  }
}

void _drawFly(G2 g, Offset p, double a) {
  final u = g.u * 1.9;
  final flap = 0.4 + 0.6 * math.sin(g.time * 90).abs();
  g.oval(p + Offset(-3 * u, -5 * u), 4.5 * u, 7 * u * flap, g.f(0xFFFFFF, 0.7 * a), -0.4);
  g.oval(p + Offset(3 * u, -5 * u), 4.5 * u, 7 * u * flap, g.f(0xE8F4FF, 0.7 * a), 0.4);
  g.oval(p, 6.5 * u, 4.6 * u, g.f(0x2C2C2A, a));
  g.circle(p + Offset(5 * u, -1 * u), 2.8 * u, 0x3E5A2E, a);
  g.circle(p + Offset(6 * u, -2 * u), 1.1 * u, 0xFFFFFF, a);
}

void _drawTongue(G2 g, Offset from, Offset tip, {Offset? fly, double extent = 1}) {
  final u = g.u;
  g.line(from, tip, 13 * u, 0xC73F5D);
  g.line(from, tip, 10 * u, 0xF0607D);
  g.line(from + (tip - from) * 0.1, tip, 2 * u, 0xFFA3B5, 0.8);
  g.circle(tip, 9.6 * u, 0xC73F5D);
  g.circle(tip, 8 * u, 0xF0607D);
  if (fly != null) {
    g.oval(tip, 4.6 * u, 3.3 * u, g.f(0x2C2C2A), 0.4);
  }
}

// --- Tilki: kuyruk sallar, yaprak girdabi ----------------------------------------------------

CapPose _tilkiPose(CelebrationContext c) {
  final e = _env(c);
  return CapPose(rotation: _sin(c, 1.4, 0.8) * 0.06 * e, dy: -_sin(c, 2.8).abs() * 1.5 * e);
}

void _tilki(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  const leafCols = [0xE8782A, 0xC9381F, 0xF2A03D, 0xB5551A];
  final ctr = c.capCenter + Offset(0, g.chubby ? 6 : 0);
  final rx = g.chubby ? 150.0 : 122.0, ry = g.chubby ? 52.0 : 44.0;

  void whirl(bool front) {
    for (var i = 0; i < 11; i++) {
      final a = (g.still ? 0.4 : g.time * 1.5) + i * g2Tau / 11;
      final depth = math.sin(a);
      if ((depth >= 0) != front) continue;
      final lift = math.sin(a * 2 + i) * 10 * u + math.sin(g.time * 3 + i) * 3;
      final p = ctr + Offset(math.cos(a) * rx, depth * ry - 8 * u + lift);
      final r = (16 + c.rand(i, 31) * 6) * u * (front ? 1.2 : 0.9) * g.pop;
      final rot = a * 2 + i;
      g.leaf(p, r, rot, leafCols[i % 4], 0x5A2C0A, front ? 1 : 0.7);
    }
  }

  whirl(false);

  // Kuyruk: gur, sallanan, beyaz uclu.
  final b = g.at(402, 194, 392, 170);
  final sw = g.wave(1.4);
  final spine = [
    for (var i = 0; i <= 16; i++)
      G2.cubic(
        b,
        b + Offset(30 * u, 18 * u),
        b + Offset((54 + sw * 10) * u, -6 * u),
        b + Offset((48 + sw * 34) * u, -66 * u),
        i / 16,
      ),
  ];
  double half(double f) => (7 + 14 * math.sin(math.pow(f, 0.7) * math.pi * 0.9 + 0.1)) * u * (f > 0.93 ? (1 - f) / 0.07 * 0.6 + 0.4 : 1);
  g.taper(spine, half, 0xB5551A, grow: 2.4 * u);
  g.taper(spine, half, 0xE8782A);
  g.taper(spine, (f) => half(f) * 0.6, 0xF4A25E, to: 0.6, op: 0.6);
  g.taper(spine, half, 0xFFF6EA, from: 0.72);

  whirl(true);
  g.sparkle(g.at(250, 80, 296, 110), 5 * u, 0xFFE0A0, 0.9);
}

// --- Kurt: aya uluma, ses dalgalari -------------------------------------------------------------

CapPose _kurtPose(CelebrationContext c) {
  final up = CelebrationContext.easeOut(c.span(0.08, 0.28)) * (1 - CelebrationContext.easeInOut(c.span(0.86, 1)));
  return CapPose(
    rotation: -0.17 * up + _sin(c, 2.2) * 0.006 * up,
    dy: -4 * up,
    scale: 1 + 0.03 * up,
  );
}

void _kurt(Canvas canvas, CelebrationContext c) {
  final g = G2(canvas, c);
  final u = g.u;
  g.ambient(CelebrationKind.twinkles, const [0xFFFFFF, 0xDCE6FF, 0xB8C4F0]);

  // Arka plandaki ay (190, 96): uluyunca parlar, etrafinda yildizlar belirir.
  const moon = Offset(190, 96);
  final lit = g.still ? 1.0 : CelebrationContext.easeOut(c.span(0.1, 0.3)) * (1 - c.span(0.88, 1));
  final glow = 1 + 0.07 * math.sin(g.time * 3.4);
  for (var i = 3; i >= 1; i--) {
    canvas.drawCircle(moon, 36.0 * (1 + i * 0.3) * glow, c.paintOf(0xFFF3C4, 0.09 * (4 - i) * lit));
  }
  canvas.drawCircle(moon, 36, c.paintOf(0xFFF1B8, 0.85 * lit));
  canvas.drawCircle(moon + const Offset(-4, -3), 31, c.paintOf(0xFFF8D8, 0.7 * lit));
  canvas.drawCircle(moon + const Offset(-10, -8), 7, c.paintOf(0xE9D68E, 0.7 * lit));
  canvas.drawCircle(moon + const Offset(12, 12), 5, c.paintOf(0xE9D68E, 0.7 * lit));
  for (var i = 0; i < 5; i++) {
    final tw = 0.5 + 0.5 * math.sin(g.time * 4 + i * 1.7);
    g.sparkle(moon + Offset.fromDirection(i * 1.3 + 0.5, 62 + (i % 2) * 8), (3 + tw * 3.5) * 1.4, 0xFFFFFF, (0.4 + tw * 0.6) * lit);
  }

  // Uluyan agiz: kapak uzerinde acilan koyu agiz.
  final mouth = g.at(340, 190, 340, 152);
  final open = g.still ? 1.0 : CelebrationContext.easeOut(c.span(0.1, 0.26)) * (1 - c.span(0.84, 0.96));
  if (open > 0.02) {
    final wob = g.still ? 0.0 : g.wave(5) * 0.6;
    final ry = (g.chubby ? 5 + 13 * open : 4 + 9 * open) * u + wob * open;
    final rx = (g.chubby ? 13 : 10) * u * (0.7 + 0.3 * open);
    g.oval(mouth + Offset(0, ry * 0.3), rx + 1.6 * u, ry + 1.6 * u, g.f(0x3E3C58));
    g.oval(mouth + Offset(0, ry * 0.3), rx, ry, g.f(0x3A1A28));
    g.oval(mouth + Offset(0, ry * 0.75), rx * 0.62, ry * 0.5, g.f(0xE8758F));
  }

  // Ses dalgalari: agizdan aya dogru genisleyen yaylar.
  final to = moon - mouth;
  final base = math.atan2(to.dy, to.dx);
  final dist = to.distance;
  for (var i = 0; i < 4; i++) {
    final cyc = g.still ? 0.2 + i * 0.22 : ((g.time * 0.9 + i / 4) % 1);
    final r = (18 + cyc * (dist - 12)) ;
    final fade = math.sin(cyc * math.pi).clamp(0.0, 1.0) * open;
    if (fade <= 0.02) continue;
    canvas.drawArc(
      Rect.fromCircle(center: mouth, radius: r),
      base - 0.42,
      0.84,
      false,
      g.s(0xDCE6FF, (3.4 - cyc * 1.4) * u * 1.2, 0.85 * fade),
    );
  }
}
