import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';
import '../domain/saved_container.dart';
import '../features/thermos/thermos_theme.dart';

/// Ayarların saklandığı yer (su kayıtlarındaki depo yaklaşımıyla aynı).
abstract class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class SharedPrefsSettingsRepository implements SettingsRepository {
  static const shapeKey = 'settings_shape_v1';
  static const themeKey = 'settings_theme_v1';
  static const goalKey = 'settings_goal_ml_v1';
  static const glassKey = 'settings_glass_ml_v1';
  static const animatedKey = 'settings_animated_celebrations_v1';
  static const containersKey = 'settings_containers_v1';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Tür uyuşmazlığı (bozuk veri) çökmesin diye get() ile okunur.
    final shapeName = prefs.get(shapeKey);
    final themeId = prefs.get(themeKey);
    final goal = prefs.get(goalKey);
    final glass = prefs.get(glassKey);
    final animated = prefs.get(animatedKey);
    final containers = prefs.get(containersKey);
    return AppSettings(
      shape: ThermosShape.values.firstWhere(
        (s) => s.name == shapeName,
        orElse: () => ThermosShape.chubby,
      ),
      theme: themeId is String
          ? ThermosTheme.byId(themeId)
          : ThermosTheme.classic,
      goalMl: goal is int
          ? AppSettings.normalizeGoal(goal)
          : AppSettings.defaultGoalMl,
      glassMl: glass is int
          ? AppSettings.normalizeGlass(glass)
          : AppSettings.defaultGlassMl,
      animatedCelebrations: animated is bool ? animated : true,
      containers: _decodeContainers(containers),
    );
  }

  /// Eksik/bozuk veri varsayılan kaplara döner; bozuk tek kap atlanır.
  static List<SavedContainer> _decodeContainers(Object? raw) {
    if (raw is! String) return AppSettings.defaultContainers;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return AppSettings.defaultContainers;
    }
    if (decoded is! List) return AppSettings.defaultContainers;
    final result = <SavedContainer>[];
    for (final item in decoded) {
      try {
        final c = SavedContainer.fromJson(
          (item as Map).cast<String, Object?>(),
        );
        if (c.name.isEmpty || result.any((r) => r.id == c.id)) continue;
        result.add(c);
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }
    if (result.isEmpty) return AppSettings.defaultContainers;
    return result.length > AppSettings.maxContainers
        ? result.sublist(0, AppSettings.maxContainers)
        : result;
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final ok =
        await prefs.setString(shapeKey, settings.shape.name) &&
        await prefs.setString(themeKey, settings.theme.id) &&
        await prefs.setInt(goalKey, settings.goalMl) &&
        await prefs.setInt(glassKey, settings.glassMl) &&
        await prefs.setBool(animatedKey, settings.animatedCelebrations) &&
        await prefs.setString(
          containersKey,
          jsonEncode([for (final c in settings.containers) c.toJson()]),
        );
    if (!ok) throw StateError('Ayarlar saklanamadı');
  }
}

/// Testler için.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this._settings = const AppSettings()]);

  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async => _settings = settings;
}
