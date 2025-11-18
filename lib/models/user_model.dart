import '../utils/constants.dart';

/// 사용자 데이터 모델
class UserModel {
  final String id;
  final String name;
  final PersonalityType personalityType;
  final String goal;
  final int currentDay; // 현재 학습 중인 Day (1-365)
  final int totalPoints; // 누적 포인트
  final int currentStreak; // 현재 연속 학습 일수
  final int maxStreak; // 최대 연속 학습 일수
  final DateTime createdAt; // 가입일
  final DateTime? lastLearningDate; // 마지막 학습 날짜

  const UserModel({
    required this.id,
    required this.name,
    required this.personalityType,
    required this.goal,
    this.currentDay = 1,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    required this.createdAt,
    this.lastLearningDate,
  });

  /// 온보딩 완료 시 새 사용자 생성
  factory UserModel.create({
    required String name,
    required PersonalityType personalityType,
    required String goal,
  }) {
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      personalityType: personalityType,
      goal: goal,
      currentDay: 1,
      totalPoints: 0,
      currentStreak: 0,
      maxStreak: 0,
      createdAt: DateTime.now(),
      lastLearningDate: null,
    );
  }

  /// JSON에서 변환
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      personalityType: PersonalityType.values.firstWhere(
        (type) => type.name == json['personalityType'],
        orElse: () => PersonalityType.balanced,
      ),
      goal: json['goal'] as String,
      currentDay: json['currentDay'] as int? ?? 1,
      totalPoints: json['totalPoints'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLearningDate: json['lastLearningDate'] != null
          ? DateTime.parse(json['lastLearningDate'] as String)
          : null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'personalityType': personalityType.name,
      'goal': goal,
      'currentDay': currentDay,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'createdAt': createdAt.toIso8601String(),
      'lastLearningDate': lastLearningDate?.toIso8601String(),
    };
  }

  /// 복사 with 수정
  UserModel copyWith({
    String? id,
    String? name,
    PersonalityType? personalityType,
    String? goal,
    int? currentDay,
    int? totalPoints,
    int? currentStreak,
    int? maxStreak,
    DateTime? createdAt,
    DateTime? lastLearningDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      personalityType: personalityType ?? this.personalityType,
      goal: goal ?? this.goal,
      currentDay: currentDay ?? this.currentDay,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      createdAt: createdAt ?? this.createdAt,
      lastLearningDate: lastLearningDate ?? this.lastLearningDate,
    );
  }

  /// 오늘 학습했는지 확인
  bool get hasLearnedToday {
    if (lastLearningDate == null) return false;
    final now = DateTime.now();
    final lastLearning = lastLearningDate!;
    return now.year == lastLearning.year &&
        now.month == lastLearning.month &&
        now.day == lastLearning.day;
  }

  /// 현재 월 (1-12)
  int get currentMonth {
    return ((currentDay - 1) ~/ 30) + 1;
  }

  /// 현재 월의 Day (1-30)
  int get currentDayInMonth {
    return ((currentDay - 1) % 30) + 1;
  }
}
