import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import '../art.dart';
import '../illustrated_artwork.dart';
import '../thermos_painter.dart';
import 'celebration_context.dart';
import 'celebrations_limon.dart';

// Grup 4 - yiyecek ve doga: kaktus, kardanadam, bulut, karpuz,
// limon, avokado, dondurma. Konumlar kapak cizimlerinin ham
// koordinatlarindan ctx.capPt ile alinir (tombul kucultme + kapak pozu).

const Map<String, SignatureCelebration> g4Celebrations = {
  'kaktus': _kaktus,
  'kardanadam': _kardan,
  'bulut': _bulut,
  'karpuz': _karpuz,
  'limon': limonCelebration,
  'avokado': _avokado,
  'dondurma': _dondurma,
};

const Map<String, CapPoseFn> g4CapPoses = {
  'kaktus': _kaktusPose,
  'bulut': _bulutPose,
  'karpuz': _karpuzPose,
  'limon': limonPose,
  'avokado': _avokadoPose,
  'dondurma': _dondurmaPose,
};

// --- Ortak yardimcilar -------------------------------------------------------

typedef _E = CelebrationContext;

const _tau = math.pi * 2;

/// Kapagin olcegi (tombul kucultme x poz olcegi).
double _ck(CelebrationContext c) =>
    (c.chubby ? chubbyCapScale : 1.0) * c.pose.scale;

Paint _stroke(CelebrationContext c, int hex, double w, [double op = 1]) =>
    _pp(c, hex, op)
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

double _sat(double x) => x.clamp(0.0, 1.0);

/// Boya: dongude zarf (tur basi/sonu alfa cukuru) uygulanmaz.
Paint _pp(CelebrationContext c, int hex, [double op = 1]) =>
    c.looping ? c.solid(hex, op) : c.paintOf(hex, op);

