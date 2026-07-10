import 'package:flutter/material.dart';

const bgColor = Color(0xFF001A1A);
const surfaceColor = Color(0xFF002929);
const cardColor = Color(0xFF003333);
const primaryColor = Color(0xFF00D4C8);
const primaryDark = Color(0xFF009E99);
const userBubble = Color(0xFF004D4D);
const aiBubble = Color(0xFF002222);
const borderColor = Color(0xFF004444);

ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryDark,
      surface: surfaceColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF4DB8B5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
      bodySmall: TextStyle(color: Color(0xFF80CECA), fontSize: 12),
    ),
  );
}
