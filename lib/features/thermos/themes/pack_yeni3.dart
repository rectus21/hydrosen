// Yeni3 paketi temaları: Boğa, Su Samuru, Fok, Balina (tamamı kod çizimi).
//
// Kurallar için bkz. pack_doga.dart başlığı: id benzersiz ASCII, üst düzey
// (top-level) çizim fonksiyonları, tasarım alanı 120..560 x 8..512.

import 'dart:math' as math;
import 'dart:ui';

import '../art.dart';
import '../celebration_style.dart';
import '../thermos_theme.dart';

const _y3Full = 'M120 8 H560 V512 H120 Z';

const List<ThermosTheme> yeni3Themes = [
  ThermosTheme(
    id: 'boga',
    name: 'Boğa',
    glass: Color(0xFFFFEBCB),
    edge: Color(0xFF8A3A1E),
    water: Color(0xFF1F8FA6),
    deepWater: Color(0xFF0B5062),
    waterSurface: Color(0xFFBDEEF0),
    mark: Color(0xFF5A2411),
    label: Color(0xFF5A2411),
    band: Color(0xFFD9A030),
    bandLight: Color(0xFFF5D27A),
    background: _bogaBg,
    capChubby: _bogaA,
    capSlim: _bogaB,
    celebration: CelebrationStyle(CelebrationKind.embers, [
      0xF28C28,
      0xFFC145,
      0xE8553A,
    ]),
  ),
  ThermosTheme(
    id: 'susamuru',
    name: 'Su Samuru',
    glass: Color(0xFFE2F2E6),
    edge: Color(0xFF4F6B3A),
    water: Color(0xFF2F86C9),
    deepWater: Color(0xFF14497F),
    waterSurface: Color(0xFFC3E6F8),
    mark: Color(0xFF3A2A18),
    label: Color(0xFF3A2A18),
    band: Color(0xFF8A6A45),
    bandLight: Color(0xFFBF9A6C),
    background: _samuruBg,
    capChubby: _samuruA,
    capSlim: _samuruB,
    celebration: CelebrationStyle(CelebrationKind.bubbles, [
      0x8FD3F0,
      0xC9EEFA,
      0xFFFFFF,
    ]),
  ),
  ThermosTheme(
    id: 'fok',
    name: 'Fok',
    glass: Color(0xFFE4F3FB),
    edge: Color(0xFF3C6E8F),
    water: Color(0xFF2B7DBE),
    deepWater: Color(0xFF12457A),
    waterSurface: Color(0xFFCBE8F9),
    mark: Color(0xFF1B4466),
    label: Color(0xFF1B4466),
    band: Color(0xFF5C7E99),
    bandLight: Color(0xFF9DB8CC),
    background: _fokBg,
    capChubby: _fokA,
    capSlim: _fokB,
    celebration: CelebrationStyle(CelebrationKind.snow, [
      0xFFFFFF,
      0xD5ECFA,
      0xA9D4F0,
    ]),
  ),
  ThermosTheme(
    id: 'balina',
    name: 'Balina',
    glass: Color(0xFFE3F1FA),
    edge: Color(0xFF1E5A8A),
    water: Color(0xFF1FA3C4),
    deepWater: Color(0xFF0B5F7F),
    waterSurface: Color(0xFFB8F0F5),
    mark: Color(0xFF0B3B63),
    label: Color(0xFF0B3B63),
    band: Color(0xFFE9965A),
    bandLight: Color(0xFFF7C79A),
    background: _balinaBg,
    capChubby: _balinaA,
    capSlim: _balinaB,
    celebration: CelebrationStyle(CelebrationKind.bubbles, [
      0x9BD7F0,
      0xD8F2FB,
      0xFFFFFF,
    ]),
  ),
];

// --- ortak yardımcılar -----------------------------------------------------

/// Yalnız M/L/Q/H/V/Z (büyük harf) içeren yolu x ekseninde (680 - x) aynalar.
String _y3Mirror(String d) {
  final tokens = RegExp(r'[A-Za-z]|-?\d+(\.\d+)?');
  final b = StringBuffer();
  var cmd = '';
  var idx = 0;
  for (final m in tokens.allMatches(d)) {
    final t = m.group(0)!;
    if (RegExp(r'[A-Za-z]').hasMatch(t)) {
      cmd = t;
      idx = 0;
      b.write(' $t');
      continue;
    }
    final v = double.parse(t);
    final flip =
        cmd == 'H' || ((cmd == 'M' || cmd == 'L' || cmd == 'Q') && idx.isEven);
    idx++;
    b.write(' ${flip ? 680 - v : v}');
  }
  return b.toString().trim();
}

/// Sol tarafı çizilen yolu iki yana basar.
void _y3Both(Art a, String left, int hex, {double op = 1}) {
  a.p(left, hex, op: op);
  a.p(_y3Mirror(left), hex, op: op);
}

void _y3BothS(Art a, String left, int hex, double width) {
  a.s(left, hex, width);
  a.s(_y3Mirror(left), hex, width);
}

