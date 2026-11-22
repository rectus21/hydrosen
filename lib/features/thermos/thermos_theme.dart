import 'dart:ui';

import 'art.dart';
import 'celebration_style.dart';
import 'themes/pack_doga.dart';
import 'themes/pack_fantastik.dart';
import 'themes/pack_hayvanlar.dart';
import 'themes/pack_yeni1.dart';
import 'themes/pack_yiyecek.dart';
import 'themes/pack_yeni2.dart';
import 'themes/pack_yeni3.dart';

/// Termos biçimi: tasarım taslaklarındaki "Tombul" ve "İnce".
enum ThermosShape {
  chubby('Tombul'),
  slim('İnce');

  const ThermosShape(this.label);
  final String label;
}

typedef BackgroundArt = void Function(Art a);

/// [happy]: hedefe ulaşıldı (kutlama ifadesi: panda güler, kaplan kükrer,
/// çilek kızarır).
typedef CapArt = void Function(Art a, bool happy);

/// Bir tema = renkler + arka plan çizimi + iki biçim için kapak çizimi.
/// Yeni tema eklemek için themes/pack_*.dart dosyalarındaki listeye eklenir
/// ([ThermosTheme.all] hepsini birleştirir).
class ThermosTheme {
  const ThermosTheme({
    required this.id,
    required this.name,
    required this.glass,
    required this.edge,
    required this.water,
    required this.deepWater,
    required this.waterSurface,
    required this.mark,
    required this.label,
    required this.band,
    required this.bandLight,
    required this.background,
    required this.capChubby,
    required this.capSlim,
    this.celebration,
  });

  final String id;
  final String name;
  final Color glass, edge, water, deepWater, waterSurface, mark, label;
  final Color band, bandLight;
  final BackgroundArt background;
  final CapArt capChubby, capSlim;

  /// Kutlama efekti; yalnız 8 özgün tema dışındakiler için kullanılır
  /// (verilmezse damla halkası).
  final CelebrationStyle? celebration;

  static ThermosTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => classic);

  static const classic = ThermosTheme(
    id: 'klasik',
    name: 'Klasik',
    glass: Color(0xFFB5D4F4),
    edge: Color(0xFF185FA5),
    water: Color(0xFF378ADD),
    deepWater: Color(0xFF0C447C),
    waterSurface: Color(0xFFB5D4F4),
    mark: Color(0xFF0C447C),
    label: Color(0xFF0C447C),
    band: Color(0xFF888780),
    bandLight: Color(0xFFB4B2A9),
    background: _klasikBg,
    capChubby: _klasikA,
    capSlim: _klasikB,
  );

  static const strawberry = ThermosTheme(
    id: 'cilek',
    name: 'Çilek',
    glass: Color(0xFFF4C0D1),
    edge: Color(0xFF993556),
    water: Color(0xFFE24B4A),
    deepWater: Color(0xFF791F1F),
    waterSurface: Color(0xFFF7C1C1),
    mark: Color(0xFF72243E),
    label: Color(0xFF72243E),
    band: Color(0xFFD4537E),
    bandLight: Color(0xFFED93B1),
    background: _cilekBg,
    capChubby: _cilekA,
    capSlim: _cilekB,
  );

  static const tiger = ThermosTheme(
    id: 'kaplan',
    name: 'Kaplan',
    glass: Color(0xFFFAC775),
    edge: Color(0xFF854F0B),
    water: Color(0xFF1D9E75),
    deepWater: Color(0xFF085041),
    waterSurface: Color(0xFF9FE1CB),
    mark: Color(0xFF412402),
    label: Color(0xFF633806),
    band: Color(0xFF2C2C2A),
    bandLight: Color(0xFF5F5E5A),
    background: _kaplanBg,
    capChubby: _kaplanA,
    capSlim: _kaplanB,
  );

  static const panda = ThermosTheme(
    id: 'panda',
    name: 'Panda',
    glass: Color(0xFFE1F5EE),
    edge: Color(0xFF0F6E56),
    water: Color(0xFF85B7EB),
    deepWater: Color(0xFF185FA5),
    waterSurface: Color(0xFFE6F1FB),
    mark: Color(0xFF085041),
    label: Color(0xFF085041),
    band: Color(0xFF2C2C2A),
    bandLight: Color(0xFF5F5E5A),
    background: _pandaBg,
    capChubby: _pandaA,
    capSlim: _pandaB,
  );

  static const unicorn = ThermosTheme(
    id: 'tekboynuz',
    name: 'Tekboynuz',
    glass: Color(0xFFE6DCFA),
    edge: Color(0xFF8A68CC),
    water: Color(0xFFB79CF0),
    deepWater: Color(0xFF7352C4),
    waterSurface: Color(0xFFF3E9FF),
    mark: Color(0xFF4A3380),
    label: Color(0xFF4A3380),
    band: Color(0xFFF59BC6),
    bandLight: Color(0xFFFAC8E0),
    background: _unicornBg,
    capChubby: _unicornA,
    capSlim: _unicornB,
  );

  static const astronaut = ThermosTheme(
    id: 'astronot',
    name: 'Astronot',
    glass: Color(0xFFB5D4F4),
    edge: Color(0xFF85B7EB),
    water: Color(0xFF5DCAA5),
    deepWater: Color(0xFF0F6E56),
    waterSurface: Color(0xFFE1F5EE),
    mark: Color(0xFF042C53),
    label: Color(0xFFE6F1FB),
    band: Color(0xFFB4B2A9),
    bandLight: Color(0xFFF1EFE8),
    background: _uzayBg,
    capChubby: _uzayA,
    capSlim: _uzayB,
  );

  static const camp = ThermosTheme(
    id: 'kamp',
    name: 'Kamp',
    glass: Color(0xFFD3D1C7),
    edge: Color(0xFF444441),
    water: Color(0xFF378ADD),
    deepWater: Color(0xFF0C447C),
    waterSurface: Color(0xFFB5D4F4),
    mark: Color(0xFF2C2C2A),
    label: Color(0xFF2C2C2A),
    band: Color(0xFF27500A),
    bandLight: Color(0xFF3B6D11),
    background: _kampBg,
    capChubby: _kampA,
    capSlim: _kampB,
  );

  static const all = [
    classic,
    strawberry,
    tiger,
    panda,
    unicorn,
    astronaut,
    camp,
    ...hayvanlarThemes,
    ...dogaThemes,
    ...yiyecekThemes,
    ...fantastikThemes,
    ...yeni1Themes,
    ...yeni2Themes,
    ...yeni3Themes,
  ];
}

