import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import '../art.dart';
import '../thermos_painter.dart';
import 'celebration_context.dart';

// Grup 4 - yiyecek ve doga: kaktus, kardanadam, sonbahar, bulut, karpuz,
// limon, avokado, dondurma, seftali. Konumlar kapak cizimlerinin ham
// koordinatlarindan ctx.capPt ile alinir (tombul kucultme + kapak pozu).

const Map<String, SignatureCelebration> g4Celebrations = {
  'kaktus': _kaktus,
  'kardanadam': _kardan,
  'sonbahar': _sonbahar,
  'bulut': _bulut,
  'karpuz': _karpuz,
  'limon': _limon,
  'avokado': _avokado,
  'dondurma': _dondurma,
  'seftali': _seftali,
};

const Map<String, CapPoseFn> g4CapPoses = {
  'kaktus': _kaktusPose,
  'sonbahar': _sonbaharPose,
  'bulut': _bulutPose,
  'karpuz': _karpuzPose,
  'limon': _limonPose,
  'avokado': _avokadoPose,
  'dondurma': _dondurmaPose,
  'seftali': _seftaliPose,
};

// --- Ortak yardimcilar -------------------------------------------------------

typedef _E = CelebrationContext;

const _tau = math.pi * 2;

/// Kapagin olcegi (tombul kucultme x poz olcegi).
double _ck(CelebrationContext c) =>
    (c.chubby ? chubbyCapScale : 1.0) * c.pose.scale;

Paint _stroke(CelebrationContext c, int hex, double w, [double op = 1]) =>
    c.paintOf(hex, op)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

void _ell(Canvas cv, Offset o, double rx, double ry, double rot, Paint p) {
  cv.save();
  cv.translate(o.dx, o.dy);
  cv.rotate(rot);
  cv.drawOval(
    Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
    p,
  );
  cv.restore();
}

Path _leafPath(double len, double wid) {
  final h = len / 2;
  return Path()
    ..moveTo(-h, 0)
    ..quadraticBezierTo(-h * 0.1, -wid * 1.6, h, 0)
    ..quadraticBezierTo(-h * 0.1, wid * 1.6, -h, 0)
    ..close();
}

/// Ucu yukari bakan damla (kutle merkezi 0,0).
Path _dropPath(double r) => Path()
  ..moveTo(0, -r * 2.0)
  ..cubicTo(r * 0.25, -r * 1.2, r, -r * 0.6, r, 0)
  ..arcToPoint(Offset(-r, 0), radius: Radius.circular(r))
  ..cubicTo(-r, -r * 0.6, -r * 0.25, -r * 1.2, 0, -r * 2.0)
  ..close();

/// Damlanin ucu hareket yonunun tersine baksin ([ang] = hiz yonu).
void _drop(Canvas cv, Offset o, double r, double ang, Paint p) {
  cv.save();
  cv.translate(o.dx, o.dy);
  cv.rotate(ang - math.pi / 2);
  cv.drawPath(_dropPath(r), p);
  cv.restore();
}

/// Kenarlari yuvarlak minik cubuk (serpinti).
void _bar(Canvas cv, Offset o, double len, double w, double rot, Paint p) {
  cv.save();
  cv.translate(o.dx, o.dy);
  cv.rotate(rot);
  cv.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: len, height: w),
      Radius.circular(w / 2),
    ),
    p,
  );
  cv.restore();
}

/// Yaprak/cicek tomurcugu: 5 yapraklı cicek.
void _blossom(
  CelebrationContext c,
  Canvas cv,
  Offset o,
  double r,
  double rot,
  int petal,
  int center, [
  double op = 1,
]) {
  for (var i = 0; i < 5; i++) {
    final a = rot + i * _tau / 5;
    _ell(
      cv,
      o + Offset(math.cos(a), math.sin(a)) * (r * 0.62),
      r * 0.62,
      r * 0.42,
      a,
      c.paintOf(petal, op),
    );
  }
  cv.drawCircle(o, r * 0.34, c.paintOf(center, op));
}

double _sat(double x) => x.clamp(0.0, 1.0);

// --- Kaktus: ustte cicek acar -------------------------------------------------

CapPose _kaktusPose(CelebrationContext c) {
  final p = _E.pulse(c.span(0.08, 0.34));
  final w = math.sin(c.t * _tau * 2.5) * 0.025 * _E.pulse(c.span(0.1, 0.9));
  return CapPose(dy: -3 * p, scale: 1 + 0.045 * p, rotation: w);
}

void _bigFlower(
  CelebrationContext c,
  Canvas cv,
  Offset o,
  double r,
  double grow,
  double spin,
) {
  if (grow <= 0) return;
  final g = grow;
  // Yumusak hale.
  cv.drawCircle(o, r * 1.5 * g, c.paintOf(0xFFFFFF, 0.28));
  for (var layer = 0; layer < 2; layer++) {
    final n = layer == 0 ? 8 : 6;
    final len = (layer == 0 ? 1.0 : 0.66) * r * g;
    final col = layer == 0 ? 0xFF6FA0 : 0xFFB3CB;
    for (var i = 0; i < n; i++) {
      final a = spin * (layer == 0 ? 1 : -1.4) + i * _tau / n + layer * 0.4;
      final d = len * 0.62;
      _ell(
        cv,
        o + Offset(math.cos(a), math.sin(a)) * d,
        len * 0.62,
        len * 0.36,
        a,
        c.paintOf(col),
      );
      _ell(
        cv,
        o + Offset(math.cos(a), math.sin(a)) * (d * 1.05),
        len * 0.4,
        len * 0.12,
        a,
        c.paintOf(0xFFFFFF, layer == 0 ? 0.28 : 0.4),
      );
    }
  }
  cv.drawCircle(o, r * 0.34 * g, c.paintOf(0xFFD166));
  for (var i = 0; i < 6; i++) {
    final a = i * _tau / 6 + spin;
    cv.drawCircle(
      o + Offset(math.cos(a), math.sin(a)) * (r * 0.18 * g),
      r * 0.05 * g,
      c.paintOf(0xE8A317),
    );
  }
}

