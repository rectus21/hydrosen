// Hayvanlar paketi temaları: Kedi, Köpek, Tavşan, Penguen, Koala, Baykuş, Tilki,
// Kurt, Civciv.
//
// Yeni tema eklerken: id benzersiz ASCII küçük harf; arka plan/kapak
// fonksiyonları üst düzey (const liste), adları temaya özgü önekli olmalı.
// Çizim alanı 120..560 x 8..512; tombul kapak a.dome, ince kapak a.box ile
// başlar; happy=true hedefe ulaşıldığında ifade değişir.

import 'dart:math' as math;
import 'dart:ui';

import '../art.dart';
import '../celebration_style.dart';
import '../thermos_theme.dart';

const _full = 'M120 8 H560 V512 H120 Z';

const List<ThermosTheme> hayvanlarThemes = [
  ThermosTheme(
    id: 'kedi',
    name: 'Kedi',
    glass: Color(0xFFFCEBD3),
    edge: Color(0xFF9A5A1E),
    water: Color(0xFF3E8FD0),
    deepWater: Color(0xFF14507F),
    waterSurface: Color(0xFFBFDDF5),
    mark: Color(0xFF4A2A10),
    label: Color(0xFF6B3A12),
    band: Color(0xFF5A3A22),
    bandLight: Color(0xFF9A6E48),
    background: _kediBg,
    capChubby: _kediA,
    capSlim: _kediB,
    celebration: CelebrationStyle(CelebrationKind.hearts, [
      0xF08A5D,
      0xED93B1,
      0xFAC775,
    ]),
  ),
  ThermosTheme(
    id: 'kopek',
    name: 'Köpek',
    glass: Color(0xFFF6E6CC),
    edge: Color(0xFF7A4A22),
    water: Color(0xFF2E86C8),
    deepWater: Color(0xFF124E7C),
    waterSurface: Color(0xFFBFE0F5),
    mark: Color(0xFF43260F),
    label: Color(0xFF5E3512),
    band: Color(0xFF102C6B),
    bandLight: Color(0xFF4D79C7),
    background: _kopekBg,
    capChubby: _kopekA,
    capSlim: _kopekB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0xF2B84B,
      0xE2574C,
      0x4BA3E3,
      0x6DBE5B,
    ]),
  ),
  ThermosTheme(
    id: 'tavsan',
    name: 'Tavşan',
    glass: Color(0xFFF9E4EE),
    edge: Color(0xFFA24D74),
    water: Color(0xFF6C8EE0),
    deepWater: Color(0xFF3A4FA8),
    waterSurface: Color(0xFFDDE6FB),
    mark: Color(0xFF6B2A4A),
    label: Color(0xFF6B2A4A),
    band: Color(0xFFE58FB0),
    bandLight: Color(0xFFF7C4D8),
    background: _tavsanBg,
    capChubby: _tavsanA,
    capSlim: _tavsanB,
    celebration: CelebrationStyle(CelebrationKind.fallingFlowers, [
      0xF4A6C0,
      0xFFFFFF,
      0xFAC775,
    ]),
  ),
  ThermosTheme(
    id: 'penguen',
    name: 'Penguen',
    glass: Color(0xFFE3F3FB),
    edge: Color(0xFF1F5F85),
    water: Color(0xFF1F7FC0),
    deepWater: Color(0xFF0B3F6B),
    waterSurface: Color(0xFFC8E8F7),
    mark: Color(0xFF0B3F6B),
    label: Color(0xFF0B3F6B),
    band: Color(0xFF2B3A55),
    bandLight: Color(0xFF5A6E8C),
    background: _penguenBg,
    capChubby: _penguenA,
    capSlim: _penguenB,
    celebration: CelebrationStyle(CelebrationKind.snow, [
      0xFFFFFF,
      0xE6F5FD,
      0xBFE6FA,
    ]),
  ),
  ThermosTheme(
    id: 'koala',
    name: 'Koala',
    glass: Color(0xFFE6F0E3),
    edge: Color(0xFF4F6B4A),
    water: Color(0xFF2F8FB5),
    deepWater: Color(0xFF14506E),
    waterSurface: Color(0xFFBFE3F0),
    mark: Color(0xFF2F4A33),
    label: Color(0xFF2F4A33),
    band: Color(0xFF6B7B6A),
    bandLight: Color(0xFF9FB09C),
    background: _koalaBg,
    capChubby: _koalaA,
    capSlim: _koalaB,
    celebration: CelebrationStyle(CelebrationKind.fallingLeaves, [
      0x6FA85A,
      0x97C459,
      0xB5D4A0,
    ]),
  ),
  ThermosTheme(
    id: 'baykus',
    name: 'Baykuş',
    glass: Color(0xFFE4DDF5),
    edge: Color(0xFFC9A27A),
    water: Color(0xFF5B6BD6),
    deepWater: Color(0xFF2A2F8F),
    waterSurface: Color(0xFFC5CCF7),
    mark: Color(0xFFF1E8FF),
    label: Color(0xFFF1E8FF),
    band: Color(0xFF5E3F26),
    bandLight: Color(0xFFB38A5E),
    background: _baykusBg,
    capChubby: _baykusA,
    capSlim: _baykusB,
    celebration: CelebrationStyle(CelebrationKind.twinkles, [
      0xF6E7B0,
      0xF2A03D,
      0xE8D5B0,
    ]),
  ),
  ThermosTheme(
    id: 'tilki',
    name: 'Tilki',
    glass: Color(0xFFFFF1DC),
    edge: Color(0xFFA5521C),
    water: Color(0xFFD98A1E),
    deepWater: Color(0xFF9A5410),
    waterSurface: Color(0xFFFFE2A6),
    mark: Color(0xFF4A2508),
    label: Color(0xFF5A2C0A),
    band: Color(0xFF8A3A14),
    bandLight: Color(0xFFD9743A),
    background: _tilkiBg,
    capChubby: _tilkiA,
    capSlim: _tilkiB,
    celebration: CelebrationStyle(CelebrationKind.fallingLeaves, [
      0xE8782A,
      0xC9381F,
      0xF2A03D,
    ]),
  ),
  ThermosTheme(
    id: 'kurt',
    name: 'Kurt',
    glass: Color(0xFFDDD9F2),
    edge: Color(0xFFB8B2E0),
    water: Color(0xFF7B5FD0),
    deepWater: Color(0xFF2E2A78),
    waterSurface: Color(0xFFCBC2F6),
    mark: Color(0xFFEFEAFF),
    label: Color(0xFFEFEAFF),
    band: Color(0xFF4A4872),
    bandLight: Color(0xFF8E8CB8),
    background: _kurtBg,
    capChubby: _kurtA,
    capSlim: _kurtB,
    celebration: CelebrationStyle(CelebrationKind.snow, [
      0xFFFFFF,
      0xDCE6FF,
      0xB8C4F0,
    ]),
  ),
  ThermosTheme(
    id: 'civciv',
    name: 'Civciv',
    glass: Color(0xFFFFF3C4),
    edge: Color(0xFFD98A1E),
    water: Color(0xFF64B5E8),
    deepWater: Color(0xFF2377B6),
    waterSurface: Color(0xFFCDEBFA),
    mark: Color(0xFF6B3D06),
    label: Color(0xFF6B3D06),
    band: Color(0xFFC97909),
    bandLight: Color(0xFFF5B83D),
    background: _civcivBg,
    capChubby: _civcivA,
    capSlim: _civcivB,
    celebration: CelebrationStyle(CelebrationKind.twinkles, [
      0xFFF3A712,
      0xFFFFD75E,
      0xFFFFFF,
    ]),
  ),
];

// --- Kedi ------------------------------------------------------------------

void _kediPaw(Art a, num x, num y, int col, double op) {
  a.o(x, y, 11, 9, col, op: op);
  a.c(x - 12, y - 12, 4.5, col, op: op);
  a.c(x - 4, y - 18, 4.5, col, op: op);
  a.c(x + 5, y - 18, 4.5, col, op: op);
  a.c(x + 13, y - 12, 4.5, col, op: op);
}