const _full = 'M120 8 H560 V512 H120 Z';

// --- Klasik ----------------------------------------------------------------

void _klasikBg(Art a) {
  a.p(_full, 0xE6F1FB);
  // Büyük termosun gövdesi merkezde sakin gökyüzüne oturur; bütün sahne
  // ayrıntıları iki yanda bir çerçeve gibi kalır.
  a.c(178, 86, 42, 0xFFF2B8);
  a.c(178, 86, 30, 0xFFD66B, op: 0.42);
  a.p(
    'M120 350 L196 276 L250 336 L304 258 L362 330 L426 282 L500 344 L560 306 V512 H120 Z',
    0xD5E8F7,
  );
  a.p(
    'M120 386 L190 326 L248 374 L304 318 L366 378 L430 326 L500 384 L560 350 V512 H120 Z',
    0xB9D9F2,
  );
  a.p('M120 420 Q230 390 340 420 Q450 450 560 410 V512 H120 Z', 0x9CC9EB);
  a.p(
    'M120 460 Q240 440 340 462 Q440 484 560 456 V512 H120 Z',
    0x85B7EB,
    op: 0.72,
  );
  for (final b in const <(num, num, num)>[
    (148, 158, 8),
    (188, 204, 13),
    (516, 108, 10),
    (532, 188, 17),
    (154, 286, 11),
    (520, 278, 8),
  ]) {
    a.p(
      'M${b.$1} ${b.$2 - b.$3 * 1.4} Q${b.$1 + b.$3} ${b.$2 - b.$3 * 0.15} ${b.$1} ${b.$2 + b.$3} '
      'Q${b.$1 - b.$3} ${b.$2 - b.$3 * 0.15} ${b.$1} ${b.$2 - b.$3 * 1.4} Z',
      0x63A9DB,
      op: 0.78,
    );
    a.c(b.$1 - b.$3 * 0.25, b.$2 - b.$3 * 0.28, b.$3 * 0.2, w, op: 0.72);
  }
}

void _klasikA(Art a, bool happy) {
  a.p(
    'M262 204 L262 110 Q262 66 306 62 L374 62 Q418 66 418 110 L418 204 Z',
    0x888780,
  );
  a.p('M262 204 L262 110 Q262 70 296 63 Q280 84 280 114 L280 204 Z', 0xD3D1C7);
  a.p('M394 66 Q418 76 418 110 L418 204 L400 204 Z', 0x5F5E5A);
  for (var i = 0; i < 11; i++) {
    a.p('M${290 + i * 10} 70 l3 0 l0 130 l-3 0 Z', 0xB4B2A9);
  }
}

void _klasikB(Art a, bool happy) {
  a.box(0x888780, 0xD3D1C7, 0x5F5E5A);
  for (var i = 0; i < 8; i++) {
    a.p('M${304 + i * 10} 98 l3 0 l0 62 l-3 0 Z', 0xB4B2A9);
  }
}

// --- Çilek -----------------------------------------------------------------

