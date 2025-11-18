/// 학습 Day 데이터 모델
class LearningDayModel {
  final int dayNumber; // 1-365
  final String title; // 학습 주제
  final List<LearningCard> cards; // 학습 카드 목록
  final List<QuizQuestion> quizQuestions; // 퀴즈 문항
  final int points; // 완료 시 획득 포인트

  const LearningDayModel({
    required this.dayNumber,
    required this.title,
    required this.cards,
    required this.quizQuestions,
    this.points = 10,
  });

  /// 월 번호 (1-12)
  int get monthNumber => ((dayNumber - 1) ~/ 30) + 1;

  /// 월 내 Day 번호 (1-30)
  int get dayInMonth => ((dayNumber - 1) % 30) + 1;

  /// JSON에서 변환
  factory LearningDayModel.fromJson(Map<String, dynamic> json) {
    return LearningDayModel(
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((card) => LearningCard.fromJson(card as Map<String, dynamic>))
          .toList(),
      quizQuestions: (json['quizQuestions'] as List<dynamic>)
          .map((quiz) => QuizQuestion.fromJson(quiz as Map<String, dynamic>))
          .toList(),
      points: json['points'] as int? ?? 10,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'cards': cards.map((card) => card.toJson()).toList(),
      'quizQuestions': quizQuestions.map((quiz) => quiz.toJson()).toList(),
      'points': points,
    };
  }
}

/// 학습 카드 모델
class LearningCard {
  final String id;
  final String content; // 학습 내용 (마크다운 지원)
  final String? imageUrl; // 이미지 URL (optional)
  final String? tip; // 팁 내용 (optional)

  const LearningCard({
    required this.id,
    required this.content,
    this.imageUrl,
    this.tip,
  });

  factory LearningCard.fromJson(Map<String, dynamic> json) {
    return LearningCard(
      id: json['id'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      tip: json['tip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (tip != null) 'tip': tip,
    };
  }
}

/// 퀴즈 문항 모델
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options; // 4개 선택지
  final int correctAnswerIndex; // 정답 인덱스 (0-3)
  final String explanation; // 정답 해설

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }
}

/// 학습 진행 상태 모델
class LearningProgress {
  final int dayNumber;
  final bool isLearningCompleted; // 학습 완료 여부
  final bool isQuizCompleted; // 퀴즈 완료 여부
  final int quizScore; // 퀴즈 점수 (0-5)
  final DateTime? completedAt; // 완료 시각

  const LearningProgress({
    required this.dayNumber,
    this.isLearningCompleted = false,
    this.isQuizCompleted = false,
    this.quizScore = 0,
    this.completedAt,
  });

  /// 완전히 완료되었는지 (학습 + 퀴즈)
  bool get isFullyCompleted => isLearningCompleted && isQuizCompleted;

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      dayNumber: json['dayNumber'] as int,
      isLearningCompleted: json['isLearningCompleted'] as bool? ?? false,
      isQuizCompleted: json['isQuizCompleted'] as bool? ?? false,
      quizScore: json['quizScore'] as int? ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'isLearningCompleted': isLearningCompleted,
      'isQuizCompleted': isQuizCompleted,
      'quizScore': quizScore,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }

  LearningProgress copyWith({
    int? dayNumber,
    bool? isLearningCompleted,
    bool? isQuizCompleted,
    int? quizScore,
    DateTime? completedAt,
  }) {
    return LearningProgress(
      dayNumber: dayNumber ?? this.dayNumber,
      isLearningCompleted: isLearningCompleted ?? this.isLearningCompleted,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
      quizScore: quizScore ?? this.quizScore,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
