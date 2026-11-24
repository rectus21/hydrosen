// Yeşil Elma ve spor temaları (resimli). Resimli sahne/kapak varlığı
// yüklenemezse devreye giren sade vektör yedekleri burada.
import 'dart:ui';

import '../art.dart';
import '../celebration_style.dart';
import '../thermos_theme.dart';

const _sFull = 'M120 8 H560 V512 H120 Z';

const List<ThermosTheme> sporThemes = [
  ThermosTheme(
    id: 'yesilelma',
    name: 'Yeşil Elma',
    glass: Color(0xFFE6F5D0),
    edge: Color(0xFF3F7A2A),
    water: Color(0xFF2E86C8),
    deepWater: Color(0xFF124E7C),
    waterSurface: Color(0xFFBFE0F5),
    mark: Color(0xFF2B4F1A),
    label: Color(0xFF2B4F1A),
    band: Color(0xFF4E9A2E),
    bandLight: Color(0xFF9AD25E),
    background: _elmaBg,
    capChubby: _elmaA,
    capSlim: _elmaB,
    celebration: CelebrationStyle(CelebrationKind.fallingLeaves, [
      0x7CC243,
      0xA8DB6A,
      0x4E9A2E,
    ]),
  ),
  ThermosTheme(
    id: 'futbol',
    name: 'Futbol',
    glass: Color(0xFFE4F4DA),
    edge: Color(0xFF2E6B2A),
    water: Color(0xFF2E86C8),
    deepWater: Color(0xFF124E7C),
    waterSurface: Color(0xFFBFE0F5),
    mark: Color(0xFF1E3D1B),
    label: Color(0xFF1E3D1B),
    band: Color(0xFFF4F4F0),
    bandLight: Color(0xFFFFFFFF),
    background: _futbolBg,
    capChubby: _futbolA,
    capSlim: _futbolB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0x3FAE4A,
      0xFFFFFF,
      0x1F7A2E,
    ]),
  ),
  ThermosTheme(
    id: 'basketbol',
    name: 'Basketbol',
    glass: Color(0xFFFFE9D2),
    edge: Color(0xFF1F2F5C),
    water: Color(0xFF2E86C8),
    deepWater: Color(0xFF124E7C),
    waterSurface: Color(0xFFBFE0F5),
    mark: Color(0xFF1B2748),
    label: Color(0xFF1B2748),
    band: Color(0xFF26407F),
    bandLight: Color(0xFF5A7BC4),
    background: _basketBg,
    capChubby: _basketA,
    capSlim: _basketB,
    celebration: CelebrationStyle(CelebrationKind.embers, [
      0xF28A2E,
      0xFFC145,
      0x26407F,
    ]),
  ),
  ThermosTheme(
    id: 'voleybol',
    name: 'Voleybol',
    glass: Color(0xFFDDF2FB),
    edge: Color(0xFF2D6FA8),
    water: Color(0xFF2E86C8),
    deepWater: Color(0xFF124E7C),
    waterSurface: Color(0xFFBFE0F5),
    mark: Color(0xFF1D4A73),
    label: Color(0xFF1D4A73),
    band: Color(0xFFF7C93A),
    bandLight: Color(0xFFFFE488),
    background: _voleyBg,
    capChubby: _voleyA,
    capSlim: _voleyB,
    celebration: CelebrationStyle(CelebrationKind.stardust, [
      0xF7C93A,
      0x3DB3E8,
      0xFFFFFF,
    ]),
  ),
  ThermosTheme(
    id: 'karaejderha',
    name: 'Kara Ejderha',
    glass: Color(0xFFD3DAE4),
    edge: Color(0xFF15151A),
    water: Color(0xFF2E86C8),
    deepWater: Color(0xFF124E7C),
    waterSurface: Color(0xFFBFE0F5),
    mark: Color(0xFF1E2430),
    label: Color(0xFF1E2430),
    band: Color(0xFF2A2A30),
    bandLight: Color(0xFFF07A2A),
    background: _karaBg,
    capChubby: _karaA,
    capSlim: _karaB,
    celebration: CelebrationStyle(CelebrationKind.embers, [
      0xF07A2A,
      0xFFC145,
      0xE8553A,
    ]),
  ),
  ThermosTheme(
    id: 'yarisarabasi',
    name: 'Yarış Arabası',
    glass: Color(0xFFE6ECF4),
    edge: Color(0xFF3A3A40),
    water: Color(0xFF2E86C8),
    deepWater: Color(0xFF124E7C),
    waterSurface: Color(0xFFBFE0F5),
    mark: Color(0xFF2A2A30),
    label: Color(0xFF2A2A30),
    band: Color(0xFFD8282A),
    bandLight: Color(0xFFFFFFFF),
    background: _yarisBg,
    capChubby: _yarisA,
    capSlim: _yarisB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0xD8282A,
      0xFFFFFF,
      0x2A2A30,
    ]),
  ),
  ThermosTheme(
    id: 'pofuduk',
    name: 'Pofuduk Kedi',
    glass: Color(0xFFE6ECF4),
    edge: Color(0xFF5B6B80),
    water: Color(0xFF2E86C8),
    deepWater: Color(0xFF124E7C),
    waterSurface: Color(0xFFBFE0F5),
    mark: Color(0xFF2E3A4A),
    label: Color(0xFF2E3A4A),
    band: Color(0xFF9AA8BC),
    bandLight: Color(0xFFFFFFFF),
    background: _pofBg,
    capChubby: _pofA,
    capSlim: _pofB,
    celebration: CelebrationStyle(CelebrationKind.hearts, [
      0xED93B1,
      0xFFFFFF,
      0x9AA8BC,
    ]),
  ),
];

