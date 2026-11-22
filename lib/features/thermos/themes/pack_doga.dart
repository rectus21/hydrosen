// Doğa paketi temaları: Okyanus, Ahtapot, Kaktüs, Kardan Adam, Sonbahar.
//
// YENİ TEMA EKLEME (yalnız bu dosyayı düzenle; başka dosyaya dokunma):
//  1. Aşağıdaki [dogaThemes] listesine bir `ThermosTheme(...)` ekle.
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

import 'dart:math' as math;
import 'dart:ui';

import '../art.dart';
import '../celebration_style.dart';
import '../thermos_theme.dart';

const _dogaFull = 'M120 8 H560 V512 H120 Z';

/// Dalgalı üst kenarlı alan: [y] çizgisi, [amp] genlik, [step] yarım dalga.
String _dogaWave(num y, num amp, {num step = 80}) {
  final b = StringBuffer('M120 $y');
  var up = true;
  for (num x = 120; x < 560; x += step) {
    b.write(' Q${x + step / 2} ${up ? y - amp : y + amp} ${x + step} $y');
    up = !up;
  }
  b.write(' V512 H120 Z');
  return b.toString();
}

const List<ThermosTheme> dogaThemes = [
  ThermosTheme(
    id: 'okyanus',
    name: 'Okyanus',
    glass: Color(0xFFE3F6FA),
    edge: Color(0xFF0E6E8C),
    water: Color(0xFF1F7FC4),
    deepWater: Color(0xFF0A4A7A),
    waterSurface: Color(0xFFBFE6F7),
    mark: Color(0xFF07406A),
    label: Color(0xFF07406A),
    band: Color(0xFFE8765A),
    bandLight: Color(0xFFF7A58F),
    background: _okyanusBg,
    capChubby: _okyanusA,
    capSlim: _okyanusB,
    celebration: CelebrationStyle(CelebrationKind.bubbles, [
      0x7EC8E3,
      0xB5E8F5,
      0xFFFFFF,
    ]),
  ),
  ThermosTheme(
    id: 'ahtapot',
    name: 'Ahtapot',
    glass: Color(0xFFFCE4EC),
    edge: Color(0xFFB03A6B),
    water: Color(0xFF7E57C9),
    deepWater: Color(0xFF42257F),
    waterSurface: Color(0xFFE3D4FA),
    mark: Color(0xFF5B1F4A),
    label: Color(0xFF5B1F4A),
    band: Color(0xFFE85D8C),
    bandLight: Color(0xFFF59BB9),
    background: _ahtapotBg,
    capChubby: _ahtapotA,
    capSlim: _ahtapotB,
    celebration: CelebrationStyle(CelebrationKind.bubbles, [
      0xF58FB2,
      0xC9A7F5,
      0xFFFFFF,
    ]),
  ),
  ThermosTheme(
    id: 'kaktus',
    name: 'Kaktüs',
    glass: Color(0xFFF6EDCB),
    edge: Color(0xFF4E7F2A),
    water: Color(0xFF1F9E8E),
    deepWater: Color(0xFF0B5A52),
    waterSurface: Color(0xFFB8EDE4),
    mark: Color(0xFF3F5E1E),
    label: Color(0xFF5A3A15),
    band: Color(0xFFC76B3B),
    bandLight: Color(0xFFE39A6A),
    background: _kaktusBg,
    capChubby: _kaktusA,
    capSlim: _kaktusB,
    celebration: CelebrationStyle(CelebrationKind.fallingFlowers, [
      0xF28BB0,
      0xFFD166,
      0xFFFFFF,
    ]),
  ),
  ThermosTheme(
    id: 'kardanadam',
    name: 'Kardan Adam',
    glass: Color(0xFFDCEBFA),
    edge: Color(0xFF6F9AD0),
    water: Color(0xFF3F8FE0),
    deepWater: Color(0xFF1B4F9C),
    waterSurface: Color(0xFFD5E9FD),
    mark: Color(0xFF0F2F66),
    label: Color(0xFFF0F6FF),
    band: Color(0xFFC0392B),
    bandLight: Color(0xFFE5594A),
    background: _kardanBg,
    capChubby: _kardanA,
    capSlim: _kardanB,
    celebration: CelebrationStyle(CelebrationKind.snow, [0xFFFFFF, 0xD5E9FD]),
  ),
  ThermosTheme(
    id: 'ayi',
    name: 'Ayı',
    glass: Color(0xFFFFF4DA),
    edge: Color(0xFF7A4A1C),
    water: Color(0xFFE39A14),
    deepWater: Color(0xFF9A5208),
    waterSurface: Color(0xFFFFDE8C),
    mark: Color(0xFF4E2D10),
    label: Color(0xFF4E2D10),
    band: Color(0xFF8B5A2B),
    bandLight: Color(0xFFC08A55),
    background: _ayiBg,
    capChubby: _ayiA,
    capSlim: _ayiB,
    celebration: CelebrationStyle(CelebrationKind.confetti, [
      0xF2B632,
      0xE39A14,
      0xFFDE8C,
      0x8B5A2B,
    ]),
  ),
];

// --- Okyanus ---------------------------------------------------------------

void _okFish(Art a, num x, num y, num s, int col, int dir) {
  // Kuyruk.
  a.p(
    'M${x - 12 * s * dir} $y L${x - 28 * s * dir} ${y - 11 * s} '
    'Q${x - 23 * s * dir} $y ${x - 28 * s * dir} ${y + 11 * s} Z',
    col,
  );
  a.o(x, y, 17 * s, 10 * s, col);
  a.o(x, y + 4 * s, 13 * s, 5 * s, w, op: 0.3);
  a.s(
    'M${x - 2 * s * dir} ${y - 8 * s} Q${x - 6 * s * dir} $y ${x - 2 * s * dir} ${y + 8 * s}',
    w,
    1.6 * s,
  );
  a.p(
    'M${x - 2 * s * dir} ${y - 9 * s} L${x - 8 * s * dir} ${y - 16 * s} L${x + 6 * s * dir} ${y - 9 * s} Z',
    col,
  );
  a.c(x + 9 * s * dir, y - 2 * s, 2.4 * s, w);
  a.c(x + 9.6 * s * dir, y - 2 * s, 1.3 * s, k);
}

