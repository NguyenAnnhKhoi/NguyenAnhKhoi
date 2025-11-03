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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern AppBar với gradient cyan
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0891B2),
            flexibleSpace: FlexibleSpaceBar(background: _buildModernHeader()),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildVoucherCarousel(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('✨ Dịch vụ nổi bật'),
                  const SizedBox(height: 16),
                  _buildFeaturedServices(),
                  const SizedBox(height: 32),
                  _buildServicesByCategory(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0891B2), const Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User greeting row
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SafeCircleAvatar(
                      imageUrl: user?.photoURL,
                      radius: 26,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào! 👋',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.displayName ??
                              user?.email?.split('@').first ??
                              'Khách hàng',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Notification icon
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Search bar
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0891B2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF0891B2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tìm kiếm dịch vụ, stylist...',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0891B2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.tune,
                              size: 16,
                              color: Color(0xFF0891B2),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Lọc',
                              style: TextStyle(
                                color: Color(0xFF0891B2),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
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
                    colors: [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
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
                              voucher.type
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
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
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Hiển thị dịch vụ nổi bật
  Widget _buildFeaturedServices() {
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

    // Lọc dịch vụ nổi bật
    final featuredServices =
        servicesProvider.services
            .where((service) => service.isFeatured)
            .toList()
          ..sort((a, b) => a.featuredOrder.compareTo(b.featuredOrder));

    if (featuredServices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.star_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Chưa có dịch vụ nổi bật nào',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
        children: featuredServices.map((service) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildServiceCard(service, isFeatured: true),
          );
        }).toList(),
      ),
    );
  }

  // Hiển thị dịch vụ theo loại
  Widget _buildServicesByCategory() {
    final servicesProvider = context.watch<ServicesProvider>();

    if (servicesProvider.isLoadingServices) {
      return const SizedBox();
    }

    // Nhóm dịch vụ theo categoryName
    final Map<String, List<Service>> groupedServices = {};

    for (var service in servicesProvider.services) {
      if (service.categoryName != null && service.categoryName!.isNotEmpty) {
        if (!groupedServices.containsKey(service.categoryName)) {
          groupedServices[service.categoryName!] = [];
        }
        groupedServices[service.categoryName]!.add(service);
      }
    }

    if (groupedServices.isEmpty) {
      return const SizedBox();
    }

    // Sắp xếp theo tên loại
    final sortedCategories = groupedServices.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedCategories.map((categoryName) {
        final categoryServices = groupedServices[categoryName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Icon mặc định dựa trên tên loại
                  Text(
                    _getCategoryIcon(categoryName),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${categoryServices.length} dịch vụ',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: categoryServices.map((service) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildServiceCard(service),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      }).toList(),
    );
  }

  // Helper method để lấy icon mặc định theo tên loại
  String _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    // Exact matches first
    if (name == 'cắt tóc') return '✂️';
    if (name == 'cắt + gội') return '💇';
    if (name == 'nhuộm tóc') return '🎨';
    if (name == 'uốn tóc') return '🌀';
    if (name == 'gội đầu') return '💈';
    if (name == 'massage') return '💆';
    if (name == 'chăm sóc da mặt') return '🧴';
    if (name == 'cạo râu') return '🪒';
    if (name == 'tạo kiểu') return '💫';
    if (name == 'combo đặc biệt') return '⭐';
    if (name == 'dịch vụ vip') return '👑';

    // Fallback partial matches
    if (name.contains('cắt')) return '✂️';
    if (name.contains('nhuộm')) return '🎨';
    if (name.contains('uốn')) return '�';
    if (name.contains('gội')) return '💈';
    if (name.contains('massage')) return '💆';
    if (name.contains('chăm sóc') || name.contains('dưỡng')) return '🧴';
    if (name.contains('cạo')) return '🪒';
    if (name.contains('tạo kiểu') || name.contains('kiểu')) return '💫';
    if (name.contains('combo')) return '⭐';
    if (name.contains('vip')) return '�';

    return '✨'; // Icon mặc định
  }

  Widget _buildServiceCard(Service service, {bool isFeatured = false}) {
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: SafeNetworkImage(
                    imageUrl: service.image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: _buildPlaceholderImage(),
                  ),
                ),
                // Featured badge
                if (isFeatured)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Nổi bật',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                            isFavorite
                                ? 'Đã xóa khỏi yêu thích'
                                : 'Đã thêm vào yêu thích',
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
      child: Icon(Icons.content_cut_rounded, size: 60, color: Colors.grey[400]),
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
