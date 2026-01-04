import 'package:flutter/material.dart';



class AppTheme {
  // ------------------------- LIGHT THEME -------------------------
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'SolaimanLipi',
    scaffoldBackgroundColor: const Color(0xFFEFF2F5),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3A7BD5),
      secondary: Color(0xFF00B4D8),
      surface:    Color(0xFF182848), 

      onSurface: Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      // background: Color(0xFFEFF2F5),
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1E1E1E),
    ),
  );

  // ------------------------- DARK THEME -------------------------
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'SolaimanLipi',
    scaffoldBackgroundColor: const Color(0xFF0D0F12),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8F8CFF),
      secondary: Color(0xFF46CFFF),
      surface:   Color(0xFF182848), 
      onSurface: Color(0xFFE6E6E6),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      // background: Color(0xFF0D0F12),
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
  );

  // ---------------------- UNIVERSAL GRADIENT ----------------------
  /// New warm-to-cool gradient (Orange → Pink → Purple)
  static const LinearGradient gradient = LinearGradient(
    colors: [
      Color(0xFF4B6CB7), // Indigo
      Color(0xFF182848), // Deep Blue
      Color(0xFF8E9EAB),

      /// Coral Peach
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ---------------------- GLASS EFFECT GRADIENT ----------------------
  static final LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white.withValues(alpha: .15), Colors.white.withValues(alpha: .04)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