/// Bayrak ipi: P0-P1-P2 eğrisi boyunca üçgen bayraklar.
void _y3Bunting(
  Art a,
  Offset p0,
  Offset p1,
  Offset p2,
  List<int> cols,
  int n, {
  double size = 24,
}) {
  final q = 'M${p0.dx} ${p0.dy} Q${p1.dx} ${p1.dy} ${p2.dx} ${p2.dy}';
  a.s(q, 0x6B4A2A, 2.2);
  for (var i = 0; i < n; i++) {
    final t = (i + 0.7) / (n + 0.4);
    final u = 1 - t;
    final x = u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx;
    final y = u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy;
    final dx = 2 * u * (p1.dx - p0.dx) + 2 * t * (p2.dx - p1.dx);
    final dy = 2 * u * (p1.dy - p0.dy) + 2 * t * (p2.dy - p1.dy);
    a.canvas.save();
    a.canvas.translate(x, y);
    a.canvas.rotate(math.atan2(dy, dx));
    a.p(
      'M${-size * 0.5} 0 L${size * 0.5} 0 L0 ${size * 1.15} Z',
      cols[i % cols.length],
    );
    a.p('M${-size * 0.5} 0 L0 0 L0 ${size * 1.15} Z', w, op: 0.18);
    a.canvas.restore();
  }
}

/// Dalgacık çizgisi: [n] dalga, her biri iki yarım ([hw] genişlikte).
String _y3Ripple(num x, num y, num hw, int n, {num amp = 5}) {
  final b = StringBuffer('M$x $y');
  for (var i = 0; i < n * 2; i++) {
    final cx = x + hw * (i + 1) - hw / 2;
    b.write(' Q$cx ${i.isEven ? y - amp : y + amp} ${x + hw * (i + 1)} $y');
  }
  return b.toString();
}

// --- Boğa ------------------------------------------------------------------

void _bogaHay(Art a, num x, num y, num s) {
  a.o(x, y, 30 * s, 22 * s, 0xE2B84E);
  a.o(x, y - 4 * s, 24 * s, 14 * s, 0xF2D272, op: 0.85);
  for (var i = -2; i <= 2; i++) {
    a.s(
      'M${x + i * 9 * s} ${y - 12 * s} q${3 * s} ${12 * s} ${-2 * s} ${24 * s}',
      0xB88A2C,
      1.4,
    );
  }
  a.s('M${x - 22 * s} ${y + 2 * s} L${x + 22 * s} ${y + 2 * s}', 0xB05A2A, 2.5);
}

void _bogaPole(Art a, num x, num y) {
  a.p('M${x - 3} $y H${x + 3} V340 H${x - 3} Z', 0x8A5A33);
  a.p('M${x - 3} $y H${x - 1} V340 H${x - 3} Z', 0xB57F4F);
  a.c(x, y, 5, 0xD9A030);
}

void _bogaBg(Art a) {
  a.p(_y3Full, 0xFFE4B8);
  a.p('M120 8 H560 V150 H120 Z', 0xFFEFD0);
  // Güneş.
  a.c(484, 126, 62, 0xFFF6DC, op: 0.7);
  a.c(484, 126, 40, 0xFFD27A, op: 0.8);
  // Uzak tepeler. Orta vadi bilinçli olarak sakin: büyük termosun
  // silueti arka planla yarışmaz, katmanlar iki yandan sahneyi sarar.
  a.p(
    'M120 300 Q190 238 268 286 Q320 306 340 304 Q390 302 448 284 Q520 248 560 280 V380 H120 Z',
    0xE8B97C,
  );
  a.p(
    'M120 330 Q220 286 300 326 Q340 338 382 326 Q470 292 560 322 V400 H120 Z',
    0xD9A265,
  );
  // Arena duvarı: kırmızı-krem şeritli barrera.
  a.p('M120 340 H560 V420 H120 Z', 0xF3E2BC);
  a.p('M120 340 H560 V362 H120 Z', 0xC94A32);
  a.p('M120 396 H560 V420 H120 Z', 0xC94A32);
  for (var x = 150.0; x < 560; x += 60) {
    a.p('M${x - 4} 340 H${x + 4} V420 H${x - 4} Z', 0xA8987A, op: 0.6);
  }
  a.p('M120 340 H560 V344 H120 Z', w, op: 0.35);
  // Kum zemin.
  a.p('M120 420 H560 V512 H120 Z', 0xEFC987);
  a.p('M120 460 Q340 440 560 462 V512 H120 Z', 0xE6B96F);
  a.s('M140 440 Q190 432 240 440 M450 452 Q500 444 540 452', 0xD3A45D, 2);
  a.s('M250 488 Q300 480 350 488', 0xD3A45D, 2);
  // Samanlar ve çiçekler.
  _bogaHay(a, 156, 410, 1.1);
  _bogaHay(a, 528, 414, 1.0);
  _bogaHay(a, 140, 450, 0.8);
  for (final f in const [
    [200, 486, 0xE8553A],
    [496, 490, 0xF6C343],
    [168, 496, 0xFFF1D6],
    [530, 480, 0xE8553A],
  ]) {
    a.s('M${f[0]} ${f[1] + 8} v-8', 0x5E8F3A, 2);
    for (var i = 0; i < 5; i++) {
      final an = i * 72 * math.pi / 180;
      a.c(f[0] + math.cos(an) * 4, f[1] + math.sin(an) * 4, 3, f[2]);
    }
    a.c(f[0], f[1], 2.2, 0xFFD25A);
  }
  // Flama ipleri.
  const cols = [0xE8553A, 0xF6C343, 0x2A9D8F, 0xFFF1D6, 0xD6406A];
  _bogaPole(a, 128, 22);
  _bogaPole(a, 552, 22);
  _y3Bunting(
    a,
    const Offset(128, 30),
    const Offset(340, 108),
    const Offset(552, 30),
    cols,
    11,
  );
  // Kenarlardaki toz halkaları arenaya hareket verir; orta alan boş kalır.
  a.s('M132 436 Q166 424 196 438', 0xFFF0C7, 3);
  a.s('M484 444 Q518 430 548 442', 0xFFF0C7, 3);
}

