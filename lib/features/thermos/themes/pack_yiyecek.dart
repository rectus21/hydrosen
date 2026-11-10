// Yiyecek paketi temaları.
//
// YENİ TEMA EKLEME (yalnız bu dosyayı düzenle; başka dosyaya dokunma):
//  1. Aşağıdaki [yiyecekThemes] listesine bir `ThermosTheme(...)` ekle.
//  2. id: tüm uygulamada benzersiz, yalnız ASCII küçük harf/rakam (örn. 'kedi').
//     name: Türkçe görünen ad (örn. 'Kedi').
//  3. Renkler (Color(0xFFRRGGBB)): glass, edge, water, deepWater, waterSurface,
//     mark, label, band, bandLight.
//  4. background: `void Function(Art a)` - 120..560 x 8..512 tasarım alanını
//     boyar (Art.p('M120 8 H560 V512 H120 Z', 0xRRGGBB) ile başla).
//  5. capChubby / capSlim: `void Function(Art a, bool happy)` - tombul ve ince
//     termos kapakları; happy=true hedefe ulaşınca (ifade değişir).
//     Tombul: a.dome(base, light, dark) üstüne; ince: a.box(base, light, dark).
//  6. Kutlama (isteğe bağlı): celebration: CelebrationStyle(
//       CelebrationKind.hearts, [0xE24B4A, 0xED93B1]) - türler için
//     celebration_style.dart'a bak. Verilmezse damla halkası oynar.
//  7. Çizim yardımcıları art.dart'tadır (Art: p, s, c, o, raw, arcTop, dome,
//     box, eye, cheeks, seeds, leaves, grain, sprig). Fonksiyon adlarını
//     dosyaya özgü öneklerle ver (örn. _kediBg, _kediA, _kediB).
//  8. Liste `const` olduğundan arka plan/kapak fonksiyonları üst düzey
//     (top-level) olmalı, kapanış (closure) olmamalı.
//  9. test/thermos_test.dart tüm temaları (iki biçim, normal/mutlu) otomatik
//     çizer ve id benzersizliğini denetler; `flutter test` geçmeli.
//
// Örnek:
//   ThermosTheme(
//     id: 'kedi', name: 'Kedi',
//     glass: Color(0xFFFAEEDA), edge: Color(0xFF854F0B),
//     water: Color(0xFF378ADD), deepWater: Color(0xFF0C447C),
//     waterSurface: Color(0xFFB5D4F4), mark: Color(0xFF412402),
//     label: Color(0xFF633806), band: Color(0xFFBA7517),
//     bandLight: Color(0xFFEF9F27),
//     background: _kediBg, capChubby: _kediA, capSlim: _kediB,
//     celebration: CelebrationStyle(CelebrationKind.hearts, [0xED93B1]),
//   ),

// ignore_for_file: unused_import
import 'dart:math' as math;
import 'dart:ui';

import '../art.dart';
import '../celebration_style.dart';
import '../thermos_theme.dart';

const _full = 'M120 8 H560 V512 H120 Z';

