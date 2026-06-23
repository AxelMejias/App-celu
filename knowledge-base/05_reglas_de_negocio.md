# 05 — Reglas de Negocio

## Dominio: Alarma

**RN-01 — Obligatoriedad de trivia**
Una alarma NO puede apagarse sin responder correctamente una pregunta de trivia. No existe botón de "snooze" ni "skip".

**RN-02 — Loop ante respuesta incorrecta**
Si el usuario responde incorrectamente, la alarma continúa sonando y se presenta una nueva pregunta (distinta a la anterior). El proceso se repite hasta acertar.

**RN-03 — Juego obligatorio al crear alarma**
No se puede guardar una alarma sin haber seleccionado un juego. El juego determina el banco de trivia.

**RN-04 — Alarma en background**
La alarma debe dispararse aunque la app esté cerrada o la pantalla bloqueada. Se implementa con `android_alarm_manager_plus`.

**RN-05 — Pantalla encendida durante quiz**
Mientras la pregunta está visible, la pantalla debe mantenerse encendida (`wakelock_plus`).

## Dominio: Trivia

**RN-06 — Pregunta aleatoria**
`QuizService` selecciona una pregunta al azar del banco del juego asociado a la alarma. No debe repetir la misma pregunta consecutivamente en una misma sesión de alarma.

**RN-07 — Formato múltiple choice**
Toda pregunta tiene exactamente 4 opciones y una sola correcta (índice `correctIndex`).

**RN-08 — Dificultad única en v1**
En v1.0 todas las preguntas se mezclan sin filtro de dificultad. La dificultad se almacena para uso futuro.

## Dominio: Pantallas

**RN-09 — SuccessScreen auto-navega**
Al responder correctamente, `SuccessScreen` espera 3 segundos y navega automáticamente a `HomeScreen` sin intervención del usuario.

**RN-10 — AlarmRingScreen desde locked screen**
La `AlarmRingScreen` debe poder mostrarse encima del lock screen de Android. Requiere flags específicos de ventana (`FLAG_SHOW_WHEN_LOCKED`, `FLAG_TURN_SCREEN_ON`).

## Dominio: Datos

**RN-11 — Persistencia local solamente**
No existe sincronización remota. Todas las alarmas se guardan en `SharedPreferences`. Si el usuario desinstala la app, los datos se pierden.

**RN-12 — Mínimo de preguntas por juego**
Un juego no debería usarse en producción con menos de 10 preguntas. El mínimo para lanzar es 15–20 según el juego (ver `04_modelo_de_datos.md`).
