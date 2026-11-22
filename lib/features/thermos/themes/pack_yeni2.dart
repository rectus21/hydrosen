// Yeni paket 2: Aslan, Geyik, İnek, Koyun, Maymun (tümü kod çizimi).
//
// Çizim alanı 120..560 x 8..512; tombul kapak a.dome, ince kapak a.box ile
// başlar; happy=true hedefe ulaşıldığında ifade değişir.

import 'dart:math' as math;
import 'dart:ui';

import '../art.dart';
import '../celebration_style.dart';
import '../thermos_theme.dart';

const _full = 'M120 8 H560 V512 H120 Z';

const List<ThermosTheme> yeni2Themes = [
  ThermosTheme(
    id: 'aslan',
    name: 'Aslan',
    glass: Color(0xFFFFF0D2),
    edge: Color(0xFF9A5A1E),
    water: Color(0xFF2E86C8),
    deepWater: Color(0xFF124E7C),
    waterSurface: Color(0xFFBFE0F5),
    mark: Color(0xFF4A2A10),
    label: Color(0xFF5E3512),
    band: Color(0xFFB5651D),
    bandLight: Color(0xFFE5A653),
    background: _aslanBg,
    capChubby: _aslanA,
    capSlim: _aslanB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0xF2B84B,
      0xFFD95A,
      0xE89A33,
      0xFFF1BD,
    ]),
  ),
  ThermosTheme(
    id: 'geyik',
    name: 'Geyik',
    glass: Color(0xFFE8F2DC),
    edge: Color(0xFF5E7A3E),
    water: Color(0xFF2F8FC0),
    deepWater: Color(0xFF14506E),
    waterSurface: Color(0xFFC4E6F5),
    mark: Color(0xFF3A4A22),
    label: Color(0xFF3A4A22),
    band: Color(0xFF7A4E2A),
    bandLight: Color(0xFFB98A5A),
    background: _geyikBg,
    capChubby: _geyikA,
    capSlim: _geyikB,
    celebration: CelebrationStyle(CelebrationKind.fallingLeaves, [
      0xE0A040,
      0xC8662A,
      0x97C459,
      0xF2C46A,
    ]),
  ),
  ThermosTheme(
    id: 'inek',
    name: 'İnek',
    glass: Color(0xFFF4F7EC),
    edge: Color(0xFF4A5A66),
    water: Color(0xFF3A8FD6),
    deepWater: Color(0xFF16508A),
    waterSurface: Color(0xFFC6E2F7),
    mark: Color(0xFF2C3A44),
    label: Color(0xFF2C3A44),
    band: Color(0xFFC0392B),
    bandLight: Color(0xFFE67E6E),
    background: _inekBg,
    capChubby: _inekA,
    capSlim: _inekB,
    celebration: CelebrationStyle(CelebrationKind.hearts, [
      0xF4A6C0,
      0xED93B1,
      0xFFFFFF,
    ]),
  ),
  ThermosTheme(
    id: 'koyun',
    name: 'Koyun',
    glass: Color(0xFFEAF3E4),
    edge: Color(0xFF5E7E4E),
    water: Color(0xFF3A8FD0),
    deepWater: Color(0xFF16508A),
    waterSurface: Color(0xFFCBE5F7),
    mark: Color(0xFF3A5A32),
    label: Color(0xFF3A5A32),
    band: Color(0xFF8AA87A),
    bandLight: Color(0xFFC2D6B4),
    background: _koyunBg,
    capChubby: _koyunA,
    capSlim: _koyunB,
    celebration: CelebrationStyle(CelebrationKind.bubbles, [
      0xFFFFFF,
      0xDDEFFB,
      0xBFE0F5,
    ]),
  ),
  ThermosTheme(
    id: 'maymun',
    name: 'Maymun',
    glass: Color(0xFFF1EBCB),
    edge: Color(0xFF5E7A2E),
    water: Color(0xFF2F8FB5),
    deepWater: Color(0xFF14506E),
    waterSurface: Color(0xFFBDE3EE),
    mark: Color(0xFF3F5A1E),
    label: Color(0xFF3F5A1E),
    band: Color(0xFF6E4524),
    bandLight: Color(0xFFB08458),
    background: _maymunBg,
    capChubby: _maymunA,
    capSlim: _maymunB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0xF2C84B,
      0x6DBE5B,
      0xE2574C,
      0x4BA3E3,
    ]),
  ),
];

// --- Ortak yardımcılar -------------------------------------------------------

/// Elipsin çevresine dizilmiş daireler (yele, yün).
void _ring(
  Art a,
  double cx,
  double cy,
  double rx,
  double ry,
  double r,
  int n,
  int hex, {
  double phase = 0,
}) {
  for (var i = 0; i < n; i++) {
    final t = (i + phase) * 2 * math.pi / n;
    a.c(cx + rx * math.cos(t), cy + ry * math.sin(t), r, hex);
  }
}

/// Mutlu kapalı göz yayı.
void _joy(Art a, double x, double y, double half, double width) =>
    a.s('M${x - half} $y Q$x ${y - half * 1.25} ${x + half} $y', k, width);