void _kediBg(Art a) {
  // Sıcak, masalsı okuma köşesi. Büyük termos için orta koridor sade.
  a.p(_full, 0xFCECD9);
  a.p('M120 8 H560 V250 H120 Z', 0xFFF5E8, op: 0.72);

  // Solda kemerli gün batımı penceresi.
  a.p('M128 74 Q128 38 168 38 Q208 38 208 74 V222 H128 Z', 0xB66B55);
  a.p('M136 76 Q136 48 168 48 Q200 48 200 76 V214 H136 Z', 0xBDDDF0);
  a.p('M136 142 Q168 118 200 142 V214 H136 Z', 0xD79A75, op: 0.7);
  a.c(172, 92, 25, 0xFFE3A0, op: 0.8);
  a.s('M168 48 V214 M136 132 H200', 0xFFF8EE, 5);
  a.p('M124 56 Q148 88 130 184 L120 202 V52 Z', 0xD98982);
  a.p('M212 56 Q188 88 206 184 L220 202 V52 Z', 0xD98982);
  a.s('M128 222 H212', 0x9E5B43, 7);

  // Sağ kenardaki dar kitap rafı sahneyi çerçeveler.
  a.p('M492 78 H552 V362 H492 Z', 0xA8643C);
  a.p('M499 88 H545 V350 H499 Z', 0xF0C994);
  for (final y in const [154, 220, 286, 350]) {
    a.p('M494 ${y - 5} H550 V$y H494 Z', 0x8A4D31);
  }
  for (final b in const [
    [504, 116, 0xE47F6B],
    [516, 120, 0x6C91C8],
    [529, 112, 0xE8A94F],
    [504, 184, 0x75A56F],
    [518, 178, 0xC47891],
    [532, 188, 0xDB8B4C],
    [505, 250, 0x7698B8],
    [520, 244, 0xE06D64],
    [534, 252, 0x91A85B],
  ]) {
    a.p('M${b[0]} ${b[1]} H${b[0] + 9} V${b[1] + 28} H${b[0]} Z', b[2]);
  }
  a.p('M500 322 Q522 304 544 322 L538 350 H506 Z', 0x7A9E72);
  a.o(512, 310, 18, 7, 0x6E9E6B, rot: -35);
  a.o(534, 306, 18, 7, 0x82B47A, rot: 30);

  // Katmanlı zemin ve termos altında sakin oval halı.
  a.p('M120 394 H560 V512 H120 Z', 0xD9AE7D);
  a.p('M120 438 H560 V512 H120 Z', 0xC99163, op: 0.42);
  for (final x in const [164, 226, 454, 516]) {
    a.s('M$x 394 V512', 0xC79770, 1.5);
  }
  a.o(340, 494, 138, 24, 0xE7B7A0, op: 0.82);
  a.o(340, 494, 108, 15, 0xF5D5C5, op: 0.7);

  // Küçük nesneler alt köşelerde; karakter silüeti kapanmaz.
  a.c(506, 456, 26, 0xD987A8);
  a.s('M484 447 Q506 432 528 447 M482 458 Q506 442 530 458', 0xB75C82, 2.6);
  a.s('M488 474 Q506 462 524 474', 0xB75C82, 2.6);
  a.o(166, 476, 31, 10, 0xE88E72);
  a.p('M197 476 L218 464 L218 488 Z', 0xE88E72);
  a.c(150, 474, 2.6, k);
  _kediPaw(a, 154, 350, 0xD6A16E, 0.48);
  _kediPaw(a, 526, 386, 0xD6A16E, 0.48);
}

void _kediEar(Art a, double y) {
  a.p('M250 ${y + 66} L254 $y L314 ${y + 26} Z', 0xD9812F);
  a.p('M264 ${y + 52} L266 ${y + 18} L296 ${y + 32} Z', 0xF4A6B8);
  a.p('M430 ${y + 66} L426 $y L366 ${y + 26} Z', 0xD9812F);
  a.p('M416 ${y + 52} L414 ${y + 18} L384 ${y + 32} Z', 0xF4A6B8);
}

void _kediA(Art a, bool happy) {
  _kediEar(a, 40);
  a.dome(0xEF9F4F, 0xF8C68A, 0xC9772C);
  for (final d in const [
    'M340 54 L340 82',
    'M316 58 Q314 70 318 80',
    'M364 58 Q366 70 362 80',
    'M246 122 Q264 122 276 130',
    'M434 122 Q416 122 404 130',
  ]) {
    a.s(d, 0xA95F1C, 4);
  }
  a.o(340, 164, 38, 28, 0xFFF4E4);
  a.cheeks(158, 0.5);
  if (happy) {
    a.s('M290 130 Q306 112 322 130', k, 4.5);
    a.s('M358 130 Q374 112 390 130', k, 4.5);
  } else {
    a.eye(306, 126, 13);
    a.eye(374, 126, 13);
  }
  a.p(
    'M330 148 Q340 142 350 148 Q346 158 340 160 Q334 158 330 148 Z',
    0xE0607E,
  );
  if (happy) {
    a.p('M318 168 Q340 198 362 168 Q340 176 318 168 Z', k);
    a.o(340, 184, 8, 4.5, 0xF4A6B8);
  } else {
    a.s(
      'M340 160 L340 168 M340 168 Q330 178 320 172 M340 168 Q350 178 360 172',
      k,
      3,
    );
  }
  for (final d in const [
    'M300 158 L262 150',
    'M300 166 L262 168',
    'M380 158 L418 150',
    'M380 166 L418 168',
  ]) {
    a.s(d, 0x7A4A22, 2);
  }
}

void _kediB(Art a, bool happy) {
  a.p('M284 112 L290 66 L326 96 Z', 0xD9812F);
  a.p('M292 104 L294 78 L314 94 Z', 0xF4A6B8);
  a.p('M396 112 L390 66 L354 96 Z', 0xD9812F);
  a.p('M388 104 L386 78 L366 94 Z', 0xF4A6B8);
  a.box(0xEF9F4F, 0xF8C68A, 0xC9772C);
  for (final d in const [
    'M340 92 L340 106',
    'M326 94 L328 102',
    'M354 94 L352 102',
    'M286 126 L298 128',
    'M394 126 L382 128',
  ]) {
    a.s(d, 0xA95F1C, 3.5);
  }
  a.o(340, 146, 22, 14, 0xFFF4E4);
  if (happy) {
    a.s('M308 124 Q320 110 332 124', k, 3.5);
    a.s('M348 124 Q360 110 372 124', k, 3.5);
  } else {
    a.c(320, 122, 5.5, k);
    a.c(360, 122, 5.5, k);
    a.c(318, 120, 1.8, w);
    a.c(358, 120, 1.8, w);
  }
  a.p('M334 136 L346 136 L340 144 Z', 0xE0607E);
  if (happy) {
    a.p('M330 148 Q340 160 350 148 Q340 152 330 148 Z', k);
  } else {
    a.s('M340 144 Q334 152 328 149 M340 144 Q346 152 352 149', k, 2);
  }
}

// --- Köpek -----------------------------------------------------------------

void _kopekBg(Art a) {
  a.p(_full, 0xCDEBFA);
  a.c(500, 80, 38, 0xFFE08A);
  a.c(500, 80, 26, 0xFFF1BD);
  for (final cl in const [
    [180, 90],
    [160, 170],
  ]) {
    a.o(cl[0], cl[1], 38, 14, w, op: 0.9);
    a.o(cl[0] + 24, cl[1] - 8, 24, 12, w, op: 0.9);
  }
  // Tepeler ve çimen.
  a.p('M120 360 Q230 300 340 350 Q450 400 560 330 V512 H120 Z', 0x9ED27A);
  a.p('M120 430 Q260 390 380 430 Q480 460 560 420 V512 H120 Z', 0x6DBE5B);
  a.p('M120 480 Q300 460 560 482 V512 H120 Z', 0x4E9F44);
  // Çit.
  for (final x in const [132, 160, 188, 492, 520, 548]) {
    a.p('M${x - 9} 360 L$x 346 L${x + 9} 360 V438 H${x - 9} Z', 0xF2E4C8);
  }
  a.p('M122 382 H206 V394 H122 Z', 0xE0CDA6);
  a.p('M478 382 H560 V394 H478 Z', 0xE0CDA6);
  // Kemik.
  a.o(188, 462, 22, 6, 0xFFF8E8, rot: -12);
  a.c(168, 466, 7, 0xFFF8E8);
  a.c(170, 454, 7, 0xFFF8E8);
  a.c(207, 470, 7, 0xFFF8E8);
  a.c(209, 458, 7, 0xFFF8E8);
  // Çiçekler.
  for (final f in const [
    [500, 470, 0xFFFFFF],
    [530, 488, 0xFAC775],
    [470, 492, 0xFFFFFF],
  ]) {
    a.c(f[0], f[1], 5, f[2]);
    a.c(f[0], f[1], 2, 0xEF9F27);
  }
}