void _cilekBg(Art a) {
  a.p(_full, 0xFFF1F5);
  a.c(492, 86, 42, 0xFFE3A1);
  a.c(492, 86, 29, 0xFFD66B, op: 0.48);
  a.p(
    'M120 344 Q206 280 286 344 Q370 286 456 344 Q514 306 560 334 V512 H120 Z',
    0xE4F1C8,
  );
  a.p(
    'M120 400 Q200 370 280 395 Q380 425 460 390 Q520 370 560 385 V512 H120 Z',
    0xBFDFA8,
  );
  a.p(
    'M120 450 Q220 430 330 452 Q450 470 560 445 V512 H120 Z',
    0xF3B6C9,
    op: 0.82,
  );
  for (final s in const [
    [170, 80, 1.0],
    [510, 110, 0.8],
    [180, 250, 0.7],
    [505, 280, 1.0],
    [160, 370, 0.6],
  ]) {
    final x = s[0], y = s[1], q = s[2];
    a.p(
      'M$x ${y - 14 * q} Q${x + 18 * q} ${y - 14 * q} ${x + 15 * q} ${y + 4 * q} '
      'Q${x + 8 * q} ${y + 20 * q} $x ${y + 20 * q} Q${x - 8 * q} ${y + 20 * q} '
      '${x - 15 * q} ${y + 4 * q} Q${x - 18 * q} ${y - 14 * q} $x ${y - 14 * q} Z',
      0xE24B4A,
    );
    a.leaves(x, y - 12 * q, [
      (-14 * q, 0x639922),
      (14 * q, 0x639922),
      (0, 0x3B6D11),
    ]);
  }
  // Küçük çiçekler alt kenarda kalır; büyük termosun camını kirletmez.
  for (final f in const <(num, num)>[
    (150, 432),
    (198, 456),
    (484, 430),
    (526, 462),
  ]) {
    for (var i = 0; i < 5; i++) {
      final dx = (i.isEven ? 1 : -1) * (4 + (i % 3) * 2);
      final dy = i < 2 ? -5 : 4;
      a.c(f.$1 + dx, f.$2 + dy, 5, 0xFFF7FA);
    }
    a.c(f.$1, f.$2, 4, 0xFFD66B);
  }
}

void _cilekA(Art a, bool happy) {
  a.p(
    'M340 206 Q240 200 250 120 Q262 60 340 54 Q418 60 430 120 Q440 200 340 206 Z',
    0xE24B4A,
  );
  a.p(
    'M340 206 Q240 200 250 120 Q260 66 320 56 Q276 88 274 134 Q276 190 340 206 Z',
    0xF09595,
    op: 0.55,
  );
  a.p(
    'M386 66 Q428 90 430 128 Q432 190 358 205 Q410 176 412 128 Q412 92 386 66 Z',
    0xA32D2D,
  );
  a.eye(310, 132, 12);
  a.eye(370, 132, 12);
  a.cheeks(156, happy ? 1 : 0.7);
  if (happy) {
    a.p('M324 154 Q340 176 356 154 Z', k);
    a.o(340, 165, 6, 3, 0xED93B1);
  } else {
    a.s('M328 156 Q340 168 352 156', k, 3);
  }
  a.seeds(const [
    [284, 100],
    [396, 100],
    [300, 182],
    [380, 182],
    [340, 90],
    [268, 140],
    [412, 140],
    [340, 192],
  ]);
  a.leaves(340, 64, const [
    (-66, 0x3B6D11),
    (66, 0x3B6D11),
    (-36, 0x639922),
    (36, 0x639922),
    (0, 0x97C459),
  ]);
  a.p('M336 30 Q342 20 348 26 L344 56 L337 56 Z', 0x27500A);
}

void _cilekB(Art a, bool happy) {
  a.box(0xE24B4A, 0xF09595, 0xA32D2D);
  a.seeds(const [
    [300, 124],
    [320, 112],
    [340, 128],
    [360, 112],
    [380, 124],
    [310, 148],
    [330, 140],
    [350, 148],
    [370, 140],
  ]);
  a.leaves(340, 94, const [
    (-40, 0x3B6D11),
    (40, 0x3B6D11),
    (-18, 0x639922),
    (18, 0x639922),
  ]);
}

// --- Kaplan ----------------------------------------------------------------