/// Yildiz: giriste genel cizici, dongude zarfsiz kendi yildizimiz.
void _star(
  CelebrationContext c,
  Canvas cv,
  Offset o,
  double r,
  int hex, [
  double op = 1,
]) {
  if (!c.looping) {
    c.star(cv, o, r, hex, op);
    return;
  }
  final path = Path();
  for (var i = 0; i < 16; i++) {
    final rr = i.isEven ? r : r * 0.38;
    final a = i * math.pi / 8 - math.pi / 2;
    final p = o + Offset(math.cos(a), math.sin(a)) * rr;
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  path.close();
  cv.drawPath(path, c.solid(hex, op));
}

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
  cv.drawCircle(o, r * 1.5 * g, _pp(c, 0xFFFFFF, 0.28));
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
        _pp(c, col),
      );
      _ell(
        cv,
        o + Offset(math.cos(a), math.sin(a)) * (d * 1.05),
        len * 0.4,
        len * 0.12,
        a,
        _pp(c, 0xFFFFFF, layer == 0 ? 0.28 : 0.4),
      );
    }
  }
  cv.drawCircle(o, r * 0.34 * g, _pp(c, 0xFFD166));
  for (var i = 0; i < 6; i++) {
    final a = i * _tau / 6 + spin;
    cv.drawCircle(
      o + Offset(math.cos(a), math.sin(a)) * (r * 0.18 * g),
      r * 0.05 * g,
      _pp(c, 0xE8A317),
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

  final illustrated = c.hasIllustratedCap;
  // Resimli kaktüste çiçekler kapağın parçasıdır; ikinci bir çiçek katmanı
  // yüzün üstüne binmesin. Halka, polen ve yaprak hareketi yine korunur.
  // Kol uclarinda minik cicekler.
  final arms = c.chubby
      ? [c.capPt(244, 80), c.capPt(436, 80)]
      : [c.capPt(266, 78), c.capPt(414, 78)];
  for (var i = 0; i < 2 && !illustrated; i++) {
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
  if (!illustrated) _bigFlower(c, cv, f, R, g * breathe, spin);

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
    _star(c, cv, p, r, i.isEven ? 0xFFD166 : 0xFFFFFF, 1 - ph);
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
  if (h > 0.001 && IllustratedArtwork.byId['kardanadam'] == null) {
    _kardanHat(cv, c, h);
  }
  _snow(cv, c);
}

void _kardanScarfFlutter(
  Canvas cv,
  CelebrationContext c,
  double k, {
  double? phase,
  double? growOverride,
}) {
  // Atkinin sag ucundan ruzgarla savrulan serit.
  final base = c.chubby ? c.capPt(436, 198) : c.capPt(396, 170);
  final grow =
      growOverride ?? (c.reduceMotion ? 1.0 : _E.easeOut(c.span(0.05, 0.3)));
  if (grow <= 0) return;
  final len = (c.chubby ? 120.0 : 108.0) * k * grow * (c.chubby ? 1.0 : 1.15);
  final thick = (c.chubby ? 30.0 : 28.0) * k;
  const n = 16;
  final el = phase ?? c.elapsed * 1.7;
  final top = <Offset>[], bot = <Offset>[];
  Offset prev = base;
  for (var i = 0; i <= n; i++) {
    final s = i / n;
    final wave = math.sin(_tau * (s * 1.1 - el)) * (4 + 20 * s) * k * 1.3;
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
  cv.drawPath(path, _pp(c, 0xC0392B));
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
  final wob = c.looping ? math.sin(_tau * c.loop * 8) : math.sin(c.elapsed * 7);
  final tilt = -0.32 * h + wob * 0.04 * h;
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
    _star(
      c,
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
    cv.drawCircle(o, r + 1.4, _pp(c, 0x9CB8DC, 0.35 * fade));
    if (i % 5 == 0) {
      final p = _stroke(c, 0xFFFFFF, 1.5, fade);
      for (var j = 0; j < 3; j++) {
        final a = j * math.pi / 3 + el * 0.8 + i;
        final d = Offset(math.cos(a), math.sin(a)) * (r * 1.7);
        cv.drawLine(o - d, o + d, p);
      }
    } else {
      cv.drawCircle(o, r, _pp(c, 0xFFFFFF, fade));
    }
  }
}

// --- Sonbahar: yaprak girdabi -----------------------------------------------

// Kept for easy theme restoration; Sonbahar is no longer registered.
// ignore: unused_element
CapPose _sonbaharPose(CelebrationContext c) {
  final env = _E.pulse(c.span(0.04, 0.85));
  final s = math.sin(c.t * _tau * 3.2);
  return CapPose(rotation: s * 0.075 * env, dx: s * 3.5 * env);
}

// ignore: unused_element
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
    cv.drawPath(_leafPath(len, len * 0.28), _pp(c, col, fade));
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
            _pp(c, 0xFFFFFF, 0.95),
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
    cv.drawCircle(sun, sr * (1.6 + 1.0 * sg), _pp(c, 0xFFE27A, 0.18 * sg));
    cv.drawCircle(sun, sr * 1.25, _pp(c, 0xFFD54A, 0.2 * sg));
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
      _star(
        c,
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
  // Çekirdekler resimli kapakta doğrudan üfleyen ağızdan çıkar.
  final o = c.hasIllustratedCap ? c.mouth : c.capCenter;
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
      _bar(cv, p, 9, 5, spin, _pp(c, col, fade));
    } else {
      final sq = 0.55 + 0.45 * math.cos(spin * 1.3).abs();
      cv.save();
      cv.translate(p.dx, p.dy);
      cv.rotate(spin);
      cv.scale(sq, 1);
      cv.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 8.5, height: 15),
        _pp(c, 0x2C2C2A, fade),
      );
      cv.drawOval(
        Rect.fromCenter(center: const Offset(-1.2, -2.4), width: 2, height: 4),
        _pp(c, 0xFFFFFF, 0.55 * fade),
      );
      cv.restore();
    }
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
  cv.drawCircle(Offset.zero, r, _pp(c, 0x6E4524));
  cv.drawCircle(Offset(-r * 0.3, -r * 0.35), r * 0.38, _pp(c, 0xA77649, 0.85));
  cv.drawCircle(Offset(r * 0.35, r * 0.3), r * 0.5, _pp(c, 0x4B2D14, 0.45));
  // Yuz.
  final ey = r * 0.02, ex = r * 0.36;
  cv.drawCircle(Offset(-ex, ey), r * 0.14 * (1 + k2 * 0.1), _pp(c, 0x2C2C2A));
  cv.drawCircle(Offset(ex, ey), r * 0.14 * (1 + k2 * 0.1), _pp(c, 0x2C2C2A));
  cv.drawCircle(Offset(-ex - 1, ey - 1.2), r * 0.05, _pp(c, 0xFFFFFF));
  cv.drawCircle(Offset(ex - 1, ey - 1.2), r * 0.05, _pp(c, 0xFFFFFF));
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
    _pp(c, 0xED93B1, 0.8),
  );
  cv.drawOval(
    Rect.fromCenter(
      center: Offset(r * 0.62, r * 0.28),
      width: r * 0.3,
      height: r * 0.18,
    ),
    _pp(c, 0xED93B1, 0.8),
  );
  cv.restore();

  // Inis tozu: kucuk yildizlar.
  for (final l in const [0.27, 0.41, 0.51]) {
    final p = c.reduceMotion ? 0.0 : c.span(l, l + 0.12);
    if (p <= 0 || p >= 1) continue;
    for (var i = 0; i < 4; i++) {
      final s = i < 2 ? -1.0 : 1.0;
      final d = (8 + 22 * _E.easeOut(p)) * (0.7 + 0.3 * (i % 2));
      _star(
        c,
        cv,
        top + Offset(s * d, -3 - 12 * p * (1 + (i % 2))),
        3 * (1 - p) + 1,
        0xFFFFFF,
        1 - p,
      );
    }
  }
  if (c.reduceMotion) {
    _star(c, cv, top + const Offset(-34, -22), 4, 0xFFFFFF, 0.9);
    _star(c, cv, top + const Offset(36, -26), 3.4, 0xFFFFFF, 0.9);
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
    _bar(cv, Offset(x, y), 9.5, 3.8, rot, _pp(c, cols[i % cols.length], fade));
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
    final col = _pp(c, 0xF4A8C4, fade);
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
        _pp(c, 0xFFFFFF, 0.65 * fade),
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
        _pp(c, 0xFFFFFF, 0.65 * fade),
      );
    }
  }
}

