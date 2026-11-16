// Yeni1 paketi temaları: Bulut, Fil, Rakun, Kirpi, Sincap (tamamı kod çizimi).
//
// Çizim alanı 120..560 x 8..512; tombul kapak a.dome, ince kapak a.box ile
// başlar; happy=true hedefe ulaşıldığında ifade değişir.

import 'dart:math' as math;
import 'dart:ui';

import '../art.dart';
import '../celebration_style.dart';
import '../thermos_theme.dart';

const _full = 'M120 8 H560 V512 H120 Z';

const List<ThermosTheme> yeni1Themes = [
  ThermosTheme(
    id: 'bulut',
    name: 'Bulut',
    glass: Color(0xFFE6F3FD),
    edge: Color(0xFF4E86B8),
    water: Color(0xFF2F86D0),
    deepWater: Color(0xFF124F8C),
    waterSurface: Color(0xFFC4E2F8),
    mark: Color(0xFF123F70),
    label: Color(0xFF1F4F80),
    band: Color(0xFF5B8FC4),
    bandLight: Color(0xFFA9CBEA),
    background: _bulutBg,
    capChubby: _bulutA,
    capSlim: _bulutB,
    celebration: CelebrationStyle(CelebrationKind.bubbles, [
      0xFFFFFF,
      0xBFE6FA,
      0xF7C6DD,
      0xFFE59A,
    ]),
  ),
  ThermosTheme(
    id: 'fil',
    name: 'Fil',
    glass: Color(0xFFF1ECF8),
    edge: Color(0xFF6C679A),
    water: Color(0xFF2A93C9),
    deepWater: Color(0xFF105A86),
    waterSurface: Color(0xFFBDE4F4),
    mark: Color(0xFF2E2B5E),
    label: Color(0xFF5A3A10),
    band: Color(0xFF7A74A8),
    bandLight: Color(0xFFB5B0D8),
    background: _filBg,
    capChubby: _filA,
    capSlim: _filB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0x4BA3E3,
      0x9AD8F5,
      0xFFFFFF,
      0xF2B84B,
    ]),
  ),
  ThermosTheme(
    id: 'rakun',
    name: 'Rakun',
    glass: Color(0xFFDDE6F2),
    edge: Color(0xFF8FA3C4),
    water: Color(0xFF2E86C4),
    deepWater: Color(0xFF123F6E),
    waterSurface: Color(0xFFBFDDF5),
    mark: Color(0xFFF0F6FF),
    label: Color(0xFFE6ECF8),
    band: Color(0xFF3C4258),
    bandLight: Color(0xFF7A829E),
    background: _rakunBg,
    capChubby: _rakunA,
    capSlim: _rakunB,
    celebration: CelebrationStyle(CelebrationKind.twinkles, [
      0xF6E7B0,
      0xFFFFFF,
      0xBFD4F5,
    ]),
  ),
  ThermosTheme(
    id: 'kirpi',
    name: 'Kirpi',
    glass: Color(0xFFF8EBD2),
    edge: Color(0xFF8A5A2E),
    water: Color(0xFF3585C8),
    deepWater: Color(0xFF14507F),
    waterSurface: Color(0xFFC2DFF5),
    mark: Color(0xFF3F2410),
    label: Color(0xFF5A3515),
    band: Color(0xFF9A3F24),
    bandLight: Color(0xFFD9805F),
    background: _kirpiBg,
    capChubby: _kirpiA,
    capSlim: _kirpiB,
    celebration: CelebrationStyle(CelebrationKind.fallingLeaves, [
      0xD9622B,
      0xE9A23B,
      0xB5382A,
      0x8A5A2E,
    ]),
  ),
  ThermosTheme(
    id: 'sincap',
    name: 'Sincap',
    glass: Color(0xFFF4ECDC),
    edge: Color(0xFF8A5530),
    water: Color(0xFF2E8CCB),
    deepWater: Color(0xFF12517F),
    waterSurface: Color(0xFFC0E0F5),
    mark: Color(0xFF3F2410),
    label: Color(0xFF1F4A2C),
    band: Color(0xFF3F7A4A),
    bandLight: Color(0xFF8CBF8E),
    background: _sincapBg,
    capChubby: _sincapA,
    capSlim: _sincapB,
    celebration: CelebrationStyle(CelebrationKind.fallingLeaves, [
      0xE8782A,
      0xF2A03D,
      0x8A5A2E,
      0x6FA85A,
    ]),
  ),
];

// --- Ortak yardımcılar -------------------------------------------------------

/// Elipsin [deg] açısındaki noktası.
Offset _ep(num cx, num cy, num rx, num ry, double deg) {
  final r = deg * math.pi / 180;
  return Offset(cx + rx * math.cos(r), cy + ry * math.sin(r));
}