void _bogaHorns(Art a, {required bool slim}) {
  const cream = 0xF5E6C4;
  const tip = 0x8C6A3E;
  if (!slim) {
    const hl = 'M286 112 Q210 112 196 54 Q194 34 206 18 Q232 66 292 74 Z';
    _y3BothS(a, hl, 0x9C7440, 6);
    _y3Both(a, hl, cream);
    _y3Both(a, 'M286 112 Q232 110 212 78 Q250 92 292 90 Z', 0xD9B070, op: 0.6);
    _y3Both(a, 'M206 18 Q198 32 198 48 Q214 38 218 30 Z', tip);
  } else {
    const hs = 'M292 112 Q258 112 250 84 Q248 70 254 60 Q268 88 298 94 Z';
    _y3BothS(a, hs, 0x9C7440, 4.5);
    _y3Both(a, hs, cream);
    _y3Both(a, 'M254 60 Q250 70 250 80 Q260 72 262 68 Z', tip);
  }
}

void _bogaA(Art a, bool happy) {
  _bogaHorns(a, slim: false);
  // Kulaklar.
  a.o(250, 124, 24, 12, 0xB23A28, rot: -22);
  a.o(430, 124, 24, 12, 0xB23A28, rot: 22);
  a.o(252, 124, 14, 6, 0xF2A58F, rot: -22);
  a.o(428, 124, 14, 6, 0xF2A58F, rot: 22);
  a.dome(0xC8442F, 0xE8745A, 0x8F2A1E);
  // Alında krem yıldız ve kıvırcık tüy.
  a.p(
    'M340 62 Q360 88 352 116 Q340 128 328 116 Q320 88 340 62 Z',
    0xFFF1D6,
    op: 0.92,
  );
  a.s('M318 70 Q326 58 338 66 Q350 56 362 70', 0x8F2A1E, 3);
  // Gözler ve kaşlar (kararlı ama sevimli).
  if (happy) {
    a.s('M286 126 Q298 108 310 126', k, 4.5);
    a.s('M370 126 Q382 108 394 126', k, 4.5);
    a.s('M282 100 L312 94', 0x5A1E12, 5);
    a.s('M398 100 L368 94', 0x5A1E12, 5);
  } else {
    a.eye(298, 124, 11);
    a.eye(382, 124, 11);
    a.s('M280 102 L316 112', 0x5A1E12, 6);
    a.s('M400 102 L364 112', 0x5A1E12, 6);
  }
  a.cheeks(150, happy ? 0.85 : 0.5);
  // Pembe-krem burun bölgesi.
  a.o(340, 166, 60, 38, 0xF4C7A8);
  a.o(340, 156, 44, 22, 0xFAD8C0, op: 0.7);
  a.o(322, 160, 6, 8, 0x7A2E1E, rot: 15);
  a.o(358, 160, 6, 8, 0x7A2E1E, rot: -15);
  // Altın burun halkası.
  a.o(340, 180, 11, 13, 0xD9A030, strokeWidth: 4.5);
  a.s('M331 176 Q334 168 340 167', 0xFFE9A0, 2);
  if (happy) {
    a.p('M318 192 Q340 216 362 192 Q340 199 318 192 Z', 0x6B1F2E);
    a.o(340, 205, 9, 4.5, 0xF2677A);
    a.s('M318 192 Q340 216 362 192', k, 2.6);
  } else {
    a.s('M322 194 Q340 206 358 194', k, 3.2);
  }
}