// =============================================================================
// DONGULER: hedefte surekli oynayan, sarmasiz (periyodik) kutlamalar. Her sey
// c.loop (0..1, 3.2 sn) fonksiyonu; parcaciklarin evresi sarar, tur basinda
// sicrama/solma olmaz.
// =============================================================================

/// Döngü evresi (hedef aşıldığı sürece) için özel imzalar; bkz.
/// celebration_registry.dart.
const Map<String, SignatureCelebration> g4Loops = {
  'kaktus': _kaktusLoop,
  'kardanadam': _kardanLoop,
  'bulut': _bulutLoop,
  'karpuz': _karpuzLoop,
  'limon': limonLoop,
  'avokado': _avokadoLoop,
  'dondurma': _dondurmaLoop,
};

/// Döngü evresi için kapak pozları.
const Map<String, CapPoseFn> g4LoopPoses = {
  'kaktus': _kaktusLoopPose,
  'kardanadam': _kardanLoopPose,
  'bulut': _bulutLoopPose,
  'karpuz': _karpuzLoopPose,
  'limon': limonLoopPose,
  'avokado': _avokadoLoopPose,
  'dondurma': _dondurmaLoopPose,
};

double _fr(double x) => x - x.floorToDouble();

/// sin(2π(loop·n + off)); n tam sayi olmali (sarma).
double _sn(CelebrationContext c, [double n = 1, double off = 0]) =>
    math.sin(_tau * (c.loop * n + off));

/// 0..1..0 yumusak nefes (n tam sayi: sarmasiz).
double _breath(CelebrationContext c, [double n = 1]) =>
    (1 - math.cos(_tau * c.loop * n)) / 2;

double _bell(double u) => math.sin(_sat(u) * math.pi);

double _smooth(double x) {
  final v = _sat(x);
  return v * v * (3 - 2 * v);
}

/// Parcacik evresi: tur basina [n] kez, parcacik basina ofsetli.
double _ph(CelebrationContext c, int i, [double n = 1, int salt = 1]) =>
    _fr(c.loop * n + c.rand(i, salt));

/// Yaprak/petal gibi donen yassi parca.
void _petal(
  Canvas cv,
  Offset o,
  double r,
  double rot,
  double flipPhase,
  Paint p,
) {
  cv.save();
  cv.translate(o.dx, o.dy);
  cv.rotate(rot);
  cv.scale(1, 0.4 + 0.6 * math.cos(flipPhase).abs());
  cv.drawOval(
    Rect.fromCenter(center: Offset.zero, width: r * 2.2, height: r),
    p,
  );
  cv.restore();
}

// --- Kaktus: cicek acik kalir, salinir, taclar suzulur, parilti -------------

CapPose _kaktusLoopPose(CelebrationContext c) => CapPose(
  dy: -2.6 * _breath(c, 2),
  scale: 1 + 0.03 * _breath(c, 2),
  rotation: 0.045 * _sn(c),
);

