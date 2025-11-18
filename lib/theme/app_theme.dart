// import 'package:flutter/material.dart';

// class AppTheme {
//   static ThemeData get lightTheme => ThemeData(
//     useMaterial3: true,
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: Colors.teal,
//       primary: Colors.teal,
//       secondary: Colors.amber,
//       surface: Colors.white,
//       brightness: Brightness.light,
//     ),
//     scaffoldBackgroundColor: Colors.grey[100],
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,
//       titleTextStyle: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: Colors.black87,
//       ),
//     ),
//     textTheme: const TextTheme(
//       headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//       titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//       bodyLarge: TextStyle(fontSize: 16),
//       bodyMedium: TextStyle(fontSize: 14),
//     ),
//     filledButtonTheme: FilledButtonThemeData(
//       style: FilledButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     ),
//   );

//   static ThemeData get darkTheme => ThemeData(
//     useMaterial3: true,
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: Colors.teal,
//       primary: Colors.tealAccent,
//       secondary: Colors.amberAccent,
//       surface: Colors.grey[900]!,
//       brightness: Brightness.dark,
//     ),
//     scaffoldBackgroundColor: Colors.grey[850],
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,
//       titleTextStyle: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//     ),
//     textTheme: const TextTheme(
//       headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//       titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//       bodyLarge: TextStyle(fontSize: 16),
//       bodyMedium: TextStyle(fontSize: 14),
//     ),
//     filledButtonTheme: FilledButtonThemeData(
//       style: FilledButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     ),
//   );

//   // 🌊 New Teal → Blue Gradient
//   static LinearGradient get gradient => const LinearGradient(
//     colors: [
//       Color(0xFF009688), // Teal
//       Color(0xFF3F51B5), // Indigo
//       Color(0xFF2196F3), // Blue
//     ],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//   // 🆕 Neutral-friendly Gradient (BlueGrey → Teal → Soft Cyan)
//   static LinearGradient get neutralGradient => const LinearGradient(
//     colors: [
//       Color(0xFF546E7A), // BlueGrey - good base
//       Color(0xFF009688), // Teal - matches your theme
//       Color(0xFF4DD0E1), // Light Cyan - soft & text friendly
//     ],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
// }

import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'SolaimanLipi',
    scaffoldBackgroundColor: Colors.transparent,
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'SolaimanLipi',
    scaffoldBackgroundColor: Colors.black,
  );

  static final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5), Color(0xFF9D00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: .25),
      Colors.white.withValues(alpha: .05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