/// Sarkık kulak: [inner]/[outer] merkezden yatay uzaklık, [top]..[bot] dikey.
void _kopekEar(
  Art a,
  int d,
  double top,
  double bot,
  double inner,
  double outer,
) {
  String pt(double dx, double y) => '${340 + d * dx} $y';
  final h = bot - top;
  final edge =
      'M${pt(inner, top)} Q${pt(outer + 10, top - 6)} ${pt(outer, top + h * 0.38)} '
      'Q${pt(outer - 2, bot - 8)} ${pt(outer - 22, bot)}';
  a.p(
    '$edge Q${pt(inner + 2, bot + 2)} ${pt(inner - 2, top + h * 0.5)} '
    'Q${pt(inner - 6, top + h * 0.2)} ${pt(inner, top)} Z',
    0x6B3F1B,
  );
  // İç gölge ve ışık.
  a.p(
    'M${pt(inner + 6, top + 8)} Q${pt(outer - 2, top + 4)} ${pt(outer - 6, top + h * 0.4)} '
    'Q${pt(outer - 8, bot - 18)} ${pt(outer - 24, bot - 10)} '
    'Q${pt(inner + 8, bot - 8)} ${pt(inner + 6, top + h * 0.5)} Z',
    0x8A5428,
  );
  a.p(
    'M${pt(inner + 12, top + 14)} Q${pt(inner + 24, top + h * 0.3)} ${pt(inner + 22, top + h * 0.6)} '
    'Q${pt(inner + 14, top + h * 0.5)} ${pt(inner + 12, top + 14)} Z',
    0xB07A42,
    op: 0.7,
  );
  a.s(edge, 0x4A2810, 2.5);
}

void _kopekA(Art a, bool happy) {
  a.dome(0xD9A066, 0xEBC08A, 0xB07A42);
  // Alında açık çizgi ve göz lekesi.
  a.p('M340 58 Q352 90 346 124 Q340 128 334 124 Q328 90 340 58 Z', 0xF8E8CE);
  a.o(380, 126, 27, 25, 0x7A4A22, rot: 12);
  // Kulaklar kafanın üstüne biner.
  _kopekEar(a, -1, 62, 200, 70, 120);
  _kopekEar(a, 1, 62, 200, 70, 120);
  // Ağız çevresi (krem).
  a.o(340, 170, 50, 36, 0xF8E8CE);
  a.o(340, 160, 36, 22, 0xFFF4E2, op: 0.7);
  a.cheeks(168, 0.45);
  if (happy) {
    a.s('M286 132 Q304 110 322 132', k, 5);
    a.s('M358 132 Q376 110 394 132', k, 5);
  } else {
    a.eye(304, 128, 15);
    a.eye(378, 128, 15);
    a.s('M286 100 Q304 90 322 100', 0x7A4A22, 4.5);
    a.s('M358 100 Q378 90 394 100', 0x7A4A22, 4.5);
  }
  // Burun.
  a.p('M320 148 Q340 138 360 148 Q358 164 340 168 Q322 164 320 148 Z', k);
  a.o(332, 148, 8, 3.4, w, op: 0.65);
  if (happy) {
    a.s('M340 168 L340 174', k, 3);
    a.p('M312 176 Q340 218 368 176 Q340 188 312 176 Z', 0x5A1E2A);
    a.o(340, 200, 14, 9, 0xE8758F);
    a.s('M340 192 L340 206', 0xC0455F, 2);
    a.s('M340 174 Q324 190 312 176 M340 174 Q356 190 368 176', k, 3);
  } else {
    a.s(
      'M340 168 L340 178 M340 178 Q326 190 314 180 M340 178 Q354 190 366 180',
      k,
      3.2,
    );
    a.p(
      'M342 184 Q358 184 358 198 Q358 208 348 205 Q343 200 342 184 Z',
      0xE8758F,
    );
    a.s('M349 188 L349 200', 0xC0455F, 1.6);
  }
}

void _kopekB(Art a, bool happy) {
  a.box(0xD9A066, 0xEBC08A, 0xB07A42);
  a.p('M340 92 Q348 112 344 128 Q340 130 336 128 Q332 112 340 92 Z', 0xF8E8CE);
  a.o(362, 122, 15, 14, 0x7A4A22, rot: 12);
  _kopekEar(a, -1, 80, 174, 54, 78);
  _kopekEar(a, 1, 80, 174, 54, 78);
  a.o(340, 148, 32, 22, 0xF8E8CE);
  if (happy) {
    a.s('M308 126 Q320 110 332 126', k, 3.5);
    a.s('M348 126 Q360 110 372 126', k, 3.5);
  } else {
    a.eye(320, 122, 8);
    a.eye(362, 122, 8);
  }
  a.p('M327 134 Q340 127 353 134 Q351 146 340 148 Q329 146 327 134 Z', k);
  a.o(335, 134, 5, 2.2, w, op: 0.65);
  if (happy) {
    a.p('M326 152 Q340 172 354 152 Q340 158 326 152 Z', 0x5A1E2A);
    a.o(340, 163, 6, 4, 0xE8758F);
  } else {
    a.s(
      'M340 148 L340 154 M340 154 Q332 161 326 156 M340 154 Q348 161 354 156',
      k,
      2.4,
    );
  }
}

// --- Tavşan ----------------------------------------------------------------

void _tavsanBg(Art a) {
  a.p(_full, 0xFCEAF2);
  a.p('M120 400 Q250 360 370 400 Q480 436 560 390 V512 H120 Z', 0xCFEAB8);
  a.p('M120 460 Q280 430 420 462 Q500 478 560 456 V512 H120 Z', 0xA8D68A);
  // Havuçlar.
  for (final c in const [
    [170, 452],
    [520, 440],
  ]) {
    final x = c[0], y = c[1];
    a.p(
      'M${x - 12} $y Q$x ${y + 54} ${x + 2} ${y + 62} Q${x + 12} ${y + 40} ${x + 12} $y Z',
      0xF0883E,
    );
    a.s('M${x - 8} ${y + 14} h10 M${x - 4} ${y + 30} h9', 0xC9621E, 2);
    a.leaves(x, y, const [(-14, 0x3B8D2A), (14, 0x3B8D2A), (0, 0x5FB04A)]);
  }
  // Çiçekler.
  for (final f in const [
    [150, 250, 0xF4A6C0],
    [190, 310, 0xFAC775],
    [520, 280, 0xF4A6C0],
    [490, 350, 0xFFFFFF],
    [160, 150, 0xFFFFFF],
    [510, 130, 0xFAC775],
  ]) {
    a.s('M${f[0]} ${f[1] + 8} V${f[1] + 40}', 0x7DB85F, 2.5);
    for (var i = 0; i < 5; i++) {
      final ang = i * 72 * math.pi / 180;
      a.c(f[0] + 8 * math.cos(ang), f[1] + 8 * math.sin(ang), 6, f[2]);
    }
    a.c(f[0], f[1], 4, 0xEF9F27);
  }
  // Kelebek.
  a.o(488, 210, 10, 7, 0xAFA9EC, rot: -30);
  a.o(502, 206, 10, 7, 0xAFA9EC, rot: 30);
  a.s('M494 212 L496 222', 0x534AB7, 2);
}

