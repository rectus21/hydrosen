import 'package:flutter/foundation.dart';

class WaterEntry {
  const WaterEntry({required this.id, required this.amountMl, required this.time});

  final int id;
  final int amountMl;
  final DateTime time;
}

/// Geçici, bellekte tutulan denetleyici. Kalıcı depolama Aşama 2'de eklenecek;
/// uygulama kapanınca kayıtlar kaybolur.
class WaterController extends ChangeNotifier {
  WaterController({this.goalMl = 2000});

  final int goalMl;
  final List<WaterEntry> _entries = [];
  int _nextId = 1;

  List<WaterEntry> get entries => List.unmodifiable(_entries.reversed);

  int get totalMl => _entries.fold(0, (sum, e) => sum + e.amountMl);

  double get progress => goalMl == 0 ? 0 : (totalMl / goalMl).clamp(0.0, 1.0);

  void add(int amountMl) {
    if (amountMl <= 0) return;
    _entries.add(WaterEntry(id: _nextId++, amountMl: amountMl, time: DateTime.now()));
    notifyListeners();
  }

  void remove(int id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
