import 'package:flutter/foundation.dart';
import '../models/alarm.dart';
import '../services/storage_service.dart';
import '../services/alarm_scheduler.dart';

/// Pure selection rule for the startup reconcile: which alarms need to be
/// (re)scheduled when [AlarmProvider] loads. Only active alarms recur, so
/// only active alarms are returned — order preserved. Testable without any
/// platform channel.
List<Alarm> alarmsToReschedule(List<Alarm> alarms) =>
    alarms.where((a) => a.isActive).toList();

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
      // Self-healing safety net: re-schedule every active alarm on load, so
      // recurrence survives force-stop, a cleared alarm, or a failed
      // callback re-schedule. Idempotent — scheduleAlarm replaces any
      // pending alarm for the same id — and a no-op off Android.
      for (final alarm in alarmsToReschedule(_alarms)) {
        await AlarmScheduler.scheduleAlarm(alarm);
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addAlarm(Alarm alarm) async {
    await AlarmScheduler.requestPermissions();
    await _storage.addAlarm(alarm);
    if (alarm.isActive) await AlarmScheduler.scheduleAlarm(alarm);
    _alarms = await _storage.loadAlarms();
    notifyListeners();
  }

  /// Updates an existing alarm in place (matching by id, preserving list
  /// position) and reschedules it: cancels the previously scheduled alarm
  /// for that id, then schedules the updated alarm if it is active.
  Future<void> updateAlarm(Alarm alarm) async {
    await _storage.updateAlarm(alarm);
    await AlarmScheduler.cancelAlarm(alarm.id);
    if (alarm.isActive) {
      await AlarmScheduler.requestPermissions();
      await AlarmScheduler.scheduleAlarm(alarm);
    }
    _alarms = await _storage.loadAlarms();
    notifyListeners();
  }

  Future<void> deleteAlarm(String id) async {
    await _storage.deleteAlarm(id);
    await AlarmScheduler.cancelAlarm(id);
    _alarms.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> toggleAlarm(String id) async {
    await _storage.toggleAlarm(id);
    final idx = _alarms.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _alarms[idx].isActive = !_alarms[idx].isActive;
      if (_alarms[idx].isActive) {
        await AlarmScheduler.requestPermissions();
        await AlarmScheduler.scheduleAlarm(_alarms[idx]);
      } else {
        await AlarmScheduler.cancelAlarm(id);
      }
    }
    notifyListeners();
  }
}