const List<ThermosTheme> yiyecekThemes = [
  ThermosTheme(
    id: 'karpuz',
    name: 'Karpuz',
    glass: Color(0xFFCDEBC0),
    edge: Color(0xFF2F6B2A),
    water: Color(0xFFE5485A),
    deepWater: Color(0xFF8E1E35),
    waterSurface: Color(0xFFF9B7BE),
    mark: Color(0xFF1F4D1C),
    label: Color(0xFF1F4D1C),
    band: Color(0xFF3F9142),
    bandLight: Color(0xFF7BC96F),
    background: _karpuzBg,
    capChubby: _karpuzA,
    capSlim: _karpuzB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0xE5485A,
      0x3F9142,
      0xF9B7BE,
      0x2C2C2A,
    ]),
  ),
  ThermosTheme(
    id: 'limon',
    name: 'Limon',
    glass: Color(0xFFFFF7C2),
    edge: Color(0xFF8A6D00),
    water: Color(0xFFF5C400),
    deepWater: Color(0xFFB78600),
    waterSurface: Color(0xFFFFE97A),
    mark: Color(0xFF5C4600),
    label: Color(0xFF5C4600),
    band: Color(0xFF7FB32E),
    bandLight: Color(0xFFB5DB5E),
    background: _limonBg,
    capChubby: _limonA,
    capSlim: _limonB,
    celebration: CelebrationStyle(CelebrationKind.bubbles, [
      0xF5C400,
      0xFFE97A,
      0x7FB32E,
    ]),
  ),
  ThermosTheme(
    id: 'avokado',
    name: 'Avokado',
    glass: Color(0xFFE3EFC0),
    edge: Color(0xFF4A5E1F),
    water: Color(0xFF8DBF3F),
    deepWater: Color(0xFF4C7A1A),
    waterSurface: Color(0xFFD2EBA0),
    mark: Color(0xFF3B2A14),
    label: Color(0xFF3B4A17),
    band: Color(0xFF6B4A2B),
    bandLight: Color(0xFF9A7448),
    background: _avokadoBg,
    capChubby: _avokadoA,
    capSlim: _avokadoB,
    celebration: CelebrationStyle(CelebrationKind.hearts, [
      0x8DBF3F,
      0xC5DE7A,
      0xED93B1,
    ]),
  ),
  ThermosTheme(
    id: 'dondurma',
    name: 'Dondurma',
    glass: Color(0xFFFFE4EE),
    edge: Color(0xFFA0486C),
    water: Color(0xFFF27FAA),
    deepWater: Color(0xFFB23C6E),
    waterSurface: Color(0xFFFFD0E1),
    mark: Color(0xFF6D2748),
    label: Color(0xFF6D2748),
    band: Color(0xFFC98B54),
    bandLight: Color(0xFFE8B880),
    background: _dondurmaBg,
    capChubby: _dondurmaA,
    capSlim: _dondurmaB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0xF27FAA,
      0x6EC3E8,
      0xFAC775,
      0xA6E3B5,
    ]),
  ),
  ThermosTheme(
    id: 'seftali',
    name: 'Şeftali',
    glass: Color(0xFFFFE3CF),
    edge: Color(0xFFB2502C),
    water: Color(0xFFFF9A62),
    deepWater: Color(0xFFC4511F),
    waterSurface: Color(0xFFFFD2B3),
    mark: Color(0xFF7A2E14),
    label: Color(0xFF7A2E14),
    band: Color(0xFF6FA83A),
    bandLight: Color(0xFFA3CF6A),
    background: _seftaliBg,
    capChubby: _seftaliA,
    capSlim: _seftaliB,
    celebration: CelebrationStyle(CelebrationKind.fallingFlowers, [
      0xFF9A62,
      0xF7B8A0,
      0x6FA83A,
    ]),
  ),
];

/// Ortak mutlu/normal ağız (kapak merkezi x=340).
void _mouth(Art a, bool happy, num y) {
  if (happy) {
    a.p('M324 $y Q340 ${y + 22} 356 $y Z', k);
    a.o(340, y + 11, 6, 3, 0xED93B1);
  } else {
    a.s('M328 $y Q340 ${y + 12} 352 $y', k, 3);
  }
}

double _cos(double r) => math.cos(r);
double _sin(double r) => math.sin(r);

// --- Karpuz ----------------------------------------------------------------

