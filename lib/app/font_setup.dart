import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gömülü yazı tipi aileleri ve lisans dosyaları (google_fonts/LICENSES).
const bundledFontLicenses = <String, String>{
  'Alegreya': 'google_fonts/LICENSES/Alegreya-OFL.txt',
  'Baloo 2': 'google_fonts/LICENSES/Baloo2-OFL.txt',
  'Chakra Petch': 'google_fonts/LICENSES/ChakraPetch-OFL.txt',
  'Cinzel': 'google_fonts/LICENSES/Cinzel-OFL.txt',
  'Grandstander': 'google_fonts/LICENSES/Grandstander-OFL.txt',
  'Kalam': 'google_fonts/LICENSES/Kalam-OFL.txt',
  'Nunito': 'google_fonts/LICENSES/Nunito-OFL.txt',
  'Pirata One': 'google_fonts/LICENSES/PirataOne-OFL.txt',
  'Quicksand': 'google_fonts/LICENSES/Quicksand-OFL.txt',
};

/// Yazı tiplerini yalnız uygulama paketinden yükler (çevrimdışı, Google'a
/// istek yok) ve OFL lisanslarını uygulamanın lisans sayfasına ekler.
void setUpBundledFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    for (final e in bundledFontLicenses.entries) {
      yield LicenseEntryWithLineBreaks([e.key], await rootBundle.loadString(e.value));
    }
  });
}