void _okTurtle(Art a, num x, num y, num dir) {
  // Arka ve ön yüzgeçler.
  a.o(x - 26 * dir, y + 16, 14, 5, 0x7DB863, rot: -25 * dir);
  a.o(x + 14 * dir, y + 22, 22, 7, 0x7DB863, rot: 28 * dir);
  a.p(
    'M${x - 34 * dir} ${y + 2} L${x - 46 * dir} ${y + 8} L${x - 34 * dir} ${y + 10} Z',
    0x7DB863,
  );
  // Baş.
  a.o(x + 40 * dir, y - 2, 13, 10.5, 0x9ACB74);
  a.c(x + 44 * dir, y - 5, 3, w);
  a.c(x + 45 * dir, y - 5, 1.6, k);
  a.s(
    'M${x + 44 * dir} ${y + 3} Q${x + 48 * dir} ${y + 5} ${x + 51 * dir} ${y + 2}',
    0x3C7D49,
    1.6,
  );
  // Kabuk.
  a.o(x, y + 6, 36, 20, 0xE8D9A0);
  a.o(x, y, 36, 24, 0x4E9A5C);
  a.o(x - 4 * dir, y - 8, 24, 8, 0x7BC27E, op: 0.5);
  a.o(x, y - 1, 12, 9, 0x8CCB7A);
  a.o(x - 22 * dir, y + 2, 9, 8, 0x6DB56E);
  a.o(x + 22 * dir, y + 2, 9, 8, 0x6DB56E);
  a.s(
    'M${x - 12} ${y - 8} L${x - 20 * dir} ${y - 14} M${x + 12} ${y - 8} L${x + 20 * dir} ${y - 14} '
    'M${x - 12} ${y + 7} L${x - 20 * dir} ${y + 14} M${x + 12} ${y + 7} L${x + 20 * dir} ${y + 14}',
    0x356F40,
    2,
  );
  a.o(x, y, 36, 24, 0x2F6B3C, strokeWidth: 2.5);
}

void _okWeed(Art a, num x, num y, num h, int col) {
  a.s(
    'M$x $y Q${x + 16} ${y - h * 0.3} ${x - 2} ${y - h * 0.55} Q${x - 14} ${y - h * 0.78} ${x + 4} ${y - h}',
    col,
    7,
  );
  a.s(
    'M${x + 10} $y Q${x + 26} ${y - h * 0.25} ${x + 10} ${y - h * 0.5} Q${x + 2} ${y - h * 0.65} ${x + 12} ${y - h * 0.78}',
    col,
    5,
  );
}

void _okCoral(Art a, num x, num y, num s, int col, int tip) {
  const branches = [
    'M0 0 Q-6 -30 -2 -58',
    'M-4 -30 Q-22 -38 -26 -60',
    'M-2 -44 Q18 -50 22 -74',
    'M2 -20 Q20 -26 30 -42',
  ];
  const tips = [
    [-2, -58],
    [-26, -60],
    [22, -74],
    [30, -42],
  ];
  for (final b in branches) {
    final nums = RegExp(r'-?\d+')
        .allMatches(b)
        .map((m) => int.parse(m[0]!))
        .toList();
    final p = <String>[];
    for (var i = 0; i < nums.length; i += 2) {
      p.add('${x + nums[i] * s} ${y + nums[i + 1] * s}');
    }
    a.s('M${p[0]} Q${p[1]} ${p[2]}', col, (7 * s).toDouble());
  }
  for (final t in tips) {
    a.c(x + t[0] * s, y + t[1] * s, 5 * s, tip);
  }
}

void _okBrain(Art a, num x, num y, num s, int col) {
  a.p(
    'M${x - 30 * s} $y Q${x - 30 * s} ${y - 40 * s} $x ${y - 40 * s} '
    'Q${x + 30 * s} ${y - 40 * s} ${x + 30 * s} $y Z',
    col,
  );
  a.o(x - 8 * s, y - 24 * s, 12 * s, 8 * s, w, op: 0.2, rot: -20);
  a.s(
    'M${x - 20 * s} ${y - 6 * s} q${6 * s} ${-12 * s} ${12 * s} ${-2 * s} q${6 * s} ${12 * s} ${12 * s} 0 q${6 * s} ${-12 * s} ${12 * s} 0 '
    'M${x - 14 * s} ${y - 20 * s} q${6 * s} ${-8 * s} ${12 * s} 0 q${6 * s} ${8 * s} ${12 * s} 0',
    0xB84A6A,
    (2.2 * s).toDouble(),
  );
}

void _okFan(Art a, num x, num y, num s, int col) {
  a.p(
    'M$x $y L${x - 34 * s} ${y - 46 * s} Q$x ${y - 70 * s} ${x + 34 * s} ${y - 46 * s} Z',
    col,
    op: 0.85,
  );
  for (final dx in const [-22, -11, 0, 11, 22]) {
    a.s('M$x $y L${x + dx * s} ${y - (56 - dx.abs() * 0.4) * s}', w, 1.2);
  }
  a.s('M$x $y v${6 * s}', 0x9B3B5A, (4 * s).toDouble());
}

String _okStar(num cx, num cy, num big, num small) {
  final b = StringBuffer();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? big : small;
    final ang = (i * 36 - 90) * math.pi / 180;
    b.write(
      '${i == 0 ? 'M' : 'L'}${cx + r * math.cos(ang)} ${cy + r * math.sin(ang)} ',
    );
  }
  b.write('Z');
  return b.toString();
}

void _okShell(Art a, num x, num y) {
  a.o(x, y, 13, 10, 0xF7D9BE);
  a.s('M$x $y q3 -4 6 0 q0 6 -7 6 q-9 0 -9 -9 q0 -10 11 -10', 0xD99A78, 1.8);
  a.o(x - 4, y - 4, 4, 2.4, w, op: 0.6);
}

void _okScallop(Art a, num x, num y) {
  a.p(
    'M$x $y L${x - 15} ${y - 10} Q$x ${y - 26} ${x + 15} ${y - 10} Z',
    0xF8B8A0,
  );
  for (final dx in const [-9, -3, 3, 9]) {
    a.s('M$x $y L${x + dx * 1.3} ${y - 17}', 0xE08A70, 1.4);
  }
  a.o(x, y + 1, 5, 2.6, 0xE08A70);
}