void _tavsanA(Art a, bool happy) {
  // Uzun kulaklar.
  a.o(298, 66, 23, 40, 0xD9BFCB, rot: -10);
  a.o(382, 66, 23, 40, 0xD9BFCB, rot: 10);
  a.o(298, 66, 20, 37, 0xFBF6F8, rot: -10);
  a.o(382, 66, 20, 37, 0xFBF6F8, rot: 10);
  a.o(298, 68, 10, 26, 0xF2A6C0, rot: -10);
  a.o(382, 68, 10, 26, 0xF2A6C0, rot: 10);
  a.dome(0xFBF6F8, w, 0xE3D3DA);
  a.cheeks(158, 0.7);
  if (happy) {
    a.s('M290 128 Q306 110 322 128', k, 4.5);
    a.s('M358 128 Q374 110 390 128', k, 4.5);
  } else {
    a.eye(306, 124, 12);
    a.eye(374, 124, 12);
  }
  a.p(
    'M331 146 Q340 140 349 146 Q345 154 340 156 Q335 154 331 146 Z',
    0xE0607E,
  );
  if (happy) {
    a.p('M322 162 Q340 192 358 162 Q340 170 322 162 Z', k);
    a.o(340, 178, 7, 4, 0xF2A6C0);
    a.p('M333 163 h8 v9 h-8 Z', w);
    a.p('M340 163 h8 v9 h-8 Z', w);
  } else {
    a.s(
      'M340 156 L340 164 M340 164 Q331 172 322 166 M340 164 Q349 172 358 166',
      k,
      3,
    );
    a.p('M333 166 h7 v11 h-7 Z', w);
    a.p('M340 166 h7 v11 h-7 Z', w);
    a.s('M333 166 h14 v11 h-14 Z M340 166 v11', 0xC9B5C0, 1.5);
  }
  for (final d in const [
    'M296 156 L262 150',
    'M296 164 L262 166',
    'M384 156 L418 150',
    'M384 164 L418 166',
  ]) {
    a.s(d, 0xB89AAA, 2);
  }
}

void _tavsanB(Art a, bool happy) {
  a.o(304, 58, 16, 34, 0xD9BFCB, rot: -12);
  a.o(376, 58, 16, 34, 0xD9BFCB, rot: 12);
  a.o(304, 58, 13.5, 31.5, 0xFBF6F8, rot: -12);
  a.o(376, 58, 13.5, 31.5, 0xFBF6F8, rot: 12);
  a.o(304, 62, 7, 21, 0xF2A6C0, rot: -12);
  a.o(376, 62, 7, 21, 0xF2A6C0, rot: 12);
  a.box(0xFBF6F8, w, 0xE3D3DA);
  a.o(298, 144, 9, 6, 0xED93B1, op: 0.55);
  a.o(382, 144, 9, 6, 0xED93B1, op: 0.55);
  if (happy) {
    a.s('M308 124 Q320 110 332 124', k, 3.5);
    a.s('M348 124 Q360 110 372 124', k, 3.5);
  } else {
    a.c(320, 122, 5.5, k);
    a.c(360, 122, 5.5, k);
    a.c(318, 120, 1.8, w);
    a.c(358, 120, 1.8, w);
  }
  a.p(
    'M335 136 Q340 132 345 136 Q343 142 340 143 Q337 142 335 136 Z',
    0xE0607E,
  );
  if (happy) {
    a.p('M330 146 Q340 162 350 146 Q340 152 330 146 Z', k);
    a.p('M337 147 h6 v5 h-6 Z', w);
  } else {
    a.s(
      'M340 143 L340 148 M340 148 Q334 154 329 150 M340 148 Q346 154 351 150',
      k,
      2,
    );
    a.p('M336 149 h4 v6 h-4 Z', w);
    a.p('M340 149 h4 v6 h-4 Z', w);
    a.s('M336 149 h8 v6 h-8 Z M340 149 v6', 0xC9B5C0, 1);
  }
}

// --- Penguen ---------------------------------------------------------------

void _penguenBg(Art a) {
  a.p(_full, 0x8EC9EA);
  a.p('M120 8 H560 V190 Q440 160 340 190 Q230 220 120 180 Z', 0xA8D8F0);
  // Kutup ışığı.
  a.p(
    'M120 90 Q220 40 330 80 Q430 118 560 60 V92 Q440 150 330 114 Q220 78 120 130 Z',
    0xB9F0D8,
    op: 0.45,
  );
  // Yıldızlar.
  for (final s in const [
    [150, 40],
    [220, 120],
    [500, 150],
    [470, 36],
    [540, 100],
    [190, 200],
  ]) {
    a.c(s[0], s[1], 3, w, op: 0.85);
  }
  // Buz dağları.
  a.p('M120 330 L190 230 L236 290 L270 250 L320 330 Z', 0xDDF2FC);
  a.p('M190 230 L236 290 L212 290 Z', 0xB5DDF0);
  a.p('M400 330 L470 220 L520 290 L548 260 L560 280 V330 Z', 0xDDF2FC);
  a.p('M470 220 L520 290 L492 290 Z', 0xB5DDF0);
  // Deniz.
  a.p('M120 330 H560 V512 H120 Z', 0x3F8FC4);
  a.s(
    'M130 360 Q150 352 170 360 Q190 368 210 360 M470 380 Q490 372 510 380 Q530 388 550 380',
    0xA8D8F0,
    3,
  );
  a.s(
    'M140 420 Q160 412 180 420 Q200 428 220 420 M480 440 Q500 432 520 440',
    0x6FB4DE,
    3,
  );
  // Buz parçaları.
  a.p('M130 480 Q160 462 220 470 Q250 476 244 496 Q190 508 134 500 Z', w);
  a.p(
    'M130 490 Q190 500 244 490 Q240 504 190 508 Q140 508 130 500 Z',
    0xB5DDF0,
  );
  a.p('M470 470 Q500 456 548 462 L560 480 Q520 496 474 490 Z', w);
  // Balık.
  a.o(512, 424, 14, 7, 0xF0997B);
  a.p('M526 424 L538 415 L538 433 Z', 0xF0997B);
  a.c(504, 422, 2, k);
}

void _penguenA(Art a, bool happy) {
  a.dome(0x2B3A55, 0x4A5C7C, 0x1A2438);
  // Beyaz yüz.
  a.o(306, 128, 32, 28, 0xF7FAFC);
  a.o(374, 128, 32, 28, 0xF7FAFC);
  a.o(340, 158, 44, 34, 0xF7FAFC);
  a.cheeks(160, 0.5);
  if (happy) {
    a.s('M292 130 Q306 114 320 130', k, 4.5);
    a.s('M360 130 Q374 114 388 130', k, 4.5);
    // Gaga açılır.
    a.p(
      'M322 146 Q340 138 358 146 Q350 158 340 158 Q330 158 322 146 Z',
      0xF2A03D,
    );
    a.p('M326 160 Q340 184 354 160 Q340 164 326 160 Z', 0xD97A22);
    a.o(340, 168, 6, 3.5, 0xE8758F);
  } else {
    a.eye(306, 126, 12);
    a.eye(374, 126, 12);
    a.p(
      'M322 146 Q340 138 358 146 Q352 160 340 166 Q328 160 322 146 Z',
      0xF2A03D,
    );
    a.s('M326 152 Q340 158 354 152', 0xD97A22, 2.5);
  }
  a.s('M330 56 Q336 42 342 56 M342 56 Q350 44 356 58', 0x1A2438, 4);
}

void _penguenB(Art a, bool happy) {
  a.box(0x2B3A55, 0x4A5C7C, 0x1A2438);
  a.o(340, 130, 38, 32, 0xF7FAFC);
  a.o(340, 148, 30, 16, 0xF7FAFC);
  a.o(300, 142, 8, 5, 0xED93B1, op: 0.5);
  a.o(380, 142, 8, 5, 0xED93B1, op: 0.5);
  if (happy) {
    a.s('M308 122 Q320 108 332 122', k, 3.5);
    a.s('M348 122 Q360 108 372 122', k, 3.5);
    a.p(
      'M328 134 Q340 128 352 134 Q348 142 340 142 Q332 142 328 134 Z',
      0xF2A03D,
    );
    a.p('M331 144 Q340 160 349 144 Q340 148 331 144 Z', 0xD97A22);
  } else {
    a.c(320, 120, 5.5, k);
    a.c(360, 120, 5.5, k);
    a.c(318, 118, 1.8, w);
    a.c(358, 118, 1.8, w);
    a.p(
      'M328 134 Q340 128 352 134 Q348 148 340 152 Q332 148 328 134 Z',
      0xF2A03D,
    );
    a.s('M331 138 Q340 143 349 138', 0xD97A22, 2);
  }
}

// --- Koala -----------------------------------------------------------------