void _karpuzBg(Art a) {
  a.p(_full, 0xEAF6DF);
  for (var i = 0; i < 5; i++) {
    final x = 120 + i * 100;
    a.p('M$x 8 h40 l-70 504 h-40 Z', 0xD3EBC1, op: 0.55);
  }
  a.p(
    'M120 410 Q210 372 300 400 Q400 430 490 392 Q530 378 560 388 V512 H120 Z',
    0xA9D98F,
  );
  a.p('M120 458 Q240 436 350 460 Q460 482 560 452 V512 H120 Z', 0x6FB867);
  for (final s in const [
    [175, 90, 1.0],
    [505, 150, 0.8],
    [190, 270, 0.7],
    [500, 300, 1.0],
  ]) {
    final x = s[0], y = s[1], q = s[2];
    // karpuz dilimi
    a.p(
      'M${x - 26 * q} $y h${52 * q} q0 ${30 * q} ${-26 * q} ${30 * q} '
      'q${-26 * q} 0 ${-26 * q} ${-30 * q} Z',
      0x3F9142,
    );
    a.p(
      'M${x - 22 * q} ${y + 1} h${44 * q} q0 ${24 * q} ${-22 * q} ${24 * q} '
      'q${-22 * q} 0 ${-22 * q} ${-24 * q} Z',
      0xE5485A,
    );
    for (final dx in const [-10.0, 0.0, 10.0]) {
      a.o(x + dx * q, y + (dx == 0 ? 14 : 8) * q, 1.8 * q, 3 * q, 0x2C2C2A);
    }
  }
  for (var i = 0; i < 22; i++) {
    final x = 130 + a.rnd() * 420;
    final y = 20 + a.rnd() * 360;
    a.o(x, y, 2, 3.4, 0x2C2C2A, op: 0.25, rot: a.rnd() * 60 - 30);
  }
}

void _karpuzSeed(Art a, num x, num y, {num rot = 0}) =>
    a.o(x, y, 4, 7, 0x2C2C2A, rot: rot);

void _karpuzA(Art a, bool happy) {
  a.o(340, 130, 96, 80, 0x2F7D32);
  a.o(340, 130, 90, 74, 0x7BC96F);
  a.o(340, 130, 86, 70, 0xF1F7DD);
  a.o(340, 130, 80, 64, 0xE5485A);
  a.p(
    'M274 130 Q276 84 318 72 Q290 96 292 134 Q296 168 322 186 Q276 176 274 130 Z',
    0xF9B7BE,
    op: 0.55,
  );
  a.p(
    'M398 78 Q420 100 420 132 Q418 174 366 192 Q402 160 402 130 Q402 100 398 78 Z',
    0xB02D45,
    op: 0.8,
  );
  a.eye(310, 128, 12);
  a.eye(370, 128, 12);
  a.cheeks(152, happy ? 1 : 0.7);
  _mouth(a, happy, 150);
  for (final s in const [
    [296, 98, -30.0],
    [384, 98, 30.0],
    [270, 146, -60.0],
    [410, 146, 60.0],
    [302, 180, -20.0],
    [378, 180, 20.0],
    [340, 90, 0.0],
    [340, 194, 0.0],
  ]) {
    _karpuzSeed(a, s[0], s[1], rot: s[2]);
  }
}

void _karpuzB(Art a, bool happy) {
  a.box(0xE5485A, 0xF9B7BE, 0xB02D45);
  // yeşil kabuk şeridi
  a.p('M284 150 L396 150 L396 164 L284 164 Z', 0x2F7D32);
  a.p('M284 146 L396 146 L396 152 L284 152 Z', 0xF1F7DD);
  for (final s in const [
    [304, 112, -20.0],
    [340, 108, 0.0],
    [376, 112, 20.0],
    [322, 132, -10.0],
    [358, 132, 10.0],
  ]) {
    _karpuzSeed(a, s[0], s[1], rot: s[2]);
  }
}

// --- Limon -----------------------------------------------------------------

void _limonBg(Art a) {
  a.p(_full, 0xFFFBD9);
  a.c(450, 100, 120, 0xFFF1A0, op: 0.45);
  a.c(450, 100, 78, 0xFFE96A, op: 0.5);
  for (var i = 0; i < 12; i++) {
    final ang = i * 30 * math.pi / 180;
    final x1 = 450 + 90 * _cos(ang), y1 = 100 + 90 * _sin(ang);
    final x2 = 450 + 130 * _cos(ang), y2 = 100 + 130 * _sin(ang);
    a.s('M$x1 $y1 L$x2 $y2', 0xFFE96A, 4);
  }
  a.p(
    'M120 396 Q210 360 300 392 Q400 424 480 384 Q526 364 560 376 V512 H120 Z',
    0xFFE16B,
  );
  a.p('M120 450 Q240 426 350 452 Q460 476 560 444 V512 H120 Z', 0xB5DB5E);
  for (final s in const [
    [170, 120, 1.0],
    [190, 270, 0.8],
    [510, 280, 1.0],
    [160, 370, 0.7],
  ]) {
    final x = s[0], y = s[1], q = s[2];
    a.c(x, y, 26 * q, 0xF5C400);
    a.c(x, y, 21 * q, 0xFFF7C2);
    a.c(x, y, 17 * q, 0xFFE35C);
    for (var i = 0; i < 6; i++) {
      final ang = (i * 60 + 30) * math.pi / 180;
      a.s(
        'M$x $y L${x + 17 * q * _cos(ang)} ${y + 17 * q * _sin(ang)}',
        0xFFF7C2,
        (2 * q).toDouble(),
      );
    }
  }
  for (var i = 0; i < 20; i++) {
    a.c(130 + a.rnd() * 420, 20 + a.rnd() * 360, 2.5, 0xFFFFFF, op: 0.8);
  }
}

