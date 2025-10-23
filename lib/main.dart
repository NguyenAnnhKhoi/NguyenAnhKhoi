// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:provider/provider.dart';

// Firebase & Services
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/firestore_service.dart';

// Providers
import 'providers/auth_provider.dart' as app_provider;
import 'providers/booking_provider.dart';
import 'providers/services_provider.dart';
import 'providers/favorites_provider.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/branch_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/account_screen.dart';
import 'screens/quick_booking_screen.dart';
import 'admin/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _configureEasyLoading();
  runApp(const MyApp());
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.wave
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = const Color(0xFF0891B2)
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Constants
  static const Color _primaryColor = Color(0xFF0891B2);
  static const String _appTitle = 'Gentlemen\'s Grooming';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(create: (_) => app_provider.AuthProvider()),
        
        // Services Provider (load data once)
        ChangeNotifierProvider(
          create: (_) => ServicesProvider()..loadAllData(),
        ),
        
        // Booking Provider
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        
        // Favorites Provider
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: _appTitle,
        theme: _buildTheme(),
        routes: _buildRoutes(),
        builder: EasyLoading.init(),
        home: const AuthWrapper(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.cyan,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: Colors.grey[50],
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: _primaryColor.withOpacity(0.4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/home': (_) => const MainScreen(),
      '/register': (_) => const RegisterScreen(),
      '/forgot-password': (_) => const ForgotPasswordScreen(),
      '/login': (_) => const LoginScreen(),
      '/my-bookings': (_) => const MainScreen(initialIndex: 2),
    };
  }
}

// Authentication Wrapper
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (authSnapshot.hasData) {
          return _buildAuthenticatedScreen(firestoreService);
        }

        return const LoginScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF0891B2)),
      ),
    );
  }

  Widget _buildAuthenticatedScreen(FirestoreService firestoreService) {
    return StreamBuilder<bool>(
      stream: firestoreService.isAdmin(),
      builder: (context, adminSnapshot) {
        if (adminSnapshot.hasError) {
          debugPrint('AuthWrapper Error: ${adminSnapshot.error}');
          return const MainScreen();
        }

        if (adminSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        return adminSnapshot.data == true 
            ? const AdminHomeScreen() 
            : const MainScreen();
      },
    );
  }
}


// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final GlobalKey<ConvexAppBarState> _appBarKey = GlobalKey<ConvexAppBarState>();

  // Screen Configuration
  static const List<Widget> _screens = [
    HomeScreen(),
    BranchScreen(),
    MyBookingsScreen(),
    AccountScreen(),
  ];

  static const List<TabItem> _tabItems = [
    TabItem(icon: Icons.home_rounded, title: 'Trang chủ'),
    TabItem(icon: Icons.storefront_rounded, title: 'Chi nhánh'),
    TabItem(icon: Icons.add, title: 'Đặt lịch'),
    TabItem(icon: Icons.history_rounded, title: 'Lịch sử'),
    TabItem(icon: Icons.person_rounded, title: 'Tài khoản'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _mapIndexToScreen(_selectedIndex),
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  int _mapIndexToScreen(int tabIndex) {
    if (tabIndex < 2) return tabIndex;
    if (tabIndex > 2) return tabIndex - 1;
    return 0;
  }

  Widget _buildBottomNavigationBar() {
    return ConvexAppBar(
      key: _appBarKey,
      style: TabStyle.reactCircle,
      backgroundColor: Colors.white,
      color: Colors.grey.shade600,
      activeColor: const Color(0xFF0891B2),
      height: 60,
      initialActiveIndex: _selectedIndex,
      items: _tabItems,
      onTap: _handleTabTap,
    );
  }

  Future<void> _handleTabTap(int index) async {
    if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QuickBookingScreen()),
      );
      _appBarKey.currentState?.animateTo(_selectedIndex);
    } else {
      setState(() => _selectedIndex = index);
    }
  }
}