void _koalaBg(Art a) {
  // Sisli okaliptüs vadisi. Derinlik var, termosun arkasında karmaşa yok.
  a.p(_full, 0xDDEFEA);
  a.p('M120 8 H560 V208 H120 Z', 0xEAF6F2, op: 0.65);
  a.c(500, 82, 42, 0xFFF0BB, op: 0.38);
  a.c(500, 82, 28, 0xFFE5A2, op: 0.78);

  // Uzak mavi dağlar, yumuşak sis ve katmanlı tepeler.
  a.p(
    'M120 292 L182 226 L232 272 L286 210 L350 282 L414 232 L474 276 L530 218 L560 252 V360 H120 Z',
    0xAFCFCE,
    op: 0.72,
  );
  a.p('M120 326 Q230 286 340 326 Q450 362 560 306 V512 H120 Z', 0xBFDCC8);
  a.p('M120 392 Q236 350 350 392 Q470 428 560 376 V512 H120 Z', 0x91BEA0);
  a.p('M120 456 Q286 426 560 458 V512 H120 Z', 0x6E9E7A);
  a.s('M120 318 Q240 296 360 316 Q470 334 560 304', 0xD5E6DD, 12);

  // Kalın dallar kadrajın kenarlarında kalır.
  a.s('M120 104 Q160 132 212 190', 0x755B42, 12);
  a.s('M560 120 Q518 150 474 214', 0x755B42, 12);
  a.s('M120 466 Q166 446 220 458', 0x69503B, 14);
  a.s('M560 454 Q522 438 478 456', 0x69503B, 14);
  a.sprig(154, 142, 1);
  a.sprig(528, 158, -1);
  a.sprig(150, 452, 1);
  a.sprig(530, 444, -1);

  // Yapraklar kenarda; merkezde 250..430 aralığı sakin tutulur.
  for (final l in const [
    [136, 86, -30, 0x628F68],
    [178, 116, 24, 0x7BAB72],
    [214, 174, -18, 0x91BD80],
    [542, 96, 30, 0x628F68],
    [506, 132, -26, 0x7BAB72],
    [470, 194, 18, 0x91BD80],
    [142, 398, 24, 0x5D8D63],
    [198, 448, -18, 0x7BAB72],
    [538, 390, -24, 0x5D8D63],
    [486, 448, 18, 0x7BAB72],
  ]) {
    a.o(l[0], l[1], 18, 7, l[3], rot: l[2]);
    a.o(l[0] + 4, l[1] - 2, 10, 3.5, 0xA6CD92, rot: l[2], op: 0.65);
  }
  for (final l in const [
    [154, 492, -18],
    [200, 478, 24],
    [480, 482, -24],
    [526, 496, 16],
  ]) {
    a.o(l[0], l[1], 13, 5, 0x83AF72, rot: l[2], op: 0.86);
  }
}

void _koalaA(Art a, bool happy) {
  // Büyük tüylü kulaklar.
  for (final x in const [266, 414]) {
    a.c(x, 84, 36, 0x9AA3AE);
    a.c(x, 86, 36, 0x8A94A1, op: 0.5);
    a.c(x, 88, 22, 0xF1E3E6);
  }
  a.dome(0xAEB6C0, 0xCDD2D9, 0x818A97);
  a.o(284, 164, 22, 16, 0xE6E8EC, op: 0.8);
  a.o(396, 164, 22, 16, 0xE6E8EC, op: 0.8);
  a.cheeks(172, 0.45);
  if (happy) {
    a.s('M300 128 Q314 112 328 128', k, 4.5);
    a.s('M352 128 Q366 112 380 128', k, 4.5);
  } else {
    a.eye(314, 126, 9);
    a.eye(366, 126, 9);
  }
  a.o(340, 152, 22, 28, 0x3C3F46);
  a.o(332, 142, 7, 4, w, op: 0.55);
  if (happy) {
    a.p('M318 180 Q340 206 362 180 Q340 190 318 180 Z', k);
    a.o(340, 194, 8, 4.5, 0xE8758F);
  } else {
    a.s(
      'M340 180 L340 186 M340 186 Q331 194 322 188 M340 186 Q349 194 358 188',
      k,
      3,
    );
  }
}

void _koalaB(Art a, bool happy) {
  for (final x in const [290, 390]) {
    a.c(x, 100, 20, 0x9AA3AE);
    a.c(x, 102, 12, 0xF1E3E6);
  }
  a.box(0xAEB6C0, 0xCDD2D9, 0x818A97);
  if (happy) {
    a.s('M308 122 Q320 108 332 122', k, 3.5);
    a.s('M348 122 Q360 108 372 122', k, 3.5);
  } else {
    a.c(320, 120, 5, k);
    a.c(360, 120, 5, k);
    a.c(318, 118, 1.6, w);
    a.c(358, 118, 1.6, w);
  }
  a.o(340, 138, 13, 17, 0x3C3F46);
  a.o(335, 131, 4, 2.4, w, op: 0.55);
  if (happy) {
    a.p('M328 156 Q340 170 352 156 Q340 160 328 156 Z', k);
  } else {
    a.s(
      'M340 154 L340 158 M340 158 Q334 163 329 160 M340 158 Q346 163 351 160',
      k,
      2,
    );
  }
}

// --- Baykuş ----------------------------------------------------------------

void _baykusBg(Art a) {
  a.p(_full, 0x141B3A);
  a.p('M120 8 H560 V200 H120 Z', 0x1B2450, op: 0.6);
  for (var i = 0; i < 34; i++) {
    final x = 125 + a.rnd() * 430;
    final y = 12 + a.rnd() * 300;
    a.c(x, y, a.rnd() * 1.4 + 0.6, w, op: 0.45 + a.rnd() * 0.45);
  }
  // Dolunay.
  a.c(490, 100, 62, 0xF6F0D0, op: 0.12);
  a.c(490, 100, 48, 0xF6F0D0, op: 0.2);
  a.c(490, 100, 38, 0xF6F0D0);
  a.c(478, 90, 8, 0xE3DBB4, op: 0.8);
  a.c(502, 116, 6, 0xE3DBB4, op: 0.8);
  a.c(504, 84, 4, 0xE3DBB4, op: 0.8);
  // Uzak ormanın siluetleri.
  for (final t in const [
    [140, 330, 54],
    [200, 316, 70],
    [262, 336, 50],
    [420, 324, 60],
    [480, 308, 76],
    [540, 334, 52],
  ]) {
    final x = t[0], y = t[1], h = t[2];
    a.p('M${x - 26} $y L$x ${y - h} L${x + 26} $y Z', 0x1F2A55);
    a.p(
      'M${x - 34} ${y + 22} L$x ${y - h + 22} L${x + 34} ${y + 22} Z',
      0x1F2A55,
    );
  }
  a.p('M120 330 H560 V512 H120 Z', 0x1F2A55);
  // Ön plandaki ağaçlar.
  for (final t in const [
    [150, 470, 150],
    [540, 470, 130],
    [200, 480, 90],
  ]) {
    final x = t[0], y = t[1], h = t[2];
    a.p('M${x - 5} 512 V${y - h ~/ 3} H${x + 5} V512 Z', 0x0A1126);
    a.p('M${x - 38} ${y - 10} L$x ${y - h} L${x + 38} ${y - 10} Z', 0x0A1126);
    a.p(
      'M${x - 30} ${y - 50} L$x ${y - h - 30} L${x + 30} ${y - 50} Z',
      0x0A1126,
    );
  }
  a.p('M120 478 Q300 460 560 480 V512 H120 Z', 0x0A1126);
  // Dal ve ateşböcekleri.
  a.s('M120 220 Q170 214 214 232', 0x2B2038, 8);
  for (final f in const [
    [180, 400],
    [236, 436],
    [502, 380],
    [468, 430],
    [160, 280],
  ]) {
    a.c(f[0], f[1], 7, 0xF6E7A0, op: 0.18);
    a.c(f[0], f[1], 2.5, 0xF6E7A0);
  }
}

