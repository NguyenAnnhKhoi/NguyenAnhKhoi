// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../models/voucher.dart';
import '../providers/auth_provider.dart';
import '../providers/services_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/voucher_service.dart';
import 'booking_screen.dart';
import 'search_screen.dart';
import 'voucher_detail_screen.dart';
import '../widgets/service_card_shimmer.dart';
import '../widgets/safe_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PageController _voucherPageController = PageController();
  Timer? _voucherTimer;
  int _currentVoucherPage = 0;
  bool _isVoucherTimerInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load services and favorites
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ServicesProvider>().loadServices();
        context.read<FavoritesProvider>().loadFavorites();
      }
    });
  }

  @override
  void dispose() {
    _voucherPageController.dispose();
    _voucherTimer?.cancel();
    super.dispose();
  }
  
  void _startVoucherAutoScroll(int voucherCount) {
    if (_isVoucherTimerInitialized || voucherCount <= 1) return;
    
    _isVoucherTimerInitialized = true;
    _voucherTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_voucherPageController.hasClients && mounted) {
        _currentVoucherPage = (_currentVoucherPage + 1) % voucherCount;
        _voucherPageController.animateToPage(
          _currentVoucherPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double appBarExpandedHeight = 220 + topPadding;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: appBarExpandedHeight,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFFFF6B9D),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildVoucherCarousel(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Dịch vụ nổi bật'),
                    const SizedBox(height: 16),
                    _buildServicesSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User greeting
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  SafeCircleAvatar(
                    imageUrl: user?.photoURL,
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Xin chào,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.displayName ?? 'Khách hàng',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.search,
                        color: Color(0xFF94A3B8),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tìm kiếm dịch vụ, stylist...',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Top buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TopButton(
                    icon: Icons.local_offer_rounded,
                    label: 'Khuyến mãi',
                    gradient: const [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
                    onTap: () {},
                  ),
                  _TopButton(
                    icon: Icons.verified_user_rounded,
                    label: 'Cam kết',
                    gradient: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    onTap: () {},
                  ),
                  _TopButton(
                    icon: Icons.info_rounded,
                    label: 'Hệ thống',
                    gradient: const [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCarousel() {
    final voucherService = VoucherService();
    
    return StreamBuilder<List<Voucher>>(
      stream: voucherService.getActiveVouchers(),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          print('Voucher Error: ${snapshot.error}');
          return const SizedBox.shrink();
        }
        
        // Show shimmer only briefly
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return _buildVoucherShimmer();
        }
        
        // Hide if no data
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final vouchers = snapshot.data!;
        
        // Start auto-scroll when vouchers are loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _startVoucherAutoScroll(vouchers.length);
          }
        });
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Voucher nổi bật',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all vouchers screen
                    },
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Color(0xFFFF6B9D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _voucherPageController,
                itemCount: vouchers.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentVoucherPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildVoucherCard(vouchers[index]);
                },
              ),
            ),
            const SizedBox(height: 12),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                vouchers.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentVoucherPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentVoucherPage == index 
                        ? const Color(0xFFFF6B9D) 
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVoucherShimmer() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherCard(Voucher voucher) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoucherDetailScreen(voucher: voucher),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background with gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF6B9D),
                      Color(0xFFFF8FAB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              
              // Pattern overlay
              CustomPaint(
                painter: _VoucherPatternPainter(),
                size: Size.infinite,
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              voucher.type.toString().split('.').last.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            voucher.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            voucher.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white.withOpacity(0.8),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'HSD: ${voucher.endDate.day}/${voucher.endDate.month}/${voucher.endDate.year}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.card_giftcard_rounded,
                            color: Color(0xFFFF6B9D),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nhận',
                            style: TextStyle(
                              color: Color(0xFFFF6B9D),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    final servicesProvider = context.watch<ServicesProvider>();

    if (servicesProvider.isLoadingServices) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: const ServiceCardShimmer(),
            ),
          ),
        ),
      );
    }

    if (servicesProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[300],
              ),
              const SizedBox(height: 12),
              Text(
                servicesProvider.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => servicesProvider.loadServices(),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (servicesProvider.services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.content_cut_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Chưa có dịch vụ nào',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: servicesProvider.services.map((service) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildServiceCard(service),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(service.id);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingScreen(preSelectedService: service),
          ),
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image with favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SafeNetworkImage(
                    imageUrl: service.image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: _buildPlaceholderImage(),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      favoritesProvider.toggleFavorite(service.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite ? 'Đã xóa khỏi yêu thích' : 'Đã thêm vào yêu thích',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Service info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dịch vụ chuyên nghiệp',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service.duration} phút',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${service.price.toStringAsFixed(0)} đ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B9D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[200]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.content_cut_rounded,
        size: 60,
        color: Colors.grey[400],
      ),
    );
  }
}

// Top button widget
class _TopButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  
  const _TopButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Voucher pattern painter
class _VoucherPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.2 + i * 0.2), size.height * 0.3),
        30,
        paint,
      );
    }

    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.3 + i * 0.2), size.height * 0.7),
        25,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
