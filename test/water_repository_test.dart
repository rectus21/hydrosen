import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/data/water_repository.dart';
import 'package:hydrosen/domain/water_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('kayıtlar kaydedilip aynı biçimde geri okunur', () async {
    final repo = SharedPrefsWaterRepository();
    final entries = [
      WaterEntry(id: 1, amountMl: 250, time: DateTime(2026, 11, 10, 8, 30)),
      WaterEntry(id: 2, amountMl: 500, time: DateTime(2026, 11, 10, 12, 5)),
    ];
    await repo.save(entries);

    final loaded = await SharedPrefsWaterRepository().load();
    expect(loaded.length, 2);
    expect(loaded[0].id, 1);
    expect(loaded[1].amountMl, 500);
    expect(loaded[1].time, DateTime(2026, 11, 10, 12, 5));
  });

  test('hiç veri yokken boş liste döner', () async {
    expect(await SharedPrefsWaterRepository().load(), isEmpty);
  });

  test('tamamen bozuk metin çökmeden boş liste verir', () async {
    SharedPreferences.setMockInitialValues({
      SharedPrefsWaterRepository.key: '{{bozuk',
    });
    expect(await SharedPrefsWaterRepository().load(), isEmpty);
  });

  test('bozuk tek kayıt atlanır, sağlam kayıtlar korunur', () async {
    SharedPreferences.setMockInitialValues({
      SharedPrefsWaterRepository.key:
          '[{"id":1,"ml":250,"t":"2026-11-10T08:00:00.000"},'
          '{"id":2,"ml":-5,"t":"2026-11-10T09:00:00.000"},'
          '{"id":3,"ml":"x","t":"?"},'
          '"metin",'
          '{"id":4,"ml":300,"t":"2026-11-10T10:00:00.000"}]',
    });
    final loaded = await SharedPrefsWaterRepository().load();
    expect(loaded.map((e) => e.id), [1, 4]);
  });
}