void _kaktus(Canvas cv, CelebrationContext c) {
  final f = c.chubby ? c.capPt(340, 46) : c.capPt(340, 80);
  final k = _ck(c);
  final R = (c.chubby ? 46.0 : 40.0) * k * (c.chubby ? 1.0 : 1.1);
  final g = c.reduceMotion
      ? 1.0
      : Curves.easeOutBack.transform(c.span(0.05, 0.38));
  final spin = c.reduceMotion ? 0.0 : c.elapsed * 0.45;
  final breathe = c.reduceMotion ? 1.0 : 1 + 0.035 * math.sin(c.elapsed * 6);

  // Kol uclarinda minik cicekler.
  final arms = c.chubby
      ? [c.capPt(244, 80), c.capPt(436, 80)]
      : [c.capPt(266, 78), c.capPt(414, 78)];
  for (var i = 0; i < 2; i++) {
    final ag = c.reduceMotion
        ? 1.0
        : Curves.easeOutBack.transform(c.span(0.2 + i * 0.07, 0.5 + i * 0.07));
    _bigFlower(
      c,
      cv,
      arms[i],
      R * 0.46,
      ag * breathe,
      -spin * (i == 0 ? 1 : -1),
    );
  }
  _bigFlower(c, cv, f, R, g * breathe, spin);

  // Acilis halkasi + polen kivilcimlari.
  final ring = c.reduceMotion ? 0.0 : c.span(0.12, 0.5);
  if (ring > 0 && ring < 1) {
    cv.drawCircle(
      f,
      R * (0.8 + 1.9 * _E.easeOut(ring)),
      _stroke(c, 0xFFFFFF, 3, 0.8 * (1 - ring)),
    );
  }
  for (var i = 0; i < 12; i++) {
    final ph = c.reduceMotion
        ? 0.2 + 0.6 * c.rand(i, 2)
        : _sat((c.t - 0.14 - c.rand(i, 1) * 0.3) / 0.5);
    if (ph <= 0 || ph >= 1) continue;
    final a = -math.pi / 2 + (c.rand(i, 2) - 0.5) * 3.0;
    final d = R * (0.9 + 2.0 * _E.easeOut(ph)) * (0.7 + 0.5 * c.rand(i, 3));
    final p =
        f + Offset(math.cos(a), math.sin(a)) * d + Offset(0, 14 * ph * ph);
    final r = (2.6 + 3 * c.rand(i, 4)) * (1 - ph * 0.5);
    c.star(cv, p, r, i.isEven ? 0xFFD166 : 0xFFFFFF, 1 - ph);
  }
}

// --- Kardan adam: kar, sapka kalkar, atki dalgalanir ---------------------------

double _hatLift(CelebrationContext c) {
  if (c.reduceMotion) return 0.85;
  final t = c.t;
  if (t < 0.1 || t > 0.74) return 0;
  if (t < 0.28) return Curves.easeOutBack.transform(_sat((t - 0.1) / 0.18));
  if (t < 0.52) return 1;
  final d = _sat((t - 0.52) / 0.22);
  final v = 1 - Curves.easeIn.transform(d);
  // Konarken minik zıplama.
  return d >= 1 ? 0 : v + (d > 0.85 ? 0.06 * math.sin((d - 0.85) * 20) : 0);
}

void _kardan(Canvas cv, CelebrationContext c) {
  final k = _ck(c);
  _kardanScarfFlutter(cv, c, k);
  final h = _hatLift(c);
  if (h > 0.001) _kardanHat(cv, c, h);
  _snow(cv, c);
}

