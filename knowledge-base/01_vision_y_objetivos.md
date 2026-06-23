# 01 — Visión y Objetivos

## Propósito

**LevelUp Alarm** es una app de alarma para Android que obliga al usuario a responder una pregunta de trivia de su videojuego favorito para poder apagarla. El objetivo es evitar que el usuario vuelva a dormirse al despertarse, combinando la necesidad de despertar con una actividad mental activa y temática.

## Problema que resuelve

Los usuarios apagan la alarma mecánicamente y se vuelven a dormir. Al requerir responder una pregunta del juego favorito, se fuerza un estado de alerta cognitiva real antes de poder silenciar la alarma.

## Objetivos por actor

### Usuario final
- Configurar alarmas con día/hora y juego asociado.
- Ver la lista de alarmas activas en la pantalla principal.
- Ser despertado por la alarma con sonido en loop.
- Responder una pregunta de trivia del juego elegido para apagar la alarma.
- Si falla, recibir una nueva pregunta y la alarma continúa sonando.
- Ver una pantalla de éxito al responder correctamente.

### Desarrollador (Acel)
- Construir la app en fases iterativas.
- Aprender Flutter/Dart a través del proyecto.
- Tener una base de código limpia, extensible a nuevos juegos.

## Alcance del proyecto

### Dentro del alcance (v1.0)
- App Android nativa (Flutter).
- 6 juegos soportados: Pokémon, League of Legends, Terraria, Valorant, Overwatch, Warframe.
- Alarmas con hora configurada manualmente.
- Trivia de 4 opciones (múltiple choice).
- Persistencia local de alarmas.
- Alarma funcional en background (pantalla bloqueada).

### Fuera del alcance (post v1.0)
- Versión iOS.
- Alarmas con recurrencia (lunes a viernes, etc.).
- Múltiples juegos por alarma.
- Estadísticas y progreso del usuario.
- Dificultad configurable.
- Modo "sin piedad" (3 fallos = 10 min extra de alarma).
- Backend o sincronización en la nube.