void _limonLeaf(Art a, num x, num y) {
  a.s('M$x ${y + 6} Q$x ${y - 4} ${x + 6} ${y - 12}', 0x5B8A1E, 3);
  a.p(
    'M${x + 4} ${y - 8} Q${x + 28} ${y - 40} ${x + 66} ${y - 22} '
    'Q${x + 40} ${y + 4} ${x + 4} ${y - 8} Z',
    0x7FB32E,
  );
  a.s(
    'M${x + 8} ${y - 10} Q${x + 36} ${y - 22} ${x + 58} ${y - 22}',
    0x4F7A12,
    2,
  );
}

void _limonA(Art a, bool happy) {
  // iki ucu sivri limon gövdesi
  a.p(
    'M232 128 Q246 120 252 108 Q262 60 340 52 Q418 60 428 108 Q434 120 448 128 '
    'Q434 138 428 150 Q418 200 340 208 Q262 200 252 150 Q246 138 232 128 Z',
    0xF5D400,
  );
  a.p(
    'M256 130 Q258 82 300 64 Q330 54 340 56 Q290 74 280 120 Q276 168 316 200 '
    'Q262 190 256 130 Z',
    0xFFF08A,
    op: 0.75,
  );
  a.p(
    'M396 66 Q432 92 428 140 Q420 192 356 206 Q404 172 406 132 Q408 96 396 66 Z',
    0xC99A00,
  );
  a.eye(310, 128, 12);
  a.eye(370, 128, 12);
  a.cheeks(152, happy ? 1 : 0.7);
  _mouth(a, happy, 150);
  for (final s in const [
    [290, 90],
    [392, 100],
    [300, 184],
    [380, 188],
    [268, 150],
  ]) {
    a.c(s[0], s[1], 2.2, 0xC99A00, op: 0.6);
  }
  _limonLeaf(a, 338, 60);
}

void _limonB(Art a, bool happy) {
  a.box(0xF5D400, 0xFFF08A, 0xC99A00);
  for (final s in const [
    [304, 120],
    [376, 122],
    [320, 152],
    [360, 150],
  ]) {
    a.c(s[0], s[1], 2.2, 0xC99A00, op: 0.6);
  }
  _limonLeaf(a, 336, 94);
}

// --- Avokado ---------------------------------------------------------------