void _kaktusLoop(Canvas cv, CelebrationContext c) {
  final base = c.chubby ? c.capPt(340, 46) : c.capPt(340, 80);
  final k = _ck(c);
  final R = (c.chubby ? 46.0 : 40.0) * k * (c.chubby ? 1.0 : 1.1);
  final sway = _sn(c);
  final f = base + Offset(sway * 4 * k, -2 * _breath(c, 2) * k);
  final arms = c.chubby
      ? [c.capPt(244, 80), c.capPt(436, 80)]
      : [c.capPt(266, 78), c.capPt(414, 78)];

  // Yayilan halka (yarim turda bir).
  for (var j = 0; j < 2; j++) {
    final u = _fr(c.loop * 2 + j * 0.5);
    cv.drawCircle(
      f,
      R * (0.9 + 1.5 * u),
      _stroke(c, 0xFFFFFF, 3 * (1 - u) + 0.5, 0.65 * (1 - u) * _sat(u * 8)),
    );
  }
  final illustrated = c.hasIllustratedCap;
  for (var i = 0; i < 2 && !illustrated; i++) {
    final s = i == 0 ? -1.0 : 1.0;
    _bigFlower(
      c,
      cv,
      arms[i] + Offset(_sn(c, 1, 0.5 + i * 0.25) * 3 * k, 0),
      R * 0.46,
      1 + 0.07 * _sn(c, 2, i * 0.25),
      s * 0.4 * _sn(c, 1, 0.25 + i * 0.25),
    );
  }
  if (!illustrated) {
    _bigFlower(c, cv, f, R, 1 + 0.05 * _sn(c, 2), 0.38 * sway);
  }

  // Suzulen cicek yapraklari.
  for (var i = 0; i < 10; i++) {
    final u = _ph(c, i);
    final start =
        f +
        Offset((c.rand(i, 2) - 0.5) * R * 1.5, (c.rand(i, 3) - 0.4) * R * 0.8);
    final pos =
        start +
        Offset(
          math.sin(_tau * (u * (1 + i % 2) + c.rand(i, 4))) * 15 +
              (c.rand(i, 5) - 0.5) * 70 * u,
          u * (95 + 55 * c.rand(i, 6)),
        );
    final fade = _bell(u) * 0.95;
    _petal(
      cv,
      pos,
      (5.5 + 3 * c.rand(i, 7)) * (k + 0.35),
      _tau * u * (1 + i % 3) * (i.isEven ? 1 : -1) + c.rand(i, 8) * 6,
      _tau * u * 2 + i,
      _pp(c, i % 3 == 0 ? 0xFFB3CB : 0xFF6FA0, fade),
    );
  }
  // Minik parildamalar.
  for (var i = 0; i < 9; i++) {
    final a = i * _tau / 9 + c.rand(i, 1);
    final d = R * (1.2 + 0.7 * c.rand(i, 2));
    final tw = math.pow(math.max(0.0, _sn(c, 2, c.rand(i, 3))), 2).toDouble();
    if (tw < 0.02) continue;
    _star(
      c,
      cv,
      f + Offset(math.cos(a) * d * 1.1, math.sin(a) * d * 0.85 - R * 0.2),
      (2.6 + 3.4 * c.rand(i, 4)) * (0.5 + 0.5 * tw),
      i.isEven ? 0xFFD166 : 0xFFFFFF,
      tw,
    );
  }
}

// --- Kardan adam: kar yagar, atki dalgalanir, sapka periyodik kalkar ---------

CapPose _kardanLoopPose(CelebrationContext c) =>
    CapPose(dy: -1.8 * _breath(c, 2), rotation: 0.02 * _sn(c));

void _kardanLoop(Canvas cv, CelebrationContext c) {
  final k = _ck(c);
  _kardanScarfFlutter(cv, c, k, phase: c.loop * 5, growOverride: 1.0);
  final h = _smooth(_bell((c.loop - 0.18) / 0.58) * 1.5);
  if (h > 0.001 && IllustratedArtwork.byId['kardanadam'] == null) {
    _kardanHat(cv, c, h);
  }
  // Surekli yagan kar: her tane kendi evresinde belirip kaybolur.
  final rect = designRect;
  for (var i = 0; i < 44; i++) {
    final u = _ph(c, i, 1 + i % 2);
    final x0 = rect.left + c.rand(i, 3) * rect.width;
    final x =
        x0 + math.sin(_tau * (u * (1 + i % 3) + c.rand(i, 4))) * 12 + u * 26;
    final y =
        rect.top +
        c.rand(i, 2) * (rect.height - 120) +
        u * (150 + 60 * c.rand(i, 7));
    final r = 1.9 + 3.0 * c.rand(i, 5);
    final fade =
        _bell(u) * _sat((y - rect.top) / 24) * _sat((rect.bottom - y) / 24);
    final o = Offset(rect.left + ((x - rect.left) % rect.width), y);
    cv.drawCircle(o, r + 1.4, _pp(c, 0x9CB8DC, 0.35 * fade));
    if (i % 5 == 0) {
      final p = _stroke(c, 0xFFFFFF, 1.5, fade);
      for (var j = 0; j < 3; j++) {
        final a = j * math.pi / 3 + _tau * u + i;
        final d = Offset(math.cos(a), math.sin(a)) * (r * 1.8);
        cv.drawLine(o - d, o + d, p);
      }
    } else {
      cv.drawCircle(o, r, _pp(c, 0xFFFFFF, fade));
    }
  }
}

