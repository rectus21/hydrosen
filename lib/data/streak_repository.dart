import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/streak.dart';

/// Seri ve rozet verisinin saklandığı yer.
abstract class StreakRepository {
  /// Kayıt yoksa ya da bozuksa null (seri su kayıtlarından kurulur).
  Future<StreakData?> load();
  Future<void> save(StreakData data);
}

class SharedPrefsStreakRepository implements StreakRepository {
  static const key = 'streak_v1';

  @override
  Future<StreakData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.get(key);
    if (raw is! String) return null;
    try {
      return StreakData.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(StreakData data) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(key, jsonEncode(data.toJson()));
    if (!ok) throw StateError('Seri saklanamadı');
  }
}

/// Testler için.
class InMemoryStreakRepository implements StreakRepository {
  InMemoryStreakRepository([this.data]);

  StreakData? data;

  @override
  Future<StreakData?> load() async => data;

  @override
  Future<void> save(StreakData data) async => this.data = data;
}
