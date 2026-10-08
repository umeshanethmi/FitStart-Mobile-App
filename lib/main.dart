import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitstart_mobile_app/screens/welcome_screen.dart';
import 'package:fitstart_mobile_app/firebase_options.dart';
import 'package:fitstart_mobile_app/services/reminder_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  ReminderNotificationService.instance.start();
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
