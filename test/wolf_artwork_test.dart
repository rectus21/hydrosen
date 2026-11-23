import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/thermos/thermos_view.dart';
import 'package:hydrosen/features/thermos/thermos_painter.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:hydrosen/features/thermos/wolf_artwork.dart';

void main() {
  testWidgets('wolf lifts its face while the cap band stays stationary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      expect(await WolfArtwork.load(), isNotNull);
    });
    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository([
          WaterEntry(id: 1, amountMl: 2000, time: DateTime.now()),
        ]),
        settingsRepository: InMemorySettingsRepository(
          AppSettings(
            theme: ThermosTheme.byId('kurt'),
            animatedCelebrations: true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    ThermosPainter painter() =>
        tester
                .widget<CustomPaint>(
                  find.byWidgetPredicate(
                    (w) => w is CustomPaint && w.painter is ThermosPainter,
                  ),
                )
                .painter!
            as ThermosPainter;
    final before = painter().headLift;
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    expect(painter().headLift, greaterThan(before));
    expect(painter().capPose.isIdentity, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final shape in ThermosShape.values) {
    testWidgets('illustrated wolf $shape: normal, howl and undo', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(() {
        tester.view.reset();
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      });
      await tester.runAsync(() async {
        expect(await WolfArtwork.load(), isNotNull);
      });
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: HydroSenApp(
            repository: InMemoryWaterRepository([
              WaterEntry(id: 1, amountMl: 1800, time: DateTime.now()),
            ]),
            settingsRepository: InMemorySettingsRepository(
              AppSettings(
                theme: ThermosTheme.byId('kurt'),
                shape: shape,
                animatedCelebrations: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<ThermosView>(find.byType(ThermosView)).happy,
        isFalse,
      );
      Future<void> capture(String state) async {
        const directory = String.fromEnvironment('HYDROSEN_CAPTURE_DIR');
        if (directory.isEmpty) return;
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('$directory/wolf-${shape.name}-$state.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('normal');
      await tester.ensureVisible(find.byKey(const ValueKey('quick-add-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quick-add-1')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ThermosView>(find.byType(ThermosView)).happy,
        isTrue,
      );
      expect(
        tester.widget<ThermosView>(find.byType(ThermosView)).totalMl,
        2000,
      );
      await capture('howl');
      await tester.tap(find.byKey(const ValueKey('quick-remove-1')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ThermosView>(find.byType(ThermosView)).happy,
        isFalse,
      );
      expect(
        tester.widget<ThermosView>(find.byType(ThermosView)).totalMl,
        1800,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
