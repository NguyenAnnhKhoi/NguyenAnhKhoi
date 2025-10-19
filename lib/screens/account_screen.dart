// lib/screens/account_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
// KHÔNG import firestore_service
import 'profile/profile_info_screen.dart';
import 'profile/favorite_services_screen.dart';
import 'profile/transaction_history_screen.dart';
import 'profile/notifications_screen.dart';
import 'profile/help_support_screen.dart';
import 'profile/about_us_screen.dart';
import 'profile/terms_policy_screen.dart';
// KHÔNG import admin_home_screen

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  // KHÔNG cần _firestoreService ở đây
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

  // ... (giữ nguyên hàm dispose)
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // *** HÀM ĐÃ SỬA LỖI ***
  Future<void> _logout() async {
    // ... (toàn bộ phần showDialog giữ nguyên) ...
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, color: Colors.red.shade400, size: 48),
              ),
              SizedBox(height: 20),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Bạn có chắc chắn muốn đăng xuất không?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      
      // *** ĐÃ XÓA KHỐI ĐIỀU HƯỚNG (Navigator) Ở ĐÂY ***
      // AuthWrapper (trong main.dart) sẽ tự động xử lý việc chuyển màn hình.
      // Chúng ta không cần làm gì thêm.
    }
  }

  // ... (giữ nguyên hàm _navigateTo)
  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ... (Giữ nguyên SliverAppBar)
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Color(0xFF0891B2),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0891B2),
                      Color(0xFF06B6D4),
                      Color(0xFF22D3EE),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 15),
                      // Avatar với border gradient
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.white.withOpacity(0.7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Color(0xFF0891B2).withOpacity(0.1),
                            backgroundImage: _user?.photoURL != null 
                                ? NetworkImage(_user!.photoURL!) 
                                : null,
                            child: _user?.photoURL == null
                                ? Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Color(0xFF0891B2),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _user?.displayName ?? "Guest",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _user?.email ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      
                      // XÓA NÚT ADMIN KHỎI ĐÂY
                      
                      // Section: Tài khoản
                      _buildSectionTitle('Tài khoản', Icons.person),
                      SizedBox(height: 12),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.person_outline,
                          title: 'Thông tin cá nhân',
                          subtitle: 'Quản lý thông tin của bạn',
                          color: Color(0xFF0891B2),
                          onTap: () => _navigateTo(const ProfileInfoScreen()),
                        ),
                        _MenuItem(
                          icon: Icons.favorite_outline,
                          title: 'Dịch vụ yêu thích',
                          subtitle: 'Các dịch vụ bạn đã lưu',
                          color: Colors.pink.shade400,
                          onTap: () => _navigateTo(const FavoriteServicesScreen()),
                        ),
                        _MenuItem(
                          icon: Icons.history,
                          title: 'Lịch sử giao dịch',
                          subtitle: 'Xem các giao dịch trước đây',
                          color: Colors.amber.shade600,
                          onTap: () => _navigateTo(const TransactionHistoryScreen()),
                        ),
                      ]),
                      
                      SizedBox(height: 24),
                      
                      // Section: Cài đặt
                      _buildSectionTitle('Cài đặt', Icons.settings),
                      SizedBox(height: 12),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.notifications_none,
                          title: 'Thông báo',
                          subtitle: 'Quản lý thông báo của bạn',
                          color: Colors.purple.shade400,
                          onTap: () => _navigateTo(const NotificationsScreen()),
                        ),
                      ]),
                      
                      SizedBox(height: 24),
                      
                      // Section: Hỗ trợ
                      _buildSectionTitle('Hỗ trợ', Icons.help_outline),
                      SizedBox(height: 12),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.support_agent,
                          title: 'Trợ giúp & Hỗ trợ',
                          subtitle: 'Liên hệ với chúng tôi',
                          color: Colors.green.shade400,
                          onTap: () => _navigateTo(const HelpSupportScreen()),
                        ),
                        _MenuItem(
                          icon: Icons.info_outline,
                          title: 'Về chúng tôi',
                          subtitle: 'Thông tin ứng dụng',
                          color: Colors.blue.shade400,
                          onTap: () => _navigateTo(const AboutUsScreen()),
                        ),
                        _MenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Chính sách & Điều khoản',
                          subtitle: 'Quy định và bảo mật',
                          color: Colors.orange.shade400,
                          onTap: () => _navigateTo(const TermsPolicyScreen(mode: 'terms')),
                        ),
                      ]),
                      
                      SizedBox(height: 32),
                      
                      // Logout Button
                      Container(
                        // ... (giữ nguyên Logout Button)
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade400,
                              Colors.red.shade500,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade200,
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: Icon(Icons.logout_rounded, size: 24),
                          label: Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Version Info
                      Center(
                        // ... (giữ nguyên Version Info)
                        child: Text(
                          'Gentlemen\'s Grooming v1.0.0',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // XÓA HÀM _buildAdminButton()
  
  // ... (giữ nguyên hàm _buildSectionTitle)
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF0891B2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Color(0xFF0891B2),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ... (giữ nguyên hàm _buildMenuCard)
  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? Radius.circular(20) : Radius.zero,
                  bottom: isLast ? Radius.circular(20) : Radius.zero,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            if (item.subtitle != null) ...[
                              SizedBox(height: 2),
                              Text(
                                item.subtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(left: 72),
                  child: Divider(height: 1, color: Colors.grey.shade100),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ... (giữ nguyên class _MenuItem)
class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });
}