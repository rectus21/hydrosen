import 'dart:ui';

import 'art.dart';
import 'celebration_style.dart';
import 'themes/pack_doga.dart';
import 'themes/pack_fantastik.dart';
import 'themes/pack_hayvanlar.dart';
import 'themes/pack_yiyecek.dart';

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
    glass: Color(0xFFCECBF6),
    edge: Color(0xFF534AB7),
    water: Color(0xFFAFA9EC),
    deepWater: Color(0xFF534AB7),
    waterSurface: Color(0xFFEEEDFE),
    mark: Color(0xFF3C3489),
    label: Color(0xFF3C3489),
    band: Color(0xFFED93B1),
    bandLight: Color(0xFFF4C0D1),
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

  static const botanic = ThermosTheme(
    id: 'botanik',
    name: 'Botanik',
    glass: Color(0xFFEAF3DE),
    edge: Color(0xFF3B6D11),
    water: Color(0xFF5DCAA5),
    deepWater: Color(0xFF0F6E56),
    waterSurface: Color(0xFFE1F5EE),
    mark: Color(0xFF27500A),
    label: Color(0xFF27500A),
    band: Color(0xFFBA7517),
    bandLight: Color(0xFFEF9F27),
    background: _botanikBg,
    capChubby: _botanikA,
    capSlim: _botanikB,
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
    botanic,
    camp,
    ...hayvanlarThemes,
    ...dogaThemes,
    ...yiyecekThemes,
    ...fantastikThemes,
  ];
}

const _full = 'M120 8 H560 V512 H120 Z';

// --- Klasik ----------------------------------------------------------------