void _kaplanBg(Art a) {
  a.p(_full, 0xFAEEDA);
  a.c(470, 110, 70, 0xFAC775);
  a.c(470, 110, 48, 0xEF9F27, op: 0.55);
  a.p(
    'M120 330 Q210 270 300 320 Q380 360 450 300 Q510 260 560 290 V512 H120 Z',
    0xFAC775,
  );
  a.p('M120 400 Q220 350 320 395 Q420 440 560 380 V512 H120 Z', 0xEF9F27);
  a.p('M120 460 Q250 430 360 458 Q470 482 560 450 V512 H120 Z', 0xBA7517);
  for (var i = 0; i < 7; i++) {
    final y = 40 + i * 62;
    a.p(
      'M120 $y Q158 ${y + 10} 190 ${y + 2} Q162 ${y + 18} 120 ${y + 16} Z',
      0x633806,
      op: 0.8,
    );
    a.p(
      'M560 ${y + 30} Q522 ${y + 40} 490 ${y + 32} Q518 ${y + 48} 560 ${y + 46} Z',
      0x633806,
      op: 0.8,
    );
  }
  for (final g in const [
    [200, 470],
    [230, 480],
    [460, 476],
    [490, 468],
  ]) {
    a.p(
      'M${g[0]} ${g[1] + 20} L${g[0] + 4} ${g[1]} L${g[0] + 8} ${g[1] + 20} Z',
      0x854F0B,
    );
  }
}

void _kaplanA(Art a, bool happy) {
  for (final e in const [278, 402]) {
    a.c(e, 72, 26, 0xBA7517);
    a.c(e, 74, 15, 0xF1EFE8);
    a.c(e, 76, 8, 0xED93B1, op: 0.6);
  }
  a.dome(0xEF9F27, 0xFAC775, 0xBA7517);
  for (final d in const [
    'M340 52 Q334 70 340 84 Q346 70 340 52',
    'M314 56 Q308 68 312 78',
    'M366 56 Q372 68 368 78',
    'M246 118 Q266 118 278 128',
    'M434 118 Q414 118 402 128',
    'M250 146 Q268 146 278 154',
    'M430 146 Q412 146 402 154',
  ]) {
    a.s(d, k, 4);
  }
  a.o(340, 166, 62, 40, 0xF1EFE8);
  a.cheeks(156, 0.55);
  a.eye(306, 124, 14);
  a.eye(374, 124, 14);
  a.p(
    'M328 148 Q340 140 352 148 Q348 160 340 162 Q332 160 328 148 Z',
    0xD4537E,
  );
  a.s(
    'M340 162 L340 168 M340 168 Q330 178 320 172 M340 168 Q350 178 360 172',
    k,
    3,
  );
  if (happy) {
    // Kükreme: ağız açılır, dişler görünür.
    a.p('M318 172 Q340 206 362 172 Q340 180 318 172 Z', k);
    a.o(340, 190, 9, 5, 0xE24B4A);
    a.p('M322 174 l4 8 l4 -7 Z', w);
    a.p('M358 174 l-4 8 l-4 -7 Z', w);
  } else {
    a.p('M334 176 Q340 186 346 176 Z', 0xE24B4A);
  }
}

void _kaplanB(Art a, bool happy) {
  for (final (e, d) in const [(300, 1), (380, -1)]) {
    a.p(
      'M${e - 12 * d} 104 Q${e - 14 * d} 80 $e 80 Q${e + 12 * d} 82 ${e + 10 * d} 102 Z',
      0xBA7517,
    );
    a.p(
      'M${e - 6 * d} 100 Q${e - 6 * d} 88 $e 88 Q${e + 6 * d} 88 ${e + 5 * d} 100 Z',
      0xF1EFE8,
    );
  }
  a.box(0xEF9F27, 0xFAC775, 0xBA7517);
  for (final d in const [
    'M340 92 L340 104',
    'M326 94 L328 102',
    'M354 94 L352 102',
    'M286 120 L298 124',
    'M394 120 L382 124',
    'M286 140 L296 142',
    'M394 140 L384 142',
  ]) {
    a.s(d, k, 4);
  }
  a.c(322, 124, 5, k);
  a.c(358, 124, 5, k);
  a.c(320, 122, 1.6, w);
  a.c(356, 122, 1.6, w);
  a.o(340, 146, 22, 13, 0xF1EFE8);
  a.p('M334 138 L346 138 L340 145 Z', 0xD4537E);
  a.s('M340 145 Q334 152 328 149 M340 145 Q346 152 352 149', k, 2);
}

// --- Panda -----------------------------------------------------------------

void _pandaBg(Art a) {
  a.p(_full, 0xE1F5EE);
  a.p('M120 440 Q260 420 380 440 Q500 460 560 430 V512 H120 Z', 0x9FE1CB);
  for (final b in const [
    [150, 10],
    [186, 40],
    [506, 0],
    [536, 30],
  ]) {
    for (var y = b[1] + 10; y < 470; y += 58) {
      a.p('M${b[0] - 8} $y h16 v54 h-16 Z', 0x5DCAA5);
      a.p('M${b[0] - 9} ${y + 52} h18 v5 h-18 Z', 0x1D9E75);
    }
    for (final l in const [
      [1, 90],
      [-1, 200],
      [1, 300],
    ]) {
      a.o(b[0] + l[0] * 22, b[1] + l[1], 20, 6, 0x1D9E75, rot: l[0] * -30);
    }
  }
}

