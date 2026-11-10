import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Testler ağa çıkmaz: Google yazı tipleri indirilmez, metin varsayılan test
/// yazı tipine düşer (aile adı yine temanınkidir). Yazı tipi kuran testler
/// testWidgets içinde çalışır; yükleme denemesi sahte zamanda kalır ve
/// çıktıyı kirletmez.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
