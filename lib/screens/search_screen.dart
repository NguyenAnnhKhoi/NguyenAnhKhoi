// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../models/branch.dart';
import 'booking_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<Service> _services = [];
  List<Stylist> _stylists = [];
  List<Service> _filteredServices = [];
  List<Stylist> _filteredStylists = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load services
      final servicesSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .get();
      _services = servicesSnapshot.docs
          .map((doc) => Service.fromFirestore(doc))
          .toList();

      // Load stylists
      final stylistsSnapshot = await FirebaseFirestore.instance
          .collection('stylists')
          .get();
      _stylists = stylistsSnapshot.docs
          .map((doc) => Stylist.fromFirestore(doc))
          .toList();

      _filteredServices = _services;
      _filteredStylists = _stylists;
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredServices = _services;
        _filteredStylists = _stylists;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredServices = _services.where((service) {
        return service.name.toLowerCase().contains(lowerQuery) ||
            service.duration.toLowerCase().contains(lowerQuery);
      }).toList();

      _filteredStylists = _stylists.where((stylist) {
        return stylist.name.toLowerCase().contains(lowerQuery) ||
            stylist.branchName?.toLowerCase().contains(lowerQuery) == true;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0891B2),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _performSearch,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm dịch vụ, stylist...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0891B2)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'Dịch vụ'),
            Tab(text: 'Stylist'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0891B2)),
            )
          : TabBarView(
              controller: _tabController,
              children: [_buildServicesList(), _buildStylistsList()],
            ),
    );
  }

  Widget _buildServicesList() {
    if (_filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy dịch vụ nào',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Chuyển sang BookingScreen với service đã được chọn sẵn
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingScreen(preSelectedService: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  service.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF0891B2),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.duration,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${service.price.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0891B2),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Color(0xFFFFB300),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildStylistsList() {
    if (_filteredStylists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy stylist nào',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStylists.length,
      itemBuilder: (context, index) {
        final stylist = _filteredStylists[index];
        return _buildStylistCard(stylist);
      },
    );
  }

  Widget _buildStylistCard(Stylist stylist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          // Hiển thị loading khi đang load branch
          if (stylist.branchId != null && stylist.branchId!.isNotEmpty) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: Color(0xFF0891B2)),
              ),
            );
          }

          // Chuyển sang BookingScreen với stylist và branch đã được chọn sẵn
          Branch? branch;

          // Nếu stylist có branchId, load branch info
          if (stylist.branchId != null && stylist.branchId!.isNotEmpty) {
            try {
              final branchDoc = await FirebaseFirestore.instance
                  .collection('branches')
                  .doc(stylist.branchId)
                  .get();

              if (branchDoc.exists) {
                branch = Branch.fromFirestore(branchDoc);
              }
            } catch (e) {
              debugPrint('Error loading branch: $e');
            }

            // Đóng loading dialog
            if (mounted) {
              Navigator.pop(context);
            }
          }

          // Chuyển sang booking screen
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingScreen(
                  preSelectedStylist: stylist,
                  preSelectedBranch: branch,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: stylist.image.isNotEmpty
                    ? NetworkImage(stylist.image)
                    : null,
                child: stylist.image.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stylist.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (stylist.branchName?.isNotEmpty == true)
                      Row(
                        children: [
                          const Icon(
                            Icons.store,
                            size: 14,
                            color: Color(0xFF0891B2),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stylist.branchName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          stylist.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ), // Đóng Padding
      ), // Đóng InkWell
    ); // Đóng Card
  }
}
