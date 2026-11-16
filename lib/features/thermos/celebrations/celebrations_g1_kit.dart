import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../thermos_painter.dart';
import 'celebration_context.dart';

// Grup 1 imza kutlamalari icin ortak yardimcilar (parcacik yayici, sekiller).

const tau = math.pi * 2;

/// Kapak genisligine gore boyut katsayisi (tombul ~1.0, ince ~0.8).
double szOf(CelebrationContext ctx) =>
    (ctx.capWidth / 138).clamp(0.72, 1.15).toDouble();

/// Yayici durumu: [p] 0..1 omur ilerlemesi (olu ise -1), [cycle] kacinci tur.
class Em {
  const Em(this.p, this.cycle);
  static const dead = Em(-1, 0);
  final double p;
  final int cycle;
  bool get live => p >= 0;
}

/// Surekli (dongulu) parcacik yayici. Parcacik [i] / [n], [start] aninda
/// sirayla dogar, her [period] saniye-oranda yeniden dogar; [end]'den sonra
/// yeni tur baslamaz. Hareketsizde sabit, dagilmis fazlar verir.
Em emit(
  CelebrationContext ctx,
  int i,
  int n, {
  double period = 0.6,
  double start = 0,
  double end = 0.88,
}) {
  if (ctx.reduceMotion) return Em((i + 0.5) / n, 0);
  final x = (ctx.t - start) / period - i / n;
  if (x < 0) return Em.dead;
  final c = x.floor();
  if (start + (c + i / n) * period > end) return Em.dead;
  return Em(x - c, c);
}

/// Parcacik+tur basina sabit rastgele.
double rr(CelebrationContext ctx, int i, Em e, int salt) =>
    ctx.rand(i + e.cycle * 37, salt);

/// Kapak ham koordinatinda cizim (pose + tombul kucultme otomatik).
void inCap(Canvas canvas, CelebrationContext ctx, void Function() draw) {
  final p = ctx.pose;
  canvas.save();
  if (!p.isIdentity) {
    final pivotY = ctx.chubby ? 208.0 : 178.0;
    canvas.translate(340 + p.dx, pivotY + p.dy);
    canvas.rotate(p.rotation);
    canvas.scale(p.scale);
    canvas.translate(-340, -pivotY);
  }
  if (ctx.chubby) {
    canvas.translate(340, 208);
    canvas.scale(chubbyCapScale);
    canvas.translate(-340, -208);
  }
  draw();
  canvas.restore();
}

Paint strokeOf(Paint base, double w) => base
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Dort uclu parilti.
void sparkle(Canvas canvas, Offset c, double r, Paint paint, [double rot = 0]) {
  final q = r * 0.2;
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(rot);
  canvas.drawPath(
    Path()
      ..moveTo(0, -r)
      ..quadraticBezierTo(q, -q, r, 0)
      ..quadraticBezierTo(q, q, 0, r)
      ..quadraticBezierTo(-q, q, -r, 0)
      ..quadraticBezierTo(-q, -q, 0, -r)
      ..close(),
    paint,
  );
  canvas.restore();
}

/// Kalp (merkez [c], yaklasik yaricap [r]).
void heart(Canvas canvas, Offset c, double r, Paint paint, [double rot = 0]) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(rot);
  canvas.scale(r / 10);
  canvas.drawPath(
    Path()
      ..moveTo(0, 8)
      ..cubicTo(-13, -1, -10, -11, 0, -4)
      ..cubicTo(10, -11, 13, -1, 0, 8)
      ..close(),
    paint,
  );
  canvas.restore();
}

/// Damla: yuvarlak ucu [dir] yonune bakar (dir: hareket yonu, radyan).
void drop(Canvas canvas, Offset c, double r, double dir, Paint paint) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(dir - math.pi / 2);
  // Yerel +y hareket yonu; sivri uc geride (-y).
  canvas.drawPath(
    Path()
      ..moveTo(0, -r * 2.1)
      ..quadraticBezierTo(r * 0.9, -r * 0.5, r, r * 0.2)
      ..arcToPoint(
        Offset(-r, r * 0.2),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..quadraticBezierTo(-r * 0.9, -r * 0.5, 0, -r * 2.1)
      ..close(),
    paint,
  );
  canvas.restore();
}

/// Karli dis (dislli cark) yolu.
Path gearPath(double r, int teeth, double rot) {
  final path = Path();
  final step = tau / teeth;
  final ro = r * 1.3;
  for (var k = 0; k < teeth; k++) {
    final a = rot + k * step;
    final pts = [
      (r, a - step * 0.3),
      (ro, a - step * 0.17),
      (ro, a + step * 0.17),
      (r, a + step * 0.3),
    ];
    for (var j = 0; j < pts.length; j++) {
      final pt = Offset(
        math.cos(pts[j].$2) * pts[j].$1,
        math.sin(pts[j].$2) * pts[j].$1,
      );
      if (k == 0 && j == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
  }
  return path..close();
}

/// Yumusak duman/bulut topu (iki katmanli).
void puff(
  Canvas canvas,
  CelebrationContext ctx,
  Offset c,
  double r,
  int hex,
  double op,
  int shade,
) {
  canvas.drawCircle(c, r, ctx.paintOf(hex, op));
  canvas.drawCircle(
    c + Offset(-r * 0.3, r * 0.25),
    r * 0.62,
    ctx.paintOf(shade, op * 0.8),
  );
  canvas.drawCircle(
    c + Offset(r * 0.38, -r * 0.1),
    r * 0.5,
    ctx.paintOf(shade, op * 0.55),
  );
}

/// Konturlu yazi (merkez [c]).
void textAt(
  Canvas canvas,
  String s,
  Offset c,
  double size,
  Paint fill, {
  Paint? outline,
  double rot = 0,
  double scale = 1,
  FontWeight weight = FontWeight.w900,
  double letterSpacing = 0,
}) {
  TextPainter tp(Paint paint) => TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        foreground: paint,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final f = tp(fill);
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(rot);
  canvas.scale(scale);
  final off = Offset(-f.width / 2, -f.height / 2);
  if (outline != null) tp(outline).paint(canvas, off);
  f.paint(canvas, off);
  canvas.restore();
}

/// Alev topu rengi: omur [p] boyunca (hex listesi, sicaktan soguga).
int rampColor(List<int> ramp, double p) {
  final x = (p.clamp(0.0, 1.0)) * (ramp.length - 1);
  final i = x.floor().clamp(0, ramp.length - 2);
  final c = Color.lerp(
    Color(0xFF000000 | ramp[i]),
    Color(0xFF000000 | ramp[i + 1]),
    x - i,
  )!;
  return c.toARGB32() & 0xFFFFFF;
}

/// Sinus tabanli yumusak 0..1 zarf: [a]..[b] arasinda acik.
double window(
  CelebrationContext ctx,
  double a,
  double b, [
  double soft = 0.05,
]) {
  if (ctx.reduceMotion) return 1;
  final t = ctx.t;
  return (((t - a) / soft).clamp(0.0, 1.0) * ((b - t) / soft).clamp(0.0, 1.0));
}
