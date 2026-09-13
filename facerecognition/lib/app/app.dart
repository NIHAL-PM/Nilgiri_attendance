import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import 'theme.dart';

class PulseAttendApp extends StatelessWidget {
  const PulseAttendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulseAttend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
