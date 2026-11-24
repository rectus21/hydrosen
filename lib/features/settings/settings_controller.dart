import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../data/settings_repository.dart';
import '../../domain/app_settings.dart';
import '../../domain/bottle_name.dart';
import '../../domain/saved_container.dart';
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
  int get glassMl => _settings.glassMl;
  bool get animatedCelebrations => _settings.animatedCelebrations;
  List<SavedContainer> get containers => _settings.containers;

  /// Seçili temanın matara/karakter adı (özel ad ya da tema adı).
  String get bottleName => _settings.bottleName(theme);

  /// Seçili tema için kullanıcı ad verdiyse o ad, yoksa null.
  String? get customBottleName => _settings.customBottleName(theme);

  /// [t] temasının matara/karakter adı.
  String bottleNameOf(ThermosTheme t) => _settings.bottleName(t);

  Future<void> load() async {
    try {
      _settings = await _repository.load();
    } catch (_) {
      _settings = const AppSettings(); // Okunamazsa varsayılanlarla aç.
    }
    _loaded = true;
    notifyListeners();
  }

  /// Tüm ayarları [next] ile DEĞİŞTİRİR (yedekten geri yükleme). Önce depoya
  /// yazılır; yazım başarısız olursa bellekteki ayar değişmez ve hata
  /// yeniden fırlatılır.
  Future<void> restore(AppSettings next) async {
    await _repository.save(next);
    _settings = next;
    _saveFailed = false;
    notifyListeners();
  }

  Future<void> setShape(ThermosShape shape) =>
      _update(_settings.copyWith(shape: shape));

  Future<void> setTheme(ThermosTheme theme) =>
      _update(_settings.copyWith(theme: theme));

  Future<void> setGoalMl(int ml) =>
      _update(_settings.copyWith(goalMl: AppSettings.normalizeGoal(ml)));

  Future<void> setGlassMl(int ml) =>
      _update(_settings.copyWith(glassMl: AppSettings.normalizeGlass(ml)));

  Future<void> setAnimatedCelebrations(bool on) =>
      _update(_settings.copyWith(animatedCelebrations: on));

  /// [theme] için matara/karakter adını kaydeder. Ad kırpılır; boş ad ya da
  /// tema adının aynısı varsayılana döner. Uzun/uygunsuz ad kaydedilmez ve
  /// hata sonucu döner.
  Future<BottleNameResult> setBottleName(ThermosTheme theme, String raw) async {
    final result = BottleName.validate(raw);
    if (!result.isOk) return result;
    final name = result.name!;
    final next = Map<String, String>.of(_settings.bottleNames);
    if (name.isEmpty || name == theme.name) {
      next.remove(theme.id);
    } else {
      next[theme.id] = name;
    }
    await _update(_settings.copyWith(bottleNames: next));
    return result;
  }

  /// Yeni kap ekler; ad boş/miktar geçersiz veya sınır doluysa false.
  Future<bool> addContainer(String name, int ml) async {
    final n = SavedContainer.normalizeName(name);
    if (n.isEmpty || !_validMl(ml)) return false;
    final list = _settings.containers;
    if (list.length >= AppSettings.maxContainers) return false;
    final id = list.fold(0, (m, c) => math.max(m, c.id)) + 1;
    await _update(
      _settings.copyWith(
        containers: [
          ...list,
          SavedContainer(id: id, name: n, ml: ml),
        ],
      ),
    );
    return true;
  }

  /// Kabın adını/miktarını yerinde günceller (kimlik ve sıra korunur).
  Future<bool> updateContainer(int id, {String? name, int? ml}) async {
    final list = _settings.containers;
    if (!list.any((c) => c.id == id)) return false;
    final n = name == null ? null : SavedContainer.normalizeName(name);
    if ((n != null && n.isEmpty) || (ml != null && !_validMl(ml))) {
      return false;
    }
    await _update(
      _settings.copyWith(
        containers: [
          for (final c in list) c.id == id ? c.copyWith(name: n, ml: ml) : c,
        ],
      ),
    );
    return true;
  }

  /// Kabı siler; en az bir kap kalmalı, son kap silinmez (false).
  Future<bool> removeContainer(int id) async {
    final list = _settings.containers;
    if (list.length <= 1 || !list.any((c) => c.id == id)) return false;
    await _update(
      _settings.copyWith(
        containers: [
          for (final c in list)
            if (c.id != id) c,
        ],
      ),
    );
    return true;
  }

  static bool _validMl(int ml) =>
      ml >= SavedContainer.minMl && ml <= SavedContainer.maxMl;

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
