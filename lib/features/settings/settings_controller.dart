import 'package:flutter/foundation.dart';

import '../../data/settings_repository.dart';
import '../../domain/app_settings.dart';
import '../thermos/thermos_theme.dart';

/// Ayarların durumu. Değişiklik hemen yansır, ardından kalıcı olarak saklanır.
class SettingsController extends ChangeNotifier {
  SettingsController({required this._repository});

  final SettingsRepository _repository;

  AppSettings _settings = const AppSettings();
  bool _loaded = false;
  bool _saveFailed = false;

  bool get loaded => _loaded;

  /// Son kaydetme denemesi başarısız olduysa true.
  bool get saveFailed => _saveFailed;
  AppSettings get settings => _settings;
  ThermosShape get shape => _settings.shape;
  ThermosTheme get theme => _settings.theme;
  int get goalMl => _settings.goalMl;

  Future<void> load() async {
    try {
      _settings = await _repository.load();
    } catch (_) {
      _settings = const AppSettings(); // Okunamazsa varsayılanlarla aç.
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setShape(ThermosShape shape) =>
      _update(_settings.copyWith(shape: shape));

  Future<void> setTheme(ThermosTheme theme) =>
      _update(_settings.copyWith(theme: theme));

  Future<void> setGoalMl(int ml) =>
      _update(_settings.copyWith(goalMl: AppSettings.normalizeGoal(ml)));

  Future<void> _update(AppSettings next) async {
    _settings = next;
    notifyListeners();
    try {
      await _repository.save(next);
      _saveFailed = false;
    } catch (_) {
      _saveFailed = true;
    }
    notifyListeners();
  }
}
