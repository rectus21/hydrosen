import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import 'celebration_context.dart';
import 'fx_sprites.dart';

part 'celebrations_fx2.dart';

// SPRITE TABANLI KUTLAMALAR: kopek, penguen, koala, koyun, avokado, kaktus.
// Spec: 02-Design/Kutlama-Alternatifleri-6-Tema.md "Rectus'un seçimi".
// Konumlar bağlamın kapak/cam çapalarından türer (tombul/ince, zoom fark
// etmez: kart koordinatı). Hareket azaltılmışken sabit kare çizilir.

/// Bu temalarda kutlama kart kırpmasına tabi değildir (Clip.none).
const fxThemeIds = {
  'kopek',
  'penguen',
  'koala',
  'koyun',
  'avokado',
  'kaktus',
  'baykus',
  'civciv',
  'rakun',
  'kamp',
  'okyanus',
  'yesilelma',
  'futbol',
  'basketbol',
  'voleybol',
  'karaejderha',
  'yarisarabasi',
  'kedi',
  'pofuduk',
};

const Map<String, SignatureCelebration> fxCelebrations = {
  'kopek': _kopek,
  'penguen': _penguen,
  'koala': _koala,
  'koyun': _koyun,
  'avokado': _avokadoDisco,
  'kaktus': _kaktus,
  'baykus': _baykus,
  'civciv': _civciv,
  'rakun': _rakun,
  'kamp': _kamp,
  'okyanus': _okyanus,
};

const Map<String, SignatureCelebration> fxLoops = {
  'kopek': _kopekLoop,
  'penguen': _penguenLoop,
  'koala': _koalaLoop,
  'koyun': _koyunLoop,
  'avokado': _avokadoDisco,
  'kaktus': _kaktusLoop,
  'baykus': _baykus,
  'civciv': _civciv,
  'rakun': _rakun,
  'kamp': _kamp,
  'okyanus': _okyanusLoop,
};

const Map<String, CapPoseFn> fxCapPoses = {
  'kopek': _kopekPose,
  'penguen': _penguenPose,
  'koala': _noPose,
  'koyun': _koyunPose,
  'avokado': _avokadoPose,
  'kaktus': _kaktusPose,
  'baykus': _baykusPose,
  'civciv': _civcivPose,
  'rakun': _noPose,
  'kamp': _noPose,
  'okyanus': _okyanusPose,
};

const Map<String, CapPoseFn> fxLoopPoses = {
  'kopek': _kopekLoopPose,
  'penguen': _penguenLoopPose,
  'koala': _noPose,
  'koyun': _noPose,
  'avokado': _avokadoPose,
  'kaktus': _kaktusLoopPose,
  'baykus': _baykusPose,
  'civciv': _civcivPose,
  'rakun': _noPose,
  'kamp': _noPose,
  'okyanus': _okyanusLoopPose,
};

const _tau = math.pi * 2;

/// Ekranın üstünden taşmamak için tasarım koordinatında en küçük y (üst
/// çubuk + zoom/drop sonrası görünür alanın güvenli payı).
const _safeTop = 14.0;
double _top(double y) => y < _safeTop ? _safeTop : y;

