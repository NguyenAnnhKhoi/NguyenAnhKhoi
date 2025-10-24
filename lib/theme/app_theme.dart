import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

/// Box Shadows chuẩn - Consistent shadows
class AppShadows {
  // Light shadows
  static List<BoxShadow> get light => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  // Medium shadows
  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // Large shadows
  static List<BoxShadow> get large => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Colored shadow với custom color
  static List<BoxShadow> colored(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];
  }

  // Elevated shadow (cho floating buttons)
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
}

/// Text Styles sử dụng Google Fonts Poppins - Trẻ trung, hiện đại, dễ đọc
class AppTextStyles {
  // ========== Headings (Compatibility với code cũ) ==========
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
  
  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
  
  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  // ========== Body Text ==========
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );
  
  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.5,
  );
  
  // ========== Special ==========
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );
  
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  
  // ========== NEW: Extended Typography System ==========
  
  // Display Styles
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static TextStyle displayMedium = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );
  
  static TextStyle displaySmall = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Headline Styles
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static TextStyle headlineSmall = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Title Styles
  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static TextStyle titleSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Label Styles
  static TextStyle labelLarge = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );
  
  static TextStyle labelMedium = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
  
  static TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.5,
  );
  
  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ========== Helper Methods ==========
  
  /// Tạo text style với màu tùy chỉnh
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Tạo text style với gradient
  static TextStyle withGradient(TextStyle style, List<Color> colors) {
    return style.copyWith(
      foreground: Paint()
        ..shader = LinearGradient(colors: colors)
            .createShader(const Rect.fromLTWH(0, 0, 200, 70)),
    );
  }
  
  /// Tạo text style với shadow
  static TextStyle withShadow(TextStyle style) {
    return style.copyWith(
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
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

/// Collection của Font Awesome Icons cho app - Trẻ trung & Professional
class AppIcons {
  // ========== Navigation Icons ==========
  static const IconData home = FontAwesomeIcons.house;
  static const IconData homeSolid = FontAwesomeIcons.solidHouse;
  static const IconData calendar = FontAwesomeIcons.calendarDays;
  static const IconData calendarSolid = FontAwesomeIcons.solidCalendarDays;
  static const IconData scissors = FontAwesomeIcons.scissors;
  static const IconData user = FontAwesomeIcons.circleUser;
  static const IconData userSolid = FontAwesomeIcons.solidCircleUser;
  static const IconData menu = FontAwesomeIcons.bars;

  // ========== Action Icons ==========
  static const IconData add = FontAwesomeIcons.plus;
  static const IconData addCircle = FontAwesomeIcons.circlePlus;
  static const IconData edit = FontAwesomeIcons.penToSquare;
  static const IconData delete = FontAwesomeIcons.trashCan;
  static const IconData save = FontAwesomeIcons.floppyDisk;
  static const IconData cancel = FontAwesomeIcons.xmark;
  static const IconData check = FontAwesomeIcons.check;
  static const IconData checkCircle = FontAwesomeIcons.circleCheck;
  static const IconData close = FontAwesomeIcons.xmark;
  static const IconData search = FontAwesomeIcons.magnifyingGlass;

  // ========== Booking Icons ==========
  static const IconData booking = FontAwesomeIcons.calendarCheck;
  static const IconData reschedule = FontAwesomeIcons.calendarDay;
  static const IconData time = FontAwesomeIcons.clock;
  static const IconData timeSolid = FontAwesomeIcons.solidClock;
  static const IconData location = FontAwesomeIcons.locationDot;
  static const IconData branch = FontAwesomeIcons.building;
  static const IconData branchSolid = FontAwesomeIcons.solidBuilding;

  // ========== Service Icons ==========
  static const IconData haircut = FontAwesomeIcons.scissors;
  static const IconData spa = FontAwesomeIcons.spa;
  static const IconData massage = FontAwesomeIcons.handSparkles;
  static const IconData nails = FontAwesomeIcons.paintbrush;
  static const IconData makeup = FontAwesomeIcons.wandMagicSparkles;
  static const IconData brush = FontAwesomeIcons.paintBrush;

  // ========== User & Profile Icons ==========
  static const IconData profile = FontAwesomeIcons.userLarge;
  static const IconData settings = FontAwesomeIcons.gear;
  static const IconData logout = FontAwesomeIcons.rightFromBracket;
  static const IconData login = FontAwesomeIcons.rightToBracket;
  static const IconData register = FontAwesomeIcons.userPlus;
  static const IconData password = FontAwesomeIcons.key;

  // ========== Social Icons ==========
  static const IconData google = FontAwesomeIcons.google;
  static const IconData facebook = FontAwesomeIcons.facebook;
  static const IconData phone = FontAwesomeIcons.phone;
  static const IconData email = FontAwesomeIcons.envelope;
  static const IconData emailSolid = FontAwesomeIcons.solidEnvelope;

  // ========== Status Icons ==========
  static const IconData success = FontAwesomeIcons.circleCheck;
  static const IconData error = FontAwesomeIcons.circleExclamation;
  static const IconData warning = FontAwesomeIcons.triangleExclamation;
  static const IconData info = FontAwesomeIcons.circleInfo;

  // ========== Payment Icons ==========
  static const IconData payment = FontAwesomeIcons.creditCard;
  static const IconData paymentSolid = FontAwesomeIcons.solidCreditCard;
  static const IconData wallet = FontAwesomeIcons.wallet;
  static const IconData money = FontAwesomeIcons.moneyBill;
  static const IconData qr = FontAwesomeIcons.qrcode;

  // ========== Rating & Favorite Icons ==========
  static const IconData star = FontAwesomeIcons.star;
  static const IconData starSolid = FontAwesomeIcons.solidStar;
  static const IconData starHalf = FontAwesomeIcons.solidStarHalfStroke;
  static const IconData heart = FontAwesomeIcons.heart;
  static const IconData heartSolid = FontAwesomeIcons.solidHeart;
  static const IconData thumbsUp = FontAwesomeIcons.thumbsUp;
  static const IconData thumbsUpSolid = FontAwesomeIcons.solidThumbsUp;

  // ========== Communication Icons ==========
  static const IconData notification = FontAwesomeIcons.bell;
  static const IconData notificationSolid = FontAwesomeIcons.solidBell;
  static const IconData chat = FontAwesomeIcons.message;
  static const IconData chatSolid = FontAwesomeIcons.solidMessage;
  static const IconData comment = FontAwesomeIcons.comment;
  static const IconData commentSolid = FontAwesomeIcons.solidComment;

  // ========== Media Icons ==========
  static const IconData image = FontAwesomeIcons.image;
  static const IconData imageSolid = FontAwesomeIcons.solidImage;
  static const IconData camera = FontAwesomeIcons.camera;
  static const IconData gallery = FontAwesomeIcons.images;
  static const IconData share = FontAwesomeIcons.share;
  static const IconData shareNodes = FontAwesomeIcons.shareNodes;

  // ========== Security Icons ==========
  static const IconData lock = FontAwesomeIcons.lock;
  static const IconData unlock = FontAwesomeIcons.lockOpen;
  static const IconData eye = FontAwesomeIcons.eye;
  static const IconData eyeSlash = FontAwesomeIcons.eyeSlash;
  static const IconData shield = FontAwesomeIcons.shield;
  static const IconData shieldCheck = FontAwesomeIcons.shieldHalved;

  // ========== Navigation Arrows ==========
  static const IconData arrowLeft = FontAwesomeIcons.arrowLeft;
  static const IconData arrowRight = FontAwesomeIcons.arrowRight;
  static const IconData arrowUp = FontAwesomeIcons.arrowUp;
  static const IconData arrowDown = FontAwesomeIcons.arrowDown;
  static const IconData chevronLeft = FontAwesomeIcons.chevronLeft;
  static const IconData chevronRight = FontAwesomeIcons.chevronRight;
  static const IconData chevronDown = FontAwesomeIcons.chevronDown;
  static const IconData chevronUp = FontAwesomeIcons.chevronUp;

  // ========== Other Common Icons ==========
  static const IconData filter = FontAwesomeIcons.filter;
  static const IconData sort = FontAwesomeIcons.sort;
  static const IconData gift = FontAwesomeIcons.gift;
  static const IconData tag = FontAwesomeIcons.tag;
  static const IconData tags = FontAwesomeIcons.tags;
  static const IconData mapPin = FontAwesomeIcons.mapPin;
  static const IconData map = FontAwesomeIcons.map;
  static const IconData mapSolid = FontAwesomeIcons.solidMap;
  static const IconData ellipsis = FontAwesomeIcons.ellipsis;
  static const IconData ellipsisVertical = FontAwesomeIcons.ellipsisVertical;
  static const IconData circle = FontAwesomeIcons.circle;
  static const IconData circleSolid = FontAwesomeIcons.solidCircle;
  static const IconData square = FontAwesomeIcons.square;
  static const IconData squareSolid = FontAwesomeIcons.solidSquare;
}

/// Emoji icons để thay thế Font Awesome - Vui vẻ, thân thiện
class EmojiIcons {
  // Navigation
  static const String home = '🏠';
  static const String calendar = '📅';
  static const String scissors = '✂️';
  static const String user = '👤';
  
  // Status
  static const String star = '⭐';
  static const String heart = '❤️';
  static const String fire = '🔥';
  static const String sparkles = '✨';
  static const String check = '✅';
  static const String cross = '❌';
  static const String warning = '⚠️';
  static const String info = 'ℹ️';
  
  // Location & Time
  static const String location = '📍';
  static const String time = '⏰';
  static const String clock = '🕐';
  
  // Money & Payment
  static const String money = '💰';
  static const String card = '💳';
  static const String wallet = '👛';
  
  // Communication
  static const String phone = '📱';
  static const String email = '📧';
  static const String bell = '🔔';
  static const String message = '💬';
  
  // Security
  static const String lock = '🔒';
  static const String unlock = '🔓';
  static const String key = '🔑';
  
  // Media
  static const String camera = '📷';
  static const String image = '🖼️';
  static const String gallery = '🎨';
  
  // Other
  static const String gift = '🎁';
  static const String crown = '👑';
  static const String trophy = '🏆';
  static const String medal = '🏅';
  static const String ribbon = '🎀';
}
