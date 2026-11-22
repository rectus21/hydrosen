import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/font_setup.dart';
import 'features/thermos/wolf_artwork.dart';
import 'features/thermos/illustrated_artwork.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpBundledFonts();
  await WolfArtwork.load();
  await IllustratedArtwork.load();
  runApp(const HydroSenApp());
}
