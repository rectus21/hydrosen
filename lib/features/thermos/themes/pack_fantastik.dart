// Fantastik paketi temaları: Ejderha, Robot, Korsan, Gece, Sihirbaz.
//
// Yeni tema eklemek için [fantastikThemes] listesine bir `ThermosTheme(...)`
// ekle (renkler, background, capChubby/capSlim, isteğe bağlı celebration).
// Liste `const` olduğundan çizim fonksiyonları üst düzey olmalıdır.
import 'dart:math' as math;
import 'dart:ui';

import '../art.dart';
import '../celebration_style.dart';
import '../thermos_theme.dart';

const _fFull = 'M120 8 H560 V512 H120 Z';

/// Dört uçlu parıltı.
void _fSpark(Art a, num x, num y, num r, int hex, {double op = 1}) {
  final q = r * 0.22;
  a.p(
    'M$x ${y - r} Q${x + q} ${y - q} ${x + r} $y Q${x + q} ${y + q} $x ${y + r} '
    'Q${x - q} ${y + q} ${x - r} $y Q${x - q} ${y - q} $x ${y - r} Z',
    hex,
    op: op,
  );
}

/// Beş köşeli yıldız.
void _fStar(Art a, num x, num y, num r, int hex, {double op = 1}) {
  final sb = StringBuffer();
  for (var i = 0; i < 10; i++) {
    final rad = i.isEven ? r : r * 0.45;
    final ang = (i * 36 - 90) * math.pi / 180;
    sb.write(i == 0 ? 'M' : 'L');
    sb.write('${x + math.cos(ang) * rad} ${y + math.sin(ang) * rad} ');
  }
  sb.write('Z');
  a.p(sb.toString(), hex, op: op);
}

const List<ThermosTheme> fantastikThemes = [
  ThermosTheme(
    id: 'ejderha',
    name: 'Ejderha',
    glass: Color(0xFFDDF0CF),
    edge: Color(0xFF27500A),
    water: Color(0xFFE8684A),
    deepWater: Color(0xFF8A2A1A),
    waterSurface: Color(0xFFFAC9B0),
    mark: Color(0xFF27500A),
    label: Color(0xFF27500A),
    band: Color(0xFF7A3B1E),
    bandLight: Color(0xFFC48A4A),
    background: _ejderhaBg,
    capChubby: _ejderhaA,
    capSlim: _ejderhaB,
    celebration: CelebrationStyle(CelebrationKind.embers, [
      0xE8684A,
      0xFAC775,
      0xEF9F27,
    ]),
  ),
  ThermosTheme(
    id: 'robot',
    name: 'Robot',
    glass: Color(0xFFDCE6F0),
    edge: Color(0xFF4A5A6A),
    water: Color(0xFF1FB5C9),
    deepWater: Color(0xFF0B5566),
    waterSurface: Color(0xFFB8F0F7),
    mark: Color(0xFFF2F7FB),
    label: Color(0xFFF2F7FB),
    band: Color(0xFFE8A317),
    bandLight: Color(0xFFFAD36B),
    background: _robotBg,
    capChubby: _robotA,
    capSlim: _robotB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0x1FB5C9,
      0xE8A317,
      0xE24B4A,
      0x97C459,
    ]),
  ),
  ThermosTheme(
    id: 'korsan',
    name: 'Korsan',
    glass: Color(0xFFF3E3BF),
    edge: Color(0xFF6B3E16),
    water: Color(0xFF1D8FB5),
    deepWater: Color(0xFF0B4A66),
    waterSurface: Color(0xFFBDE8F5),
    mark: Color(0xFF3A2008),
    label: Color(0xFF4A2A0E),
    band: Color(0xFFB22E2E),
    bandLight: Color(0xFFE05A4F),
    background: _korsanBg,
    capChubby: _korsanA,
    capSlim: _korsanB,
    celebration: CelebrationStyle(CelebrationKind.bubbles, [
      0xBDE8F5,
      0xFFFFFF,
      0xFAC775,
    ]),
  ),
  ThermosTheme(
    id: 'gece',
    name: 'Gece',
    glass: Color(0xFFB9C0F0),
    edge: Color(0xFF2B3380),
    water: Color(0xFF6F86F2),
    deepWater: Color(0xFF3443B0),
    waterSurface: Color(0xFFD6DCFF),
    mark: Color(0xFFEEF0FF),
    label: Color(0xFFEEF0FF),
    band: Color(0xFF3C4AA8),
    bandLight: Color(0xFF7F8EE0),
    background: _geceBg,
    capChubby: _geceA,
    capSlim: _geceB,
    celebration: CelebrationStyle(CelebrationKind.twinkles, [
      0xFFF1B8,
      0xFFFFFF,
      0xB9C0F0,
    ]),
  ),
  ThermosTheme(
    id: 'sihirbaz',
    name: 'Sihirbaz',
    glass: Color(0xFFE6D7F7),
    edge: Color(0xFF5B2E91),
    water: Color(0xFF7F3FBF),
    deepWater: Color(0xFF3E1A6E),
    waterSurface: Color(0xFFD9B8F5),
    mark: Color(0xFFF6EDFF),
    label: Color(0xFFF6EDFF),
    band: Color(0xFFF2B632),
    bandLight: Color(0xFFFFDB70),
    background: _sihirbazBg,
    capChubby: _sihirbazA,
    capSlim: _sihirbazB,
    celebration: CelebrationStyle(CelebrationKind.stardust, [
      0xF2B632,
      0xD9B8F5,
      0xFFFFFF,
    ]),
  ),
  ThermosTheme(
    id: 'maviejderha',
    name: 'Mavi Ejderha',
    glass: Color(0xFFE2ECF8),
    edge: Color(0xFF244C8C),
    water: Color(0xFF2E8CE6),
    deepWater: Color(0xFF123F8C),
    waterSurface: Color(0xFFBFE4FF),
    mark: Color(0xFFEAF3FF),
    label: Color(0xFFEAF3FF),
    band: Color(0xFF2F66C8),
    bandLight: Color(0xFF7FB0F0),
    background: _maviEjderhaBg,
    capChubby: _maviEjderhaA,
    capSlim: _maviEjderhaB,
    celebration: CelebrationStyle(CelebrationKind.stardust, [
      0x38D6F5,
      0x8FD0FF,
      0xE6F6FF,
    ]),
  ),
];