void _tree(Art a, double x, double base, double h, int trunk, int crown) {
  a.s('M$x $base Q${x + 4} ${base - h * 0.5} ${x + 2} ${base - h}', trunk, 7);
  a.s(
    'M${x + 3} ${base - h * 0.55} Q${x + 18} ${base - h * 0.7} ${x + 30} ${base - h * 0.9}',
    trunk,
    4,
  );
  a.s(
    'M${x + 2} ${base - h * 0.6} Q${x - 14} ${base - h * 0.75} ${x - 26} ${base - h * 0.95}',
    trunk,
    4,
  );
  a.o(x + 2, base - h - 4, 46, 11, crown);
  a.o(x + 30, base - h * 0.92, 28, 8, crown);
  a.o(x - 26, base - h * 0.98, 28, 8, crown);
}

// --- Aslan -------------------------------------------------------------------

void _aslanBg(Art a) {
  a.p(_full, 0xFFD9A6);
  a.p('M120 8 H560 V150 H120 Z', 0xF2A07A, op: 0.55);
  a.p('M120 8 H560 V70 H120 Z', 0xE0767A, op: 0.4);
  // Gün batımı.
  a.c(410, 300, 92, 0xFFE9B0, op: 0.35);
  a.c(410, 300, 66, 0xFFE08A);
  a.c(410, 300, 48, 0xFFF1BD);
  // Uzak dağlar.
  a.p(
    'M120 330 L200 270 L260 318 L330 262 L420 330 L500 280 L560 320 V380 H120 Z',
    0xD98A6A,
    op: 0.8,
  );
  // Savan.
  a.p('M120 350 Q250 322 380 352 Q480 372 560 346 V512 H120 Z', 0xE8B25E);
  a.p('M120 420 Q260 392 400 424 Q490 442 560 416 V512 H120 Z', 0xC98B3E);
  a.p('M120 474 Q300 452 560 478 V512 H120 Z', 0x9A6228);
  // Akasya ağaçları.
  _tree(a, 176, 396, 96, 0x5A3A1E, 0x4F5A2A);
  _tree(a, 514, 372, 70, 0x5A3A1E, 0x4F5A2A);
  // Kuşlar.
  a.s('M236 130 q8 -8 16 0 q8 -8 16 0', 0x6B3A1E, 2.5);
  a.s('M470 96 q6 -6 12 0 q6 -6 12 0', 0x6B3A1E, 2.5);
  a.s('M180 70 q5 -5 10 0 q5 -5 10 0', 0x6B3A1E, 2);
  // Otlar.
  for (final x in const [140, 150, 210, 480, 500, 540]) {
    a.s(
      'M$x 490 q-4 -16 -9 -24 M$x 490 q2 -18 4 -28 M$x 490 q6 -14 12 -20',
      0x7A4E1E,
      2,
    );
  }
}

void _aslanEye(Art a, double x, double y, double r) {
  a.o(x, y, r, r * 1.1, 0xE8A21C);
  a.o(x, y + r * 0.1, r * 0.55, r * 0.85, 0x3A1E0E);
  a.c(x - r * 0.3, y - r * 0.35, r * 0.28, w);
}

void _aslanA(Art a, bool happy) {
  // Katmanlı yele.
  _ring(a, 340, 132, 104, 88, 31, 16, 0xA85A1A);
  _ring(a, 340, 132, 92, 76, 29, 16, 0xC87625, phase: 0.5);
  _ring(a, 340, 132, 80, 66, 27, 14, 0xE29A38);
  a.dome(0xE29A38, 0xF0B456, 0xC87625);
  // Kulaklar yelenin içinde.
  for (final x in const [276, 404]) {
    a.c(x, 66, 19, 0xE8B466);
    a.c(x, 68, 10, 0x9A5A3A);
  }
  // Yüz.
  a.o(340, 148, 64, 58, 0xF3C77E);
  a.o(340, 132, 46, 28, 0xFAD995, op: 0.6);
  a.cheeks(172, 0.4);
  if (happy) {
    _joy(a, 308, 128, 14, 4.5);
    _joy(a, 372, 128, 14, 4.5);
  } else {
    _aslanEye(a, 308, 128, 13);
    _aslanEye(a, 372, 128, 13);
    a.s('M290 108 Q308 98 326 108', 0xA85A1A, 4.5);
    a.s('M354 108 Q372 98 390 108', 0xA85A1A, 4.5);
  }
  // Burun sırtı, ağız çevresi ve geniş burun.
  a.s('M340 132 L340 144', 0xD9A55B, 5);
  a.o(324, 176, 24, 17, 0xFBE6B8);
  a.o(356, 176, 24, 17, 0xFBE6B8);
  a.p(
    'M320 148 Q340 138 360 148 Q358 164 340 170 Q322 164 320 148 Z',
    0x6B3A1E,
  );
  a.o(331, 148, 8, 3.2, w, op: 0.6);
  for (final d in const [-1, 1]) {
    a.c(340 + d * 18, 178, 1.8, 0x8A5A32);
    a.c(340 + d * 26, 182, 1.8, 0x8A5A32);
    a.c(340 + d * 14, 186, 1.8, 0x8A5A32);
  }
  if (happy) {
    a.s('M340 170 L340 176', k, 3);
    a.p('M318 178 Q340 212 362 178 Q340 190 318 178 Z', 0x5A1E2A);
    a.o(340, 197, 11, 7, 0xE8758F);
    a.s('M340 176 Q326 192 318 178 M340 176 Q354 192 362 178', k, 3);
  } else {
    a.s(
      'M340 170 L340 180 M340 180 Q328 192 316 182 M340 180 Q352 192 364 182',
      k,
      3.2,
    );
  }
}

