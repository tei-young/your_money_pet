import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Splash 화면
/// 2초 동안 표시 후 자동으로 Welcome 화면으로 이동
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade 애니메이션 (0 -> 1)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Scale 애니메이션 (0.8 -> 1.0)
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // 애니메이션 시작
    _controller.forward();

    // 2초 후 Welcome 화면으로 이동
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // TODO: 온보딩 완료 여부 확인 후 분기
        // if (onboardingCompleted) {
        //   Navigator.pushReplacementNamed(context, '/home');
        // } else {
        //   Navigator.pushReplacementNamed(context, '/welcome');
        // }

        // 임시: Welcome 화면으로 이동 (나중에 구현)
        debugPrint('TODO: Navigate to Welcome screen');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 (임시: 아이콘 사용)
                _buildLogo(),

                const SizedBox(height: 32),

                // 앱 이름
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),

                const SizedBox(height: 16),

                // 태그라인
                Text(
                  '귀여운 친구와 함께\n투자 공부',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // 로딩 인디케이터
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 로고 위젯 (임시: 원형 아이콘)
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.pets,
        size: 64,
        color: Colors.white,
      ),
    );
  }
}