// --- Ejderha ---------------------------------------------------------------

void _ejderhaBg(Art a) {
  a.p(_fFull, 0xFDE9D0);
  a.c(200, 96, 40, 0xFAC775);
  a.c(200, 96, 28, 0xFFF1D6, op: 0.8);
  // Uzak dağlar
  a.p(
    'M120 330 L190 210 L240 280 L300 190 L370 300 L430 230 L490 310 L560 250 V512 H120 Z',
    0xC9B9A3,
  );
  a.p('M300 190 L282 218 L300 212 L316 222 Z', w, op: 0.9);
  a.p('M190 210 L176 232 L192 228 L204 236 Z', w, op: 0.9);
  // Kale (sağ)
  a.p('M462 300 h80 v212 h-80 Z', 0x8B7F72);
  for (final x in const [462, 480, 498, 516, 534]) {
    a.p('M$x 290 h10 v14 h-10 Z', 0x8B7F72);
  }
  a.p('M474 244 h56 v60 h-56 Z', 0x9C9082);
  a.p('M468 244 L502 204 L536 244 Z', 0xB22E2E);
  a.p('M502 204 v-26 h18 l-4 8 l4 8 h-14 Z', 0xE8684A);
  a.p('M494 340 q8 -22 16 0 v26 h-16 Z', 0x3A2A22);
  a.p('M492 262 q4 -10 8 0 v12 h-8 Z', 0x3A2A22);
  // Yeşil tepeler
  a.p('M120 400 Q220 350 320 395 Q430 440 560 380 V512 H120 Z', 0x97C459);
  a.p('M120 458 Q250 430 360 458 Q470 482 560 450 V512 H120 Z', 0x639922);
  // Minik uçan ejderha
  a.p('M200 190 Q214 176 230 188 Q216 186 208 196 Z', 0x3F7D2A);
  a.p('M232 188 Q246 178 256 190 Q246 188 240 196 Z', 0x3F7D2A);
  a.o(231, 194, 8, 4, 0x6FB04A);
}

void _ejderhaA(Art a, bool happy) {
  // Kulak yüzgeçleri
  for (final d in const [-1, 1]) {
    a.p(
      'M${340 + d * 90} 110 Q${340 + d * 132} 80 ${340 + d * 120} 138 '
      'Q${340 + d * 110} 120 ${340 + d * 92} 138 Z',
      0xE8684A,
    );
  }
  // Boynuzlar
  for (final d in const [-1, 1]) {
    a.p(
      'M${340 + d * 44} 62 Q${340 + d * 56} 30 ${340 + d * 76} 22 '
      'Q${340 + d * 68} 46 ${340 + d * 68} 72 Z',
      0xFFF1D6,
    );
    a.p(
      'M${340 + d * 52} 58 Q${340 + d * 60} 40 ${340 + d * 72} 30 '
      'Q${340 + d * 62} 50 ${340 + d * 62} 66 Z',
      0xFAC775,
      op: 0.8,
    );
  }
  a.dome(0x6FB04A, 0x9BD36F, 0x3F7D2A);
  // Sırt pulları
  for (final x in const [310, 340, 370]) {
    a.p('M${x - 9} 62 L$x 40 L${x + 9} 62 Z', 0xE8684A);
  }
  // Gözler
  a.eye(300, 118, 14);
  a.eye(380, 118, 14);
  a.s('M286 100 Q300 94 314 100', 0x27500A, 3);
  a.s('M366 100 Q380 94 394 100', 0x27500A, 3);
  // Burun kısmı
  a.o(340, 166, 58, 38, 0xE6F0A8);
  a.o(316, 156, 6, 8, 0x27500A);
  a.o(364, 156, 6, 8, 0x27500A);
  a.cheeks(140, 0.5);
  if (happy) {
    // Kocaman gülüş, dil ve minik alev
    a.p('M298 170 Q340 214 382 170 Q340 182 298 170 Z', k);
    a.o(340, 190, 14, 8, 0xED93B1);
    a.p('M308 172 l5 9 l5 -8 Z', w);
    a.p('M372 172 l-5 9 l-5 -8 Z', w);
    a.p(
      'M392 190 Q410 172 430 180 Q418 188 432 198 Q410 202 392 190 Z',
      0xEF9F27,
    );
    a.p(
      'M398 190 Q412 180 422 186 Q414 192 422 196 Q408 198 398 190 Z',
      0xFAC775,
    );
  } else {
    a.s('M308 178 Q340 196 372 178', k, 3.5);
    a.p('M366 180 l4 8 l4 -9 Z', w);
  }
}