void _aslanB(Art a, bool happy) {
  _ring(a, 340, 128, 70, 52, 22, 14, 0xA85A1A);
  _ring(a, 340, 128, 60, 44, 20, 14, 0xC87625, phase: 0.5);
  a.box(0xE29A38, 0xF0B456, 0xC87625);
  _ring(a, 340, 128, 54, 40, 19, 12, 0xE29A38);
  _ring(a, 340, 128, 52, 38, 16, 12, 0xF0B456, phase: 0.5);
  for (final x in const [290, 390]) {
    a.c(x, 88, 13, 0xE8B466);
    a.c(x, 90, 7, 0x9A5A3A);
  }
  a.o(340, 134, 42, 34, 0xF3C77E);
  if (happy) {
    _joy(a, 322, 124, 8, 3.2);
    _joy(a, 358, 124, 8, 3.2);
  } else {
    _aslanEye(a, 322, 123, 7.5);
    _aslanEye(a, 358, 123, 7.5);
  }
  a.o(332, 146, 14, 10, 0xFBE6B8);
  a.o(348, 146, 14, 10, 0xFBE6B8);
  a.p(
    'M328 134 Q340 128 352 134 Q350 144 340 148 Q330 144 328 134 Z',
    0x6B3A1E,
  );
  if (happy) {
    a.p('M328 152 Q340 168 352 152 Q340 158 328 152 Z', 0x5A1E2A);
  } else {
    a.s(
      'M340 148 L340 154 M340 154 Q333 160 326 156 M340 154 Q347 160 354 156',
      k,
      2.2,
    );
  }
}

// --- Geyik -------------------------------------------------------------------

void _geyikBg(Art a) {
  a.p(_full, 0xDCEFCB);
  a.p('M120 8 H560 V230 H120 Z', 0xF2F8D6, op: 0.6);
  // Sisli orman açıklığı, büyük termosun baş ve gövde konturunu temiz tutar.
  a.p('M236 8 Q340 112 444 8 V420 H236 Z', 0xFFFBE0, op: 0.13);
  // Işık huzmeleri.
  a.p('M200 8 L250 8 L330 420 L250 420 Z', 0xFFFBD8, op: 0.35);
  a.p('M440 8 L480 8 L520 420 L450 420 Z', 0xFFFBD8, op: 0.28);
  // Uzak çam sırası.
  for (final x in const [130, 180, 236, 440, 500, 548]) {
    a.p('M${x - 30} 360 L$x 200 L${x + 30} 360 Z', 0x8DBE82, op: 0.7);
  }
  // Ön çamlar.
  for (final t in const [
    [150, 420, 1.0],
    [530, 410, 0.9],
  ]) {
    final x = t[0], y = t[1], s = t[2];
    a.p('M${x - 8} $y h16 v40 h-16 Z', 0x6B4A2A);
    a.p(
      'M${x - 46 * s} ${y + 4} L$x ${y - 120 * s} L${x + 46 * s} ${y + 4} Z',
      0x3F7A4A,
    );
    a.p(
      'M${x - 38 * s} ${y - 46 * s} L$x ${y - 150 * s} L${x + 38 * s} ${y - 46 * s} Z',
      0x4E8E58,
    );
    a.p(
      'M${x - 28 * s} ${y - 94 * s} L$x ${y - 176 * s} L${x + 28 * s} ${y - 94 * s} Z',
      0x5FA168,
    );
  }
  // Orman zemini.
  a.p('M120 410 Q260 380 380 410 Q480 434 560 404 V512 H120 Z', 0x8CC070);
  a.p('M120 460 Q280 436 440 462 Q510 474 560 456 V512 H120 Z', 0x6BA655);
  a.p(
    'M300 512 Q312 456 302 410 Q340 392 378 410 Q368 456 380 512 Z',
    0xB8D78C,
    op: 0.3,
  );
  // Mantarlar.
  for (final m in const [
    [172, 478, 1.0],
    [210, 494, 0.7],
    [506, 470, 1.1],
    [470, 496, 0.65],
  ]) {
    final x = m[0], y = m[1], s = m[2];
    a.p(
      'M${x - 7 * s} ${y - 14 * s} h${14 * s} l${3 * s} ${16 * s} h${-20 * s} Z',
      0xF6E6CC,
    );
    a.p(
      'M${x - 26 * s} ${y - 12 * s} Q$x ${y - 56 * s} ${x + 26 * s} ${y - 12 * s} Q$x ${y - 6 * s} ${x - 26 * s} ${y - 12 * s} Z',
      0xD9483B,
    );
    a.c(x - 10 * s, y - 28 * s, 3.4 * s, w);
    a.c(x + 8 * s, y - 34 * s, 3 * s, w);
    a.c(x + 14 * s, y - 22 * s, 2.4 * s, w);
  }
  // Eğrelti otları.
  for (final x in const [240, 450]) {
    for (final d in const [-26, -12, 0, 12, 26]) {
      a.s(
        'M$x 500 Q${x + d * 0.5} ${480 - d.abs()} ${x + d} ${470 + d.abs() * 0.6}',
        0x3F7A4A,
        3,
      );
    }
  }
}

