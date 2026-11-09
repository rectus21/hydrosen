import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../data/water_repository.dart';
import '../../domain/water_entry.dart';

/// Günlük su takibinin durumu. Kayıtlar [WaterRepository] ile kalıcıdır.
/// "Bugün", yerel saate göre takvim günüdür (gece 00:00'da yeni gün başlar).
class WaterController extends ChangeNotifier {
  WaterController({
    required this._repository,
    this.goalMl = 2000,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final WaterRepository _repository;
  final DateTime Function() _now;
  final int goalMl;

  List<WaterEntry> _entries = [];
  bool _loaded = false;
  bool _saveFailed = false;

  bool get loaded => _loaded;

  /// Son kaydetme denemesi başarısız olduysa true; kayıtlar yalnızca bellekte kalmış olabilir.
  bool get saveFailed => _saveFailed;

  Future<void> load() async {
    _entries = await _repository.load();
    _loaded = true;
    notifyListeners();
  }

  bool _isToday(DateTime t) {
    final n = _now();
    return t.year == n.year && t.month == n.month && t.day == n.day;
  }

  /// Bugünün kayıtları, en yeni önde.
  List<WaterEntry> get todayEntries =>
      _entries.where((e) => _isToday(e.time)).toList().reversed.toList();

  int get totalMl => todayEntries.fold(0, (sum, e) => sum + e.amountMl);

  double get progress => goalMl == 0 ? 0 : (totalMl / goalMl).clamp(0.0, 1.0);

  Future<void> add(int amountMl) async {
    if (amountMl <= 0) return;
    final nextId = _entries.fold(0, (m, e) => math.max(m, e.id)) + 1;
    _entries = [
      ..._entries,
      WaterEntry(id: nextId, amountMl: amountMl, time: _now()),
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> remove(int id) async {
    _entries = _entries.where((e) => e.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await _repository.save(_entries);
      _saveFailed = false;
    } catch (_) {
      _saveFailed = true;
    }
    notifyListeners();
  }
}