// --- Sonbahar: yapraklar surekli girdap yapar ---------------------------------

// ignore: unused_element
CapPose _sonbaharLoopPose(CelebrationContext c) =>
    CapPose(rotation: 0.07 * _sn(c, 2), dx: 3.5 * _sn(c, 2));

// ignore: unused_element
void _sonbaharLoop(Canvas cv, CelebrationContext c) {
  final o = c.capCenter;
  final cw = c.capWidth;
  const cols = [0xD2691E, 0xE8A21E, 0xC0392B, 0xF2B134, 0xA0522D, 0x8E6B1E];
  for (var j = 0; j < 3; j++) {
    final rx = cw * (0.62 + 0.14 * j), ry = cw * (0.2 + 0.05 * j);
    final rect = Rect.fromCenter(
      center: o + Offset(0, -cw * 0.04 - j * 6),
      width: rx * 2,
      height: ry * 2,
    );
    final start = _tau * (c.loop * (j.isEven ? 1 : -1) + j * 0.33);
    final al = 0.35 + 0.35 * (0.5 + 0.5 * _sn(c, 2, j * 0.33));
    cv.drawArc(
      rect,
      start,
      1.5 + 0.4 * j,
      false,
      _stroke(c, 0xFFFFFF, 3.2, al),
    );
    cv.drawArc(
      rect,
      start + 0.1,
      1.0,
      false,
      _stroke(c, 0xE8A21E, 1.6, al * 0.7),
    );
  }
  for (var i = 0; i < 28; i++) {
    final p = _ph(c, i);
    final th = c.rand(i, 2) * _tau + p * _tau * 1.7;
    final rr = cw * (0.4 + 0.75 * _E.easeOut(p)) * (0.75 + 0.45 * c.rand(i, 3));
    final pos =
        o +
        Offset(math.cos(th) * rr, math.sin(th) * rr * 0.5) +
        Offset(p > 0.8 ? (p - 0.8) * 160 : 0, -cw * 0.1 - p * cw * 0.5);
    final fade = math.pow(math.sin(p * math.pi), 0.6).toDouble();
    final spin = th * 1.3 + c.rand(i, 4) * 6;
    final len = (22 + 14 * c.rand(i, 5)) * (c.chubby ? 1.0 : 0.9);
    cv.save();
    cv.translate(pos.dx, pos.dy);
    cv.rotate(spin);
    cv.scale(1, 0.35 + 0.65 * math.cos(spin * 0.7).abs());
    cv.drawPath(
      _leafPath(len, len * 0.28),
      _pp(c, cols[i % cols.length], fade),
    );
    cv.drawLine(
      Offset(-len * 0.5, 0),
      Offset(len * 0.5, 0),
      _stroke(c, 0x5A2E12, 1.2, 0.55 * fade),
    );
    cv.restore();
  }
}

// --- Bulut: gunes isinlari doner, gokkusagi parildar, hafif yagmur ------------

CapPose _bulutLoopPose(CelebrationContext c) {
  final rain = 0.5 - 0.5 * math.cos(_tau * c.loop);
  return CapPose(
    dx: 1.1 * rain * _sn(c, 14),
    dy: -3.5 * _breath(c, 2),
    scale: 1 + 0.025 * _breath(c, 2),
  );
}

