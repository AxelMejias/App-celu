# LevelUp Alarm ⏰🎮

Una alarma que no se apaga hasta que demuestres que estás despierto: para silenciarla tenés que responder correctamente una pregunta de trivia del videojuego que elijas.

Además de las alarmas, incluye una capa social completa: cuentas de usuario, estadísticas en la nube, amigos y desafíos de trivia asincrónicos entre jugadores.

## Screenshots

| Perfil y estadísticas | Amigos | Desafíos | Nueva alarma |
|:---:|:---:|:---:|:---:|
| ![Perfil](docs/screenshots/profile.png) | ![Amigos](docs/screenshots/friends.png) | ![Desafíos](docs/screenshots/challenges.png) | ![Nueva alarma](docs/screenshots/create_alarm.png) |

## Features

**Alarmas con trivia**
- Alarmas exactas que sobreviven reinicios del dispositivo (`android_alarm_manager_plus` + notificación full-screen)
- Para apagar la alarma hay que responder bien una pregunta del juego elegido; si errás, viene otra pregunta
- Banco de 103 preguntas de 6 juegos: Pokémon, League of Legends, Terraria, Valorant, Overwatch y Warframe
- Tema visual propio por juego (colores, íconos)

**Social (Firebase)**
- Registro e inicio de sesión con email/contraseña y Google Sign-In
- Perfil con estadísticas por juego persistidas en Firestore: respondidas, correctas, racha actual y mejor racha
- Sistema de amigos: búsqueda por username, solicitudes, y perfiles de amigos con sus estadísticas
- Desafíos asincrónicos entre amigos: ambos responden el mismo set de preguntas congelado y gana quien acierte más

## Stack

| Capa | Tecnología |
|---|---|
| UI | Flutter (Material 3, animaciones custom) |
| Estado | `provider` (ChangeNotifier + ProxyProvider) |
| Backend | Firebase Auth + Cloud Firestore (reglas de seguridad auth-scoped) |
| Alarmas | `android_alarm_manager_plus`, `flutter_local_notifications` (full-screen intent) |
| Persistencia local | `shared_preferences` |
| Tests | `flutter_test`, `mocktail`, `fake_cloud_firestore` — **185+ tests** |

## Arquitectura

```
lib/
├── models/      # Entidades puras (Alarm, Question, GameStats, Challenge, ...)
├── services/    # Acceso a plataforma y datos (AuthService, ProfileService,
│                #   FriendsService, ChallengeService, AlarmScheduler, ...)
├── providers/   # Estado observable (AuthProvider, AlarmProvider, ...)
├── screens/     # UI por pantalla
├── widgets/     # Componentes reutilizables (AuthGate, AnswerButton, ...)
├── data/        # Banco de preguntas por juego
└── theme/       # AppTheme + GameTheme por juego
```

Principios que sigue el proyecto:

- **Servicios inyectables**: todo acceso a Firebase/plataforma está detrás de una clase inyectable, así la lógica se testea con dobles (`mocktail`, `fake_cloud_firestore`) sin tocar servicios reales.
- **Modelos libres de infraestructura**: las entidades no importan Firestore; la (de)serialización vive en los servicios.
- **TDD estricto**: cada feature se desarrolló con ciclo RED → GREEN → REFACTOR; la suite corre completa en segundos.
- **Spec-driven development**: cada cambio nace de una propuesta con specs y tareas antes de escribir código.

## Cómo correrlo

Requisitos: Flutter SDK, Android SDK (minSdk 26), y un proyecto de Firebase propio.

```bash
git clone https://github.com/AxelMejias/App-celu.git
cd App-celu
flutter pub get

# Configurar Firebase (genera lib/firebase_options.dart y google-services.json)
dart pub global activate flutterfire_cli
flutterfire configure

flutter run
```

> `android/app/google-services.json` no está en el repo — cada quien usa su propio proyecto de Firebase. En Firebase Console hay que habilitar **Authentication** (Email/Password y Google) y **Cloud Firestore**. Las reglas de seguridad están en [`firestore.rules`](firestore.rules) y se despliegan con `firebase deploy --only firestore:rules`.

## Tests

```bash
flutter test      # suite completa
flutter analyze   # cero warnings
```

---

Hecho por [Axel Mejias](https://github.com/AxelMejias) 🇦🇷
