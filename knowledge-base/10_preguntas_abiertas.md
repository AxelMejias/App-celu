# 10 — Preguntas Abiertas

## P1 — `minSdkVersion` de Android [ALTA]
¿Cuál es el `minSdkVersion` definido en `android/app/build.gradle`? Esto impacta qué APIs de alarm manager están disponibles y qué permisos son necesarios. En Android 12+ (API 31) se requiere `SCHEDULE_EXACT_ALARM` y a partir de Android 13 (API 33) es necesario pedir permiso en runtime.

**Acción:** Revisar `android/app/build.gradle` → `defaultConfig.minSdkVersion`.

---

## P2 — Persistencia: SharedPreferences o SQLite para alarmas [MEDIA]
El plan actual es usar SharedPreferences para alarmas. Si más adelante se agregan recurrencias (lunes-viernes) o historial, el modelo de datos crece. ¿Arrancamos con SharedPreferences y migramos, o empezamos con SQLite desde ya?

**Suposición actual:** SharedPreferences para v1.

---

## P3 — Comportamiento con múltiples alarmas simultáneas [MEDIA]
¿Qué pasa si el usuario tiene 3 alarmas a la misma hora, o dos que se solapan? ¿Se apila una por encima de la otra, o se ignoran las posteriores?

**No definido todavía.** Registrado para cuando se implemente la lógica de background (Fase 4).

---

## P4 — Idioma de las preguntas [BAJA]
¿Las preguntas serán en español o inglés? Los términos técnicos de juegos como LoL o Valorant son frecuentemente usados en inglés por la comunidad hispanohablante.

**Suposición actual:** Español, con nombres propios de juego en su idioma original.

---

## P5 — Distribución de la app [BAJA]
¿La app se va a distribuir por APK directo, Google Play Store, o es solo para uso personal?

**Sin definir.** Impacta si se necesita firmar el APK con clave de producción y si hay restricciones adicionales de Play Store para apps de alarma (que en los últimos años han tenido restricciones de permisos).

---

## P6 — `AlarmRingScreen` sobre lock screen [ALTA]
La pantalla de alarma debe mostrarse sobre el lock screen de Android. Esto requiere flags específicos de ventana que varían entre versiones de Android. ¿Se usará `WindowManager` nativo o hay un package que lo abstraiga?

**Referencia:** `android_alarm_manager_plus` puede necesitar un plugin complementario o código nativo para los flags `FLAG_SHOW_WHEN_LOCKED` y `FLAG_TURN_SCREEN_ON`.

---

## P7 — ¿Existe un `app.dart` separado del `main.dart`? [BAJA]
La arquitectura propuesta contempla un `app.dart` para la configuración de `MaterialApp` y rutas. El `main.dart` actual hace todo junto. ¿Se refactoriza ahora o cuando crezca?

**Sin bloqueo actual.** Registrado para cuando se arme el change de arquitectura.
