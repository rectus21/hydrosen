import 'dart:convert';

import '../features/thermos/thermos_theme.dart';
import 'app_settings.dart';
import 'bottle_name.dart';
import 'badges.dart';
import 'reminder_planner.dart';
import 'saved_container.dart';
import 'streak.dart';
import 'water_entry.dart';

/// Yedek dosyası geçersizse fırlatılır; [message] kullanıcıya gösterilebilir
/// (Türkçe, sade). Hiçbir veri değişmeden önce fırlatılır.
class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => 'BackupException: $message';
}

/// Hatırlatıcı ayarları (yedek ve geri yükleme için).
class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.startMinute = ReminderPlanner.defaultStartMinute,
    this.endMinute = ReminderPlanner.defaultEndMinute,
    this.intervalMinute = 60,
    this.stopAtGoal = true,
    this.dailyCap = ReminderPlanner.defaultDailyCap,
  });

  final bool enabled;
  final int startMinute;
  final int endMinute;
  final int intervalMinute;
  final bool stopAtGoal;
  final int dailyCap;

  Map<String, Object> toJson() => {
    'enabled': enabled,
    'startMinute': startMinute,
    'endMinute': endMinute,
    'intervalMinute': intervalMinute,
    'stopAtGoal': stopAtGoal,
    'dailyCap': dailyCap,
  };

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.enabled == enabled &&
      other.startMinute == startMinute &&
      other.endMinute == endMinute &&
      other.intervalMinute == intervalMinute &&
      other.stopAtGoal == stopAtGoal &&
      other.dailyCap == dailyCap;

  @override
  int get hashCode => Object.hash(
    enabled,
    startMinute,
    endMinute,
    intervalMinute,
    stopAtGoal,
    dailyCap,
  );
}

/// Yedeklenen her şey. [reminder] ve [streak] boş olabilir (eski/yarım yedek).
class BackupData {
  const BackupData({
    required this.entries,
    this.settings,
    this.reminder,
    this.streak,
  });

  final List<WaterEntry> entries;

  /// Tercihler + kaplar + matara adları (yoksa mevcut ayarlar korunur).
  final AppSettings? settings;
  final ReminderSettings? reminder;

  /// Seri verisi ve rozetler.
  final StreakData? streak;
}

/// Geri yüklemeden önce kullanıcıya gösterilen özet.
class BackupSummary {
  const BackupSummary({
    required this.entryCount,
    required this.badgeCount,
    this.firstDay,
    this.lastDay,
  });

  factory BackupSummary.of(BackupData data) {
    DateTime? first, last;
    for (final e in data.entries) {
      final d = dayOf(e.time);
      if (first == null || d.isBefore(first)) first = d;
      if (last == null || d.isAfter(last)) last = d;
    }
    return BackupSummary(
      entryCount: data.entries.length,
      badgeCount: data.streak?.badges.length ?? 0,
      firstDay: first,
      lastDay: last,
    );
  }

  final int entryCount;
  final int badgeCount;
  final DateTime? firstDay;
  final DateTime? lastDay;

  static const _months = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];

  static String _day(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// Örn. "142 kayıt, 8 rozet, 23 Kas–24 Kas" (kayıt yoksa tarih aralığı yok).
  String get text {
    final parts = ['$entryCount kayıt', '$badgeCount rozet'];
    final a = firstDay, b = lastDay;
    if (a != null && b != null) {
      parts.add(a == b ? _day(a) : '${_day(a)}–${_day(b)}');
    }
    return parts.join(', ');
  }
}

