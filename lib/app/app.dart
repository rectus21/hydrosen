import 'package:flutter/material.dart';

import '../data/settings_repository.dart';
import '../data/water_repository.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_controller.dart';

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
    return MaterialApp(
      title: 'HydroSen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(repository: _repository, settings: _settings),
    );
  }
}
