# CHANGES — Secuencia de Implementación

> Índice canónico de todos los changes del proyecto **LevelUp Alarm**.
> Cada change es atómico: un agente puede implementarlo en una sesión (~2-5 horas).
> **Leer este archivo antes de ejecutar cualquier `/opsx:propose`.**

---

## Cómo usar este documento

1. **Identificar el change** a trabajar (respetando dependencias — no saltear).
2. **Leer los archivos KB** listados en "Leer antes" del change elegido.
3. **Ejecutar** `/opsx:propose C-NN-nombre-del-change` para crear la propuesta + tareas.
4. **Implementar** con `/opsx:apply C-NN-nombre-del-change`.
5. **Archivar** con `/opsx:archive C-NN-nombre-del-change` y marcar el checkbox `[x]`.

---

## Árbol de dependencias

```
C-01 (foundation-setup)
└── C-02 (core-models)
    ├── C-04 (questions-bank)
    │   └── C-06 (quiz-service)
    │           └── C-08 (quiz-logic-integration)
    │                   └── C-09 (background-alarm-service)
    │                           └── C-11 (animations-and-polish)
    └── C-05 (storage-service)
            └── C-07 (alarm-list-integration)
                    └── C-09 ─────────────────────────────────┘

C-01 ──► C-03 (missing-screens-ui)
              ├── C-08 ──────────────────────────────────────┘
              └── C-10 (game-themes)
                      └── C-11 ─────────────────────────────┘
```

### Paralelismo por fase

```
GATE 0: inicio ─────────────────────────────────────────────────
  → C-01 foundation-setup             [solo, bloqueante]

GATE 1: C-01 ✓  ← PRIMER FORK
  → C-02 core-models                  [Agente A]
  → C-03 missing-screens-ui           [Agente B]

GATE 2: C-02 ✓  ← SEGUNDO FORK
  → C-04 questions-bank               [Agente A]
  → C-05 storage-service              [Agente B]

GATE 3: C-04 ✓
  → C-06 quiz-service                 [Agente A]

GATE 4: C-05 ✓
  → C-07 alarm-list-integration       [Agente B]

GATE 5: C-03 ✓ + C-06 ✓
  → C-08 quiz-logic-integration       [Agente A o B]

GATE 6: C-03 ✓
  → C-10 game-themes                  [Agente B — si C-03 ✓]

GATE 7: C-07 ✓ + C-08 ✓
  → C-09 background-alarm-service     [Agente A]

GATE 8: C-09 ✓ + C-10 ✓
  → C-11 animations-and-polish        [Agente B]
```

### Camino crítico (9 changes — mínimo irreducible a app funcionando)

```
C-01 → C-02 → C-04 → C-06 → C-08 → C-09
                  └── C-05 → C-07 ──┘
         └── C-03 ──────────────────┘
```

Versión lineal del mínimo bloqueante:
`C-01 → C-02 → C-03 → C-05 → C-04 → C-06 → C-07 → C-08 → C-09`

### Plan óptimo con 3 agentes

| Paso | Agente A (Datos/Servicios) | Agente B (UI/Pantallas) | Agente C (Integración) |
|------|---------------------------|------------------------|------------------------|
| 1 | C-01 foundation-setup | — | — |
| 2 | C-02 core-models | C-03 missing-screens-ui | — |
| 3 | C-04 questions-bank | C-05 storage-service | — |
| 4 | C-06 quiz-service | C-07 alarm-list-integration | — |
| 5 | C-08 quiz-logic-integration | C-10 game-themes | — |
| 6 | C-09 background-alarm-service | — | — |
| 7 | — | C-11 animations-and-polish | — |

---

## FASE 1 — Fundación e Infraestructura

> C-01 debe completarse antes de cualquier otro change. C-02 y C-03 pueden correr en paralelo.