double _sp(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
double _eo(double x) => Curves.easeOutCubic.transform(x.clamp(0.0, 1.0));
double _back(double x) => Curves.easeOutBack.transform(x.clamp(0.0, 1.0));
double _hump(double x) => math.sin(x.clamp(0.0, 1.0) * math.pi);
double _fract(double x) => x - x.floorToDouble();

/// Ömrünün başında/sonunda yumuşak belirip sönen 0..1 zarf (k: 0..1).
double _life(double k, [double inK = 0.12, double outK = 0.2]) =>
    math.min((k / inK).clamp(0.0, 1.0), ((1 - k) / outK).clamp(0.0, 1.0));

CapPose _noPose(CelebrationContext c) => CapPose.identity;

class _Fx {
  _Fx(this.cv, this.c);

  final Canvas cv;
  final CelebrationContext c;

  /// Zarf (giriş/çıkış ve döngü geçişi).
  double get a => c.alpha;

  /// Kapak pozu uygulanmamış kafa merkezi (kararlı çapa).
  Offset get head => c.capCenter - Offset(c.pose.dx, c.pose.dy);

  double get glassL => c.glass.left;
  double get glassR => c.glass.right;

  /// Giriş ya da döngü boyunca [cycles] tur atan faz (radyan).
  double ph(double cycles) =>
      c.looping ? c.loop * cycles * _tau : c.t * cycles * _tau;

  void spr(
    String name,
    Offset p,
    double w, {
    double? h,
    double rot = 0,
    double op = 1,
    bool flip = false,
    Alignment at = Alignment.center,
    Color? tint,
    BlendMode? blend,
  }) {
    final img = FxSprites.get(name);
    if (img == null) return;
    final o = (op * a).clamp(0.0, 1.0);
    if (o <= 0.01 || w <= 0.5) return;
    final hh = h ?? w * img.height / img.width;
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = true;
    if (blend != null) paint.blendMode = blend;
    if (tint == null) {
      paint.color = Color.fromARGB((o * 255).round(), 255, 255, 255);
    } else {
      paint.colorFilter = ColorFilter.mode(
        tint.withValues(alpha: o),
        BlendMode.modulate,
      );
    }
    cv.save();
    cv.translate(p.dx, p.dy);
    if (rot != 0) cv.rotate(rot);
    if (flip) cv.scale(-1, 1);
    cv.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(-w * (0.5 + at.x / 2), -hh * (0.5 + at.y / 2), w, hh),
      paint,
    );
    cv.restore();
  }

  void heart(Offset p, double s, int hex, double op) {
    final path = Path()
      ..moveTo(0, s * 0.35)
      ..cubicTo(-s * 1.1, -s * 0.35, -s * 0.55, -s * 1.05, 0, -s * 0.4)
      ..cubicTo(s * 0.55, -s * 1.05, s * 1.1, -s * 0.35, 0, s * 0.35)
      ..close();
    cv.save();
    cv.translate(p.dx, p.dy);
    cv.drawPath(path, c.paintOf(hex, op));
    cv.restore();
  }

  static final _text = <String, TextPainter>{};

  TextPainter _tp(String text, double op) {
    final bucket = (op.clamp(0.0, 1.0) * 12).round();
    return _text.putIfAbsent('$text|$bucket', () {
      return TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3B2A1A).withValues(alpha: bucket / 12),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    });
  }

  /// Koddan çizilen konuşma balonu. [tail]: kuyruğun yönü (-1 sol, 1 sağ).
  void bubble(String text, Offset center, double scale, double op, int tail) {
    final o = (op * a).clamp(0.0, 1.0);
    if (o <= 0.02 || scale <= 0.01) return;
    final tp = _tp(text, o);
    final w = tp.width + 28, h = tp.height + 16;
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          Radius.circular(h / 2),
        ),
      );
    final tailPath = Path()
      ..moveTo(tail * w * 0.14, h / 2 - 3)
      ..lineTo(tail * w * 0.40, h / 2 - 3)
      ..lineTo(tail * w * 0.50, h / 2 + 15)
      ..close();
    final shape = Path.combine(PathOperation.union, body, tailPath);
    cv.save();
    cv.translate(center.dx, center.dy);
    cv.scale(scale);
    cv.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF3B2A1A).withValues(alpha: o),
    );
    cv.drawPath(
      shape,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: o),
    );
    tp.paint(cv, Offset(-tp.width / 2, -tp.height / 2));
    cv.restore();
  }
}

// =============================================================== KÖPEK ====

const _pawTints = [0xFF6EB6FF, 0xFFFF8FB8, 0xFFFFD34D, 0xFF7BD66B];
const _boneHeldRot = 0.5;

CapPose _kopekPose(CelebrationContext c) {
  // Kemik düşerken baş (~%30) zıplar ve yakalar; <= %40 kafa yüksekliği.
  // Başın üstü ekran üst güvenli sınırını geçmesin (büyük kapakta kısalır).
  final room = (c.capTop.dy - _safeTop).clamp(10.0, 48.0);
  final hop = _hump(_sp(c.t, 0.22, 0.48));
  return CapPose(dy: -room * hop);
}

CapPose _kopekLoopPose(CelebrationContext c) =>
    CapPose(rotation: math.sin(c.loop * 2 * _tau) * 0.052); // +-3 derece