void _kardanScarfFlutter(Canvas cv, CelebrationContext c, double k) {
  // Atkinin sag ucundan ruzgarla savrulan serit.
  final base = c.chubby ? c.capPt(436, 198) : c.capPt(396, 170);
  final grow = c.reduceMotion ? 1.0 : _E.easeOut(c.span(0.05, 0.3));
  if (grow <= 0) return;
  final len = (c.chubby ? 120.0 : 108.0) * k * grow * (c.chubby ? 1.0 : 1.15);
  final thick = (c.chubby ? 30.0 : 28.0) * k;
  const n = 16;
  final el = c.elapsed;
  final top = <Offset>[], bot = <Offset>[];
  Offset prev = base;
  for (var i = 0; i <= n; i++) {
    final s = i / n;
    final wave = math.sin(_tau * (s * 1.1 - el * 1.7)) * (4 + 20 * s) * k * 1.3;
    final p = base + Offset(len * s, wave - 8 * s * k);
    final dir = (p - prev);
    prev = p;
    final nrm = dir.distance < 0.001
        ? const Offset(0, 1)
        : Offset(-dir.dy, dir.dx) / dir.distance;
    final th = thick * (1 - 0.35 * s) * 0.5;
    top.add(p - nrm * th);
    bot.add(p + nrm * th);
  }
  final path = Path()..moveTo(top.first.dx, top.first.dy);
  for (final p in top.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  for (final p in bot.reversed) {
    path.lineTo(p.dx, p.dy);
  }
  path.close();
  cv.drawPath(path, c.paintOf(0xC0392B));
  // Acik renk seritler.
  for (final i in const [4, 9, 14]) {
    if (i >= top.length) continue;
    cv.drawLine(top[i], bot[i], _stroke(c, 0xE5594A, 4 * k + 1.5));
  }
  // Saçak.
  final end = (top.last + bot.last) / 2;
  for (var j = -1; j <= 1; j++) {
    final o = Offset(j * 5.0 * k, 0) + (top.last - bot.last) * (j * 0.28);
    cv.drawLine(
      end + o * 0.4,
      end + o * 0.4 + Offset(6 * k, 5 * k * (1 + j.abs() * 0.0)),
      _stroke(c, 0xC0392B, 2.5 * k + 0.8),
    );
  }
}

void _kardanHat(Canvas cv, CelebrationContext c, double h) {
  final chub = c.chubby;
  // Orijinal sapkayi/bereyi arka plan + kafa ile ortup yerine kaldirilmisini ciz.
  final clipRaw = chub
      ? Rect.fromLTRB(268, 0, 412, 74)
      : Rect.fromLTRB(268, 36, 412, 126);
  final a = c.capPt(clipRaw.left, clipRaw.top);
  final b = c.capPt(clipRaw.right, clipRaw.bottom);
  cv.save();
  cv.clipRect(Rect.fromPoints(a, b), doAntiAlias: false);
  c.theme.background(Art(cv));
  if (!chub) {
    cv.drawPath(
      Path()
        ..moveTo(300, 92)
        ..quadraticBezierTo(300, 40, 340, 40)
        ..quadraticBezierTo(380, 40, 380, 92),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = c.theme.band,
    );
    cv.drawPath(
      Path()
        ..moveTo(304, 90)
        ..quadraticBezierTo(304, 48, 340, 48),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = c.theme.bandLight,
    );
  }
  cv.save();
  if (chub) {
    cv.translate(340, 208);
    cv.scale(chubbyCapScale);
    cv.translate(-340, -208);
  }
  final art = Art(cv);
  if (chub) {
    art.dome(0xF4F8FF, w, 0xBCD0EA);
  } else {
    art.box(0xF4F8FF, w, 0xBCD0EA);
  }
  cv.restore();
  cv.restore();

  // Kalkmis sapka / bere (kenar etrafinda hafif egik).
  final lift = (chub ? 46.0 : 38.0) * h;
  final tilt = -0.32 * h + math.sin(c.elapsed * 7) * 0.04 * h;
  cv.save();
  if (chub) {
    cv.translate(340, 208);
    cv.scale(chubbyCapScale);
    cv.translate(-340, -208);
  }
  final pv = chub ? const Offset(340, 56) : const Offset(340, 112);
  cv.translate(pv.dx + 18 * h, pv.dy - lift / (chub ? chubbyCapScale : 1));
  cv.rotate(tilt);
  cv.translate(-pv.dx, -pv.dy);
  final ar = Art(cv);
  if (chub) {
    ar.o(340, 56, 62, 10, 0x2C2C2A);
    ar.p('M300 56 L304 12 Q340 4 376 12 L380 56 Z', 0x3B3B3A);
    ar.p('M302 46 L379 46 L380 56 L300 56 Z', 0xC0392B);
    ar.p('M310 16 L318 16 L316 44 L310 44 Z', 0x5F5E5A, op: 0.8);
  } else {
    ar.p('M284 112 Q284 66 340 62 Q396 66 396 112 Z', 0xC0392B);
    ar.p('M284 112 L396 112 L396 124 L284 124 Z', 0xE5594A);
    for (var x = 292; x < 396; x += 12) {
      ar.s('M$x 112 L$x 124', 0xC0392B, 2);
    }
    ar.c(340, 58, 10, w);
  }
  cv.restore();

  // Sapkanin altindan cikan minik kivilcim/yildizlar.
  final top = chub ? c.capPt(340, 46) : c.capPt(340, 92);
  for (var i = 0; i < 3; i++) {
    final a2 = -math.pi / 2 + (i - 1) * 0.7;
    final d = (14 + 10 * h) * _ck(c) * 1.4;
    c.star(
      cv,
      top + Offset(math.cos(a2), math.sin(a2)) * (d + 6),
      3.4 + i % 2,
      0xFFFFFF,
      0.9 * _sat(h * 1.4),
    );
  }
}

void _snow(Canvas cv, CelebrationContext c) {
  const n = 42;
  final el = c.elapsed;
  final rect = designRect;
  for (var i = 0; i < n; i++) {
    final sp = 46 + 70 * c.rand(i, 1);
    final span = rect.height + 40;
    final y = rect.top - 20 + ((c.rand(i, 2) * span + el * sp) % span);
    final x =
        rect.left +
        c.rand(i, 3) * rect.width +
        math.sin(el * (1.2 + c.rand(i, 4)) + i) * 12 +
        el * 14;
    final xx = rect.left + ((x - rect.left) % rect.width);
    final r = 1.8 + 3.0 * c.rand(i, 5);
    final o = Offset(xx, y);
    final fade = _sat((y - rect.top) / 30) * _sat((rect.bottom - y) / 30);
    // Acik zeminde de gorunsun diye mavimsi hale.
    cv.drawCircle(o, r + 1.4, c.paintOf(0x9CB8DC, 0.35 * fade));
    if (i % 5 == 0) {
      final p = _stroke(c, 0xFFFFFF, 1.5, fade);
      for (var j = 0; j < 3; j++) {
        final a = j * math.pi / 3 + el * 0.8 + i;
        final d = Offset(math.cos(a), math.sin(a)) * (r * 1.7);
        cv.drawLine(o - d, o + d, p);
      }
    } else {
      cv.drawCircle(o, r, c.paintOf(0xFFFFFF, fade));
    }
  }
}

// --- Sonbahar: yaprak girdabi -----------------------------------------------

CapPose _sonbaharPose(CelebrationContext c) {
  final env = _E.pulse(c.span(0.04, 0.85));
  final s = math.sin(c.t * _tau * 3.2);
  return CapPose(rotation: s * 0.075 * env, dx: s * 3.5 * env);
}

void _sonbahar(Canvas cv, CelebrationContext c) {
  final o = c.capCenter;
  final cw = c.capWidth;
  const cols = [0xD2691E, 0xE8A21E, 0xC0392B, 0xF2B134, 0xA0522D, 0x8E6B1E];
  // Ruzgar cizgileri.
  for (var j = 0; j < 3; j++) {
    final ph = c.reduceMotion ? 0.5 : _sat((c.t - 0.06 - j * 0.07) / 0.6);
    if (ph <= 0 || ph >= 1) continue;
    final rx = cw * (0.62 + 0.14 * j), ry = cw * (0.2 + 0.05 * j);
    final start = _tau * (ph * 1.4 + j * 0.33);
    final rect = Rect.fromCenter(
      center: o + Offset(0, -cw * 0.04 - j * 6),
      width: rx * 2,
      height: ry * 2,
    );
    cv.drawArc(
      rect,
      start,
      1.2 + 0.4 * j,
      false,
      _stroke(c, 0xFFFFFF, 3.2, 0.7 * math.sin(ph * math.pi)),
    );
    cv.drawArc(
      rect,
      start + 0.1,
      0.9,
      false,
      _stroke(c, 0xE8A21E, 1.6, 0.5 * math.sin(ph * math.pi)),
    );
  }
  const n = 24;
  for (var i = 0; i < n; i++) {
    final d = c.rand(i, 1) * 0.3;
    final p = c.reduceMotion
        ? 0.15 + 0.7 * c.rand(i, 7)
        : _sat((c.t - 0.03 - d) / 0.66);
    if (p <= 0 || p >= 1) continue;
    final th = c.rand(i, 2) * _tau + p * _tau * 1.7;
    final rr = cw * (0.4 + 0.75 * _E.easeOut(p)) * (0.75 + 0.45 * c.rand(i, 3));
    var pos =
        o +
        Offset(math.cos(th) * rr, math.sin(th) * rr * 0.5) +
        Offset((p > 0.8 ? (p - 0.8) * 160 : 0), -cw * 0.1 - p * cw * 0.5);
    final fade = math.pow(math.sin(p * math.pi), 0.6).toDouble();
    final spin = th * 1.3 + c.rand(i, 4) * 6;
    final len = (22 + 14 * c.rand(i, 5)) * (c.chubby ? 1.0 : 0.9);
    final flip = 0.35 + 0.65 * math.cos(spin * 0.7).abs();
    cv.save();
    cv.translate(pos.dx, pos.dy);
    cv.rotate(spin);
    cv.scale(1, flip);
    final col = cols[i % cols.length];
    cv.drawPath(_leafPath(len, len * 0.28), c.paintOf(col, fade));
    cv.drawLine(
      Offset(-len * 0.5, 0),
      Offset(len * 0.5, 0),
      _stroke(c, 0x5A2E12, 1.2, 0.55 * fade),
    );
    cv.restore();
  }
}

// --- Bulut: kisa yagmur, sonra gunes ve gokkusagi ----------------------------

CapPose _bulutPose(CelebrationContext c) {
  final rain = _E.pulse(c.span(0.04, 0.46));
  final shiver = math.sin(c.t * _tau * 9) * 1.4 * rain;
  final hop = _E.pulse(c.span(0.46, 0.7)) * -4;
  return CapPose(
    dx: shiver,
    dy: hop,
    scale: 1 + 0.03 * _E.pulse(c.span(0.46, 0.7)),
  );
}

void _bulut(Canvas cv, CelebrationContext c) {
  final cc = c.capCenter;
  final cw = c.capWidth;
  final k = _ck(c);

  // Gokkusagi (arkada kalsin diye once).
  final rb = c.reduceMotion ? 1.0 : _E.easeOut(c.span(0.42, 0.72));
  if (rb > 0) {
    final cy = cc.dy + (c.chubby ? 14 : 12);
    final rxo = cw * (c.chubby ? 0.9 : 0.98);
    final ryo = (cy - c.capTop.dy) + (c.chubby ? 26 : 34);
    const cols = [0xE24B4A, 0xF5A23C, 0xF7D84A, 0x6FC36A, 0x4BA3E3, 0x9A6FD8];
    final bw = c.chubby ? 6.2 : 5.4;
    for (var i = 0; i < cols.length; i++) {
      final rx = rxo - i * bw, ry = ryo - i * bw;
      final rect = Rect.fromCenter(
        center: Offset(cc.dx, cy),
        width: rx * 2,
        height: ry * 2,
      );
      cv.drawArc(
        rect,
        math.pi,
        math.pi * rb,
        false,
        _stroke(c, cols[i], bw + 0.8, 0.95),
      );
    }
    // Uclarda minik bulutlar.
    final pf = _sat((rb - 0.6) / 0.4);
    if (pf > 0) {
      for (final sx in const [-1.0, 1.0]) {
        final e = Offset(cc.dx + sx * (rxo - bw * 2.6), cy + 2);
        for (final q in const [
          [0.0, 0.0, 9.0],
          [-8.0, 4.0, 7.0],
          [8.0, 4.0, 7.0],
        ]) {
          cv.drawCircle(
            e + Offset(q[0], q[1]) * pf,
            q[2] * pf * (k + 0.3),
            c.paintOf(0xFFFFFF, 0.95),
          );
        }
      }
    }
  }

  // Yagmur.
  final rainAmt = c.reduceMotion
      ? 0.0
      : _sat((c.t - 0.03) / 0.08) * (1 - _sat((c.t - 0.38) / 0.1));
  if (rainAmt > 0) {
    final y0 = (c.chubby ? c.capPt(340, 212) : c.capPt(340, 176)).dy;
    final fall = c.chubby ? 150.0 : 140.0;
    for (var i = 0; i < 30; i++) {
      if (c.rand(i, 3) > rainAmt) continue;
      final x = cc.dx + (c.rand(i, 1) - 0.5) * cw * 0.92;
      final ph =
          (c.elapsed * (1.7 + 0.5 * c.rand(i, 2)) + c.rand(i, 4) * 3) % 1;
      final y = y0 - 6 + ph * fall;
      final fade = _sat((1 - ph) * 3) * _sat(ph * 8);
      final l = 9 + 7 * c.rand(i, 5);
      cv.drawLine(
        Offset(x, y),
        Offset(x - 1.6, y + l),
        _stroke(c, i.isEven ? 0x4BA3E3 : 0x8CC8F0, 2.8, 0.95 * fade),
      );
    }
  }

  // Gunes: isinlar + hale + yuz.
  final sun = c.chubby ? c.capPt(408, 62) : c.capPt(388, 80);
  final sr = (c.chubby ? 26.0 : 17.0) * (c.chubby ? chubbyCapScale : 1.0);
  final sg = c.reduceMotion ? 1.0 : _E.easeOut(c.span(0.4, 0.62));
  if (sg > 0) {
    cv.drawCircle(sun, sr * (1.6 + 1.0 * sg), c.paintOf(0xFFE27A, 0.18 * sg));
    cv.drawCircle(sun, sr * 1.25, c.paintOf(0xFFD54A, 0.2 * sg));
    final rot = c.reduceMotion ? 0.0 : c.elapsed * 0.9;
    const rays = 9;
    for (var i = 0; i < rays; i++) {
      final a = (-165 + i * (225 / (rays - 1))) * math.pi / 180 + rot * 0.12;
      final inner = sr * 1.18;
      final outer = sr * (1.75 + 0.35 * math.sin(c.elapsed * 6 + i)) * sg;
      cv.drawLine(
        sun + Offset(math.cos(a), math.sin(a)) * inner,
        sun + Offset(math.cos(a), math.sin(a)) * (inner + (outer - inner)),
        _stroke(c, 0xFFC83D, 3.2 * (c.chubby ? 1 : 0.85), sg),
      );
    }
    for (var i = 0; i < 4; i++) {
      final a =
          -2.6 +
          i * 0.7 +
          (c.reduceMotion ? 0 : math.sin(c.elapsed * 3 + i) * 0.1);
      final d = sr * (2.5 + 0.2 * (i % 2));
      c.star(
        cv,
        sun + Offset(math.cos(a), math.sin(a)) * d,
        3.4,
        0xFFFFFF,
        sg * 0.9,
      );
    }
  }
}

// --- Karpuz: cekirdekler konfeti gibi firlar ---------------------------------

CapPose _karpuzPose(CelebrationContext c) {
  final t = c.t;
  final squash = _E.pulse(c.span(0.0, 0.1));
  final pop = _E.pulse(c.span(0.08, 0.26));
  final wob = math.sin(t * _tau * 4) * 0.03 * _E.pulse(c.span(0.1, 0.7));
  return CapPose(
    scale: 1 - 0.07 * squash + 0.09 * pop,
    dy: 3 * squash - 4 * pop,
    rotation: wob,
  );
}

void _karpuz(Canvas cv, CelebrationContext c) {
  final o = c.capCenter;
  final cw = c.capWidth;
  final t0 = 0.07;
  // Patlama parlamasi + isinlar.
  final fl = c.reduceMotion ? 0.0 : c.span(t0, t0 + 0.2);
  if (fl > 0 && fl < 1) {
    final e = _E.easeOut(fl);
    cv.drawCircle(
      o,
      cw * 0.55 * e,
      _stroke(c, 0xFFFFFF, 4 * (1 - fl), 0.9 * (1 - fl)),
    );
    for (var i = 0; i < 12; i++) {
      final a = i * _tau / 12;
      final d = Offset(math.cos(a), math.sin(a));
      cv.drawLine(
        o + d * (cw * 0.35 + cw * 0.3 * e),
        o + d * (cw * 0.35 + cw * (0.3 + 0.25 * (1 - fl)) * e),
        _stroke(c, i.isEven ? 0xE5485A : 0xF9B7BE, 3, 1 - fl),
      );
    }
  }
  const n = 40;
  const g = 560.0;
  for (var i = 0; i < n; i++) {
    final tau = c.reduceMotion
        ? 0.18 + 0.55 * c.rand(i, 9)
        : c.elapsed - t0 * _E.duration - c.rand(i, 6) * 0.12;
    if (tau < 0) continue;
    final a = -math.pi / 2 + (c.rand(i, 1) - 0.5) * 2.7;
    final sp = 210 + 170 * c.rand(i, 2);
    final start = o + Offset((c.rand(i, 7) - 0.5) * cw * 0.3, -cw * 0.1);
    final p =
        start +
        Offset(
          math.cos(a) * sp * tau,
          math.sin(a) * sp * tau + 0.5 * g * tau * tau,
        );
    final life = _sat(1 - (c.t - 0.7) / 0.28);
    final fade = c.reduceMotion ? 1.0 : life;
    if (fade <= 0) continue;
    final spin = c.rand(i, 3) * 6 + tau * (4 + 8 * c.rand(i, 4));
    if (i % 4 == 3) {
      // Meyve konfetisi.
      final col = const [0xE5485A, 0x3F9142, 0xF9B7BE, 0x7BC96F][(i ~/ 4) % 4];
      _bar(cv, p, 9, 5, spin, c.paintOf(col, fade));
    } else {
      final sq = 0.55 + 0.45 * math.cos(spin * 1.3).abs();
      cv.save();
      cv.translate(p.dx, p.dy);
      cv.rotate(spin);
      cv.scale(sq, 1);
      cv.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 8.5, height: 15),
        c.paintOf(0x2C2C2A, fade),
      );
      cv.drawOval(
        Rect.fromCenter(center: const Offset(-1.2, -2.4), width: 2, height: 4),
        c.paintOf(0xFFFFFF, 0.55 * fade),
      );
      cv.restore();
    }
  }
}

