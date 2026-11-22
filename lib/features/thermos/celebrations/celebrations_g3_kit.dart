import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../thermos_painter.dart';
import 'celebration_context.dart';

// Grup 3 ortak cizim ve zamanlama yardimcilari.

typedef Ctx = CelebrationContext;

const double tau = math.pi * 2;

/// Kapak olcegi (tombulda kucultme x poz olcegi).
double capK(Ctx c) => (c.chubby ? chubbyCapScale : 1.0) * c.pose.scale;

/// Sekle gore ham kapak koordinati -> tasarim koordinati (poz uygulanmis).
Offset at(Ctx c, double cx, double cy, double sx, double sy) =>
    c.chubby ? c.capPt(cx, cy) : c.capPt(sx, sy);

/// Ham kapak vektorunu (olcek + poz donusu) tasarim vektorune cevirir.
Offset vec(Ctx c, double x, double y) {
  final k = capK(c);
  final r = c.pose.rotation, co = math.cos(r), si = math.sin(r);
  return Offset((x * co - y * si) * k, (x * si + y * co) * k);
}

double clamp01(double x) => x.clamp(0.0, 1.0);

/// 0..1 -> 0..1..0 pencere (a..b arasinda tepe).
double win(Ctx c, double a, double b) => Ctx.pulse(c.span(a, b));

double frac(double x) => x - x.floorToDouble();

Paint fillP(Ctx c, int hex, [double op = 1]) => c.paintOf(hex, op);

Paint lineP(Ctx c, int hex, double w, [double op = 1]) => c.paintOf(hex, op)
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Paint glowP(Ctx c, int hex, double blur, [double op = 1]) =>
    c.paintOf(hex, op)..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

void xf(Canvas cv, Offset p, double ang, double s, void Function() draw) {
  cv.save();
  cv.translate(p.dx, p.dy);
  if (ang != 0) cv.rotate(ang);
  if (s != 1) cv.scale(s);
  draw();
  cv.restore();
}

/// Dort uclu parlama yildizi.
void sparkle(Canvas cv, Offset p, double r, Paint paint) {
  if (r <= 0.2) return;
  final path = Path();
  for (var i = 0; i < 8; i++) {
    final a = i * math.pi / 4 - math.pi / 2;
    final rr = i.isEven ? r : r * 0.26;
    final x = p.dx + math.cos(a) * rr, y = p.dy + math.sin(a) * rr;
    i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
  }
  cv.drawPath(path..close(), paint);
}

Path heartPath(Offset c, double s) {
  return Path()
    ..moveTo(c.dx, c.dy + s * 0.95)
    ..cubicTo(
      c.dx - s * 1.7,
      c.dy - s * 0.1,
      c.dx - s * 0.95,
      c.dy - s * 1.3,
      c.dx,
      c.dy - s * 0.45,
    )
    ..cubicTo(
      c.dx + s * 0.95,
      c.dy - s * 1.3,
      c.dx + s * 1.7,
      c.dy - s * 0.1,
      c.dx,
      c.dy + s * 0.95,
    )
    ..close();
}

/// Ucu [ang] yonune bakan damla.
void teardrop(Canvas cv, Offset p, double r, double ang, Paint paint) {
  if (r <= 0.15) return;
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(ang + math.pi / 2);
  final path = Path()
    ..moveTo(0, -r * 1.9)
    ..quadraticBezierTo(r * 1.15, -r * 0.1, 0, r)
    ..quadraticBezierTo(-r * 1.15, -r * 0.1, 0, -r * 1.9)
    ..close();
  cv.drawPath(path, paint);
  cv.restore();
}

/// Su damlasi: damla + beyaz parlak nokta.
void waterDrop(
  Ctx c,
  Canvas cv,
  Offset p,
  double r,
  double ang,
  double op, {
  int base = 0x4BA3E3,
  int light = 0xFFFFFF,
}) {
  teardrop(cv, p, r, ang, fillP(c, base, op));
  cv.drawCircle(
    p + Offset(-r * 0.25, -r * 0.1),
    r * 0.3,
    fillP(c, light, op * 0.85),
  );
}

void bubble(
  Ctx c,
  Canvas cv,
  Offset p,
  double r,
  double op, {
  int tint = 0xBFE6FA,
}) {
  cv.drawCircle(p, r, fillP(c, tint, op * 0.22));
  cv.drawCircle(p, r, lineP(c, 0xFFFFFF, math.max(1.0, r * 0.14), op * 0.9));
  cv.drawCircle(
    p + Offset(-r * 0.35, -r * 0.35),
    r * 0.22,
    fillP(c, 0xFFFFFF, op * 0.95),
  );
}

