import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/challenge.dart';
import '../models/challenge_question.dart';
import '../models/user_summary.dart';
import 'quiz_service.dart';

/// Number of questions embedded in a new challenge (see C-15 design D-4).
const int kChallengeQuestionCount = 5;

/// Thin wrapper over `cloud_firestore` for the challenge data model:
/// creating a duel with an embedded, frozen question set (reusing
/// `QuizService`), listing incoming/sent/history challenges, and resolving
/// the winner when the opponent submits their score. `FirebaseFirestore`
/// and `QuizService` are both injectable so tests run against
/// `fake_cloud_firestore` without a real project (see C-15 design D-4, D-7,
/// mirrors C-13/C-14 design D-7).
class ChallengeService {
  ChallengeService({FirebaseFirestore? firestore, QuizService? quizService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _quizService = quizService ?? QuizService();

  final FirebaseFirestore _firestore;
  final QuizService _quizService;

  CollectionReference<Map<String, dynamic>> get _challenges => _firestore.collection('challenges');

  /// Builds a frozen set of [count] questions for [game] by delegating to
  /// `QuizService.getRandomQuestions` and mapping each `Question` to a
  /// `ChallengeQuestion` snapshot (see C-15 design D-4).
  List<ChallengeQuestion> buildQuestionSet(String game, {int count = kChallengeQuestionCount}) {
    return _quizService
        .getRandomQuestions(game, count: count)
        .map(ChallengeQuestion.fromQuestion)
        .toList();
  }

  /// Creates a new `challenges/{autoId}` document: the proposer has already
  /// played their round ([fromScore]), the question set is frozen inside
  /// the document, and the challenge starts `pending` with no opponent
  /// score/winner yet (see C-15 design D-1, D-2, D-3).
  Future<Challenge> createChallenge({
    required String fromUid,
    required String fromUsername,
    required UserSummary opponent,
    required String game,
    required int fromScore,
    required List<ChallengeQuestion> questions,
  }) async {
    final docRef = _challenges.doc();
    final data = <String, dynamic>{
      'game': game,
      'fromUid': fromUid,
      'fromUsername': fromUsername,
      'toUid': opponent.uid,
      'toUsername': opponent.username,
      'questions': questions.map((q) => q.toMap()).toList(),
      'fromScore': fromScore,
      'toScore': null,
      'status': 'pending',
      'winnerUid': null,
      'isDraw': false,
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    };
    await docRef.set(data);

    final saved = await docRef.get();
    return Challenge.fromMap(saved.data()!, id: docRef.id);
  }

  /// Pending challenges addressed to [uid] (see C-15 design D-7).
  Future<List<Challenge>> loadIncoming(String uid) async {
    final snapshot =
        await _challenges.where('toUid', isEqualTo: uid).where('status', isEqualTo: 'pending').get();
    return _mapDocs(snapshot.docs);
  }

  /// Pending challenges originated by [uid], waiting on the opponent (see
  /// C-15 design D-7).
  Future<List<Challenge>> loadSent(String uid) async {
    final snapshot =
        await _challenges.where('fromUid', isEqualTo: uid).where('status', isEqualTo: 'pending').get();
    return _mapDocs(snapshot.docs);
  }

  /// Completed challenges where [uid] participated as proposer or opponent
  /// (two queries merged and deduplicated by id — see C-15 design D-7).
  Future<List<Challenge>> loadHistory(String uid) async {
    final asFrom =
        await _challenges.where('fromUid', isEqualTo: uid).where('status', isEqualTo: 'completed').get();
    final asTo =
        await _challenges.where('toUid', isEqualTo: uid).where('status', isEqualTo: 'completed').get();

    final byId = <String, Challenge>{};
    for (final doc in [...asFrom.docs, ...asTo.docs]) {
      byId[doc.id] = Challenge.fromMap(doc.data(), id: doc.id);
    }
    return byId.values.toList();
  }

  /// Records the opponent's [score] on a pending [challenge]: resolves the
  /// winner (a pure calculation, see `resolveWinner`) and writes `toScore`,
  /// `status`, `winnerUid`, `isDraw` and `completedAt` in a single atomic
  /// update (see C-15 design D-5).
  Future<void> submitOpponentScore({required Challenge challenge, required int score}) async {
    final result = resolveWinner(
      fromScore: challenge.fromScore,
      toScore: score,
      fromUid: challenge.fromUid,
      toUid: challenge.toUid,
    );

    await _challenges.doc(challenge.challengeId).update({
      'toScore': score,
      'status': 'completed',
      'winnerUid': result.winnerUid,
      'isDraw': result.isDraw,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// The `username` field of `users/{uid}`, or empty string if missing.
  /// Used by `ChallengesProvider` to denormalize the proposer's username
  /// (see C-15 design D-8, mirrors C-14 design D-6).
  Future<String> loadUsername(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['username'] as String? ?? '';
  }

  List<Challenge> _mapDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.map((doc) => Challenge.fromMap(doc.data(), id: doc.id)).toList();
  }
}
