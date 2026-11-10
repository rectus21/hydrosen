// Fantastik paketi temaları.
//
// YENİ TEMA EKLEME (yalnız bu dosyayı düzenle; başka dosyaya dokunma):
//  1. Aşağıdaki [fantastikThemes] listesine bir `ThermosTheme(...)` ekle.
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
import 'dart:ui';

import '../art.dart';
import '../celebration_style.dart';
import '../thermos_theme.dart';

const List<ThermosTheme> fantastikThemes = [];
