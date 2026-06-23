## ADDED Requirements

### Requirement: Colores base centralizados
El sistema SHALL tener `lib/theme/app_theme.dart` con una clase `AppTheme` que exponga los colores base del proyecto como constantes estáticas: `background` (`Color(0xFF1A1A2E)`), `appBar` (`Color(0xFF16213E)`).

#### Scenario: Color de fondo accesible
- **WHEN** cualquier pantalla necesita el color de fondo
- **THEN** puede usar `AppTheme.background` en lugar de hardcodear el valor hex

#### Scenario: Consistencia visual
- **WHEN** se revisa el código de cualquier pantalla existente o nueva
- **THEN** no existen colores hex hardcodeados que coincidan con los valores de `AppTheme` (todos usan la constante)

### Requirement: Tema global Material oscuro
El sistema SHALL configurar `ThemeData` en `app.dart` con `brightness: Brightness.dark`, `colorSchemeSeed: Colors.deepPurple` y `scaffoldBackgroundColor: AppTheme.background`.

#### Scenario: Tema aplicado globalmente
- **WHEN** la app abre en cualquier pantalla
- **THEN** el fondo es `0xFF1A1A2E` y el acento primario es deepPurple, sin necesidad de configurarlo por pantalla

#### Scenario: AppBar usa color correcto
- **WHEN** cualquier pantalla muestra un `AppBar`
- **THEN** el color de fondo del AppBar es `AppTheme.appBar` (`0xFF16213E`) por defecto del tema