void _bogaB(Art a, bool happy) {
  _bogaHorns(a, slim: true);
  a.o(276, 126, 14, 8, 0xB23A28, rot: -22);
  a.o(404, 126, 14, 8, 0xB23A28, rot: 22);
  a.box(0xC8442F, 0xE8745A, 0x8F2A1E);
  a.p(
    'M340 94 Q354 110 348 128 Q340 136 332 128 Q326 110 340 94 Z',
    0xFFF1D6,
    op: 0.92,
  );
  if (happy) {
    a.s('M298 122 Q310 106 322 122', k, 3.8);
    a.s('M358 122 Q370 106 382 122', k, 3.8);
    a.s('M296 102 L322 98', 0x5A1E12, 4);
    a.s('M384 102 L358 98', 0x5A1E12, 4);
  } else {
    a.eye(312, 118, 8);
    a.eye(368, 118, 8);
    a.s('M294 104 L324 112', 0x5A1E12, 4.5);
    a.s('M386 104 L356 112', 0x5A1E12, 4.5);
  }
  a.o(340, 146, 38, 20, 0xF4C7A8);
  a.o(329, 143, 4, 5, 0x7A2E1E, rot: 15);
  a.o(351, 143, 4, 5, 0x7A2E1E, rot: -15);
  a.o(340, 157, 8, 9, 0xD9A030, strokeWidth: 3.4);
  if (happy) {
    a.s('M326 152 Q340 162 354 152', k, 2.4);
  }
}

// --- Su Samuru -------------------------------------------------------------

void _samuruRock(Art a, num x, num y, num rx, num ry, {int base = 0x8B8F8C}) {
  a.o(x, y, rx, ry, base);
  a.o(x - rx * 0.25, y - ry * 0.35, rx * 0.6, ry * 0.4, w, op: 0.22);
  a.o(x + rx * 0.3, y + ry * 0.4, rx * 0.7, ry * 0.4, k, op: 0.12);
}

void _samuruReed(Art a, num x, num y, num h, {bool cattail = true}) {
  a.s('M$x $y Q${x + 6} ${y - h * 0.5} ${x + 2} ${y - h}', 0x4C8A3E, 3.2);
  if (cattail) {
    a.o(x + 2, y - h - 4, 4.5, 14, 0x6B3F1E, rot: 4);
    a.s('M${x + 2} ${y - h - 20} v-8', 0x4C8A3E, 1.6);
  }
}

void _samuruBg(Art a) {
  a.p(_y3Full, 0xD9F0F5);
  a.p('M120 8 H560 V190 H120 Z', 0xE6F6F8);
  // Güneş ve bulutlar.
  a.c(190, 96, 34, 0xFFF3C4, op: 0.8);
  a.o(480, 72, 34, 12, w, op: 0.85);
  a.o(506, 80, 24, 10, w, op: 0.85);
  a.o(250, 140, 26, 9, w, op: 0.7);
  // Uzak tepeler ve ağaçlar.
  a.p('M120 250 Q220 190 330 240 Q430 196 560 246 V330 H120 Z', 0xA9D3A0);
  a.p('M120 280 Q250 236 360 276 Q460 244 560 276 V340 H120 Z', 0x86BF86);
  for (final t in const [
    [150, 262, 1.0],
    [190, 270, 0.8],
    [500, 262, 1.0],
    [536, 268, 0.8],
  ]) {
    a.p(
      'M${t[0]} ${t[1] - 46 * t[2]} L${t[0] - 18 * t[2]} ${t[1]} L${t[0] + 18 * t[2]} ${t[1]} Z',
      0x4F8F5A,
    );
  }
  // Nehir.
  a.p('M120 330 Q300 316 560 332 V512 H120 Z', 0x9BD3E6);
  a.p('M120 400 Q300 386 560 402 V512 H120 Z', 0x82C4DC, op: 0.7);
  for (final r in const [
    [150, 352, 40],
    [440, 362, 50],
    [220, 420, 44],
    [520, 440, 38],
    [170, 470, 50],
  ]) {
    a.s(_y3Ripple(r[0], r[1], r[2] / 4, 2), w, 2.2);
  }
  // Atlayan balık sol kenarda kalır; merkez büyük termosa ayrılır.
  a.s('M132 318 Q152 270 182 316', w, 2.5);
  a.o(153, 282, 15, 7, 0xF29B4B, rot: -35);
  a.p('M140 290 L130 282 L134 296 Z', 0xF29B4B);
  a.c(161, 278, 1.6, k);
  // Nilüfer yaprakları.
  for (final l in const [
    [470, 480],
    [500, 496],
    [200, 496],
  ]) {
    a.o(l[0], l[1], 20, 7, 0x55A55A);
    a.p(
      'M${l[0]} ${l[1]} L${l[0] + 20} ${l[1] - 3} L${l[0] + 20} ${l[1] + 3} Z',
      0x9BD3E6,
    );
  }
  a.c(470, 474, 4, 0xFFC1D6);
  // Kıyı, taşlar ve kamışlar.
  a.p('M120 470 Q150 440 190 462 Q200 480 200 512 H120 Z', 0x7FB074);
  a.p('M480 480 Q520 446 560 462 V512 H490 Z', 0x7FB074);
  _samuruRock(a, 150, 486, 36, 22);
  _samuruRock(a, 188, 500, 26, 14, base: 0x9AA09B);
  _samuruRock(a, 520, 496, 40, 22);
  _samuruRock(a, 484, 506, 22, 12, base: 0x9AA09B);
  _samuruRock(a, 450, 340, 22, 10, base: 0x9AA09B);
  _samuruReed(a, 134, 470, 120);
  _samuruReed(a, 150, 476, 150);
  _samuruReed(a, 168, 472, 100, cattail: false);
  _samuruReed(a, 536, 470, 130);
  _samuruReed(a, 552, 474, 100, cattail: false);
  _samuruReed(a, 520, 478, 150);
}

