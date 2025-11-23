import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/character_provider.dart';
import 'goal_setting_screen.dart';

/// 이름 설정 화면
/// 사용자 닉네임 입력 (선택한 캐릭터 기준)
class NameSettingScreen extends StatefulWidget {
  final PersonalityType personalityType;

  const NameSettingScreen({
    super.key,
    required this.personalityType,
  });

  @override
  State<NameSettingScreen> createState() => _NameSettingScreenState();
}

class _NameSettingScreenState extends State<NameSettingScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _defaultName = '';

  @override
  void initState() {
    super.initState();
    // 선택한 캐릭터 기준 디폴트 이름 설정
    final selectedCharacter = context.read<CharacterProvider>().selectedCharacter;
    if (selectedCharacter != null) {
      _defaultName = selectedCharacter.characterName.split(' ').last;
    } else {
      // fallback: personalityType 기준
      _defaultName = widget.personalityType.characterName.split(' ').last;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    setState(() {}); // 글자 수 카운터 업데이트
  }

  void _onNext() {
    final inputName = _nameController.text.trim();

    // 입력이 비어있으면 디폴트 이름 사용
    final finalName = inputName.isEmpty ? _defaultName : inputName;

    // 목표 설정 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoalSettingScreen(
          personalityType: widget.personalityType,
          userName: finalName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: ScreenSize.paddingHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // 캐릭터 (작은 크기)
                    _buildCharacter(),

                    const SizedBox(height: 32),

                    // 제목
                    Text(
                      '어떻게 불러드릴까요?',
                      style: theme.textTheme.displayMedium,
                    ),

                    const SizedBox(height: 12),

                    // 부제
                    Text(
                      '함께 투자를 배울 이름을 알려주세요',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // 이름 입력 필드
                    _buildNameInput(theme),

                    const SizedBox(height: 16),

                    // 안내 텍스트
                    Text(
                      '입력하지 않으면 "$_defaultName"으로 시작해요',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  /// 캐릭터 표시 (선택한 캐릭터 기준)
  Widget _buildCharacter() {
    final selectedCharacter = context.watch<CharacterProvider>().selectedCharacter;
    final character = selectedCharacter ?? widget.personalityType;

    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: character.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: character.color.withOpacity(0.3),
            width: 3,
          ),
        ),
        child: Icon(
          Icons.pets,
          size: 50,
          color: character.color,
        ),
      ),
    );
  }

  /// 이름 입력 필드 (Placeholder로 디폴트 이름 표시)
  Widget _buildNameInput(ThemeData theme) {
    final selectedCharacter = context.watch<CharacterProvider>().selectedCharacter;
    final character = selectedCharacter ?? widget.personalityType;

    return TextField(
      controller: _nameController,
      onChanged: _onNameChanged,
      autofocus: true,
      maxLength: 10,
      keyboardType: TextInputType.name,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: _defaultName,
        hintStyle: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary.withOpacity(0.3),
        ),
        counterText: '${_nameController.text.length}/10',
        counterStyle: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenSize.borderRadius),
          borderSide: BorderSide(
            color: character.color,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
    );
  }

  /// 하단 버튼 (항상 활성화)
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(ScreenSize.paddingHorizontal),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _onNext, // 항상 활성화
        child: const Text('다음'),
      ),
    );
  }
}
