import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/water_repository.dart';

void main() {
  testWidgets('ana ekran: ekleme ve silme toplamı günceller', (tester) async {
    await tester.pumpWidget(HydroSenApp(repository: InMemoryWaterRepository()));
    await tester.pumpAndSettle();
    expect(find.text('0 ml'), findsOneWidget);

    await tester.tap(find.text('250 ml'));
    await tester.pumpAndSettle();
    expect(
      find.text('250 ml'),
      findsNWidgets(3),
    ); // düğme + halka toplamı + liste

    await tester.tap(find.byTooltip('Sil'));
    await tester.pumpAndSettle();
    expect(find.text('0 ml'), findsOneWidget);
  });

  testWidgets('uygulama yeniden açılınca kayıt ekranda geri gelir', (
    tester,
  ) async {
    final repo = InMemoryWaterRepository();

    await tester.pumpWidget(HydroSenApp(repository: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('500 ml'));
    await tester.pumpAndSettle();

    // Uygulamayı kapat, aynı depoyla yeniden aç.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(HydroSenApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.text('%25 tamamlandı'), findsOneWidget);
    expect(find.byTooltip('Sil'), findsOneWidget);
  });
}
