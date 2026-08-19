import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NyseBitesApp());
}

class NyseBitesApp extends StatelessWidget {
  const NyseBitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyse Bites | Cookie & Cake Company',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDF9F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3C2216),
          primary: const Color(0xFF3C2216),
          secondary: const Color(0xFF8E4A23),
          surface: const Color(0xFFFFFFFF),
        ),
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}