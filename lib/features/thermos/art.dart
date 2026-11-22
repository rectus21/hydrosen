import 'dart:math' as math;
import 'dart:ui';

import 'svg_path.dart';

const k = 0x2C2C2A; // koyu çizgi
const w = 0xFFFFFF;

/// Tema çizimleri için küçük çizim dili. Tasarım taslaklarındaki (SVG/JS)
/// yardımcıların birebir karşılığıdır; koordinatlar taslaklarla aynıdır.
class Art {
  Art(this.canvas);

  final Canvas canvas;
  int _seed = 7;

  /// Taslaklardaki tohumlu rastgele sayı üreteciyle aynı dizi.
  double rnd() {
    _seed = (_seed * 16807) % 2147483647;
    return _seed / 2147483647;
  }

  static final _cache = <String, Path>{};
  Path path(String d) => _cache.putIfAbsent(d, () => svgPath(d));

  Paint _fill(int hex, double op) =>
      Paint()..color = Color(0xFF000000 | hex).withValues(alpha: op);

  void p(String d, int hex, {double op = 1}) =>
      canvas.drawPath(path(d), _fill(hex, op));

  void raw(Path path, int hex, {double op = 1}) =>
      canvas.drawPath(path, _fill(hex, op));

  void s(String d, int hex, double width) => canvas.drawPath(
    path(d),
    _fill(hex, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );

  void c(num x, num y, num r, int hex, {double op = 1}) => canvas.drawCircle(
    Offset(x.toDouble(), y.toDouble()),
    r.toDouble(),
    _fill(hex, op),
  );

  void o(
    num x,
    num y,
    num rx,
    num ry,
    int hex, {
    double op = 1,
    num rot = 0,
    double? strokeWidth,
  }) {
    canvas.save();
    canvas.translate(x.toDouble(), y.toDouble());
    if (rot != 0) canvas.rotate(rot * math.pi / 180);
    final paint = _fill(hex, op);
    if (strokeWidth != null) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
    }
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2.0, height: ry * 2.0),
      paint,
    );
    canvas.restore();
  }

  /// Üst yarım çember çizgisi (gökkuşağı).
  void arcTop(num cx, num cy, num r, int hex, double width) => canvas.drawArc(
    Rect.fromCircle(
      center: Offset(cx.toDouble(), cy.toDouble()),
      radius: r.toDouble(),
    ),
    math.pi,
    math.pi,
    false,
    _fill(hex, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width,
  );

  // --- Ortak karakter parçaları -------------------------------------------

  static const domeLight =
      'M260 150 Q246 120 270 84 Q300 56 340 52 Q296 70 282 110 Q276 150 300 196 Q266 184 260 150 Z';
  static const domeDark =
      'M398 64 Q440 96 436 140 Q432 186 380 204 Q418 170 420 134 Q420 94 398 64 Z';
  static const boxBase =
      'M284 164 L284 116 Q284 92 310 90 L370 90 Q396 92 396 116 L396 164 Z';
  static const boxLight =
      'M284 164 L284 116 Q284 94 302 91 Q296 104 296 120 L296 164 Z';
  static const boxDark = 'M380 92 Q396 96 396 116 L396 164 L384 164 Z';

  /// Tombul kapak: büyük oval kafa, sol ışık, sağ gölge.
  void dome(int base, int light, int dark) {
    o(340, 130, 96, 80, base);
    p(domeLight, light, op: 0.7);
    p(domeDark, dark);
  }

  /// İnce kapak: yuvarlatılmış kutu.
  void box(int base, int light, int dark) {
    p(boxBase, base);
    p(boxLight, light, op: 0.8);
    p(boxDark, dark);
  }

  void eye(num x, num y, num r) {
    o(x, y, r, r * 1.15, k);
    c(x - r * 0.35, y - r * 0.4, r * 0.38, w);
    c(x + r * 0.3, y + r * 0.35, r * 0.15, w);
  }

  void cheeks(num y, double op) {
    o(282, y, 14, 8, 0xED93B1, op: op);
    o(398, y, 14, 8, 0xED93B1, op: op);
  }

  void seeds(List<List<num>> pts) {
    for (final pt in pts) {
      p('M${pt[0]} ${pt[1] - 4} q3 4 0 9 q-3 -5 0 -9 Z', 0xFAC775);
    }
  }

  /// [(dx, renk)] listesiyle bir noktadan çıkan yapraklar.
  void leaves(num cx, num cy, List<(num, int)> list) {
    for (final (dx, col) in list) {
      p(
        'M$cx $cy Q${cx + dx * 0.5} ${cy - 24} ${cx + dx} ${cy - 10} '
        'Q${cx + dx * 0.5} ${cy + 6} $cx $cy Z',
        col,
      );
    }
  }

  /// Ahşap damarları; [clip] verilirse onun içine kırpılır.
  void grain(num x1, num x2, num y1, num y2, int hex, {Path? clip}) {
    canvas.save();
    if (clip != null) canvas.clipPath(clip);
    for (var y = y1; y < y2; y += 12) {
      s('M$x1 $y Q${(x1 + x2) / 2} ${y - 6} $x2 $y', hex, 1.2);
    }
    canvas.restore();
  }

  /// Okaliptüs dalı ve beyaz çiçek.
  void sprig(num x, num y, int dir) {
    s(
      'M$x $y Q${x + 20 * dir} ${y - 30} ${x + 46 * dir} ${y - 44}',
      0x3B6D11,
      2.5,
    );
    const offs = [
      [10, -14],
      [22, -26],
      [34, -36],
      [18, -8],
      [32, -20],
    ];
    for (var i = 0; i < offs.length; i++) {
      o(
        x + offs[i][0] * dir,
        y + offs[i][1],
        9,
        5,
        i.isOdd ? 0x97C459 : 0x639922,
        rot: -40 * dir,
      );
    }
    for (var i = 0; i < 5; i++) {
      final a = i * 72 * math.pi / 180;
      c(x + 46 * dir + math.cos(a) * 6, y - 46 + math.sin(a) * 6, 5, w);
    }
    c(x + 46 * dir, y - 46, 4, 0xFAC775);
  }
}