void _okyanusBg(Art a) {
  a.p(_dogaFull, 0xE7FAFD);
  a.p(_dogaWave(40, 7, step: 55), 0xC7EEF8);
  a.p('M120 200 H560 V512 H120 Z', 0xB0E2F0, op: 0.6);
  a.p('M120 330 H560 V512 H120 Z', 0x8FD0E6, op: 0.55);
  // Büyük termosun arkasında sakin bir su koridoru, kenarlarda ise derinlik.
  a.p('M242 8 Q340 110 438 8 V512 H242 Z', 0xD8F5FA, op: 0.18);
  a.p(
    'M120 220 Q154 176 190 226 Q214 258 238 292 L238 512 H120 Z',
    0x559DB9,
    op: 0.24,
  );
  a.p(
    'M560 196 Q524 164 492 222 Q468 260 446 302 L446 512 H560 Z',
    0x4D94B2,
    op: 0.22,
  );
  // Yüzeyden süzülen ışık demetleri.
  for (final r in const [
    [140, 200, 90, 250],
    [250, 290, 190, 280],
    [390, 430, 430, 520],
    [500, 540, 470, 520],
  ]) {
    a.p('M${r[0]} 30 L${r[1]} 30 L${r[3]} 500 L${r[2]} 500 Z', w, op: 0.14);
  }
  // Uzak mercan siluetleri.
  a.o(210, 470, 46, 30, 0x6FBFD8, op: 0.5);
  a.o(480, 470, 52, 34, 0x6FBFD8, op: 0.5);
  // Balık sürüsü (sol), kaplumbağa (sağ).
  for (final f in const [
    [160, 150, 0.7, 0xFFC93C],
    [190, 172, 0.55, 0xFFB52E],
    [150, 188, 0.6, 0xFFC93C],
    [200, 134, 0.5, 0xFFB52E],
    [176, 210, 0.45, 0xFFC93C],
  ]) {
    _okFish(a, f[0], f[1], f[2], f[3].toInt(), 1);
  }
  _okFish(a, 512, 200, 0.9, 0xF2677A, -1);
  _okTurtle(a, 500, 112, -1);
  // Su altı yosunları.
  _okWeed(a, 138, 486, 150, 0x3F9E6B);
  _okWeed(a, 156, 490, 110, 0x55B57C);
  _okWeed(a, 542, 488, 140, 0x3F9E6B);
  _okWeed(a, 524, 492, 100, 0x55B57C);
  // Kabarcıklar.
  for (final b in const [
    [160, 330, 6],
    [172, 306, 4],
    [150, 280, 3],
    [520, 210, 5],
    [532, 188, 3],
    [506, 410, 4],
    [494, 386, 3],
    [140, 420, 4],
    [215, 90, 3],
  ]) {
    a.c(b[0], b[1], b[2], w, op: 0.25);
    a.o(b[0], b[1], b[2], b[2], w, op: 0.8, strokeWidth: 1.5);
    a.c(b[0] - b[2] * 0.3, b[1] - b[2] * 0.3, b[2] * 0.25, w, op: 0.9);
  }
  // Kum zemin.
  a.p('M120 466 Q250 446 360 462 Q460 476 560 454 V512 H120 Z', 0xF3DFAA);
  a.p('M120 490 Q300 474 560 492 V512 H120 Z', 0xE6CB8A);
  a.s('M150 480 Q180 474 210 480 M420 486 Q450 480 480 486', 0xD9BE7E, 2);
  // Mercan resifi.
  _okBrain(a, 188, 474, 1.0, 0xE9788C);
  _okCoral(a, 232, 480, 0.9, 0xF08A5D, 0xFFB38A);
  _okCoral(a, 126, 486, 0.8, 0xE8567A, 0xFF8FAE);
  _okFan(a, 470, 482, 1.0, 0xB57BDB);
  _okCoral(a, 516, 486, 0.95, 0xF2A03D, 0xFFCC77);
  _okBrain(a, 552, 488, 0.8, 0xF0A3B8);
  // Deniz yıldızı ve kabuklar.
  a.p(_okStar(300, 494, 14, 6), 0xF2677A);
  a.c(300, 494, 2, 0xFFD2D8);
  a.p(_okStar(410, 498, 11, 4.8), 0xFFA040);
  _okShell(a, 268, 498);
  _okScallop(a, 360, 502);
}

void _okyanusA(Art a, bool happy) {
  const top = 0x7C9DB8;
  const fin = 0x5C7C94;
  // Sırt yüzgeci (kafanın tepesinde) ve yan yüzgeçler.
  a.p('M296 78 Q326 44 350 12 Q354 54 388 80 Z', fin);
  a.p('M312 70 Q334 40 348 20 Q346 46 352 70 Z', 0x7E9DB4, op: 0.8);
  a.p('M262 172 Q226 186 212 222 Q246 216 272 204 Z', fin);
  a.p('M418 172 Q454 186 468 222 Q434 216 408 204 Z', fin);
  a.dome(top, 0xA9C4D6, 0x4F6F88);
  // Beyaz karın (kafa içine kırpılmış).
  a.canvas.save();
  a.canvas.clipPath(
    Path()..addOval(
      Rect.fromCenter(center: const Offset(340, 130), width: 192, height: 160),
    ),
  );
  a.p('M244 156 Q290 138 340 152 Q390 138 436 156 V220 H244 Z', 0xF2F8FB);
  a.p(
    'M244 168 Q290 154 340 166 Q390 154 436 168 V220 H244 Z',
    0xDCEAF1,
    op: 0.6,
  );
  a.canvas.restore();
  // Solungaç yarıkları.
  for (final x in const [254, 264, 274]) {
    a.s('M$x 118 Q${x + 6} 130 $x 144', 0x4F6F88, 3);
    a.s('M${680 - x} 118 Q${674 - x} 130 ${680 - x} 144', 0x4F6F88, 3);
  }
  if (happy) {
    a.s('M286 122 Q298 106 310 122', k, 4.5);
    a.s('M370 122 Q382 106 394 122', k, 4.5);
  } else {
    a.eye(298, 118, 11);
    a.eye(382, 118, 11);
  }
  a.c(326, 142, 2, 0x4F6F88);
  a.c(354, 142, 2, 0x4F6F88);
  a.cheeks(158, happy ? 0.75 : 0.5);
  if (happy) {
    // Açık, dişli gülümseme.
    a.p('M292 160 Q340 218 388 160 Q340 174 292 160 Z', 0x6B1F2E);
    a.o(340, 200, 20, 9, 0xF2677A);
    for (var i = 0; i < 6; i++) {
      final x = 300.0 + i * 15.6;
      final u = (x + 7.8 - 340) / 48;
      final y = 160 + 7 * (1 - u * u);
      a.p('M$x ${y - 1} L${x + 7.8} ${y + 11} L${x + 15.6} ${y - 1} Z', w);
    }
    a.s('M292 160 Q340 218 388 160', k, 3);
  } else {
    a.s('M298 166 Q340 190 382 166', k, 3.5);
    a.p('M322 177 L329 187 L336 180 Z', w);
    a.p('M344 180 L351 187 L358 177 Z', w);
  }
}

void _okyanusB(Art a, bool happy) {
  const fin = 0x5C7C94;
  a.p('M316 98 Q336 62 352 38 Q356 74 378 98 Z', fin);
  a.p('M284 142 L260 170 L290 164 Z', fin);
  a.p('M396 142 L420 170 L390 164 Z', fin);
  a.box(0x7C9DB8, 0xA9C4D6, 0x4F6F88);
  a.p('M284 138 Q340 126 396 138 L396 164 L284 164 Z', 0xF2F8FB);
  for (final x in const [294, 302]) {
    a.s('M$x 112 Q${x + 4} 120 $x 130', 0x4F6F88, 2.2);
    a.s('M${680 - x} 112 Q${676 - x} 120 ${680 - x} 130', 0x4F6F88, 2.2);
  }
  if (happy) {
    a.s('M306 118 Q316 106 326 118', k, 3.5);
    a.s('M354 118 Q364 106 374 118', k, 3.5);
    a.p('M314 140 Q340 170 366 140 Q340 148 314 140 Z', 0x6B1F2E);
    for (var i = 0; i < 4; i++) {
      final x = 321.0 + i * 9.5;
      a.p('M$x 142 L${x + 4.75} 150 L${x + 9.5} 142 Z', w);
    }
    a.o(340, 158, 8, 3.5, 0xF2677A);
  } else {
    a.eye(316, 116, 7);
    a.eye(364, 116, 7);
    a.s('M318 146 Q340 158 362 146', k, 2.8);
    a.p('M333 152 L338 158 L343 152 Z', w);
  }
}

