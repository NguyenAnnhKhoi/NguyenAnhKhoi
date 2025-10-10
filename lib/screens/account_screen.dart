// lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'profile/profile_info_screen.dart';
import 'profile/favorite_services_screen.dart';
import 'profile/transaction_history_screen.dart';
import 'profile/notifications_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/help_support_screen.dart';
import 'profile/about_us_screen.dart';
import 'profile/terms_policy_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  String username = "Guest";
  final _authService = AuthService();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUser();
    
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

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      username = prefs.getString("username") ?? "Guest";
    });
  }

  Future<void> _logout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFF00BCD4)),
            SizedBox(width: 12),
            Text('Đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }
  
  // Hàm helper để điều hướng
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
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF0F245C),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Thành viên',
                      style: TextStyle(
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.event_available,
                            label: 'Lịch hẹn',
                            value: '5',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star,
                            label: 'Điểm tích lũy',
                            value: '250',
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // --- CÁC MỤC ĐÃ ĐƯỢC CẬP NHẬT ---
                    _buildMenuSection([
                      _MenuItem(icon: Icons.person_outline, title: 'Thông tin cá nhân', subtitle: 'Cập nhật thông tin của bạn', onTap: () => _navigateTo(const ProfileInfoScreen())),
                      _MenuItem(icon: Icons.favorite_outline, title: 'Dịch vụ yêu thích', subtitle: 'Quản lý dịch vụ yêu thích', onTap: () => _navigateTo(const FavoriteServicesScreen())),
                      _MenuItem(icon: Icons.history, title: 'Lịch sử giao dịch', subtitle: 'Xem lịch sử thanh toán', onTap: () => _navigateTo(const TransactionHistoryScreen())),
                    ]),
                    const SizedBox(height: 16),
                    _buildMenuSection([
                      _MenuItem(icon: Icons.notifications_none, title: 'Thông báo', subtitle: 'Cài đặt thông báo', onTap: () => _navigateTo(const NotificationsScreen())),
                      _MenuItem(icon: Icons.settings_outlined, title: 'Cài đặt', subtitle: 'Tùy chỉnh ứng dụng', onTap: () => _navigateTo(const SettingsScreen())),
                    ]),
                    const SizedBox(height: 16),
                    _buildMenuSection([
                       _MenuItem(icon: Icons.help_outline, title: 'Trợ giúp & Hỗ trợ', subtitle: 'Câu hỏi thường gặp', onTap: () => _navigateTo(const HelpSupportScreen())),
                      _MenuItem(icon: Icons.info_outline, title: 'Về chúng tôi', subtitle: 'Phiên bản 1.0.0', onTap: () => _navigateTo(const AboutUsScreen())),
                      _MenuItem(icon: Icons.privacy_tip_outlined, title: 'Chính sách & Điều khoản', subtitle: 'Điều khoản sử dụng', onTap: () => _navigateTo(const TermsPolicyScreen())),
                    ]),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, size: 22),
                        label: const Text('Đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(List<_MenuItem> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          _MenuItem item = entry.value;
          bool isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: const Color(0xFF1E3A8A), size: 24),
                ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: item.subtitle != null ? Text(item.subtitle!, style: const TextStyle(fontSize: 12)) : null,
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ),
              if (!isLast) const Divider(height: 1, indent: 72, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}