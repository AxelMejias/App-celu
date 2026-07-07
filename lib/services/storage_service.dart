import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

class StorageService {
  static const _kAlarmsKey = 'alarms';

  Future<List<Alarm>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAlarmsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Alarm.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAlarms(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAlarmsKey, jsonEncode(alarms.map((a) => a.toJson()).toList()));
  }

  Future<void> addAlarm(Alarm alarm) async {
    final alarms = await loadAlarms();
    alarms.add(alarm);
    await saveAlarms(alarms);
  }

  Future<void> deleteAlarm(String id) async {
    final alarms = await loadAlarms();
    alarms.removeWhere((a) => a.id == id);
    await saveAlarms(alarms);
  }

  Future<void> toggleAlarm(String id) async {
    final alarms = await loadAlarms();
    final index = alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      alarms[index].isActive = !alarms[index].isActive;
    }
    await saveAlarms(alarms);
  }

  /// Replaces the alarm with a matching id, preserving its position in the
  /// persisted list. No-op if no alarm with that id exists.
  Future<void> updateAlarm(Alarm alarm) async {
    final alarms = await loadAlarms();
    final index = alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      alarms[index] = alarm;
    }
    await saveAlarms(alarms);
  }
}