// --- Ahtapot ---------------------------------------------------------------

void _ahtapotBg(Art a) {
  a.p(_dogaFull, 0xDDF3F0);
  a.p('M120 8 H560 V200 H120 Z', 0xEAF8F6);
  a.p('M120 196 H560 V360 H120 Z', 0xBDE4E2, op: 0.55);
  a.p('M120 330 H560 V512 H120 Z', 0x91D0D0, op: 0.38);
  // Sahnenin ortası büyük termos için açık kalır; ışık iki yandan süzülür.
  a.p('M140 8 H208 L286 420 H226 Z', w, op: 0.13);
  a.p('M476 8 H540 L466 420 H406 Z', w, op: 0.11);
  // Uzak kaya kemerleri sahneyi çerçeveler.
  a.p(
    'M120 344 Q142 264 196 248 Q228 250 246 282 L226 304 Q210 278 184 284 Q154 298 150 364 Z',
    0x5CA5A0,
    op: 0.42,
  );
  a.p(
    'M560 326 Q536 252 494 244 Q458 246 438 278 L458 300 Q474 274 500 280 Q530 294 536 350 Z',
    0x579B9A,
    op: 0.4,
  );
  a.p('M120 420 Q320 396 560 424 V512 H120 Z', 0xF3E3B8);
  a.p('M120 470 Q300 448 560 474 V512 H120 Z', 0xE6CC96, op: 0.55);
  // yosunlar
  for (final x in const [140, 160, 520, 540]) {
    a.s(
      'M$x 490 Q${x + 16} 440 ${x - 6} 390 Q${x + 12} 350 ${x - 2} 310',
      x < 300 ? 0x4FA66A : 0x3E9560,
      6,
    );
  }
  // mercanlar
  a.s('M200 480 L200 440 M200 456 L184 430 M200 450 L216 424', 0xF2677A, 7);
  a.s('M480 482 L480 436 M480 458 L498 432 M480 446 L464 422', 0xF59E42, 7);
  a.o(172, 490, 22, 14, 0xB57EDC);
  a.o(172, 484, 14, 8, 0xCDA5EC);
  a.o(510, 492, 24, 15, 0xF59BB9);
  a.o(510, 486, 15, 8, 0xFBC4D6);
  // küçük balıklar
  _okFish(a, 170, 230, 0.8, 0xFFC93C, 1);
  _okFish(a, 510, 190, 0.8, 0x7EC8E3, -1);
  for (final b in const [
    [140, 120, 5],
    [154, 98, 3],
    [530, 90, 4],
    [516, 64, 3],
    [500, 330, 4],
    [150, 340, 3],
  ]) {
    a.o(b[0], b[1], b[2], b[2], w, op: 0.8, strokeWidth: 1.5);
  }
}

void _ahtapotTentacles(Art a, bool slim) {
  final lx = slim ? 292 : 262;
  final rx = slim ? 388 : 418;
  final y = slim ? 164 : 188;
  a.s('M$lx $y q-14 14 -4 28 q8 10 -2 18', 0xE4638F, 12);
  a.s('M${lx + 18} ${y + 6} q-6 18 6 26', 0xE4638F, 11);
  a.s('M$rx $y q14 14 4 28 q-8 10 2 18', 0xE4638F, 12);
  a.s('M${rx - 18} ${y + 6} q6 18 -6 26', 0xE4638F, 11);
  a.c(lx - 8, y + 24, 2.5, 0xF9C2D6);
  a.c(rx + 8, y + 24, 2.5, 0xF9C2D6);
}

void _ahtapotA(Art a, bool happy) {
  _ahtapotTentacles(a, false);
  a.dome(0xE4638F, 0xF58FB2, 0xB03A6B);
  for (final s in const [
    [290, 78, 6],
    [330, 64, 5],
    [380, 76, 7],
    [410, 110, 5],
    [270, 112, 5],
    [352, 100, 4],
  ]) {
    a.c(s[0], s[1], s[2], 0xF9B3CC, op: 0.8);
  }
  if (happy) {
    a.s('M286 134 Q300 114 314 134 M366 134 Q380 114 394 134', k, 4);
    a.p('M318 156 Q340 192 362 156 Z', 0x7A1F44);
    a.o(340, 176, 10, 5, 0xF2677A);
  } else {
    a.o(300, 130, 17, 19, w);
    a.o(380, 130, 17, 19, w);
    a.o(302, 134, 9, 11, k);
    a.o(382, 134, 9, 11, k);
    a.c(298, 129, 3.5, w);
    a.c(378, 129, 3.5, w);
    a.s('M322 160 Q340 174 358 160', k, 3.5);
  }
  a.cheeks(158, happy ? 0.9 : 0.55);
}

void _ahtapotB(Art a, bool happy) {
  _ahtapotTentacles(a, true);
  a.box(0xE4638F, 0xF58FB2, 0xB03A6B);
  for (final s in const [
    [304, 104, 4],
    [356, 100, 5],
    [380, 112, 3],
  ]) {
    a.c(s[0], s[1], s[2], 0xF9B3CC, op: 0.8);
  }
  if (happy) {
    a.s('M304 128 Q314 114 324 128 M356 128 Q366 114 376 128', k, 3.5);
    a.s('M326 146 Q340 160 354 146', k, 3.5);
  } else {
    a.o(314, 126, 10, 12, w);
    a.o(366, 126, 10, 12, w);
    a.o(316, 129, 5, 6, k);
    a.o(368, 129, 5, 6, k);
    a.s('M328 148 Q340 156 352 148', k, 3);
  }
  a.o(296, 144, 7, 4, 0xF9B3CC, op: 0.7);
  a.o(384, 144, 7, 4, 0xF9B3CC, op: 0.7);
}

// --- Kaktüs ----------------------------------------------------------------

void _kaktusBg(Art a) {
  a.p(_dogaFull, 0xFCE9C8);
  a.p('M120 8 H560 V190 H120 Z', 0xFDF3DC);
  a.p('M120 124 H560 V270 H120 Z', 0xF7D7B1, op: 0.34);
  a.c(450, 100, 44, 0xFFD27A);
  a.c(450, 100, 32, 0xFFE3A3);
  // Uzak, yumuşak mesa katmanları; merkezde termos silueti için düşük kontrast.
  a.p('M120 292 L162 254 H218 L246 288 L270 304 H120 Z', 0xD98F70, op: 0.52);
  a.p('M560 278 L528 244 H474 L448 282 L424 300 H560 Z', 0xD4866C, op: 0.48);
  a.p(
    'M120 330 L200 260 L270 320 L340 270 L420 330 L500 280 L560 320 V512 H120 Z',
    0xE9B98A,
    op: 0.72,
  );
  a.p('M120 400 Q250 350 360 400 Q460 440 560 390 V512 H120 Z', 0xF0CD8F);
  a.p('M120 450 Q300 420 560 456 V512 H120 Z', 0xE4B56F);
  // arka plan küçük kaktüsler
  for (final (x, y) in const [(160, 440), (520, 450)]) {
    a.p(
      'M${x - 9} $y V${y - 60} Q$x ${y - 70} ${x + 9} ${y - 60} V$y Z',
      0x6FAE4F,
    );
    a.s('M${x + 9} ${y - 24} h12 v-20', 0x6FAE4F, 8);
    a.s('M${x - 9} ${y - 34} h-12 v-14', 0x6FAE4F, 8);
  }
  a.s('M200 480 Q250 470 300 480 M420 490 Q470 480 520 490', 0xD39A55, 2.5);
  a.c(250, 478, 10, 0xB98B4E);
  a.s('M240 478 L260 478 M250 468 L250 488', 0x8F6A35, 1.5);
}