void _ejderhaB(Art a, bool happy) {
  for (final d in const [-1, 1]) {
    a.p(
      'M${340 + d * 36} 94 Q${340 + d * 44} 62 ${340 + d * 62} 54 '
      'Q${340 + d * 56} 76 ${340 + d * 54} 98 Z',
      0xFFF1D6,
    );
  }
  for (final x in const [322, 340, 358]) {
    a.p('M${x - 7} 92 L$x 76 L${x + 7} 92 Z', 0xE8684A);
  }
  a.box(0x6FB04A, 0x9BD36F, 0x3F7D2A);
  a.c(320, 118, 5.5, k);
  a.c(360, 118, 5.5, k);
  a.c(318, 116, 1.8, w);
  a.c(358, 116, 1.8, w);
  a.o(340, 144, 26, 16, 0xE6F0A8);
  a.o(332, 140, 3, 4, 0x27500A);
  a.o(348, 140, 3, 4, 0x27500A);
  if (happy) {
    a.p('M322 150 Q340 168 358 150 Q340 156 322 150 Z', k);
    a.o(340, 158, 6, 3, 0xED93B1);
  } else {
    a.s('M326 150 Q340 158 354 150', k, 2.5);
  }
}

// --- Robot -----------------------------------------------------------------

void _robotBg(Art a) {
  a.p(_fFull, 0x1E2A3A);
  // Devre yolları
  for (final d in const [
    'M120 70 H190 L214 94 H300',
    'M560 120 H500 L476 144 H430',
    'M120 260 H170 L196 286 H210',
    'M560 300 H520 L494 326 H470',
    'M120 420 H230 L254 444 H330',
    'M560 440 H470 L446 464 H400',
  ]) {
    a.s(d, 0x2F4A63, 4);
  }
  for (final pt in const [
    [300, 94],
    [430, 144],
    [210, 286],
    [470, 326],
    [330, 444],
    [400, 464],
  ]) {
    a.c(pt[0], pt[1], 7, 0x1FB5C9, op: 0.8);
    a.c(pt[0], pt[1], 3, 0x1E2A3A);
  }
  // Dişliler
  for (final g in const [
    [160, 160, 34, 0x3A5470],
    [520, 220, 28, 0x34506A],
    [150, 360, 26, 0x34506A],
    [510, 400, 38, 0x3A5470],
  ]) {
    final x = g[0], y = g[1], r = g[2], col = g[3];
    for (var i = 0; i < 8; i++) {
      a.o(x, y, r + 7, 5, col, rot: i * 22.5);
    }
    a.c(x, y, r, col);
    a.c(x, y, r * 0.45, 0x1E2A3A);
  }
  a.p('M120 480 H560 V512 H120 Z', 0x2F4A63);
  for (var x = 130; x < 560; x += 40) {
    a.p('M$x 488 h20 v8 h-20 Z', 0xE8A317, op: 0.7);
  }
}

void _robotHead(Art a, bool happy, {required bool slim}) {
  const cx = 340;
  final w2 = slim ? 40 : 52;
  final h2 = slim ? 26 : 38;
  final cy = slim ? 126 : 128;
  // Ekran
  a.p(
    'M${cx - w2} ${cy - h2 + 8} Q${cx - w2} ${cy - h2} ${cx - w2 + 10} ${cy - h2} '
    'H${cx + w2 - 10} Q${cx + w2} ${cy - h2} ${cx + w2} ${cy - h2 + 8} '
    'V${cy + h2 - 8} Q${cx + w2} ${cy + h2} ${cx + w2 - 10} ${cy + h2} '
    'H${cx - w2 + 10} Q${cx - w2} ${cy + h2} ${cx - w2} ${cy + h2 - 8} Z',
    0x14202E,
  );
  final ex = slim ? 20 : 26;
  final ey = slim ? cy - 6 : cy - 8;
  final r = slim ? 8 : 11;
  if (happy) {
    for (final d in const [-1, 1]) {
      a.s(
        'M${cx + d * ex - r} ${ey + 4} Q${cx + d * ex} ${ey - r - 4} ${cx + d * ex + r} ${ey + 4}',
        0x7BF0FF,
        slim ? 4 : 5,
      );
    }
    final mw = slim ? 14 : 20;
    a.p(
      'M${cx - mw} ${cy + 10} Q$cx ${cy + (slim ? 30 : 38)} ${cx + mw} ${cy + 10} Z',
      0x7BF0FF,
    );
  } else {
    for (final d in const [-1, 1]) {
      a.c(cx + d * ex, ey, r + 4, 0x1FB5C9, op: 0.3);
      a.c(cx + d * ex, ey, r, 0x7BF0FF);
      a.c(cx + d * ex - 3, ey - 3, r * 0.3, w);
    }
    final mw = slim ? 12 : 18;
    a.s('M${cx - mw} ${cy + 16} H${cx + mw}', 0x7BF0FF, slim ? 3 : 4);
  }
  // Küçük LED'ler
  a.c(cx - w2 + 8, cy + h2 - 8, 3, 0xE24B4A);
  a.c(cx + w2 - 8, cy + h2 - 8, 3, 0xFAD36B);
}

void _robotA(Art a, bool happy) {
  // Anten
  a.s('M340 52 V28', 0x5F7184, 5);
  if (happy) a.c(340, 22, 19, 0xFAD36B, op: 0.35);
  a.c(340, 22, 12, happy ? 0xFAD36B : 0xE24B4A);
  a.c(336, 18, 4, w, op: 0.8);
  // Kulak parçaları
  for (final d in const [-1, 1]) {
    a.p('M${340 + d * 100 - 10} 110 h20 v40 h-20 Z', 0x5F7184);
    a.p('M${340 + d * 100 - 6} 118 h12 v24 h-12 Z', 0x8FA1B3);
  }
  a.dome(0xB4C4D4, 0xE3ECF4, 0x7B8EA1);
  a.s('M270 78 Q340 58 410 78', 0x7B8EA1, 3);
  _robotHead(a, happy, slim: false);
}

