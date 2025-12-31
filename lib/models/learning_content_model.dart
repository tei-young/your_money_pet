import 'package:cloud_firestore/cloud_firestore.dart';

/// 학습 콘텐츠 모델 (Firestore: learning_contents)
class LearningContent {
  final int day;
  final String personality; // "safe", "balanced", "aggressive", "challenger"
  final String title;
  final int estimatedMinutes;
  final int points;
  final List<LearningCard> cards;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearningContent({
    required this.day,
    required this.personality,
    required this.title,
    required this.estimatedMinutes,
    required this.points,
    required this.cards,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore 문서에서 변환
  factory LearningContent.fromJson(Map<String, dynamic> json) {
    final cardsList = (json['cards'] as List)
        .map((c) => LearningCard.fromJson(c as Map<String, dynamic>))
        .toList();

    // cards를 order로 정렬
    cardsList.sort((a, b) => a.order.compareTo(b.order));

    return LearningContent(
      day: json['day'] as int,
      personality: json['personality'] as String,
      title: json['title'] as String,
      estimatedMinutes: json['estimatedMinutes'] as int,
      points: json['points'] as int,
      cards: cardsList,
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
      'title': title,
      'estimatedMinutes': estimatedMinutes,
      'points': points,
      'cards': cards.map((c) => c.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// 학습 카드 모델
class LearningCard {
  final int order;
  final String type; // "text", "image", "quiz_link"
  final String content;
  final String? imageUrl;
  final String? tip;

  const LearningCard({
    required this.order,
    required this.type,
    required this.content,
    this.imageUrl,
    this.tip,
  });

  /// JSON에서 변환
  factory LearningCard.fromJson(Map<String, dynamic> json) {
    return LearningCard(
      order: json['order'] as int,
      type: json['type'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      tip: json['tip'] as String?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'type': type,
      'content': content,
      'imageUrl': imageUrl,
      'tip': tip,
    };
  }
}