void _bulutLoop(Canvas cv, CelebrationContext c) {
  final cc = c.capCenter;
  final cw = c.capWidth;
  final k = _ck(c);
  final cy = cc.dy + (c.chubby ? 14 : 12);
  final rxo = cw * (c.chubby ? 0.9 : 0.98);
  final ryo = (cy - c.capTop.dy) + (c.chubby ? 26 : 34);
  const cols = [0xE24B4A, 0xF5A23C, 0xF7D84A, 0x6FC36A, 0x4BA3E3, 0x9A6FD8];
  final bw = c.chubby ? 6.2 : 5.4;
  final sweep = _fr(c.loop);
  for (var i = 0; i < cols.length; i++) {
    final rect = Rect.fromCenter(
      center: Offset(cc.dx, cy),
      width: (rxo - i * bw) * 2,
      height: (ryo - i * bw) * 2,
    );
    final al = 0.82 + 0.16 * _sn(c, 2, -i / 12);
    cv.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      _stroke(c, cols[i], bw + 0.8, al),
    );
    // Soldan saga kayan parilti.
    cv.drawArc(
      rect,
      math.pi + sweep * (math.pi + 0.8) - 0.4,
      0.4,
      false,
      _stroke(c, 0xFFFFFF, bw * 0.8, 0.55 * _bell(sweep)),
    );
  }
  for (final sx in const [-1.0, 1.0]) {
    final e = Offset(cc.dx + sx * (rxo - bw * 2.6), cy + 2);
    final puff = 1 + 0.08 * _sn(c, 2, sx > 0 ? 0.25 : 0);
    for (final q in const [
      [0.0, 0.0, 9.0],
      [-8.0, 4.0, 7.0],
      [8.0, 4.0, 7.0],
    ]) {
      cv.drawCircle(
        e + Offset(q[0], q[1]) * puff,
        q[2] * puff * (k + 0.3),
        _pp(c, 0xFFFFFF, 0.95),
      );
    }
  }

  // Ara sira hafif yagmur (yagis yogunlugu tur boyunca dalgalanir).
  final env = 0.5 - 0.5 * math.cos(_tau * c.loop);
  final y0 = (c.chubby ? c.capPt(340, 212) : c.capPt(340, 176)).dy;
  for (var i = 0; i < 18; i++) {
    final ph = _ph(c, i, 2, 4);
    final x = cc.dx + (c.rand(i, 1) - 0.5) * cw * 0.9;
    final y = y0 - 6 + ph * 105;
    final gate = _sat((env - c.rand(i, 3) * 0.9) * 4);
    final fade = gate * _sat((1 - ph) * 3) * _sat(ph * 8);
    if (fade < 0.02) continue;
    final l = 8 + 6 * c.rand(i, 5);
    cv.drawLine(
      Offset(x, y),
      Offset(x - 1.6, y + l),
      _stroke(c, i.isEven ? 0x4BA3E3 : 0x8CC8F0, 2.6, 0.85 * fade),
    );
  }

  // Gunes: tam turda bir doner, isinlar nabiz atar.
  final sun = c.chubby ? c.capPt(408, 62) : c.capPt(388, 80);
  final sr = (c.chubby ? 26.0 : 17.0) * (c.chubby ? chubbyCapScale : 1.0);
  final pulse = _sn(c, 2);
  cv.drawCircle(sun, sr * (2.1 + 0.25 * pulse), _pp(c, 0xFFE27A, 0.2));
  cv.drawCircle(sun, sr * 1.25, _pp(c, 0xFFD54A, 0.22));
  const rays = 12;
  for (var i = 0; i < rays; i++) {
    final a = _tau * (i / rays + c.loop);
    final d = Offset(math.cos(a), math.sin(a));
    final len = sr * (0.5 + 0.28 * _sn(c, 3, i / rays * 3));
    cv.drawLine(
      sun + d * (sr * 1.2),
      sun + d * (sr * 1.2 + len + sr * 0.35),
      _stroke(c, 0xFFC83D, 3.2 * (c.chubby ? 1 : 0.85)),
    );
  }
  for (var i = 0; i < 4; i++) {
    final a = -2.6 + i * 0.7 + 0.1 * _sn(c, 1, i / 4);
    final tw = 0.5 + 0.5 * _sn(c, 2, i / 4);
    _star(
      c,
      cv,
      sun + Offset(math.cos(a), math.sin(a)) * (sr * (2.7 + 0.2 * (i % 2))),
      2.2 + 2.0 * tw,
      0xFFFFFF,
      0.5 + 0.5 * tw,
    );
  }
}

// --- Karpuz: cekirdekler ritmik olarak patlar ---------------------------------

CapPose _karpuzLoopPose(CelebrationContext c) {
  final x = _fr(c.loop * 3);
  final squash = _bell(x / 0.1);
  final pop = _bell((x - 0.08) / 0.22);
  return CapPose(
    scale: 1 - 0.07 * squash + 0.09 * pop,
    dy: 3 * squash - 4 * pop,
    rotation: 0.025 * _sn(c, 3),
  );
}