void _kaktusFlower(Art a, num x, num y, num r, bool happy) {
  final c = happy ? 0xFF6FA0 : 0xF28BB0;
  for (var i = 0; i < 6; i++) {
    final ang = i * 60 * math.pi / 180;
    a.o(
      x + math.cos(ang) * r,
      y + math.sin(ang) * r,
      r * 0.8,
      r * 0.5,
      c,
      rot: i * 60,
    );
  }
  a.c(x, y, r * 0.55, 0xFFD166);
}

void _kaktusA(Art a, bool happy) {
  a.s('M270 140 q-24 0 -26 -26 v-22', 0x5FA043, 24);
  a.s('M410 140 q24 0 26 -26 v-22', 0x5FA043, 24);
  a.dome(0x5FA043, 0x8CCB66, 0x3B7A2A);
  for (final x in const [300, 320, 340, 360, 380]) {
    a.s(
      'M$x 62 Q${x + (x - 340) * 0.35} 130 ${x + (x - 340) * 0.5} 200',
      0x3B7A2A,
      1.8,
    );
  }
  for (final p in const [
    [300, 90],
    [326, 78],
    [354, 84],
    [380, 96],
    [290, 160],
    [392, 170],
    [262, 118],
    [420, 120],
  ]) {
    a.s(
      'M${p[0] - 4} ${p[1] - 3} l8 6 M${p[0] + 4} ${p[1] - 3} l-8 6',
      0xFFF3C4,
      1.6,
    );
  }
  _kaktusFlower(a, 340, 46, happy ? 17 : 13, happy);
  if (happy) {
    a.s('M298 126 Q310 110 322 126 M358 126 Q370 110 382 126', k, 4);
    a.p('M318 150 Q340 184 362 150 Z', 0x6B2A2A);
    a.o(340, 168, 9, 5, 0xF2677A);
  } else {
    a.eye(310, 124, 9);
    a.eye(370, 124, 9);
    a.s('M324 152 Q340 166 356 152', k, 3.5);
  }
  a.cheeks(148, happy ? 0.9 : 0.6);
}

void _kaktusB(Art a, bool happy) {
  a.s('M290 130 q-22 0 -24 -22 v-20', 0x5FA043, 18);
  a.s('M390 130 q22 0 24 -22 v-20', 0x5FA043, 18);
  a.box(0x5FA043, 0x8CCB66, 0x3B7A2A);
  for (final x in const [312, 340, 368]) {
    a.s('M$x 94 L$x 162', 0x3B7A2A, 1.8);
  }
  for (final p in const [
    [304, 104],
    [376, 104],
    [304, 154],
    [376, 154],
  ]) {
    a.s(
      'M${p[0] - 3} ${p[1] - 2} l6 4 M${p[0] + 3} ${p[1] - 2} l-6 4',
      0xFFF3C4,
      1.5,
    );
  }
  _kaktusFlower(a, 340, 80, happy ? 15 : 11, happy);
  if (happy) {
    a.s('M312 122 Q320 110 328 122 M352 122 Q360 110 368 122', k, 3);
    a.s('M328 142 Q340 154 352 142', k, 3);
  } else {
    a.eye(320, 120, 6);
    a.eye(360, 120, 6);
    a.s('M330 142 Q340 150 350 142', k, 3);
  }
  a.o(300, 138, 7, 4, 0xED93B1, op: 0.7);
  a.o(380, 138, 7, 4, 0xED93B1, op: 0.7);
}

// --- Kardan Adam -----------------------------------------------------------

void _kardanBg(Art a) {
  a.p(_dogaFull, 0x14224A);
  a.p('M120 8 H560 V200 H120 Z', 0x1B2D5E);
  final r = Art(a.canvas);
  for (var i = 0; i < 45; i++) {
    final x = 125 + r.rnd() * 430;
    final y = 12 + r.rnd() * 330;
    a.c(x, y, r.rnd() * 1.6 + 0.6, w, op: 0.5 + r.rnd() * 0.5);
  }
  a.c(484, 80, 30, 0xFFF3C4);
  a.c(496, 72, 26, 0x1B2D5E);
  // koyu arka tepeler (etiketler okunabilsin)
  a.p(
    'M120 360 Q200 300 280 350 Q360 390 440 340 Q500 310 560 350 V512 H120 Z',
    0x2A3F75,
  );
  // çam ağaçları
  for (final (x, y) in const [(150, 430), (190, 450), (520, 440), (550, 455)]) {
    a.p('M$x ${y - 80} L${x + 22} ${y - 20} L${x - 22} ${y - 20} Z', 0x1F5A45);
    a.p('M$x ${y - 56} L${x + 28} ${y + 6} L${x - 28} ${y + 6} Z', 0x2A7358);
    a.p('M$x ${y - 80} L${x + 8} ${y - 62} L${x - 8} ${y - 62} Z', w);
    a.p(
      'M$x ${y - 56} L${x + 12} ${y - 34} L${x - 12} ${y - 34} Z',
      w,
      op: 0.9,
    );
  }
  a.p('M120 482 Q300 460 560 486 V512 H120 Z', 0xEAF2FF);
  a.p('M120 498 Q320 484 560 500 V512 H120 Z', w);
  for (var i = 0; i < 26; i++) {
    a.c(
      125 + r.rnd() * 430,
      20 + r.rnd() * 450,
      r.rnd() * 2 + 1.5,
      w,
      op: 0.85,
    );
  }
}

void _kardanScarf(Art a, num y, num span, bool tail) {
  a.p(
    'M${340 - span} $y Q340 ${y + 26} ${340 + span} $y '
    'L${340 + span - 4} ${y + 22} Q340 ${y + 48} ${340 - span + 4} ${y + 22} Z',
    0xC0392B,
  );
  a.s(
    'M${340 - span + 20} ${y + 14} l6 16 M${340 + span - 20} ${y + 14} l-6 16',
    0xE5594A,
    3,
  );
  if (tail) {
    a.p('M376 ${y + 24} l26 4 l-6 46 l-24 -4 Z', 0xC0392B);
    a.p('M378 ${y + 40} l24 4 l-1 8 l-24 -4 Z', 0xE5594A);
  }
}