void _pandaA(Art a, bool happy) {
  a.c(280, 74, 26, k);
  a.c(400, 74, 26, k);
  a.dome(w, w, 0xD3D1C7);
  a.o(306, 128, 24, 18, k, rot: -25);
  a.o(374, 128, 24, 18, k, rot: 25);
  a.c(308, 126, 10, w);
  a.c(372, 126, 10, w);
  a.eye(309, 127, 6);
  a.eye(371, 127, 6);
  a.cheeks(160, 0.6);
  a.o(340, 156, 12, 8, k);
  if (happy) {
    // Gülümseme: geniş açık ağız ve dil.
    a.s('M340 164 L340 168', k, 3);
    a.p('M322 168 Q340 192 358 168 Q340 174 322 168 Z', k);
    a.o(340, 180, 6, 3.5, 0xED93B1);
  } else {
    a.s(
      'M340 164 L340 170 M340 170 Q332 178 324 174 M340 170 Q348 178 356 174',
      k,
      3,
    );
  }
}

void _pandaB(Art a, bool happy) {
  a.c(298, 92, 12, k);
  a.c(382, 92, 12, k);
  a.box(w, w, 0xD3D1C7);
  a.o(320, 124, 12, 9, k, rot: -25);
  a.o(360, 124, 12, 9, k, rot: 25);
  a.c(321, 123, 3.5, w);
  a.c(359, 123, 3.5, w);
  a.o(340, 142, 6, 4, k);
  if (happy) {
    a.p('M330 148 Q340 162 350 148 Q340 152 330 148 Z', k);
  } else {
    a.s('M340 146 Q334 152 330 150 M340 146 Q346 152 350 150', k, 2);
  }
}

// --- Tekboynuz -------------------------------------------------------------

const _uniMane = [0xF6A5C8, 0xFFC9A0, 0xFFE58F, 0xA5E6CC, 0x9CCBF5, 0xB79CF0];
const _uniLash = 0x4B2E8F;

/// Dört köşeli, içbükey parıltı yıldızı.
void _sparkle(Art a, num x, num y, num s, int hex, {double op = 1}) {
  final q = s * 0.22;
  a.p(
    'M$x ${y - s} Q${x + q} ${y - q} ${x + s} $y Q${x + q} ${y + q} $x ${y + s} '
    'Q${x - q} ${y + q} ${x - s} $y Q${x - q} ${y - q} $x ${y - s} Z',
    hex,
    op: op,
  );
}

void _cloud(Art a, num x, num y, num sc, {double op = 0.95}) {
  a.o(x + 30 * sc, y + 16 * sc, 56 * sc, 14 * sc, 0xD9CCF5, op: op * 0.5);
  for (final b in const [
    [0, 0, 22],
    [26, -12, 28],
    [58, -2, 22],
    [30, 8, 26],
  ]) {
    a.c(x + b[0] * sc, y + b[1] * sc, b[2] * sc, w, op: op);
  }
}

void _unicornBg(Art a) {
  a.p(_full, 0xE9E2FB);
  a.canvas.drawRect(
    const Rect.fromLTWH(120, 8, 440, 504),
    Paint()
      ..shader = Gradient.linear(
        const Offset(0, 8),
        const Offset(0, 512),
        [
          const Color(0xFFC9D3FA),
          const Color(0xFFEBD9F8),
          const Color(0xFFFCE4EE),
          const Color(0xFFFFF1E4),
        ],
        const [0, 0.45, 0.8, 1],
      ),
  );
  // Gökkuşağı sağ kenarı çerçeveler; büyük termosun camı temiz kalır.
  for (final (i, col) in const [
    0xF7A8B8,
    0xFFD0A8,
    0xFFF0A8,
    0xB5EAD0,
    0xA8D8F7,
    0xCDB8F5,
  ].indexed) {
    a.arcTop(470, 400, 190 - i * 13, col, 14);
  }
  _cloud(a, 168, 96, 0.95);
  _cloud(a, 468, 64, 0.6, op: 0.85);
  _cloud(a, 486, 392, 0.86);
  _cloud(a, 142, 368, 0.7);
  // Ay ve yıldızlar iki yan koridorda; kapağın siluetini bozmaz.
  a.c(174, 188, 31, 0xFFF3C9, op: 0.92);
  a.c(187, 178, 30, 0xDED7FA, op: 0.94);
  for (final star in const <(num, num, num, int)>[
    (146, 44, 7, 0xFFFFFF),
    (210, 142, 5, 0xFFD66B),
    (512, 132, 8, 0xFFFFFF),
    (528, 244, 5, 0xFFD66B),
    (154, 286, 6, 0xFFFFFF),
    (494, 318, 7, 0xFFFFFF),
  ]) {
    _sparkle(a, star.$1, star.$2, star.$3, star.$4, op: 0.9);
  }
  a.p(
    'M120 450 Q214 410 296 448 Q390 408 470 452 Q520 428 560 444 V512 H120 Z',
    0xD7F2E8,
  );
  // Uzak şato yalnız sol kıyıda görünür; temaya hikâye verir.
  a.p(
    'M132 430 V374 H150 V346 L168 374 H180 V326 L198 350 L216 326 V430 Z',
    0xBBA9E8,
    op: 0.75,
  );
  a.p('M142 374 H174 V430 H142 Z M184 350 H210 V430 H184 Z', 0xD5C7F3, op: 0.9);
  a.p(
    'M154 400 Q158 388 162 400 V430 H154 Z M193 382 Q197 370 201 382 V430 H193 Z',
    0x7862B8,
    op: 0.7,
  );
  a.p('M120 468 Q250 440 380 462 Q470 478 560 458 V512 H120 Z', 0xCFF0E3);
  a.p('M120 488 Q260 462 400 484 Q480 498 560 478 V512 H120 Z', 0xF9D2E4);
}