void _klasikBg(Art a) {
  a.p(_full, 0xE6F1FB);
  a.p('M120 420 Q230 390 340 420 Q450 450 560 410 V512 H120 Z', 0xB5D4F4);
  a.p(
    'M120 460 Q240 440 340 462 Q440 484 560 456 V512 H120 Z',
    0x85B7EB,
    op: 0.6,
  );
  for (final b in const [
    [170, 90, 18],
    [200, 150, 8],
    [505, 70, 22],
    [480, 140, 10],
    [160, 260, 12],
    [520, 250, 16],
    [190, 350, 7],
    [500, 340, 9],
  ]) {
    a.c(b[0], b[1], b[2], 0xB5D4F4);
    a.c(b[0] - b[2] * 0.35, b[1] - b[2] * 0.35, b[2] * 0.25, w);
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
  a.p(_full, 0xFBEAF0);
  a.p(
    'M120 400 Q200 370 280 395 Q380 425 460 390 Q520 370 560 385 V512 H120 Z',
    0xF4C0D1,
  );
  a.p(
    'M120 450 Q220 430 330 452 Q450 470 560 445 V512 H120 Z',
    0xED93B1,
    op: 0.6,
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
  for (var i = 0; i < 26; i++) {
    final x = 130 + a.rnd() * 420;
    final y = 20 + a.rnd() * 360;
    a.c(x, y, 2.5, 0xF4C0D1);
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

void _unicornBg(Art a) {
  a.p(_full, 0xEEEDFE);
  for (final (col, r) in const [
    (0xED93B1, 150),
    (0xFAC775, 134),
    (0x9FE1CB, 118),
    (0xAFA9EC, 102),
  ]) {
    a.arcTop(280, 512, r, col, 14);
  }
  for (final cl in const [
    [180, 90],
    [480, 70],
    [500, 300],
  ]) {
    for (final b in const [
      [0, 0, 22],
      [22, -8, 26],
      [46, 0, 20],
      [22, 8, 22],
    ]) {
      a.c(cl[0] + b[0], cl[1] + b[1], b[2], w);
    }
  }
  for (var i = 0; i < 14; i++) {
    final x = 140 + a.rnd() * 400;
    final y = 30 + a.rnd() * 380;
    final s = 4 + a.rnd() * 5;
    a.p(
      'M$x ${y - s} L${x + s * 0.3} ${y - s * 0.3} L${x + s} $y '
      'L${x + s * 0.3} ${y + s * 0.3} L$x ${y + s} L${x - s * 0.3} ${y + s * 0.3} '
      'L${x - s} $y L${x - s * 0.3} ${y - s * 0.3} Z',
      0xFAC775,
    );
  }
}

void _unicornA(Art a, bool happy) {
  for (final (e, d) in const [(280, 1), (400, -1)]) {
    a.p('M${e - 16 * d} 96 L${e + 2 * d} 44 L${e + 20 * d} 92 Z', w);
    a.p('M${e - 6 * d} 88 L${e + 2 * d} 58 L${e + 10 * d} 86 Z', 0xF4C0D1);
  }
  a.dome(w, w, 0xCECBF6);
  for (final m in const [
    [262, 112, 20, 0xED93B1],
    [270, 84, 22, 0xAFA9EC],
    [296, 62, 22, 0x9FE1CB],
    [248, 142, 16, 0xFAC775],
    [322, 52, 16, 0xED93B1],
    [256, 170, 14, 0xAFA9EC],
  ]) {
    a.c(m[0], m[1], m[2], m[3]);
  }
  a.p('M326 64 L340 4 L354 64 Z', 0xFAC775);
  for (final s in const [
    [16, 30],
    [26, 46],
    [38, 58],
  ]) {
    a.s(
      'M${340 - s[0] / 2.4} ${s[1]} L${340 + s[0] / 2.4} ${s[1] - 6}',
      0xBA7517,
      2,
    );
  }
  a.s('M294 128 Q306 138 318 128 M362 128 Q374 138 386 128', k, 3.5);
  a.s('M294 128 l-6 -4 M300 134 l-4 5 M386 128 l6 -4 M380 134 l4 5', k, 2);
  a.cheeks(152, 0.7);
  a.s('M330 160 Q340 170 350 160', k, 3);
  a.o(330, 148, 2, 3, 0xAFA9EC);
  a.o(350, 148, 2, 3, 0xAFA9EC);
}

void _unicornB(Art a, bool happy) {
  a.box(w, w, 0xCECBF6);
  for (final m in const [
    [296, 96, 0xED93B1],
    [312, 92, 0xAFA9EC],
    [328, 90, 0x9FE1CB],
    [352, 90, 0xFAC775],
    [368, 92, 0xED93B1],
    [384, 96, 0xAFA9EC],
  ]) {
    a.c(m[0], m[1], 10, m[2]);
  }
  a.p('M330 90 L340 40 L350 90 Z', 0xFAC775);
  a.s('M322 128 Q330 134 338 128 M342 128 Q350 134 358 128', k, 2.5);
  a.o(310, 142, 8, 5, 0xED93B1, op: 0.7);
  a.o(370, 142, 8, 5, 0xED93B1, op: 0.7);
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

// --- Botanik ---------------------------------------------------------------

void _botanikBg(Art a) {
  a.p(_full, 0xF1EFE8);
  final arch = Path()
    ..moveTo(190, 512)
    ..lineTo(190, 230)
    ..arcToPoint(const Offset(490, 230), radius: const Radius.circular(150))
    ..lineTo(490, 512)
    ..close();
  a.raw(arch, 0xF0997B, op: 0.55);
  a.p('M120 470 H560 V512 H120 Z', 0xD3D1C7);
  for (final b in const [
    [150, 60, 1],
    [530, 120, -1],
    [160, 300, 1],
    [520, 330, -1],
  ]) {
    final s = b[2];
    a.s(
      'M${b[0]} ${b[1]} Q${b[0] + 40 * s} ${b[1] + 60} ${b[0] + 20 * s} ${b[1] + 140}',
      0x639922,
      2.5,
    );
    for (var i = 0; i < 6; i++) {
      a.o(
        b[0] + (14 + i * 3) * s,
        b[1] + 18 + i * 20,
        12,
        8,
        i.isOdd ? 0x97C459 : 0xC0DD97,
      );
    }
  }
}

void _botanikA(Art a, bool happy) {
  a.dome(0xC68A4E, 0xE0B07A, 0x8F5E2E);
  a.grain(
    262,
    418,
    90,
    200,
    0x8F5E2E,
    clip: Path()
      ..addOval(
        Rect.fromCenter(
          center: const Offset(340, 130),
          width: 192,
          height: 160,
        ),
      ),
  );
  a.c(340, 58, 12, 0x8F5E2E);
  a.c(338, 55, 4, 0xE0B07A);
  a.sprig(300, 150, 1);
  a.sprig(380, 150, -1);
}

void _botanikB(Art a, bool happy) {
  a.box(0xC68A4E, 0xE0B07A, 0x8F5E2E);
  a.grain(288, 392, 104, 164, 0x8F5E2E, clip: a.path(Art.boxBase));
  a.sprig(352, 150, 1);
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
