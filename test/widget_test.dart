import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/features/home/water_controller.dart';

void main() {
  group('WaterController', () {
    test('toplam ve ilerleme hesaplanır, silme toplamı düşürür', () {
      final c = WaterController(goalMl: 2000);
      c.add(500);
      c.add(250);
      expect(c.totalMl, 750);
      expect(c.progress, closeTo(0.375, 1e-9));
      c.remove(c.entries.first.id);
      expect(c.totalMl, 500);
    });

    test('ilerleme 1.0 üzerine çıkmaz, geçersiz miktar eklenmez', () {
      final c = WaterController(goalMl: 1000);
      c.add(1500);
      c.add(0);
      c.add(-5);
      expect(c.entries.length, 1);
      expect(c.progress, 1.0);
    });
  });

  testWidgets('ana ekran: ekleme ve silme toplamı günceller', (tester) async {
    await tester.pumpWidget(const HydroSenApp());
    expect(find.text('0 ml'), findsOneWidget);

    await tester.tap(find.text('250 ml'));
    await tester.pumpAndSettle();
    expect(find.text('250 ml'), findsNWidgets(3)); // düğme + halka toplamı + liste

    await tester.tap(find.byTooltip('Sil'));
    await tester.pumpAndSettle();
    expect(find.text('0 ml'), findsOneWidget);
  });
}
