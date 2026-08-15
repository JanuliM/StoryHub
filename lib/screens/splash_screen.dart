import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Wait for 3 seconds and initialize auth concurrently
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      ApiService().initAuth(),
    ]);

    if (mounted) {
      if (ApiService.authToken != null && ApiService.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFFA43A14);
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2);
    final textColorDark = isDark ? Colors.white : const Color(0xFF2D241E);
    final textColorMuted = isDark ? Colors.white70 : const Color(0xFF7A6E65);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Book Logo Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 54,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Title
                  Text(
                    'StoryHub',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: textColorDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtitle
                  Text(
                    'Collect memories, craft narratives.',
                    style: TextStyle(
                      fontSize: 15,
                      color: textColorMuted,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Progress indicator
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
