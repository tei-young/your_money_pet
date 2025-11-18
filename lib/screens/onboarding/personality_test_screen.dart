import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'personality_result_screen.dart';

/// 투자 성향 진단 화면 (5문항)
/// 다크 모드 배경
/// 선택 즉시 자동 전환
class PersonalityTestScreen extends StatefulWidget {
  const PersonalityTestScreen({super.key});

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  int _currentQuestion = 0;
  final Map<PersonalityType, int> _scores = {
    PersonalityType.safe: 0,
    PersonalityType.balanced: 0,
    PersonalityType.aggressive: 0,
    PersonalityType.challenger: 0,
  };

  // 5개 질문
  final List<QuestionData> _questions = const [
    QuestionData(
      question: '1,000만원이 생긴다면?',
      options: [
        AnswerOption(
          text: '예금에 안전하게 넣어둔다',
          type: PersonalityType.safe,
          score: 3,
        ),
        AnswerOption(
          text: 'ETF에 분산 투자한다',
          type: PersonalityType.balanced,
          score: 3,
        ),
        AnswerOption(
          text: '성장주에 투자한다',
          type: PersonalityType.aggressive,
          score: 3,
        ),
        AnswerOption(
          text: '비트코인에 투자한다',
          type: PersonalityType.challenger,
          score: 3,
        ),
      ],
    ),
    QuestionData(
      question: '투자 경험이 있나요?',
      options: [
        AnswerOption(
          text: '예적금만 해봤어요',
          type: PersonalityType.safe,
          score: 2,
        ),
        AnswerOption(
          text: 'ETF나 펀드를 해봤어요',
          type: PersonalityType.balanced,
          score: 2,
        ),
        AnswerOption(
          text: '개별 주식을 해봤어요',
          type: PersonalityType.aggressive,
          score: 2,
        ),
        AnswerOption(
          text: '가상자산도 해봤어요',
          type: PersonalityType.challenger,
          score: 2,
        ),
      ],
    ),
    QuestionData(
      question: '투자 손실이 났을 때\n반응은?',
      options: [
        AnswerOption(
          text: '무서워서 바로 판다',
          type: PersonalityType.safe,
          score: 2,
        ),
        AnswerOption(
          text: '고민하다가 일부만 판다',
          type: PersonalityType.balanced,
          score: 2,
        ),
        AnswerOption(
          text: '참고 기다린다',
          type: PersonalityType.aggressive,
          score: 2,
        ),
        AnswerOption(
          text: '더 사서 물타기 한다',
          type: PersonalityType.challenger,
          score: 2,
        ),
      ],
    ),
    QuestionData(
      question: '투자 목표 기간은?',
      options: [
        AnswerOption(
          text: '1년 이내 단기',
          type: PersonalityType.safe,
          score: 1,
        ),
        AnswerOption(
          text: '3-5년 중기',
          type: PersonalityType.balanced,
          score: 2,
        ),
        AnswerOption(
          text: '10년 이상 장기',
          type: PersonalityType.aggressive,
          score: 2,
        ),
        AnswerOption(
          text: '정하지 않았어요',
          type: PersonalityType.challenger,
          score: 1,
        ),
      ],
    ),
    QuestionData(
      question: '가장 중요하게\n생각하는 건?',
      options: [
        AnswerOption(
          text: '원금 보존',
          type: PersonalityType.safe,
          score: 3,
        ),
        AnswerOption(
          text: '안정적 수익',
          type: PersonalityType.balanced,
          score: 3,
        ),
        AnswerOption(
          text: '높은 수익률',
          type: PersonalityType.aggressive,
          score: 3,
        ),
        AnswerOption(
          text: '새로운 경험',
          type: PersonalityType.challenger,
          score: 3,
        ),
      ],
    ),
  ];

  void _onAnswerSelected(AnswerOption answer) {
    // 점수 추가
    setState(() {
      _scores[answer.type] = (_scores[answer.type] ?? 0) + answer.score;
    });

    // 0.3초 대기 (선택 피드백)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentQuestion < _questions.length - 1) {
        // 다음 질문
        setState(() {
          _currentQuestion++;
        });
      } else {
        // 마지막 질문: 결과 화면으로 이동
        _navigateToResult();
      }
    });
  }

  void _navigateToResult() {
    // 가장 높은 점수의 성향 찾기
    final result = _scores.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    // 결과 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalityResultScreen(
          resultType: result.key,
          allScores: _scores,
        ),
      ),
    );
  }

  void _onBack() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFF1F2937), // 다크 그레이
      body: SafeArea(
        child: Column(
          children: [
            // 상단: 네비게이션
            _buildTopBar(),

            // 중간: 캐릭터 + 질문
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: ScreenSize.paddingHorizontal,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // 캐릭터 + 말풍선
                    _buildCharacterWithBubble(),

                    const SizedBox(height: 48),

                    // 질문
                    _buildQuestion(question.question),

                    const SizedBox(height: 32),

                    // 선택지
                    ...question.options.map(
                      (option) => _buildOption(option),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상단 바 (뒤로가기, 프로그레스, 닫기)
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 뒤로가기
          IconButton(
            onPressed: _onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          // 프로그레스 인디케이터 (●●●○○)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _questions.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= _currentQuestion
                        ? AppColors.primary
                        : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),

          // 닫기
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  /// 캐릭터 + 말풍선
  Widget _buildCharacterWithBubble() {
    return Column(
      children: [
        // 말풍선
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4B5563)),
          ),
          child: const Text(
            '무엇을 배우시겠어요?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFD1D5DB),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 캐릭터 (임시: 아이콘)
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.pets,
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    );
  }

  /// 질문 텍스트
  Widget _buildQuestion(String question) {
    return Text(
      question,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 선택지 카드
  Widget _buildOption(AnswerOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
        child: InkWell(
          onTap: () => _onAnswerSelected(option),
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF4B5563),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
            ),
            child: Text(
              option.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 질문 데이터 모델
class QuestionData {
  final String question;
  final List<AnswerOption> options;

  const QuestionData({
    required this.question,
    required this.options,
  });
}

/// 답변 옵션 모델
class AnswerOption {
  final String text;
  final PersonalityType type;
  final int score;

  const AnswerOption({
    required this.text,
    required this.type,
    required this.score,
  });
}
