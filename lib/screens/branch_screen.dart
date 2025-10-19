// lib/screens/branch_screen.dart
import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';
import 'map_screen.dart';
// --- THÊM IMPORT ---
import 'quick_booking_screen.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Branch> _branches = [];

  // --- THAY ĐỔI: Chuyển hướng tới bản đồ với một chi nhánh đích cụ thể ---
  void _navigateToDirections(Branch destinationBranch) {
    if (_branches.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            branches: _branches,
            destinationBranch: destinationBranch, // Truyền chi nhánh cần chỉ đường
          ),
        ),
      );
    }
  }

  // --- THÊM MỚI: Chuyển hướng tới màn hình đặt lịch nhanh với chi nhánh đã chọn ---
  void _navigateToQuickBooking(Branch selectedBranch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickBookingScreen(initialBranch: selectedBranch),
      ),
    );
  }

  void _navigateToMapScreen() {
    if (_branches.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(branches: _branches),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có dữ liệu chi nhánh.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF0891B2),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Hệ thống Salon',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                child: Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 60,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            actions: [
              // --- THAY ĐỔI: Tăng kích thước icon bản đồ ---
              IconButton(
                onPressed: _navigateToMapScreen,
                icon: Container(
                  padding: EdgeInsets.all(8), // Tăng padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.map_outlined, color: Colors.white, size: 24), // Tăng size
                ),
              ),
              SizedBox(width: 10), // Tăng khoảng cách
            ],
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Branch>>(
              stream: _firestoreService.getBranches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('Lỗi: ${snapshot.error}'),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Không có chi nhánh nào."));
                }

                _branches = snapshot.data!;
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  itemCount: _branches.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: _buildBranchCard(_branches[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(Branch branch) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  branch.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.business_rounded,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        branch.rating.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 12),
                _infoRow(Icons.location_on_outlined, branch.address),
                SizedBox(height: 8),
                _infoRow(Icons.access_time_outlined, 'Giờ mở cửa: ${branch.hours}'),
                SizedBox(height: 16),
                // --- THAY ĐỔI: Thay thế 1 nút bằng 2 nút mới ---
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToDirections(branch),
                        icon: Icon(Icons.directions_car_rounded, size: 18),
                        label: Text('Chỉ đường'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF0891B2),
                          side: BorderSide(color: Color(0xFF0891B2)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToQuickBooking(branch),
                        icon: Icon(Icons.calendar_month_rounded, size: 18),
                        label: Text('Đặt lịch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0891B2),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF0891B2), size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}