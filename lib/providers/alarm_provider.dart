import 'package:flutter/foundation.dart';
import '../models/alarm.dart';
import '../services/storage_service.dart';

class AlarmProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Alarm> _alarms = [];

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  AlarmProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _alarms = await _storage.loadAlarms();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addAlarm(Alarm alarm) async {
    await _storage.addAlarm(alarm);
    _alarms = await _storage.loadAlarms();
    notifyListeners();
  }

  Future<void> deleteAlarm(String id) async {
    await _storage.deleteAlarm(id);
    _alarms.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> toggleAlarm(String id) async {
    await _storage.toggleAlarm(id);
    final idx = _alarms.indexWhere((a) => a.id == id);
    if (idx != -1) _alarms[idx].isActive = !_alarms[idx].isActive;
    notifyListeners();
  }
}