/// kopek_happy.png'de açık ağız ~ (0.53, 0.56); capCenter = (0.5, 0.5).
Offset _kopekMouth(CelebrationContext c) =>
    c.capCenter + Offset(c.capWidth * 0.03, c.capWidth * 0.06);

void _boneInMouth(_Fx f, double op) {
  f.spr(
    'kopek_bone',
    _kopekMouth(f.c),
    f.c.capWidth * 0.55,
    rot: _boneHeldRot * 0.7,
    op: op,
  );
}

List<Offset> _pawSpots(_Fx f) {
  final l = f.glassL - 34, r = f.glassR + 34;
  return [
    Offset(l, 432),
    Offset(r, 392),
    Offset(l - 6, 340),
    Offset(r + 6, 300),
    Offset(l - 2, 248),
    Offset(r + 2, 208),
    Offset(l - 10, 196),
  ];
}

void _kopek(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  final spots = _pawSpots(f);
  final base = f.head;
  final bubblePos = Offset(base.dx + 92, _top(base.dy - 66));
  if (c.reduceMotion) {
    for (var i = 0; i < 4; i++) {
      f.spr(
        'kopek_paw',
        spots[i],
        40,
        rot: i.isEven ? -0.3 : 0.3,
        tint: Color(_pawTints[i % 4]),
      );
    }
    _boneInMouth(f, 1);
    f.bubble('HAV HAV!', bubblePos, 1, 1, -1);
    return;
  }
  final t = c.t;
  // Dönen kemik düşer, ağza girince kalır.
  const tc = 0.35;
  if (t >= tc) {
    _boneInMouth(f, 1);
  } else if (t > 0.02) {
    final k = _sp(t, 0.02, tc);
    final target = _kopekMouth(c);
    final start = Offset(target.dx + 18, base.dy - 200);
    final pos = Offset.lerp(start, target, k * k)!;
    f.spr(
      'kopek_bone',
      pos,
      62,
      rot: _boneHeldRot - (1 - k) * 2 * _tau,
      op: _sp(t, 0.02, 0.08),
    );
  }
  // Pati izleri sırayla.
  for (var i = 0; i < spots.length; i++) {
    final s = 0.40 + i * 0.065;
    final k = _sp(t, s, s + 0.12);
    if (k <= 0) continue;
    f.spr(
      'kopek_paw',
      spots[i],
      40 * _back(k),
      rot: i.isEven ? -0.3 : 0.3,
      tint: Color(_pawTints[i % 4]),
    );
  }
  // HAV HAV! balonu.
  final bk = _sp(t, 0.30, 0.38);
  if (bk > 0) {
    f.bubble(
      'HAV HAV!',
      bubblePos,
      _back(bk) * (1 + 0.03 * math.sin(t * 40)),
      1,
      -1,
    );
  }
}

void _kopekLoop(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  _boneInMouth(f, 1);
  final base = f.head;
  final k = _sp(c.loop, 0.15, 0.75);
  if (k <= 0 || k >= 1) return;
  if (c.loopCount.isEven) {
    f.heart(
      base + Offset(78 + 8 * math.sin(k * 6), -10 - 70 * _eo(k)),
      9 + 5 * _hump(k),
      0xFFFF6B8E,
      _life(k),
    );
  } else {
    final left = (c.loopCount ~/ 2).isEven;
    final p = Offset(
      left ? f.glassL - 36 : f.glassR + 36,
      300 + (c.loopCount % 5) * 22.0,
    );
    f.spr(
      'kopek_paw',
      p,
      38 * _back(_sp(k, 0, 0.3)),
      rot: left ? -0.3 : 0.3,
      op: _life(k, 0.2, 0.3),
      tint: Color(_pawTints[c.loopCount % 4]),
    );
  }
}

// ============================================================== PENGUEN ===

CapPose _penguenPose(CelebrationContext c) {
  final k = _sp(c.t, 0.35, 1);
  return CapPose(rotation: math.sin(k * 2 * _tau) * 0.04);
}

CapPose _penguenLoopPose(CelebrationContext c) => CapPose(
  rotation: math.sin(c.loop * 3 * _tau) * 0.05,
  dx: math.sin(c.loop * 3 * _tau) * 3,
);