void _geyikAntler(Art a, int d, double x, double y, double s) {
  String p(double dx, double dy) => '${x + d * dx * s} ${y + dy * s}';
  const c = 0x7A4E2A;
  a.s('M${p(0, 0)} Q${p(6, -26)} ${p(2, -54)}', c, 6.5 * s);
  a.s('M${p(4, -22)} Q${p(18, -30)} ${p(24, -48)}', c, 5 * s);
  a.s('M${p(3, -40)} Q${p(-8, -50)} ${p(-12, -66)}', c, 4.5 * s);
  a.s('M${p(2, -54)} Q${p(6, -64)} ${p(4, -76)}', c, 4 * s);
  a.s('M${p(0, 0)} Q${p(6, -26)} ${p(2, -54)}', 0xA9774A, 2 * s);
}

void _geyikEar(Art a, int d, double x, double y, double s) {
  a.o(x, y, 38 * s, 17 * s, 0xB77A44, rot: d * 32);
  a.o(x + d * 2, y + 1, 29 * s, 10.5 * s, 0xF2B8A4, rot: d * 32);
  a.o(x + d * 6, y + 2, 18 * s, 5 * s, 0xFAD6C6, rot: d * 32, op: 0.8);
}

void _geyikA(Art a, bool happy) {
  _geyikAntler(a, -1, 304, 76, 1.05);
  _geyikAntler(a, 1, 376, 76, 1.05);
  _geyikEar(a, -1, 246, 96, 1);
  _geyikEar(a, 1, 434, 96, 1);
  a.dome(0xC98B50, 0xE0AB72, 0xA66D38);
  // Alında beyaz benekler.
  for (final s in const [
    [340, 74, 6.0],
    [318, 84, 5.0],
    [362, 84, 5.0],
    [302, 100, 4.0],
    [378, 100, 4.0],
    [340, 94, 4.0],
  ]) {
    a.o(s[0], s[1], s[2], s[2] * 0.8, w, op: 0.9);
  }
  // Burun çevresi.
  a.o(340, 170, 44, 34, 0xF2DDB8);
  a.o(340, 158, 30, 18, 0xFAEBCF, op: 0.7);
  a.cheeks(164, 0.4);
  if (happy) {
    _joy(a, 302, 128, 14, 4.5);
    _joy(a, 378, 128, 14, 4.5);
  } else {
    a.o(302, 128, 14, 16, k);
    a.o(378, 128, 14, 16, k);
    a.c(297, 121, 5.4, w);
    a.c(373, 121, 5.4, w);
    a.c(306, 134, 2.4, w);
    a.c(382, 134, 2.4, w);
  }
  a.o(340, 152, 15, 11, 0x3A2418);
  a.o(335, 148, 5, 2.6, w, op: 0.55);
  if (happy) {
    a.s('M340 163 L340 170', k, 3);
    a.p('M318 174 Q340 206 362 174 Q340 184 318 174 Z', 0x5A1E2A);
    a.o(340, 192, 10, 6, 0xE8758F);
    a.s('M340 170 Q326 184 318 174 M340 170 Q354 184 362 174', k, 3);
  } else {
    a.s(
      'M340 163 L340 172 M340 172 Q328 184 318 175 M340 172 Q352 184 362 175',
      k,
      3,
    );
  }
}

void _geyikB(Art a, bool happy) {
  _geyikAntler(a, -1, 292, 98, 0.78);
  _geyikAntler(a, 1, 388, 98, 0.78);
  _geyikEar(a, -1, 280, 108, 0.62);
  _geyikEar(a, 1, 400, 108, 0.62);
  a.box(0xC98B50, 0xE0AB72, 0xA66D38);
  for (final s in const [
    [340, 99, 4.0],
    [324, 106, 3.4],
    [356, 106, 3.4],
  ]) {
    a.o(s[0], s[1], s[2], s[2] * 0.8, w, op: 0.9);
  }
  a.o(340, 148, 32, 22, 0xF2DDB8);
  if (happy) {
    _joy(a, 318, 122, 8, 3.2);
    _joy(a, 362, 122, 8, 3.2);
  } else {
    a.o(318, 122, 8, 9.5, k);
    a.o(362, 122, 8, 9.5, k);
    a.c(315, 118, 3, w);
    a.c(359, 118, 3, w);
  }
  a.o(340, 138, 10, 7.5, 0x3A2418);
  a.o(337, 135, 3, 1.8, w, op: 0.55);
  if (happy) {
    a.p('M328 152 Q340 168 352 152 Q340 158 328 152 Z', 0x5A1E2A);
  } else {
    a.s(
      'M340 145 L340 152 M340 152 Q332 159 326 154 M340 152 Q348 159 354 154',
      k,
      2.2,
    );
  }
}

// --- İnek --------------------------------------------------------------------

