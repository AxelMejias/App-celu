import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Alarm {
  final String id;
  final TimeOfDay time;
  final String game;
  bool isActive;

  Alarm({
    String? id,
    required this.time,
    required this.game,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': {'hour': time.hour, 'minute': time.minute},
        'game': game,
        'isActive': isActive,
      };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
        id: json['id'] as String,
        time: TimeOfDay(
          hour: (json['time'] as Map)['hour'] as int,
          minute: (json['time'] as Map)['minute'] as int,
        ),
        game: json['game'] as String,
        isActive: json['isActive'] as bool,
      );
}
