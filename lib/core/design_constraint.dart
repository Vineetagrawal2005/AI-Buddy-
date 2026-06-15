import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colors from Peblo wireframe
class AppColors {
  static const Color primaryPurple = Color(0xFF6F2BC2);
  static const Color darkPurple = Color(0xFF36165E);

  static const Color background = Color(0xFFFFFFFF);
  static const Color cardGray = Color(0xFFF5F5F7);
  static const Color borderGray = Color(0xFFE0E0E5);

  static const Color textPrimary = Color(0xFF36165E);
  static const Color textSecondary = Color(0xFF8E8E93);

  // Not in wireframe but needed for quiz feedback
  static const Color successGreen = Color(0xFF6BCB77);
  static const Color errorRed = Color(0xFFFF6B6B);
}

/// Typography — Poppins, per style guidance
class AppTextStyles {
  static TextStyle appBarTitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryPurple,
  );

  static TextStyle storyLabel = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  static TextStyle storyText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle quizQuestion = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle quizOption = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle placeholderText = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );
}

/// Layout constants (spacing, radii) inferred from wireframe
class AppDimens {
  static const double screenPadding = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double optionRadius = 12.0;

  static const double sectionSpacing = 16.0;
  static const double cardPadding = 16.0;
  static const double buttonHeight = 56.0;

  static const double buddyAspectRatio = 1.0; // square placeholder
}