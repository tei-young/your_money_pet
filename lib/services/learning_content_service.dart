import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/learning_content_model.dart';
import '../models/quiz_model.dart';

/// 학습 콘텐츠 Firestore 서비스
class LearningContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 학습 콘텐츠 조회 (learning_contents 컬렉션)
  ///
  /// [day]: 학습 일차 (1-365)
  /// [personality]: 사용자 성향 ("safe", "balanced", "aggressive", "challenger")
  ///
  /// Returns: LearningContent 객체 또는 null (콘텐츠 없음)
  Future<LearningContent?> getLearningContent(
    int day,
    String personality,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('learning_contents')
          .where('personality', isEqualTo: personality)
          .where('day', isEqualTo: day)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ No learning content found for day=$day, personality=$personality');
        return null;
      }

      return LearningContent.fromJson(snapshot.docs.first.data());
    } catch (e) {
      debugPrint('❌ Error fetching learning content: $e');
      rethrow;
    }
  }

  /// 퀴즈 조회 (quiz_contents 컬렉션)
  ///
  /// [day]: 학습 일차 (1-365)
  /// [personality]: 사용자 성향 ("safe", "balanced", "aggressive", "challenger")
  ///
  /// Returns: Quiz 객체 또는 null (퀴즈 없음)
  Future<Quiz?> getQuiz(
    int day,
    String personality,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_contents')
          .where('personality', isEqualTo: personality)
          .where('day', isEqualTo: day)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ No quiz found for day=$day, personality=$personality');
        return null;
      }

      return Quiz.fromJson(snapshot.docs.first.data());
    } catch (e) {
      debugPrint('❌ Error fetching quiz: $e');
      rethrow;
    }
  }

  /// 학습 콘텐츠와 퀴즈를 병렬로 조회 (성능 최적화)
  ///
  /// [day]: 학습 일차 (1-365)
  /// [personality]: 사용자 성향 ("safe", "balanced", "aggressive", "challenger")
  ///
  /// Returns: (LearningContent?, Quiz?) 튜플
  Future<(LearningContent?, Quiz?)> getLearningContentWithQuiz(
    int day,
    String personality,
  ) async {
    try {
      // 병렬 로딩으로 성능 최적화
      final results = await Future.wait([
        getLearningContent(day, personality),
        getQuiz(day, personality),
      ]);

      return (results[0] as LearningContent?, results[1] as Quiz?);
    } catch (e) {
      debugPrint('❌ Error fetching learning content with quiz: $e');
      rethrow;
    }
  }

  /// quiz_link 카드의 퀴즈 ID로 퀴즈 조회
  ///
  /// [quizId]: Firestore 문서 ID
  ///
  /// Returns: Quiz 객체 또는 null (퀴즈 없음)
  Future<Quiz?> getQuizById(String quizId) async {
    try {
      final doc = await _firestore
          .collection('quiz_contents')
          .doc(quizId)
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ Quiz not found with id=$quizId');
        return null;
      }

      return Quiz.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('❌ Error fetching quiz by id: $e');
      rethrow;
    }
  }
}