void _inekBg(Art a) {
  a.p(_full, 0xCFE8FA);
  a.c(510, 76, 34, 0xFFE08A);
  a.c(510, 76, 23, 0xFFF1BD);
  for (final cl in const [
    [190, 80],
    [440, 150],
  ]) {
    a.o(cl[0], cl[1], 40, 14, w, op: 0.92);
    a.o(cl[0] + 26, cl[1] - 9, 25, 13, w, op: 0.92);
    a.o(cl[0] - 22, cl[1] - 6, 20, 10, w, op: 0.92);
  }
  // Tepe ve çayır.
  a.p(
    'M120 286 Q226 244 330 284 Q454 324 560 268 V382 H120 Z',
    0xC7DF9D,
    op: 0.52,
  );
  a.p('M120 330 Q240 290 360 330 Q460 364 560 320 V512 H120 Z', 0xA8D67E);
  a.p('M120 410 Q260 376 400 412 Q490 432 560 404 V512 H120 Z', 0x84C05E);
  a.p('M120 468 Q300 446 560 470 V512 H120 Z', 0x62A546);
  // Çayır yolu zemine derinlik verir; termosun arkasında yalnızca yumuşak ton kalır.
  a.p(
    'M314 512 Q326 462 310 412 Q340 392 370 412 Q354 462 366 512 Z',
    0xD8C995,
    op: 0.42,
  );
  // Ahır.
  a.p('M126 410 V312 L176 276 L226 312 V410 Z', 0xC0392B);
  a.p('M118 316 L176 270 L234 316 L226 322 L176 284 L126 322 Z', 0x7A2418);
  a.p('M156 410 V350 H196 V410 Z', 0xF6EBDD);
  a.s('M156 350 L196 410 M196 350 L156 410', 0xC0392B, 3);
  a.o(176, 310, 9, 9, 0xF6EBDD);
  a.p('M226 410 V336 Q226 322 240 322 Q254 322 254 336 V410 Z', 0xB8B5AE);
  // Çit.
  for (final x in const [440, 468, 496, 524, 552]) {
    a.p('M${x - 5} 388 h10 v52 h-10 Z', 0xF2E4C8);
  }
  a.p('M432 398 H560 V408 H432 Z', 0xE0CDA6);
  a.p('M432 418 H560 V428 H432 Z', 0xE0CDA6);
  // Çiçekler.
  for (final f in const [
    [150, 450, 0xF4A6C0],
    [196, 480, 0xFFFFFF],
    [240, 454, 0xFAC775],
    [480, 462, 0xF4A6C0],
    [520, 488, 0xFFFFFF],
    [452, 490, 0xFAC775],
    [144, 496, 0xFAC775],
  ]) {
    a.s('M${f[0]} ${f[1]} v18', 0x4E9F44, 2);
    for (var i = 0; i < 5; i++) {
      final ang = i * 72 * math.pi / 180;
      a.c(f[0] + 5.5 * math.cos(ang), f[1] + 5.5 * math.sin(ang), 4.2, f[2]);
    }
    a.c(f[0], f[1], 3, 0xEF9F27);
  }
}

void _inekPatch(
  Art a,
  Path clip,
  double x,
  double y,
  double rx,
  double ry,
  double rot,
) {
  a.canvas.save();
  a.canvas.clipPath(clip);
  a.o(x, y, rx, ry, 0x2C2C2A, rot: rot);
  a.canvas.restore();
}

void _inekEye(Art a, double x, double y, double r) {
  a.o(x, y, r, r * 1.15, k);
  a.c(x - r * 0.35, y - r * 0.4, r * 0.38, w);
  a.c(x + r * 0.3, y + r * 0.35, r * 0.15, w);
}

void _inekA(Art a, bool happy) {
  // Boynuzlar ve kulaklar kafanın arkasından çıkar.
  for (final d in const [-1, 1]) {
    a.p(
      'M${340 + d * 38} 62 Q${340 + d * 56} 30 ${340 + d * 74} 40 Q${340 + d * 62} 48 ${340 + d * 56} 68 Z',
      0xF4E4C0,
    );
    a.s(
      'M${340 + d * 40} 62 Q${340 + d * 54} 38 ${340 + d * 70} 42',
      0xD6BE8C,
      2,
    );
  }
  a.o(238, 104, 34, 16, 0x2C2C2A, rot: 24);
  a.o(442, 104, 34, 16, 0xFAFAF5, rot: -24);
  a.o(442, 105, 24, 9, 0xF6B6C4, rot: -24);
  a.o(442, 104, 34, 16, 0xC9CCC4, rot: -24, strokeWidth: 2);
  // Küpe.
  a.p('M456 112 h14 v16 h-14 Z', 0xFAC775);
  a.c(463, 120, 2.4, 0xB07A22);
  a.dome(0xFAFAF5, w, 0xDCDDD4);
  _inekPatch(
    a,
    Path()..addOval(
      Rect.fromCenter(center: const Offset(340, 130), width: 192, height: 160),
    ),
    284,
    88,
    40,
    28,
    -18,
  );
  // Tepe tutamı.
  a.p('M330 56 Q338 40 342 56 Q350 42 356 58 Q344 64 330 56 Z', 0x6B5A4A);
  a.cheeks(160, 0.4);
  // Pembe burun-ağız bölgesi.
  a.o(340, 172, 54, 33, 0xF6B6C4);
  a.o(340, 160, 38, 16, 0xFAD0DA, op: 0.7);
  a.o(322, 174, 6, 9, 0xC0607A);
  a.o(358, 174, 6, 9, 0xC0607A);
  if (happy) {
    _joy(a, 306, 124, 13, 4.5);
    _joy(a, 374, 124, 13, 4.5);
    a.p('M318 186 Q340 212 362 186 Q340 194 318 186 Z', 0x5A1E2A);
    a.o(340, 199, 9, 5, 0xE8758F);
  } else {
    _inekEye(a, 306, 124, 12);
    _inekEye(a, 374, 124, 12);
    a.s('M326 192 Q340 202 354 192', k, 3);
  }
}