// --- Limon: sikilir, damlalar sicrar -------------------------------------------

const _limonHits = [0.09, 0.3];

CapPose _limonPose(CelebrationContext c) {
  var sq = 0.0;
  for (final h in _limonHits) {
    sq += math.sin(_sat(c.span(h, h + 0.12)) * math.pi);
  }
  final rel = _E.pulse(c.span(0.5, 0.7));
  return CapPose(
    scale: 1 - 0.1 * sq + 0.04 * rel,
    dy: 5 * sq,
    rotation: math.sin(c.t * _tau * 6) * 0.03 * _E.pulse(c.span(0.05, 0.55)),
  );
}

void _limon(Canvas cv, CelebrationContext c) {
  final o = c.capCenter;
  final cw = c.capWidth;
  const per = 24;
  final hits = c.reduceMotion ? [0.3] : _limonHits;
  for (var e = 0; e < hits.length; e++) {
    final hit = hits[e];
    final tau0 = c.reduceMotion ? 0.0 : c.elapsed - (hit + 0.05) * _E.duration;
    for (var i = 0; i < per; i++) {
      final id = e * 40 + i;
      final tau = c.reduceMotion
          ? 0.12 + 0.5 * c.rand(id, 8)
          : tau0 - c.rand(id, 6) * 0.06;
      if (tau < 0) continue;
      final side = (c.rand(id, 1) - 0.5) * 2;
      final a = -math.pi / 2 + side * 1.35;
      final sp = 170 + 150 * c.rand(id, 2);
      final start = o + Offset(side * cw * 0.3, -cw * 0.1);
      final v = Offset(math.cos(a) * sp, math.sin(a) * sp);
      final p = start + v * tau + Offset(0, 0.5 * 540 * tau * tau);
      final vel = v + Offset(0, 540 * tau);
      final life = c.reduceMotion ? 1.0 : _sat(1 - (c.t - 0.72) / 0.22);
      if (life <= 0) continue;
      final r = 4.2 + 4.2 * c.rand(id, 3);
      final ang = math.atan2(vel.dy, vel.dx);
      _drop(cv, p, r, ang, c.paintOf(i % 3 == 0 ? 0xFFE97A : 0xF5D400, life));
      cv.drawCircle(
        p + Offset(-r * 0.3, -r * 0.3),
        r * 0.28,
        c.paintOf(0xFFFFFF, 0.8 * life),
      );
    }
    // Sikma halkasi.
    final ring = c.reduceMotion ? 0.0 : c.span(hit, hit + 0.18);
    if (ring > 0 && ring < 1) {
      _ell(
        cv,
        o + Offset(0, cw * 0.05),
        cw * (0.4 + 0.5 * _E.easeOut(ring)),
        cw * (0.3 + 0.28 * _E.easeOut(ring)),
        0,
        _stroke(c, 0xFFF08A, 3, 0.9 * (1 - ring)),
      );
    }
  }
  // Sudaki halkalar ve damlama.
  final g = c.glass;
  for (var i = 0; i < 5; i++) {
    final base = (c.reduceMotion ? 0.45 : 0.36) + i * 0.11;
    final ph = c.reduceMotion ? 0.35 + 0.1 * i : _sat((c.t - base) / 0.2);
    if (ph <= 0 || ph >= 1) continue;
    final x = g.left + g.width * (0.2 + 0.6 * c.rand(i, 11));
    _ell(
      cv,
      Offset(x, c.waterY + 1),
      4 + 14 * ph,
      1.6 + 4 * ph,
      0,
      _stroke(c, 0xFFFFFF, 2, 0.8 * (1 - ph)),
    );
  }
  // Sag taraftan suzulen kalin damla.
  final dr = c.reduceMotion ? 0.5 : c.span(0.34, 0.8);
  if (dr > 0) {
    final x = o.dx + cw * 0.36;
    final y0 = o.dy + cw * 0.28;
    final len = 30 * _E.easeInOut(dr * 1.4);
    final fall = dr > 0.7 ? math.pow((dr - 0.7) / 0.3, 2) * 90 : 0.0;
    final col = c.paintOf(0xF5D400, 1 - _sat((dr - 0.9) * 8));
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 3, y0 + fall, 6, len),
        const Radius.circular(3),
      ),
      col,
    );
    cv.drawCircle(Offset(x, y0 + len + fall), 5.2, col);
    cv.drawCircle(
      Offset(x - 1.6, y0 + len + fall - 1.5),
      1.5,
      c.paintOf(0xFFFFFF, 0.8),
    );
  }
}

