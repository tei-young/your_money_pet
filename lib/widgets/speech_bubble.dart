import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SpeechBubble extends StatefulWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const SpeechBubble({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDuration.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: CustomPaint(
        painter: _SpeechBubblePainter(
          backgroundColor: widget.backgroundColor ?? Colors.white,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.textColor ?? AppColors.textPrimary,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final Color backgroundColor;

  _SpeechBubblePainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 8, size.width, size.height - 8),
      const Radius.circular(12),
    );

    // 말풍선 꼬리 (위쪽 중앙)
    path.moveTo(size.width / 2 - 8, 8);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width / 2 + 8, 8);

    path.addRRect(rect);

    // 그림자
    canvas.drawPath(path, shadowPaint);

    // 말풍선
    canvas.drawPath(path, paint);

    // 테두리
    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
