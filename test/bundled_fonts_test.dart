import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart'
    show findFamilyWithVariantAssetPath;
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_family_with_variant.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_variant.dart';
import 'package:hydrosen/app/app_look.dart';
import 'package:hydrosen/app/font_setup.dart';

/// Temalarda kullanılan ağırlıklar (app_look.dart TextTheme + painter'lar).
const _weights = [
  FontWeight.w400,
  FontWeight.w500,
  FontWeight.w600,
  FontWeight.w700,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('her AppFont x ağırlık için gömülü dosya asset listesinde var', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();
    final missing = <String>[];
    for (final font in AppFont.values) {
      for (final w in _weights) {
        final family = font.style(TextStyle(fontWeight: w)).fontFamily!;
        // "Baloo2_600" -> aile + varyant
        final i = family.indexOf('_');
        final fam = family.substring(0, i);
        final variant = GoogleFontsVariant.fromString(family.substring(i + 1));
        final path = findFamilyWithVariantAssetPath(
          GoogleFontsFamilyWithVariant(
            family: fam,
            googleFontsVariant: variant,
          ),
          assets,
          isWeb: false,
        );
        if (path == null) missing.add('${font.family} $w -> $family');
      }
    }
    expect(missing, isEmpty);
  });

  test('gömülü TTF dosyaları pubspec klasöründe ve geçerli', () {
    final files = Directory('google_fonts')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.ttf'));
    expect(files, isNotEmpty);
    for (final f in files) {
      final head = f.readAsBytesSync().sublist(0, 4);
      expect(head, [0, 1, 0, 0], reason: f.path);
    }
    expect(File('pubspec.yaml').readAsStringSync(), contains('google_fonts/'));
  });

  test('her ailenin OFL lisansı asset olarak var', () async {
    for (final path in bundledFontLicenses.values) {
      expect(await rootBundle.loadString(path), contains('SIL OPEN FONT'));
    }
    expect(
      bundledFontLicenses.keys.toSet(),
      AppFont.values.map((f) => f.family).toSet(),
    );
  });

  testWidgets('gömülü yazı tipleri ağsız yüklenir', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    for (final font in AppFont.values) {
      for (final w in _weights) {
        font.style(TextStyle(fontWeight: w));
      }
    }
    await tester.runAsync(GoogleFonts.pendingFonts);
  });
}