void _aurora(_Fx f, double op, double wave) {
  f.spr(
    'penguen_aurora',
    Offset(340 + 12 * math.sin(wave), 62 + 5 * math.sin(wave * 1.7)),
    540,
    h: 100 + 8 * math.sin(wave * 1.3),
    op: op * (0.82 + 0.1 * math.sin(wave * 1.1)),
  );
}

void _snow(_Fx f, int n, double op, {double from = 0}) {
  if (!f.c.looping && f.c.t < from) return;
  for (var i = 0; i < n; i++) {
    final r = f.c.rand(i, 21);
    // Giriş ve döngüde tam 1 tur: tur sınırında süreklilik korunur.
    final k = _fract((f.c.looping ? f.c.loop : f.c.t) + r);
    final x = 130 + 420 * f.c.rand(i, 22) + math.sin(k * 6 + i) * 14;
    final y = 24 + 470 * k;
    f.spr(
      'penguen_snowflake',
      Offset(x, y),
      12 + 14 * f.c.rand(i, 23),
      rot: k * 4 + i,
      op: op * _life(k, 0.1, 0.15),
    );
  }
}

void _penguinSlide(_Fx f, double k, bool left, double y, double endX) {
  final startX = left ? 96.0 : 584.0;
  final x = ui.lerpDouble(startX, endX, _eo(k))!;
  f.spr(
    'penguen_mini_slide',
    Offset(x, y + math.sin(k * 14) * 2),
    78,
    flip: !left,
    op: _life(k, 0.12, 0.3),
  );
}

void _penguen(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  final endL = f.glassL - 46, endR = f.glassR + 46;
  const lanesL = [345.0, 405.0, 455.0], lanesR = [375.0, 430.0, 340.0];
  if (c.reduceMotion) {
    _aurora(f, 1, 0);
    f.spr('penguen_mini_slide', Offset(endL - 30, 420), 78);
    f.spr('penguen_mini_slide', Offset(endR + 30, 400), 78, flip: true);
    for (var i = 0; i < 6; i++) {
      f.spr(
        'penguen_snowflake',
        Offset(140 + 400 * c.rand(i, 22), 90 + 380 * c.rand(i, 24)),
        14 + 12 * c.rand(i, 23),
        rot: i * 0.7,
      );
    }
    return;
  }
  final t = c.t;
  _aurora(f, _eo(_sp(t, 0.02, 0.26)), f.ph(1.5));
  for (var i = 0; i < 3; i++) {
    final s = 0.14 + i * 0.16;
    final k = _sp(t, s, s + 0.38);
    if (k > 0 && k < 1) _penguinSlide(f, k, true, lanesL[i], endL);
    final s2 = s + 0.06;
    final k2 = _sp(t, s2, s2 + 0.38);
    if (k2 > 0 && k2 < 1) _penguinSlide(f, k2, false, lanesR[i], endR);
  }
  _snow(f, 16, 0.95, from: 0.08);
}

void _penguenLoop(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  _aurora(f, 0.8, f.ph(1));
  _snow(f, 7, 0.85);
}

// ================================================================ KOALA ===

void _leaf(_Fx f, int i, double k) {
  final x = 140 + 400 * f.c.rand(i, 3) + math.sin(k * 5 + i * 1.7) * 30;
  final y = _top(10 + 490 * (k * 0.85 + 0.15 * k * k));
  final dir = i.isEven ? 1.0 : -1.0;
  f.spr(
    i.isEven ? 'koala_leaf_1' : 'koala_leaf_2',
    Offset(x, y),
    34 + 16 * f.c.rand(i, 4),
    rot: dir * k * (5 + 4 * f.c.rand(i, 5)) + i,
    op: _life(k, 0.1, 0.15),
  );
}

void _koala(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  if (c.reduceMotion) {
    for (var i = 0; i < 7; i++) {
      final x = 150 + 360 * c.rand(i, 3);
      final y = 40 + 400 * c.rand(i, 6);
      f.spr(
        i.isEven ? 'koala_leaf_1' : 'koala_leaf_2',
        Offset(x, y),
        40 + 10 * c.rand(i, 4),
        rot: i * 1.3,
      );
    }
    return;
  }
  for (var i = 0; i < 13; i++) {
    final s = 0.02 + 0.45 * c.rand(i, 7);
    final k = _sp(c.t, s, s + 0.52);
    if (k > 0 && k < 1) _leaf(f, i, k);
  }
}