void _face(Art a, bool happy, num y) {
  a.eye(310, y, 11);
  a.eye(370, y, 11);
  if (happy) {
    a.p('M324 ${y + 22} Q340 ${y + 44} 356 ${y + 22} Z', k);
  } else {
    a.s('M328 ${y + 24} Q340 ${y + 34} 352 ${y + 24}', k, 3);
  }
}

// --- Yeşil Elma ------------------------------------------------------------

void _elmaBg(Art a) {
  a.p(_sFull, 0xDDF1FA);
  a.c(480, 90, 34, 0xFFF2B8);
  a.p('M120 330 Q250 290 340 330 Q450 372 560 320 V512 H120 Z', 0xA9D98F);
  a.p('M120 430 Q260 400 350 432 Q460 462 560 424 V512 H120 Z', 0x6FB867);
}

void _elmaA(Art a, bool happy) {
  a.o(340, 134, 92, 82, 0x5FA838);
  a.o(340, 134, 86, 76, 0x8CCB4E);
  a.o(312, 100, 28, 18, 0xC4E88C, op: 0.7);
  a.s('M340 62 Q344 44 354 34', 0x6B4A2B, 6);
  a.p('M352 44 Q384 22 410 40 Q384 62 352 44 Z', 0x4E9A2E);
  _face(a, happy, 130);
  a.cheeks(158, happy ? 1 : 0.7);
}

void _elmaB(Art a, bool happy) {
  a.box(0x8CCB4E, 0xC4E88C, 0x4E9A2E);
  a.s('M340 92 Q344 78 352 70', 0x6B4A2B, 5);
  a.p('M350 78 Q378 60 396 76 Q372 94 350 78 Z', 0x4E9A2E);
}

// --- Futbol ----------------------------------------------------------------

void _futbolBg(Art a) {
  a.p(_sFull, 0xFFD9A8);
  a.c(450, 140, 54, 0xFFF0B8, op: 0.8);
  a.p('M120 300 H560 V512 H120 Z', 0x4DB05A);
  a.p('M120 380 H560 V512 H120 Z', 0x3FA04C);
  a.s('M120 440 H560', 0xFFFFFF, 4);
}

void _futbolA(Art a, bool happy) {
  a.c(340, 130, 88, 0x2C2C2A);
  a.c(340, 130, 84, 0xFFFFFF);
  a.p('M340 76 L372 98 L360 136 L320 136 L308 98 Z', 0x2C2C2A, op: 0.9);
  _face(a, happy, 150);
}

void _futbolB(Art a, bool happy) {
  a.box(0xFFFFFF, 0xFFFFFF, 0xC9D2C9);
  a.p('M340 94 L360 108 L352 130 L328 130 L320 108 Z', 0x2C2C2A);
}

// --- Basketbol -------------------------------------------------------------

void _basketBg(Art a) {
  a.p(_sFull, 0xFFE3C2);
  a.c(200, 150, 40, 0xFFB064, op: 0.5);
  a.p('M120 330 H560 V512 H120 Z', 0xD9964F);
  for (var i = 0; i < 6; i++) {
    a.p('M${120 + i * 80} 330 h40 v182 h-40 Z', 0xC98640, op: 0.5);
  }
}

void _basketA(Art a, bool happy) {
  a.c(340, 130, 88, 0x2C2C2A);
  a.c(340, 130, 84, 0xF28A2E);
  a.s('M340 46 V214', 0x2C2C2A, 4);
  a.s('M256 130 H424', 0x2C2C2A, 4);
  a.s('M290 70 Q320 130 290 190', 0x2C2C2A, 4);
  a.s('M390 70 Q360 130 390 190', 0x2C2C2A, 4);
  _face(a, happy, 150);
}

void _basketB(Art a, bool happy) {
  a.box(0xF28A2E, 0xFFB064, 0xC25A12);
  a.s('M340 92 V160', 0x2C2C2A, 3);
}

// --- Voleybol --------------------------------------------------------------