void _karpuzLoop(Canvas cv, CelebrationContext c) {
  final o = c.hasIllustratedCap ? c.mouth : c.capCenter;
  final cw = c.capWidth;
  final x = _fr(c.loop * 3);
  final fl = (x - 0.1) / 0.28;
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
  const g = 560.0;
  for (var i = 0; i < 32; i++) {
    final raw = c.loop * 3 - 0.1 - 0.05 * c.rand(i, 6);
    final ph = _fr(raw);
    final burst = raw.floor() % 3;
    final tau = ph * (3.2 / 3);
    final a = -math.pi / 2 + (c.rand(i, 1) - 0.5) * 2.3 + (burst - 1) * 0.45;
    final sp = 200 + 130 * c.rand(i, 2);
    final start = o + Offset((c.rand(i, 7) - 0.5) * cw * 0.3, -cw * 0.1);
    final p =
        start +
        Offset(
          math.cos(a) * sp * tau,
          math.sin(a) * sp * tau + 0.5 * g * tau * tau,
        );
    final fade = _sat((1 - ph) / 0.2) * _sat(ph * 25);
    if (fade <= 0.01) continue;
    final spin = c.rand(i, 3) * 6 + tau * (4 + 8 * c.rand(i, 4));
    if (i % 4 == 3) {
      final col = const [0xE5485A, 0x3F9142, 0xF9B7BE, 0x7BC96F][(i ~/ 4) % 4];
      _bar(cv, p, 9, 5, spin, _pp(c, col, fade));
    } else {
      cv.save();
      cv.translate(p.dx, p.dy);
      cv.rotate(spin);
      cv.scale(0.55 + 0.45 * math.cos(spin * 1.3).abs(), 1);
      cv.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 8.5, height: 15),
        _pp(c, 0x2C2C2A, fade),
      );
      cv.drawOval(
        Rect.fromCenter(center: const Offset(-1.2, -2.4), width: 2, height: 4),
        _pp(c, 0xFFFFFF, 0.55 * fade),
      );
      cv.restore();
    }
  }
}

// --- Avokado: cekirdek surekli ziplar -----------------------------------------

/// Ziplama evresi 0..1 (inis x=0'da; tur sinirinda cekirdek havada).
double _hopX(CelebrationContext c) => _fr(c.loop * 2 + 0.5);

double _hopSquash(double x) {
  final d = math.min(x, 1 - x);
  final v = _sat(1 - d / 0.12);
  return v * v;
}

CapPose _avokadoLoopPose(CelebrationContext c) {
  final sq = _hopSquash(_hopX(c));
  return CapPose(dy: 3.5 * sq, scale: 1 - 0.025 * sq);
}

void _avokadoLoop(Canvas cv, CelebrationContext c) {
  final top = c.capTop;
  final k = _ck(c);
  final r = (c.chubby ? 24.0 : 19.0) * (c.chubby ? 1.1 : 1.0);
  final x = _hopX(c);
  final h = 4 * x * (1 - x);
  final sq = _hopSquash(x);
  final height = h * (c.chubby ? 40.0 : 34.0);
  final air = _sat(h * 4);
  final pos = top + Offset(math.sin(_tau * x) * 3, -r * 0.55 - height);
  final sy = 1 - 0.24 * sq + 0.12 * air * _bell(x);
  final sx = 1 + 0.28 * sq - 0.05 * air;
  cv.save();
  cv.translate(pos.dx, pos.dy + r * 0.3 * sq);
  cv.rotate(0.14 * math.sin(_tau * x));
  cv.scale(sx, sy);
  final k2 = k + 0.3;
  cv.drawCircle(Offset.zero, r, _pp(c, 0x6E4524));
  cv.drawCircle(Offset(-r * 0.3, -r * 0.35), r * 0.38, _pp(c, 0xA77649, 0.85));
  cv.drawCircle(Offset(r * 0.35, r * 0.3), r * 0.5, _pp(c, 0x4B2D14, 0.45));
  final ey = r * 0.02, ex = r * 0.36;
  // Goz kirpma (turda iki kez).
  final blink = _fr(c.loop * 2 + 0.2) > 0.93 ? 0.15 : 1.0;
  for (final sxx in const [-1.0, 1.0]) {
    cv.save();
    cv.translate(sxx * ex, ey);
    cv.scale(1, blink);
    cv.drawCircle(Offset.zero, r * 0.14 * (1 + k2 * 0.1), _pp(c, 0x2C2C2A));
    cv.drawCircle(const Offset(-1, -1.2), r * 0.05, _pp(c, 0xFFFFFF));
    cv.restore();
  }
  cv.drawPath(
    Path()
      ..moveTo(-r * 0.22, r * 0.34)
      ..quadraticBezierTo(0, r * (0.62 + 0.14 * h), r * 0.22, r * 0.34),
    _stroke(c, 0x2C2C2A, 1.8),
  );
  for (final sxx in const [-1.0, 1.0]) {
    cv.drawOval(
      Rect.fromCenter(
        center: Offset(sxx * r * 0.62, r * 0.28),
        width: r * 0.3,
        height: r * 0.18,
      ),
      _pp(c, 0xED93B1, 0.8),
    );
  }
  cv.restore();
  // Inis tozu.
  final dp = x / 0.45;
  if (dp < 1) {
    for (var i = 0; i < 4; i++) {
      final s = i < 2 ? -1.0 : 1.0;
      final d = (8 + 24 * _E.easeOut(dp)) * (0.7 + 0.3 * (i % 2));
      _star(
        c,
        cv,
        top + Offset(s * d, -3 - 13 * dp * (1 + (i % 2))),
        3.2 * (1 - dp) + 1,
        0xFFFFFF,
        (1 - dp) * _sat(dp * 10),
      );
    }
  }
  // Havada parildayan yildizlar.
  for (var i = 0; i < 2; i++) {
    final tw = 0.5 + 0.5 * _sn(c, 2, i * 0.5);
    _star(
      c,
      cv,
      top + Offset(i == 0 ? -40 : 42, -26 - 10.0 * i),
      2.4 + 2.4 * tw,
      0xFFFFFF,
      0.4 + 0.6 * tw,
    );
  }
}

