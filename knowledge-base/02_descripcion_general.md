# 02 — Descripción General

## Stack tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Framework | Flutter | 3.44.0 (stable) |
| Lenguaje | Dart | (incluido en Flutter SDK) |
| Plataforma target | Android | API 37 (Android 17.0 "CinnamonBun") |
| IDE principal | VS Code + extensiones Flutter/Dart | — |
| IDE secundario | Android Studio Panda 4 (2025.3.4 P1) | — |
| Runtime JVM | Java JDK 21 | — |
| Flutter SDK path | `C:\flutter\sdk` | — |
| Emulador | Pixel 8 — Android 17.0 API 37 x86_64 | — |

## Arquitectura general

**Patrón:** MVVM (Model — View — ViewModel) con **Provider** para manejo de estado.

```
lib/
├── main.dart                  ← Entry point
├── app.dart                   ← MaterialApp, tema, rutas
├── models/                    ← Estructuras de datos puras
├── screens/                   ← Vistas (Widgets)
├── widgets/                   ← Componentes reutilizables
├── services/                  ← Lógica de negocio y acceso a sistema
├── data/                      ← Datos estáticos (preguntas por juego)
└── theme/                     ← Colores y estilos globales
```

## Dependencias principales (pubspec.yaml)

| Package | Versión | Propósito |
|---------|---------|-----------|
| `provider` | ^6.1.1 | Manejo de estado (ViewModel layer) |
| `android_alarm_manager_plus` | ^3.0.3 | Alarmas en background Android |
| `flutter_local_notifications` | ^16.0.0 | Notificaciones locales |
| `shared_preferences` | ^2.2.0 | Persistencia de alarmas (key-value) |
| `sqflite` | ^2.3.0 | Base de datos local (preguntas) |
| `path` | ^1.8.3 | Rutas de sistema de archivos |
| `just_audio` | ^0.9.36 | Reproducción de sonido de alarma |
| `wakelock_plus` | ^1.1.4 | Mantener pantalla encendida durante el quiz |
| `font_awesome_flutter` | ^10.6.0 | Íconos adicionales |

## Integraciones externas

Ninguna para v1.0. Todo es local (sin API, sin backend, sin autenticación).

## Convenciones de código

- **Archivos:** snake_case (ej. `home_screen.dart`)
- **Clases:** PascalCase (ej. `HomeScreen`, `AlarmService`)
- **Colores base:**
  - Fondo: `0xFF1A1A2E`
  - AppBar: `0xFF16213E`
- **Tema global:** Material oscuro con accent deepPurple

## Comandos de desarrollo

```bash
# Correr la app
flutter run                     # desde levelup_alarm/

# Instalar dependencias
flutter pub get

# Limpiar build
flutter clean && flutter pub get && flutter run

# Build para distribución
flutter build apk --release

# Diagnóstico
flutter doctor
```

> El emulador debe iniciarse manualmente desde Android Studio → Device Manager **antes** de correr `flutter run`.