// --- Avokado: cekirdek ziplar --------------------------------------------------

/// Bebek cekirdegin ziplama egrisi: (yukseklik 0..1, sikisma 0..1).
(double, double) _pitHop(double t) {
  const segs = [
    [0.07, 0.27, 1.0],
    [0.27, 0.41, 0.5],
    [0.41, 0.51, 0.24],
    [0.51, 0.58, 0.08],
  ];
  for (var i = 0; i < segs.length; i++) {
    final s = segs[i];
    if (t >= s[0] && t < s[1]) {
      final x = (t - s[0]) / (s[1] - s[0]);
      final sq =
          (x > 0.84 ? (x - 0.84) / 0.16 : 0.0) +
          (x < 0.1 ? (0.1 - x) / 0.1 * 0.5 : 0.0);
      return (4 * x * (1 - x) * s[2], sq);
    }
  }
  return (0, 0);
}

CapPose _avokadoPose(CelebrationContext c) {
  var land = 0.0;
  for (final l in const [0.27, 0.41, 0.51]) {
    land += math.sin(_sat(c.span(l, l + 0.07)) * math.pi);
  }
  final launch = math.sin(_sat(c.span(0.04, 0.1)) * math.pi);
  return CapPose(
    dy: 3.5 * land - 3 * launch,
    scale: 1 - 0.025 * land + 0.03 * launch,
  );
}