void _inekB(Art a, bool happy) {
  for (final d in const [-1, 1]) {
    a.p(
      'M${340 + d * 26} 94 Q${340 + d * 38} 66 ${340 + d * 52} 74 Q${340 + d * 42} 80 ${340 + d * 40} 98 Z',
      0xF4E4C0,
    );
  }
  a.o(278, 112, 24, 11, 0x2C2C2A, rot: 24);
  a.o(402, 112, 24, 11, 0xFAFAF5, rot: -24);
  a.o(402, 113, 16, 6, 0xF6B6C4, rot: -24);
  a.box(0xFAFAF5, w, 0xDCDDD4);
  _inekPatch(
    a,
    Path()..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(284, 90, 112, 74),
        const Radius.circular(24),
      ),
    ),
    302,
    94,
    26,
    15,
    -12,
  );
  a.o(340, 146, 36, 19, 0xF6B6C4);
  a.o(329, 148, 4, 6, 0xC0607A);
  a.o(351, 148, 4, 6, 0xC0607A);
  if (happy) {
    _joy(a, 320, 116, 8, 3.2);
    _joy(a, 360, 116, 8, 3.2);
    a.p('M330 156 Q340 168 350 156 Q340 160 330 156 Z', 0x5A1E2A);
  } else {
    _inekEye(a, 320, 116, 7);
    _inekEye(a, 360, 116, 7);
    a.s('M332 158 Q340 164 348 158', k, 2.2);
  }
}

// --- Koyun -------------------------------------------------------------------

void _koyunBg(Art a) {
  a.p(_full, 0xD3ECFB);
  a.p('M120 8 H560 V160 H120 Z', 0xE6F4FD, op: 0.7);
  a.c(150, 80, 30, 0xFFF3C4);
  a.c(150, 80, 20, 0xFFE59A);
  for (final cl in const [
    [440, 80, 1.2],
    [240, 170, 1.0],
    [500, 230, 0.8],
  ]) {
    final x = cl[0], y = cl[1], s = cl[2];
    a.o(x, y, 46 * s, 15 * s, w);
    a.o(x + 26 * s, y - 10 * s, 28 * s, 15 * s, w);
    a.o(x - 24 * s, y - 7 * s, 22 * s, 11 * s, w);
  }
  // Yeşil tepeler.
  a.p('M120 320 Q230 270 340 322 Q450 372 560 310 V512 H120 Z', 0xB7DD8E);
  a.p('M120 390 Q250 346 390 394 Q480 420 560 384 V512 H120 Z', 0x92C86A);
  a.p('M120 456 Q300 424 560 458 V512 H120 Z', 0x6DB04F);
  // Merkezde düşük kontrastlı vadi açıklığı.
  a.p(
    'M286 512 Q306 452 300 392 Q340 370 380 392 Q374 452 394 512 Z',
    0xA9D882,
    op: 0.34,
  );
  // Çit.
  for (final x in const [138, 170, 202, 482, 514, 546]) {
    a.p('M${x - 5} 370 h10 v58 h-10 Z', 0xF2E4C8);
  }
  a.p('M126 382 H214 V392 H126 Z', 0xE0CDA6);
  a.p('M126 404 H214 V414 H126 Z', 0xE0CDA6);
  a.p('M470 382 H560 V392 H470 Z', 0xE0CDA6);
  a.p('M470 404 H560 V414 H470 Z', 0xE0CDA6);
  // Çiçek ve ot.
  for (final f in const [
    [160, 470, 0xFFFFFF],
    [212, 492, 0xFAC775],
    [490, 474, 0xF4A6C0],
    [530, 494, 0xFFFFFF],
    [452, 496, 0xFAC775],
  ]) {
    a.s('M${f[0]} ${f[1]} v14', 0x4E9F44, 2);
    for (var i = 0; i < 5; i++) {
      final ang = i * 72 * math.pi / 180;
      a.c(f[0] + 5 * math.cos(ang), f[1] + 5 * math.sin(ang), 3.8, f[2]);
    }
    a.c(f[0], f[1], 2.6, 0xEF9F27);
  }
}

void _koyunWool(Art a, double cx, double cy, double rx, double ry, double r) {
  _ring(a, cx, cy, rx, ry, r, 15, 0xE3D6BE);
  _ring(a, cx, cy - 2, rx * 0.95, ry * 0.95, r, 15, 0xFFF8EC, phase: 0.5);
  _ring(a, cx, cy - 4, rx * 0.72, ry * 0.7, r * 0.85, 12, 0xFFFFFF);
  // Kıvrım çizgileri.
  for (var i = 0; i < 15; i++) {
    final t = (i + 0.5) * 2 * math.pi / 15;
    final x = cx + rx * 0.95 * math.cos(t);
    final y = cy - 2 + ry * 0.95 * math.sin(t);
    a.s(
      'M${x - r * 0.45} ${y + r * 0.1} Q$x ${y - r * 0.55} ${x + r * 0.4} ${y + r * 0.05}',
      0xE3D6BE,
      1.6,
    );
  }
}

