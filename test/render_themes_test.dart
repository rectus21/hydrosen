// Atılabilir görsel doğrulama: ana ekran düzenini (ThemeScene + termos +
// kutlama katmanı, 390x844) kurar ve kareleri PNG olarak kaydeder.
//
// Varsayılan olarak ATLANIR. Çalıştırmak için:
//   RENDER_THEMES=1 flutter test test/render_themes_test.dart
// Çıktı: <vault>/HydroSen/02-Design/yeni-temalar/render/
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/features/home/home_sections.dart' show ThemeSection;
import 'package:hydrosen/features/settings/settings_controller.dart';
import 'package:hydrosen/app/theme_scene.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydrosen/features/home/home_screen.dart'
    show kThermosDrop, kThermosZoom;
import 'package:hydrosen/features/thermos/celebration_overlay.dart';
import 'package:hydrosen/features/thermos/celebrations/fx_sprites.dart';
import 'package:hydrosen/features/thermos/illustrated_artwork.dart';
import 'package:hydrosen/features/thermos/thermos_painter.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:hydrosen/features/thermos/thermos_view.dart';

const _outDir =
    r'C:\Users\PC\Documents\Obsidian Vault\HydroSen\02-Design\yeni-temalar\render';

final _enabled = Platform.environment.containsKey('RENDER_THEMES');

void main() {
  testWidgets(
    'karaejderha kareleri',
    (tester) async {
      await _run(tester, 'karaejderha', const [
        ('intro_015', 390),
        ('intro_035', 520),
        ('intro_055', 520),
        ('intro_080', 650),
      ], loopAfter: 'loop');
    },
    skip: !_enabled,
  );

  testWidgets(
    'tema ekrani',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() async {
        await _loadFonts();
        await IllustratedArtwork.load();
        await FxSprites.load();
      });
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      Directory(_outDir).createSync(recursive: true);
      final shot = GlobalKey();
      final settings = SettingsController(
        repository: InMemorySettingsRepository(),
      );
      await settings.load();
      settings.setTheme(ThermosTheme.byId('panda'));
      await tester.pumpWidget(
        RepaintBoundary(
          key: shot,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: ThemeScene(
                theme: settings.theme,
                child: SafeArea(
                  child: ThemeSection(
                    settings: settings,
                    onOpenSettings: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      // Kapak PNG'lerinin gerçek zamanlı çözülmesi için bekle.
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 400)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.runAsync(() async {
        final boundary =
            shot.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_outDir/tema_ekrani.png').writeAsBytesSync(
          data!.buffer.asUint8List(),
        );
      });
    },
    skip: !_enabled,
  );

  testWidgets(
    'kedi kareleri',
    (tester) async {
      await _run(tester, 'kedi', const [], rest: true);
      await _run(tester, 'kedi', const [
        ('intro_030', 780),
        ('intro_060', 780),
      ], loopAfter: 'loop');
    },
    skip: !_enabled,
  );

  testWidgets(
    'pofuduk kareleri',
    (tester) async {
      await _run(tester, 'pofuduk', const [], rest: true);
      await _run(tester, 'pofuduk', const [
        ('intro_030', 780),
        ('intro_060', 780),
      ], loopAfter: 'loop');
    },
    skip: !_enabled,
  );

  testWidgets(
    'limon kareleri',
    (tester) async {
      await _run(tester, 'limon', const [], rest: true);
    },
    skip: !_enabled,
  );

  testWidgets(
    'limon intro',
    (tester) async {
      await _run(tester, 'limon', const [
        ('intro_015', 600),
        ('intro_030', 600),
        ('intro_050', 800),
        ('intro_065', 600),
        ('intro_090', 1000),
      ], loopAfter: 'loop');
    },
    skip: !_enabled,
  );

  testWidgets(
    'okyanus kareleri',
    (tester) async {
      await _run(tester, 'okyanus', const [
        ('intro_010', 400),
        ('intro_030', 800),
        ('intro_045', 600),
        ('intro_065', 800),
        ('intro_080', 600),
      ], loopAfter: 'loop');
    },
    skip: !_enabled,
  );

  testWidgets(
    'yarisarabasi kareleri',
    (tester) async {
      await _run(tester, 'yarisarabasi', const [
        ('intro_050', 1300),
      ]);
    },
    skip: !_enabled,
  );
}

Future<void> _loadFonts() async {
  for (final f in const ['arialbd.ttf']) {
    final file = File('C:\\Windows\\Fonts\\$f');
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    for (final family in const ['Roboto', 'Ahem', '.SF UI Text']) {
      final l = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await l.load();
    }
  }
}

Future<void> _run(
  WidgetTester tester,
  String id,
  List<(String, int)> frames, {
  String? loopAfter,
  bool rest = false,
}) async {
  await tester.runAsync(() async {
    await _loadFonts();
    await IllustratedArtwork.load();
    await FxSprites.load();
  });
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  Directory(_outDir).createSync(recursive: true);

  final theme = ThermosTheme.byId(id);
  final trigger = ValueNotifier<int>(0);
  final tKey = GlobalKey();
  final shot = GlobalKey();
  final celebrationT = ValueNotifier<double?>(null);
  final celebrationLoop = ValueNotifier<double?>(null);

  await tester.pumpWidget(
    RepaintBoundary(
      key: shot,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: ThemeScene(
            theme: theme,
            thermosKey: tKey,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 56),
                  ValueListenableBuilder<int>(
                    valueListenable: trigger,
                    builder: (context, n, _) => LayoutBuilder(
                      builder: (context, constraints) {
                        final natural =
                            constraints.maxWidth *
                            designRect.height /
                            designRect.width;
                        final baseH = natural.clamp(0.0, 600.0);
                        return SizedBox(
                          height: baseH,
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(0, baseH * kThermosDrop),
                              child: Transform.scale(
                                scale: kThermosZoom,
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height: baseH,
                                  width: constraints.maxWidth,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      ThermosView(
                                        key: tKey,
                                        progress: rest ? 0.6 : 1,
                                        goalMl: 2000,
                                        totalMl: rest ? 1200 : 2000,
                                        celebrations: n,
                                        theme: theme,
                                        happy: !rest,
                                        celebrationT: celebrationT,
                                        celebrationLoop: celebrationLoop,
                                        animatedCelebrations: true,
                                      ),
                                      Positioned.fill(
                                        child: CelebrationOverlay(
                                          trigger: n,
                                          theme: theme,
                                          shape: ThermosShape.chubby,
                                          progress: celebrationT,
                                          looping: n > 0,
                                          loopProgress: celebrationLoop,
                                          animated: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));

  Future<void> snap(String name) async {
    await tester.runAsync(() async {
      final boundary =
          shot.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_outDir\\${id}_$name.png').writeAsBytesSync(
        data!.buffer.asUint8List(),
      );
    });
  }

  if (rest) {
    await snap('rest');
    return;
  }
  trigger.value = 1;
  await tester.pump();
  for (final (name, ms) in frames) {
    await tester.pump(Duration(milliseconds: ms));
    await snap(name);
  }
  if (loopAfter != null) {
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1500));
    await snap(loopAfter);
  }
}
