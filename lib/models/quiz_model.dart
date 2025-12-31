import 'package:cloud_firestore/cloud_firestore.dart';

/// 퀴즈 모델 (Firestore: quiz_contents)
class Quiz {
  final int day;
  final String personality; // "safe", "balanced", "aggressive", "challenger"
  final List<QuizQuestion> questions;
  final int totalPoints;
  final int passingScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Quiz({
    required this.day,
    required this.personality,
    required this.questions,
    required this.totalPoints,
    required this.passingScore,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore 문서에서 변환
  factory Quiz.fromJson(Map<String, dynamic> json) {
    final questionsList = (json['questions'] as List)
        .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList();

    // 질문을 order로 정렬
    questionsList.sort((a, b) => a.order.compareTo(b.order));

    return Quiz(
      day: json['day'] as int,
      personality: json['personality'] as String,
      questions: questionsList,
      totalPoints: json['totalPoints'] as int,
      passingScore: json['passingScore'] as int,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'personality': personality,
      'questions': questions.map((q) => q.toJson()).toList(),
      'totalPoints': totalPoints,
      'passingScore': passingScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// 퀴즈 질문 모델
class QuizQuestion {
  final int order;
  final String question;
  final List<QuizOption> options; // 배열 순서 보장 (order 필드 없음)
  final int points;

  const QuizQuestion({
    required this.order,
    required this.question,
    required this.options,
    required this.points,
  });

  /// JSON에서 변환
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      order: json['order'] as int,
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
          .toList(), // 배열 순서 유지, 정렬 불필요
      points: json['points'] as int,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'points': points,
    };
  }
}

/// 퀴즈 선택지 모델
class QuizOption {
  final String text;
  final bool isCorrect;
  final String explanation;

  const QuizOption({
    required this.text,
    required this.isCorrect,
    required this.explanation,
  });

  /// JSON에서 변환
  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
      explanation: json['explanation'] as String,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }
}
