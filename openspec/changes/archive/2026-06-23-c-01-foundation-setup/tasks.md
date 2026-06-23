## 1. Dependencias de Flutter

- [x] 1.1 Abrir `pubspec.yaml` y agregar bajo `dependencies:`: `provider: ^6.1.1`, `android_alarm_manager_plus: ^3.0.3`, `flutter_local_notifications: ^16.0.0`, `shared_preferences: ^2.2.0`, `sqflite: ^2.3.0`, `path: ^1.8.3`, `just_audio: ^0.9.36`, `wakelock_plus: ^1.1.4`, `font_awesome_flutter: ^10.6.0`
- [x] 1.2 Correr `flutter pub get` desde `levelup_alarm/` y verificar que no hay errores de resolución de versiones
- [x] 1.3 Verificar que `flutter run` sigue funcionando tras agregar las dependencias (requiere flutter run manual)

## 2. Permisos Android

- [x] 2.1 Abrir `android/app/src/main/AndroidManifest.xml` y agregar antes de `<application>`: permiso `RECEIVE_BOOT_COMPLETED`
- [x] 2.2 Agregar permiso `SCHEDULE_EXACT_ALARM` en AndroidManifest.xml
- [x] 2.3 Agregar permiso `USE_EXACT_ALARM` en AndroidManifest.xml
- [x] 2.4 Agregar permiso `WAKE_LOCK` en AndroidManifest.xml
- [x] 2.5 Agregar permiso `FOREGROUND_SERVICE` en AndroidManifest.xml
- [x] 2.6 Agregar permiso `POST_NOTIFICATIONS` en AndroidManifest.xml
- [x] 2.7 Verificar `android/app/build.gradle`: confirmar que `minSdkVersion` es ≥ 26; si es menor, actualizarlo a 26 (era flutter.minSdkVersion → 21 por defecto; actualizado a 26 en build.gradle.kts)

## 3. Estructura de carpetas

- [x] 3.1 Crear `lib/models/` (vacío, agregar `.gitkeep`)
- [x] 3.2 Crear `lib/services/` (vacío, agregar `.gitkeep`)
- [x] 3.3 Crear `lib/data/` (vacío, agregar `.gitkeep`)
- [x] 3.4 Crear `lib/widgets/` (vacío, agregar `.gitkeep`)
- [x] 3.5 Crear `lib/theme/` (vacío, agregar `.gitkeep`)

## 4. Theme system

- [x] 4.1 Crear `lib/theme/app_theme.dart` con clase `AppTheme` y constantes: `static const Color background = Color(0xFF1A1A2E)` y `static const Color appBar = Color(0xFF16213E)`
- [x] 4.2 Verificar que el archivo importa `package:flutter/material.dart`

## 5. App scaffold (app.dart)

- [x] 5.1 Crear `lib/app.dart` con clase `App extends StatelessWidget` que retorna `MaterialApp` con `title: 'LevelUp Alarm'`, `theme: ThemeData(brightness: Brightness.dark, colorSchemeSeed: Colors.deepPurple, scaffoldBackgroundColor: AppTheme.background, appBarTheme: AppBarTheme(backgroundColor: AppTheme.appBar))`
- [x] 5.2 Agregar en `app.dart` las rutas nombradas: `'/'` → `HomeScreen`, `'/create-alarm'` → `CreateAlarmScreen`, `'/select-game'` → `SelectGameScreen`
- [x] 5.3 Refactorizar `lib/main.dart` para que solo contenga `void main() { runApp(const App()); }` (sin MaterialApp inline)
- [x] 5.4 Verificar que `home_screen.dart`, `create_alarm_screen.dart` y `select_game_screen.dart` siguen funcionando tras el refactor
- [x] 5.5 Correr `flutter run` y confirmar que la app abre en HomeScreen sin errores (requiere flutter run manual)
