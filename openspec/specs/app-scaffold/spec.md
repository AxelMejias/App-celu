# Spec: App Scaffold

## Purpose

Define the entry-point structure, canonical folder layout, and dependency resolution for the Flutter application, ensuring all subsequent changes have a consistent foundation to build on.

## Requirements

### Requirement: App entry point separado
El sistema SHALL tener un `lib/app.dart` que contenga `MaterialApp` con tema oscuro y rutas nombradas. `lib/main.dart` SHALL solo inicializar providers globales y llamar `runApp(const App())`.

#### Scenario: App arranca sin errores
- **WHEN** se corre `flutter run`
- **THEN** la app abre en `HomeScreen` sin errores en consola

#### Scenario: Rutas nombradas definidas
- **WHEN** se navega con `Navigator.pushNamed(context, '/create-alarm')`
- **THEN** la app navega a `CreateAlarmScreen` correctamente

### Requirement: Estructura de carpetas canónica
El sistema SHALL tener la siguiente estructura bajo `lib/`: carpetas `models/`, `services/`, `data/`, `widgets/`, `theme/` presentes en el repositorio (con archivo `.gitkeep` si están vacías).

#### Scenario: Carpetas existentes
- **WHEN** un agente ejecuta el change C-02 o C-03
- **THEN** las carpetas destino (`lib/models/`, `lib/services/`, etc.) existen y no hay que crearlas

### Requirement: Dependencias de Flutter resueltas
El sistema SHALL tener `pubspec.yaml` con los 9 packages del proyecto declarados y `flutter pub get` ejecutado exitosamente (sin errores de resolución).

#### Scenario: Packages disponibles para importar
- **WHEN** un archivo Dart hace `import 'package:provider/provider.dart'`
- **THEN** el import resuelve sin error de compilación

#### Scenario: Sin conflictos de versiones
- **WHEN** se corre `flutter pub get`
- **THEN** el output no contiene warnings de conflicto entre packages
