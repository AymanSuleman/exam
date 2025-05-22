import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class AppTheme {
  static Color primaryColor = Colors.blue.shade800;
  static Color secondaryColor = Colors.lightBlueAccent;
  static Color backgroundColor = const Color(0xFFF5F6FA);
  static Color activeColor = Colors.green.shade600;
  static Color inactiveColor = Colors.red.shade600;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF616161);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: backgroundColor,
      ),
      fontFamily: 'Poppins',
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade600),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14),
        labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      dividerColor: Colors.grey.shade300,
    );
  }

  // Quill Toolbar Theme Config - for consistent toolbar button colors & icons
  // static final QuillToolbarTheme quillToolbarTheme = QuillToolbarTheme(
  //     color: Colors.white,
  //     iconColor: primaryColor,
  //     iconSelectedColor: secondaryColor,
  //     disabledIconColor: Colors.grey.shade400,
  //     borderRadius: BorderRadius.circular(8),
  //     elevation: 2,
  //     toggleColor: primaryColor.withOpacity(0.15),
  //     toggleBorderColor: primaryColor,
  //     buttonPadding: const EdgeInsets.all(8),
  //     multiRowsDisplay: false,
  //   );

  // Quill Editor default background and cursor color can be accessed via
  static Color get quillEditorBackground => Colors.white;
  static Color get quillCursorColor => primaryColor;
}
