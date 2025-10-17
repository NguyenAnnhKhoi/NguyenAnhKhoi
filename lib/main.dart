// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/account_screen.dart';
import 'screens/branch_screen.dart';
import 'screens/quick_booking_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'services/notification_service.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  configLoading();
}

void configLoading() {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gentlemen\'s Grooming',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: const Color(0xFF0891B2),
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0891B2),
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
            backgroundColor: const Color(0xFF0891B2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF0891B2).withOpacity(0.4),
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
            borderSide: const BorderSide(color: Color(0xFF0891B2), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
      routes: {
        '/home': (_) => const MainScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/login': (_) => const LoginScreen(),
      },
      builder: EasyLoading.init(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0891B2),
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // === PHẦN SỬA LỖI 1: Tạo GlobalKey ===
  // Key này sẽ cho phép chúng ta truy cập và điều khiển ConvexAppBar
  final GlobalKey<ConvexAppBarState> _appBarKey = GlobalKey<ConvexAppBarState>();

  final List<Widget> _actualScreens = [
    const HomeScreen(),
    const BranchScreen(),
    const MyBookingsScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    int mapIndexToScreen(int tabIndex) {
      if (tabIndex < 2) return tabIndex;
      if (tabIndex > 2) return tabIndex - 1;
      return 0;
    }
    
    return Scaffold(
      body: IndexedStack(
        index: mapIndexToScreen(_selectedIndex),
        children: _actualScreens,
      ),
      bottomNavigationBar: ConvexAppBar(
        // === PHẦN SỬA LỖI 2: Gán Key cho AppBar ===
        key: _appBarKey,

        style: TabStyle.reactCircle,
        backgroundColor: Colors.white,
        color: Colors.grey.shade600,
        activeColor: const Color(0xFF0891B2),
        height: 60,
        initialActiveIndex: _selectedIndex,
        items: const [
          TabItem(icon: Icons.home_rounded, title: 'Trang chủ'),
          TabItem(icon: Icons.storefront_rounded, title: 'Chi nhánh'),
          TabItem(icon: Icons.add, title: 'Đặt lịch'),
          TabItem(icon: Icons.history_rounded, title: 'Lịch sử'),
          TabItem(icon: Icons.person_rounded, title: 'Tài khoản'),
        ],
        onTap: (int index) async {
          if (index == 2) {
            // Khi nhấn "Đặt lịch", chúng ta điều hướng đến màn hình mới
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuickBookingScreen()),
            );
            // === PHẦN SỬA LỖI 3: Đồng bộ lại AppBar sau khi quay về ===
            // Sau khi quay lại, dùng key để "ra lệnh" cho AppBar
            // nhảy về đúng tab đang được chọn (_selectedIndex)
            _appBarKey.currentState?.animateTo(_selectedIndex);
          } else {
            // Khi nhấn các tab khác, cập nhật trạng thái như bình thường
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}