# 03 — Actores y Roles

## Actores del sistema

### Usuario final
El único actor de la app. Persona que quiere ser despertada con un mecanismo que le impida volver a dormirse. Tiene interés en uno o más de los 6 juegos soportados.

**No existe autenticación.** La app es single-user, local, sin cuentas ni login.

## Flujo de interacción por pantalla

| Pantalla | Actor | Acción |
|----------|-------|--------|
| `HomeScreen` | Usuario | Ver alarmas activas, crear nueva alarma |
| `CreateAlarmScreen` | Usuario | Elegir hora y juego |
| `SelectGameScreen` | Usuario | Seleccionar uno de los 6 juegos |
| `AlarmRingScreen` | Sistema → Usuario | La alarma suena, usuario ve la pantalla de alarma |
| `QuizScreen` | Usuario | Responde pregunta de trivia para apagar la alarma |
| `SuccessScreen` | Sistema | Confirma éxito, vuelve sola a HomeScreen en 3 segundos |

## Juegos soportados (actores de dominio)

Cada juego es una categoría de trivia con su propio banco de preguntas y color temático:

| ID | Nombre | Color temático (referencia) |
|----|--------|-----------------------------|
| `pokemon` | Pokémon | Amarillo/Rojo |
| `lol` | League of Legends | Azul/Dorado |
| `terraria` | Terraria | Verde/Marrón |
| `valorant` | Valorant | Rojo/Blanco |
| `overwatch` | Overwatch | Naranja/Azul |
| `warframe` | Warframe | Gris metálico/Dorado |

## Permisos de Android requeridos

Dado que no hay roles de usuario, los "permisos" en este contexto son permisos del sistema Android que la app necesita declarar en `AndroidManifest.xml`:

| Permiso | Para qué |
|---------|----------|
| `RECEIVE_BOOT_COMPLETED` | Restaurar alarmas al reiniciar el dispositivo |
| `SCHEDULE_EXACT_ALARM` | Disparar alarmas a la hora exacta (Android 12+) |
| `USE_EXACT_ALARM` | Alternativa en Android 13+ |
| `WAKE_LOCK` | Mantener la pantalla encendida durante el quiz |
| `FOREGROUND_SERVICE` | Correr el servicio de alarma en background |
| `POST_NOTIFICATIONS` | Mostrar notificación cuando suena la alarma (Android 13+) |

> **Nota:** Los permisos de alarma exacta en Android 12+ requieren que el usuario los autorice manualmente desde Ajustes del sistema.
