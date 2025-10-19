import 'package:flutter/material.dart';

/// Bảng màu phong cách Gen Z - Hiện đại, trẻ trung, dễ tiếp cận
class AppColors {
  // Primary Colors - Cyan/Teal (Trendy & Fresh)
  static const primary = Color(0xFF0891B2); // Cyan 600
  static const primaryLight = Color(0xFF06B6D4); // Cyan 500
  static const primaryLighter = Color(0xFF22D3EE); // Cyan 400
  static const primaryDark = Color(0xFF0E7490); // Cyan 700
  
  // Gradient Colors - Cho các button và header đẹp mắt
  static const gradientPink = [Color(0xFFFF6B9D), Color(0xFFFFA06B)];
  static const gradientCyan = [Color(0xFF0891B2), Color(0xFF06B6D4)];
  static const gradientPurple = [Color(0xFF8B5CF6), Color(0xFFC084FC)];
  static const gradientOrange = [Color(0xFFFFA500), Color(0xFFFF6B35)];
  static const gradientGreen = [Color(0xFF10B981), Color(0xFF34D399)];
  
  // Background Colors
  static const backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const backgroundWhite = Colors.white;
  static const backgroundGray = Color(0xFFF1F5F9); // Slate 100
  
  // Text Colors
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF475569); // Slate 600
  static const textTertiary = Color(0xFF64748B); // Slate 500
  static const textLight = Color(0xFF94A3B8); // Slate 400
  
  // Status Colors
  static const success = Color(0xFF10B981); // Green
  static const error = Color(0xFFEF4444); // Red
  static const warning = Color(0xFFF59E0B); // Amber
  static const info = Color(0xFF3B82F6); // Blue
  
  // Rating & Star
  static const star = Color(0xFFFFB300);
  static const starBackground = Color(0xFFFFF3E0);
  static const starText = Color(0xFFE65100);
}

/// Spacing chuẩn cho app - Consistent spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border Radius chuẩn - Rounded corners
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;
}

/// Text Styles - Typography
class AppTextStyles {
  // Headings
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  
  static const h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );
  
  static const h3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );
  
  static const h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  // Body Text
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
  
  // Special
  static const caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );
  
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}

/// Shadows - Box shadows chuẩn
class AppShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> colored(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];
  }
}

/// App Theme - Theme tổng thể
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.cyan,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    useMaterial3: true,
    fontFamily: 'Roboto',
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        fontFamily: 'Roboto',
      ),
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        elevation: 6,
        shadowColor: AppColors.primary.withOpacity(0.5),
        textStyle: AppTextStyles.button,
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      shadowColor: Colors.black.withOpacity(0.08),
    ),
  );
}
