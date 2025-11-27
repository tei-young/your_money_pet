import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../home/main_navigation_screen.dart';

/// 로그인/회원가입 화면
///
/// 사용 시점:
/// - 온보딩 완료 후
/// - 로그아웃 후
/// - 앱 재시작 시 미로그인 상태
/// - 학습 시도 시 미로그인
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 현재 모드 (true: 로그인, false: 회원가입)
  bool _isLoginMode = true;

  // 폼 컨트롤러
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  // 폼 키
  final _formKey = GlobalKey<FormState>();

  // 로딩 상태
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  /// 모드 전환
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _passwordConfirmController.clear();
    });
  }

  /// 이메일 검증
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식이 아니에요';
    }

    return null;
  }

  /// 비밀번호 검증
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }

    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 해요';
    }

    return null;
  }

  /// 비밀번호 확인 검증
  String? _validatePasswordConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 다시 입력해주세요';
    }

    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않아요';
    }

    return null;
  }

  /// 이메일/비밀번호 로그인/회원가입
  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isLoginMode) {
        // 로그인
        await authService.signInWithEmail(
          email: email,
          password: password,
        );
      } else {
        // 회원가입
        final credential = await authService.signUpWithEmail(
          email: email,
          password: password,
        );

        // 회원가입 후 UserProvider에 사용자 정보 동기화
        if (credential != null && mounted) {
          final userProvider = context.read<UserProvider>();
          // 온보딩에서 생성한 임시 사용자 데이터를 Firebase UID와 연결
          // TODO: Firestore에 사용자 데이터 저장
        }
      }

      if (!mounted) return;

      // 로그인/회원가입 성공 → 홈 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFF56565),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Google 로그인
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final credential = await authService.signInWithGoogle();

      // 사용자가 로그인 취소한 경우
      if (credential == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      // Google 로그인 성공 → UserProvider에 사용자 정보 동기화
      final userProvider = context.read<UserProvider>();
      // TODO: Firestore에서 사용자 데이터 로드 또는 생성

      // 홈 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFF56565),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // 로고 영역 (Placeholder)
                _buildLogoSection(),

                const SizedBox(height: 40),

                // 안내 문구
                _buildHeaderText(),

                const SizedBox(height: 40),

                // 로그인/회원가입 탭
                _buildModeTabs(),

                const SizedBox(height: 24),

                // 이메일/비밀번호 폼
                _buildEmailPasswordForm(),

                const SizedBox(height: 24),

                // 로그인/회원가입 버튼
                _buildSubmitButton(),

                const SizedBox(height: 24),

                // 구분선
                _buildDivider(),

                const SizedBox(height: 24),

                // Google 로그인 버튼
                _buildGoogleSignInButton(),

                const SizedBox(height: 24),

                // 하단 모드 전환 링크
                _buildToggleLink(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 로고 섹션
  Widget _buildLogoSection() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF9F7AEA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(60),
      ),
      child: const Icon(
        Icons.pets,
        size: 60,
        color: Color(0xFF9F7AEA),
      ),
    );
  }

  /// 헤더 텍스트
  Widget _buildHeaderText() {
    return const Column(
      children: [
        Text(
          '학습을 시작해봐요!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '로그인이 필요해요',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  /// 모드 탭
  Widget _buildModeTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!_isLoginMode) _toggleMode();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _isLoginMode
                        ? const Color(0xFF9F7AEA)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                '로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _isLoginMode ? FontWeight.bold : FontWeight.normal,
                  color: _isLoginMode
                      ? const Color(0xFF9F7AEA)
                      : const Color(0xFF718096),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_isLoginMode) _toggleMode();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: !_isLoginMode
                        ? const Color(0xFF9F7AEA)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                '회원가입',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: !_isLoginMode ? FontWeight.bold : FontWeight.normal,
                  color: !_isLoginMode
                      ? const Color(0xFF9F7AEA)
                      : const Color(0xFF718096),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 이메일/비밀번호 폼
  Widget _buildEmailPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 이메일
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            decoration: InputDecoration(
              labelText: '이메일',
              hintText: 'example@email.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF9F7AEA), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF56565)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF56565), width: 2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 비밀번호
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '6자 이상 입력해주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF9F7AEA), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF56565)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF56565), width: 2),
              ),
            ),
          ),

          // 회원가입 모드: 비밀번호 확인
          if (!_isLoginMode) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordConfirmController,
              obscureText: true,
              validator: _validatePasswordConfirm,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                hintText: '비밀번호를 다시 입력해주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF9F7AEA), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF56565)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF56565), width: 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 제출 버튼
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleEmailAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9F7AEA),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isLoginMode ? '로그인하기' : '회원가입하기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '또는',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  /// Google 로그인 버튼
  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google 로고 (Placeholder)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF9F7AEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.g_mobiledata,
                size: 16,
                color: Color(0xFF9F7AEA),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Google로 계속하기',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 하단 모드 전환 링크
  Widget _buildToggleLink() {
    return GestureDetector(
      onTap: _toggleMode,
      child: Text(
        _isLoginMode ? '계정이 없으신가요? 회원가입 →' : '이미 계정이 있으신가요? 로그인 →',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF9F7AEA),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
