import 'package:flutter/material.dart';

/// 머니펫 앱 상수 정의
class AppConstants {
  // 앱 정보
  static const String appName = '머니펫';
  static const String appVersion = '1.0.0';

  // 학습 관련
  static const int totalDays = 365;
  static const int daysPerMonth = 30;
  static const int quizQuestionsCount = 5;
  static const int learningTimeMinutes = 3;
  static const int quizTimeMinutes = 2;

  // 포인트
  static const int learningPoints = 50;
  static const int quizPointsPerQuestion = 20;
  static const int totalQuizPoints = 100;
}

/// 머니펫 색상 팔레트
class AppColors {
  // 메인 컬러 (톤다운 보라-회색)
  static const Color primary = Color(0xFF9F7AEA); // 메인 보라
  static const Color primaryLight = Color(0xFFD6BCFA); // 연한 보라
  static const Color primaryPale = Color(0xFFF3E8FF); // 파스텔 보라
  static const Color primaryDark = Color(0xFF805AD5); // 진한 보라

  // 서브 컬러 (회색)
  static const Color secondary = Color(0xFF718096); // 메인 회색
  static const Color secondaryLight = Color(0xFFA0AEC0); // 연한 회색
  static const Color secondaryPale = Color(0xFFEDF2F7); // 파스텔 회색
  static const Color secondaryDark = Color(0xFF4A5568); // 진한 회색

  // 배경 컬러
  static const Color background = Color(0xFFFAFBFC); // 오프화이트
  static const Color surface = Color(0xFFF7FAFC); // 연한 그레이블루
  static const Color card = Color(0xFFFFFFFF); // 순백

  // 텍스트 컬러
  static const Color textPrimary = Color(0xFF2D3748); // 메인 텍스트
  static const Color textSecondary = Color(0xFF718096); // 보조 텍스트
  static const Color textTertiary = Color(0xFFA0AEC0); // 연한 텍스트
  static const Color textDisabled = Color(0xFFCBD5E0); // 비활성

  // 기능 컬러
  static const Color success = Color(0xFF48BB78); // 학습 완료, 정답
  static const Color error = Color(0xFFF56565); // 에러, 오답
  static const Color warning = Color(0xFFED8936); // 경고
  static const Color info = Color(0xFF4299E1); // 정보

  // 테두리
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF0F0F0);

  // 성향별 컬러
  static const Color safeType = Color(0xFF718096); // 안전형 (머니베어)
  static const Color balancedType = Color(0xFFB794F6); // 밸런스형 (밸런스토끼)
  static const Color aggressiveType = Color(0xFF9F7AEA); // 공격형 (코인캣)
  static const Color challengerType = Color(0xFF4A5568); // 도전형 (세이빙덕)
}

/// 투자 성향 타입
enum PersonalityType {
  safe, // 안전형
  balanced, // 밸런스형
  aggressive, // 공격형
  challenger, // 도전형
}

/// 성향별 컬러 확장
extension PersonalityTypeExtension on PersonalityType {
  Color get color {
    switch (this) {
      case PersonalityType.safe:
        return AppColors.safeType;
      case PersonalityType.balanced:
        return AppColors.balancedType;
      case PersonalityType.aggressive:
        return AppColors.aggressiveType;
      case PersonalityType.challenger:
        return AppColors.challengerType;
    }
  }

  Color get lightColor {
    switch (this) {
      case PersonalityType.safe:
        return const Color(0xFFA0AEC0);
      case PersonalityType.balanced:
        return const Color(0xFFD6BCFA);
      case PersonalityType.aggressive:
        return const Color(0xFFD6BCFA);
      case PersonalityType.challenger:
        return const Color(0xFF718096);
    }
  }

  String get displayName {
    switch (this) {
      case PersonalityType.safe:
        return '안전형';
      case PersonalityType.balanced:
        return '밸런스형';
      case PersonalityType.aggressive:
        return '공격형';
      case PersonalityType.challenger:
        return '도전형';
    }
  }

  String get characterName {
    switch (this) {
      case PersonalityType.safe:
        return 'Money Bear 머니베어';
      case PersonalityType.balanced:
        return 'Save Sheep 세이브쉽';
      case PersonalityType.aggressive:
        return 'Hunter Cat 헌터캣';
      case PersonalityType.challenger:
        return 'Chaser Fox 체이서폭스';
    }
  }

  String get description {
    switch (this) {
      case PersonalityType.safe:
        return '든든하게 지키는 • 원금을 보호하며 안정적으로 자산 증식';
      case PersonalityType.balanced:
        return '부드럽게 균형잡는 • 안정성과 수익성의 균형을 추구';
      case PersonalityType.aggressive:
        return '날카롭게 사냥하는 • 기회를 포착하며 높은 수익 추구';
      case PersonalityType.challenger:
        return '영리하게 도전하는 • 새로운 투자 기회에 도전하며 성장';
    }
  }

  String get curriculum {
    switch (this) {
      case PersonalityType.safe:
        return '예적금의 기본과 복리의 힘부터 인플레이션 대응과 안전한 포트폴리오 구성까지';
      case PersonalityType.balanced:
        return '주식과 채권의 기본, ETF 이해부터 글로벌 자산배분과 목표수익률 달성 전략까지';
      case PersonalityType.aggressive:
        return '주식투자의 기본과 기업 분석부터 업종 트렌드 예측과 고수익 투자 전략까지';
      case PersonalityType.challenger:
        return '가상자산 이해와 블록체인 기술부터 DeFi, NFT와 혁신기술 투자 전략까지';
    }
  }
}

/// 화면 크기 상수
class ScreenSize {
  static const double paddingHorizontal = 24.0;
  static const double paddingVertical = 16.0;
  static const double borderRadius = 12.0;
  static const double cardRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double iconSize = 24.0;
}

/// 애니메이션 상수
class AnimationDuration {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
