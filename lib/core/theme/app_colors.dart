import 'package:flutter/material.dart';

/// Color palette untuk Begya Outdoor App
/// Tema: Hijau (Alam & Outdoor), Hitam (Elegan), Putih (Modern)
class AppColors {
  // Primary Color (Hijau Alam)
  static const Color primaryGreen = Color(0xFF27391C);
  static const Color primaryGreenLight = Color(0xFF3D5A2E);
  static const Color primaryGreenDark = Color(0xFF1F2A16);

  // Secondary Color (Hijau Muda)
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color secondaryGreenLight = Color(0xFF81C784);
  static const Color secondaryGreenDark = Color(0xFF2E7D32);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey900 = Color(0xFF212121);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color greyLight = Color(0xFFFAFAFA);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Background Colors
  static const Color bgPrimary = Color(0xFF0F1512);
  static const Color bgSecondary = Color(0xFF1A2318);
  static const Color bgTertiary = Color(0xFF27391C);

  // Transparent variants
  static const Color transparentBlack = Color(0x00000000);
  static const Color blackOverlay = Color(0x80000000);

  // Gradient colors
  static const List<Color> gradientGreen = [primaryGreen, secondaryGreen];
  static const List<Color> gradientDark = [bgPrimary, primaryGreen];

  // Text colors
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey600;
  static const Color textTertiary = grey500;
  static const Color textHint = grey400;
  static const Color textOnPrimary = white;

  // Border colors
  static const Color borderDefault = grey300;
  static const Color borderColor = grey300; // alias for consistency
  static const Color borderLight = grey200;
  static const Color borderDark = grey700;

  // Shadow colors
  static const Color shadowColor = Color(0x1F000000);
  // Additional aliases
  static const Color errorColor = error;
  static const Color warningColor = warning;
  static const Color infoColor = info;
  static const Color successColor = success;
}