void _robotB(Art a, bool happy) {
  a.s('M340 92 V64', 0x5F7184, 5);
  if (happy) a.c(340, 58, 17, 0xFAD36B, op: 0.35);
  a.c(340, 58, 11, happy ? 0xFAD36B : 0xE24B4A);
  a.c(336, 54, 3.5, w, op: 0.8);
  a.box(0xB4C4D4, 0xE3ECF4, 0x7B8EA1);
  _robotHead(a, happy, slim: true);
}

// --- Korsan ----------------------------------------------------------------

void _korsanBg(Art a) {
  a.p(_fFull, 0xBDE8F5);
  a.c(200, 100, 44, 0xFFE9A8);
  a.c(200, 100, 30, 0xFFF6D6, op: 0.8);
  // Bulutlar
  for (final c in const [
    [470, 90],
    [420, 150],
  ]) {
    a.o(c[0], c[1], 44, 14, w, op: 0.85);
    a.o(c[0] - 18, c[1] - 12, 24, 14, w, op: 0.85);
  }
  // Martı
  a.s('M250 170 Q262 158 274 170 Q286 158 298 170', 0x4A5A6A, 3);
  // Gemi
  a.s('M430 350 V190', 0x6B3E16, 6);
  a.p('M434 196 Q500 230 434 296 Z', 0xF8F2E2);
  a.p('M426 210 Q372 240 426 290 Z', 0xF8F2E2);
  a.p('M434 196 l26 8 l-26 8 Z', 0xB22E2E);
  a.p('M360 330 H520 Q500 380 470 388 H400 Q372 376 360 330 Z', 0x6B3E16);
  a.s('M366 346 H514', 0x3A2008, 3);
  // Deniz
  a.p(
    'M120 380 Q200 360 280 380 Q360 400 440 380 Q500 366 560 380 V512 H120 Z',
    0x378ADD,
  );
  a.p('M120 420 Q210 400 300 424 Q400 448 560 414 V512 H120 Z', 0x1D6FB5);
  a.p('M120 466 Q240 448 340 470 Q450 492 560 460 V512 H120 Z', 0x0B4A66);
  for (final p in const [
    [160, 400],
    [320, 440],
    [480, 410],
    [220, 480],
  ]) {
    a.s('M${p[0]} ${p[1]} q12 -8 24 0 q12 8 24 0', w, 2.5);
  }
}

void _korsanA(Art a, bool happy) {
  a.dome(0xF5C9A0, 0xFBE0C4, 0xD9A074);
  // Bandana
  a.p('M246 118 Q250 60 340 50 Q430 60 434 118 Q340 92 246 118 Z', 0xC8342F);
  a.p('M246 118 Q340 92 434 118 L432 128 Q340 104 248 128 Z', 0x8E1F1C);
  for (final d in const [
    [290, 76],
    [330, 66],
    [372, 72],
    [406, 92],
    [308, 96],
    [356, 94],
  ]) {
    a.c(d[0], d[1], 4, w, op: 0.9);
  }
  // Düğüm
  a.p('M424 104 Q458 92 466 66 Q442 80 424 90 Z', 0xC8342F);
  a.p('M424 108 Q462 112 474 138 Q444 128 424 118 Z', 0xC8342F);
  a.c(424, 104, 8, 0x8E1F1C);
  // Sağ göz
  a.eye(380, 138, 13);
  // Göz bandı
  a.s('M246 120 L436 156', k, 4);
  a.o(298, 140, 22, 19, k);
  a.o(292, 134, 8, 5, 0x5F5E5A, op: 0.7, rot: -20);
  a.cheeks(168, 0.5);
  a.p('M338 146 Q344 154 336 160 Q330 154 338 146 Z', 0xD9A074);
  // Küpe
  a.s('M438 154 q10 6 4 18', 0xFAC775, 3);
  if (happy) {
    a.p('M300 176 Q340 214 380 176 Q340 186 300 176 Z', k);
    a.o(340, 196, 11, 6, 0xE24B4A);
    a.p('M346 178 l8 0 l-3 9 Z', 0xFAC775);
  } else {
    a.s('M312 180 Q340 196 368 180', k, 3.5);
    a.p('M350 184 l8 -2 l-2 9 Z', 0xFAC775);
  }
}

void _korsanB(Art a, bool happy) {
  a.box(0xF5C9A0, 0xFBE0C4, 0xD9A074);
  a.p(
    'M284 112 Q284 90 310 90 L370 90 Q396 92 396 112 Q340 102 284 112 Z',
    0xC8342F,
  );
  a.p('M284 108 Q340 98 396 108 L396 116 Q340 106 284 116 Z', 0x8E1F1C);
  for (final x in const [304, 330, 356, 380]) {
    a.c(x, 98, 2.5, w, op: 0.9);
  }
  a.p('M392 100 Q412 94 418 78 Q404 88 392 92 Z', 0xC8342F);
  a.p('M392 106 Q414 108 420 124 Q404 118 392 114 Z', 0xC8342F);
  a.s('M286 116 L394 134', k, 3);
  a.o(318, 128, 12, 10, k);
  a.c(364, 128, 5, k);
  a.c(362, 126, 1.6, w);
  if (happy) {
    a.p('M322 146 Q340 164 358 146 Q340 152 322 146 Z', k);
  } else {
    a.s('M324 150 Q340 158 356 150', k, 2.5);
  }
}

// --- Gece ------------------------------------------------------------------

