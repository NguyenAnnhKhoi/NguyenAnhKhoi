import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'admin_home_screen.dart';
import 'admin_login_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 1. KIỂM TRA ĐĂNG NHẬP
        if (authSnapshot.hasData) {
          // 2. KIỂM TRA QUYỀN ADMIN
          return StreamBuilder<bool>(
            stream: firestoreService.isAdmin(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Nếu là admin, cho vào
              if (adminSnapshot.data == true) {
                return const AdminHomeScreen();
              }

              // Nếu đăng nhập nhưng không phải admin, đá ra
              // Đăng xuất và hiển thị trang Login với thông báo lỗi
              FirebaseAuth.instance.signOut();
              return const AdminLoginScreen(
                errorMessage: 'Tài khoản không có quyền quản trị.',
              );
            },
          );
        }

        // Nếu chưa đăng nhập, hiển thị trang Login
        return const AdminLoginScreen();
      },
    );
  }
}