void _kardanA(Art a, bool happy) {
  a.dome(0xF4F8FF, w, 0xBCD0EA);
  // silindir şapka
  a.o(340, 56, 62, 10, 0x2C2C2A);
  a.p('M300 56 L304 12 Q340 4 376 12 L380 56 Z', 0x3B3B3A);
  a.p('M302 46 L379 46 L380 56 L300 56 Z', 0xC0392B);
  a.p('M310 16 L318 16 L316 44 L310 44 Z', 0x5F5E5A, op: 0.8);
  // yüz
  if (happy) {
    a.s('M296 112 Q308 98 320 112 M360 112 Q372 98 384 112', k, 4);
  } else {
    a.c(308, 110, 6, k);
    a.c(372, 110, 6, k);
  }
  a.p('M336 124 L400 140 L336 148 Z', 0xF28A2E);
  a.p('M336 124 L372 133 L336 134 Z', 0xF9B061);
  if (happy) {
    a.p('M308 156 Q340 190 372 156 Z', 0x6B2A2A);
  } else {
    for (var i = 0; i < 5; i++) {
      final t = (i - 2) / 2;
      a.c(340 + t * 28, 168 - t * t * 8, 3.2, k);
    }
  }
  a.cheeks(144, happy ? 0.85 : 0.55);
  _kardanScarf(a, 188, 96, true);
}

void _kardanB(Art a, bool happy) {
  a.box(0xF4F8FF, w, 0xBCD0EA);
  // örgü bere
  a.p('M284 112 Q284 66 340 62 Q396 66 396 112 Z', 0xC0392B);
  a.p('M284 112 L396 112 L396 124 L284 124 Z', 0xE5594A);
  for (var x = 292; x < 396; x += 12) {
    a.s('M$x 112 L$x 124', 0xC0392B, 2);
  }
  a.c(340, 58, 10, w);
  // yüz
  if (happy) {
    a.s('M304 142 Q314 130 324 142 M356 142 Q366 130 376 142', k, 3.5);
  } else {
    a.c(314, 140, 5, k);
    a.c(366, 140, 5, k);
  }
  a.p('M334 146 L376 154 L334 160 Z', 0xF28A2E);
  _kardanScarf(a, 160, 56, false);
}

// --- Sonbahar --------------------------------------------------------------

void _sbLeaf(Art a, num x, num y, num rot, int col, [num s = 1]) {
  a.o(x, y, 14 * s, 7 * s, col, rot: rot);
  final dx = 12 * s * math.cos(rot * math.pi / 180);
  final dy = 12 * s * math.sin(rot * math.pi / 180);
  a.s('M${x - dx} ${y - dy} L${x + dx} ${y + dy}', 0x7A4524, 1.2);
}

// Kept for easy theme restoration; Sonbahar is no longer in the catalog.
// ignore: unused_element
void _sonbaharBg(Art a) {
  a.p(_dogaFull, 0xFBE4BF);
  a.p('M120 8 H560 V180 H120 Z', 0xFDF0D5);
  a.c(200, 110, 34, 0xFFC873);
  a.p('M120 330 Q230 270 340 320 Q450 370 560 300 V512 H120 Z', 0xE9B77C);
  // ağaçlar
  for (final (x, h, c1, c2) in const [
    (160, 0, 0xD2691E, 0xE8923F),
    (520, 20, 0xC0392B, 0xE0603E),
    (128, 80, 0xE8A21E, 0xF2C14E),
  ]) {
    final top = 150.0 + h;
    a.p(
      'M${x - 8} 470 L${x - 5} ${top + 100} L${x + 5} ${top + 100} L${x + 8} 470 Z',
      0x7A4524,
    );
    a.s('M$x ${top + 120} l-26 -26 M$x ${top + 140} l24 -22', 0x7A4524, 4);
    a.c(x, top + 60, 62, c1);
    a.c(x - 36, top + 84, 38, c2);
    a.c(x + 38, top + 86, 40, c2);
    a.c(x - 12, top + 40, 22, c2, op: 0.7);
    a.c(x + 22, top + 66, 16, c1, op: 0.8);
  }
  a.p('M120 450 Q300 426 560 452 V512 H120 Z', 0xB9743A);
  a.p('M120 486 Q320 470 560 490 V512 H120 Z', 0x9A5A2A);
  for (final l in const [
    [170, 462, 20, 0xD2691E],
    [210, 478, -30, 0xE8A21E],
    [250, 468, 40, 0xC0392B],
    [440, 466, -20, 0xE8923F],
    [490, 480, 30, 0xD2691E],
    [530, 466, -40, 0xE8A21E],
    [300, 496, 10, 0xC0392B],
    [420, 498, -10, 0xE8A21E],
  ]) {
    _sbLeaf(a, l[0], l[1], l[2], l[3], 0.8);
  }
}

// ignore: unused_element
void _sonbaharA(Art a, bool happy) {
  // meşe palamudu kapağı
  a.p('M338 52 Q336 30 352 16 Q348 36 346 52 Z', 0x7A4524);
  a.dome(0xB06A3A, 0xD08E5C, 0x7A4524);
  final clip = Path()
    ..addOval(
      Rect.fromCenter(center: const Offset(340, 130), width: 192, height: 160),
    );
  a.canvas.save();
  a.canvas.clipPath(clip);
  for (var x = 220.0; x < 470; x += 26) {
    a.s('M$x 40 L${x + 90} 220', 0x7A4524, 1.3);
    a.s('M${x + 90} 40 L$x 220', 0x7A4524, 1.3);
  }
  a.canvas.restore();
  // yüz
  if (happy) {
    a.s('M296 128 Q308 112 320 128 M360 128 Q372 112 384 128', k, 4);
    a.p('M318 152 Q340 186 362 152 Z', 0x5A2020);
    a.o(340, 170, 9, 5, 0xE0603E);
  } else {
    a.eye(308, 126, 9);
    a.eye(372, 126, 9);
    a.s('M324 152 Q340 166 356 152', k, 3.5);
  }
  a.cheeks(148, happy ? 0.9 : 0.6);
  _sbLeaf(a, 366, 30, -30, 0xD2691E, 1.2);
  _sbLeaf(a, 266, 70, -50, 0xE8A21E, 1.1);
  _sbLeaf(a, 420, 80, 50, 0xC0392B, 1.1);
}

// ignore: unused_element
void _sonbaharB(Art a, bool happy) {
  a.p('M338 90 Q336 62 354 46 Q348 68 346 90 Z', 0x7A4524);
  a.box(0xB06A3A, 0xD08E5C, 0x7A4524);
  a.canvas.save();
  a.canvas.clipPath(a.path(Art.boxBase));
  for (var x = 270.0; x < 400; x += 22) {
    a.s('M$x 90 L${x + 50} 164', 0x7A4524, 1.2);
    a.s('M${x + 50} 90 L$x 164', 0x7A4524, 1.2);
  }
  a.canvas.restore();
  if (happy) {
    a.s('M308 126 Q318 112 328 126 M352 126 Q362 112 372 126', k, 3.5);
    a.s('M328 146 Q340 158 352 146', k, 3.5);
  } else {
    a.eye(318, 124, 6);
    a.eye(362, 124, 6);
    a.s('M330 146 Q340 154 350 146', k, 3);
  }
  a.o(300, 142, 7, 4, 0xED93B1, op: 0.7);
  a.o(380, 142, 7, 4, 0xED93B1, op: 0.7);
  _sbLeaf(a, 372, 64, -30, 0xD2691E, 1);
}