void _samuruFish(Art a, num x, num y, double s) {
  a.o(x, y, 16 * s, 8 * s, 0xF29B4B);
  a.o(x - 2 * s, y + 3 * s, 12 * s, 4 * s, 0xFFD6A6, op: 0.7);
  a.p(
    'M${x + 12 * s} $y L${x + 24 * s} ${y - 8 * s} L${x + 24 * s} ${y + 8 * s} Z',
    0xE07A2E,
  );
  a.c(x - 8 * s, y - 1.5 * s, 1.8 * s, k);
  a.s(
    'M${x - 3 * s} ${y - 5 * s} q${3 * s} ${5 * s} 0 ${10 * s}',
    0xC8682A,
    1.2,
  );
}

void _samuruA(Art a, bool happy) {
  const brown = 0x9A6B43;
  const dark = 0x6E4A2C;
  // Küçük yuvarlak kulaklar.
  a.c(278, 74, 17, dark);
  a.c(402, 74, 17, dark);
  a.c(278, 76, 9, 0xD9B48A);
  a.c(402, 76, 9, 0xD9B48A);
  a.dome(brown, 0xBE8B5E, dark);
  a.p('M300 72 Q340 54 380 72 Q340 92 300 72 Z', 0xB57F52, op: 0.55);
  // Krem yüz bölgesi.
  a.o(340, 170, 66, 40, 0xF2E0C2);
  a.o(340, 162, 52, 24, 0xFFF1DC, op: 0.7);
  // Gözler.
  if (happy) {
    a.s('M286 118 Q298 102 310 118', k, 4.5);
    a.s('M370 118 Q382 102 394 118', k, 4.5);
  } else {
    a.eye(298, 116, 11);
    a.eye(382, 116, 11);
  }
  a.cheeks(146, happy ? 0.8 : 0.45);
  // Burun ve bıyık noktaları.
  a.o(340, 148, 13, 9, 0x3A2A1E);
  a.o(336, 145, 4, 2.4, w, op: 0.55);
  a.s('M340 157 v8', 0x3A2A1E, 2.6);
  for (final p in const [
    [316, 166],
    [322, 174],
    [364, 166],
    [358, 174],
  ]) {
    a.c(p[0], p[1], 1.6, 0x8A6A4A);
  }
  // Bıyıklar.
  _y3BothS(a, 'M300 164 Q270 156 244 160', 0x7A5636, 2.2);
  _y3BothS(a, 'M300 172 Q270 174 246 184', 0x7A5636, 2.2);
  if (happy) {
    a.p('M320 168 Q340 198 360 168 Q340 176 320 168 Z', 0x6B1F2E);
    a.o(340, 184, 9, 5, 0xF2677A);
    a.p('M333 169 l3 7 l4 -7 Z M340 169 l4 7 l3 -7 Z', w);
    // Pençeleriyle tuttuğu balık.
    _samuruFish(a, 336, 200, 1.35);
    a.o(300, 202, 15, 11, dark);
    a.o(374, 202, 15, 11, dark);
  } else {
    a.s('M326 166 Q340 176 354 166', 0x3A2A1E, 3);
  }
}

void _samuruB(Art a, bool happy) {
  const brown = 0x9A6B43;
  const dark = 0x6E4A2C;
  a.c(296, 94, 12, dark);
  a.c(384, 94, 12, dark);
  a.c(296, 96, 6, 0xD9B48A);
  a.c(384, 96, 6, 0xD9B48A);
  a.box(brown, 0xBE8B5E, dark);
  a.o(340, 148, 40, 20, 0xF2E0C2);
  if (happy) {
    a.s('M300 116 Q312 102 324 116', k, 3.8);
    a.s('M356 116 Q368 102 380 116', k, 3.8);
  } else {
    a.eye(312, 114, 8);
    a.eye(368, 114, 8);
  }
  a.o(340, 136, 9, 6.5, 0x3A2A1E);
  a.o(337, 134, 2.8, 1.6, w, op: 0.55);
  _y3BothS(a, 'M312 148 Q292 142 274 146', 0x7A5636, 1.8);
  _y3BothS(a, 'M312 154 Q292 156 276 164', 0x7A5636, 1.8);
  if (happy) {
    a.s('M328 150 Q340 160 352 150', 0x3A2A1E, 2.6);
    _samuruFish(a, 336, 172, 1.0);
    a.o(312, 174, 9, 7, dark);
    a.o(364, 174, 9, 7, dark);
  } else {
    a.s('M340 143 v5 M330 150 Q340 156 350 150', 0x3A2A1E, 2.3);
  }
}

// --- Fok -------------------------------------------------------------------

