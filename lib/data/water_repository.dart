import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/water_entry.dart';

/// Su kayıtlarının saklandığı yer. Arayüz bu sınıfı bilir, depolama
/// teknolojisini bilmez; ileride sqflite'a geçmek yalnızca yeni bir uygulama yazmayı gerektirir.
abstract class WaterRepository {
  Future<List<WaterEntry>> load();
  Future<void> save(List<WaterEntry> entries);
}

class SharedPrefsWaterRepository implements WaterRepository {
  static const key = 'water_entries_v1';

  @override
  Future<List<WaterEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return [];
    }
    if (decoded is! List) return [];
    final result = <WaterEntry>[];
    for (final item in decoded) {
      try {
        result.add(WaterEntry.fromJson((item as Map).cast<String, Object?>()));
      } on FormatException {
        continue; // Bozuk tek kayıt diğerlerini etkilemesin.
      } on TypeError {
        continue;
      }
    }
    return result;
  }

  @override
  Future<void> save(List<WaterEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      key,
      jsonEncode([for (final e in entries) e.toJson()]),
    );
    if (!ok) throw StateError('Kayıtlar saklanamadı');
  }
}

/// Testler için.
class InMemoryWaterRepository implements WaterRepository {
  InMemoryWaterRepository([List<WaterEntry> initial = const []])
    : _entries = [...initial];

  List<WaterEntry> _entries;

  @override
  Future<List<WaterEntry>> load() async => [..._entries];

  @override
  Future<void> save(List<WaterEntry> entries) async => _entries = [...entries];
}