void _avokadoBg(Art a) {
  a.p(_full, 0xF1F6DC);
  a.p(
    'M120 330 Q210 280 300 320 Q390 360 470 300 Q520 266 560 290 V512 H120 Z',
    0xD6E8A4,
  );
  a.p('M120 400 Q220 360 320 398 Q420 436 560 380 V512 H120 Z', 0xA9CE6A);
  a.p('M120 458 Q250 432 360 458 Q470 482 560 450 V512 H120 Z', 0x7BA83A);
  for (final s in const [
    [175, 90, 1.0],
    [500, 120, 0.8],
    [185, 250, 0.7],
    [505, 270, 1.0],
  ]) {
    final x = s[0], y = s[1], q = s[2];
    // küçük avokado yarımı
    a.p(
      'M$x ${y - 26 * q} Q${x + 22 * q} ${y - 18 * q} ${x + 20 * q} ${y + 8 * q} '
      'Q${x + 18 * q} ${y + 28 * q} $x ${y + 28 * q} '
      'Q${x - 18 * q} ${y + 28 * q} ${x - 20 * q} ${y + 8 * q} '
      'Q${x - 22 * q} ${y - 18 * q} $x ${y - 26 * q} Z',
      0x3F6B1F,
    );
    a.p(
      'M$x ${y - 21 * q} Q${x + 17 * q} ${y - 14 * q} ${x + 15 * q} ${y + 8 * q} '
      'Q${x + 13 * q} ${y + 23 * q} $x ${y + 23 * q} '
      'Q${x - 13 * q} ${y + 23 * q} ${x - 15 * q} ${y + 8 * q} '
      'Q${x - 17 * q} ${y - 14 * q} $x ${y - 21 * q} Z',
      0xDDEB8E,
    );
    a.c(x, y + 8 * q, 8 * q, 0x8A5A32);
  }
  for (var i = 0; i < 22; i++) {
    a.c(130 + a.rnd() * 420, 20 + a.rnd() * 330, 2.4, 0xFFFFFF, op: 0.7);
  }
}

void _avokadoA(Art a, bool happy) {
  a.p(
    'M340 46 Q420 52 432 128 Q444 206 340 210 Q236 206 248 128 Q260 52 340 46 Z',
    0x3F6B1F,
  );
  a.p(
    'M340 58 Q408 64 418 128 Q428 194 340 198 Q252 194 262 128 Q272 64 340 58 Z',
    0xDDEB8E,
  );
  a.p(
    'M340 58 Q408 64 418 128 Q428 194 340 198 Q252 194 262 128 Q272 64 340 58 Z',
    0xB9D56A,
    op: 0.45,
  );
  a.p(
    'M276 120 Q280 82 316 66 Q292 92 292 130 Q294 168 318 188 Q272 176 276 120 Z',
    0xF3F8C4,
    op: 0.7,
  );
  // çekirdek
  a.c(340, 138, 40, 0x6E4524);
  a.p('M312 112 Q330 96 352 100 Q326 106 318 124 Z', 0xA77649, op: 0.8);
  a.p('M366 104 Q384 124 372 160 Q380 128 366 104 Z', 0x4B2D14, op: 0.7);
  a.eye(324, 134, 8);
  a.eye(356, 134, 8);
  a.o(282, 150, 12, 7, 0xED93B1, op: happy ? 1 : 0.7);
  a.o(398, 150, 12, 7, 0xED93B1, op: happy ? 1 : 0.7);
  if (happy) {
    a.p('M330 148 Q340 164 350 148 Z', k);
  } else {
    a.s('M331 150 Q340 158 349 150', k, 2.6);
  }
}

void _avokadoB(Art a, bool happy) {
  a.box(0x3F6B1F, 0x6E9B3B, 0x2A4A12);
  a.p(
    'M296 160 L296 118 Q296 100 340 98 Q384 100 384 118 L384 160 Z',
    0xDDEB8E,
  );
  a.p(
    'M296 160 L296 118 Q296 104 312 100 Q306 120 308 160 Z',
    0xF3F8C4,
    op: 0.7,
  );
  a.c(340, 130, 15, 0x6E4524);
  a.p('M330 120 Q338 112 348 116 Q336 118 332 126 Z', 0xA77649, op: 0.8);
}

// --- Dondurma --------------------------------------------------------------

