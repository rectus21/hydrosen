import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama açıkken çalışan, ayarları cihazda saklanan su hatırlatıcısı.
class ReminderController extends ChangeNotifier {
  ReminderController({required this.onDue, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const _enabledKey = 'reminder_enabled_v1';
  static const _startKey = 'reminder_start_minute_v1';
  static const _endKey = 'reminder_end_minute_v1';
  static const _intervalKey = 'reminder_interval_minute_v1';

  final VoidCallback onDue;
  final DateTime Function() _now;
  Timer? _timer;
  String? _lastSlot;

  bool loaded = false;
  bool enabled = false;
  int startMinute = 8 * 60;
  int endMinute = 22 * 60;
  int intervalMinute = 60;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      enabled = prefs.getBool(_enabledKey) ?? false;
      startMinute = prefs.getInt(_startKey) ?? startMinute;
      endMinute = prefs.getInt(_endKey) ?? endMinute;
      intervalMinute = prefs.getInt(_intervalKey) ?? intervalMinute;
      if (startMinute < 0 || endMinute >= 1440 || startMinute >= endMinute) {
        startMinute = 8 * 60;
        endMinute = 22 * 60;
      }
      if (!{30, 60, 90, 120}.contains(intervalMinute)) intervalMinute = 60;
    } catch (_) {
      // Kısmen okunmuş/bozuk veri hatırlatıcıyı yanlışlıkla açmasın.
      enabled = false;
      startMinute = 8 * 60;
      endMinute = 22 * 60;
      intervalMinute = 60;
    }
    loaded = true;
    _syncTimer();
    notifyListeners();
  }

  Future<void> configure({
    bool? active,
    int? start,
    int? end,
    int? interval,
  }) async {
    final nextStart = start ?? startMinute;
    final nextEnd = end ?? endMinute;
    if (nextStart < 0 || nextEnd >= 1440 || nextStart >= nextEnd) return;
    if (interval != null && !{30, 60, 90, 120}.contains(interval)) return;
    enabled = active ?? enabled;
    startMinute = nextStart;
    endMinute = nextEnd;
    intervalMinute = interval ?? intervalMinute;
    _lastSlot = null;
    _syncTimer();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);
      await prefs.setInt(_startKey, startMinute);
      await prefs.setInt(_endKey, endMinute);
      await prefs.setInt(_intervalKey, intervalMinute);
    } catch (_) {
      // Ekrandaki ayar kullanılmaya devam eder; bir sonraki açılışta sıfırlanır.
    }
  }

  void _syncTimer() {
    _timer?.cancel();
    if (enabled) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => checkDue());
    }
  }

  void checkDue() {
    if (!enabled) return;
    final n = _now();
    final minute = n.hour * 60 + n.minute;
    if (minute < startMinute || minute >= endMinute) return;
    if ((minute - startMinute) % intervalMinute != 0) return;
    final slot = '${n.year}-${n.month}-${n.day}-$minute';
    if (_lastSlot == slot) return;
    _lastSlot = slot;
    onDue();
  }

  DateTime? get nextReminder {
    if (!enabled) return null;
    final n = _now();
    for (var day = 0; day < 2; day++) {
      final d = DateTime(n.year, n.month, n.day + day);
      for (
        var minute = startMinute;
        minute < endMinute;
        minute += intervalMinute
      ) {
        final at = d.add(Duration(minutes: minute));
        if (at.isAfter(n)) return at;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
