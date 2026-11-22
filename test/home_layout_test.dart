import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/features/thermos/thermos_view.dart';

void main() {
  testWidgets('ana ekranda termos büyük, bardak özet kutusu yok', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });

    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(ThermosView)).height, 600);
    final firstQuick = tester.getTopLeft(
      find.byKey(const ValueKey('quick-add-1')),
    );
    final thermos = tester.getRect(find.byType(ThermosView));
    final controls = tester.getRect(
      find.byKey(const ValueKey('daily-control-card')),
    );
    expect(thermos.bottom, lessThanOrEqualTo(controls.top));
    expect(firstQuick.dy, greaterThan(controls.top));
    expect(find.text('0 / 2000 ml'), findsOneWidget);
    expect(find.text('0 / 10'), findsNothing);
    expect(find.text('bardak'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kısa telefonda termos boşluk bırakmaz ve kontroller erişilir', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });

    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    final thermosSize = tester.getSize(find.byType(ThermosView));
    expect(thermosSize.width, closeTo(328, 0.1));
    expect(thermosSize.height, closeTo(328 * 504 / 440, 0.1));

    expect(find.text('Özel miktar'), findsOneWidget);

    final controls = tester.getRect(
      find.byKey(const ValueKey('daily-control-card')),
    );
    final tabs = tester.getRect(find.byKey(const ValueKey('bottom-tabs')));
    expect(controls.bottom, lessThanOrEqualTo(tabs.top));
    expect(tabs.bottom, lessThanOrEqualTo(640));
    expect(tester.takeException(), isNull);
  });
}
