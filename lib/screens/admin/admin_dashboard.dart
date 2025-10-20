// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import 'admin_ui.dart';
import 'manage_services_screen.dart';
import 'manage_branches_screen.dart';
import 'manage_stylists_screen.dart';
import 'manage_bookings_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _adminService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0891B2))),
      );
    }

    // Guard: Only allow admins
    if (_currentUser!.isAdmin != true) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quyền truy cập')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text(
                'Bạn không có quyền truy cập khu vực này',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      );
    }

    return AdminScaffold(
      title: 'Admin Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await _authService.signOut();
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminCard(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AdminColors.accent, AdminColors.accentSoft],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.shield, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chào mừng Admin!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentUser?.displayName ?? 'Admin',
                          style: const TextStyle(color: AdminColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Quản lý hệ thống',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.12,
              children: [
                _buildManagementCard(
                  icon: Icons.build_circle_outlined,
                  title: 'Dịch vụ',
                  subtitle: 'Quản lý dịch vụ',
                  color: AdminColors.accent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageServicesScreen(),
                    ),
                  ),
                ),
                _buildManagementCard(
                  icon: Icons.storefront_outlined,
                  title: 'Chi nhánh',
                  subtitle: 'Quản lý chi nhánh',
                  color: AdminColors.accentSoft,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageBranchesScreen(),
                    ),
                  ),
                ),
                _buildManagementCard(
                  icon: Icons.person_outline,
                  title: 'Stylist',
                  subtitle: 'Quản lý stylist',
                  color: const Color(0xFF6AE6E6),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageStylistsScreen(),
                    ),
                  ),
                ),
                _buildManagementCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Đơn đặt lịch',
                  subtitle: 'Quản lý đơn đặt lịch',
                  color: AdminColors.accent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageBookingsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AdminCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.arrow_outward, color: Color.fromARGB(255, 250, 249, 249)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AdminColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AdminColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