void _horn(Art a, num cx, num tipY, num baseY, num half) {
  final h = baseY - tipY;
  a.p('M$cx $tipY L${cx + half} $baseY L${cx - half} $baseY Z', 0xFFD66B);
  a.p(
    'M$cx $tipY L${cx + half} $baseY L${cx + half * 0.15} $baseY Z',
    0xE9A93A,
    op: 0.55,
  );
  for (var i = 1; i <= 4; i++) {
    final y = tipY + h * i / 5;
    final hw = half * i / 5;
    a.s('M${cx - hw} ${y + 5} L${cx + hw} ${y - 5}', 0xD98E1F, 2.4);
  }
  a.s(
    'M${cx - half * 0.38} ${baseY - 5} L${cx - half * 0.06} ${tipY + 10}',
    w,
    2.6,
  );
  _sparkle(a, cx + half * 2, tipY + 6, half * 0.75, w);
}

/// Yele: tepeden iki yana akan altı pastel şerit (d 5 = en dış).
void _maneChubby(Art a) {
  for (var d = 5; d >= 0; d--) {
    final col = _uniMane[d];
    for (final m in const [false, true]) {
      String x(num v) => '${m ? 680 - v : v}';
      a.s(
        'M${x(314 - d * 2)} ${96 - d} '
        'Q${x(210 - d * 9)} 90 ${x(190 - d * 9)} 160 '
        'Q${x(178 - d * 9)} 218 ${x(204 - d * 8)} ${246 + d * 2}',
        col,
        17,
      );
    }
  }
}

void _maneSlim(Art a) {
  for (var d = 5; d >= 0; d--) {
    final col = _uniMane[d];
    for (final m in const [false, true]) {
      String x(num v) => '${m ? 680 - v : v}';
      a.s(
        'M${x(308 - d)} ${106 - d} '
        'Q${x(262 - d * 6)} 100 ${x(262 - d * 6)} 142 '
        'Q${x(262 - d * 6)} 186 ${x(292 - d)} ${196 + d}',
        col,
        10,
      );
    }
  }
}

void _uniEye(Art a, num x, num y, num r, int dir, bool happy) {
  if (happy) {
    a.s(
      'M${x - r} ${y + r * 0.3} Q$x ${y - r * 1.5} ${x + r} ${y + r * 0.3}',
      _uniLash,
      r * 0.4,
    );
  } else {
    a.o(x, y, r, r * 1.25, _uniLash);
    a.o(x, y + r * 0.5, r * 0.72, r * 0.55, 0x9A7BE8);
    a.c(x - r * 0.3, y - r * 0.4, r * 0.42, w);
    a.c(x + r * 0.35, y + r * 0.55, r * 0.2, w);
    a.c(x + r * 0.45, y - r * 0.1, r * 0.12, w);
  }
  // Uzun kirpikler (dış üst köşeden).
  final ex = x + dir * r;
  final ey = y - r * (happy ? 0.1 : 0.6);
  a.s(
    'M$ex $ey l${dir * r * 0.7} ${-r * 0.5} '
    'M${ex + dir * r * 0.05} ${ey + r * 0.45} l${dir * r * 0.8} ${-r * 0.1} '
    'M${ex - dir * r * 0.3} ${ey - r * 0.4} l${dir * r * 0.4} ${-r * 0.7}',
    _uniLash,
    r * 0.2,
  );
}