void _geceBg(Art a) {
  a.p(_fFull, 0x1B2255);
  a.p('M120 8 H560 V200 Q340 260 120 200 Z', 0x262F6E, op: 0.6);
  // Büyük ay
  a.c(180, 270, 52, 0xFFF1B8, op: 0.12);
  a.c(180, 270, 40, 0xFFF1B8);
  a.c(168, 262, 6, 0xE3C766, op: 0.7);
  a.c(192, 284, 8, 0xE3C766, op: 0.7);
  a.c(190, 252, 4, 0xE3C766, op: 0.7);
  // Yıldızlar
  for (final s in const [
    [160, 60, 10],
    [250, 130, 7],
    [320, 40, 9],
    [190, 220, 6],
    [380, 170, 7],
    [520, 230, 8],
    [150, 340, 8],
    [530, 350, 6],
    [160, 460, 7],
    [500, 440, 9],
    [400, 40, 6],
  ]) {
    _fSpark(a, s[0], s[1], s[2], 0xFFF1B8);
  }
  for (final s in const [
    [220, 80],
    [290, 200],
    [410, 90],
    [200, 280],
    [540, 170],
    [170, 400],
    [520, 300],
    [300, 30],
    [450, 200],
  ]) {
    a.c(s[0], s[1], 2.5, w, op: 0.85);
  }
  // Tepeler
  a.p('M120 400 Q220 340 320 390 Q430 440 560 370 V512 H120 Z', 0x2B3380);
  a.p('M120 456 Q250 420 360 454 Q470 484 560 440 V512 H120 Z', 0x141A42);
  // Küçük ev
  a.p('M186 420 h40 v34 h-40 Z', 0x141A42);
  a.p('M180 422 L206 400 L232 422 Z', 0x0E1233);
  a.p('M198 432 h16 v14 h-16 Z', 0xF6D860);
}

void _geceFace(Art a, bool happy, {required bool slim}) {
  final cy = slim ? 126 : 128;
  final ex = slim ? 20 : 30;
  final r = slim ? 8 : 12;
  // Kraterler
  if (!slim) {
    a.c(278, 86, 9, 0xE3C766, op: 0.6);
    a.c(414, 150, 12, 0xE3C766, op: 0.6);
    a.c(396, 78, 6, 0xE3C766, op: 0.6);
  } else {
    a.c(296, 150, 5, 0xE3C766, op: 0.6);
    a.c(384, 148, 6, 0xE3C766, op: 0.6);
  }
  if (happy) {
    for (final d in const [-1, 1]) {
      a.o(340 + d * ex, cy, r, r * 1.1, 0x1B2255);
      a.c(340 + d * ex - 3, cy - 3, r * 0.4, w);
      a.c(340 + d * ex + 3, cy + 3, r * 0.2, w);
    }
  } else {
    // Uyuyan gözler
    for (final d in const [-1, 1]) {
      a.s(
        'M${340 + d * ex - r} ${cy - 2} Q${340 + d * ex} ${cy + r} ${340 + d * ex + r} ${cy - 2}',
        0x1B2255,
        slim ? 3 : 4,
      );
    }
  }
  final by = cy + (slim ? 14 : 22);
  final bw = slim ? 8 : 12;
  a.o(340 - ex - 8, by, bw, bw * 0.6, 0xED93B1, op: 0.55);
  a.o(340 + ex + 8, by, bw, bw * 0.6, 0xED93B1, op: 0.55);
  final my = cy + (slim ? 20 : 30);
  if (happy) {
    final mw = slim ? 10 : 16;
    final mh = slim ? 20 : 28;
    a.p(
      'M${340 - mw} $my Q340 ${my + mh} ${340 + mw} $my Q340 ${my + 6} ${340 - mw} $my Z',
      0x1B2255,
    );
  } else {
    a.s('M332 $my Q340 ${my + 8} 348 $my', 0x1B2255, slim ? 2.5 : 3.5);
  }
}

void _geceA(Art a, bool happy) {
  a.dome(0xFFF1B8, 0xFFFBE0, 0xE3C766);
  // Uyku külahı
  a.p(
    'M262 96 Q290 40 372 36 Q414 36 420 66 Q404 56 380 60 Q320 66 296 110 Z',
    0x3C4AA8,
  );
  a.p('M252 104 Q300 76 430 100 Q420 120 400 114 Q310 92 262 124 Z', 0xF4F0E0);
  a.c(424, 74, 11, 0xF4F0E0);
  _fStar(a, 332, 66, 8, 0xFFF1B8);
  _geceFace(a, happy, slim: false);
  if (happy) {
    _fSpark(a, 250, 56, 12, 0xFFF1B8);
    _fSpark(a, 440, 130, 9, w);
  } else {
    a.s('M446 150 h14 l-14 14 h14', 0xFFF1B8, 3);
  }
}

void _geceB(Art a, bool happy) {
  a.box(0xFFF1B8, 0xFFFBE0, 0xE3C766);
  a.p(
    'M284 108 Q284 90 310 90 L370 90 Q396 92 396 108 Q340 98 284 112 Z',
    0x3C4AA8,
  );
  a.p('M284 106 Q340 92 396 106 L396 112 Q340 100 284 114 Z', 0xF4F0E0);
  _geceFace(a, happy, slim: true);
  if (happy) {
    _fSpark(a, 414, 90, 9, 0xFFF1B8);
  } else {
    a.s('M406 96 h12 l-12 12 h12', 0xFFF1B8, 2.5);
  }
}

// --- Sihirbaz --------------------------------------------------------------

