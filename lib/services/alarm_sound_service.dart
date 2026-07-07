import 'dart:async' show unawaited;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:just_audio/just_audio.dart' show AudioPlayer, LoopMode;
import 'package:wakelock_plus/wakelock_plus.dart' show WakelockPlus;

/// Bundled looping alarm clip asset path (see design.md D-6). `.wav` here —
/// the shipped asset is `assets/sounds/alarm.wav` (substituted for the
/// `alarm.mp3` referenced in the planning artifacts).
const String _alarmAsset = 'assets/sounds/alarm.wav';

/// Looping alarm audio + screen wake-lock, active only during the
/// alarm-triggered flow (`AlarmRingScreen` -> `QuizScreen` -> `SuccessScreen`).
///
/// Screens never touch `just_audio`/`wakelock_plus` directly; they call
/// through this seam so they stay unit-testable with a mock, and so the
/// start/stop idempotency contract can be verified without any platform
/// channel (see openspec/changes/c-19-alarm-ringing/design.md, D-2/D-3).
abstract class AlarmSoundService {
  /// Starts the alarm loop + wake-lock. Idempotent: calling this while
  /// already ringing has no additional effect.
  Future<void> startRinging();

  /// Stops the alarm loop + releases the wake-lock. Idempotent: calling
  /// this while idle has no effect.
  Future<void> stopRinging();

  /// Whether the alarm is currently ringing.
  bool get isRinging;
}

/// Thin seam over the looping-audio plugin, so [RealAlarmSoundService] can
/// be unit-tested with a mock instead of a real `just_audio` `AudioPlayer`.
abstract class AudioLoop {
  Future<void> play();
  Future<void> stop();
}

/// Thin seam over the screen wake-lock plugin, so [RealAlarmSoundService]
/// can be unit-tested with a mock instead of the real `wakelock_plus` API.
abstract class ScreenWakeLock {
  Future<void> enable();
  Future<void> disable();
}

/// Pure start/stop state machine that delegates side effects to its
/// injected [AudioLoop] and [ScreenWakeLock] collaborators. See design.md
/// D-3 for the full contract.
class RealAlarmSoundService implements AlarmSoundService {
  // Field names are private (`_audio`/`_wakeLock`) for encapsulation while
  // the constructor keeps public parameter names per the design contract,
  // so an initializing formal (`this._audio`) isn't usable here.
  RealAlarmSoundService({required AudioLoop audio, required ScreenWakeLock wakeLock})
      // ignore: prefer_initializing_formals
      : _audio = audio,
        // ignore: prefer_initializing_formals
        _wakeLock = wakeLock;

  /// Wires the real `just_audio`/`wakelock_plus` collaborators. Installed by
  /// `main()` before `runApp` (see design.md D-2).
  factory RealAlarmSoundService.platform() => RealAlarmSoundService(
        audio: JustAudioLoop(),
        wakeLock: WakelockPlusScreenLock(),
      );

  final AudioLoop _audio;
  final ScreenWakeLock _wakeLock;
  bool _ringing = false;

  @override
  bool get isRinging => _ringing;

  @override
  Future<void> startRinging() async {
    if (_ringing) return;
    _ringing = true;
    await _wakeLock.enable();
    await _audio.play();
  }

  @override
  Future<void> stopRinging() async {
    if (!_ringing) return;
    _ringing = false;
    await _audio.stop();
    await _wakeLock.disable();
  }
}

/// Wraps a `just_audio` [AudioPlayer] as an [AudioLoop]. Never crashes the
/// alarm flow on a plugin failure — every call is guarded and logs via
/// [debugPrint] instead of rethrowing (no silent catch: see design.md,
/// Risks/Trade-offs).
class JustAudioLoop implements AudioLoop {
  JustAudioLoop() {
    // Preparación anticipada en el arranque: la init de ExoPlayer + carga
    // del asset puede tardar varios segundos en frío, y pagarla dentro del
    // primer play() hacía que la alarma apareciera muda unos segundos.
    unawaited(_prepare().catchError((Object e) {
      debugPrint('JustAudioLoop.preload failed (se reintenta en play): $e');
    }));
  }

  final AudioPlayer _player = AudioPlayer();
  Future<void>? _preparing;

  /// Carga el asset y el modo loop una sola vez; si falla, permite
  /// reintentar en el próximo llamado.
  Future<void> _prepare() => _preparing ??= _doPrepare();

  Future<void> _doPrepare() async {
    try {
      await _player.setAsset(_alarmAsset);
      await _player.setLoopMode(LoopMode.one);
    } catch (e) {
      _preparing = null;
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    try {
      await _prepare();
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      debugPrint('JustAudioLoop.play failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      // pause (no stop): stop() desarma los buffers y el próximo play
      // volvería a pagar la preparación completa.
      await _player.pause();
    } catch (e) {
      debugPrint('JustAudioLoop.stop failed: $e');
    }
  }
}

/// Wraps `wakelock_plus` as a [ScreenWakeLock]. Guarded the same way as
/// [JustAudioLoop] — a plugin failure never crashes the alarm flow.
class WakelockPlusScreenLock implements ScreenWakeLock {
  @override
  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      debugPrint('WakelockPlusScreenLock.enable failed: $e');
    }
  }

  @override
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('WakelockPlusScreenLock.disable failed: $e');
    }
  }
}

/// Safe default: every widget test and the pre-platform-init boot get a
/// harmless no-op, so nothing touches a plugin until `main()` installs the
/// real implementation.
class NoopAlarmSoundService implements AlarmSoundService {
  @override
  bool get isRinging => false;

  @override
  Future<void> startRinging() async {}

  @override
  Future<void> stopRinging() async {}
}

/// Swappable global instance. Defaults to [NoopAlarmSoundService]; `main()`
/// swaps it for a [RealAlarmSoundService] before `runApp` (see design.md D-2).
AlarmSoundService alarmSound = NoopAlarmSoundService();