void _unicornA(Art a, bool happy) {
  _maneChubby(a);
  for (final (e, d) in const [(270, 1), (410, -1)]) {
    a.p('M${e - 14 * d} 108 L${e - 14 * d} 52 L${e + 26 * d} 86 Z', w);
    a.p('M${e - 10 * d} 98 L${e - 10 * d} 66 L${e + 14 * d} 86 Z', 0xF9C4DA);
  }
  _horn(a, 340, 10, 76, 19);
  a.dome(w, w, 0xE3DAF6);
  // Perçem: boynuzun dibinde pastel kıvrımlar.
  a.c(322, 68, 13, 0xF6A5C8);
  a.c(358, 68, 13, 0xB79CF0);
  a.c(340, 74, 13, 0xA5E6CC);
  a.c(306, 82, 9, 0xFFE58F);
  a.c(374, 82, 9, 0x9CCBF5);
  _uniEye(a, 300, 134, 15, -1, happy);
  _uniEye(a, 380, 134, 15, 1, happy);
  a.o(280, 160, 15, 9, 0xF59BC0, op: 0.6);
  a.o(400, 160, 15, 9, 0xF59BC0, op: 0.6);
  a.o(340, 168, 30, 19, 0xFFE3EF);
  a.o(329, 164, 3, 4.5, 0xE58BB0);
  a.o(351, 164, 3, 4.5, 0xE58BB0);
  if (happy) {
    a.p('M324 176 Q340 200 356 176 Z', 0xB5527F);
    a.o(340, 186, 7, 4, 0xF59BC0);
    _sparkle(a, 236, 70, 12, 0xFFD66B);
    _sparkle(a, 452, 96, 9, w);
    _sparkle(a, 222, 150, 8, w);
    _sparkle(a, 462, 168, 12, 0xFFD66B);
  } else {
    a.s('M326 176 Q340 187 354 176', 0xB5527F, 3);
  }
}

void _unicornB(Art a, bool happy) {
  _maneSlim(a);
  for (final (e, d) in const [(296, 1), (384, -1)]) {
    a.p('M${e - 6 * d} 100 L${e - 8 * d} 66 L${e + 16 * d} 90 Z', w);
    a.p('M${e - 4 * d} 94 L${e - 5 * d} 76 L${e + 8 * d} 90 Z', 0xF9C4DA);
  }
  _horn(a, 340, 34, 94, 11);
  a.box(w, w, 0xE3DAF6);
  a.c(326, 92, 9, 0xF6A5C8);
  a.c(354, 92, 9, 0xB79CF0);
  a.c(340, 96, 9, 0xA5E6CC);
  _uniEye(a, 313, 122, 9, -1, happy);
  _uniEye(a, 367, 122, 9, 1, happy);
  a.o(298, 142, 9, 5.5, 0xF59BC0, op: 0.6);
  a.o(382, 142, 9, 5.5, 0xF59BC0, op: 0.6);
  a.o(340, 144, 15, 10, 0xFFE3EF);
  a.o(334, 142, 2, 2.8, 0xE58BB0);
  a.o(346, 142, 2, 2.8, 0xE58BB0);
  if (happy) {
    a.p('M331 150 Q340 164 349 150 Z', 0xB5527F);
    _sparkle(a, 262, 96, 8, 0xFFD66B);
    _sparkle(a, 422, 120, 7, w);
  } else {
    a.s('M332 151 Q340 157 348 151', 0xB5527F, 2.2);
  }
}

// --- Astronot --------------------------------------------------------------

const visorChubby =
    'M282 112 Q282 92 304 90 L376 90 Q398 92 398 112 L398 158 Q398 182 374 182 L306 182 Q282 182 282 158 Z';
const visorSlim =
    'M292 112 Q292 104 300 104 L380 104 Q388 104 388 112 L388 138 Q388 146 380 146 L300 146 Q292 146 292 138 Z';

void _uzayBg(Art a) {
  a.p(_full, 0x042C53);
  for (var i = 0; i < 60; i++) {
    final x = 125 + a.rnd() * 430;
    final y = 12 + a.rnd() * 495;
    final r = a.rnd() * 1.8 + 0.6;
    final op = 0.5 + a.rnd() * 0.5;
    a.c(x, y, r, w, op: op);
  }
  a.c(190, 110, 44, 0x7F77DD);
  a.s('M154 96 Q180 86 214 98', 0x534AB7, 6);
  a.o(190, 114, 72, 14, 0xCECBF6, rot: -15, strokeWidth: 4);
  a.c(500, 380, 38, 0xD3D1C7);
  for (final c in const [
    [488, 370, 8],
    [512, 392, 6],
    [498, 398, 4],
  ]) {
    a.c(c[0], c[1], c[2], 0xB4B2A9);
  }
  a.s('M460 60 L520 30', w, 2);
  a.c(520, 30, 3, w);
  a.p('M120 470 Q300 440 560 480 V512 H120 Z', 0x0C447C);
}