void _sihirbazBg(Art a) {
  a.p(_fFull, 0x2A1A4D);
  a.p('M120 8 H560 V260 Q340 330 120 260 Z', 0x3B2670, op: 0.6);
  // Uzak kule
  a.p('M470 330 h36 v182 h-36 Z', 0x4B3490);
  a.p('M462 330 L488 262 L514 330 Z', 0x7F4FD0);
  a.p('M480 380 q8 -16 16 0 v22 h-16 Z', 0xFFDB70);
  _fStar(a, 488, 254, 8, 0xFFDB70);
  // Işıltılar
  for (final s in const [
    [160, 80, 14, 0xFFDB70],
    [250, 160, 9, 0xD9B8F5],
    [420, 70, 12, 0xD9B8F5],
    [520, 190, 10, 0xFFDB70],
    [180, 260, 10, 0xD9B8F5],
    [300, 40, 8, 0xFFDB70],
    [150, 380, 12, 0xFFDB70],
    [530, 450, 12, 0xD9B8F5],
    [200, 470, 9, 0xFFDB70],
    [400, 440, 8, 0xD9B8F5],
  ]) {
    _fSpark(a, s[0], s[1], s[2], s[3]);
  }
  for (final s in const [
    [210, 120],
    [350, 120],
    [470, 150],
    [150, 200],
    [230, 340],
    [540, 320],
    [300, 460],
    [170, 450],
  ]) {
    a.c(s[0], s[1], 2.5, w, op: 0.85);
  }
  // Zemin
  a.p('M120 470 Q250 440 360 466 Q470 490 560 456 V512 H120 Z', 0x1A0F33);
  // İksir şişesi
  a.p('M184 438 h24 v-18 h-8 v-10 h-8 v10 h-8 Z', 0xD9B8F5);
  a.c(196, 448, 22, 0xD9B8F5);
  a.c(196, 452, 17, 0x7F3FBF);
  a.c(190, 446, 4, w, op: 0.6);
  // Kitap
  a.p('M440 470 h70 v16 h-70 Z', 0xB22E2E);
  a.p('M444 472 h62 v4 h-62 Z', 0xFFDB70);
}

void _sihirbazHat(Art a, {required bool slim}) {
  if (!slim) {
    a.p('M258 100 Q300 70 322 24 Q334 6 350 20 Q356 52 424 100 Z', 0x7F4FD0);
    a.p('M258 100 Q296 72 316 34 Q310 80 282 108 Z', 0xA77BEC, op: 0.7);
    a.p('M262 88 Q340 66 420 88 L426 104 Q340 82 256 104 Z', 0xF2B632);
    a.o(340, 106, 112, 14, 0x5B2E91);
    a.o(340, 102, 112, 12, 0x7F4FD0);
    _fStar(a, 336, 52, 9, 0xFFDB70);
    _fStar(a, 372, 76, 6, 0xFFDB70);
    _fSpark(a, 310, 72, 6, w);
    a.c(352, 18, 5, 0xFFDB70);
  } else {
    a.p('M296 92 Q326 66 338 30 Q348 18 358 30 Q362 60 388 92 Z', 0x7F4FD0);
    a.p('M296 92 Q322 68 332 40 Q330 76 312 98 Z', 0xA77BEC, op: 0.7);
    a.p('M300 80 Q342 66 386 80 L390 92 Q342 78 296 92 Z', 0xF2B632);
    a.o(340, 94, 66, 10, 0x5B2E91);
    a.o(340, 91, 66, 8, 0x7F4FD0);
    _fStar(a, 344, 56, 7, 0xFFDB70);
    a.c(348, 28, 4, 0xFFDB70);
  }
}

void _sihirbazA(Art a, bool happy) {
  a.dome(0xF5C9A0, 0xFBE0C4, 0xD9A074);
  // Sakal
  a.p(
    'M256 150 Q262 206 340 222 Q418 206 424 150 Q388 186 340 176 Q292 186 256 150 Z',
    0xF4F0F8,
  );
  a.p('M300 180 Q340 200 380 180 Q340 214 300 180 Z', 0xD6CFE0, op: 0.6);
  // Burun ve bıyık
  a.o(340, 148, 9, 7, 0xE7AE86);
  a.o(318, 166, 24, 9, 0xF4F0F8, rot: 12);
  a.o(362, 166, 24, 9, 0xF4F0F8, rot: -12);
  // Kaşlar ve gözler
  a.o(304, 122, 18, 7, 0xF4F0F8, rot: -8);
  a.o(376, 122, 18, 7, 0xF4F0F8, rot: 8);
  if (happy) {
    for (final d in const [-1, 1]) {
      a.s(
        'M${340 + d * 36 - 11} 138 Q${340 + d * 36} 120 ${340 + d * 36 + 11} 138',
        k,
        4,
      );
    }
    a.cheeks(156, 0.5);
    _fSpark(a, 240, 60, 12, 0xFFDB70);
    _fSpark(a, 446, 124, 10, w);
    _fSpark(a, 254, 160, 8, 0xD9B8F5);
  } else {
    a.eye(304, 138, 10);
    a.eye(376, 138, 10);
    a.cheeks(156, 0.4);
  }
  _sihirbazHat(a, slim: false);
}

