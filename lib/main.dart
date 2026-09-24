import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitStart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // The primary blue color
          primary: const Color(0xFF2563EB),
        ),
        primaryColor: const Color(0xFF2563EB),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}