void _baykusTufts(
  Art a,
  double y,
  double sx,
  double base,
  int dark, {
  double sc = 1,
}) {
  // Kulak tüyleri: kafanın üst köşelerinden yukarı sivri tutam.
  for (final d in const [-1, 1]) {
    String pt(double dx, double yy) => '${340 + d * dx} $yy';
    a.p(
      'M${pt(sx + 40 * sc, y + base + 30)} Q${pt(sx + 44 * sc, y + 6)} ${pt(sx + 20 * sc, y)} '
      'Q${pt(sx - 8 * sc, y + 12)} ${pt(sx - 42 * sc, y + base)} Z',
      0x5A3A22,
    );
    a.p(
      'M${pt(sx + 32 * sc, y + base + 24)} Q${pt(sx + 34 * sc, y + 20)} ${pt(sx + 20 * sc, y + 10)} '
      'Q${pt(sx + 2 * sc, y + 24)} ${pt(sx - 20 * sc, y + base + 4)} Z',
      0x8B6240,
    );
    a.s('M${pt(sx + 22 * sc, y + 24)} L${pt(sx + 10 * sc, y + 56)}', dark, 2.4);
    a.s('M${pt(sx + 8 * sc, y + 30)} L${pt(sx - 2 * sc, y + 58)}', dark, 2.4);
  }
}

void _baykusEye(Art a, double x, double y, double r, bool wink) {
  a.c(x, y, r * 1.18, 0x6B4A2C);
  a.c(x, y, r * 1.06, 0xFFF3D6);
  if (wink) {
    a.s(
      'M${x - r * 0.8} ${y + 2} Q$x ${y - r * 0.9} ${x + r * 0.8} ${y + 2}',
      k,
      4.5,
    );
    return;
  }
  a.c(x, y, r * 0.78, 0xF2A03D);
  a.c(x, y + r * 0.1, r * 0.6, 0xFFC25A, op: 0.6);
  a.c(x, y, r * 0.44, k);
  a.c(x - r * 0.22, y - r * 0.26, r * 0.2, w);
  a.c(x + r * 0.2, y + r * 0.22, r * 0.09, w);
}

/// Tüy pulları: her noktada küçük "U" kıvrımı.
void _baykusScales(Art a, List<List<num>> pts, int col, double sz) {
  for (final p in pts) {
    a.s(
      'M${p[0] - sz} ${p[1]} Q${p[0]} ${p[1] + sz * 0.9} ${p[0] + sz} ${p[1]}',
      col,
      2,
    );
  }
}

/// Yüz diski: krem dolgu, kenara doğru ince tüy çizgileri.
void _baykusDisc(Art a, String disc, num cx, num cy, num rx, num ry) {
  a.canvas.save();
  a.canvas.clipPath(a.path(disc));
  a.o(cx, cy, rx, ry, 0xF3E3C4);
  a.o(cx, cy + 10, rx * 0.84, ry * 0.7, 0xFFF6E2, op: 0.6);
  a.canvas.restore();
}

void _baykusA(Art a, bool happy) {
  _baykusTufts(a, 14, 80, 62, 0x2F1E12);
  a.dome(0x8B6240, 0xB38A5E, 0x5E3F26);
  // Kafada tüy dokusu.
  _baykusScales(
    a,
    const [
      [280, 78],
      [300, 66],
      [380, 66],
      [400, 78],
      [262, 100],
      [418, 100],
      [340, 66],
      [320, 76],
      [360, 76],
    ],
    0x5E3F26,
    7,
  );
  // Kalp biçimli yüz diski.
  const disc =
      'M340 112 Q318 84 282 90 Q246 100 250 148 Q256 196 340 208 '
      'Q424 196 430 148 Q434 100 398 90 Q362 84 340 112 Z';
  a.p(disc, 0xA67A50);
  _baykusDisc(a, disc, 340, 150, 84, 62);
  // Kaşlar (diskin üst kenarında koyu V).
  a.s('M340 112 Q324 98 300 98 M340 112 Q356 98 380 98', 0x6B4A2C, 4);
  _baykusEye(a, 302, 134, 29, false);
  _baykusEye(a, 378, 134, 29, happy);
  // Gaga: küçük, kancalı.
  a.p(
    'M328 144 Q340 134 352 144 Q350 162 340 174 Q330 162 328 144 Z',
    0xE8902A,
  );
  a.p(
    'M332 146 Q340 140 348 146 Q346 156 340 160 Q334 156 332 146 Z',
    0xF9C066,
  );
  a.p('M336 164 Q340 176 344 164 Q340 168 336 164 Z', 0xB5651D);
  if (happy) {
    a.s('M316 190 Q340 204 364 190', 0x3A2412, 3);
  }
  a.cheeks(176, 0.4);
  // Göğüs: V kıvrım tüyleri.
  _baykusScales(
    a,
    const [
      [300, 196],
      [320, 202],
      [340, 206],
      [360, 202],
      [380, 196],
    ],
    0xD9BD92,
    8,
  );
}

void _baykusB(Art a, bool happy) {
  _baykusTufts(a, 46, 54, 44, 0x2F1E12, sc: 0.5);
  a.box(0x8B6240, 0xB38A5E, 0x5E3F26);
  const disc =
      'M340 108 Q326 94 304 98 Q282 106 286 134 Q292 164 340 168 '
      'Q388 164 394 134 Q398 106 376 98 Q354 94 340 108 Z';
  a.p(disc, 0xA67A50);
  _baykusDisc(a, disc, 340, 134, 56, 40);
  _baykusEye(a, 316, 124, 17, false);
  _baykusEye(a, 364, 124, 17, happy);
  a.p(
    'M333 132 Q340 125 347 132 Q345 146 340 154 Q335 146 333 132 Z',
    0xE8902A,
  );
  a.p('M336 146 Q340 156 344 146 Q340 150 336 146 Z', 0xB5651D);
  if (happy) {
    a.s('M328 158 Q340 164 352 158', 0x3A2412, 2.5);
  }
}

// --- Tilki -----------------------------------------------------------------

void _tilkiBg(Art a) {
  a.p(_full, 0xFBE3B8);
  a.p('M120 8 H560 V170 H120 Z', 0xF8D39A, op: 0.7);
  a.c(200, 120, 44, 0xFFF1C8, op: 0.9);
  a.c(200, 120, 32, 0xFFE3A0);
  // Uzak tepeler.
  a.p('M120 300 Q220 250 330 300 Q440 340 560 280 V512 H120 Z', 0xE8B27A);
  // Ağaçlar.
  for (final t in const [
    [150, 330, 0xD9541E, 40],
    [215, 350, 0xE8902A, 34],
    [470, 320, 0xC9381F, 44],
    [535, 346, 0xF2A03D, 36],
  ]) {
    final x = t[0], y = t[1], r = t[3];
    a.p('M${x - 6} 440 L${x - 4} $y H${x + 4} L${x + 6} 440 Z', 0x6B3F1E);
    a.c(x, y - 8, r, t[2]);
    a.c(x - r * 0.5, y + 6, r * 0.7, t[2]);
    a.c(x + r * 0.5, y + 4, r * 0.7, t[2]);
    a.c(x - r * 0.3, y - r * 0.5, r * 0.4, w, op: 0.15);
  }
  // Zemin ve yaprak halısı.
  a.p('M120 420 Q260 396 380 424 Q480 446 560 420 V512 H120 Z', 0xB5651D);
  a.p('M120 470 Q300 450 560 474 V512 H120 Z', 0x8A4A16);
  for (final l in const [
    [160, 440, 0xE8782A, -20],
    [200, 462, 0xC9381F, 25],
    [250, 490, 0xF2A03D, -10],
    [470, 450, 0xC9381F, 15],
    [520, 480, 0xE8782A, -25],
    [500, 500, 0xF2A03D, 20],
    [140, 492, 0xF2A03D, 30],
  ]) {
    a.o(l[0], l[1], 12, 5.5, l[2], rot: l[3]);
    a.s('M${l[0] - 9} ${l[1]} h18', 0x8A3A14, 1.2);
  }
  // Mantar.
  a.p('M498 432 h8 v18 h-8 Z', 0xF5E6CC);
  a.o(502, 432, 15, 9, 0xD9381F);
  a.c(497, 429, 2.4, w);
  a.c(507, 433, 2, w);
  // Düşen yapraklar.
  for (final l in const [
    [150, 190, 0xE8782A, 30],
    [510, 210, 0xC9381F, -30],
    [190, 250, 0xF2A03D, -20],
    [480, 150, 0xE8782A, 20],
  ]) {
    a.o(l[0], l[1], 9, 4.5, l[2], rot: l[3]);
  }
}