void _sihirbazB(Art a, bool happy) {
  a.box(0xF5C9A0, 0xFBE0C4, 0xD9A074);
  a.p(
    'M290 138 Q296 170 340 176 Q384 170 390 138 Q366 154 340 148 Q314 154 290 138 Z',
    0xF4F0F8,
  );
  a.o(340, 134, 6, 5, 0xE7AE86);
  a.o(326, 144, 14, 6, 0xF4F0F8, rot: 12);
  a.o(354, 144, 14, 6, 0xF4F0F8, rot: -12);
  a.o(322, 112, 11, 4.5, 0xF4F0F8, rot: -8);
  a.o(358, 112, 11, 4.5, 0xF4F0F8, rot: 8);
  if (happy) {
    for (final d in const [-1, 1]) {
      a.s(
        'M${340 + d * 18 - 7} 126 Q${340 + d * 18} 114 ${340 + d * 18 + 7} 126',
        k,
        3,
      );
    }
    _fSpark(a, 286, 70, 9, 0xFFDB70);
    _fSpark(a, 408, 110, 8, w);
  } else {
    a.c(322, 122, 4.5, k);
    a.c(358, 122, 4.5, k);
    a.c(320, 120, 1.5, w);
    a.c(356, 120, 1.5, w);
  }
  _sihirbazHat(a, slim: true);
}

// --- Mavi Ejderha ----------------------------------------------------------

void _maviPagoda(Art a, num cx, num base, num s, int hex) {
  var y = base.toDouble();
  for (var i = 0; i < 4; i++) {
    final w = (34 - i * 6) * s;
    a.p(
      'M${cx - w + 8 * s} $y h${2 * (w - 8 * s)} v${-20 * s} h${-2 * (w - 8 * s)} Z',
      hex,
    );
    final ry = y - 20 * s;
    a.p(
      'M${cx - w - 10 * s} ${ry + 2 * s} Q${cx - w + 6 * s} ${ry + 8 * s} ${cx - w + 16 * s} $ry '
      'L${cx + w - 16 * s} $ry Q${cx + w - 6 * s} ${ry + 8 * s} ${cx + w + 10 * s} ${ry + 2 * s} '
      'Q${cx + w - 8 * s} ${ry - 4 * s} $cx ${ry - 22 * s} '
      'Q${cx - w + 8 * s} ${ry - 4 * s} ${cx - w - 10 * s} ${ry + 2 * s} Z',
      hex,
    );
    y = ry - 14 * s;
  }
  a.p('M${cx - 1.5 * s} ${y - 6 * s} h${3 * s} v${-24 * s} h${-3 * s} Z', hex);
}

void _maviEjderhaBg(Art a) {
  a.p(_fFull, 0x14224A);
  a.p('M120 8 H560 V260 H120 Z', 0x1B2E62, op: 0.6);
  // Yıldızlar
  for (final st in const [
    [150.0, 40.0],
    [210.0, 80.0],
    [260.0, 30.0],
    [330.0, 64.0],
    [400.0, 28.0],
    [450.0, 90.0],
    [520.0, 50.0],
    [170.0, 130.0],
    [300.0, 120.0],
    [380.0, 150.0],
    [540.0, 140.0],
  ]) {
    a.c(st[0], st[1], 2, 0xE6F0FF, op: 0.85);
  }
  // Ay
  a.c(210, 150, 52, 0xCFE4FF, op: 0.12);
  a.c(210, 150, 40, 0xCFE4FF, op: 0.2);
  a.c(210, 150, 30, 0xEAF3FF);
  a.c(200, 142, 6, 0xC2D6F0, op: 0.7);
  a.c(220, 160, 4, 0xC2D6F0, op: 0.7);
  // Uzak dağlar
  a.p(
    'M120 330 L180 250 L230 300 L300 220 L370 310 L440 250 L500 300 L560 240 V512 H120 Z',
    0x2B4A86,
  );
  _maviPagoda(a, 440, 270, 0.9, 0x0F1B3E);
  // Sis
  a.o(250, 320, 150, 20, 0xA9C6F0, op: 0.18);
  a.o(480, 350, 110, 16, 0xA9C6F0, op: 0.16);
  a.p(
    'M120 380 L190 310 L250 360 L330 290 L420 380 L490 330 L560 370 V512 H120 Z',
    0x223C70,
  );
  a.o(330, 400, 170, 22, 0xA9C6F0, op: 0.2);
  a.p(
    'M120 440 L220 380 L300 430 L400 370 L480 430 L560 400 V512 H120 Z',
    0x1A2F5C,
  );
  a.o(200, 460, 130, 18, 0xA9C6F0, op: 0.18);
  a.p('M120 480 Q250 450 360 480 Q470 500 560 470 V512 H120 Z', 0x0F1B3E);
  // Bulutlar
  for (final cl in const [
    [440.0, 120.0, 1.0],
    [160.0, 230.0, 0.8],
  ]) {
    final x = cl[0], y = cl[1], s = cl[2];
    a.o(x, y, 44 * s, 10 * s, 0x6C8CC4, op: 0.5);
    a.o(x - 14 * s, y - 8 * s, 22 * s, 9 * s, 0x6C8CC4, op: 0.5);
    a.o(x + 16 * s, y - 6 * s, 18 * s, 8 * s, 0x6C8CC4, op: 0.5);
  }
}

/// Geriye ve yukarıya kıvrılan boynuz (d: -1 sol, 1 sağ).
String _maviHorn(int d, num x0, num y0, num s) {
  return 'M${340 + d * x0} $y0 '
      'Q${340 + d * (x0 + 10 * s)} ${y0 - 34 * s} ${340 + d * (x0 + 44 * s)} ${y0 - 52 * s} '
      'Q${340 + d * (x0 + 74 * s)} ${y0 - 66 * s} ${340 + d * (x0 + 84 * s)} ${y0 - 96 * s} '
      'Q${340 + d * (x0 + 58 * s)} ${y0 - 84 * s} ${340 + d * (x0 + 34 * s)} ${y0 - 70 * s} '
      'Q${340 + d * (x0 - 10 * s)} ${y0 - 48 * s} ${340 + d * (x0 - 22 * s)} ${y0 + 6 * s} Z';
}

