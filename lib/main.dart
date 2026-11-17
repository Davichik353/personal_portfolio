// lib/main.dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'screens/projects_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Davichik Portfolio",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          primary: const Color(0xFF1565C0),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        useMaterial3: true,
        fontFamily: 'PortfolioSans',
        textTheme:
            const TextTheme(
              bodyLarge: TextStyle(fontSize: 16, height: 1.6),
              bodyMedium: TextStyle(fontSize: 14, height: 1.5),
              headlineLarge: TextStyle(
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
              headlineSmall: TextStyle(fontWeight: FontWeight.w700),
              titleLarge: TextStyle(fontWeight: FontWeight.w600),
            ).apply(
              bodyColor: const Color(0xFF172033),
              displayColor: const Color(0xFF172033),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 1,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
      home: const MyAppHome(),
      routes: {'/projects': (context) => const ProjectsScreen()},
    );
  }
}
