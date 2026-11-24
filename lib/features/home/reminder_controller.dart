import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/reminder_planner.dart';

/// Hatırlatıcının dışarıdan bilmesi gereken bugünkü durum.
class ReminderContext {
  const ReminderContext({this.lastDrink, this.goalReached = false});

  /// Bugünün son su kaydının zamanı (yoksa null).
  final DateTime? lastDrink;

  /// Bugünkü hedef tamamlandı mı.
  final bool goalReached;
}

/// Ayarları cihazda saklanan akıllı su hatırlatıcısı. Zamanı [ReminderPlanner]
/// hesaplar; bu sınıf ayarları saklar, zamanlayıcıyı çalıştırır ve gönderilen
/// hatırlatmaları sayar. Teslimat ([onDue]) soyuttur.
class ReminderController extends ChangeNotifier {
  ReminderController({
    required this.onDue,
    DateTime Function()? now,
    this.contextProvider,
  }) : _now = now ?? DateTime.now;

  static const _enabledKey = 'reminder_enabled_v1';
  static const _startKey = 'reminder_start_minute_v1';
  static const _endKey = 'reminder_end_minute_v1';
  static const _intervalKey = 'reminder_interval_minute_v1';
  static const _stopAtGoalKey = 'reminder_stop_at_goal_v1';
  static const _dailyCapKey = 'reminder_daily_cap_v1';
  static const _stateKey = 'reminder_day_state_v1';

  /// Hatırlatma zamanı gelince çağrılır; türü [lastKind] söyler.
  final VoidCallback onDue;

  /// Son su kaydı ve hedef durumu (ev ekranı bağlar).
  ReminderContext Function()? contextProvider;

  final DateTime Function() _now;
  Timer? _timer;
  late ReminderDayState _state = _emptyState();

  bool loaded = false;
  bool enabled = false;
  int startMinute = ReminderPlanner.defaultStartMinute;
  int endMinute = ReminderPlanner.defaultEndMinute;
  int intervalMinute = 60;
  bool stopAtGoal = true;
  int dailyCap = ReminderPlanner.defaultDailyCap;

  /// Denetleyicinin saati (testlerde sahte olabilir).
  DateTime get now => _now();

  /// Son gönderilen hatırlatmanın türü ([onDue] içinde okunur).
  ReminderKind lastKind = ReminderKind.normal;

  /// Bugün şimdiye kadar gönderilen hatırlatma sayısı.
  int get sentToday => _state.forDay(_now()).sent;

  ReminderDayState _emptyState() {
    final n = _now();
    return ReminderDayState(day: DateTime(n.year, n.month, n.day));
  }

  ReminderPlanner get planner => ReminderPlanner(
    startMinute: startMinute,
    endMinute: endMinute,
    intervalMinutes: intervalMinute,
    dailyCap: dailyCap,
    stopAtGoal: stopAtGoal,
  );

  /// Şu anki duruma göre plan.
  ReminderPlan get plan {
    final ctx = contextProvider?.call() ?? const ReminderContext();
    return planner.plan(
      now: _now(),
      lastDrink: ctx.lastDrink,
      goalReached: ctx.goalReached,
      state: _state,
    );
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      enabled = prefs.getBool(_enabledKey) ?? false;
      startMinute = prefs.getInt(_startKey) ?? startMinute;
      endMinute = prefs.getInt(_endKey) ?? endMinute;
      intervalMinute = prefs.getInt(_intervalKey) ?? intervalMinute;
      stopAtGoal = prefs.getBool(_stopAtGoalKey) ?? true;
      dailyCap = ReminderPlanner.clampCap(
        prefs.getInt(_dailyCapKey) ?? ReminderPlanner.defaultDailyCap,
      );
      if (ReminderPlanner.validateWindow(startMinute, endMinute) != null) {
        startMinute = ReminderPlanner.defaultStartMinute;
        endMinute = ReminderPlanner.defaultEndMinute;
      }
      if (!ReminderPlanner.intervals.contains(intervalMinute)) {
        intervalMinute = 60;
      }
      final raw = prefs.getString(_stateKey);
      if (raw != null) {
        _state = ReminderDayState.tryFromJson(jsonDecode(raw)) ?? _state;
      }
    } catch (_) {
      // Kısmen okunmuş/bozuk veri hatırlatıcıyı yanlışlıkla açmasın.
      enabled = false;
      startMinute = ReminderPlanner.defaultStartMinute;
      endMinute = ReminderPlanner.defaultEndMinute;
      intervalMinute = 60;
      stopAtGoal = true;
      dailyCap = ReminderPlanner.defaultDailyCap;
    }
    loaded = true;
    _syncTimer();
    notifyListeners();
  }

  /// Ayarları değiştirir. Geçersiz değerde (ör. bitiş başlangıçtan önce)
  /// hiçbir şeyi değiştirmeden false döner.
  Future<bool> configure({
    bool? active,
    int? start,
    int? end,
    int? interval,
    bool? stopAtGoalValue,
    int? cap,
  }) async {
    final nextStart = start ?? startMinute;
    final nextEnd = end ?? endMinute;
    if (ReminderPlanner.validateWindow(nextStart, nextEnd) != null) {
      return false;
    }
    if (interval != null && !ReminderPlanner.intervals.contains(interval)) {
      return false;
    }
    enabled = active ?? enabled;
    startMinute = nextStart;
    endMinute = nextEnd;
    intervalMinute = interval ?? intervalMinute;
    stopAtGoal = stopAtGoalValue ?? stopAtGoal;
    dailyCap = ReminderPlanner.clampCap(cap ?? dailyCap);
    _syncTimer();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);
      await prefs.setInt(_startKey, startMinute);
      await prefs.setInt(_endKey, endMinute);
      await prefs.setInt(_intervalKey, intervalMinute);
      await prefs.setBool(_stopAtGoalKey, stopAtGoal);
      await prefs.setInt(_dailyCapKey, dailyCap);
    } catch (_) {
      // Ekrandaki ayar kullanılmaya devam eder; bir sonraki açılışta sıfırlanır.
    }
    return true;
  }

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (enabled) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => checkDue());
    }
  }

  /// Zamanı gelmiş bir hatırlatma varsa teslim eder (dakikada birkaç kez
  /// çağrılabilir; aynı hatırlatma bir kez gönderilir).
  void checkDue() {
    if (!enabled) return;
    final n = _now();
    final p = plan;
    if (!p.isDue(n)) {
      // Gece yarısından sonra eski gün sayaçları kendiliğinden sıfırlanır.
      return;
    }
    _state = _state.afterSent(p.kind, n);
    lastKind = p.kind;
    _saveState();
    onDue();
    notifyListeners();
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_stateKey, jsonEncode(_state.toJson()));
    } catch (_) {
      // Saklanamazsa sayaç bellekte sürer.
    }
  }

  /// Sonraki hatırlatmanın zamanı (kapalıysa null). Bugünün hatırlatması
  /// bittiyse yarının ilkidir.
  DateTime? get nextReminder => enabled ? plan.at : null;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
