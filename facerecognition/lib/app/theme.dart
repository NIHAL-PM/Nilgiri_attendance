import 'package:flutter/material.dart';

/// Central design token system for PulseAttend.
/// Every colour, radius, spacing, and text style lives here.
abstract class AppTheme {
  // ---------------------------------------------------------------------------
  // Colour palette
  // ---------------------------------------------------------------------------
  static const Color bgDeep      = Color(0xFF090A0F);
  static const Color bgSurface   = Color(0xFF141722);
  static const Color bgCard      = Color(0xFF1C2030);
  static const Color cyan        = Color(0xFF00F2FE);
  static const Color green       = Color(0xFF00FF87);
  static const Color red         = Color(0xFFFF0844);
  static const Color gold        = Color(0xFFFEE140);
  static const Color blue        = Color(0xFF4FACFE);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSub     = Color(0xFF8E95A5);
  static const Color textMuted   = Color(0xFF4A5168);
  static const Color border      = Color(0xFF252A3A);

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00FF87), Color(0xFF00C66A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C2030), Color(0xFF141722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0D0F1A), Color(0xFF090A0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ---------------------------------------------------------------------------
  // Border radius
  // ---------------------------------------------------------------------------
  static const double radiusSm  = 12;
  static const double radiusMd  = 20;
  static const double radiusLg  = 28;
  static const double radiusXl  = 36;
  static const double radiusFull = 100;

  // ---------------------------------------------------------------------------
  // Spacing
  // ---------------------------------------------------------------------------
  static const double spaceSm  = 8;
  static const double spaceMd  = 16;
  static const double spaceLg  = 24;
  static const double spaceXl  = 32;
  static const double spaceXxl = 48;

  // ---------------------------------------------------------------------------
  // ThemeData
  // ---------------------------------------------------------------------------
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDeep,
    primaryColor: cyan,
    colorScheme: const ColorScheme.dark(
      primary: cyan,
      secondary: green,
      error: red,
      surface: bgSurface,
    ),
    textTheme: _textTheme,
    iconTheme: const IconThemeData(color: textPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgSurface,
      selectedItemColor: cyan,
      unselectedItemColor: textMuted,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
    ),
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      color: textPrimary, fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: -1),
    displayMedium: TextStyle(
      color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
    headlineLarge: TextStyle(
      color: textPrimary, fontSize: 26, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(
      color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(
      color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(
      color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(
      color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(
      color: textSub, fontSize: 13, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(color: textSub, fontSize: 16, height: 1.6),
    bodyMedium: TextStyle(color: textSub, fontSize: 14, height: 1.5),
    bodySmall: TextStyle(color: textMuted, fontSize: 12, height: 1.4),
    labelLarge: TextStyle(
      color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
    labelMedium: TextStyle(
      color: textSub, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    labelSmall: TextStyle(
      color: textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8),
  );
}