void _koalaLoop(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  for (var i = 0; i < 4; i++) {
    _leaf(f, i + 20 * (c.loopCount % 3), _fract(c.loop + i / 4));
  }
}

// ================================================================ KOYUN ===

CapPose _koyunPose(CelebrationContext c) {
  final k = _sp(c.t, 0.04, 0.2);
  return CapPose(dy: -8 * _hump(k), scale: 1 + 0.03 * _hump(k));
}

void _puffBurst(_Fx f, double t) {
  final o = f.head;
  for (var i = 0; i < 6; i++) {
    final s = 0.04 + i * 0.03;
    final k = _sp(t, s, s + 0.34);
    if (k <= 0 || k >= 1) continue;
    final ang = -math.pi * (0.08 + 0.84 * i / 5);
    final d = 24 + 78 * _eo(k);
    final p0 = o + Offset(math.cos(ang) * d * 1.15, math.sin(ang) * d);
    final p = Offset(p0.dx, math.max(p0.dy, _safeTop + 24));
    f.spr(
      'koyun_wool_puff',
      p,
      22 + 34 * _back(k * 1.2),
      rot: i - 2.5 + k,
      op: _life(k, 0.1, 0.45),
    );
  }
}

double _fenceX(_Fx f) => f.glassL - 68;

void _fence(_Fx f, double op) {
  f.spr(
    'koyun_fence',
    Offset(_fenceX(f), 468),
    104,
    at: Alignment.bottomCenter,
    op: op,
  );
}

void _sheepJump(_Fx f, double k) {
  if (k <= 0 || k >= 1) return;
  final x = _fenceX(f) - 80 + 160 * k;
  final y = 440 - 100 * _hump(k);
  f.spr(
    'koyun_mini_jump',
    Offset(x, y),
    58,
    rot: -math.cos(k * math.pi) * 0.45,
    op: _life(k, 0.1, 0.14),
  );
}

void _koyun(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  final bubblePos = Offset(f.head.dx + 100, _top(f.head.dy - 66));
  if (c.reduceMotion) {
    for (var i = 0; i < 4; i++) {
      final ang = -math.pi * (0.15 + 0.7 * i / 3);
      f.spr(
        'koyun_wool_puff',
        f.head + Offset(math.cos(ang) * 84, math.sin(ang) * 70),
        40,
      );
    }
    f.bubble('Mee!', bubblePos, 1, 1, -1);
    _fence(f, 1);
    f.spr('koyun_mini_jump', Offset(_fenceX(f), 345), 58);
    return;
  }
  final t = c.t;
  _puffBurst(f, t);
  final bk = _sp(t, 0.22, 0.34);
  if (bk > 0) f.bubble('Mee!', bubblePos, _back(bk), 1, -1);
  _fence(f, _sp(t, 0.24, 0.38));
  for (var i = 0; i < 3; i++) {
    final s = 0.36 + i * 0.17;
    _sheepJump(f, _sp(t, s, s + 0.26));
  }
}

void _koyunLoop(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  _fence(f, 0.9);
  _sheepJump(f, _sp(c.loop, 0.12, 0.62));
  final o = f.head;
  for (var i = 0; i < 3; i++) {
    final s = 0.1 + i * 0.22;
    final k = _sp(c.loop, s, s + 0.4);
    if (k <= 0 || k >= 1) continue;
    final side = (i + c.loopCount).isEven ? 1.0 : -1.0;
    f.spr(
      'koyun_wool_puff',
      Offset(
        o.dx + side * (46 + 18 * i) + math.sin(k * 5) * 8,
        math.max(o.dy - 20 - 90 * k, _safeTop + 16),
      ),
      20.0 + 6 * i,
      rot: k * 2,
      op: _life(k, 0.2, 0.4) * 0.9,
    );
  }
}

// ================================================================ KAKTÜS ===

CapPose _kaktusPose(CelebrationContext c) {
  final swell = _hump(_sp(c.t, 0.28, 0.6));
  return CapPose(scale: 1 + 0.07 * swell);
}

CapPose _kaktusLoopPose(CelebrationContext c) =>
    CapPose(scale: 1 + 0.02 * math.sin(c.loop * _tau));