// --- Ayı -------------------------------------------------------------------

String _ayiHex(num cx, num cy, num r) {
  final b = StringBuffer();
  for (var i = 0; i < 6; i++) {
    final ang = (60 * i - 90) * math.pi / 180;
    b.write(i == 0 ? 'M' : 'L');
    b.write('${cx + r * math.cos(ang)} ${cy + r * math.sin(ang)} ');
  }
  b.write('Z');
  return b.toString();
}

void _ayiPine(Art a, num x, num y, num s, int hex) {
  for (var i = 0; i < 3; i++) {
    final yy = y - i * 34 * s;
    final w = (46 - i * 11) * s;
    a.p('M${x - w} $yy L$x ${yy - 54 * s} L${x + w} $yy Z', hex);
  }
  a.p('M${x - 6 * s} $y h${12 * s} v${22 * s} h${-12 * s} Z', 0x6B4423);
}

void _ayiBg(Art a) {
  a.p(_dogaFull, 0xEAF3C9);
  a.c(204, 92, 36, 0xFFF3B0);
  a.c(204, 92, 24, 0xFFE27A);
  // Uzak orman
  a.p(
    'M120 330 Q200 270 280 320 Q370 260 450 320 Q510 290 560 310 V512 H120 Z',
    0xB7D9A0,
  );
  _ayiPine(a, 160, 380, 1.1, 0x8DBE79);
  _ayiPine(a, 520, 370, 1.2, 0x8DBE79);
  _ayiPine(a, 460, 400, 0.9, 0x6FA85A);
  _ayiPine(a, 210, 410, 0.8, 0x6FA85A);
  // Ön tepe
  a.p('M120 430 Q250 396 360 428 Q470 456 560 420 V512 H120 Z', 0x6FA85A);
  a.p('M120 472 Q300 448 560 476 V512 H120 Z', 0x4F8F46);
  // Ağaç gövdesi ve petek
  a.p('M500 120 h34 v300 h-34 Z', 0x7A5230);
  a.c(512, 96, 36, 0x5E9E48);
  a.c(540, 120, 26, 0x4F8F46);
  for (final h in const [
    [506.0, 220.0],
    [530.0, 220.0],
    [518.0, 242.0],
    [494.0, 242.0],
    [506.0, 264.0],
  ]) {
    a.p(_ayiHex(h[0], h[1], 14), 0xF2B632);
    a.p(_ayiHex(h[0], h[1], 9), 0xE39A14, op: 0.7);
  }
  a.p('M492 270 q4 24 8 0 Z M524 250 q4 30 8 0 Z', 0xF2B632);
  // Arılar
  for (final b in const [
    [250.0, 190.0],
    [292.0, 224.0],
  ]) {
    a.o(b[0], b[1], 8, 5.5, 0xF2B632);
    a.s('M${b[0] - 3} ${b[1] - 5} v10 M${b[0] + 3} ${b[1] - 5} v10', k, 1.6);
    a.o(b[0] - 2, b[1] - 8, 6, 3, w, op: 0.8, rot: -30);
    a.o(b[0] + 4, b[1] - 8, 6, 3, w, op: 0.8, rot: 30);
  }
  // Bal küpü
  a.o(180, 476, 38, 7, 0x3C6B36, op: 0.5);
  a.p('M146 430 Q142 468 160 476 L200 476 Q218 468 214 430 Z', 0xA9683A);
  a.o(180, 430, 36, 9, 0x8B5230);
  a.o(180, 430, 29, 6, 0xF2B632);
  a.p('M160 432 q3 22 7 0 Z M190 434 q3 16 7 0 Z', 0xF2B632);
  a.p('M152 444 h56 v20 h-56 Z', 0xF7E7C0);
  a.s('M164 454 h32', 0xA9683A, 3);
}

void _ayiEars(Art a, num y, num dx, num r) {
  for (final d in const [-1, 1]) {
    a.c(340 + d * dx, y, r, 0x8B5A2B);
    a.c(340 + d * dx, y + r * 0.1, r * 0.58, 0xE9B98C);
    a.c(340 + d * dx, y + r * 0.2, r * 0.38, 0xC98A62, op: 0.6);
  }
}

void _ayiA(Art a, bool happy) {
  _ayiEars(a, 74, 74, 34);
  a.dome(0x8B5A2B, 0xB57A47, 0x5E3A1B);
  // Tüy dokusu
  a.s('M318 70 q4 -8 8 0 M340 62 q4 -8 8 0 M362 70 q4 -8 8 0', 0x5E3A1B, 2.5);
  // Kaşlar
  a.o(304, 100, 10, 4, 0x6B4423, rot: -10);
  a.o(376, 100, 10, 4, 0x6B4423, rot: 10);
  // Peluş burun bölgesi
  a.o(340, 168, 54, 38, 0xF3DDB5);
  a.o(334, 156, 30, 14, w, op: 0.2);
  a.cheeks(146, 0.45);
  if (happy) {
    a.s('M296 120 Q308 104 320 120 M360 120 Q372 104 384 120', k, 4.5);
  } else {
    a.eye(308, 122, 9);
    a.eye(372, 122, 9);
  }
  a.o(340, 146, 17, 12, 0x2E2018);
  a.o(334, 142, 6, 3.5, w, op: 0.55);
  if (happy) {
    a.p('M308 170 Q340 218 372 170 Q340 184 308 170 Z', 0x5A1F22);
    a.o(340, 192, 15, 9, 0xE8758F);
    a.s('M340 158 V170', k, 3);
  } else {
    a.s(
      'M340 158 V168 M340 168 Q328 180 316 172 M340 168 Q352 180 364 172',
      k,
      3.2,
    );
  }
}

void _ayiB(Art a, bool happy) {
  _ayiEars(a, 98, 44, 21);
  a.box(0x8B5A2B, 0xB57A47, 0x5E3A1B);
  a.o(340, 148, 30, 20, 0xF3DDB5);
  if (happy) {
    a.s('M308 118 Q318 106 328 118 M352 118 Q362 106 372 118', k, 3.5);
  } else {
    a.c(318, 118, 5, k);
    a.c(362, 118, 5, k);
    a.c(316, 116, 1.6, w);
    a.c(360, 116, 1.6, w);
  }
  a.o(340, 134, 10, 7, 0x2E2018);
  a.o(336, 131, 3.5, 2, w, op: 0.55);
  if (happy) {
    a.p('M326 146 Q340 166 354 146 Q340 154 326 146 Z', 0x5A1F22);
    a.o(340, 157, 6, 3.5, 0xE8758F);
  } else {
    a.s(
      'M340 141 V146 M340 146 Q334 153 327 149 M340 146 Q346 153 353 149',
      k,
      2.2,
    );
  }
}

