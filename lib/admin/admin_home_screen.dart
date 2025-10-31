// lib/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'manage_services_screen.dart';
import 'manage_branches_screen.dart';
import 'manage_stylists_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_vouchers_screen.dart';
import '../services/auth_service.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          // Nút đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await AuthService().signOut();
              // Sau khi đăng xuất, StreamBuilder trong AdminApp sẽ tự động
              // chuyển người dùng về trang AdminLoginScreen.
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminCard(
            context,
            icon: Icons.calendar_today_rounded,
            title: 'Quản lý Đặt lịch',
            color: Colors.purple.shade400,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageBookingsScreen()),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.content_cut_rounded,
            title: 'Quản lý Dịch vụ',
            color: Colors.blue.shade400,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageServicesScreen()),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.storefront_rounded,
            title: 'Quản lý Chi nhánh',
            color: Colors.green.shade400,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageBranchesScreen()),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.person_rounded,
            title: 'Quản lý Stylist',
            color: Colors.orange.shade400,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageStylistsScreen()),
              );
            },
          ),
          _buildAdminCard(
            context,
            icon: Icons.local_offer_rounded,
            title: 'Quản lý Khuyến mãi',
            color: Colors.pink.shade400,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageVouchersScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: onTap,
      ),
    );
  }
}