Offset _kFlowerPos(_Fx f) {
  final p = f.c.capTop + const Offset(0, 16);
  return Offset(p.dx, math.max(p.dy, _safeTop + 28));
}

void _rainbow(_Fx f, double op) {
  f.spr(
    'kaktus_rainbow',
    Offset(f.head.dx, f.head.dy + 10),
    330,
    h: 112,
    at: Alignment.bottomCenter,
    op: op,
  );
}

void _kaktus(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  final h = f.head;
  final cloudY = (c.capTop.dy + 6).clamp(62.0, 100.0);
  if (c.reduceMotion) {
    _rainbow(f, 0.6);
    f.spr('kaktus_cloud', Offset(h.dx - 85, cloudY), 130);
    f.spr('kaktus_raindrop', Offset(h.dx - 100, cloudY + 70), 16);
    f.spr('kaktus_raindrop', Offset(h.dx - 66, cloudY + 92), 16);
    f.spr('kaktus_flower', _kFlowerPos(f), 54);
    for (var i = 0; i < 5; i++) {
      final a = -math.pi * (0.15 + 0.7 * i / 4);
      f.spr(
        'kaktus_petal',
        _kFlowerPos(f) + Offset(math.cos(a) * 54, math.sin(a) * 46),
        20,
        rot: a + 1.2,
      );
    }
    return;
  }
  final t = c.t;
  _rainbow(f, 0.6 * _eo(_sp(t, 0.34, 0.64)));
  // Bulut gelir, damlalar düşer.
  final ck = _sp(t, 0.02, 0.24);
  if (ck > 0) {
    f.spr(
      'kaktus_cloud',
      Offset(
        h.dx + ui.lerpDouble(-210, -85, _eo(ck))!,
        cloudY + 2 * math.sin(f.ph(3)),
      ),
      130,
      op: _eo(ck),
    );
  }
  for (var i = 0; i < 6; i++) {
    final s = 0.2 + i * 0.045;
    final k = _sp(t, s, s + 0.22);
    if (k <= 0 || k >= 1) continue;
    final x = h.dx - 128 + 16 * i + (i.isEven ? 0 : 6);
    final y = cloudY + 42 + (h.dy + 30 - cloudY - 42) * k * k;
    f.spr('kaktus_raindrop', Offset(x, y), 15, op: _life(k, 0.1, 0.2));
  }
  // Çiçek açar, yapraklar taç gibi saçılır.
  final fk = _sp(t, 0.5, 0.68);
  final fp = _kFlowerPos(f);
  if (fk > 0) {
    f.spr(
      'kaktus_flower',
      fp,
      54 * _back(fk),
      rot: (1 - _back(fk)) * -1.6,
      op: _sp(fk, 0, 0.3),
    );
  }
  for (var i = 0; i < 7; i++) {
    final s = 0.62 + i * 0.012;
    final k = _sp(t, s, s + 0.3);
    if (k <= 0 || k >= 1) continue;
    final a = -math.pi * (0.1 + 0.8 * i / 6);
    final d = 26 + 54 * _eo(k);
    final pp =
        fp + Offset(math.cos(a) * d * 1.15, math.sin(a) * d + 34 * k * k);
    f.spr(
      'kaktus_petal',
      Offset(pp.dx, _top(pp.dy)),
      20,
      rot: a + 1.2 + k * 3,
      op: _life(k, 0.1, 0.45),
    );
  }
}

void _kaktusLoop(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  _rainbow(f, 0.38);
  final fp = _kFlowerPos(f);
  final breathe = 1 + 0.07 * math.sin(c.loop * _tau);
  f.spr('kaktus_flower', fp, 54 * breathe, rot: math.sin(c.loop * _tau) * 0.05);
  final k = _sp(c.loop, 0.15, 0.7);
  if (k <= 0 || k >= 1) return;
  if (c.loopCount.isEven) {
    f.spr(
      'kaktus_raindrop',
      Offset(f.head.dx - 72, _top(f.head.dy - 100 + 120 * k * k)),
      15,
      op: _life(k, 0.15, 0.2),
    );
  } else {
    f.spr(
      'kaktus_petal',
      fp + Offset(34 * k + math.sin(k * 7) * 8, 10 + 90 * k),
      20,
      rot: k * 4,
      op: _life(k, 0.15, 0.3),
    );
  }
}
