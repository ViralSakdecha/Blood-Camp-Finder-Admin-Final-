import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart'; // Navigates to the MainAppWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Controller for the falling drop
  late AnimationController _dropFallController;
  late Animation<double> _dropFallAnimation;

  // Controller for the ripple effect on impact
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  // Controller for the wave filling the screen
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  // Controller for the final fade out to the main app
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialization of all animation controllers
    _dropFallController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _dropFallAnimation = CurvedAnimation(parent: _dropFallController, curve: Curves.easeIn);

    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _rippleController, curve: Curves.easeOut));

    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _waveAnimation = CurvedAnimation(parent: _waveController, curve: Curves.easeIn);

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    // Start the animation sequence
    _startAnimationSequence();

    // Navigate after the animations are scheduled to complete
    Timer(const Duration(milliseconds: 3200), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainAppWrapper(),
          // Use a fade transition for a smooth switch to the main app
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  void _startAnimationSequence() async {
    // Wait for the drop to fall
    await _dropFallController.forward();
    // Trigger the ripple and wave simultaneously
    _rippleController.forward();
    _waveController.forward();
    // Wait a moment before starting the fade-out
    await Future.delayed(const Duration(milliseconds: 1000));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _dropFallController.dispose();
    _rippleController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // The elegant white background
      body: FadeTransition(
        opacity: _fadeAnimation, // This will fade out the entire screen at the end
        child: AnimatedBuilder(
          // Listen to all controllers to repaint when any of them change
          animation: Listenable.merge([_dropFallController, _rippleController, _waveController]),
          builder: (context, child) {
            return CustomPaint(
              painter: BloodSplashPainter(
                dropFallProgress: _dropFallAnimation.value,
                rippleProgress: _rippleAnimation.value,
                waveHeightProgress: _waveAnimation.value,
              ),
              child: Container(),
            );
          },
        ),
      ),
    );
  }
}

// The Custom Painter that brings the animation to life
class BloodSplashPainter extends CustomPainter {
  final double dropFallProgress;
  final double rippleProgress;
  final double waveHeightProgress;
  final Color bloodColor = const Color(0xffc2002f); // A deep, professional red

  BloodSplashPainter({
    required this.dropFallProgress,
    required this.rippleProgress,
    required this.waveHeightProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- 1. Draw the Falling Drop ---
    if (dropFallProgress < 1.0) {
      final dropPaint = Paint()..color = bloodColor;
      final dropSize = 15.0;
      final dropY = (size.height - (dropSize * 2.5)) * dropFallProgress; // Adjusted for impact point
      final dropPath = Path();
      dropPath.moveTo(size.width / 2, dropY);
      // A more realistic teardrop shape that stretches as it falls
      dropPath.cubicTo(
        size.width / 2 - dropSize, dropY + dropSize,
        size.width / 2 + dropSize, dropY + dropSize,
        size.width / 2, dropY + (dropSize * (2 + dropFallProgress * 0.5)),
      );
      canvas.drawPath(dropPath, dropPaint);
    }

    // --- 2. Draw the Ripple on Impact ---
    if (rippleProgress > 0.0) {
      final ripplePaint = Paint()
        ..color = bloodColor.withOpacity(1.0 - rippleProgress) // Fades out
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      // The ripple expands outwards
      canvas.drawCircle(Offset(size.width / 2, size.height), 100 * rippleProgress, ripplePaint);
    }

    // --- 3. Draw the Filling Wave ---
    if (waveHeightProgress > 0) {
      final wavePaint = Paint()..color = bloodColor;
      final path = Path();
      final waveHeight = size.height * waveHeightProgress;

      path.moveTo(0, size.height);
      path.lineTo(0, size.height - waveHeight);

      // A more complex wave for a fluid, dynamic feel
      for (double i = 0; i < size.width; i++) {
        path.lineTo(
            i,
            size.height - waveHeight + sin(i * 0.02 + (waveHeightProgress * 2 * pi)) * 10 * (1 - waveHeightProgress)
        );
      }

      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint every frame for smooth animation
  }
}