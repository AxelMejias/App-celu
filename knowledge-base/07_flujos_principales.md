# 07 — Flujos Principales

## Flujo 1: Crear una alarma

```
HomeScreen
  └─ [FAB +] ──► CreateAlarmScreen
                    ├─ [Elegir hora] ──► TimePicker nativo Android
                    │                       └─ hora seleccionada → _selectedTime
                    │
                    ├─ [Elegir juego] ──► SelectGameScreen
                    │                       └─ juego seleccionado → Navigator.pop(context, game)
                    │                           └─ _selectedGame en CreateAlarmScreen
                    │
                    └─ [Guardar] ──► StorageService.saveAlarm(alarm)
                                        └─ Navigator.pop ──► HomeScreen
                                                                └─ lista actualizada
```

**Precondición:** El usuario debe seleccionar tanto hora como juego para poder guardar.

---

## Flujo 2: Disparo de alarma (background)

```
AlarmService (background)
  └─ Detecta hora configurada
      └─ Reproduce sonido en loop (just_audio)
      └─ Lanza notificación (flutter_local_notifications)
          └─ Abre AlarmRingScreen (sobre lock screen)
              └─ [Ir al quiz] ──► QuizScreen
```

**Notas:** Este flujo requiere que el servicio esté registrado en `AndroidManifest.xml` con los permisos de background y exact alarm.

---

## Flujo 3: Responder el quiz

```
QuizScreen
  ├─ QuizService.getQuestion(game) ──► pregunta aleatoria
  │
  ├─ Usuario selecciona opción
  │   │
  │   ├─ [CORRECTO] ──► para sonido
  │   │               ──► cancela alarma
  │   │               ──► SuccessScreen
  │   │                       └─ (3 segundos) ──► HomeScreen
  │   │
  │   └─ [INCORRECTO] ──► feedback visual (rojo)
  │                    ──► (2 segundos) ──► nueva pregunta
  │                                        └─ vuelve a QuizScreen
  │
  └─ Sonido sigue en loop hasta respuesta correcta
```

**Regla clave (RN-01, RN-02):** No hay escape. La alarma no para hasta acertar.

---

## Flujo 4: Primera apertura de la app

```
main.dart
  └─ inicializar Provider (ChangeNotifierProvider)
  └─ inicializar StorageService
      └─ cargar alarmas guardadas
          └─ HomeScreen
              ├─ [sin alarmas] ──► "No hay alarmas todavía. Presioná + para crear una."
              └─ [con alarmas] ──► lista de AlarmCard widgets
```

---

## Diagrama de navegación de pantallas

```
HomeScreen ◄──────────────────────────────────────────────────────┐
    │                                                              │
    │ [FAB +]                                                      │
    ▼                                                              │
CreateAlarmScreen ──[Elegir juego]──► SelectGameScreen            │
    │                                      │ (Navigator.pop)      │
    │ ◄─────────────────────────────────────                      │
    │ [Guardar]                                                    │
    │                                                              │
    └──► HomeScreen (actualizado)                                  │
                                                                   │
AlarmService ──► AlarmRingScreen ──► QuizScreen                    │
                                         │                         │
                                         │ [Correcto]              │
                                         ▼                         │
                                    SuccessScreen ─────────────────┘
                                         │ (3 seg auto)
```
