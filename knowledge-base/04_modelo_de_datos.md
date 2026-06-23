# 04 — Modelo de Datos

## Entidades principales

### Alarm (lib/models/alarm.dart)

Representa una alarma configurada por el usuario.

```dart
class Alarm {
  final String id;          // UUID generado al crear
  final TimeOfDay time;     // Hora de la alarma
  final String game;        // ID del juego (ej. "pokemon")
  bool isActive;            // Si la alarma está habilitada

  Alarm({
    required this.id,
    required this.time,
    required this.game,
    this.isActive = true,
  });
}
```

**Persistencia:** SharedPreferences (serialización JSON). Clave: `"alarms"` → lista JSON.

---

### Question (lib/models/question.dart)

Representa una pregunta de trivia.

```dart
class Question {
  final String game;              // "pokemon", "lol", etc.
  final String text;              // Enunciado de la pregunta
  final List<String> options;     // 4 opciones de respuesta
  final int correctIndex;         // Índice correcto (0–3)
  final String difficulty;        // "easy" | "medium" | "hard"

  const Question({
    required this.game,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
  });
}
```

**Persistencia:** Datos estáticos en Dart (`const List<Question>`), uno por juego en `lib/data/`. No requieren base de datos a menos que se expandan significativamente.

---

## Relaciones

```
Alarm (1) ──── (1) Juego (string ID)
                        │
                        ▼
              Question Bank por juego
              (lib/data/{game}_questions.dart)
```

Una alarma referencia un juego por ID. Al sonar, `QuizService` usa ese ID para filtrar las preguntas del banco correspondiente.

---

## Banco de preguntas (lib/data/)

| Archivo | Juego | Mínimo para lanzar | Objetivo |
|---------|-------|--------------------|---------|
| `pokemon_questions.dart` | Pokémon | 20 | 100+ |
| `lol_questions.dart` | League of Legends | 20 | 100+ |
| `terraria_questions.dart` | Terraria | 15 | 80+ |
| `valorant_questions.dart` | Valorant | 15 | 80+ |
| `overwatch_questions.dart` | Overwatch | 15 | 80+ |
| `warframe_questions.dart` | Warframe | 15 | 80+ |

---

## Seed data de ejemplo (Pokémon)

```dart
const List<Question> pokemonQuestions = [
  Question(
    game: "pokemon",
    text: "¿Cuántos Pokémon hay en la primera generación?",
    options: ["121", "151", "175", "100"],
    correctIndex: 1,
    difficulty: "easy",
  ),
  Question(
    game: "pokemon",
    text: "¿Qué tipo es efectivo contra tipo Dragón?",
    options: ["Fuego", "Agua", "Hielo", "Planta"],
    correctIndex: 2,
    difficulty: "easy",
  ),
  Question(
    game: "pokemon",
    text: "¿Cuál es el Pokémon más pesado de la primera generación?",
    options: ["Snorlax", "Golem", "Onix", "Kangaskhan"],
    correctIndex: 0,
    difficulty: "medium",
  ),
];
```
