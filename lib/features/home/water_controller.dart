import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../data/water_repository.dart';
import '../../domain/drink_type.dart';
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

  /// Denetleyicinin saati (testlerde sahte olabilir).
  DateTime get now => _now();

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
    try {
      _entries = await _repository.load();
      _saveFailed = false;
    } catch (_) {
      // Bozuk/erişilemeyen depolama uygulamayı sonsuz yükleme ekranında
      // bırakmasın. Kullanıcı bellekte kayıt eklemeye devam edebilir.
      _entries = [];
      _saveFailed = true;
    }
    _loaded = true;
    _observeGoal(); // Başlangıç durumu: açılışta kutlama oynamaz.
    notifyListeners();
  }

  bool _isToday(DateTime t) {
    final n = _now();
    return t.year == n.year && t.month == n.month && t.day == n.day;
  }

  // En yeni önce: önce saat, eşitse sonradan eklenen (büyük kimlik).
  static int _newestFirst(WaterEntry a, WaterEntry b) {
    final c = b.time.compareTo(a.time);
    return c != 0 ? c : b.id.compareTo(a.id);
  }

  /// Bugünün kayıtları, en yeni önde.
  List<WaterEntry> get todayEntries =>
      _entries.where((e) => _isToday(e.time)).toList()..sort(_newestFirst);

  /// Tüm kayıtlar, en yeni önce. Geçmiş günler Kayıtlar sekmesinde gösterilir.
  List<WaterEntry> get allEntries => [..._entries]..sort(_newestFirst);

  /// Bugünün hedefe sayılan toplamı (içecek oranlarıyla).
  int get totalMl => todayEntries.fold(0, (sum, e) => sum + e.countedMl);

  double get progress => goalMl == 0 ? 0 : (totalMl / goalMl).clamp(0.0, 1.0);

  // Geri al için bir önceki durumun görüntüsü (yalnız son değişiklik).
  List<WaterEntry>? _undoSnapshot;

  /// Son ekleme/çıkarma/silme geri alınabilir mi?
  bool get canUndo => _undoSnapshot != null;

  /// Kayıt ekler. Varsayılan: şimdi, su. Geçmiş bir [time] bugünün toplamını
  /// etkilemez.
  Future<void> add(
    int amountMl, {
    DrinkType drink = DrinkType.water,
    DateTime? time,
  }) async {
    if (amountMl <= 0) return;
    _undoSnapshot = _entries;
    final nextId = _entries.fold(0, (m, e) => math.max(m, e.id)) + 1;
    _entries = [
      ..._entries,
      WaterEntry(
        id: nextId,
        amountMl: amountMl,
        time: time ?? _now(),
        drink: drink,
      ),
    ];
    _observeGoal();
    notifyListeners();
    await _persist();
  }

  /// Kaydı yerinde günceller (kimlik korunur). Kayıt yoksa false.
  Future<bool> update(
    int id, {
    int? amountMl,
    DateTime? time,
    DrinkType? drink,
  }) async {
    if (amountMl != null && amountMl <= 0) return false;
    final index = _entries.indexWhere((e) => e.id == id);
    if (index < 0) return false;
    _undoSnapshot = _entries;
    _entries = [
      for (var i = 0; i < _entries.length; i++)
        i == index
            ? _entries[i].copyWith(amountMl: amountMl, time: time, drink: drink)
            : _entries[i],
    ];
    _observeGoal();
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> remove(int id) async {
    if (!_entries.any((entry) => entry.id == id)) return;
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
    // Miktar hedefe sayılan ml'dir; en yeni bugünkü kayıttan başlanır.
    for (final e in todayEntries) {
      if (left <= 0) break;
      final i = next.indexWhere((x) => x.id == e.id);
      if (e.countedMl <= left) {
        left -= e.countedMl;
        next.removeAt(i);
      } else {
        // Ham miktarı, kalan sayılan miktara karşılık gelecek şekilde küçült.
        final keepCounted = e.countedMl - left;
        final raw = math.max(1, (keepCounted * 100 / e.drink.percent).round());
        next[i] = e.copyWith(amountMl: raw);
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
