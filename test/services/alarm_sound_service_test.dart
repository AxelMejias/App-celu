import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/services/alarm_sound_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioLoop extends Mock implements AudioLoop {}

class MockScreenWakeLock extends Mock implements ScreenWakeLock {}

void main() {
  late MockAudioLoop audio;
  late MockScreenWakeLock wakeLock;
  late RealAlarmSoundService service;

  setUp(() {
    audio = MockAudioLoop();
    wakeLock = MockScreenWakeLock();
    when(() => audio.play()).thenAnswer((_) async {});
    when(() => audio.stop()).thenAnswer((_) async {});
    when(() => wakeLock.enable()).thenAnswer((_) async {});
    when(() => wakeLock.disable()).thenAnswer((_) async {});
    service = RealAlarmSoundService(audio: audio, wakeLock: wakeLock);
  });

  group('RealAlarmSoundService', () {
    test('startRinging while idle enables wake-lock and plays audio once, and sets isRinging',
        () async {
      await service.startRinging();

      verify(() => wakeLock.enable()).called(1);
      verify(() => audio.play()).called(1);
      expect(service.isRinging, isTrue);
    });

    test('startRinging again while already ringing triggers no additional calls (idempotent)',
        () async {
      await service.startRinging();
      await service.startRinging();

      verify(() => wakeLock.enable()).called(1);
      verify(() => audio.play()).called(1);
      expect(service.isRinging, isTrue);
    });

    test('stopRinging while ringing stops audio and disables wake-lock once, and clears isRinging',
        () async {
      await service.startRinging();

      await service.stopRinging();

      verify(() => audio.stop()).called(1);
      verify(() => wakeLock.disable()).called(1);
      expect(service.isRinging, isFalse);
    });

    test('stopRinging while idle triggers no calls (idempotent)', () async {
      await service.stopRinging();

      verifyNever(() => audio.stop());
      verifyNever(() => wakeLock.disable());
      expect(service.isRinging, isFalse);
    });
  });
}
