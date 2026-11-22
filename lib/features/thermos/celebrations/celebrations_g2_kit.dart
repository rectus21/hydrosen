import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../celebration_style.dart';
import 'celebration_context.dart';

const g2Tau = math.pi * 2;

/// Grup 2 imza kutlamalari icin ortak cizim kiti: kapak cizimindeki ham
/// koordinati tasarim koordinatina ceviren [at] ve kucuk cizim yardimcilari.
class G2 {
  G2(this.canvas, this.c);

  final Canvas canvas;
  final CelebrationContext c;

  bool get chubby => c.chubby;

  /// Efekt olcegi: tombul kapak 0,72 kuculdugu, ince kapak daha dar oldugu
  /// icin boyutlar buna gore olceklenir.
  double get u => chubby ? 1.0 : 0.84;

  /// Saniye cinsinden zaman (hareket azaltilmisken t sabit oldugundan sabit).
  double get time => c.elapsed;
  double get t => c.t;
  bool get still => c.reduceMotion;

  /// Basta hizla beliren olcek zarfi (0..1).
  double get pop => CelebrationContext.easeOut(c.span(0, 0.12));

  double wave(double hz, [double phase = 0]) =>
      math.sin(time * g2Tau * hz + phase);

  /// Kapak ham koordinati; tombul ve ince icin ayri verilir.
  Offset at(double cx, double cy, double sx, double sy) =>
      chubby ? c.capPt(cx, cy) : c.capPt(sx, sy);

  Paint f(int hex, [double op = 1]) => c.paintOf(hex, op);

  Paint s(int hex, double w, [double op = 1]) => c.paintOf(hex, op)
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void oval(Offset p, double rx, double ry, Paint paint, [double rot = 0]) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    if (rot != 0) canvas.rotate(rot);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      paint,
    );
    canvas.restore();
  }

  void circle(Offset p, double r, int hex, [double op = 1]) =>
      canvas.drawCircle(p, r, f(hex, op));

  void line(Offset a, Offset b, double w, int hex, [double op = 1]) =>
      canvas.drawLine(a, b, s(hex, w, op));

  /// Koyu konturlu kalin cubuk.
  void capsule(
    Offset a,
    Offset b,
    double w,
    int hex,
    int dark, [
    double op = 1,
  ]) {
    line(a, b, w + 2.6 * u, dark, op);
    line(a, b, w, hex, op);
  }

  static Offset cubic(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final m = 1 - t;
    return p0 * (m * m * m) +
        p1 * (3 * m * m * t) +
        p2 * (3 * m * t * t) +
        p3 * (t * t * t);
  }

  /// [pts] omurgasi boyunca [half](0..1) yaricapli dolgu seridi.
  void taper(
    List<Offset> pts,
    double Function(double f) half,
    int hex, {
    double from = 0,
    double to = 1,
    double op = 1,
    double grow = 0,
  }) {
    final n = pts.length;
    final left = <Offset>[], right = <Offset>[];
    for (var i = 0; i < n; i++) {
      final f = i / (n - 1);
      if (f < from - 1e-6 || f > to + 1e-6) continue;
      final a = pts[math.max(i - 1, 0)], b = pts[math.min(i + 1, n - 1)];
      final d = b - a;
      final len = d.distance;
      if (len == 0) continue;
      final nrm = Offset(-d.dy / len, d.dx / len);
      final w = half(f) + grow;
      left.add(pts[i] + nrm * w);
      right.add(pts[i] - nrm * w);
    }
    if (left.length < 2) return;
    final path = Path()..moveTo(left.first.dx, left.first.dy);
    for (final p in left.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    for (final p in right.reversed) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, f(hex, op));
    // Uclari yuvarlat.
    final w0 = half(from) + grow, w1 = half(to) + grow;
    if (from <= 0 && w0 > 0) canvas.drawCircle(pts.first, w0, f(hex, op));
    if (to >= 1 && w1 > 0) canvas.drawCircle(pts.last, w1, f(hex, op));
  }

  /// Tema stilindeki ya da verilen genel parcacik efektini arka plana cizer.
  void ambient(CelebrationKind kind, List<int> colors) =>
      c.kind(canvas, kind, colors);

  /// Yerel (rotasyonlu/olcekli) cizim.
  void local(Offset p, double rot, double scale, void Function() draw) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    if (rot != 0) canvas.rotate(rot);
    if (scale != 1) canvas.scale(scale);
    draw();
    canvas.restore();
  }

  /// Pati: [ang] kolun yonu (radyan), ucta avuc ici ve uc parmak.
  void paw(Offset p, double ang, int hex, int dark, int pad) {
    local(p, ang + math.pi / 2, u, () {
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 30, height: 26),
        f(dark),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 25, height: 21),
        f(hex),
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 2.5), width: 13, height: 10),
        f(pad),
      );
      for (final x in const [-7.0, 0.0, 7.0]) {
        final y = x == 0 ? -6.0 : -4.2;
        canvas.drawCircle(Offset(x, y), 2.6, f(pad));
      }
    });
  }

  /// Kucuk 4 kollu parilti.
  void sparkle(Offset p, double r, int hex, [double op = 1]) {
    final q = r * 0.24;
    final path = Path()
      ..moveTo(p.dx, p.dy - r)
      ..quadraticBezierTo(p.dx + q, p.dy - q, p.dx + r, p.dy)
      ..quadraticBezierTo(p.dx + q, p.dy + q, p.dx, p.dy + r)
      ..quadraticBezierTo(p.dx - q, p.dy + q, p.dx - r, p.dy)
      ..quadraticBezierTo(p.dx - q, p.dy - q, p.dx, p.dy - r)
      ..close();
    canvas.drawPath(path, f(hex, op));
  }

  /// Almond yaprak (ucu [ang] yonunde), merkez [p].
  void leaf(
    Offset p,
    double r,
    double ang,
    int hex,
    int vein, [
    double op = 1,
  ]) {
    local(p, ang, 1, () {
      final path = Path()
        ..moveTo(-r, 0)
        ..quadraticBezierTo(0, -r * 0.7, r, 0)
        ..quadraticBezierTo(0, r * 0.7, -r, 0)
        ..close();
      canvas.drawPath(path, f(hex, op));
      canvas.drawLine(Offset(-r, 0), Offset(r * 0.8, 0), s(vein, r * 0.1, op));
    });
  }
}
