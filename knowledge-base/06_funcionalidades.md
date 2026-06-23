# 06 — Funcionalidades

## Épica 1: Gestión de alarmas

| ID | Historia | Estado |
|----|----------|--------|
| F-01 | Como usuario, quiero ver la lista de mis alarmas activas en la pantalla principal | 🟡 UI parcial (HomeScreen sin alarmas reales) |
| F-02 | Como usuario, quiero crear una alarma eligiendo hora y juego | ✅ UI hecha (CreateAlarmScreen + SelectGameScreen) |
| F-03 | Como usuario, quiero que mis alarmas persistan aunque cierre la app | ❌ Pendiente (storage_service) |
| F-04 | Como usuario, quiero activar/desactivar una alarma sin borrarla | ❌ Pendiente |
| F-05 | Como usuario, quiero eliminar una alarma | ❌ Pendiente |

## Épica 2: Alarma en background

| ID | Historia | Estado |
|----|----------|--------|
| F-06 | Como usuario, quiero que la alarma suene a la hora configurada aunque la app esté cerrada | ❌ Pendiente (Fase 4) |
| F-07 | Como usuario, quiero que la alarma suene con la pantalla bloqueada | ❌ Pendiente (Fase 4) |
| F-08 | Como usuario, quiero que la alarma suene en loop hasta que la apague | ❌ Pendiente |

## Épica 3: Quiz de trivia

| ID | Historia | Estado |
|----|----------|--------|
| F-09 | Como usuario, quiero ver una pregunta del juego elegido al sonar la alarma | 🟡 UI básica hardcodeada pendiente (quiz_screen.dart) |
| F-10 | Como usuario, quiero elegir entre 4 opciones de respuesta | 🟡 Pendiente |
| F-11 | Como usuario, si respondo bien, quiero que la alarma se apague | ❌ Pendiente |
| F-12 | Como usuario, si respondo mal, quiero recibir una nueva pregunta y que la alarma siga | ❌ Pendiente |
| F-13 | Como usuario, quiero ver feedback visual al responder (correcto/incorrecto) | ❌ Pendiente (Fase 5) |

## Épica 4: Experiencia visual

| ID | Historia | Estado |
|----|----------|--------|
| F-14 | Como usuario, quiero ver la pantalla de éxito al responder bien | ❌ Pendiente (success_screen.dart) |
| F-15 | Como usuario, quiero que cada juego tenga colores temáticos en la UI | ❌ Pendiente (Fase 5) |
| F-16 | Como usuario, quiero ver la alarma sonando con la pantalla de la alarma activa | ❌ Pendiente (alarm_ring_screen.dart) |

## Épica 5: Funcionalidades post-v1

| ID | Idea | Estado |
|----|------|--------|
| F-17 | Alarmas recurrentes (lunes a viernes, etc.) | 📋 Backlog |
| F-18 | Estadísticas de aciertos/errores | 📋 Backlog |
| F-19 | Dificultad configurable por alarma | 📋 Backlog |
| F-20 | Múltiples juegos en la misma alarma | 📋 Backlog |
| F-21 | Modo "sin piedad" (3 fallos = 10 min extra) | 📋 Backlog |
| F-22 | Soporte iOS | 📋 Backlog |

---

**Leyenda:** ✅ Hecho | 🟡 En progreso / UI parcial | ❌ Pendiente | 📋 Backlog
