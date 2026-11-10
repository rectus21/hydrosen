import 'package:flutter/material.dart';

import '../data/settings_repository.dart';
import '../data/water_repository.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_controller.dart';
import 'app_look.dart';

class HydroSenApp extends StatefulWidget {
  const HydroSenApp({super.key, this.repository, this.settingsRepository});

  /// Verilmezse cihazda kalıcı depolama kullanılır; testler sahte bir depo verir.
  final WaterRepository? repository;
  final SettingsRepository? settingsRepository;

  @override
  State<HydroSenApp> createState() => _HydroSenAppState();
}

class _HydroSenAppState extends State<HydroSenApp> {
  late final SettingsController _settings;
  late final WaterRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SharedPrefsWaterRepository();
    _settings = SettingsController(
      repository: widget.settingsRepository ?? SharedPrefsSettingsRepository(),
    )..load();
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tema seçilince yalnız termos değil tüm uygulama (renkler, arka plan,
    // yazı tipleri) değişir.
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, home) => MaterialApp(
        title: 'HydroSen',
        debugShowCheckedModeBanner: false,
        theme: AppLook.of(_settings.theme).themeData,
        home: home,
      ),
      child: HomeScreen(repository: _repository, settings: _settings),
    );
  }
}
