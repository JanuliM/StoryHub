import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const StoryHubApp());
}

class StoryHubApp extends StatelessWidget {
  const StoryHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFB83B00);
    const backgroundColor = Color(0xFFFBF9F5);

    return MaterialApp(
      title: 'StoryHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          surface: backgroundColor,
        ),
        fontFamily: 'Serif',
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