### [C-01] `foundation-setup`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Agregar todas las dependencias a `pubspec.yaml`: `provider ^6.1.1`, `android_alarm_manager_plus ^3.0.3`, `flutter_local_notifications ^16.0.0`, `shared_preferences ^2.2.0`, `sqflite ^2.3.0`, `path ^1.8.3`, `just_audio ^0.9.36`, `wakelock_plus ^1.1.4`, `font_awesome_flutter ^10.6.0`
  - Correr `flutter pub get` y verificar resolución sin conflictos
  - Declarar todos los permisos en `android/app/src/main/AndroidManifest.xml`: `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `WAKE_LOCK`, `FOREGROUND_SERVICE`, `POST_NOTIFICATIONS`
  - Crear `lib/app.dart` con `MaterialApp`, tema oscuro deepPurple, rutas nombradas placeholder
  - Crear estructura de carpetas vacías: `lib/models/`, `lib/services/`, `lib/data/`, `lib/widgets/`, `lib/theme/`
  - Crear `lib/theme/app_theme.dart` con colores base: fondo `0xFF1A1A2E`, appBar `0xFF16213E`
  - Verificar `minSdkVersion` en `android/app/build.gradle` (debe ser ≥ 26 para alarmas background modernas)
  - Correr `flutter run` y confirmar que la app abre sin errores tras los cambios
- **Dependencias**: ninguna
- **Governance**: BAJO
- **Leer antes**:
  - `knowledge-base/02_descripcion_general.md` §Dependencias principales
  - `knowledge-base/03_actores_y_roles.md` §Permisos de Android
  - `knowledge-base/08_arquitectura_propuesta.md` §Estructura de directorios objetivo
  - `knowledge-base/10_preguntas_abiertas.md` §P1 (minSdkVersion)

---

### [C-02] `core-models`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Crear `lib/models/alarm.dart`: clase `Alarm` con campos `id` (String UUID), `time` (TimeOfDay), `game` (String ID), `isActive` (bool), constructor named, `toJson()` / `fromJson()` para persistencia
  - Crear `lib/models/question.dart`: clase `Question` con campos `game` (String), `text` (String), `options` (List<String> de 4 elementos), `correctIndex` (int 0-3), `difficulty` (String: easy/medium/hard), constructor `const`
  - Ambos modelos con prueba manual de serialización (en comentario o dartpad)
  - No incluye lógica de negocio — solo estructuras de datos puras
- **Dependencias**: `C-01`
- **Governance**: BAJO
- **Leer antes**:
  - `knowledge-base/04_modelo_de_datos.md` §Entidades principales
  - `knowledge-base/05_reglas_de_negocio.md` §RN-07 (formato múltiple choice)

---

## FASE 2 — UI Completa

> Depende solo de C-01. Puede correr en paralelo con C-02.

### [C-03] `missing-screens-ui`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Crear `lib/screens/alarm_ring_screen.dart`: `StatefulWidget`, fondo oscuro temático, texto "¡Alarma!" animado, hora visible, botón "Responder pregunta" que navega a `QuizScreen`. Sin sonido real todavía (placeholder).
  - Crear `lib/screens/quiz_screen.dart`: `StatefulWidget`, pregunta hardcodeada de ejemplo, 4 botones de opción (`ElevatedButton` con `lib/widgets/answer_button.dart`), lógica visual de correcto/incorrecto (color verde/rojo), navegación a `SuccessScreen` al acertar.
  - Crear `lib/screens/success_screen.dart`: `StatefulWidget`, mensaje de éxito, auto-navegación a `HomeScreen` después de 3 segundos con `Future.delayed`.
  - Crear `lib/widgets/answer_button.dart`: widget reutilizable para botones de respuesta del quiz.
  - Conectar las 3 nuevas pantallas a rutas nombradas en `lib/app.dart`.
  - Actualizar `lib/screens/home_screen.dart` para incluir botón de prueba que navega a `AlarmRingScreen` (para testing de flujo completo de UI).
- **Dependencias**: `C-01`
- **Governance**: BAJO
- **Leer antes**:
  - `knowledge-base/07_flujos_principales.md` §Flujo 3 (responder quiz) y §Diagrama de navegación
  - `knowledge-base/05_reglas_de_negocio.md` §RN-01 (no hay skip), §RN-02 (loop en fallo), §RN-09 (SuccessScreen auto-navega)
  - `knowledge-base/08_arquitectura_propuesta.md` §Estructura de directorios objetivo

---

## FASE 3 — Datos y Servicios

> C-04 y C-05 pueden correr en paralelo después de C-02. C-06 depende de C-04.

### [C-04] `questions-bank`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Crear `lib/data/pokemon_questions.dart`: `const List<Question> pokemonQuestions` con mínimo 20 preguntas (mix easy/medium/hard)
  - Crear `lib/data/lol_questions.dart`: mínimo 20 preguntas sobre League of Legends
  - Crear `lib/data/terraria_questions.dart`: mínimo 15 preguntas
  - Crear `lib/data/valorant_questions.dart`: mínimo 15 preguntas
  - Crear `lib/data/overwatch_questions.dart`: mínimo 15 preguntas
  - Crear `lib/data/warframe_questions.dart`: mínimo 15 preguntas
  - Todas las preguntas en español, con nombres propios en idioma original del juego
  - Crear `lib/data/all_questions.dart`: mapa `Map<String, List<Question>> questionsByGame` que agrupa todos los archivos
- **Dependencias**: `C-02`
- **Governance**: BAJO
- **Leer antes**:
  - `knowledge-base/04_modelo_de_datos.md` §Banco de preguntas y §Seed data de ejemplo
  - `knowledge-base/09_decisiones_y_supuestos.md` §Suposición (idioma español)

---

### [C-05] `storage-service`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Crear `lib/services/storage_service.dart`: clase `StorageService` con métodos `saveAlarms(List<Alarm>)`, `loadAlarms() → Future<List<Alarm>>`, `addAlarm(Alarm)`, `deleteAlarm(String id)`, `toggleAlarm(String id)`
  - Persistencia via `SharedPreferences` bajo la clave `"alarms"` como JSON array
  - Serialización: `Alarm.toJson()` / `Alarm.fromJson()` (implementados en C-02)
  - Inicialización del servicio en `main.dart` antes de correr la app
  - Test manual: guardar una alarma, cerrar y reabrir la app, verificar que persiste
- **Dependencias**: `C-02`
- **Governance**: BAJO
- **Leer antes**:
  - `knowledge-base/04_modelo_de_datos.md` §Persistencia (SharedPreferences)
  - `knowledge-base/05_reglas_de_negocio.md` §RN-11 (local only), §RN-03 (juego obligatorio)

---

### [C-06] `quiz-service`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Crear `lib/services/quiz_service.dart`: clase `QuizService` con método `getQuestion(String game) → Question`
  - Lógica: selección aleatoria de `questionsByGame[game]`, sin repetir la misma pregunta consecutivamente en una sesión de alarma (tracking de `lastQuestionIndex`)
  - Método `resetSession()` para limpiar el estado al cerrar la alarma
  - Integración con `all_questions.dart` del C-04
- **Dependencias**: `C-04`
- **Governance**: BAJO
- **Leer antes**:
  - `knowledge-base/05_reglas_de_negocio.md` §RN-06 (pregunta aleatoria sin repetición), §RN-08 (dificultad sin filtro en v1)
  - `knowledge-base/04_modelo_de_datos.md` §Question

---

## FASE 4 — Integración y Lógica

> C-07 y el inicio de C-08 pueden correr en paralelo. C-09 requiere C-07 y C-08 completos.

### [C-07] `alarm-list-integration`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Crear `lib/widgets/alarm_card.dart`: card visual para cada alarma en la lista (hora, nombre del juego, toggle on/off, botón de borrar)
  - Actualizar `lib/screens/home_screen.dart`: reemplazar texto placeholder por `ListView` con `AlarmCard` usando datos reales de `StorageService`
  - Crear provider `lib/providers/alarm_provider.dart` (ChangeNotifier): expone `List<Alarm> alarms`, métodos `add`, `toggle`, `delete` que llaman a `StorageService` y notifican la UI
  - Conectar provider en `main.dart` con `ChangeNotifierProvider`
  - `CreateAlarmScreen`: al guardar, llama a `alarmProvider.add(alarm)` en lugar de solo navegar
  - Eliminar botón de prueba de `HomeScreen` agregado en C-03
- **Dependencias**: `C-05`
- **Governance**: BAJO
- **Leer antes**:
  - `knowledge-base/07_flujos_principales.md` §Flujo 1 (crear alarma) y §Flujo 4 (primera apertura)
  - `knowledge-base/06_funcionalidades.md` §Épica 1 (F-01 a F-05)
  - `knowledge-base/08_arquitectura_propuesta.md` §MVVM + Provider

---

### [C-08] `quiz-logic-integration`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Actualizar `lib/screens/quiz_screen.dart`: reemplazar pregunta hardcodeada por `QuizService.getQuestion(game)`, recibir `game` como parámetro de ruta desde `AlarmRingScreen`
  - Lógica de respuesta correcta: parar sonido (cuando se implemente), llamar `Navigator.pushReplacementNamed('/success')`
  - Lógica de respuesta incorrecta: feedback visual rojo 2 segundos → `QuizService.getQuestion(game)` → mostrar nueva pregunta (RN-02)
  - Actualizar `lib/screens/alarm_ring_screen.dart`: botón "Responder pregunta" pasa el `game` a `QuizScreen`
  - `lib/screens/success_screen.dart`: `Future.delayed(Duration(seconds: 3))` → `Navigator.pushNamedAndRemoveUntil('/home', (_) => false)` (RN-09)
  - Activar `wakelock_plus` al entrar a `QuizScreen`, liberarlo al salir
- **Dependencias**: `C-03`, `C-06`
- **Governance**: MEDIO
- **Leer antes**:
  - `knowledge-base/07_flujos_principales.md` §Flujo 3 (responder quiz)
  - `knowledge-base/05_reglas_de_negocio.md` §RN-01, §RN-02, §RN-05, §RN-09
  - `knowledge-base/10_preguntas_abiertas.md` §P6 (lock screen)

---

### [C-09] `background-alarm-service`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Crear `lib/services/alarm_service.dart`: integración con `android_alarm_manager_plus` para programar callbacks a la hora exacta
  - Callback de alarma: iniciar reproducción de sonido (`just_audio`, loop), lanzar notificación via `flutter_local_notifications` que abre `AlarmRingScreen`
  - Flags de ventana para mostrar `AlarmRingScreen` sobre lock screen: `FLAG_SHOW_WHEN_LOCKED`, `FLAG_TURN_SCREEN_ON`, `FLAG_KEEP_SCREEN_ON` (requiere código nativo o plugin)
  - Registrar `AlarmService` como `BroadcastReceiver` en `AndroidManifest.xml` con intent `BOOT_COMPLETED`
  - Activar `wakelock_plus` en el callback de alarma
  - Actualizar `AlarmProvider`: al hacer `add(alarm)`, llamar `AlarmService.schedule(alarm)`; al hacer `toggle(false)` o `delete`, llamar `AlarmService.cancel(alarm.id)`
  - Probar en dispositivo físico (los emuladores son poco confiables para background alarms — RN-04)
- **Dependencias**: `C-07`, `C-08`
- **Governance**: ALTO
- **Leer antes**:
  - `knowledge-base/05_reglas_de_negocio.md` §RN-04 (background), §RN-05 (wakelock), §RN-10 (lock screen)
  - `knowledge-base/03_actores_y_roles.md` §Permisos de Android
  - `knowledge-base/07_flujos_principales.md` §Flujo 2 (disparo de alarma)
  - `knowledge-base/10_preguntas_abiertas.md` §P3 (alarmas simultáneas), §P6 (lock screen)

---

## FASE 5 — Pulido Visual

> C-10 y C-11 son opcionales para v1 pero mejoran significativamente la UX. C-10 puede correr en paralelo con C-09.

### [C-10] `game-themes`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - Actualizar `lib/theme/app_theme.dart`: agregar mapa `Map<String, Color> gameColors` con colores primario/secundario por juego (Pokémon, LoL, Terraria, Valorant, Overwatch, Warframe)
  - Actualizar `lib/screens/select_game_screen.dart`: cada `GameCard` usa el color temático del juego
  - Actualizar `lib/screens/alarm_ring_screen.dart`: fondo/acentos según `game` de la alarma activa
  - Actualizar `lib/screens/quiz_screen.dart`: borde/acentos según juego actual
  - Actualizar `lib/screens/success_screen.dart`: color de acento según juego
  - Actualizar `lib/widgets/alarm_card.dart`: indicador de color por juego en la card
- **Dependencias**: `C-03`
- **Governance**: BAJO
- **Leer antes**:
  - `knowledge-base/03_actores_y_roles.md` §Juegos soportados (tabla de colores)
  - `knowledge-base/08_arquitectura_propuesta.md` §Variables de entorno / configuración (colores base)

---

### [C-11] `animations-and-polish`
- **Estado**: `[ ]` pendiente
- **Scope**:
  - `QuizScreen`: animación de respuesta correcta (flash verde + scale up) y respuesta incorrecta (shake + flash rojo)
  - `SuccessScreen`: animación de entrada (fade in + scale), contador visual de 3 segundos (CircularProgressIndicator en reversa)
  - `AlarmRingScreen`: animación pulsante del icono de alarma (AnimatedContainer o Lottie si aplica)
  - Transiciones entre pantallas: `PageRouteBuilder` con fade/slide en lugar de push default
  - `HomeScreen` → `CreateAlarmScreen`: slide desde abajo (modal feel)
  - Feedback háptico al seleccionar respuesta (`HapticFeedback.mediumImpact()`)
- **Dependencias**: `C-08`, `C-10`
- **Governance**: BAJO
- **Leer antes**:
  - `knowledge-base/06_funcionalidades.md` §Épica 4 (F-13, F-14, F-15)
  - `knowledge-base/07_flujos_principales.md` §Flujo 3 (responder quiz)

---

## Resumen

| Change | Fase | Governance | Dependencias | Estado |
|--------|------|-----------|-------------|--------|
| C-01 foundation-setup | 1 | BAJO | — | `[ ]` |
| C-02 core-models | 1 | BAJO | C-01 | `[ ]` |
| C-03 missing-screens-ui | 2 | BAJO | C-01 | `[ ]` |
| C-04 questions-bank | 3 | BAJO | C-02 | `[ ]` |
| C-05 storage-service | 3 | BAJO | C-02 | `[ ]` |
| C-06 quiz-service | 3 | BAJO | C-04 | `[ ]` |
| C-07 alarm-list-integration | 4 | BAJO | C-05 | `[ ]` |
| C-08 quiz-logic-integration | 4 | MEDIO | C-03, C-06 | `[ ]` |
| C-09 background-alarm-service | 4 | ALTO | C-07, C-08 | `[ ]` |
| C-10 game-themes | 5 | BAJO | C-03 | `[ ]` |
| C-11 animations-and-polish | 5 | BAJO | C-08, C-10 | `[ ]` |

**Total: 11 changes | 5 fases | Camino crítico: 9 changes | 3 gates de paralelismo**

Para arrancar: `/opsx:propose C-01-foundation-setup`