void _koyunFace(
  Art a,
  bool happy,
  double cx,
  double cy,
  double fw,
  double fh,
  double e,
  double ey,
) {
  // Kulaklar yüzün yanında.
  for (final d in const [-1, 1]) {
    a.o(
      cx + d * (fw + 6),
      cy - fh * 0.25,
      24 * e,
      11 * e,
      0xE2BC8C,
      rot: d * 22,
    );
    a.o(
      cx + d * (fw + 8),
      cy - fh * 0.25,
      15 * e,
      6 * e,
      0xF2B8A4,
      rot: d * 22,
    );
  }
  a.o(cx, cy, fw, fh, 0xF6E0C0);
  a.o(cx, cy - fh * 0.25, fw * 0.7, fh * 0.45, 0xFBEBD2, op: 0.7);
  a.o(cx - fw * 0.66, cy + fh * 0.32, 13 * e, 8 * e, 0xED93B1, op: 0.45);
  a.o(cx + fw * 0.66, cy + fh * 0.32, 13 * e, 8 * e, 0xED93B1, op: 0.45);
  if (happy) {
    _joy(a, cx - fw * 0.42, ey, 10 * e, 3.6 * e);
    _joy(a, cx + fw * 0.42, ey, 10 * e, 3.6 * e);
  } else {
    a.eye(cx - fw * 0.42, ey, 9 * e);
    a.eye(cx + fw * 0.42, ey, 9 * e);
  }
  final ny = cy + fh * 0.2;
  a.o(cx, ny, 10 * e, 7 * e, 0xC0607A);
  a.o(cx - 3 * e, ny - 2 * e, 3.4 * e, 1.8 * e, w, op: 0.6);
  if (happy) {
    a.p(
      'M${cx - 14 * e} ${ny + 10 * e} Q$cx ${ny + 34 * e} ${cx + 14 * e} ${ny + 10 * e} Q$cx ${ny + 18 * e} ${cx - 14 * e} ${ny + 10 * e} Z',
      0x5A1E2A,
    );
  } else {
    a.s(
      'M$cx ${ny + 6 * e} v${6 * e} M$cx ${ny + 12 * e} Q${cx - 7 * e} ${ny + 20 * e} ${cx - 13 * e} ${ny + 14 * e} M$cx ${ny + 12 * e} Q${cx + 7 * e} ${ny + 20 * e} ${cx + 13 * e} ${ny + 14 * e}',
      k,
      2.8 * e,
    );
  }
}

void _koyunA(Art a, bool happy) {
  _koyunWool(a, 340, 118, 92, 62, 34);
  a.dome(0xFFF8EC, 0xFFF8EC, 0xF3EAD8);
  // Üstte kıvırcık perçem.
  for (final p in const [
    [340, 62, 22.0],
    [312, 68, 19.0],
    [368, 68, 19.0],
  ]) {
    a.c(p[0], p[1], p[2], 0xFFFFFF);
    a.s(
      'M${p[0] - p[2] * 0.5} ${p[1] + 2} Q${p[0]} ${p[1] - p[2] * 0.9} ${p[0] + p[2] * 0.5} ${p[1] + 2}',
      0xD9C9A8,
      2,
    );
  }
  _koyunFace(a, happy, 340, 148, 60, 56, 1, 134);
}

void _koyunB(Art a, bool happy) {
  _koyunWool(a, 340, 122, 62, 38, 24);
  a.box(0xFFF8EC, 0xFFF8EC, 0xF3EAD8);
  for (final p in const [
    [340, 84, 14.0],
    [320, 88, 12.0],
    [360, 88, 12.0],
  ]) {
    a.c(p[0], p[1], p[2], 0xFFFFFF);
  }
  _koyunFace(a, happy, 340, 134, 38, 32, 0.62, 126);
}

// --- Maymun ------------------------------------------------------------------

void _banana(Art a, double x, double y, double dir) {
  for (var i = 0; i < 3; i++) {
    final ox = x + dir * i * 11, oy = y + i * 3;
    a.p(
      'M$ox $oy Q${ox + dir * 26} ${oy + 18} ${ox + dir * 14} ${oy + 56} Q${ox + dir * 12} ${oy + 60} ${ox + dir * 8} ${oy + 56} Q${ox + dir * 14} ${oy + 24} ${ox - dir * 4} ${oy + 8} Z',
      i == 1 ? 0xF7D54A : 0xF2C230,
    );
    a.p(
      'M${ox + dir * 14} ${oy + 56} l${dir * 1.0} 6 l${-dir * 5.0} -2 Z',
      0x6B4A22,
    );
  }
  a.s('M$x ${y - 14} L$x ${y + 2}', 0x4E7A2A, 5);
}

void _jungleLeaf(Art a, double x, double y, double len, double rot, int hex) {
  a.o(x, y, len, len * 0.32, hex, rot: rot);
  final r = rot * math.pi / 180;
  a.s(
    'M${x - len * math.cos(r)} ${y - len * math.sin(r)} L${x + len * math.cos(r)} ${y + len * math.sin(r)}',
    0x2E6A34,
    2,
  );
}