void _maviEjderhaA(Art a, bool happy) {
  // Yan yüzgeçler
  for (final d in const [-1, 1]) {
    a.p(
      'M${340 + d * 90} 112 Q${340 + d * 140} 96 ${340 + d * 134} 150 '
      'Q${340 + d * 120} 134 ${340 + d * 112} 156 Q${340 + d * 104} 138 ${340 + d * 92} 150 Z',
      0x38B6E8,
    );
    a.s(
      'M${340 + d * 96} 126 L${340 + d * 128} 122 M${340 + d * 98} 138 L${340 + d * 120} 142',
      0x1B7AB0,
      2,
    );
  }
  // Boynuzlar
  for (final d in const [-1, 1]) {
    a.p(_maviHorn(d, 50, 104, 0.74), 0xE8DDC0);
    a.p(_maviHorn(d, 56, 100, 0.64), 0xB8A982, op: 0.45);
  }
  a.dome(0x2F66C8, 0x5E92E8, 0x1B3F8F);
  // Alın pulu ve pul deseni
  a.p('M328 78 L340 52 L352 78 Z', 0x1B3F8F);
  a.p('M332 78 L340 60 L348 78 Z', 0x38B6E8, op: 0.8);
  for (final y in const [90.0, 104.0]) {
    for (var x = 296.0; x <= 384; x += 22) {
      a.s('M$x $y q10 8 20 0', 0x1B3F8F, 2);
    }
  }
  // Kaşlar
  a.p('M276 108 Q300 94 322 114 L322 122 Q300 108 276 120 Z', 0x1B3F8F);
  a.p('M404 108 Q380 94 358 114 L358 122 Q380 108 404 120 Z', 0x1B3F8F);
  // Gözler
  for (final x in const [300, 380]) {
    a.o(x, 130, 14, 11, 0xFFD23F);
    a.o(x, 130, 14, 11, 0xE59A00, op: 0.5, strokeWidth: 2);
    a.o(x, 130, 3.6, 10, 0x1A1230);
    a.c(x - 5, 125, 2.4, w, op: 0.9);
  }
  // Burun kısmı
  a.o(340, 168, 62, 40, 0x4F88DA);
  a.o(340, 160, 44, 20, 0x7FB0F0, op: 0.45);
  a.o(318, 154, 6, 9, 0x13224F, rot: 15);
  a.o(362, 154, 6, 9, 0x13224F, rot: -15);
  a.cheeks(150, 0.3);
  if (happy) {
    a.p('M292 172 Q340 224 388 172 Q340 186 292 172 Z', 0x13224F);
    a.p('M302 174 l6 14 l6 -12 Z', w);
    a.p('M378 174 l-6 14 l-6 -12 Z', w);
    a.o(340, 200, 16, 8, 0x2E5CB8);
    // Mavi alev
    a.p(
      'M340 204 Q352 244 340 286 Q360 270 364 240 Q386 268 372 306 Q422 270 400 220 Q384 238 376 214 Q366 200 340 204 Z',
      0x38B6E8,
    );
    a.p(
      'M342 208 Q350 240 344 268 Q362 254 362 236 Q376 254 372 276 Q394 252 386 228 Q376 238 370 222 Q360 210 342 208 Z',
      0x9BE7FF,
    );
    a.p('M346 214 Q354 236 350 252 Q362 242 360 228 Q354 218 346 214 Z', w,
        op: 0.9);
  } else {
    a.s('M300 184 Q340 204 380 184', k, 3.5);
    a.p('M306 184 l4 9 l5 -8 Z', w);
    a.p('M374 184 l-4 9 l-5 -8 Z', w);
  }
}

void _maviEjderhaB(Art a, bool happy) {
  for (final d in const [-1, 1]) {
    a.p(_maviHorn(d, 34, 98, 0.62), 0xE8DDC0);
    a.p(
      'M${340 + d * 56} 124 Q${340 + d * 90} 112 ${340 + d * 84} 146 Q${340 + d * 72} 134 ${340 + d * 58} 148 Z',
      0x38B6E8,
    );
  }
  for (final x in const [322, 340, 358]) {
    a.p('M${x - 7} 92 L$x 74 L${x + 7} 92 Z', 0x1B3F8F);
  }
  a.box(0x2F66C8, 0x5E92E8, 0x1B3F8F);
  a.p('M300 108 Q314 100 330 112 L330 117 Q314 108 300 114 Z', 0x1B3F8F);
  a.p('M380 108 Q366 100 350 112 L350 117 Q366 108 380 114 Z', 0x1B3F8F);
  for (final x in const [316, 364]) {
    a.o(x, 126, 8, 6.5, 0xFFD23F);
    a.o(x, 126, 2.2, 6, 0x1A1230);
  }
  a.o(340, 146, 28, 17, 0x4F88DA);
  a.o(331, 142, 3, 4.5, 0x13224F);
  a.o(349, 142, 3, 4.5, 0x13224F);
  if (happy) {
    a.p('M320 152 Q340 172 360 152 Q340 158 320 152 Z', 0x13224F);
    a.p(
      'M340 160 Q348 180 340 200 Q356 190 354 176 Q366 184 362 206 Q382 184 368 160 Q356 170 352 162 Q348 156 340 160 Z',
      0x38B6E8,
    );
    a.p(
      'M342 162 Q348 178 344 190 Q354 184 352 174 Q362 182 358 196 Q372 180 362 168 Q354 172 350 164 Z',
      0x9BE7FF,
    );
  } else {
    a.s('M324 154 Q340 160 356 154', k, 2.5);
  }
}
