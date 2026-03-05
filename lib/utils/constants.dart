import 'package:flutter/material.dart';

class AppColors {
  // 🌿 Modern Health Colors - Teal Theme
  static const Color primary = Color(0xFF00897B); // Deep Teal
  static const Color primaryLight = Color(0xFF4DB6AC); // Light Teal
  static const Color primaryDark = Color(0xFF00695C); // Dark Teal
    static Color get primaryWithLightOpacity => primary.withValues(alpha: 0.15);
  
  // Accent Colors
  static const Color accent = Color(0xFF4DB6AC); // Soft Teal
  static const Color accentLight = Color(0xFFB2DFDB); // Very Light Teal
  
  // Background
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Status Colors - Keeping these subtle
  static const Color success = Color(0xFF2E7D32); // Forest Green
  static const Color warning = Color(0xFFF57C00); // Warm Orange
  static const Color error = Color(0xFFC62828); // Soft Red
  static const Color info = Color(0xFF0288D1); // Soft Blue
  
  // BMI Category Colors (Soft, calming tones)
  static const Color underweight = Color(0xFF4FC3F7); // Soft Sky Blue
  static const Color normal = Color(0xFF66BB6A); // Soft Green
  static const Color overweight = Color(0xFFFFB74D); // Soft Orange
  static const Color obese = Color(0xFFEF5350); // Soft Red
  
  // Gradients - Fresh & Modern
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFE0F2F1), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF5F5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4DB6AC), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // New - Soft background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTypography {
  static const String fontFamily = 'Poppins';
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    color: Color(0xFF00897B),
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Color(0xFF00897B),
  );
  
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: Color(0xFF00897B),
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF00897B),
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF00897B),
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF37474F),
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF37474F),
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color(0xFF546E7A),
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF546E7A),
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Color(0xFF78909C),
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: Color(0xFF90A4AE),
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: Color(0xFFB0BEC5),
  );
}

class AppShadows {
  // Soft, minimal shadows for modern look
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0xFF00897B).withValues(alpha: 0.08),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
    BoxShadow(
      color: Color(0xFF000000).withValues(alpha: 0.02),
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ];
  
  static BoxShadow soft = BoxShadow(
    color: Color(0xFF00897B).withValues(alpha: 0.1),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
  
  static BoxShadow subtle = BoxShadow(
    color: Color(0xFF000000).withValues(alpha: 0.03),
    blurRadius: 10,
    offset: const Offset(0, 3),
  );
}