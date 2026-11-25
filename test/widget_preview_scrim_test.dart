import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/domain/widget_snapshot.dart';
import 'package:hydrosen/features/thermos/illustrated_artwork.dart';
import 'package:hydrosen/features/widget/widget_preview.dart';

Color _amountColor(WidgetTester tester) => tester
    .widget<Text>(find.textContaining('1200 / 2000 ml').first)
    .style!
    .color!;

Future<void> _pump(WidgetTester tester, String id) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: WidgetPreview(
        snapshot: WidgetSnapshot(
          todayMl: 1200,
          goalMl: 2000,
          streakDay: 3,
          themeId: id,
          characterName: id,
        ),
        size: WidgetPreviewSize.small2x2,
      ),
    ),
  ),
);

void main() {
  tearDown(IllustratedArtwork.bottomLuma.clear);

  testWidgets('açık sahnede koyu, koyu sahnede beyaz yazı', (tester) async {
    IllustratedArtwork.bottomLuma['panda'] = 0.8;
    IllustratedArtwork.bottomLuma['gece'] = 0.2;
    await _pump(tester, 'panda');
    expect(_amountColor(tester), const Color(0xFF10223A));
    await _pump(tester, 'gece');
    expect(_amountColor(tester), Colors.white);
  });
}