void _avokado(Canvas cv, CelebrationContext c) {
  final top = c.capTop;
  final k = _ck(c);
  final r = (c.chubby ? 24.0 : 19.0) * (c.chubby ? 1.1 : 1.0);
  final (h, sq) = c.reduceMotion ? (0.7, 0.0) : _pitHop(c.t);
  final rest = c.t > 0.58 || (c.reduceMotion ? false : c.t < 0.07);
  if (!c.reduceMotion && c.t < 0.05) return;
  final height = h * (c.chubby ? 60.0 : 42.0);
  final pop = _sat((c.t - 0.05) / 0.04);
  final pos =
      top +
      Offset(0, -r * 0.55 - height) +
      (c.reduceMotion
          ? const Offset(0, 0)
          : Offset(math.sin(c.t * 9) * 0 + (c.t * 0), 0));
  // Gunes gibi parlama: cikis aninda halka.
  final ring = c.reduceMotion ? 0.0 : c.span(0.05, 0.22);
  if (ring > 0 && ring < 1) {
    cv.drawCircle(
      top,
      r * (1.0 + 2.6 * _E.easeOut(ring)),
      _stroke(c, 0xFFFFFF, 3, 0.8 * (1 - ring)),
    );
  }
  final sy = 1 - 0.22 * sq + (rest ? 0 : 0.12 * (h > 0.05 ? 1 : 0));
  final sx = 1 + 0.26 * sq - (rest ? 0 : 0.05 * (h > 0.05 ? 1 : 0));
  final wob = (c.reduceMotion || c.t < 0.58)
      ? 0.0
      : math.sin((c.t - 0.58) * 38) * 0.14 * _sat(1 - (c.t - 0.58) / 0.16);
  cv.save();
  cv.translate(pos.dx, pos.dy + r * 0.3 * sq);
  cv.rotate(wob + (rest ? 0 : math.sin(c.t * _tau * 3) * 0.1));
  cv.scale(sx * pop, sy * pop);
  final k2 = k + 0.3;
  cv.drawCircle(Offset.zero, r, c.paintOf(0x6E4524));
  cv.drawCircle(
    Offset(-r * 0.3, -r * 0.35),
    r * 0.38,
    c.paintOf(0xA77649, 0.85),
  );
  cv.drawCircle(Offset(r * 0.35, r * 0.3), r * 0.5, c.paintOf(0x4B2D14, 0.45));
  // Yuz.
  final ey = r * 0.02, ex = r * 0.36;
  cv.drawCircle(
    Offset(-ex, ey),
    r * 0.14 * (1 + k2 * 0.1),
    c.paintOf(0x2C2C2A),
  );
  cv.drawCircle(Offset(ex, ey), r * 0.14 * (1 + k2 * 0.1), c.paintOf(0x2C2C2A));
  cv.drawCircle(Offset(-ex - 1, ey - 1.2), r * 0.05, c.paintOf(0xFFFFFF));
  cv.drawCircle(Offset(ex - 1, ey - 1.2), r * 0.05, c.paintOf(0xFFFFFF));
  final smile = Path()
    ..moveTo(-r * 0.22, r * 0.34)
    ..quadraticBezierTo(0, r * (0.34 + 0.28 + 0.12 * h), r * 0.22, r * 0.34);
  cv.drawPath(smile, _stroke(c, 0x2C2C2A, 1.8));
  cv.drawOval(
    Rect.fromCenter(
      center: Offset(-r * 0.62, r * 0.28),
      width: r * 0.3,
      height: r * 0.18,
    ),
    c.paintOf(0xED93B1, 0.8),
  );
  cv.drawOval(
    Rect.fromCenter(
      center: Offset(r * 0.62, r * 0.28),
      width: r * 0.3,
      height: r * 0.18,
    ),
    c.paintOf(0xED93B1, 0.8),
  );
  cv.restore();

  // Inis tozu: kucuk yildizlar.
  for (final l in const [0.27, 0.41, 0.51]) {
    final p = c.reduceMotion ? 0.0 : c.span(l, l + 0.12);
    if (p <= 0 || p >= 1) continue;
    for (var i = 0; i < 4; i++) {
      final s = i < 2 ? -1.0 : 1.0;
      final d = (8 + 22 * _E.easeOut(p)) * (0.7 + 0.3 * (i % 2));
      c.star(
        cv,
        top + Offset(s * d, -3 - 12 * p * (1 + (i % 2))),
        3 * (1 - p) + 1,
        0xFFFFFF,
        1 - p,
      );
    }
  }
  if (c.reduceMotion) {
    c.star(cv, top + const Offset(-34, -22), 4, 0xFFFFFF, 0.9);
    c.star(cv, top + const Offset(36, -26), 3.4, 0xFFFFFF, 0.9);
  }
}