/// Yedek dosyasının biçimi (sürümlü JSON) ve doğrulaması.
///
/// Biçim (`schemaVersion` 1):
/// ```
/// { "app": "hydrosen", "schemaVersion": 1, "createdAt": "...",
///   "entries": [ {id, ml, t, d?} ... ],        // ZORUNLU
///   "settings": { shape, theme, goalMl, glassMl, animatedCelebrations,
///                 containers: [...], bottleNames: {...} },   // isteğe bağlı
///   "reminder": { enabled, startMinute, ... },               // isteğe bağlı
///   "streak": { ...StreakData... } }                         // isteğe bağlı
/// ```
/// Eksik isteğe bağlı bölüm: `settings`/`reminder` yoksa mevcut değerler
/// korunur, `streak` yoksa seri kayıtlardan yeniden kurulur. Bölüm VAR ama
/// bozuksa tüm dosya reddedilir (kısmi geri yükleme yok). Bilinmeyen alanlar
/// yok sayılır; `schemaVersion` desteklenenden büyükse reddedilir.
abstract final class BackupCodec {
  static const app = 'hydrosen';
  static const schemaVersion = 1;
  static const maxFileChars = 20 * 1024 * 1024;
  static const maxEntries = 200000;
  static const maxEntryMl = 10000;

  static String fileName(DateTime now) => 'hydrosen-yedek-${dayKey(now)}.json';