void _fokFloe(Art a, num x, num y, num s) {
  a.p(
    'M${x - 60 * s} $y L${x - 40 * s} ${y - 14 * s} L${x + 44 * s} ${y - 14 * s} L${x + 62 * s} $y Z',
    0xFFFFFF,
  );
  a.p(
    'M${x - 60 * s} $y L${x + 62 * s} $y L${x + 48 * s} ${y + 16 * s} L${x - 44 * s} ${y + 16 * s} Z',
    0xBFE0F2,
  );
  a.p(
    'M${x - 60 * s} $y L${x - 44 * s} ${y + 16 * s} L${x - 20 * s} ${y + 16 * s} L${x - 30 * s} $y Z',
    0x9CCBE6,
    op: 0.7,
  );
  a.s('M${x - 30 * s} ${y - 8 * s} H${x - 6 * s}', 0xD9EEF9, 2);
}

void _fokBg(Art a) {
  a.p(_y3Full, 0xDDF0FA);
  a.p('M120 8 H560 V160 H120 Z', 0xEEF8FD);
  // Soluk güneş ve aurora çizgileri.
  a.c(204, 112, 54, 0xFFF4D8, op: 0.75);
  a.c(204, 112, 32, 0xFFE9B4, op: 0.9);
  a.s('M300 70 Q380 40 470 76', 0xBFE8DD, 9);
  a.s('M320 96 Q400 70 500 104', 0xD3E4FA, 7);
  // Buz dağları iki yanda yükselir; merkezde geniş, açık bir boğaz kalır.
  a.p('M120 300 L184 212 L220 252 L264 196 L302 300 Z', 0xF4FAFE);
  a.p('M264 196 L302 300 L270 300 L260 242 Z', 0xC9E3F3, op: 0.85);
  a.p('M398 300 L434 230 L470 262 L520 214 L560 258 V300 Z', 0xEAF5FB);
  a.p('M520 214 L560 258 V300 H520 L506 250 Z', 0xC9E3F3, op: 0.85);
  a.p('M190 210 L226 250 L216 300 L170 300 Z', 0xC9E3F3, op: 0.7);
  // Deniz.
  a.p('M120 298 H560 V512 H120 Z', 0x9CD0EC);
  a.p('M120 380 H560 V512 H120 Z', 0x82BFE2, op: 0.7);
  a.p('M120 450 H560 V512 H120 Z', 0x6BAFD8, op: 0.6);
  for (final r in const [
    [140, 326],
    [420, 336],
    [230, 372],
    [500, 396],
    [160, 424],
    [440, 462],
  ]) {
    a.s(_y3Ripple(r[0], r[1], 10, 3), w, 2.2);
  }
  // Buz kütleleri.
  _fokFloe(a, 168, 340, 0.8);
  _fokFloe(a, 508, 352, 0.9);
  _fokFloe(a, 150, 420, 1.0);
  _fokFloe(a, 520, 440, 0.7);
  // Kar kıyısı.
  a.p('M120 470 Q190 448 250 480 Q300 500 340 512 H120 Z', w);
  a.p('M560 484 Q500 468 450 490 Q420 504 400 512 H560 Z', w);
  a.p('M120 490 Q190 478 240 500 L260 512 H120 Z', 0xDCEEF8, op: 0.8);
  a.p('M560 500 Q500 490 456 506 L440 512 H560 Z', 0xDCEEF8, op: 0.8);
  // Kar taneleri.
  for (final s in const [
    [150, 60, 3],
    [240, 150, 2.4],
    [520, 150, 3],
    [330, 40, 2.2],
    [440, 120, 2.6],
    [180, 220, 2.4],
  ]) {
    a.c(s[0], s[1], s[2], w, op: 0.9);
  }
}

void _fokFace(Art a, {required bool slim, required bool happy}) {
  const spot = 0xB7C3CE;
  if (!slim) {
    a.o(284, 96, 12, 8, spot, rot: -25);
    a.o(396, 100, 10, 7, spot, rot: 25);
    a.o(340, 70, 14, 7, spot);
    // Açık yüz alanı.
    a.o(340, 160, 66, 44, w, op: 0.9);
    if (happy) {
      a.s('M284 122 Q298 104 312 122', k, 4.5);
      a.s('M368 122 Q382 104 396 122', k, 4.5);
    } else {
      a.o(298, 122, 13, 15, 0x1F2933);
      a.o(382, 122, 13, 15, 0x1F2933);
      a.c(293, 116, 5, w);
      a.c(377, 116, 5, w);
      a.c(303, 128, 2.4, w);
      a.c(387, 128, 2.4, w);
    }
    a.cheeks(152, happy ? 0.8 : 0.45);
    a.o(340, 146, 11, 8, 0x2A3540);
    a.o(337, 143, 3.4, 2, w, op: 0.6);
    a.s('M340 154 v8', 0x2A3540, 2.4);
    for (final p in const [
      [320, 160],
      [326, 168],
      [360, 160],
      [354, 168],
    ]) {
      a.c(p[0], p[1], 1.5, 0x8896A3);
    }
    _y3BothS(a, 'M306 160 Q272 148 244 150', 0x7B8998, 2);
    _y3BothS(a, 'M306 168 Q274 170 248 182', 0x7B8998, 2);
    _y3BothS(a, 'M308 154 Q280 138 258 132', 0x7B8998, 2);
    if (happy) {
      a.p('M322 166 Q340 192 358 166 Q340 172 322 166 Z', 0x6B1F2E);
      a.o(340, 180, 8, 4.5, 0xF2677A);
    } else {
      a.s('M326 164 Q333 172 340 164 Q347 172 354 164', 0x2A3540, 2.6);
    }
  } else {
    a.o(300, 104, 8, 5, spot, rot: -20);
    a.o(380, 106, 8, 5, spot, rot: 20);
    a.o(340, 96, 10, 5, spot);
    a.o(340, 142, 44, 24, w, op: 0.9);
    if (happy) {
      a.s('M298 118 Q310 104 322 118', k, 3.8);
      a.s('M358 118 Q370 104 382 118', k, 3.8);
    } else {
      a.o(310, 118, 9, 11, 0x1F2933);
      a.o(370, 118, 9, 11, 0x1F2933);
      a.c(306, 113, 3.4, w);
      a.c(366, 113, 3.4, w);
      a.c(313, 122, 1.6, w);
      a.c(373, 122, 1.6, w);
    }
    a.o(340, 134, 8, 6, 0x2A3540);
    a.o(338, 132, 2.4, 1.5, w, op: 0.6);
    _y3BothS(a, 'M316 144 Q292 138 270 142', 0x7B8998, 1.8);
    _y3BothS(a, 'M316 150 Q294 154 274 162', 0x7B8998, 1.8);
    if (happy) {
      a.s('M328 146 Q340 156 352 146', 0x2A3540, 2.6);
    } else {
      a.s(
        'M340 140 v4 M332 148 Q336 153 340 148 Q344 153 348 148',
        0x2A3540,
        2.2,
      );
    }
  }
}

