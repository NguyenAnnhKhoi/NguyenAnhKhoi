// lib/screens/account_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'profile/profile_info_screen.dart';
import 'profile/favorite_services_screen.dart';
import 'profile/transaction_history_screen.dart';
import 'profile/notifications_screen.dart';
import 'profile/help_support_screen.dart';
import 'profile/about_us_screen.dart';
import 'profile/terms_policy_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  User? _user;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        // Điều hướng về màn hình đăng nhập và xóa hết các màn hình cũ
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A8A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F245C)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _user?.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
                      child: _user?.photoURL == null
                          ? const Icon(Icons.person, size: 60, color: Color(0xFF1E3A8A))
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _user?.displayName ?? "Guest",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.email ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMenuSection([
                      _MenuItem(icon: Icons.person_outline, title: 'Thông tin cá nhân', onTap: () => _navigateTo(const ProfileInfoScreen())),
                      _MenuItem(icon: Icons.favorite_outline, title: 'Dịch vụ yêu thích', onTap: () => _navigateTo(const FavoriteServicesScreen())),
                      _MenuItem(icon: Icons.history, title: 'Lịch sử giao dịch', onTap: () => _navigateTo(const TransactionHistoryScreen())),
                    ]),
                    const SizedBox(height: 16),
                    _buildMenuSection([
                      _MenuItem(icon: Icons.notifications_none, title: 'Thông báo', onTap: () => _navigateTo(const NotificationsScreen())),
                      
                    ]),
                    const SizedBox(height: 16),
                    _buildMenuSection([
                      _MenuItem(icon: Icons.help_outline, title: 'Trợ giúp & Hỗ trợ', onTap: () => _navigateTo(const HelpSupportScreen())),
                      _MenuItem(icon: Icons.info_outline, title: 'Về chúng tôi', onTap: () => _navigateTo(const AboutUsScreen())),
                      // *** DÒNG CODE ĐÃ SỬA LỖI ***
                      _MenuItem(icon: Icons.privacy_tip_outlined, title: 'Chính sách & Điều khoản', onTap: () => _navigateTo(const TermsPolicyScreen(mode: 'terms'))),
                    ]),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, size: 22),
                        label: const Text('Đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<_MenuItem> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: items.map((item) {
          return ListTile(
            onTap: item.onTap,
            leading: Icon(item.icon, color: const Color(0xFF1E3A8A)),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}