  static String encode(BackupData data, {DateTime? now}) {
    final s = data.settings;
    final map = <String, Object?>{
      'app': app,
      'schemaVersion': schemaVersion,
      'createdAt': (now ?? DateTime.now()).toIso8601String(),
      'entries': [for (final e in data.entries) e.toJson()],
      if (s != null)
        'settings': {
          'shape': s.shape.name,
          'theme': s.theme.id,
          'goalMl': s.goalMl,
          'glassMl': s.glassMl,
          'animatedCelebrations': s.animatedCelebrations,
          'containers': [for (final c in s.containers) c.toJson()],
          'bottleNames': s.bottleNames,
        },
      if (data.reminder != null) 'reminder': data.reminder!.toJson(),
      if (data.streak != null) 'streak': data.streak!.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static const _notBackup =
      'Bu dosya bir HydroSen yedeği gibi görünmüyor. Hiçbir şey değişmedi.';
  static const _corrupt =
      'Yedek dosyası bozuk ya da eksik. Hiçbir şey değişmedi.';

  /// Metni çözer ve TAM doğrular; geçersizse [BackupException].
  static BackupData decode(String text) {
    if (text.length > maxFileChars) {
      throw const BackupException('Bu dosya çok büyük. Hiçbir şey değişmedi.');
    }
    final Object? root;
    try {
      root = jsonDecode(text);
    } on FormatException {
      throw const BackupException(_notBackup);
    }
    if (root is! Map || root['app'] != app) {
      throw const BackupException(_notBackup);
    }
    final version = root['schemaVersion'];
    if (version is! int || version < 1) {
      throw const BackupException(_corrupt);
    }
    if (version > schemaVersion) {
      throw const BackupException(
        'Bu yedek HydroSen\'in daha yeni bir sürümüyle alınmış. '
        'Uygulamayı güncelleyip tekrar dene. Hiçbir şey değişmedi.',
      );
    }
    try {
      return BackupData(
        entries: _entries(root['entries']),
        settings: _settings(root['settings']),
        reminder: _reminder(root['reminder']),
        streak: _streak(root['streak']),
      );
    } on _Invalid {
      throw const BackupException(_corrupt);
    } on FormatException {
      throw const BackupException(_corrupt);
    } on TypeError {
      throw const BackupException(_corrupt);
    }
  }

  static List<WaterEntry> _entries(Object? raw) {
    if (raw is! List || raw.length > maxEntries) throw const _Invalid();
    final ids = <int>{};
    final out = <WaterEntry>[];
    for (final item in raw) {
      if (item is! Map) throw const _Invalid();
      final e = WaterEntry.fromJson(item.cast<String, Object?>());
      if (e.amountMl > maxEntryMl ||
          e.time.year < 2000 ||
          e.time.year > 2100 ||
          e.id < 0 ||
          !ids.add(e.id)) {
        throw const _Invalid();
      }
      if (item['d'] != null && item['d'] != e.drink.id) {
        throw const _Invalid(); // bilinmeyen içecek
      }
      out.add(e);
    }
    return out;
  }

  /// Yok → null (mevcut ayarlar korunur). Var ama bozuk → [_Invalid].
  static AppSettings? _settings(Object? raw) {
    if (raw == null) return null;
    if (raw is! Map) throw const _Invalid();
    final shapeName = raw['shape'];
    final shape = ThermosShape.values.where((s) => s.name == shapeName);
    if (shape.isEmpty) throw const _Invalid();
    final themeId = raw['theme'];
    if (themeId is! String) throw const _Invalid();
    final goal = raw['goalMl'], glass = raw['glassMl'];
    if (goal is! int ||
        goal < AppSettings.minGoalMl ||
        goal > AppSettings.maxGoalMl ||
        glass is! int ||
        glass < AppSettings.minGlassMl ||
        glass > AppSettings.maxGlassMl) {
      throw const _Invalid();
    }
    final animated = raw['animatedCelebrations'];
    if (animated is! bool) throw const _Invalid();

    final rawContainers = raw['containers'];
    final containers = <SavedContainer>[];
    if (rawContainers != null) {
      if (rawContainers is! List ||
          rawContainers.isEmpty ||
          rawContainers.length > AppSettings.maxContainers) {
        throw const _Invalid();
      }
      for (final c in rawContainers) {
        if (c is! Map) throw const _Invalid();
        final sc = SavedContainer.fromJson(c.cast<String, Object?>());
        if (sc.name.isEmpty || containers.any((x) => x.id == sc.id)) {
          throw const _Invalid();
        }
        containers.add(sc);
      }
    }
    final rawNames = raw['bottleNames'];
    final names = <String, String>{};
    if (rawNames != null) {
      if (rawNames is! Map) throw const _Invalid();
      rawNames.forEach((k, v) {
        if (k is! String || v is! String) throw const _Invalid();
        final r = BottleName.validate(v);
        final n = r.name;
        if (!r.isOk || n == null || n.isEmpty) throw const _Invalid();
        names[k] = n;
      });
    }
    return AppSettings(
      shape: shape.first,
      // Bilinmeyen tema kimliği (daha yeni uygulamadan): Klasik'e döner.
      theme: ThermosTheme.byId(themeId),
      goalMl: goal,
      glassMl: glass,
      animatedCelebrations: animated,
      containers: containers.isEmpty
          ? AppSettings.defaultContainers
          : containers,
      bottleNames: names,
    );
  }

  static ReminderSettings? _reminder(Object? raw) {
    if (raw == null) return null;
    if (raw is! Map) throw const _Invalid();
    final enabled = raw['enabled'], stop = raw['stopAtGoal'];
    final start = raw['startMinute'], end = raw['endMinute'];
    final interval = raw['intervalMinute'], cap = raw['dailyCap'];
    if (enabled is! bool ||
        stop is! bool ||
        start is! int ||
        end is! int ||
        interval is! int ||
        cap is! int ||
        ReminderPlanner.validateWindow(start, end) != null ||
        !ReminderPlanner.intervals.contains(interval) ||
        ReminderPlanner.clampCap(cap) != cap) {
      throw const _Invalid();
    }
    return ReminderSettings(
      enabled: enabled,
      startMinute: start,
      endMinute: end,
      intervalMinute: interval,
      stopAtGoal: stop,
      dailyCap: cap,
    );
  }

  static StreakData? _streak(Object? raw) {
    if (raw == null) return null;
    if (raw is! Map) throw const _Invalid();
    // Rozet tarihleri ve bilinen kimlikler sıkı denetlenir (fromJson yumuşak).
    final badges = raw['badges'];
    if (badges != null) {
      if (badges is! Map) throw const _Invalid();
      for (final e in badges.entries) {
        if (e.key is! String ||
            Badges.byId(e.key as String) == null ||
            parseDayKey(e.value) == null) {
          throw const _Invalid();
        }
      }
    }
    final data = StreakData.fromJson(raw);
    if (data == null) throw const _Invalid();
    return data;
  }
}

class _Invalid implements Exception {
  const _Invalid();
}