void _dondurmaBg(Art a) {
  a.p(_full, 0xFFF4E4);
  for (var i = -4; i < 14; i++) {
    final x = 120 + i * 40;
    a.s('M$x 8 L${x + 200} 512', 0xF6DDB8, 2);
    a.s('M${x + 440} 8 L${x + 240} 512', 0xF6DDB8, 2);
  }
  a.p(
    'M120 396 Q210 366 300 392 Q400 420 480 384 Q526 366 560 376 V512 H120 Z',
    0xFFD3E3,
  );
  a.p('M120 452 Q240 430 350 454 Q460 476 560 446 V512 H120 Z', 0xF6A9C6);
  for (final s in const [
    [175, 100, 1.0],
    [505, 130, 0.8],
    [190, 270, 0.7],
    [500, 290, 1.0],
  ]) {
    final x = s[0], y = s[1], q = s[2];
    a.p('M${x - 16 * q} $y L${x + 16 * q} $y L$x ${y + 40 * q} Z', 0xE0A964);
    a.c(x, y - 4 * q, 19 * q, 0xF27FAA);
    a.c(x - 6 * q, y - 10 * q, 5 * q, 0xFFD0E1, op: 0.8);
    a.c(x + 2 * q, y - 26 * q, 4 * q, 0xD62B4A);
  }
  const cols = [0xF27FAA, 0x6EC3E8, 0xFAC775, 0xA6E3B5];
  for (var i = 0; i < 28; i++) {
    final x = 130 + a.rnd() * 420, y = 20 + a.rnd() * 350;
    a.o(x, y, 2, 6, cols[i % 4], op: 0.8, rot: a.rnd() * 180);
  }
}

void _dondurmaSprinkles(Art a, List<List<num>> pts) {
  const cols = [0xFFFFFF, 0x6EC3E8, 0xFAC775, 0x8E5BD0];
  for (var i = 0; i < pts.length; i++) {
    a.o(pts[i][0], pts[i][1], 2.6, 7, cols[i % 4], rot: pts[i][2]);
  }
}

void _dondurmaA(Art a, bool happy) {
  // damlayan top
  a.p(
    'M246 130 Q246 56 340 50 Q434 56 434 130 Q440 160 430 170 '
    'Q424 190 410 178 Q404 214 388 200 Q380 184 372 190 Q364 214 346 200 '
    'Q336 188 326 196 Q316 214 298 196 Q292 184 280 190 Q268 196 262 176 '
    'Q244 172 246 130 Z',
    0xF4A8C4,
  );
  a.p(
    'M262 124 Q266 74 312 62 Q286 90 286 130 Q288 160 304 172 Q262 162 262 124 Z',
    0xFFD0E1,
    op: 0.7,
  );
  a.p(
    'M398 66 Q430 90 428 134 Q426 176 408 176 Q412 140 400 108 Q398 86 398 66 Z',
    0xD9779F,
  );
  // çikolata sosu
  a.p(
    'M262 90 Q300 74 340 82 Q384 74 420 92 Q408 104 396 98 Q388 114 374 102 '
    'Q360 118 346 104 Q330 116 318 102 Q304 112 292 100 Q278 108 262 90 Z',
    0x7A4A2E,
  );
  _dondurmaSprinkles(a, const [
    [290, 90, 30],
    [330, 94, -20],
    [366, 92, 50],
    [402, 94, -40],
    [270, 100, 70],
    [314, 70, 20],
  ]);
  a.eye(312, 134, 12);
  a.eye(368, 134, 12);
  a.cheeks(158, happy ? 1 : 0.7);
  _mouth(a, happy, 156);
  // kiraz
  a.s('M342 56 Q350 36 366 30', 0x4F7A12, 3);
  a.c(340, 56, 15, 0xD62B4A);
  a.c(335, 51, 4, 0xFFFFFF, op: 0.8);
}

void _dondurmaB(Art a, bool happy) {
  a.box(0xF4A8C4, 0xFFD0E1, 0xD9779F);
  a.p(
    'M284 108 Q312 98 340 106 Q368 98 396 108 L396 122 Q384 134 372 122 '
    'Q360 138 348 124 Q336 138 324 124 Q312 134 300 122 Q290 130 284 120 Z',
    0x7A4A2E,
  );
  _dondurmaSprinkles(a, const [
    [304, 112, 30],
    [340, 116, -20],
    [376, 114, 50],
    [316, 146, 70],
    [356, 148, -30],
  ]);
  a.s('M342 90 Q350 72 364 66', 0x4F7A12, 3);
  a.c(340, 90, 12, 0xD62B4A);
  a.c(336, 86, 3.4, 0xFFFFFF, op: 0.8);
}

// --- Şeftali ---------------------------------------------------------------

