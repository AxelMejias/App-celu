# 08 — Arquitectura Propuesta

## Patrón general: MVVM + Provider

```
┌─────────────────────────────────────────────────────────────┐
│  View (Screens / Widgets)                                   │
│  lib/screens/*.dart, lib/widgets/*.dart                     │
│  └── Solo UI, sin lógica de negocio                         │
├─────────────────────────────────────────────────────────────┤
│  ViewModel (Providers)                                      │
│  lib/providers/*.dart  (a crear)                            │
│  └── Estado reactivo, expone datos a la View               │
├─────────────────────────────────────────────────────────────┤
│  Model (Models + Services + Data)                           │
│  lib/models/, lib/services/, lib/data/                      │
│  └── Lógica pura, acceso a storage, banco de preguntas     │
└─────────────────────────────────────────────────────────────┘
```

## Estructura de directorios objetivo

```
levelup_alarm/
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml     ← permisos declarados acá
├── lib/
│   ├── main.dart                   ← entry point + Provider setup
│   ├── app.dart                    ← MaterialApp, tema, rutas nombradas
│   │
│   ├── models/
│   │   ├── alarm.dart
│   │   └── question.dart
│   │
│   ├── screens/
│   │   ├── home_screen.dart        ✅
│   │   ├── create_alarm_screen.dart ✅
│   │   ├── select_game_screen.dart ✅
│   │   ├── alarm_ring_screen.dart  ❌
│   │   ├── quiz_screen.dart        ❌
│   │   └── success_screen.dart     ❌
│   │
│   ├── widgets/
│   │   ├── alarm_card.dart         ← card en HomeScreen
│   │   ├── game_card.dart          ← card en SelectGameScreen
│   │   └── answer_button.dart      ← botón de opción en QuizScreen
│   │
│   ├── services/
│   │   ├── alarm_service.dart      ← disparo background (android_alarm_manager_plus)
│   │   ├── quiz_service.dart       ← pregunta aleatoria por juego
│   │   └── storage_service.dart    ← CRUD alarmas con SharedPreferences
│   │
│   ├── data/
│   │   ├── pokemon_questions.dart
│   │   ├── lol_questions.dart
│   │   ├── terraria_questions.dart
│   │   ├── valorant_questions.dart
│   │   ├── overwatch_questions.dart
│   │   └── warframe_questions.dart
│   │
│   └── theme/
│       └── app_theme.dart          ← colores base + colores por juego
│
├── assets/
│   ├── images/
│   └── sounds/
│       └── alarm_default.mp3
│
└── pubspec.yaml
```

## Decisiones de arquitectura

### Manejo de estado: Provider (no Riverpod, no Bloc)
Provider es el punto de entrada recomendado para Flutter. Suficiente para la complejidad de esta app. Se puede migrar a Riverpod si el estado crece.

### Persistencia de alarmas: SharedPreferences
Las alarmas son objetos simples (hora + juego). SharedPreferences con serialización JSON es suficiente para v1. SQLite queda reservado para el banco de preguntas si escala.

### Banco de preguntas: Dart estático
Las preguntas se definen como listas `const` en archivos Dart. No requieren base de datos para v1. Si se agregan cientos de preguntas dinámicas, considerar SQLite o un JSON bundled.

### Background alarms: android_alarm_manager_plus
Alternativa a `AlarmManager` nativo. Permite programar callbacks Dart en background. Requiere registrar la app con permisos en `AndroidManifest.xml`.

## Seguridad y permisos (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## Variables de entorno / configuración

No hay variables de entorno en v1 (sin API keys, sin backend). Configuración hardcodeada:

| Config | Valor | Archivo |
|--------|-------|---------|
| Color fondo | `0xFF1A1A2E` | `app_theme.dart` |
| Color AppBar | `0xFF16213E` | `app_theme.dart` |
| Tema base | deepPurple oscuro | `main.dart` |
| Tiempo SuccessScreen | 3 segundos | `success_screen.dart` |
| Pausa entre preguntas (fallo) | 2 segundos | `quiz_screen.dart` |