void _voleyBg(Art a) {
  a.p(_sFull, 0xBFE6F7);
  a.c(150, 90, 36, 0xFFE488);
  a.p('M120 300 Q250 280 340 300 Q450 320 560 296 V512 H120 Z', 0x6EC8E8);
  a.p('M120 380 Q260 360 350 384 Q460 408 560 376 V512 H120 Z', 0xF3DDA0);
}

void _voleyA(Art a, bool happy) {
  a.c(340, 130, 88, 0x2C2C2A);
  a.c(340, 130, 84, 0xFFFFFF);
  a.p('M262 118 Q300 70 360 56 Q320 100 330 150 Q290 130 262 118 Z', 0x3DB3E8);
  a.p(
    'M418 130 Q392 176 340 204 Q360 160 352 120 Q388 120 418 130 Z',
    0xF7C93A,
  );
  _face(a, happy, 150);
  a.cheeks(172, happy ? 1 : 0.7);
}

void _voleyB(Art a, bool happy) {
  a.box(0xFFFFFF, 0xFFFFFF, 0xBFD6E6);
  a.p('M284 100 Q320 90 340 110 L340 160 L284 160 Z', 0x3DB3E8);
  a.p('M340 110 Q370 94 396 104 L396 160 L340 160 Z', 0xF7C93A);
}

// --- Kara Ejderha ----------------------------------------------------------

void _karaBg(Art a) {
  a.p(_sFull, 0xF2A04A);
  a.p(
    'M120 300 L220 230 L300 300 L400 210 L500 290 L560 250 V512 H120 Z',
    0x2A2024,
  );
  a.p('M120 420 Q340 380 560 420 V512 H120 Z', 0x151015);
  a.p('M200 470 Q340 440 480 470 L460 490 Q340 466 220 490 Z', 0xF07A2A);
}

void _karaA(Art a, bool happy) {
  a.o(340, 136, 92, 80, 0x1E1E24);
  a.p('M262 100 Q236 60 250 30 Q278 60 292 92 Z', 0x6B5A3A);
  a.p('M418 100 Q444 60 430 30 Q402 60 388 92 Z', 0x6B5A3A);
  a.c(306, 126, 12, 0xF0B83A);
  a.c(374, 126, 12, 0xF0B83A);
  a.o(306, 126, 3, 10, k);
  a.o(374, 126, 3, 10, k);
  if (happy) {
    a.p('M312 170 Q340 204 368 170 Z', 0x7A1E1E);
  } else {
    a.s('M318 176 Q340 184 362 176', 0x6B5A3A, 4);
  }
}

void _karaB(Art a, bool happy) {
  a.box(0x2A2A30, 0x55555E, 0x15151A);
  a.p('M300 100 Q290 76 296 62 Q312 80 318 100 Z', 0x6B5A3A);
  a.p('M380 100 Q390 76 384 62 Q368 80 362 100 Z', 0x6B5A3A);
  a.c(322, 122, 7, 0xF0B83A);
  a.c(358, 122, 7, 0xF0B83A);
}

// --- Yarış Arabası ---------------------------------------------------------

void _yarisBg(Art a) {
  a.p(_sFull, 0xBFE0F5);
  a.p('M120 300 H560 V512 H120 Z', 0x6A6A72);
  a.p('M120 300 H560 V320 H120 Z', 0xD8282A);
  a.p('M330 330 h20 v182 h-20 Z', 0xFFFFFF, op: 0.7);
}

void _yarisA(Art a, bool happy) {
  a.o(340, 150, 100, 52, 0xD8282A);
  a.o(340, 134, 52, 40, 0xFFFFFF);
  a.c(262, 190, 20, 0x2A2A30);
  a.c(418, 190, 20, 0x2A2A30);
  _face(a, happy, 130);
}

void _yarisB(Art a, bool happy) {
  a.box(0xD8282A, 0xFF7A7A, 0x8E1517);
  a.p('M316 110 H364 V150 H316 Z', 0xFFFFFF);
}

// --- Pofuduk Kedi ----------------------------------------------------------

void _pofBg(Art a) {
  a.p(_sFull, 0xE9EEF5);
  a.p('M120 330 H560 V512 H120 Z', 0xD2DAE6);
}

void _pofA(Art a, bool happy) {
  a.o(340, 134, 92, 80, 0xE8EAEE);
  a.p('M262 100 L270 52 L306 84 Z', 0xB8BEC8);
  a.p('M418 100 L410 52 L374 84 Z', 0xB8BEC8);
  a.c(310, 126, 11, 0x4A9BE0);
  a.c(370, 126, 11, 0x4A9BE0);
  _face(a, happy, 138);
}

void _pofB(Art a, bool happy) {
  a.box(0xE8EAEE, 0xFFFFFF, 0xB8BEC8);
  a.c(322, 122, 7, 0x4A9BE0);
  a.c(358, 122, 7, 0x4A9BE0);
}