// --- Dondurma: seker serpintisi yagar, damla suzulur --------------------------

CapPose _dondurmaPose(CelebrationContext c) {
  final j = math.sin(c.t * _tau * 4.5) * 0.045 * _E.pulse(c.span(0.02, 0.6));
  final b = _E.pulse(c.span(0.05, 0.25));
  return CapPose(rotation: j, dy: -3 * b);
}

void _dondurma(Canvas cv, CelebrationContext c) {
  final o = c.capCenter;
  final cw = c.capWidth;
  final k = _ck(c);
  const cols = [0xF27FAA, 0x6EC3E8, 0xFAC775, 0x8E5BD0, 0x7BD99A, 0xE24B4A];
  final top = c.capTop.dy;
  final hw = cw * 0.46;
  const n = 52;
  final span = c.glass.top + 140 - 8;
  for (var i = 0; i < n; i++) {
    final x = o.dx + (c.rand(i, 1) - 0.5) * cw * 1.5;
    final start = 0.03 + c.rand(i, 2) * 0.5;
    final spd = 150 + 120 * c.rand(i, 3);
    final tau = c.reduceMotion
        ? 0.35 + 0.5 * c.rand(i, 9)
        : c.elapsed - start * _E.duration;
    if (tau < 0) continue;
    final inScoop = (x - o.dx).abs() < hw * 0.92;
    // Topa konanlar yuzeyde kalir.
    final nx = ((x - o.dx) / hw).clamp(-1.0, 1.0);
    final landY =
        top + (c.chubby ? 6 : 0) + (1 - math.sqrt(1 - nx * nx)) * cw * 0.34 + 3;
    var y = 8 - 14 + spd * tau;
    var rot = c.rand(i, 4) * 3 + tau * (3 + 5 * c.rand(i, 5));
    var settled = false;
    if (inScoop && y >= landY) {
      y = landY - 2 * math.exp(-(y - landY) / 4);
      y = landY;
      settled = true;
      rot = (c.rand(i, 4) - 0.5) * 2.4;
    }
    if (!inScoop && y > span) continue;
    final fade = settled
        ? _sat(1 - (c.t - 0.8) / 0.18)
        : _sat((span + 10 - y) / 40);
    if (fade <= 0) continue;
    _bar(
      cv,
      Offset(x, y),
      9.5,
      3.8,
      rot,
      c.paintOf(cols[i % cols.length], fade),
    );
  }

  // Suzulen damla (kapagin sag alt kenarindan).
  final raw = c.chubby ? const Offset(358, 202) : const Offset(318, 164);
  final a = c.capPt(raw.dx, raw.dy);
  final dr = c.reduceMotion ? 0.6 : c.span(0.22, 0.9);
  if (dr > 0) {
    final grow = _E.easeInOut(_sat(dr / 0.62));
    final len = (c.chubby ? 86.0 : 92.0) * grow;
    final drip = dr > 0.62
        ? math.pow((dr - 0.62) / 0.38, 2.0).toDouble() * 110
        : 0.0;
    final fade = _sat(1 - (dr - 0.9) * 10);
    final wd = (c.chubby ? 11.0 : 10.0) * (k + 0.28);
    final col = c.paintOf(0xF4A8C4, fade);
    final x = a.dx;
    final y0 = a.dy - 4;
    if (dr <= 0.62) {
      cv.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - wd * 0.42, y0, wd * 0.84, len),
          Radius.circular(wd * 0.42),
        ),
        col,
      );
      cv.drawCircle(Offset(x, y0 + len), wd * 0.68, col);
      cv.drawCircle(
        Offset(x - wd * 0.2, y0 + len - wd * 0.2),
        wd * 0.2,
        c.paintOf(0xFFFFFF, 0.65 * fade),
      );
    } else {
      // Kopan damla: serbest dusen top.
      final stub = len * (1 - 0.6 * _sat((dr - 0.62) / 0.15));
      cv.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - wd * 0.42, y0, wd * 0.84, stub),
          Radius.circular(wd * 0.42),
        ),
        col,
      );
      _drop(cv, Offset(x, y0 + len + drip), wd * 0.7, math.pi / 2, col);
      cv.drawCircle(
        Offset(x - wd * 0.2, y0 + len + drip - wd * 0.1),
        wd * 0.2,
        c.paintOf(0xFFFFFF, 0.65 * fade),
      );
    }
  }
}

// --- Seftali: cicek yapraklari savrulur, yanaklar kizarir ---------------------