/// Elips çevresinde dışa bakan üçgen dikenler ([from]..[to] derece).
void _spikes(
  Art a,
  num cx,
  num cy,
  num rx,
  num ry,
  double from,
  double to,
  double step,
  double len,
  double half,
  int hex,
) {
  for (var d = from; d <= to + 0.01; d += step) {
    final b1 = _ep(cx, cy, rx, ry, d - half);
    final b2 = _ep(cx, cy, rx, ry, d + half);
    final tip = _ep(cx, cy, rx + len, ry + len, d);
    a.raw(
      Path()
        ..moveTo(b1.dx, b1.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(b2.dx, b2.dy)
        ..close(),
      hex,
    );
  }
}

void _pine(Art a, num x, num y, num h, int c1, int c2, {int trunk = 0x6B4A2E}) {
  a.p('M${x - 4} $y V${y + 30} H${x + 4} V$y Z', trunk);
  for (var i = 0; i < 3; i++) {
    final top = y - h + i * h * 0.26;
    final bot = y - h * 0.16 + i * h * 0.06 - (2 - i) * h * 0.06;
    final hw = h * (0.2 + i * 0.1);
    a.p('M$x $top L${x - hw} $bot L${x + hw} $bot Z', i.isEven ? c1 : c2);
  }
}

void _bird(Art a, num x, num y, int hex) => a.s(
  'M${x - 10} $y Q${x - 5} ${y - 8} $x $y Q${x + 5} ${y - 8} ${x + 10} $y',
  hex,
  2.4,
);

// --- Bulut -----------------------------------------------------------------

void _bulutCloud(Art a, num x, num y, double s, {double op = 1}) {
  a.o(x, y, 40 * s, 15 * s, w, op: op);
  a.c(x - 14 * s, y - 10 * s, 18 * s, w, op: op);
  a.c(x + 12 * s, y - 14 * s, 22 * s, w, op: op);
  a.c(x + 30 * s, y - 4 * s, 14 * s, w, op: op);
}

void _bulutBg(Art a) {
  a.p(_full, 0x8CCBF2);
  a.p('M120 150 H560 V512 H120 Z', 0xB4E0F8, op: 0.85);
  a.p('M120 310 H560 V512 H120 Z', 0xD6EFFC, op: 0.9);
  // Güneş.
  a.c(500, 84, 62, 0xFFF1B0, op: 0.35);
  a.c(500, 84, 46, 0xFFE58A, op: 0.6);
  a.c(500, 84, 34, 0xFFD65A);
  a.c(490, 74, 10, 0xFFF1B8, op: 0.7);
  // Gökkuşağı.
  const rb = [0xF28B82, 0xFAC775, 0xFFF0A0, 0x9BD67A, 0x7CC4F0, 0xB9A4E8];
  for (var i = 0; i < rb.length; i++) {
    a.arcTop(200, 310, 128 - i * 9, rb[i], 9.5);
  }
  _bulutCloud(a, 110, 322, 1.0);
  _bulutCloud(a, 288, 322, 1.0);
  _bulutCloud(a, 190, 120, 1.1, op: 0.95);
  _bulutCloud(a, 470, 200, 0.9, op: 0.9);
  _bulutCloud(a, 150, 420, 1.2);
  _bulutCloud(a, 500, 400, 1.3);
  _bulutCloud(a, 330, 500, 1.8);
  _bulutCloud(a, 190, 505, 1.3);
  _bulutCloud(a, 480, 505, 1.2);
  _bird(a, 230, 60, 0x4F7FA8);
  _bird(a, 262, 74, 0x4F7FA8);
  for (final t in const [
    [140, 220],
    [520, 300],
    [420, 90],
    [160, 50],
  ]) {
    final x = t[0], y = t[1];
    a.p(
      'M$x ${y - 8} Q$x $y ${x + 8} $y Q$x $y $x ${y + 8} '
      'Q$x $y ${x - 8} $y Q$x $y $x ${y - 8} Z',
      w,
      op: 0.9,
    );
  }
}

void _bulutSun(Art a, num x, num y, num r) {
  a.c(x, y, r + 10, 0xFFE9A0, op: 0.55);
  for (var d = -165; d <= -15; d += 25) {
    final p1 = _ep(x, y, r + 6, r + 6, d.toDouble());
    final p2 = _ep(x, y, r + 16, r + 16, d.toDouble());
    a.s('M${p1.dx} ${p1.dy} L${p2.dx} ${p2.dy}', 0xFFC93C, 5);
  }
  a.c(x, y, r, 0xFFD65A);
  a.c(x - r * 0.3, y - r * 0.3, r * 0.3, 0xFFF1B8, op: 0.7);
}

void _bulutA(Art a, bool happy) {
  _bulutSun(a, 408, 62, 26);
  const puffs = [
    [296.0, 72.0, 32.0],
    [346.0, 54.0, 35.0],
    [392.0, 74.0, 30.0],
    [252.0, 132.0, 30.0],
    [430.0, 132.0, 30.0],
    [288.0, 188.0, 30.0],
    [392.0, 188.0, 30.0],
  ];
  for (final p in puffs) {
    a.c(p[0], p[1] + 5, p[2], 0xC6DAEE);
  }
  for (final p in puffs) {
    a.c(p[0], p[1], p[2], 0xFAFDFF);
  }
  a.dome(0xFAFDFF, w, 0xD3E3F4);
  a.o(340, 100, 40, 12, w, op: 0.8);
  a.cheeks(160, happy ? 0.95 : 0.7);
  if (happy) {
    a.s('M290 126 Q306 108 322 126', k, 4.5);
    a.s('M358 126 Q374 108 390 126', k, 4.5);
    a.p('M322 150 Q340 182 358 150 Q340 158 322 150 Z', k);
    a.o(340, 166, 8, 5, 0xF08AA6);
  } else {
    a.eye(306, 124, 12);
    a.eye(374, 124, 12);
    a.s('M326 150 Q340 164 354 150', k, 3.5);
  }
}

void _bulutB(Art a, bool happy) {
  _bulutSun(a, 388, 80, 17);
  const puffs = [
    [302.0, 96.0, 20.0],
    [340.0, 82.0, 24.0],
    [380.0, 98.0, 20.0],
    [284.0, 132.0, 16.0],
    [396.0, 132.0, 16.0],
    [296.0, 160.0, 14.0],
    [384.0, 160.0, 14.0],
  ];
  for (final p in puffs) {
    a.c(p[0], p[1] + 3, p[2], 0xC6DAEE);
  }
  for (final p in puffs) {
    a.c(p[0], p[1], p[2], 0xFAFDFF);
  }
  a.box(0xFAFDFF, w, 0xD3E3F4);
  a.o(284, 142, 11, 6, 0xF4A6C0, op: 0.7);
  a.o(396, 142, 11, 6, 0xF4A6C0, op: 0.7);
  if (happy) {
    a.s('M306 122 Q319 108 332 122', k, 3.5);
    a.s('M348 122 Q361 108 374 122', k, 3.5);
    a.p('M328 138 Q340 156 352 138 Q340 144 328 138 Z', k);
  } else {
    a.c(320, 122, 5.5, k);
    a.c(360, 122, 5.5, k);
    a.c(318, 120, 1.8, w);
    a.c(358, 120, 1.8, w);
    a.s('M331 138 Q340 148 349 138', k, 2.6);
  }
}

// --- Fil -------------------------------------------------------------------

void _filBg(Art a) {
  a.p(_full, 0xFFE3B0);
  a.p('M120 120 H560 V512 H120 Z', 0xFDD08C, op: 0.8);
  a.p('M120 220 H560 V512 H120 Z', 0xF9BE78, op: 0.7);
  // Güneş.
  a.c(470, 170, 80, 0xFFF0C8, op: 0.35);
  a.c(470, 170, 58, 0xFFD58A, op: 0.6);
  a.c(470, 170, 44, 0xF7A83A);
  // Uzak tepe ve zemin.
  a.p('M120 330 Q220 290 330 330 Q440 366 560 316 V512 H120 Z', 0xE0A45E);
  a.p('M120 394 Q260 360 380 396 Q480 420 560 388 V512 H120 Z', 0xC8A25A);
  a.p('M120 452 Q300 430 560 456 V512 H120 Z', 0x8FAE4A);
  // Akasya.
  a.p('M172 336 Q176 292 168 262 L180 262 Q186 292 186 336 Z', 0x5A3E26);
  a.o(176, 252, 56, 14, 0x4F7A34);
  a.o(150, 262, 36, 11, 0x5E8A3A);
  a.o(206, 262, 34, 10, 0x5E8A3A);
  // Uzaktaki fil siluetleri.
  for (final e in const [
    [510.0, 346.0, 0.8],
    [546.0, 352.0, 0.55],
  ]) {
    final x = e[0], y = e[1], s = e[2];
    a.o(x, y, 22 * s, 14 * s, 0x8A7A9A, op: 0.8);
    a.c(x - 20 * s, y - 6 * s, 10 * s, 0x8A7A9A, op: 0.8);
    a.s(
      'M${x - 28 * s} ${y - 4 * s} q-6 ${14 * s} 0 ${24 * s}',
      0x8A7A9A,
      5 * s,
    );
  }
  // Uzun otlar.
  for (var i = 0; i < 16; i++) {
    final x = 126 + i * 28.0 + a.rnd() * 10;
    final h = 18 + a.rnd() * 22;
    a.s('M$x 480 Q${x + 4} ${480 - h / 2} ${x + 8} ${480 - h}', 0x6F9A38, 3);
  }
  // Orman yaprakları (köşeler).
  for (final l in const [
    [-1, 150, 80],
    [1, 540, 440],
  ]) {
    final d = l[0].toDouble();
    final x = l[1], y = l[2];
    for (var i = 0; i < 4; i++) {
      final ang = (i * 22 - 20) * math.pi / 180;
      final ex = x + d * 70 * math.cos(ang) * 1.2;
      final ey = y + 70 * math.sin(ang) + 30;
      a.p(
        'M$x $y Q${(x + ex) / 2} ${y - 30 - i * 6} $ex $ey Q${(x + ex) / 2} ${y + 10} $x $y Z',
        i.isEven ? 0x3F7A3A : 0x5C9A48,
      );
    }
  }
  _bird(a, 330, 90, 0x7A5A3A);
  _bird(a, 366, 108, 0x7A5A3A);
  _bird(a, 300, 118, 0x7A5A3A);
}

void _filEar(Art a, num x, num y, num rx, num ry, num dir) {
  final rot = -10.0 * dir;
  a.o(x, y, rx + 4, ry + 4, 0x7E7BA6, rot: rot);
  a.o(x, y, rx, ry, 0xA9A6C8, rot: rot);
  a.o(
    x + dir * rx * 0.1,
    y + ry * 0.08,
    rx * 0.66,
    ry * 0.7,
    0xE9B4C8,
    rot: rot,
  );
  a.o(
    x + dir * rx * 0.2,
    y + ry * 0.02,
    rx * 0.4,
    ry * 0.5,
    0xF2CBD9,
    rot: rot,
    op: 0.7,
  );
}

void _filTusks(Art a, num y, num dx, num s) {
  for (final d in const [-1, 1]) {
    a.p(
      'M${340 + d * dx} $y Q${340 + d * (dx + 10 * s)} ${y + 6 * s} ${340 + d * (dx + 8 * s)} ${y + 18 * s} '
      'Q${340 + d * (dx - 2 * s)} ${y + 8 * s} ${340 + d * (dx - 5 * s)} ${y - 1} Z',
      0xFFF4DC,
    );
  }
}

void _filA(Art a, bool happy) {
  _filEar(a, 232, 124, 52, 66, -1);
  _filEar(a, 448, 124, 52, 66, 1);
  a.dome(0xAFACCE, 0xCFCCE6, 0x8582AE);
  a.o(340, 96, 44, 14, w, op: 0.18);
  _filTusks(a, 172, 26, 1.1);
  // Hortum.
  final trunk = happy
      ? 'M340 138 Q338 174 346 190 Q356 208 372 198 Q384 188 374 174'
      : 'M340 138 Q340 176 340 188 Q340 206 322 206 Q310 205 312 192';
  a.s(trunk, 0x8F8CB8, 30);
  a.s(trunk, 0xAFACCE, 24);
  a.s(trunk, 0xCFCCE6, 5);
  final tip = happy ? const [374, 174] : const [312, 192];
  a.c(tip[0], tip[1], 5, 0xE9B4C8);
  for (final y in const [152, 164, 176]) {
    a.s('M331 $y Q340 ${y + 5} 349 $y', 0x7E7BA6, 2.4);
  }
  if (happy) {
    for (final d in const [
      [366, 150, 3.5],
      [382, 134, 3.0],
      [356, 132, 2.5],
    ]) {
      a.c(d[0], d[1], d[2], 0x4BA3E3);
    }
  }
  a.cheeks(150, happy ? 0.9 : 0.55);
  if (happy) {
    a.s('M286 118 Q302 100 318 118', k, 4.5);
    a.s('M362 118 Q378 100 394 118', k, 4.5);
  } else {
    a.eye(302, 114, 11);
    a.eye(378, 114, 11);
  }
  a.s('M284 98 Q300 90 314 96', 0x7E7BA6, 3);
  a.s('M396 98 Q380 90 366 96', 0x7E7BA6, 3);
}

void _filB(Art a, bool happy) {
  _filEar(a, 258, 110, 32, 42, -1);
  _filEar(a, 422, 110, 32, 42, 1);
  a.box(0xAFACCE, 0xCFCCE6, 0x8582AE);
  final trunk = happy
      ? 'M340 124 Q339 144 343 154 Q349 168 360 162 Q367 156 361 148'
      : 'M340 124 Q340 148 340 154 Q340 168 328 168 Q321 167 322 159';
  a.s(trunk, 0x8F8CB8, 19);
  a.s(trunk, 0xAFACCE, 14);
  a.s(trunk, 0xCFCCE6, 3);
  for (final y in const [134, 142, 150]) {
    a.s('M334 $y Q340 ${y + 3} 346 $y', 0x7E7BA6, 1.8);
  }
  if (happy) {
    a.c(366, 142, 2.5, 0x4BA3E3);
    a.c(374, 130, 2, 0x4BA3E3);
    a.s('M308 114 Q319 102 330 114', k, 3.5);
    a.s('M350 114 Q361 102 372 114', k, 3.5);
  } else {
    a.c(319, 112, 5, k);
    a.c(361, 112, 5, k);
    a.c(317, 110, 1.6, w);
    a.c(359, 110, 1.6, w);
  }
  a.o(298, 136, 9, 5, 0xED93B1, op: 0.55);
  a.o(382, 136, 9, 5, 0xED93B1, op: 0.55);
}

// --- Rakun -----------------------------------------------------------------

void _rakunBg(Art a) {
  a.p(_full, 0x16213A);
  a.p('M120 8 H560 V220 H120 Z', 0x1C2B4A, op: 0.7);
  for (var i = 0; i < 40; i++) {
    final x = 125 + a.rnd() * 430;
    final y = 12 + a.rnd() * 300;
    a.c(x, y, a.rnd() * 1.3 + 0.5, w, op: 0.4 + a.rnd() * 0.5);
  }
  // Hilal.
  a.c(492, 96, 36, 0xF2EBC8);
  a.c(506, 88, 32, 0x1C2B4A);
  // Uzak orman.
  for (final t in const [
    [140, 340, 60],
    [200, 328, 78],
    [262, 346, 54],
    [420, 332, 66],
    [480, 318, 84],
    [540, 342, 58],
  ]) {
    _pine(a, t[0], t[1], t[2], 0x1D3A44, 0x1D3A44, trunk: 0x1D3A44);
  }
  a.p('M120 340 H560 V512 H120 Z', 0x1D3A44);
  // Ön plan.
  for (final t in const [
    [150, 480, 160],
    [540, 480, 140],
    [204, 492, 96],
  ]) {
    _pine(a, t[0], t[1], t[2], 0x0C1F24, 0x0F2A2C, trunk: 0x0A1A1E);
  }
  a.p('M120 480 Q300 462 560 482 V512 H120 Z', 0x0C1F24);
  // Mantarlar ve ateşböcekleri.
  for (final m in const [
    [236, 478],
    [500, 484],
  ]) {
    a.p('M${m[0] - 3} ${m[1]} V${m[1] + 10} H${m[0] + 3} V${m[1]} Z', 0xE6DCC8);
    a.p(
      'M${m[0] - 12} ${m[1]} Q${m[0]} ${m[1] - 16} ${m[0] + 12} ${m[1]} Z',
      0xC9473A,
    );
    a.c(m[0] - 4, m[1] - 6, 1.8, w);
    a.c(m[0] + 5, m[1] - 4, 1.4, w);
  }
  for (final f in const [
    [176, 410],
    [240, 440],
    [506, 390],
    [470, 436],
    [160, 290],
    [520, 270],
  ]) {
    a.c(f[0], f[1], 8, 0xF6E7A0, op: 0.18);
    a.c(f[0], f[1], 2.5, 0xF6E7A0);
  }
}

void _rakunEar(Art a, num x, num y, num r) {
  a.c(x, y, r, 0x8E949D);
  a.canvas.save();
  a.canvas.clipPath(
    Path()..addOval(
      Rect.fromCircle(center: Offset(x.toDouble(), y.toDouble()), radius: r.toDouble()),
    ),
  );
  // Çizgili uç: koyu iç, açık bant, koyu uç.
  a.o(x, y + r * 0.3, r * 0.6, r * 0.55, 0x3A3D46);
  a.p(
    'M${x - r} ${y - r * 0.1} Q$x ${y - r * 0.5} ${x + r} ${y - r * 0.1} V${y - r} H${x - r} Z',
    0xF1F2F4,
  );
  a.p(
    'M${x - r} ${y - r * 0.45} Q$x ${y - r * 0.82} ${x + r} ${y - r * 0.45} V${y - r} H${x - r} Z',
    0x2E3036,
  );
  a.canvas.restore();
}

void _rakunA(Art a, bool happy) {
  _rakunEar(a, 266, 84, 34);
  _rakunEar(a, 414, 84, 34);
  a.dome(0x9EA4AC, 0xBDC2C9, 0x737982);
  // Yanak tüyleri.
  a.p('M246 140 L226 154 L252 160 L232 176 L264 176 Z', 0x9EA4AC);
  a.p('M434 140 L454 154 L428 160 L448 176 L416 176 Z', 0x9EA4AC);
  // Alın çizgisi.
  a.p('M340 60 Q352 80 350 108 L340 150 L330 108 Q328 80 340 60 Z', 0xF1F2F4);
  // Maske.
  a.o(296, 130, 40, 26, 0x24262C, rot: -14);
  a.o(384, 130, 40, 26, 0x24262C, rot: 14);
  a.o(340, 128, 24, 14, 0x24262C);
  // Beyaz ağız bölgesi.
  a.o(340, 170, 44, 32, 0xF4F2EE);
  a.o(340, 176, 30, 20, w, op: 0.5);
  a.cheeks(172, 0.4);
  if (happy) {
    a.s('M286 134 Q302 114 318 134', w, 4.5);
    a.s('M362 134 Q378 114 394 134', w, 4.5);
  } else {
    for (final x in const [304, 376]) {
      a.o(x, 130, 12, 13, w);
      a.o(x + 1, 131, 7.5, 9, k);
      a.c(x - 2, 126, 3, w);
      a.c(x + 3, 135, 1.4, w);
    }
  }
  // Burun ve ağız.
  a.o(340, 154, 13, 9, 0x2A2C32);
  a.o(335, 151, 4.5, 2.5, w, op: 0.55);
  if (happy) {
    a.p('M320 172 Q340 202 360 172 Q340 180 320 172 Z', k);
    a.o(340, 188, 9, 5, 0xE8758F);
  } else {
    a.s(
      'M340 163 L340 172 M340 172 Q330 182 320 176 M340 172 Q350 182 360 176',
      k,
      3,
    );
  }
  for (final p in const [
    [318, 168],
    [324, 174],
    [362, 168],
    [356, 174],
  ]) {
    a.c(p[0], p[1], 1.1, 0x6E7077);
  }
}

void _rakunB(Art a, bool happy) {
  _rakunEar(a, 298, 92, 21);
  _rakunEar(a, 382, 92, 21);
  a.box(0x9EA4AC, 0xBDC2C9, 0x737982);
  a.p('M340 92 Q347 104 346 118 L340 138 L334 118 Q333 104 340 92 Z', 0xF1F2F4);
  a.o(314, 120, 22, 14, 0x24262C, rot: -12);
  a.o(366, 120, 22, 14, 0x24262C, rot: 12);
  a.o(340, 119, 12, 8, 0x24262C);
  a.o(340, 146, 25, 17, 0xF4F2EE);
  if (happy) {
    a.s('M306 122 Q317 110 328 122', w, 3.5);
    a.s('M352 122 Q363 110 374 122', w, 3.5);
  } else {
    for (final x in const [320, 360]) {
      a.o(x, 120, 6.5, 7, w);
      a.o(x + 0.5, 120.5, 4, 4.8, k);
      a.c(x - 1, 118, 1.5, w);
    }
  }
  a.o(340, 137, 7.5, 5, 0x2A2C32);
  a.o(337, 135.5, 2.5, 1.5, w, op: 0.55);
  if (happy) {
    a.p('M330 148 Q340 162 350 148 Q340 153 330 148 Z', k);
  } else {
    a.s(
      'M340 142 L340 146 M340 146 Q334 152 328 149 M340 146 Q346 152 352 149',
      k,
      2,
    );
  }
}

// --- Kirpi -----------------------------------------------------------------

void _kirpiApple(Art a, num x, num y, num r) {
  a.c(x, y, r, 0xD0392B);
  a.c(x + r * 0.35, y + r * 0.2, r * 0.7, 0xB02A20, op: 0.5);
  a.c(x - r * 0.35, y - r * 0.35, r * 0.28, 0xF2A39A, op: 0.8);
  a.s('M$x ${y - r} q1 -6 5 -9', 0x5A3A22, 2.4);
  a.o(x + 7, y - r - 5, 6, 3, 0x6FA85A, rot: -25);
}

void _kirpiBg(Art a) {
  a.p(_full, 0xFBE7BE);
  a.p('M120 120 H560 V512 H120 Z', 0xF9D9A0, op: 0.7);
  a.c(150, 90, 40, 0xFFF1C8, op: 0.8);
  a.c(150, 90, 28, 0xFFE08A);
  // Tepe ve zemin.
  a.p('M120 350 Q240 310 360 354 Q470 392 560 336 V512 H120 Z', 0xD9A55C);
  a.p('M120 412 Q280 380 400 418 Q490 440 560 410 V512 H120 Z', 0xBE7F3C);
  a.p('M120 470 Q300 448 560 474 V512 H120 Z', 0x9A6430);
  // Çit.
  for (final x in const [130, 160, 190, 520, 550]) {
    a.p('M${x - 9} 372 L$x 360 L${x + 9} 372 V440 H${x - 9} Z', 0xF4E2BC);
  }
  a.s('M120 392 H212 M508 392 H560', 0xD9BD8A, 4);
  // Elma ağacı (sağ).
  a.p('M514 360 Q516 300 508 250 L526 250 Q534 300 536 360 Z', 0x6B4A2E);
  a.c(500, 220, 44, 0xD9822B);
  a.c(546, 214, 38, 0xC96A24);
  a.c(520, 178, 40, 0xE09A38);
  a.c(484, 246, 30, 0xC96A24);
  for (final p in const [
    [492.0, 232.0, 10.0],
    [536.0, 200.0, 9.0],
    [516.0, 262.0, 9.0],
    [548.0, 240.0, 8.0],
  ]) {
    _kirpiApple(a, p[0], p[1], p[2]);
  }
  // Sol ağaç dalı ve elmalar.
  a.s('M120 180 Q170 176 214 200', 0x6B4A2E, 7);
  a.c(150, 160, 26, 0xE09A38);
  a.c(186, 168, 22, 0xC96A24);
  _kirpiApple(a, 178, 218, 9);
  _kirpiApple(a, 140, 196, 8);
  // Yerdeki yaprak ve elmalar.
  _kirpiApple(a, 470, 470, 12);
  _kirpiApple(a, 214, 488, 10);
  for (final l in const [
    [150, 440, 0xD9622B, -20],
    [180, 456, 0xE9A23B, 25],
    [250, 470, 0xB5382A, -35],
    [440, 440, 0xE9A23B, 20],
    [520, 460, 0xD9622B, -25],
    [400, 490, 0xB5382A, 30],
    [290, 496, 0xE9A23B, -15],
  ]) {
    a.o(l[0], l[1], 14, 7, l[2], rot: l[3]);
    a.o(l[0], l[1], 10, 0.9, 0x7A3A18, rot: l[3], op: 0.6);
  }
}

void _kirpiEars(Art a, num lx, num rx, num y, num r) {
  for (final x in [lx, rx]) {
    a.c(x, y, r, 0xE0B98E);
    a.c(x, y + 1, r * 0.6, 0xF0A9B0);
  }
}

void _kirpiA(Art a, bool happy) {
  // Katmanlı sivri dikenler (arkadan öne).
  _spikes(a, 340, 126, 100, 84, 168, 372, 11, 26, 6.5, 0x4A3222);
  _spikes(a, 340, 126, 98, 82, 174, 366, 11, 20, 6, 0x6B4A2E);
  _spikes(a, 340, 128, 96, 80, 164, 376, 9, 12, 5, 0x8A6240);
  a.dome(0x8A6240, 0xA77D55, 0x654528);
  for (var d = 200.0; d <= 350; d += 15) {
    final p1 = _ep(340, 130, 70, 56, d);
    final p2 = _ep(340, 130, 94, 78, d);
    a.s('M${p1.dx} ${p1.dy} L${p2.dx} ${p2.dy}', 0x4A3222, 2.4);
  }
  _kirpiEars(a, 258, 422, 138, 15);
  // Yüz ve saç çizgisi saçağı.
  a.o(340, 156, 72, 56, 0xF3DDBA);
  a.o(340, 170, 56, 36, 0xFBEBCF, op: 0.7);
  _spikes(a, 340, 156, 70, 54, 205, 335, 14, -12, 8, 0x8A6240);
  a.cheeks(172, happy ? 0.9 : 0.6);
  if (happy) {
    a.s('M292 140 Q306 124 320 140', k, 4.5);
    a.s('M360 140 Q374 124 388 140', k, 4.5);
  } else {
    a.eye(306, 138, 9);
    a.eye(374, 138, 9);
  }
  a.o(340, 160, 10, 7.5, 0x2A1E1A);
  a.o(336, 157.5, 3.4, 2, w, op: 0.6);
  if (happy) {
    a.p('M324 176 Q340 200 356 176 Q340 183 324 176 Z', k);
    a.o(340, 190, 7, 4, 0xE8758F);
  } else {
    a.s(
      'M340 167 L340 174 M340 174 Q331 183 322 177 M340 174 Q349 183 358 177',
      k,
      3,
    );
  }
}

void _kirpiB(Art a, bool happy) {
  _spikes(a, 340, 126, 66, 52, 172, 368, 12, 24, 7, 0x4A3222);
  _spikes(a, 340, 126, 62, 48, 178, 362, 12, 17, 6.5, 0x6B4A2E);
  _spikes(a, 340, 128, 58, 44, 170, 370, 10, 9, 5.5, 0x8A6240);
  a.box(0x8A6240, 0xA77D55, 0x654528);
  for (var d = 205.0; d <= 340; d += 22) {
    final p1 = _ep(340, 120, 40, 20, d);
    final p2 = _ep(340, 120, 54, 30, d);
    a.s('M${p1.dx} ${p1.dy} L${p2.dx} ${p2.dy}', 0x4A3222, 2);
  }
  _kirpiEars(a, 282, 398, 118, 9);
  a.o(340, 138, 40, 28, 0xF3DDBA);
  _spikes(a, 340, 138, 38, 26, 208, 332, 16, -8, 9, 0x8A6240);
  if (happy) {
    a.s('M312 128 Q322 116 332 128', k, 3.2);
    a.s('M348 128 Q358 116 368 128', k, 3.2);
  } else {
    a.c(322, 126, 4.8, k);
    a.c(358, 126, 4.8, k);
    a.c(320.5, 124.5, 1.5, w);
    a.c(356.5, 124.5, 1.5, w);
  }
  a.o(340, 138, 6, 4.5, 0x2A1E1A);
  a.o(338, 136.5, 2, 1.2, w, op: 0.6);
  a.o(304, 140, 8, 4.5, 0xED93B1, op: 0.5);
  a.o(376, 140, 8, 4.5, 0xED93B1, op: 0.5);
  if (happy) {
    a.p('M331 148 Q340 160 349 148 Q340 153 331 148 Z', k);
  } else {
    a.s(
      'M340 143 L340 146 M340 146 Q334 152 328 149 M340 146 Q346 152 352 149',
      k,
      2,
    );
  }
}

// --- Sincap ----------------------------------------------------------------

void _sincapAcorn(Art a, num x, num y, double s) {
  a.o(x, y + 4 * s, 9 * s, 12 * s, 0xC98A4A);
  a.o(x - 3 * s, y + 2 * s, 2.6 * s, 6 * s, 0xE8B070, op: 0.8);
  a.p(
    'M${x - 11 * s} ${y - 2 * s} Q$x ${y - 14 * s} ${x + 11 * s} ${y - 2 * s} Q$x ${y + 2 * s} ${x - 11 * s} ${y - 2 * s} Z',
    0x6B4A2E,
  );
  a.s('M$x ${y - 8 * s} L${x + 1} ${y - 13 * s}', 0x4A3222, 2 * s);
}

void _sincapBg(Art a) {
  a.p(_full, 0xD8EEE0);
  a.p('M120 120 H560 V512 H120 Z', 0xE6F3DB, op: 0.7);
  a.c(500, 84, 46, 0xFFF3C4, op: 0.7);
  a.c(500, 84, 30, 0xFFE59A);
  // Uzak çam tepeleri.
  for (final t in const [
    [140, 340, 120],
    [210, 330, 150],
    [270, 344, 100],
    [420, 336, 110],
    [490, 324, 150],
    [546, 340, 110],
  ]) {
    _pine(a, t[0], t[1], t[2], 0x7FB58A, 0x8EC096, trunk: 0x7FB58A);
  }
  a.p('M120 340 Q300 322 560 336 V512 H120 Z', 0x9CCB86);
  // Ön çamlar.
  _pine(a, 156, 450, 230, 0x2F6B45, 0x3E8654);
  _pine(a, 532, 456, 200, 0x2F6B45, 0x3E8654);
  _pine(a, 214, 470, 120, 0x3E8654, 0x4C9A62);
  a.p('M120 448 Q300 424 560 452 V512 H120 Z', 0x7FAE62);
  a.p('M120 486 Q300 470 560 488 V512 H120 Z', 0x5F9250);
  // Meşe palamutları ve mantar.
  _sincapAcorn(a, 470, 478, 0.9);
  _sincapAcorn(a, 440, 492, 0.7);
  _sincapAcorn(a, 250, 490, 0.8);
  a.p('M404 470 V484 H410 V470 Z', 0xF1E6D0);
  a.p('M394 470 Q407 450 420 470 Z', 0xD9503A);
  a.c(402, 464, 2, w);
  a.c(412, 462, 1.6, w);
  // Düşen yapraklar.
  for (final l in const [
    [136, 200, 0xE8782A, -25],
    [186, 250, 0xF2A03D, 20],
    [520, 270, 0xE8782A, 30],
    [488, 330, 0xF2A03D, -20],
  ]) {
    a.o(l[0], l[1], 11, 5, l[2], rot: l[3]);
  }
}

void _sincapEar(Art a, num x, num y, num dir, double s) {
  // Kulak: yuvarlak üçgen + üstünde koyu tutam.
  a.p(
    'M${x - dir * 20 * s} ${y + 18 * s} Q${x - dir * 24 * s} ${y - 14 * s} ${x - dir * 2 * s} ${y - 26 * s} '
    'Q${x + dir * 22 * s} ${y - 14 * s} ${x + dir * 22 * s} ${y + 22 * s} Z',
    0xC8702A,
  );
  a.p(
    'M${x - dir * 12 * s} ${y + 16 * s} Q${x - dir * 14 * s} ${y - 6 * s} ${x - dir * 1 * s} ${y - 14 * s} '
    'Q${x + dir * 13 * s} ${y - 6 * s} ${x + dir * 13 * s} ${y + 18 * s} Z',
    0xF4B6A4,
  );
  a.p(
    'M${x - dir * 2 * s} ${y - 22 * s} Q${x - dir * 6 * s} ${y - 40 * s} ${x - dir * 2 * s} ${y - 54 * s} '
    'Q${x + dir * 8 * s} ${y - 38 * s} ${x + dir * 10 * s} ${y - 20 * s} Z',
    0x8A4A1C,
  );
  a.p(
    'M${x + dir * 4 * s} ${y - 22 * s} Q${x + dir * 6 * s} ${y - 34 * s} ${x + dir * 14 * s} ${y - 42 * s} '
    'Q${x + dir * 18 * s} ${y - 28 * s} ${x + dir * 14 * s} ${y - 18 * s} Z',
    0xA85A22,
  );
}

void _sincapTail(Art a, num x, num y, double s) {
  // (x, y): kuyruğun gövdeye bağlandığı alt nokta; yukarı kıvrılan kabarık tüy.
  String q(num dx, num dy) => '${x + dx * s} ${y + dy * s}';
  final spine =
      'M${q(0, -4)} Q${q(78, 14)} ${q(92, -52)} Q${q(102, -108)} ${q(46, -144)}';
  a.s(spine, 0x9A4E18, 58 * s);
  a.s(spine, 0xDE8A3A, 48 * s);
  a.s(spine, 0xEDA255, 26 * s);
  a.s(
    'M${q(10, -10)} Q${q(70, 6)} ${q(84, -52)} Q${q(92, -96)} ${q(54, -126)}',
    0xB86222,
    3.5 * s,
  );
  // Kabarık tüy uçları.
  for (final b in const [
    [112.0, -40.0, 15.0],
    [106.0, -84.0, 16.0],
    [76.0, -128.0, 16.0],
  ]) {
    a.c(x + b[0] * s - 12 * s, y + b[1] * s, b[2] * s, 0xDE8A3A);
  }
  // Krem uç.
  a.c(x + 46 * s, y - 144 * s, 25 * s, 0xFBE3C0);
  a.c(x + 40 * s, y - 150 * s, 10 * s, w, op: 0.5);
}

void _sincapA(Art a, bool happy) {
  _sincapTail(a, 420, 196, 1.0);
  _sincapEar(a, 276, 90, -1, 1.0);
  _sincapEar(a, 404, 90, 1, 1.0);
  a.dome(0xE08A3C, 0xF2AE66, 0xB96722);
  for (final d in const [
    'M340 56 L340 80',
    'M320 60 Q318 72 322 80',
    'M360 60 Q362 72 358 80',
  ]) {
    a.s(d, 0xB96722, 4);
  }
  a.o(340, 170, 56, 36, 0xFBEBD2);
  a.o(340, 180, 40, 22, w, op: 0.4);
  a.cheeks(164, happy ? 0.9 : 0.55);
  if (happy) {
    a.s('M286 130 Q302 112 318 130', k, 4.5);
    a.s('M362 130 Q378 112 394 130', k, 4.5);
  } else {
    a.eye(302, 128, 13);
    a.eye(378, 128, 13);
  }
  a.o(340, 152, 10, 7, 0x4A2A18);
  a.o(336, 149.5, 3.2, 1.8, w, op: 0.6);
  if (happy) {
    a.p('M322 168 Q340 196 358 168 Q340 176 322 168 Z', k);
    a.o(340, 183, 8, 4.5, 0xE8758F);
  } else {
    a.s(
      'M340 159 L340 166 M340 166 Q331 175 322 169 M340 166 Q349 175 358 169',
      k,
      3,
    );
    a.p('M333 172 H340 V183 H333 Z', w);
    a.p('M340 172 H347 V183 H340 Z', w);
    a.s('M340 172 V183', 0xC9B79A, 1);
  }
  _sincapAcorn(a, 270, 186, 1.2);
}

void _sincapB(Art a, bool happy) {
  _sincapTail(a, 392, 170, 0.62);
  _sincapEar(a, 298, 86, -1, 0.62);
  _sincapEar(a, 382, 86, 1, 0.62);
  a.box(0xE08A3C, 0xF2AE66, 0xB96722);
  a.o(340, 146, 28, 16, 0xFBEBD2);
  if (happy) {
    a.s('M306 122 Q318 108 330 122', k, 3.5);
    a.s('M350 122 Q362 108 374 122', k, 3.5);
  } else {
    a.c(320, 122, 5.5, k);
    a.c(360, 122, 5.5, k);
    a.c(318, 120, 1.8, w);
    a.c(358, 120, 1.8, w);
  }
  a.o(340, 136, 6, 4.5, 0x4A2A18);
  if (happy) {
    a.p('M330 148 Q340 160 350 148 Q340 153 330 148 Z', k);
  } else {
    a.s(
      'M340 140 L340 144 M340 144 Q334 150 328 147 M340 144 Q346 150 352 147',
      k,
      2,
    );
    a.p('M336 148 H340 V154 H336 Z', w);
    a.p('M340 148 H344 V154 H340 Z', w);
  }
  _sincapAcorn(a, 300, 162, 0.6);
}
