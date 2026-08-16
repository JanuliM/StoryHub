import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

// Global notifier for dark mode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const StoryHubApp());
}

class StoryHubApp extends StatelessWidget {
  const StoryHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFB83B00);
    const backgroundColor = Color(0xFFFBF9F5);
    const darkBackgroundColor = Color(0xFF121212);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'StoryHub',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: backgroundColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              primary: primaryColor,
              surface: backgroundColor,
              brightness: Brightness.light,
            ),
            fontFamily: 'Serif',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: darkBackgroundColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              primary: primaryColor,
              surface: darkBackgroundColor,
              brightness: Brightness.dark,
            ),
            fontFamily: 'Serif',
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}
