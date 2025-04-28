import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greatly_user/core/theme/app_text_theme.dart';
import 'app_colors.dart';


ThemeData appTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    // Replace fontFamily with Google Fonts
    textTheme: GoogleFonts.aBeeZeeTextTheme(appTextTheme()), // Use Google Fonts
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.onPrimary),
      titleTextStyle: GoogleFonts.aBeeZee(
        textStyle: appTextTheme().titleLarge?.copyWith(color: AppColors.onPrimary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        textStyle: GoogleFonts.aBeeZee(
          textStyle: appTextTheme().labelLarge,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.surface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: AppColors.surface, width: 1.0),
      ),
      labelStyle: GoogleFonts.aBeeZee(
        textStyle: appTextTheme().bodyLarge?.copyWith(color: AppColors.onBackground),
      ),
    ),
  );
}