// --- Kurbağa ---------------------------------------------------------------

void _kurbagaPad(Art a, num x, num y, num rx, int hex) {
  final ry = rx * 0.38;
  a.o(x, y, rx, ry, hex);
  a.o(x - rx * 0.2, y - ry * 0.25, rx * 0.55, ry * 0.4, w, op: 0.15);
  a.p(
    'M$x $y L${x + rx * 0.95} ${y - ry * 0.35} L${x + rx * 0.95} ${y + ry * 0.1} Z',
    0x6DBBB0,
  );
}

// Kept for easy theme restoration; Kurbağa is no longer in the catalog.
// ignore: unused_element
void _kurbagaBg(Art a) {
  a.p(_dogaFull, 0xD3EEDF);
  a.c(490, 80, 34, 0xFFF3B0);
  a.c(490, 80, 22, 0xFFE27A);
  // Uzak kıyı
  a.p(
    'M120 250 Q200 214 280 246 Q380 206 470 244 Q520 232 560 250 V512 H120 Z',
    0x9FCDA4,
  );
  // Su
  a.p('M120 290 H560 V512 H120 Z', 0x8ED0C4);
  a.p('M120 360 H560 V512 H120 Z', 0x6DBBB0);
  a.p('M120 440 H560 V512 H120 Z', 0x56A89E);
  // Halkalar
  a.o(430, 330, 40, 9, w, op: 0.55, strokeWidth: 2);
  a.o(430, 330, 24, 5, w, op: 0.5, strokeWidth: 2);
  a.o(210, 400, 34, 8, w, op: 0.5, strokeWidth: 2);
  // Kamışlar
  for (final r in const [
    [140.0, 290.0, 130.0],
    [156.0, 290.0, 100.0],
    [532.0, 290.0, 120.0],
    [546.0, 290.0, 90.0],
  ]) {
    a.s(
      'M${r[0]} ${r[1]} Q${r[0] + 4} ${r[1] - r[2] / 2} ${r[0] - 2} ${r[1] - r[2]}',
      0x4F8F46,
      5,
    );
    a.o(r[0] - 2, r[1] - r[2] - 14, 6, 17, 0x7A4A2A);
  }
  // Nilüfer yaprakları
  _kurbagaPad(a, 190, 330, 46, 0x4FA84A);
  _kurbagaPad(a, 500, 380, 52, 0x5FBA55);
  _kurbagaPad(a, 150, 470, 56, 0x4FA84A);
  _kurbagaPad(a, 520, 480, 44, 0x3E983E);
  _kurbagaPad(a, 330, 500, 48, 0x5FBA55);
  // Nilüfer çiçeği
  for (final d in const [-1, 0, 1]) {
    a.o(190 + d * 9, 316, 6, 14, 0xF6A7C1, rot: d * 28);
  }
  a.c(190, 322, 4, 0xFFE27A);
  // Yusufçuk
  a.o(280, 160, 12, 2.4, 0x2F8FC4);
  a.o(274, 154, 9, 3, w, op: 0.7, rot: -20);
  a.o(286, 154, 9, 3, w, op: 0.7, rot: 20);
  a.c(292, 160, 3, 0x1F6B96);
}

void _kurbagaEye(Art a, num x, num y, num r) {
  a.c(x, y, r, 0xF4F8DC);
  a.c(x, y + r * 0.1, r, 0x3A7D2E, op: 0.25);
  a.c(x, y - r * 0.05, r * 0.72, 0xFFFBE8);
  a.o(x, y, r * 0.38, r * 0.5, k);
  a.c(x - r * 0.15, y - r * 0.2, r * 0.14, w);
}

// ignore: unused_element
void _kurbagaA(Art a, bool happy) {
  a.dome(0x5DB04A, 0x8AD36F, 0x3A7D2E);
  // Çıkık gözler
  for (final d in const [-1, 1]) {
    a.c(340 + d * 58, 70, 33, 0x5DB04A);
    a.c(340 + d * 58, 74, 33, 0x3A7D2E, op: 0.25);
    a.c(340 + d * 58, 68, 26, 0x6FC15A);
  }
  _kurbagaEye(a, 282, 66, 21);
  _kurbagaEye(a, 398, 66, 21);
  if (happy) {
    // Mutlu kısık göz kapağı
    a.p('M258 66 Q282 36 306 66 Z', 0x5DB04A);
    a.p('M374 66 Q398 36 422 66 Z', 0x5DB04A);
    a.s('M262 68 Q282 52 302 68 M378 68 Q398 52 418 68', 0x2C5A22, 3);
  }
  // Benekler
  a.c(318, 108, 6, 0x4A9A3C, op: 0.8);
  a.c(364, 104, 8, 0x4A9A3C, op: 0.8);
  a.c(340, 92, 5, 0x4A9A3C, op: 0.8);
  a.o(342, 154, 66, 38, 0x8AD36F, op: 0.55);
  // Burun delikleri
  a.c(330, 130, 3.2, 0x2C5A22);
  a.c(350, 130, 3.2, 0x2C5A22);
  a.cheeks(150, 0.5);
  if (happy) {
    a.p('M262 162 Q340 224 418 162 Q340 176 262 162 Z', 0x5A1F22);
    // Dil dışarıda
    a.p('M322 180 Q340 188 358 180 L358 214 Q340 244 322 214 Z', 0xF0607D);
    a.s('M340 186 V220', 0xC73F5D, 2.5);
  } else {
    a.s('M262 162 Q340 196 418 162', 0x2C5A22, 4);
    a.s('M262 162 q-6 -4 -10 -10 M418 162 q6 -4 10 -10', 0x2C5A22, 3);
  }
}

// ignore: unused_element
void _kurbagaB(Art a, bool happy) {
  a.box(0x5DB04A, 0x8AD36F, 0x3A7D2E);
  for (final d in const [-1, 1]) {
    a.c(340 + d * 30, 88, 20, 0x5DB04A);
    a.c(340 + d * 30, 86, 15, 0x6FC15A);
  }
  _kurbagaEye(a, 310, 86, 13);
  _kurbagaEye(a, 370, 86, 13);
  if (happy) {
    a.p('M296 86 Q310 68 324 86 Z', 0x5DB04A);
    a.p('M356 86 Q370 68 384 86 Z', 0x5DB04A);
    a.s('M298 88 Q310 76 322 88 M358 88 Q370 76 382 88', 0x2C5A22, 2.5);
  }
  a.c(332, 114, 2.6, 0x2C5A22);
  a.c(348, 114, 2.6, 0x2C5A22);
  a.o(298, 132, 8, 5, 0xED93B1, op: 0.5);
  a.o(382, 132, 8, 5, 0xED93B1, op: 0.5);
  if (happy) {
    a.p('M298 136 Q340 168 382 136 Q340 144 298 136 Z', 0x5A1F22);
    a.p('M330 148 Q340 152 350 148 L350 164 Q340 178 330 164 Z', 0xF0607D);
  } else {
    a.s('M298 136 Q340 156 382 136', 0x2C5A22, 3);
  }
}