// --- Dondurma: serpinti yagar, damla tekrar tekrar suzulur --------------------

CapPose _dondurmaLoopPose(CelebrationContext c) =>
    CapPose(rotation: 0.04 * _sn(c, 2), dy: -2.4 * _breath(c, 2));

void _dondurmaLoop(Canvas cv, CelebrationContext c) {
  final o = c.capCenter;
  final cw = c.capWidth;
  final k = _ck(c);
  const cols = [0xF27FAA, 0x6EC3E8, 0xFAC775, 0x8E5BD0, 0x7BD99A, 0xE24B4A];
  final top = c.capTop.dy;
  final hw = cw * 0.46;
  final span = c.glass.top + 140 - 8;
  for (var i = 0; i < 46; i++) {
    final u = _ph(c, i, 1 + i % 2, 2);
    final x = o.dx + (c.rand(i, 1) - 0.5) * cw * 1.5;
    final nx = ((x - o.dx) / hw).clamp(-1.0, 1.0);
    final inScoop = (x - o.dx).abs() < hw * 0.92;
    final landY =
        top + (c.chubby ? 6 : 0) + (1 - math.sqrt(1 - nx * nx)) * cw * 0.34 + 3;
    var y = -6 + (span + 6) * _sat(u * 1.25);
    var rot = c.rand(i, 4) * 3 + _tau * u * (1 + (c.rand(i, 5) * 2).floor());
    var fade = _sat(u * 12);
    if (inScoop && y >= landY) {
      y = landY;
      rot = (c.rand(i, 4) - 0.5) * 2.4;
      fade *= _sat((1 - u) / 0.2);
    } else {
      fade *= _sat((span + 10 - y) / 40);
      if (u > 0.8) fade *= _sat((1 - u) / 0.2);
    }
    if (fade <= 0.01) continue;
    _bar(cv, Offset(x, y), 9.5, 3.8, rot, _pp(c, cols[i % cols.length], fade));
  }
  // Iki suzulen damla (yarim tur arayla).
  for (var d = 0; d < 2; d++) {
    final raw = d == 0
        ? (c.chubby ? const Offset(358, 202) : const Offset(318, 164))
        : (c.chubby ? const Offset(322, 204) : const Offset(362, 166));
    final a = c.capPt(raw.dx, raw.dy);
    final dr = _fr(c.loop + d * 0.5);
    final grow = _E.easeInOut(_sat(dr / 0.62));
    final len = (c.chubby ? 70.0 : 78.0) * grow * (d == 0 ? 1 : 0.85);
    final drip = dr > 0.62
        ? math.pow((dr - 0.62) / 0.38, 2.0).toDouble() * 110
        : 0.0;
    final fade = _sat(dr * 12) * _sat((1 - dr) * 10);
    if (fade < 0.01) continue;
    final wd = (c.chubby ? 11.0 : 10.0) * (k + 0.28);
    final col = _pp(c, 0xF4A8C4, fade);
    final px = a.dx, y0 = a.dy - 4;
    final stub = dr <= 0.62 ? len : len * (1 - 0.6 * _sat((dr - 0.62) / 0.15));
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px - wd * 0.42, y0, wd * 0.84, stub),
        Radius.circular(wd * 0.42),
      ),
      col,
    );
    if (dr <= 0.62) {
      cv.drawCircle(Offset(px, y0 + len), wd * 0.68, col);
    } else {
      _drop(cv, Offset(px, y0 + len + drip), wd * 0.7, math.pi / 2, col);
    }
    cv.drawCircle(
      Offset(px - wd * 0.2, y0 + len + (dr > 0.62 ? drip : 0) - wd * 0.2),
      wd * 0.2,
      _pp(c, 0xFFFFFF, 0.65 * fade),
    );
  }
}
