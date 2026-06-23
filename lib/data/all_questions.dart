import '../models/question.dart';
import 'pokemon_questions.dart';
import 'lol_questions.dart';
import 'terraria_questions.dart';
import 'valorant_questions.dart';
import 'overwatch_questions.dart';
import 'warframe_questions.dart';

const Map<String, List<Question>> questionsByGame = {
  'pokemon': pokemonQuestions,
  'lol': lolQuestions,
  'terraria': terrariaQuestions,
  'valorant': valorantQuestions,
  'overwatch': overwatchQuestions,
  'warframe': warframeQuestions,
};
