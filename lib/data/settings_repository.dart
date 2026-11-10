import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';
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

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Tür uyuşmazlığı (bozuk veri) çökmesin diye get() ile okunur.
    final shapeName = prefs.get(shapeKey);
    final themeId = prefs.get(themeKey);
    final goal = prefs.get(goalKey);
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
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final ok =
        await prefs.setString(shapeKey, settings.shape.name) &&
        await prefs.setString(themeKey, settings.theme.id) &&
        await prefs.setInt(goalKey, settings.goalMl);
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
