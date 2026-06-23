# Spec: Android Permissions

## Purpose

Define the required Android permissions and minimum SDK configuration to support exact alarms, background execution, and notifications in the Flutter alarm application.

## Requirements

### Requirement: Permisos de alarma declarados
El sistema SHALL declarar en `AndroidManifest.xml` los permisos `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM` y `USE_EXACT_ALARM` para habilitar alarmas exactas y persistencia tras reboot.

#### Scenario: Permiso de boot presente
- **WHEN** se inspecciona `android/app/src/main/AndroidManifest.xml`
- **THEN** contiene `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>`

#### Scenario: Permisos de alarma exacta presentes
- **WHEN** se inspecciona `AndroidManifest.xml`
- **THEN** contiene `SCHEDULE_EXACT_ALARM` y `USE_EXACT_ALARM`

### Requirement: Permisos de background y pantalla declarados
El sistema SHALL declarar `WAKE_LOCK` y `FOREGROUND_SERVICE` para mantener la app activa durante la alarma, y `POST_NOTIFICATIONS` para las notificaciones en Android 13+.

#### Scenario: WAKE_LOCK declarado
- **WHEN** se inspecciona `AndroidManifest.xml`
- **THEN** contiene `<uses-permission android:name="android.permission.WAKE_LOCK"/>`

#### Scenario: POST_NOTIFICATIONS declarado
- **WHEN** la app corre en Android 13+ (API 33)
- **THEN** puede solicitar permiso de notificaciones en runtime (la declaración en Manifest es prerequisito)

### Requirement: minSdkVersion compatible con alarmas
El sistema SHALL tener `minSdkVersion` ≥ 26 en `android/app/build.gradle` para soportar `android_alarm_manager_plus`.

#### Scenario: minSdkVersion verificado
- **WHEN** se inspecciona `android/app/build.gradle`
- **THEN** `minSdkVersion` es 26 o superior