CapPose _seftaliPose(CelebrationContext c) {
  final s = math.sin(c.t * _tau * 2.2);
  final env = _E.pulse(c.span(0.04, 0.9));
  return CapPose(
    rotation: s * 0.04 * env,
    dy: -2.2 * math.sin(c.t * _tau * 2.2 + 1.2).abs() * env,
  );
}

void _seftali(Canvas cv, CelebrationContext c) {
  final o = c.capCenter;
  final cw = c.capWidth;
  final k = _ck(c);
  const cols = [0xFFB3C1, 0xF7B8A0, 0xFF9A62, 0xF8A0B5, 0xFFD2B3];
  final rect = designRect;

  // Kapaktan savrulan yapraklar + gokyuzunden suzulenler.
  const n = 30;
  for (var i = 0; i < n; i++) {
    final burst = i < 12;
    final el = c.elapsed;
    Offset pos;
    double fade;
    final sway = math.sin(el * (1.6 + c.rand(i, 4)) + i * 1.7);
    if (burst) {
      final tau = c.reduceMotion
          ? 0.3 + 0.8 * c.rand(i, 9)
          : el - 0.18 - c.rand(i, 6) * 0.5;
      if (tau < 0) continue;
      final a = -math.pi / 2 + (c.rand(i, 1) - 0.5) * 2.6;
      final sp = 70 + 70 * c.rand(i, 2);
      pos =
          o +
          Offset(
            math.cos(a) * sp * tau + sway * 12,
            math.sin(a) * sp * tau + 36 * tau * tau,
          );
      fade = _sat(1 - (c.t - 0.75) / 0.23);
    } else {
      final span = rect.height + 40;
      final y =
          rect.top -
          20 +
          ((c.rand(i, 2) * span + el * (38 + 34 * c.rand(i, 3))) % span);
      final x =
          rect.left +
          ((c.rand(i, 5) * rect.width + el * 24 + sway * 22) % rect.width);
      pos = Offset(x, y);
      fade = _sat((y - rect.top) / 30) * _sat((rect.bottom - y) / 30);
    }
    final rot =
        c.rand(i, 7) * 6 + el * (1 + c.rand(i, 8) * 2) * (i.isEven ? 1 : -1);
    final r = 9 + 5.5 * c.rand(i, 10);
    final col = cols[i % cols.length];
    if (i % 6 == 0) {
      _blossom(c, cv, pos, r * 1.15, rot, col, 0xF26B6B, fade);
    } else {
      final f = 0.45 + 0.55 * math.cos(rot * 1.4).abs();
      cv.save();
      cv.translate(pos.dx, pos.dy);
      cv.rotate(rot);
      cv.scale(1, f);
      cv.drawPath(
        _dropPath(r * 0.55).transform(Matrix4.rotationZ(math.pi / 2).storage),
        c.paintOf(col, fade),
      );
      cv.restore();
    }
  }

  // Yanak kizarmasi (tombul kapakta yuz var; ince kapakta yok).
  final pulse = c.reduceMotion ? 0.8 : 0.5 + 0.5 * math.sin(c.elapsed * 7);
  final amt = c.reduceMotion
      ? 1.0
      : _sat(c.span(0.06, 0.2)) * _sat((1 - c.t) / 0.2 + 0.0);
  if (c.chubby) {
    for (final sx in const [282.0, 398.0]) {
      final p = c.capPt(sx, 154);
      cv.drawOval(
        Rect.fromCenter(
          center: p,
          width: 46 * k + 8 * pulse,
          height: 26 * k + 5 * pulse,
        ),
        c.paintOf(0xFF5E7E, (0.28 + 0.28 * pulse) * amt),
      );
      cv.drawOval(
        Rect.fromCenter(center: p, width: 30 * k, height: 17 * k),
        c.paintOf(0xF24B6A, (0.55 + 0.35 * pulse) * amt),
      );
      for (var j = 0; j < 3; j++) {
        final lx = p.dx + (j - 1) * 6.5 * k;
        cv.drawLine(
          Offset(lx - 1.6, p.dy + 3),
          Offset(lx + 1.6, p.dy - 3),
          _stroke(c, 0xFFFFFF, 1.5, 0.75 * amt),
        );
      }
    }
    // Minik kalpler.
    for (var i = 0; i < 3; i++) {
      final ph = c.reduceMotion
          ? 0.3 + 0.2 * i
          : ((c.elapsed * 0.9 + i * 0.37) % 1);
      final base = c.capPt(i.isEven ? 398 : 282, 150);
      _heart(
        cv,
        base + Offset(math.sin(ph * 6 + i) * 6, -ph * 40),
        4.6 * (k + 0.3) * (1 - ph * 0.3),
        c.paintOf(0xFF5E7E, 0.95 * math.sin(ph * math.pi) * amt),
      );
    }
  } else {
    final p = c.capPt(340, 130);
    cv.drawOval(
      Rect.fromCenter(center: p, width: cw * 1.25, height: cw * 1.05),
      c.paintOf(0xFFB3C1, 0.1 + 0.12 * pulse),
    );
    for (var i = 0; i < 4; i++) {
      final a = -2.4 + i * 0.55;
      c.star(
        cv,
        p + Offset(math.cos(a), math.sin(a)) * (cw * 0.62),
        3.4,
        0xFFFFFF,
        0.6 + 0.4 * math.sin(c.elapsed * 5 + i),
      );
    }
  }
}

void _heart(Canvas cv, Offset o, double r, Paint p) {
  final path = Path()
    ..moveTo(o.dx, o.dy + r * 0.9)
    ..cubicTo(
      o.dx - r * 1.6,
      o.dy - r * 0.1,
      o.dx - r * 0.7,
      o.dy - r * 1.3,
      o.dx,
      o.dy - r * 0.4,
    )
    ..cubicTo(
      o.dx + r * 0.7,
      o.dy - r * 1.3,
      o.dx + r * 1.6,
      o.dy - r * 0.1,
      o.dx,
      o.dy + r * 0.9,
    )
    ..close();
  cv.drawPath(path, p);
}

/// Döngü evresi (hedef aşıldığı sürece) için isteğe bağlı özel imzalar; boşsa
/// giriş imzasının orta bölümü döngülenir. Bkz. celebration_registry.dart.
const Map<String, SignatureCelebration> g4Loops = {};

/// Döngü evresi için isteğe bağlı kapak pozları (boşsa giriş pozu döngülenir).
const Map<String, CapPoseFn> g4LoopPoses = {};