void _tilkiEars(Art a, double y, double spread, double wd) {
  for (final d in const [-1, 1]) {
    String pt(double dx, double yy) => '${340 + d * dx} $yy';
    final ox = spread + wd; // dış taban
    final ix = spread - wd; // iç taban
    final tx = spread + wd * 0.55; // uç
    final base = y + 96;
    // Dış kulak.
    a.p(
      'M${pt(ox + 6, base)} Q${pt(ox + 4, y + 40)} ${pt(tx, y)} '
      'Q${pt(ix + 4, y + 30)} ${pt(ix, base - 8)} Z',
      0xE8782A,
    );
    // Koyu uç.
    a.p(
      'M${pt(tx, y)} Q${pt(tx + wd * 0.2, y + 14)} ${pt(tx + wd * 0.5, y + 38)} '
      'Q${pt(tx, y + 30)} ${pt(tx - wd * 0.6, y + 36)} '
      'Q${pt(tx - wd * 0.3, y + 16)} ${pt(tx, y)} Z',
      0x3A2418,
    );
    // Açık iç kulak.
    a.p(
      'M${pt(ox - 12, base - 6)} Q${pt(ox - 10, y + 56)} ${pt(tx - 3, y + 42)} '
      'Q${pt(ix + 14, y + 52)} ${pt(ix + 14, base - 12)} Z',
      0xFFE8CF,
    );
    a.p(
      'M${pt(ox - 22, base - 8)} Q${pt(ox - 20, y + 66)} ${pt(tx - 4, y + 54)} '
      'Q${pt(ix + 22, y + 66)} ${pt(ix + 24, base - 12)} Z',
      0xF2B6A0,
      op: 0.55,
    );
  }
}

void _tilkiA(Art a, bool happy) {
  _tilkiEars(a, 14, 74, 34);
  a.dome(0xE8782A, 0xF4A25E, 0xB5551A);
  // Alında koyu turuncu "V".
  a.p(
    'M340 56 Q316 70 304 96 Q328 84 340 98 Q352 84 376 96 Q364 70 340 56 Z',
    0xC9601E,
    op: 0.55,
  );
  // Beyaz yanak tüyleri (püsküllü) ve ağız bölgesi.
  a.p(
    'M246 112 L232 132 L252 134 L238 156 L260 156 L252 180 L278 172 '
    'Q300 206 340 212 Q380 206 402 172 L428 180 L420 156 L442 156 L428 134 '
    'L448 132 L434 112 Q404 148 340 150 Q276 148 246 112 Z',
    0xFFF6EA,
  );
  // Turuncu burun sırtı (alından buruna incelir).
  a.p(
    'M316 106 Q340 100 364 106 Q352 140 344 166 L336 166 Q328 140 316 106 Z',
    0xE8782A,
  );
  // Gözler: badem biçimli, kehribar.
  for (final d in const [-1, 1]) {
    final x = 340 + d * 40.0;
    if (happy) {
      a.s('M${x - 17} 122 Q$x 100 ${x + 17} 122', k, 5);
    } else {
      final l = d == -1 ? 122 : 114;
      final r = d == -1 ? 114 : 122;
      a.p('M${x - 20} $l Q$x 94 ${x + 20} $r Q$x 142 ${x - 20} $l Z', k);
      a.o(x, 118, 13, 12, 0xF2A21E);
      a.o(x, 122, 9, 6, 0xFFD36A, op: 0.6);
      a.o(x, 118, 4, 11, k);
      a.c(x - 5, 112, 3.6, w);
      a.c(x + 4, 125, 1.6, w);
    }
  }
  // Burun ve ağız.
  a.p('M324 164 Q340 156 356 164 Q352 178 340 182 Q328 178 324 164 Z', k);
  a.o(333, 164, 6, 2.6, w, op: 0.7);
  a.cheeks(170, 0.3);
  if (happy) {
    a.s('M340 182 L340 188', k, 3);
    a.p('M320 188 Q340 218 360 188 Q340 196 320 188 Z', 0x5A1E2A);
    a.o(340, 205, 10, 6, 0xE8758F);
    a.s('M340 188 Q330 198 320 188 M340 188 Q350 198 360 188', k, 2.6);
  } else {
    a.s(
      'M340 182 L340 190 M340 190 Q330 200 320 192 M340 190 Q350 200 360 192',
      k,
      3,
    );
  }
}

void _tilkiB(Art a, bool happy) {
  _tilkiEars(a, 14, 42, 24);
  a.box(0xE8782A, 0xF4A25E, 0xB5551A);
  // Beyaz yanak tüyleri.
  a.p(
    'M284 124 L278 138 L290 140 L284 154 L296 156 L290 166 L310 164 '
    'Q326 170 340 172 Q354 170 370 164 L390 166 L384 156 L396 154 L390 140 '
    'L402 138 L396 124 Q370 146 340 146 Q310 146 284 124 Z',
    0xFFF6EA,
  );
  a.p(
    'M326 114 Q340 110 354 114 Q348 136 343 150 L337 150 Q332 136 326 114 Z',
    0xE8782A,
  );
  for (final d in const [-1, 1]) {
    final x = 340 + d * 26.0;
    if (happy) {
      a.s('M${x - 10} 124 Q$x 110 ${x + 10} 124', k, 3.5);
    } else {
      a.p('M${x - 11} 122 Q$x 108 ${x + 11} 122 Q$x 132 ${x - 11} 122 Z', k);
      a.o(x, 120, 6.5, 6, 0xF2A21E);
      a.o(x, 120, 2.2, 5.6, k);
      a.c(x - 2.4, 117, 1.8, w);
    }
  }
  a.p('M331 146 Q340 141 349 146 Q347 155 340 158 Q333 155 331 146 Z', k);
  a.o(336, 146, 3.6, 1.6, w, op: 0.7);
  if (happy) {
    a.p('M326 160 Q340 176 354 160 Q340 164 326 160 Z', 0x5A1E2A);
  } else {
    a.s(
      'M340 158 L340 162 M340 162 Q334 168 328 164 M340 162 Q346 168 352 164',
      k,
      2.2,
    );
  }
}

// --- Kurt ------------------------------------------------------------------

void _kurtBg(Art a) {
  a.p(_full, 0x1B1F4A);
  a.p('M120 8 H560 V220 H120 Z', 0x262B62, op: 0.55);
  for (var i = 0; i < 40; i++) {
    final x = 125 + a.rnd() * 430;
    final y = 12 + a.rnd() * 280;
    a.c(x, y, a.rnd() * 1.4 + 0.5, w, op: 0.4 + a.rnd() * 0.5);
  }
  // Ay.
  a.c(190, 96, 58, 0xEDEBFA, op: 0.12);
  a.c(190, 96, 46, 0xEDEBFA, op: 0.2);
  a.c(190, 96, 36, 0xEDEBFA);
  a.c(180, 88, 7, 0xCFCCE8, op: 0.8);
  a.c(202, 108, 5, 0xCFCCE8, op: 0.8);
  // Uzak dağlar.
  a.p(
    'M120 330 L200 220 L250 290 L310 190 L380 300 L430 240 L500 310 L560 250 V340 H120 Z',
    0x3A3F7A,
  );
  a.p('M310 190 L338 232 L322 226 L310 244 L296 226 L284 232 Z', 0xEAF0FF);
  a.p('M200 220 L222 252 L208 246 L196 258 L180 246 Z', 0xEAF0FF);
  a.p('M430 240 L452 270 L438 264 L426 276 L410 264 Z', 0xEAF0FF);
  // Yakın dağ.
  a.p(
    'M120 380 L230 290 L300 350 L360 320 L460 390 L560 320 V420 H120 Z',
    0x2A2E5E,
  );
  a.p('M230 290 L262 322 L244 316 L230 332 L212 316 Z', 0xDCE6FF);
  a.p('M560 320 L530 344 L544 340 L560 352 Z', 0xDCE6FF);
  // Kar zemini.
  a.p('M120 410 Q250 384 380 414 Q480 436 560 408 V512 H120 Z', 0xDDE6F8);
  a.p('M120 466 Q300 444 560 470 V512 H120 Z', 0xC3CFEE);
  // Karlı çamlar.
  for (final t in const [
    [150, 440, 100],
    [520, 436, 86],
    [200, 462, 60],
  ]) {
    final x = t[0], y = t[1], h = t[2];
    a.p('M${x - 4} ${y + 24} V$y H${x + 4} V${y + 24} Z', 0x2B2548);
    a.p('M${x - 32} $y L$x ${y - h} L${x + 32} $y Z', 0x1C2B4A);
    a.p(
      'M${x - 22} ${y - h * 0.5} L$x ${y - h} L${x + 22} ${y - h * 0.5} Z',
      0xEAF0FF,
    );
  }
  // Pençe izleri.
  for (final p in const [
    [300, 490],
    [340, 478],
    [384, 490],
  ]) {
    a.o(p[0], p[1], 6, 5, 0xA9B4DA);
    a.c(p[0] - 7, p[1] - 8, 2.4, 0xA9B4DA);
    a.c(p[0], p[1] - 11, 2.4, 0xA9B4DA);
    a.c(p[0] + 7, p[1] - 8, 2.4, 0xA9B4DA);
  }
}

