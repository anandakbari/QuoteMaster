import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quote_master/constants/colors.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({Key? key}) : super(key: key);

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated quote icon container
        AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _pulseAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background subtle pulsing circle
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),

                      // Rotating quote marks
                      Transform.rotate(
                        angle: _rotationController.value * 2 * 3.14159,
                        child: const Text(
                          '""',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Animated loading text
        _AnimatedLoadingText(
          text: 'Finding wisdom',
          controller: _pulseController,
        ),
      ],
    );
  }
}

// Animated loading text with dots
class _AnimatedLoadingText extends StatefulWidget {
  final String text;
  final AnimationController controller;

  const _AnimatedLoadingText({
    required this.text,
    required this.controller,
  });

  @override
  _AnimatedLoadingTextState createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<_AnimatedLoadingText> with SingleTickerProviderStateMixin {
  late int _dotCount;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotCount = 0;

    // Use an animation controller instead of Timer
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Listen to animation to update dot count
    _dotController.addListener(() {
      final newCount = (_dotController.value * 4).floor() % 4;
      if (newCount != _dotCount) {
        setState(() {
          _dotCount = newCount;
        });
      }
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = List.filled(_dotCount, '.').join();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        // Fixed width container for dots to prevent text shifting
        SizedBox(
          width: 30,
          child: Text(
            dots,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}