void _maymunBg(Art a) {
  a.p(_full, 0xCDEBC0);
  a.p('M120 8 H560 V200 H120 Z', 0xE8F5C8, op: 0.6);
  // Uzak gövdeler kenarlara çekildi; büyük termosun merkezi sakin kaldı.
  for (final x in const [168, 224, 456, 512]) {
    a.p('M${x - 9} 8 h18 V420 h-18 Z', 0x6BA06A, op: 0.5);
  }
  a.p('M244 8 Q340 112 436 8 V416 H244 Z', 0xF1F7CC, op: 0.14);
  // Büyük yapraklar.
  _jungleLeaf(a, 150, 300, 70, -35, 0x3F8E48);
  _jungleLeaf(a, 142, 340, 60, 25, 0x2F7A3A);
  _jungleLeaf(a, 540, 280, 72, 38, 0x3F8E48);
  _jungleLeaf(a, 548, 330, 58, -22, 0x2F7A3A);
  _jungleLeaf(a, 130, 130, 56, 30, 0x4E9E54);
  _jungleLeaf(a, 550, 120, 56, -30, 0x4E9E54);
  // Sarmaşıklar.
  for (final v in const [
    [170, 150, 0x3B7A3A],
    [236, 110, 0x4E8A3E],
    [454, 120, 0x3B7A3A],
    [520, 160, 0x4E8A3E],
  ]) {
    final x = v[0], len = v[1], c = v[2];
    a.s(
      'M$x 8 Q${x + 14} ${len * 0.4} ${x - 6} ${len * 0.65} Q${x - 16} ${len * 0.85} $x $len',
      c,
      4,
    );
    a.o(x + 8, len * 0.35, 9, 4.5, c, rot: 40);
    a.o(x - 10, len * 0.62, 9, 4.5, c, rot: -40);
    a.o(x - 2, len, 8, 4, c, rot: 80);
  }
  // Zemin.
  a.p('M120 400 Q250 372 380 402 Q480 424 560 392 V512 H120 Z', 0x7DB85F);
  a.p('M120 456 Q290 430 440 458 Q510 470 560 450 V512 H120 Z', 0x4E9A48);
  a.p(
    'M306 512 Q318 462 310 414 Q340 394 370 414 Q362 462 374 512 Z',
    0x8AC36C,
    op: 0.3,
  );
  // Muz salkımları.
  _banana(a, 168, 190, 1);
  _banana(a, 520, 208, -1);
  // Tropik çiçek.
  for (final f in const [
    [200, 488, 0xF06A8A],
    [500, 490, 0xF29A3A],
  ]) {
    for (var i = 0; i < 5; i++) {
      final ang = (i * 72 - 90) * math.pi / 180;
      a.o(
        f[0] + 8 * math.cos(ang),
        f[1] + 8 * math.sin(ang),
        7,
        4,
        f[2],
        rot: i * 72 - 90,
      );
    }
    a.c(f[0], f[1], 3.5, 0xFFE08A);
  }
}

void _maymunA(Art a, bool happy) {
  // Büyük yan kulaklar.
  for (final d in const [-1, 1]) {
    a.c(340 + d * 98, 134, 31, 0x7A4A28);
    a.c(340 + d * 98, 134, 31, 0x5E3818, op: 0.35);
    a.c(340 + d * 99, 135, 20, 0xF2C8A0);
    a.c(340 + d * 100, 136, 12, 0xE8AE86, op: 0.7);
  }
  a.dome(0x8A5A32, 0xA87848, 0x6E4524);
  // Alın kıvrımı.
  a.s('M326 62 Q340 44 354 62', 0x5E3818, 5);
  // Açık renk yüz maskesi.
  a.c(316, 128, 33, 0xF6D9B0);
  a.c(364, 128, 33, 0xF6D9B0);
  a.o(340, 164, 52, 40, 0xF6D9B0);
  a.o(340, 180, 36, 24, 0xFBE9CC);
  a.cheeks(176, 0.4);
  if (happy) {
    _joy(a, 316, 124, 11, 4.2);
    _joy(a, 364, 124, 11, 4.2);
  } else {
    a.eye(316, 124, 10.5);
    a.eye(364, 124, 10.5);
    a.s('M300 106 Q316 98 330 106', 0x6E4524, 3.5);
    a.s('M350 106 Q364 98 380 106', 0x6E4524, 3.5);
  }
  a.o(331, 154, 4, 5.5, 0x6E4524);
  a.o(349, 154, 4, 5.5, 0x6E4524);
  if (happy) {
    a.p('M312 170 Q340 214 368 170 Q340 182 312 170 Z', 0x5A1E2A);
    a.o(340, 195, 13, 8, 0xE8758F);
  } else {
    a.s(
      'M340 164 L340 170 M340 170 Q328 184 314 174 M340 170 Q352 184 366 174',
      0x6E4524,
      3.2,
    );
  }
}

void _maymunB(Art a, bool happy) {
  for (final d in const [-1, 1]) {
    a.c(340 + d * 62, 126, 21, 0x7A4A28);
    a.c(340 + d * 63, 127, 13, 0xF2C8A0);
  }
  a.box(0x8A5A32, 0xA87848, 0x6E4524);
  a.s('M330 94 Q340 82 350 94', 0x5E3818, 3.5);
  a.c(326, 122, 20, 0xF6D9B0);
  a.c(354, 122, 20, 0xF6D9B0);
  a.o(340, 142, 32, 24, 0xF6D9B0);
  a.o(340, 150, 22, 14, 0xFBE9CC);
  if (happy) {
    _joy(a, 326, 118, 7, 3);
    _joy(a, 354, 118, 7, 3);
  } else {
    a.eye(326, 118, 6.5);
    a.eye(354, 118, 6.5);
  }
  a.o(334, 138, 2.6, 3.4, 0x6E4524);
  a.o(346, 138, 2.6, 3.4, 0x6E4524);
  if (happy) {
    a.p('M326 148 Q340 168 354 148 Q340 156 326 148 Z', 0x5A1E2A);
  } else {
    a.s(
      'M340 142 L340 146 M340 146 Q333 154 325 148 M340 146 Q347 154 355 148',
      0x6E4524,
      2.2,
    );
  }
}
