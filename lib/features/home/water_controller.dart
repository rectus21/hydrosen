import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../data/water_repository.dart';
import '../../domain/water_entry.dart';
import 'goal_celebration.dart';

/// Günlük su takibinin durumu. Kayıtlar [WaterRepository] ile kalıcıdır.
/// "Bugün", yerel saate göre takvim günüdür (gece 00:00'da yeni gün başlar).
class WaterController extends ChangeNotifier {
  WaterController({
    required this._repository,
    this._goalMl = 2000,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final WaterRepository _repository;
  final DateTime Function() _now;
  int _goalMl;

  int get goalMl => _goalMl;

  /// Ayarlardan gelen yeni günlük hedef; kayıtlar etkilenmez.
  set goalMl(int value) {
    if (value == _goalMl) return;
    _goalMl = value;
    _observeGoal();
    notifyListeners();
  }

  final _goalTracker = GoalCelebrationTracker();
  int _celebrations = 0;

  /// Bugün hedefin kaç kez aşağıdan yukarı geçildiği (bu oturumda). Değeri
  /// her arttığında ana ekran bir kez kutlama oynatır.
  int get celebrations => _celebrations;

  void _observeGoal() {
    if (!_loaded) return;
    final crossed = _goalTracker.observe(
      now: _now(),
      totalMl: totalMl,
      goalMl: _goalMl,
    );
    if (crossed) _celebrations++;
  }

  List<WaterEntry> _entries = [];
  bool _loaded = false;
  bool _saveFailed = false;

  bool get loaded => _loaded;

  /// Son kaydetme denemesi başarısız olduysa true; kayıtlar yalnızca bellekte kalmış olabilir.
  bool get saveFailed => _saveFailed;

  Future<void> load() async {
    _entries = await _repository.load();
    _loaded = true;
    _observeGoal(); // Başlangıç durumu: açılışta kutlama oynamaz.
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

  // Geri al için bir önceki durumun görüntüsü (yalnız son değişiklik).
  List<WaterEntry>? _undoSnapshot;

  /// Son ekleme/çıkarma/silme geri alınabilir mi?
  bool get canUndo => _undoSnapshot != null;

  Future<void> add(int amountMl) async {
    if (amountMl <= 0) return;
    _undoSnapshot = _entries;
    final nextId = _entries.fold(0, (m, e) => math.max(m, e.id)) + 1;
    _entries = [
      ..._entries,
      WaterEntry(id: nextId, amountMl: amountMl, time: _now()),
    ];
    _observeGoal();
    notifyListeners();
    await _persist();
  }

  Future<void> remove(int id) async {
    _undoSnapshot = _entries;
    _entries = _entries.where((e) => e.id != id).toList();
    _observeGoal();
    notifyListeners();
    await _persist();
  }

  /// Bugünden [amountMl] kadar su çıkarır (bardak sırasında "son dolu
  /// bardağa dokun"). Kayıtlar hep pozitif kalır, eksi kayıt yazılmaz:
  /// en yeni kayıttan başlanır; kayıt tam [amountMl] ise silinir, büyükse
  /// aynı kayıt azalır (yerinde küçülür), küçükse silinir ve kalan miktar
  /// bir önceki bugünkü kayıttan düşülür. Bugünün toplamı yetmezse hepsi
  /// silinir. Düşülen miktarı döner (0: çıkarılacak bir şey yoktu).
  Future<int> removeAmount(int amountMl) async {
    if (amountMl <= 0) return 0;
    var left = amountMl;
    final next = [..._entries];
    for (var i = next.length - 1; i >= 0 && left > 0; i--) {
      final e = next[i];
      if (!_isToday(e.time)) continue;
      if (e.amountMl <= left) {
        left -= e.amountMl;
        next.removeAt(i);
      } else {
        next[i] = WaterEntry(
          id: e.id,
          amountMl: e.amountMl - left,
          time: e.time,
        );
        left = 0;
      }
    }
    final removed = amountMl - left;
    if (removed == 0) return 0;
    _undoSnapshot = _entries;
    _entries = next;
    _observeGoal();
    notifyListeners();
    await _persist();
    return removed;
  }

  /// Son değişikliği geri alır; geri alınacak bir şey yoksa false.
  Future<bool> undo() async {
    final snapshot = _undoSnapshot;
    if (snapshot == null) return false;
    _undoSnapshot = null;
    _entries = snapshot;
    _observeGoal();
    notifyListeners();
    await _persist();
    return true;
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
