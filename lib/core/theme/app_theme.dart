import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Warm & Comforting
  static const Color softPink = Color(0xFFFFF0F5);
  static const Color gentleCream = Color(0xFFF8F8F8);
  static const Color pastelPeach = Color(0xFFFFE4E1);
  static const Color leafGreen = Color(0xFF8BC34A);
  static const Color heartPink = Color(0xFFFF6B6B);
  static const Color warmGrey = Color(0xFF333333);
  static const Color softPurple = Color(0xFFE6E6FA);
  static const Color lightPink = Color(0xFFFFB6C1);

  // Gradients
  static const LinearGradient softPinkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softPink, lightPink],
  );

  static const LinearGradient softPurpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softPurple, softPink],
  );

  // Typography
  static TextTheme get textTheme {
    return GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: warmGrey,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: warmGrey,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: warmGrey,
      ),
      headlineLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: warmGrey,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: warmGrey,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: warmGrey,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: warmGrey,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: warmGrey,
      ),
      titleSmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: warmGrey,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: warmGrey,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: warmGrey,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: warmGrey,
      ),
    );
  }



  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: leafGreen,
        secondary: heartPink,
        surface: gentleCream,
        background: softPink,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: warmGrey,
        onBackground: warmGrey,
      ),
      textTheme: textTheme,
      fontFamily: GoogleFonts.nunito().fontFamily,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: warmGrey,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: warmGrey),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: gentleCream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(16),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warmGrey,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: warmGrey,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: softPink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: leafGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: warmGrey.withOpacity(0.5),
        ),
      ),
    );
  }

  // Convenience getters for colors and text styles
  static AppThemeColors get colors => AppThemeColors();
  static AppThemeTextStyles get textStyles => AppThemeTextStyles();
}

// Colors class for easier access
class AppThemeColors {
  Color get softPink => AppTheme.softPink;
  Color get gentleCream => AppTheme.gentleCream;
  Color get pastelPeach => AppTheme.pastelPeach;
  Color get leafGreen => AppTheme.leafGreen;
  Color get heartPink => AppTheme.heartPink;
  Color get warmGrey => AppTheme.warmGrey;
  Color get softPurple => AppTheme.softPurple;
  Color get lightPink => AppTheme.lightPink;
  Color get textPrimary => AppTheme.warmGrey;
  Color get textSecondary => AppTheme.warmGrey.withOpacity(0.7);
}

// Text styles class for easier access
class AppThemeTextStyles {
  TextStyle? get displayLarge => AppTheme.textTheme.displayLarge;
  TextStyle? get displayMedium => AppTheme.textTheme.displayMedium;
  TextStyle? get displaySmall => AppTheme.textTheme.displaySmall;
  TextStyle? get headlineLarge => AppTheme.textTheme.headlineLarge;
  TextStyle? get headlineMedium => AppTheme.textTheme.headlineMedium;
  TextStyle? get headlineSmall => AppTheme.textTheme.headlineSmall;
  TextStyle? get titleLarge => AppTheme.textTheme.titleLarge;
  TextStyle? get titleMedium => AppTheme.textTheme.titleMedium;
  TextStyle? get titleSmall => AppTheme.textTheme.titleSmall;
  TextStyle? get bodyLarge => AppTheme.textTheme.bodyLarge;
  TextStyle? get bodyMedium => AppTheme.textTheme.bodyMedium;
  TextStyle? get bodySmall => AppTheme.textTheme.bodySmall;
}