void _seftaliBg(Art a) {
  a.p(_full, 0xFFF0E2);
  for (final s in const [
    [190, 70, 1.0],
    [480, 130, 0.8],
    [250, 210, 0.6],
  ]) {
    final x = s[0], y = s[1], q = s[2];
    a.c(x, y, 22 * q, 0xFFFFFF, op: 0.85);
    a.c(x + 24 * q, y + 6 * q, 18 * q, 0xFFFFFF, op: 0.85);
    a.c(x - 24 * q, y + 8 * q, 16 * q, 0xFFFFFF, op: 0.85);
  }
  a.p(
    'M120 380 Q210 340 300 372 Q400 406 480 366 Q526 346 560 360 V512 H120 Z',
    0xCBE5A0,
  );
  a.p('M120 440 Q240 414 350 442 Q460 468 560 434 V512 H120 Z', 0x9CC965);
  for (final s in const [
    [175, 270, 1.0],
    [505, 290, 0.9],
    [490, 60, 0.7],
  ]) {
    final x = s[0], y = s[1], q = s[2];
    a.c(x, y, 22 * q, 0xFF9A62);
    a.c(x + 8 * q, y + 2 * q, 14 * q, 0xF26B6B, op: 0.5);
    a.c(x - 8 * q, y - 8 * q, 5 * q, 0xFFD2B3, op: 0.8);
    a.leaves(x, y - 20 * q, [(-16 * q, 0x6FA83A), (16 * q, 0x4F7A12)]);
  }
  // çiçekler
  for (var i = 0; i < 9; i++) {
    final x = 140 + a.rnd() * 400, y = 30 + a.rnd() * 320;
    for (var j = 0; j < 5; j++) {
      final ang = j * 72 * math.pi / 180;
      a.c(x + 4 * _cos(ang), y + 4 * _sin(ang), 2.6, 0xFFB8C6, op: 0.9);
    }
    a.c(x, y, 1.8, 0xFAC775);
  }
}

void _seftaliLeaf(Art a, num x, num y, num s) {
  a.s(
    'M$x $y Q${x + 2 * s} ${y - 12 * s} ${x + 6 * s} ${y - 20 * s}',
    0x6B4A2B,
    3,
  );
  a.p(
    'M${x + 4 * s} ${y - 14 * s} Q${x + 30 * s} ${y - 48 * s} ${x + 70 * s} ${y - 26 * s} '
    'Q${x + 44 * s} ${y + 2 * s} ${x + 4 * s} ${y - 14 * s} Z',
    0x6FA83A,
  );
  a.s(
    'M${x + 8 * s} ${y - 15 * s} Q${x + 38 * s} ${y - 28 * s} ${x + 62 * s} ${y - 26 * s}',
    0x4F7A12,
    2,
  );
}

void _seftaliA(Art a, bool happy) {
  a.p(
    'M340 70 Q312 46 270 66 Q238 90 244 140 Q252 204 340 210 '
    'Q428 204 436 140 Q442 90 410 66 Q368 46 340 70 Z',
    0xFFA877,
  );
  a.p(
    'M360 72 Q404 52 424 92 Q444 140 418 182 Q396 206 346 208 Q408 180 412 130 '
    'Q414 90 360 72 Z',
    0xF26B6B,
    op: 0.75,
  );
  a.p(
    'M262 120 Q264 82 296 70 Q276 96 278 130 Q282 166 308 190 Q262 176 262 120 Z',
    0xFFE0C6,
    op: 0.7,
  );
  a.s('M340 72 Q326 110 338 150', 0xD9683C, 2.5);
  a.eye(308, 130, 12);
  a.eye(372, 130, 12);
  a.cheeks(154, happy ? 1 : 0.7);
  _mouth(a, happy, 152);
  _seftaliLeaf(a, 340, 70, 1);
}

void _seftaliB(Art a, bool happy) {
  a.box(0xFFA877, 0xFFE0C6, 0xF26B6B);
  a.s('M340 92 Q328 120 338 150', 0xD9683C, 2.5);
  a.o(380, 130, 10, 20, 0xF26B6B, op: 0.35);
  _seftaliLeaf(a, 336, 92, 0.8);
}