void _fokA(Art a, bool happy) {
  a.o(250, 196, 22, 10, 0xA7B5C2, rot: -30);
  a.o(430, 196, 22, 10, 0xA7B5C2, rot: 30);
  a.dome(0xDDE5EC, w, 0xA3B1BF);
  _fokFace(a, slim: false, happy: happy);
}

void _fokB(Art a, bool happy) {
  a.o(280, 160, 12, 6, 0xA7B5C2, rot: -30);
  a.o(400, 160, 12, 6, 0xA7B5C2, rot: 30);
  a.box(0xDDE5EC, w, 0xA3B1BF);
  _fokFace(a, slim: true, happy: happy);
}

// --- Balina ----------------------------------------------------------------

void _balinaGull(Art a, num x, num y, double s) {
  a.s(
    'M$x $y q${8 * s} ${-9 * s} ${16 * s} 0 q${8 * s} ${-9 * s} ${16 * s} 0',
    w,
    3.2 * s,
  );
}

void _balinaBg(Art a) {
  // Masalsı açık deniz: ufukta sıcak gün ışığı, altta serin
  // turkuaz katmanlar. Orta kolon bilerek sade tutulur; büyük termos
  // sahnenin kahramanı olarak okunur.
  a.p(_y3Full, 0xA8DDF3);
  a.p('M120 8 H560 V164 H120 Z', 0x8CCCEB);
  a.p('M120 164 H560 V292 H120 Z', 0xC8EBF8);
  // Güneş ve bulutlar kenarlarda.
  a.c(494, 112, 54, 0xFFF4CB, op: 0.65);
  a.c(494, 112, 30, 0xFFE59A);
  for (final c in const [
    [180, 86, 0.9],
    [450, 196, 0.7],
    [146, 208, 0.55],
  ]) {
    a.o(c[0], c[1], 40 * c[2], 13 * c[2], w, op: 0.9);
    a.o(c[0] + 22 * c[2], c[1] - 8 * c[2], 28 * c[2], 13 * c[2], w, op: 0.9);
    a.o(c[0] - 20 * c[2], c[1] - 5 * c[2], 22 * c[2], 11 * c[2], w, op: 0.9);
  }
  // Martılar.
  _balinaGull(a, 142, 154, 0.8);
  _balinaGull(a, 202, 128, 0.55);
  _balinaGull(a, 506, 218, 0.7);
  // Uzak yelkenli sağ kenarda; termosun içinden geçmez.
  a.p('M506 278 L506 244 L530 278 Z', w);
  a.p('M502 278 L502 252 L486 278 Z', 0xF2F6F8);
  a.p('M486 280 H536 L527 288 H494 Z', 0xB86A3E);
  // Sol ufukta minik deniz feneri silueti sahneye özgün bir imza verir.
  a.p('M146 286 L152 234 H170 L176 286 Z', 0xF6E6D2);
  a.p('M149 250 H173 L171 264 H150 Z', 0xE56B5D);
  a.p('M148 234 L161 220 L174 234 Z', 0x2E6383);
  a.p('M154 270 H168 V286 H154 Z', 0x3E7898);
  // Deniz.
  a.p('M120 290 H560 V512 H120 Z', 0x70BFE3);
  a.p('M120 290 H560 V300 H120 Z', 0xBCE5F6);
  a.p('M120 370 H560 V512 H120 Z', 0x5BAAD8, op: 0.6);
  a.p('M120 450 H560 V512 H120 Z', 0x4A98CC, op: 0.55);
  for (var row = 0; row < 6; row++) {
    final y = 316.0 + row * 34;
    for (var i = 0; i < 4; i++) {
      final x = 124.0 + i * 124 + (row.isOdd ? 62 : 0);
      // Termosun merkezinde daha soluk, kenarlarda daha belirgin dalga.
      final ripple = x > 270 && x < 420 ? 0x91CBE6 : 0xB5DDF2;
      a.s(_y3Ripple(x, y, 10, 3, amp: 7), ripple, 2.2);
    }
  }
  // Kayalıklar.
  a.p('M120 440 Q150 410 190 430 Q220 440 230 470 L240 512 H120 Z', 0x7C8C94);
  a.p('M120 440 Q150 410 190 430 Q160 440 140 470 L120 480 Z', 0x9BAAB1);
  a.p('M520 470 Q540 450 560 452 V512 H500 Z', 0x7C8C94);
  a.s(_y3Ripple(120, 476, 14, 4, amp: 8), 0xD6EEF9, 2.4);
  a.s(_y3Ripple(440, 492, 14, 3, amp: 8), 0xD6EEF9, 2.4);
  for (final b in const [
    [160, 388, 4],
    [172, 372, 3],
    [510, 408, 4],
    [524, 392, 3],
    [150, 496, 3],
  ]) {
    a.o(b[0], b[1], b[2], b[2], w, op: 0.85, strokeWidth: 1.5);
  }
}