void heart(
  Ctx c,
  Canvas cv,
  Offset p,
  double s,
  int hex,
  double op, {
  double rot = 0,
}) {
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  cv.drawPath(heartPath(Offset.zero, s), fillP(c, hex, op));
  cv.restore();
}

void snowflake(Ctx c, Canvas cv, Offset p, double r, double rot, double op) {
  final paint = lineP(c, 0xFFFFFF, math.max(1.0, r * 0.2), op);
  final tip = lineP(c, 0xDDF2FC, math.max(0.8, r * 0.14), op);
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  for (var i = 0; i < 6; i++) {
    cv.save();
    cv.rotate(i * math.pi / 3);
    cv.drawLine(Offset.zero, Offset(0, -r), paint);
    cv.drawLine(Offset(0, -r * 0.55), Offset(-r * 0.3, -r * 0.8), tip);
    cv.drawLine(Offset(0, -r * 0.55), Offset(r * 0.3, -r * 0.8), tip);
    cv.restore();
  }
  cv.drawCircle(Offset.zero, r * 0.18, fillP(c, 0xFFFFFF, op));
  cv.restore();
}

/// Tuy: x ekseni boyunca [len] uzunlukta.
void feather(
  Ctx c,
  Canvas cv,
  Offset p,
  double len,
  double ang,
  int hex,
  double op, {
  int vein = 0x5E3F26,
}) {
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(ang);
  final w = len * 0.28;
  final path = Path()
    ..moveTo(-len * 0.5, 0)
    ..quadraticBezierTo(-len * 0.1, -w * 1.5, len * 0.5, 0)
    ..quadraticBezierTo(-len * 0.1, w * 1.5, -len * 0.5, 0)
    ..close();
  cv.drawPath(path, fillP(c, hex, op));
  cv.drawLine(
    Offset(-len * 0.58, 0),
    Offset(len * 0.42, 0),
    lineP(c, vein, math.max(1.0, len * 0.05), op * 0.8),
  );
  for (var i = -2; i <= 2; i++) {
    if (i == 0) continue;
    final x = i * len * 0.12;
    cv.drawLine(
      Offset(x, 0),
      Offset(x + len * 0.1, i.sign * w * (1.1 - i.abs() * 0.18)),
      lineP(c, vein, math.max(0.7, len * 0.025), op * 0.5),
    );
  }
  cv.restore();
}

void butterfly(
  Ctx c,
  Canvas cv,
  Offset p,
  double s,
  double flap,
  double rot,
  int wing,
  int wing2,
  double op,
) {
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  final f = 0.18 + 0.82 * flap.abs();
  for (final d in const [-1.0, 1.0]) {
    cv.save();
    cv.scale(d * f, 1);
    cv.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.62, -s * 0.45),
        width: s * 1.3,
        height: s * 1.0,
      ),
      fillP(c, wing, op),
    );
    cv.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.45, s * 0.45),
        width: s * 0.85,
        height: s * 0.75,
      ),
      fillP(c, wing2, op),
    );
    cv.drawCircle(
      Offset(s * 0.66, -s * 0.5),
      s * 0.16,
      fillP(c, 0xFFFFFF, op * 0.8),
    );
    cv.restore();
  }
  cv.drawOval(
    Rect.fromCenter(center: Offset.zero, width: s * 0.2, height: s * 1.1),
    fillP(c, 0x4A3222, op),
  );
  cv.drawLine(
    Offset(0, -s * 0.5),
    Offset(-s * 0.25, -s * 0.8),
    lineP(c, 0x4A3222, 1.1, op),
  );
  cv.drawLine(
    Offset(0, -s * 0.5),
    Offset(s * 0.25, -s * 0.8),
    lineP(c, 0x4A3222, 1.1, op),
  );
  cv.restore();
}

void banana(Ctx c, Canvas cv, Offset p, double s, double rot, double op) {
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  cv.scale(s);
  final path = Path()
    ..moveTo(-13, -4)
    ..quadraticBezierTo(0, 14, 13, -7)
    ..quadraticBezierTo(2, 4, -13, -4)
    ..close();
  cv.drawPath(path, fillP(c, 0xFFD84A, op));
  cv.drawPath(
    Path()
      ..moveTo(-10, -2)
      ..quadraticBezierTo(0, 8, 9, -3),
    lineP(c, 0xFFF1A0, 1.6, op * 0.9),
  );
  cv.drawPath(path, lineP(c, 0x9A6B1E, 1.3, op * 0.9));
  cv.drawCircle(const Offset(-13, -4), 2.2, fillP(c, 0x5A3A1E, op));
  cv.drawCircle(const Offset(13, -7), 2.0, fillP(c, 0x5A3A1E, op));
  cv.restore();
}

