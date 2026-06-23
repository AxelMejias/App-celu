## Why

El proyecto LevelUp Alarm tiene la estructura de pantallas básica en pie pero carece de las dependencias de Flutter, los permisos de Android y la organización de carpetas necesarios para implementar cualquier funcionalidad real (alarmas en background, quiz, persistencia). Sin este foundation, ningún change posterior puede avanzar.

## What Changes

- Agregar 9 packages al `pubspec.yaml` (provider, android_alarm_manager_plus, flutter_local_notifications, shared_preferences, sqflite, path, just_audio, wakelock_plus, font_awesome_flutter)
- Declarar 6 permisos en `android/app/src/main/AndroidManifest.xml` (RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM, WAKE_LOCK, FOREGROUND_SERVICE, POST_NOTIFICATIONS)
- Crear `lib/app.dart` con MaterialApp, tema oscuro y rutas nombradas
- Crear estructura de carpetas vacías: `lib/models/`, `lib/services/`, `lib/data/`, `lib/widgets/`, `lib/theme/`
- Crear `lib/theme/app_theme.dart` con colores base del proyecto
- Verificar y documentar `minSdkVersion` en `android/app/build.gradle`

## Capabilities

### New Capabilities
- `app-scaffold`: Estructura de carpetas, `app.dart`, sistema de rutas nombradas y tema global
- `android-permissions`: Declaración de permisos necesarios en AndroidManifest.xml para alarmas background y notificaciones
- `theme-system`: Colores base centralizados en `app_theme.dart`

### Modified Capabilities
- (ninguna — no hay specs existentes aún)

## Impact

- `pubspec.yaml` — agregado de dependencias (bloqueante: sin esto ningún package del proyecto puede importarse)
- `android/app/src/main/AndroidManifest.xml` — declaración de permisos
- `android/app/build.gradle` — verificación de minSdkVersion
- `lib/main.dart` — refactor para delegar a `app.dart`
- Estructura de directorios de `lib/` — creación de carpetas canónicas
