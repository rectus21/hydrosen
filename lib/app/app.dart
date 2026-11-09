import 'package:flutter/material.dart';

import '../data/water_repository.dart';
import '../features/home/home_screen.dart';

class HydroSenApp extends StatelessWidget {
  const HydroSenApp({super.key, this.repository});

  /// Verilmezse cihazda kalıcı depolama kullanılır; testler sahte bir depo verir.
  final WaterRepository? repository;

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
      home: HomeScreen(repository: repository ?? SharedPrefsWaterRepository()),
    );
  }
}
