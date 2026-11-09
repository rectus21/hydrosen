import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:hydrosen/features/home/water_controller.dart';

class _FailingRepository implements WaterRepository {
  @override
  Future<List<WaterEntry>> load() async => [];

  @override
  Future<void> save(List<WaterEntry> entries) async =>
      throw StateError('disk dolu');
}

void main() {
  final today = DateTime(2026, 11, 10, 14, 0);

  WaterController make(WaterRepository repo, {DateTime? now}) =>
      WaterController(repository: repo, goalMl: 2000, now: () => now ?? today);

  test('toplam ve ilerleme hesaplanır, silme toplamı düşürür', () async {
    final c = make(InMemoryWaterRepository());
    await c.load();
    await c.add(500);
    await c.add(250);
    expect(c.totalMl, 750);
    expect(c.progress, closeTo(0.375, 1e-9));
    await c.remove(c.todayEntries.first.id);
    expect(c.totalMl, 500);
  });

  test('ilerleme 1.0 üzerine çıkmaz, geçersiz miktar eklenmez', () async {
    final c = WaterController(
      repository: InMemoryWaterRepository(),
      goalMl: 1000,
      now: () => today,
    );
    await c.load();
    await c.add(1500);
    await c.add(0);
    await c.add(-5);
    expect(c.todayEntries.length, 1);
    expect(c.progress, 1.0);
  });

  test('kayıtlar yeni bir denetleyici açıldığında (uygulama yeniden başlayınca) geri gelir', () async {
    final repo = InMemoryWaterRepository();
    final first = make(repo);
    await first.load();
    await first.add(250);
    await first.add(330);

    final second = make(repo);
    await second.load();
    expect(second.totalMl, 580);
    expect(second.todayEntries.length, 2);
  });

  test('silme de kalıcıdır', () async {
    final repo = InMemoryWaterRepository();
    final first = make(repo);
    await first.load();
    await first.add(250);
    await first.remove(first.todayEntries.first.id);

    final second = make(repo);
    await second.load();
    expect(second.todayEntries, isEmpty);
  });

  test('gün değişince sayaç sıfırdan başlar, eski kayıt silinmez', () async {
    final repo = InMemoryWaterRepository();
    final dun = make(repo, now: DateTime(2026, 11, 9, 23, 50));
    await dun.load();
    await dun.add(700);

    final bugun = make(repo, now: DateTime(2026, 11, 10, 0, 5));
    await bugun.load();
    expect(bugun.totalMl, 0);
    expect(bugun.todayEntries, isEmpty);
    await bugun.add(200);
    expect(bugun.totalMl, 200);

    // Dünün kaydı hâlâ depoda.
    final stored = await repo.load();
    expect(stored.length, 2);
  });

  test('kimlikler silmeden sonra tekrar kullanılmaz çakışmaz', () async {
    final c = make(InMemoryWaterRepository());
    await c.load();
    await c.add(100);
    await c.add(200);
    final ids = c.todayEntries.map((e) => e.id).toSet();
    expect(ids.length, 2);
  });

  test(
    'kaydetme başarısız olursa saveFailed işaretlenir, uygulama çökmez',
    () async {
      final c = make(_FailingRepository());
      await c.load();
      await c.add(250);
      expect(c.saveFailed, isTrue);
      expect(c.totalMl, 250); // bellekte durur
    },
  );
}