void _balinaSpout(Art a, num x, num y, num h) {
  for (final tipX in const [-30.0, 30.0]) {
    final d = 'M$x $y Q$x ${y - h} ${x + tipX} ${y - h * 0.9}';
    a.s(d, 0xBFE9FA, 7);
    a.s(d, w, 3);
    a.c(x + tipX * 1.25, y - h * 0.9 + 12, 3, w);
    a.c(x + tipX * 1.5, y - h * 0.9 + 26, 2.2, 0xBFE9FA);
  }
  final d = 'M$x $y V${y - h * 1.05}';
  a.s(d, 0xBFE9FA, 7);
  a.s(d, w, 3);
  a.c(x, y - h * 1.2, 4, w);
}

void _balinaA(Art a, bool happy) {
  const blue = 0x4D86B8;
  const dark = 0x2F5F8C;
  _balinaSpout(a, 340, 58, 44);
  a.o(250, 192, 26, 11, dark, rot: -35);
  a.o(430, 192, 26, 11, dark, rot: 35);
  a.dome(blue, 0x7FB0DA, dark);
  // Açık renkli karın çizgisi (alt çene).
  a.canvas.save();
  a.canvas.clipPath(
    Path()..addOval(
      Rect.fromCenter(center: const Offset(340, 130), width: 192, height: 160),
    ),
  );
  a.p('M244 156 Q340 190 436 156 V220 H244 Z', 0xE4F1F8);
  for (final y in const [176, 188, 200]) {
    a.s('M262 $y Q340 ${y + 22} 418 $y', 0xB5D2E4, 2.4);
  }
  a.canvas.restore();
  a.o(340, 56, 11, 5, dark);
  if (happy) {
    a.s('M278 118 Q292 100 306 118', k, 4.5);
    a.s('M374 118 Q388 100 402 118', k, 4.5);
    a.p('M268 152 Q340 218 412 152 Q340 172 268 152 Z', 0x5A2036);
    a.o(340, 192, 22, 9, 0xF2677A);
    a.s('M268 152 Q340 218 412 152', k, 3);
  } else {
    a.eye(292, 122, 10);
    a.eye(388, 122, 10);
    a.s('M268 152 Q340 196 412 152', k, 3.6);
    a.s('M268 152 l-5 -5 M412 152 l5 -5', k, 3);
  }
  a.cheeks(148, happy ? 0.8 : 0.5);
}

void _balinaB(Art a, bool happy) {
  const blue = 0x4D86B8;
  const dark = 0x2F5F8C;
  _balinaSpout(a, 340, 92, 28);
  a.p('M284 140 L260 166 L290 160 Z', dark);
  a.p('M396 140 L420 166 L390 160 Z', dark);
  a.box(blue, 0x7FB0DA, dark);
  a.p('M284 142 Q340 164 396 142 L396 164 L284 164 Z', 0xE4F1F8);
  a.s('M294 154 Q340 172 386 154', 0xB5D2E4, 2);
  a.o(340, 90, 8, 3.5, dark);
  if (happy) {
    a.s('M298 116 Q310 102 322 116', k, 3.6);
    a.s('M358 116 Q370 102 382 116', k, 3.6);
    a.p('M296 138 Q340 172 384 138 Q340 150 296 138 Z', 0x5A2036);
    a.o(340, 156, 12, 5, 0xF2677A);
  } else {
    a.eye(310, 118, 7);
    a.eye(370, 118, 7);
    a.s('M298 138 Q340 160 382 138', k, 3);
  }
  a.o(292, 132, 7, 4, 0xED93B1, op: happy ? 0.7 : 0.45);
  a.o(388, 132, 7, 4, 0xED93B1, op: happy ? 0.7 : 0.45);
}