void _kurtEars(Art a, double y, double spread, double wd) {
  for (final d in const [-1, 1]) {
    final x = 340 + d * spread;
    a.p(
      'M${x - wd} ${y + 84} L${x + d * 6} $y L${x + wd} ${y + 84} Z',
      0x6A6890,
    );
    a.p(
      'M${x - wd * 0.55} ${y + 76} L${x + d * 6} ${y + 20} L${x + wd * 0.55} ${y + 76} Z',
      0x3E3C58,
    );
    a.p(
      'M${x - wd * 0.3} ${y + 70} L${x + d * 6} ${y + 34} L${x + wd * 0.3} ${y + 70} Z',
      0x8E8CB8,
      op: 0.6,
    );
  }
}

void _kurtA(Art a, bool happy) {
  _kurtEars(a, 24, 70, 36);
  a.dome(0x7C7A9A, 0xA09EBE, 0x555373);
  // Alın çizgileri.
  a.s('M340 58 L340 84 M318 62 L322 82 M362 62 L358 82', 0x555373, 4);
  // Soluk burun bölgesi ve yanaklar.
  a.p(
    'M290 148 Q310 126 340 140 Q370 126 390 148 Q400 184 340 208 Q280 184 290 148 Z',
    0xDAD6E6,
  );
  a.p(
    'M250 140 Q268 170 300 180 Q276 188 262 176 Q250 160 250 140 Z',
    0xB9B6D2,
    op: 0.7,
  );
  a.p(
    'M430 140 Q412 170 380 180 Q404 188 418 176 Q430 160 430 140 Z',
    0xB9B6D2,
    op: 0.7,
  );
  if (happy) {
    a.s('M284 118 Q302 100 320 118', k, 4.5);
    a.s('M360 118 Q378 100 396 118', k, 4.5);
  } else {
    a.o(302, 118, 14, 11, 0xF2C23C);
    a.o(378, 118, 14, 11, 0xF2C23C);
    a.o(302, 118, 4, 9, k);
    a.o(378, 118, 4, 9, k);
    a.c(298, 114, 2, w);
    a.c(374, 114, 2, w);
    a.s('M282 100 Q300 108 320 108', 0x3E3C58, 4);
    a.s('M360 108 Q380 108 398 100', 0x3E3C58, 4);
  }
  a.p('M326 148 Q340 140 354 148 Q350 162 340 166 Q330 162 326 148 Z', k);
  a.o(334, 148, 5, 2.4, w, op: 0.6);
  if (happy) {
    a.s('M340 166 L340 172', k, 3);
    a.p('M318 172 Q340 206 362 172 Q340 180 318 172 Z', k);
    a.o(340, 192, 9, 5, 0xE8758F);
  } else {
    a.s(
      'M340 166 L340 174 M340 174 Q330 184 318 177 M340 174 Q350 184 362 177',
      k,
      3,
    );
  }
}

void _kurtB(Art a, bool happy) {
  _kurtEars(a, 34, 42, 26);
  a.box(0x7C7A9A, 0xA09EBE, 0x555373);
  a.p(
    'M306 132 Q320 120 340 128 Q360 120 374 132 Q380 158 340 164 Q300 158 306 132 Z',
    0xDAD6E6,
  );
  if (happy) {
    a.s('M304 118 Q316 104 328 118', k, 3.5);
    a.s('M352 118 Q364 104 376 118', k, 3.5);
  } else {
    a.o(316, 116, 8, 6.5, 0xF2C23C);
    a.o(364, 116, 8, 6.5, 0xF2C23C);
    a.o(316, 116, 2.4, 5.5, k);
    a.o(364, 116, 2.4, 5.5, k);
    a.s('M302 106 Q314 110 326 110 M354 110 Q366 110 378 106', 0x3E3C58, 3);
  }
  a.p('M332 132 Q340 126 348 132 Q346 141 340 143 Q334 141 332 132 Z', k);
  if (happy) {
    a.p('M328 148 Q340 162 352 148 Q340 154 328 148 Z', k);
  } else {
    a.s(
      'M340 143 L340 148 M340 148 Q334 154 328 151 M340 148 Q346 154 352 151',
      k,
      2,
    );
  }
}

// --- Civciv ---------------------------------------------------------------

void _civcivBg(Art a) {
  a.p(_full, 0xDDF1FF);
  a.c(492, 74, 36, 0xFFF2A8, op: 0.75);
  a.p('M120 356 Q230 326 340 356 Q450 386 560 344 V512 H120 Z', 0xB9DD78);
  a.p('M120 418 Q230 382 340 414 Q450 446 560 398 V512 H120 Z', 0x83C35A);
  for (final p in const [
    [170, 420],
    [214, 382],
    [470, 414],
    [510, 370],
    [442, 462],
  ]) {
    a.c(p[0], p[1], 5, 0xFFFFFF);
    a.c(p[0] - 5, p[1], 4, 0xFFFFFF);
    a.c(p[0] + 5, p[1], 4, 0xFFFFFF);
    a.c(p[0], p[1], 2.4, 0xF2B84B);
  }
}

void _civcivFace(Art a, bool happy, {required bool slim}) {
  final cy = slim ? 124.0 : 126.0;
  final eyeDx = slim ? 25.0 : 42.0;
  final eyeR = slim ? 8.0 : 14.0;
  for (final d in const [-1, 1]) {
    final x = 340 + d * eyeDx;
    a.c(x, cy, eyeR, 0x5A330D);
    a.c(x - eyeR * 0.3, cy - eyeR * 0.35, eyeR * 0.28, w);
  }
  final by = slim ? 143.0 : 158.0;
  if (happy) {
    a.p(
      'M${slim ? 328 : 322} $by Q340 ${by - 12} ${slim ? 352 : 358} $by '
      'Q340 ${by + (slim ? 15 : 20)} ${slim ? 328 : 322} $by Z',
      0xE87919,
    );
    a.p(
      'M${slim ? 331 : 326} ${by + 2} Q340 ${by + (slim ? 12 : 16)} '
      '${slim ? 349 : 354} ${by + 2} Z',
      0x7A2E16,
    );
  } else {
    a.p(
      'M${slim ? 328 : 322} $by Q340 ${by - 10} ${slim ? 352 : 358} $by '
      'Q340 ${by + (slim ? 8 : 11)} ${slim ? 328 : 322} $by Z',
      0xE87919,
    );
  }
}

void _civcivA(Art a, bool happy) {
  a.dome(0xFFD936, 0xFFFF72, 0xE4A510);
  a.p('M326 58 Q338 30 348 58 Q360 34 366 66 Q346 56 326 58 Z', 0xFFF078);
  _civcivFace(a, happy, slim: false);
  a.cheeks(170, 0.25);
}

void _civcivB(Art a, bool happy) {
  a.box(0xFFD936, 0xFFFF72, 0xE4A510);
  a.p('M332 98 Q340 78 348 98 Q358 82 360 104 Q346 98 332 98 Z', 0xFFF078);
  _civcivFace(a, happy, slim: true);
  a.o(310, 146, 9, 5, 0xED93B1, op: 0.22);
  a.o(370, 146, 9, 5, 0xED93B1, op: 0.22);
}