void _uzayA(Art a, bool happy) {
  a.c(250, 140, 14, 0xB4B2A9);
  a.c(430, 140, 14, 0xB4B2A9);
  a.dome(0xF1EFE8, w, 0xB4B2A9);
  a.p(visorChubby, 0x26215C);
  a.p('M296 104 L318 104 L300 150 L292 150 Z', w, op: 0.35);
  a.p('M328 104 L336 104 L318 150 L312 150 Z', w, op: 0.2);
  a.c(372, 160, 6, 0x5DCAA5, op: 0.7);
  a.s('M340 52 L340 26', 0x888780, 3);
  a.c(340, 22, 7, 0xE24B4A);
  a.s('M304 196 L376 196', 0x185FA5, 4);
}

void _uzayB(Art a, bool happy) {
  a.box(0xF1EFE8, w, 0xB4B2A9);
  a.p(visorSlim, 0x26215C);
  a.p('M302 110 L316 110 L306 140 L298 140 Z', w, op: 0.35);
  a.s('M368 90 L368 72', 0x888780, 2.5);
  a.c(368, 68, 5, 0xE24B4A);
}

// --- Kamp ------------------------------------------------------------------

void _kampBg(Art a) {
  a.p(_full, 0xFAECE7);
  a.c(440, 150, 46, 0xF0997B);
  a.p(
    'M120 330 L210 200 L280 280 L360 170 L450 290 L520 230 L560 270 V512 H120 Z',
    0x888780,
  );
  a.p('M330 196 L360 170 L392 214 L372 206 L360 216 L346 204 Z', w);
  a.p(
    'M120 400 L200 320 L270 380 L350 300 L440 380 L520 330 L560 360 V512 H120 Z',
    0x5F5E5A,
  );
  for (final t in const [
    [150, 420],
    [180, 440],
    [480, 420],
    [515, 440],
    [545, 425],
  ]) {
    a.p(
      'M${t[0]} ${t[1] - 60} L${t[0] + 20} ${t[1]} L${t[0] - 20} ${t[1]} Z',
      0x27500A,
    );
    a.p(
      'M${t[0]} ${t[1] - 80} L${t[0] + 14} ${t[1] - 36} L${t[0] - 14} ${t[1] - 36} Z',
      0x3B6D11,
    );
  }
  // Küçük ateş ve çadır kenarlarda kalır; merkezdeki büyük termos örtülmez.
  a.p('M142 456 L178 406 L214 456 Z', 0xD8C8A8);
  a.p('M178 406 L178 456 H214 Z', 0xB49A73);
  a.p('M171 456 L178 430 L185 456 Z', 0x5B4634);
  a.s('M476 464 L524 438 M480 438 L524 464', 0x5B4634, 5);
  a.p(
    'M488 450 Q474 428 494 412 Q490 434 504 442 Q520 425 516 466 Q500 480 488 450 Z',
    0xF28C28,
  );
  a.p(
    'M496 452 Q488 438 500 428 Q500 442 508 448 Q514 456 504 466 Q496 464 496 452 Z',
    0xFFD15C,
  );
  a.p('M120 460 H560 V512 H120 Z', 0x444441);
}

void _compass(Art a, num cx, num cy, num r) {
  a.c(cx, cy, r, 0xF1EFE8);
  a.c(cx, cy, r * 0.8, 0x2C2C2A);
  a.p(
    'M$cx ${cy - r * 0.67} L${cx + r * 0.2} $cy L$cx ${cy + r * 0.67} L${cx - r * 0.2} $cy Z',
    0xE24B4A,
  );
  a.p(
    'M$cx $cy L${cx + r * 0.2} $cy L$cx ${cy + r * 0.67} L${cx - r * 0.2} $cy Z',
    w,
  );
}

void _kampA(Art a, bool happy) {
  a.dome(0x3B6D11, 0x639922, 0x27500A);
  a.p('M248 168 Q340 214 432 168 L436 186 Q340 232 244 186 Z', 0x27500A);
  for (var i = 0; i < 14; i++) {
    final x = 258 + i * 12.5;
    a.p('M$x ${176 - (7 - i).abs() * 0.3} l3 0 l0 18 l-3 0 Z', 0x173404);
  }
  _compass(a, 340, 118, 30);
  a.c(340, 118, 3, 0x888780);
  a.o(340, 46, 18, 24, 0x888780, strokeWidth: 5);
  a.s('M340 68 L340 54', 0x888780, 5);
}

void _kampB(Art a, bool happy) {
  a.box(0x3B6D11, 0x639922, 0x27500A);
  for (var i = 0; i < 9; i++) {
    a.p('M${292 + i * 11} 150 l3 0 l0 12 l-3 0 Z', 0x173404);
  }
  _compass(a, 340, 122, 16);
}
