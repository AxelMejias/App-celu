# Knowledge Base — LevelUp Alarm

Base de conocimiento del proyecto **LevelUp Alarm** — app Android de alarma con trivia de videojuegos, desarrollada en Flutter/Dart.

## Índice

| # | Archivo | Contenido |
|---|---------|-----------|
| 01 | [01_vision_y_objetivos.md](01_vision_y_objetivos.md) | Propósito, objetivos, alcance de v1 y backlog |
| 02 | [02_descripcion_general.md](02_descripcion_general.md) | Stack (Flutter 3.44, Dart, Android), packages, comandos |
| 03 | [03_actores_y_roles.md](03_actores_y_roles.md) | Actor único (usuario), 6 juegos, permisos Android |
| 04 | [04_modelo_de_datos.md](04_modelo_de_datos.md) | Entidades `Alarm` y `Question`, banco de preguntas |
| 05 | [05_reglas_de_negocio.md](05_reglas_de_negocio.md) | 12 reglas codificadas (trivia obligatoria, loop, persistencia) |
| 06 | [06_funcionalidades.md](06_funcionalidades.md) | Historias de usuario por épica, estado actual |
| 07 | [07_flujos_principales.md](07_flujos_principales.md) | Flujos extremo a extremo: crear alarma, background, quiz |
| 08 | [08_arquitectura_propuesta.md](08_arquitectura_propuesta.md) | MVVM + Provider, estructura de carpetas, permisos |
| 09 | [09_decisiones_y_supuestos.md](09_decisiones_y_supuestos.md) | 7 decisiones de diseño + supuestos inferidos |
| 10 | [10_preguntas_abiertas.md](10_preguntas_abiertas.md) | 7 incertidumbres priorizadas |

## Estado del proyecto (al momento de generar la KB)

- **Fase 1 (Setup):** ✅ Completa
- **Fase 2 (UI básica):** 🟡 En progreso — 3/6 pantallas hechas
- **Fase 3 (Datos y lógica):** ❌ Pendiente
- **Fase 4 (Alarmas background):** ❌ Pendiente
- **Fase 5 (Pulido):** ❌ Pendiente

## Próximo paso

Completar Fase 2: crear `alarm_ring_screen.dart`, `quiz_screen.dart` y `success_screen.dart`.
