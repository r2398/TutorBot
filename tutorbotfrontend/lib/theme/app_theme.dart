import 'package:flutter/material.dart';

class AppTheme {

  // Primary Colors
  static const Color primaryOrange = Color(0xFFF97316); // Vibrant Orange
  static const Color primaryIndigo = Color(0xFF4F46E5); // Deep Indigo

  // Neutral Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Almost White (Slate 50)
  static const Color backgroundDark = Color(0xFF020617);  // Near Black (Slate 950)
  static const Color surfaceLight = Color(0xFFFFFFFF);   // Pure White
  static const Color surfaceDark = Color(0xFF1E293B);    // Dark Blue-Gray (Slate 800)

  // Text Colors
  static const Color textHeader = Color(0xFF0F172A);      // Dark Slate (Slate 900)
  static const Color textBody = Color(0xFF334155);        // Medium Slate (Slate 700)
  static const Color textMuted = Color(0xFF64748B);        // Lighter Slate (Slate 500)
  static const Color textWhite = Color(0xFFE2E8F0);        // Light Gray (Slate 200)

  // Accent & Utility Colors
  static const Color accentGreen = Color(0xFF22C55E);      // Green
  static const Color accentYellow = Color(0xFFEAB308);    // Yellow
  static const Color accentRed = Color(0xFFEF4444);        // Red
  static const Color borderLight = Color(0xFFE2E8F0);      // Light Border (Slate 200)
  static const Color borderDark = Color(0xFF334155);        // Dark Border (Slate 700)

  // --- Light Theme Definition ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryOrange,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryOrange,
      secondary: primaryIndigo,
      surface: surfaceLight,
      background: backgroundLight,
      error: accentRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textHeader,
      onBackground: textHeader,
      onError: Colors.white,
    ),

    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderLight, width: 1),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 1,
        shadowColor: primaryOrange.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textBody,
        side: const BorderSide(color: borderLight, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
    ),

    textTheme: const TextTheme(
      displaySmall: TextStyle(color: textHeader, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: textHeader, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textHeader, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textBody, height: 1.5),
      bodyMedium: TextStyle(color: textMuted, height: 1.5),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: textHeader,
      elevation: 0,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryOrange,
      unselectedItemColor: textMuted,
    ),

    dividerTheme: const DividerThemeData(color: borderLight, thickness: 1),
  );

  // --- Dark Theme Definition ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryOrange,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryOrange,
      secondary: primaryIndigo,
      surface: surfaceDark,
      background: backgroundDark,
      error: accentRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textWhite,
      onBackground: textWhite,
      onError: Colors.white,
    ),

    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderDark, width: 1),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 1,
        shadowColor: primaryOrange.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textWhite,
        side: const BorderSide(color: borderDark, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: textMuted.withOpacity(0.8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
    ),

    textTheme: const TextTheme(
      displaySmall: TextStyle(color: textWhite, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textWhite, height: 1.5),
      bodyMedium: TextStyle(color: textMuted, height: 1.5),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: textWhite,
      elevation: 0,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryOrange,
      unselectedItemColor: textMuted,
    ),

    dividerTheme: const DividerThemeData(color: borderDark, thickness: 1),
  );
}