void apple(Ctx c, Canvas cv, Offset p, double r, double op) {
  cv.drawCircle(p, r, fillP(c, 0xD0392B, op));
  cv.drawCircle(
    p + Offset(r * 0.3, r * 0.2),
    r * 0.7,
    fillP(c, 0xB02A20, op * 0.5),
  );
  cv.drawCircle(
    p + Offset(-r * 0.35, -r * 0.35),
    r * 0.26,
    fillP(c, 0xF2A39A, op * 0.85),
  );
  cv.drawLine(
    p + Offset(0, -r),
    p + Offset(r * 0.3, -r * 1.5),
    lineP(c, 0x5A3A22, r * 0.2, op),
  );
  xf(cv, p + Offset(r * 0.7, -r * 1.2), -0.45, 1, () {
    cv.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 0.95, height: r * 0.5),
      fillP(c, 0x6FA85A, op),
    );
  });
}

void acorn(Ctx c, Canvas cv, Offset p, double r, double rot, double op) {
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  cv.drawOval(
    Rect.fromCenter(
      center: Offset(0, r * 0.15),
      width: r * 1.5,
      height: r * 1.9,
    ),
    fillP(c, 0xD9A05B, op),
  );
  cv.drawOval(
    Rect.fromCenter(
      center: Offset(-r * 0.2, r * 0.3),
      width: r * 0.4,
      height: r * 0.9,
    ),
    fillP(c, 0xF0C58A, op * 0.8),
  );
  cv.drawArc(
    Rect.fromCenter(
      center: Offset(0, -r * 0.35),
      width: r * 1.9,
      height: r * 1.3,
    ),
    math.pi,
    math.pi,
    true,
    fillP(c, 0x7A4A22, op),
  );
  cv.drawLine(
    Offset(0, -r * 1.0),
    Offset(r * 0.15, -r * 1.35),
    lineP(c, 0x5A3A22, r * 0.2, op),
  );
  cv.restore();
}

/// Donen para: [spin] radyan, en/boy daralir.
void coin(Ctx c, Canvas cv, Offset p, double r, double spin, double op) {
  final sx = math.max(0.18, math.cos(spin).abs());
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.scale(sx, 1);
  cv.drawCircle(Offset.zero, r * 1.0, fillP(c, 0xC99A2E, op));
  cv.drawCircle(Offset.zero, r * 0.82, fillP(c, 0xF2C94C, op));
  cv.drawCircle(Offset.zero, r * 0.52, lineP(c, 0xC99A2E, r * 0.16, op * 0.8));
  cv.drawLine(
    Offset(-r * 0.4, r * 0.5),
    Offset(r * 0.3, -r * 0.55),
    lineP(c, 0xFFF3B0, r * 0.2, op * 0.9),
  );
  cv.restore();
}

void fish(
  Ctx c,
  Canvas cv,
  Offset p,
  double s,
  double rot,
  double op, {
  int body = 0xF2994A,
  int belly = 0xFFD7A8,
}) {
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  cv.scale(s);
  cv.drawPath(
    Path()
      ..moveTo(-8, 0)
      ..lineTo(-18, -8)
      ..lineTo(-16, 0)
      ..lineTo(-18, 8)
      ..close(),
    fillP(c, body, op),
  );
  cv.drawOval(
    Rect.fromCenter(center: Offset.zero, width: 28, height: 15),
    fillP(c, body, op),
  );
  cv.drawOval(
    Rect.fromCenter(center: const Offset(1, 3), width: 20, height: 7),
    fillP(c, belly, op * 0.9),
  );
  cv.drawCircle(const Offset(7, -2), 2.1, fillP(c, 0x24262C, op));
  cv.drawCircle(const Offset(7.6, -2.6), 0.7, fillP(c, 0xFFFFFF, op));
  cv.drawLine(
    const Offset(-1, -6),
    const Offset(-1, 6),
    lineP(c, 0xD97A22, 1.2, op * 0.7),
  );
  cv.restore();
}

/// Kucuk "puf" bulutu (3 daire).
void puff(Ctx c, Canvas cv, Offset p, double r, int hex, double op) {
  cv.drawCircle(p, r, fillP(c, hex, op));
  cv.drawCircle(p + Offset(-r * 0.7, r * 0.2), r * 0.7, fillP(c, hex, op));
  cv.drawCircle(p + Offset(r * 0.7, r * 0.15), r * 0.75, fillP(c, hex, op));
}

/// Basit yerlesim: (aci, yaricap) cevresinde kapak merkezine gore konum.
Offset around(Offset center, double ang, double rx, double ry) =>
    center + Offset(math.cos(ang) * rx, math.sin(ang) * ry);
