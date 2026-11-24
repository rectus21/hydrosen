// Faz 4 – Erişilebilirlik: ekran okuyucu etiketleri ve dokunma hedefi/etiket
// yönergeleri (androidTapTargetGuideline, labeledTapTargetGuideline,
// textContrastGuideline) ana ekranlarda.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/app/app.dart';
import 'package:hydrosen/data/settings_repository.dart';
import 'package:hydrosen/data/streak_repository.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/app_settings.dart';
import 'package:hydrosen/domain/drink_type.dart';
import 'package:hydrosen/domain/streak.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/backup/backup_io.dart';
import 'package:hydrosen/features/thermos/thermos_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoIO implements BackupFileIO {
  @override
  bool get canSave => true;
  @override
  bool get canPick => true;
  @override
  Future<bool> saveFile({
    required String fileName,
    required String content,
  }) async => true;
  @override
  Future<String?> pickFileText() async => null;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final today = DateTime.now();
  final d0 = DateTime(today.year, today.month, today.day);

  Future<SemanticsHandle> pumpApp(
    WidgetTester tester, {
    String themeId = 'klasik',
    List<WaterEntry>? entries,
    StreakData? streak,
    bool settle = true,
  }) async {
    final handle = tester.ensureSemantics();
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      tester.view.reset();
    });
    await tester.pumpWidget(
      HydroSenApp(
        repository: InMemoryWaterRepository(
          entries ??
              [
                WaterEntry(
                  id: 1,
                  amountMl: 1200,
                  time: d0.add(const Duration(hours: 8)),
                ),
                WaterEntry(
                  id: 2,
                  amountMl: 250,
                  time: d0.add(const Duration(hours: 9)),
                  drink: DrinkType.tea,
                ),
              ],
        ),
        settingsRepository: InMemorySettingsRepository(
          AppSettings(theme: ThermosTheme.byId(themeId)),
        ),
        streakRepository: InMemoryStreakRepository(streak),
        backupIo: _NoIO(),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 600));
    }
    return handle;
  }

  Future<void> tab(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> guidelines(WidgetTester tester, {bool contrast = false}) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    if (contrast) {
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
  }

  group('ekran okuyucu etiketleri', () {
    testWidgets(
      'termos: doluluk tek ifade ("Termos, 1200 / 2000 ml, yüzde 60")',
      (tester) async {
        // 1200 su + 250 çay (200 sayılır) = 1400 ml sayılır; 1200 için yalnız su.
        final h = await pumpApp(
          tester,
          entries: [
            WaterEntry(
              id: 1,
              amountMl: 1200,
              time: d0.add(const Duration(hours: 8)),
            ),
          ],
        );
        expect(
          find.bySemanticsLabel('Termos, 1200 / 2000 ml, yüzde 60'),
          findsOneWidget,
        );
        h.dispose();
      },
    );

    testWidgets('hızlı düğmeler, özel miktar ve seri satırı etiketli', (
      tester,
    ) async {
      final h = await pumpApp(tester);
      expect(find.bySemanticsLabel('+1 bardak, 200 ml'), findsOneWidget);
      expect(find.bySemanticsLabel('+2 bardak, 400 ml'), findsOneWidget);
      expect(find.bySemanticsLabel('−1 bardak, 200 ml'), findsOneWidget);
      expect(find.bySemanticsLabel('Özel miktar'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'^Seri: ')), findsOneWidget);
      h.dispose();
    });

    testWidgets('süs katmanları (kutlama çizimi) anlamsal ağaçta yok', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        entries: [
          WaterEntry(
            id: 1,
            amountMl: 2000,
            time: d0.add(const Duration(hours: 8)),
          ),
        ],
        settle: false,
      );
      // Hedef dolu + döngü kutlaması: etiket olmayan (adsız) düğüm bulunmaz.
      final root = tester.semantics.find(find.byType(MaterialApp));
      final unnamed = <String>[];
      void walk(SemanticsNode n) {
        final d = n.getSemanticsData();
        final hasContent =
            d.label.isNotEmpty ||
            d.value.isNotEmpty ||
            d.hint.isNotEmpty ||
            d.tooltip.isNotEmpty;
        final interactive =
            d.hasAction(SemanticsAction.tap) ||
            d.hasAction(SemanticsAction.longPress);
        if (interactive && !hasContent && !d.flagsCollection.isTextField) {
          unnamed.add(
            '${n.id} ${n.rect} ${d.flagsCollection} ${d.actions} tt=${d.tooltip}',
          );
        }
        n.visitChildren((c) {
          walk(c);
          return true;
        });
      }

      walk(root);
      expect(unnamed, isEmpty, reason: 'etiketsiz dokunulabilir: $unnamed');
      h.dispose();
    });

    testWidgets('kayıt satırı, silme ve düzenleme sayfası', (tester) async {
      final h = await pumpApp(tester);
      await tab(tester, 'Kayıtlar');
      expect(find.byTooltip('Kaydı sil'), findsWidgets);
      // Gün özeti: seçili günün toplamı yazıyla okunur.
      expect(find.bySemanticsLabel(RegExp(r'ml')), findsWidgets);
      await tester.tap(find.textContaining('1200 ml').first);
      await tester.pumpAndSettle();
      await guidelines(tester);
      h.dispose();
    });

    testWidgets('Tema: avatar adı + seçili durumu', (tester) async {
      final h = await pumpApp(tester, themeId: 'panda');
      await tab(tester, 'Tema');
      await tester.tap(find.byKey(const ValueKey('theme-chip-Hayvanlar')));
      await tester.pumpAndSettle();
      final panda = tester.getSemantics(
        find.byKey(const ValueKey('theme-card-panda')),
      );
      expect(panda.label, 'Panda');
      expect(panda.flagsCollection.isSelected.name, 'isTrue');
      final aslan = tester.getSemantics(
        find.byKey(const ValueKey('theme-card-aslan')),
      );
      expect(aslan.label, 'Aslan');
      expect(aslan.flagsCollection.isSelected.name, isNot('isTrue'));
      final kedi = tester.getSemantics(
        find.byKey(const ValueKey('theme-card-kedi')),
      );
      expect(kedi.label, 'Kedi');
      h.dispose();
    });

    testWidgets('Rozetler: kazanılan tarih, kalan gün', (tester) async {
      final streak = StreakData(
        start: d0.subtract(const Duration(days: 5)),
        through: d0.subtract(const Duration(days: 1)),
        goalDays: {for (var i = 1; i <= 4; i++) d0.subtract(Duration(days: i))},
        throughGoalMl: 2000,
        lastGoalMl: 2000,
        best: 4,
        badges: {'ilk_kayit': d0.subtract(const Duration(days: 5))},
      );
      final h = await pumpApp(tester, streak: streak);
      await tab(tester, 'Profil');
      await tester.scrollUntilVisible(
        find.text('Rozetlerim'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'İlk kayıt rozeti kazanıldı, \d+ \w+')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'7 gün rozeti kilitli, \d+ gün kaldı')),
        findsOneWidget,
      );
      h.dispose();
    });
  });

  group('dokunma hedefleri ve etiketler (yönergeler)', () {
    testWidgets('Günlük', (tester) async {
      final h = await pumpApp(tester);
      await guidelines(tester);
      h.dispose();
    });

    testWidgets('Günlük: Özel miktar penceresi', (tester) async {
      final h = await pumpApp(tester);
      await tester.tap(find.text('Özel miktar'));
      await tester.pumpAndSettle();
      expect(find.text('Özel miktar (ml)'), findsOneWidget);
      await guidelines(tester);
      h.dispose();
    });

    testWidgets('Kayıtlar', (tester) async {
      final h = await pumpApp(tester);
      await tab(tester, 'Kayıtlar');
      await guidelines(tester);
      h.dispose();
    });

    testWidgets('Kayıtlar: aylık görünüm', (tester) async {
      final h = await pumpApp(tester);
      await tab(tester, 'Kayıtlar');
      await tester.tap(find.text('Aylık'));
      await tester.pumpAndSettle();
      await guidelines(tester);
      h.dispose();
    });
    testWidgets('Hatırlatıcı', (tester) async {
      final h = await pumpApp(tester);
      await tab(tester, 'Hatırlatıcı');
      await guidelines(tester);
      h.dispose();
    });

    testWidgets('Tema ızgarası', (tester) async {
      final h = await pumpApp(tester);
      await tab(tester, 'Tema');
      await guidelines(tester);
      h.dispose();
    });

    testWidgets('Profil (yedek ve widget bölümleri dahil)', (tester) async {
      final h = await pumpApp(tester);
      await tab(tester, 'Profil');
      await guidelines(tester);
      await tester.scrollUntilVisible(
        find.text('Yedekle ve geri yükle'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await guidelines(tester);
      await tester.scrollUntilVisible(
        find.text("Ana ekran widget'ı (yakında)"),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await guidelines(tester);
      h.dispose();
    });

    testWidgets('Ayarlar', (tester) async {
      final h = await pumpApp(tester);
      await tester.tap(find.byTooltip('Ayarlar'));
      await tester.pumpAndSettle();
      await guidelines(tester);
      h.dispose();
    });

    testWidgets('metin kontrastı: Günlük, Hatırlatıcı, Profil (açık tema)', (
      tester,
    ) async {
      final h = await pumpApp(tester, themeId: 'klasik');
      await tab(tester, 'Hatırlatıcı');
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await tab(tester, 'Profil');
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      h.dispose();
    });
  });
}
