# 09 — Decisiones y Supuestos

## Decisiones de diseño

### D-01: Flutter sobre React Native o nativo Android
**Decisión:** Flutter (Dart).
**Razón:** Ecosistema unificado, hot reload excelente, buen soporte para background alarms con `android_alarm_manager_plus`. La intención es eventualmente portar a iOS, donde Flutter brilla.

### D-02: Provider como sistema de estado
**Decisión:** `provider ^6.1.1` (no Bloc, no Riverpod).
**Razón:** Es la solución recomendada oficialmente para apps de complejidad media-baja. Acel está aprendiendo Flutter, empezar con Provider reduce la curva.

### D-03: Preguntas como datos estáticos en Dart
**Decisión:** `const List<Question>` en archivos `.dart`, no JSON ni SQLite.
**Razón:** Menos complejidad en v1. Los archivos Dart se compilan junto a la app. Migrar a JSON bundled o SQLite es viable si el banco crece a 500+ preguntas.

### D-04: SharedPreferences para alarmas
**Decisión:** SharedPreferences con serialización JSON para persistir alarmas.
**Razón:** Una alarma tiene 3 campos. No justifica SQLite. Si se agregan recurrencias, tags, o historial, revisar.

### D-05: Nombre de archivos snake_case, clases PascalCase
**Decisión:** Convención estándar de Dart/Flutter.
**Razón:** Linting oficial de Dart lo requiere. Consistencia en todo el proyecto.

### D-06: Solo Android en v1
**Decisión:** Target inicial exclusivamente Android.
**Razón:** Las APIs de alarma en background difieren significativamente entre Android e iOS. Android es la plataforma principal del desarrollador. iOS va a requerir `BGTaskScheduler` (iOS 13+), que es un scope separado.

### D-07: Sin backend en v1
**Decisión:** App 100% offline, sin API, sin autenticación.
**Razón:** Proyecto personal/aprendizaje. El valor está en la experiencia local. Backend (estadísticas, sincronización) es post-v1.

---

## Supuestos inferidos

**Suposición:** El usuario tiene un único dispositivo Android. No hay escenario multi-dispositivo.

**Suposición:** El banco de preguntas inicial se cargará manualmente por el desarrollador (no hay CMS ni flujo de ingesta de preguntas en la app).

**Suposición:** La app se distribuirá via APK directo (sideload) o Google Play Store, no como PWA ni web.

**Suposición:** Las preguntas se escribirán en español, ya que el desarrollador es hispanohablante y el target de usuarios parece ser hispanohablante.

**Suposición:** El nivel mínimo de Android soportado es API 26 (Android 8.0 Oreo). Esto es necesario para background alarm managers modernos. Confirmar en `pubspec.yaml` → `android.minSdkVersion`.
