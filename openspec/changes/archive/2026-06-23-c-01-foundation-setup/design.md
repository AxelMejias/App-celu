## Context

El proyecto LevelUp Alarm tiene un `pubspec.yaml` con solo las dependencias default de Flutter y 3 pantallas funcionales. No tiene packages externos, permisos de Android, ni estructura de carpetas para servicios/modelos/datos. Este change no agrega lógica de negocio — solo instala la infraestructura sobre la cual todos los changes posteriores construyen.

Estado actual relevante:
- `lib/main.dart`: punto de entrada que configura MaterialApp directamente
- `lib/screens/`: 3 pantallas existentes (home, create_alarm, select_game)
- `android/app/src/main/AndroidManifest.xml`: vacío de permisos

## Goals / Non-Goals

**Goals:**
- Agregar todas las dependencias de Flutter necesarias para el proyecto completo
- Declarar permisos de Android en AndroidManifest.xml
- Separar la configuración de MaterialApp a `lib/app.dart`
- Crear estructura de carpetas canónica vacía
- Centralizar colores en `lib/theme/app_theme.dart`

**Non-Goals:**
- No implementar ningún service, model ni lógica de negocio
- No modificar las 3 pantallas existentes (solo el main.dart)
- No configurar `android_alarm_manager_plus` con receivers (eso es C-09)

## Decisions

**D1: Separar app.dart de main.dart**
`main.dart` solo inicializa providers y llama `runApp(App())`. `app.dart` contiene `MaterialApp`, tema, y rutas nombradas. Razón: convención estándar Flutter que mantiene el entry point limpio y facilita testing.

**D2: Rutas nombradas como strings constantes**
Definir constantes de rutas en `app.dart`: `static const String home = '/home'`, etc. Alternativa considerada: go_router — descartado por añadir complejidad innecesaria en v1.

**D3: Colores como constantes en app_theme.dart**
`class AppTheme { static const Color background = Color(0xFF1A1A2E); ... }`. No usar ThemeExtension aún — overhead innecesario para v1. Extensible si se necesita theming dinámico.

**D4: minSdkVersion = 26 (Android 8.0)**
Requerido por `android_alarm_manager_plus`. Cubre 99%+ de dispositivos Android activos. Si el `build.gradle` actual tiene un valor menor, actualizarlo.

## Risks / Trade-offs

[Risk: android_alarm_manager_plus requiere configuración nativa adicional (BroadcastReceiver en AndroidManifest)] → Mitigation: Este change solo declara los permisos básicos. La configuración del receiver se hace en C-09 cuando se implementa el servicio.

[Risk: `SCHEDULE_EXACT_ALARM` en Android 12+ requiere permiso en runtime del usuario] → Mitigation: Registrado en `10_preguntas_abiertas.md` P1. La solicitud en runtime se implementa en C-09.

[Risk: Conflictos de versiones entre packages] → Mitigation: Usar `flutter pub get` y revisar el output por conflictos. Las versiones especificadas en `CHANGES.md` C-01 son compatibles entre sí (validadas contra pubspec de proyectos similares).
