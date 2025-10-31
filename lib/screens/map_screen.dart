import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/branch.dart';

class MapScreen extends StatefulWidget {
  final List<Branch> branches;
  // --- THÊM MỚI: Thêm tham số tùy chọn cho chi nhánh đích ---
  final Branch? destinationBranch;

  const MapScreen({
    super.key, 
    required this.branches, 
    this.destinationBranch, // Constructor mới
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late MapController _mapController;
  GeoPoint? _userLocation;
  bool _isLoading = true;

  late AnimationController _cardAnimationController;
  late Animation<Offset> _cardAnimation;
  Branch? _selectedBranch;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initPosition: GeoPoint(latitude: 16.047079, longitude: 108.206230),
    );
    _initializeMap();

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _initializeMap() async {
    try {
      if (!mounted) return;
      await _checkAndRequestLocationPermission();
      if (!mounted) return;
      
      await _getCurrentLocation();
      if (!mounted) return;
      
      await _addBranchMarkers();
      if (!mounted) return;

      // --- THÊM MỚI: Tự động vẽ đường đi nếu có chi nhánh đích ---
      await _drawInitialRouteIfNeeded();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Error initializing map: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khởi tạo bản đồ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- HÀM MỚI: Kiểm tra và vẽ đường đi ban đầu ---
  Future<void> _drawInitialRouteIfNeeded() async {
    // Chỉ vẽ khi có chi nhánh đích và đã lấy được vị trí người dùng
    if (widget.destinationBranch != null && _userLocation != null) {
      // Đợi một chút để đảm bảo map đã sẵn sàng
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _drawRoute(widget.destinationBranch!);
      }
    }
  }

  // ... (Toàn bộ các hàm khác như checkPermission, getCurrentLocation... giữ nguyên)
  // ...
  // ...
  Future<void> _checkAndRequestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dịch vụ định vị đã bị tắt. Vui lòng bật để tiếp tục.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quyền truy cập vị trí bị từ chối.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quyền truy cập vị trí bị từ chối vĩnh viễn.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (!mounted) return;

      setState(() {
        _userLocation = GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });

      if (!mounted) return;
      
      await _mapController.moveTo(_userLocation!);
      if (!mounted) return;
      
      await _mapController.setZoom(zoomLevel: 16.0);
      if (!mounted) return;

      await _mapController.addMarker(
        _userLocation!,
        markerIcon: const MarkerIcon(
          icon: Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 48,
          ),
        ),
      );
    } catch (e) {
      debugPrint("❌ Lỗi khi lấy vị trí: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lấy vị trí hiện tại'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _addBranchMarkers() async {
    for (var branch in widget.branches) {
      if (!mounted) return;
      
      GeoPoint branchPoint = GeoPoint(
        latitude: branch.latitude,
        longitude: branch.longitude,
      );
      try {
        // Sử dụng icon mặc định của flutter_osm_plugin thay vì custom widget
        await _mapController.addMarker(
          branchPoint,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Color(0xFF0891B2),
              size: 48,
            ),
          ),
        );
      } catch (e) {
        debugPrint("❌ Lỗi khi thêm marker chi nhánh ${branch.name}: $e");
      }
    }
  }

  Future<void> _drawRoute(Branch destinationBranch) async {
    try {
      if (!mounted) return;
      
      if (_userLocation == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tìm thấy vị trí của bạn.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      if (!mounted) return;
      
      setState(() {
        _selectedBranch = destinationBranch;
      });
      
      _cardAnimationController.forward();
      
      // Cập nhật markers để highlight chi nhánh đã chọn
      await _refreshBranchMarkers();
      
      if (!mounted) return;

      await _mapController.clearAllRoads();
      
      if (!mounted) return;

      GeoPoint destinationPoint = GeoPoint(
        latitude: destinationBranch.latitude,
        longitude: destinationBranch.longitude,
      );

      await _mapController.drawRoad(
        _userLocation!,
        destinationPoint,
        roadType: RoadType.car,
        roadOption: const RoadOption(
          roadWidth: 8,
          roadColor: Color(0xFF0891B2),
          zoomInto: true,
        ),
      );
    } catch (e) {
      debugPrint("❌ Lỗi khi vẽ đường đi: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể vẽ đường đi. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _refreshBranchMarkers() async {
    // Xóa và thêm lại tất cả markers với trạng thái mới
    try {
      for (var branch in widget.branches) {
        if (!mounted) return;
        
        GeoPoint branchPoint = GeoPoint(
          latitude: branch.latitude,
          longitude: branch.longitude,
        );
        
        // Xóa marker cũ
        try {
          await _mapController.removeMarker(branchPoint);
        } catch (e) {
          debugPrint("⚠️ Không thể xóa marker: $e");
          // Continue anyway
        }
        
        if (!mounted) return;
        
        // Thêm marker mới với màu highlight nếu được chọn
        bool isSelected = _selectedBranch?.id == branch.id;
        await _mapController.addMarker(
          branchPoint,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: isSelected ? Colors.red : const Color(0xFF0891B2),
              size: isSelected ? 56 : 48,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi refresh markers: $e");
    }
  }

  Future<void> _launchMaps(Branch branch) async {
    final lat = branch.latitude;
    final long = branch.longitude;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$long';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    try {
      _cardAnimationController.dispose();
      _mapController.dispose();
    } catch (e) {
      debugPrint("❌ Error disposing controllers: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_userLocation != null && mounted) {
            try {
              _mapController.moveTo(_userLocation!);
              _mapController.setZoom(zoomLevel: 16.0);
            } catch (e) {
              debugPrint("❌ Lỗi khi di chuyển đến vị trí người dùng: $e");
            }
          }
        },
        backgroundColor: const Color(0xFF0891B2),
        child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 28),
      ),
      body: Stack(
        children: [
          OSMFlutter(
            controller: _mapController,
            osmOption: const OSMOption(
              zoomOption: ZoomOption(
                initZoom: 8,
                minZoomLevel: 3,
                maxZoomLevel: 19,
                stepZoom: 1.0,
              ),
              userTrackingOption: UserTrackingOption(
                enableTracking: false,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0891B2),
                    const Color(0xFF0891B2).withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
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
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0891B2)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.map_outlined, color: Color(0xFF0891B2), size: 22),
                              const SizedBox(width: 12),
                              Text(
                                'Bản đồ chi nhánh',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
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
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.95),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0891B2).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: Color(0xFF0891B2),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Đang tìm vị trí của bạn...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: _buildBranchesList(),
            ),
          ),
          if (_selectedBranch != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SafeArea(
                top: false,
                child: _buildSelectedBranchCard(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBranchesList() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _selectedBranch == null ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: _selectedBranch != null,
        child: SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.branches.length,
            itemBuilder: (context, index) {
              final branch = widget.branches[index];
              return GestureDetector(
                onTap: () async {
                  if (!mounted) return;
                  
                  try {
                    // Add haptic feedback
                    await _mapController.moveTo(
                      GeoPoint(
                        latitude: branch.latitude,
                        longitude: branch.longitude,
                      ),
                    );
                    
                    if (!mounted) return;
                    await _mapController.setZoom(zoomLevel: 16.5);
                    
                    if (!mounted) return;
                    await _drawRoute(branch);
                  } catch (e) {
                    debugPrint("❌ Lỗi khi chọn chi nhánh: $e");
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Không thể chọn chi nhánh này'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0891B2).withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0891B2).withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              bottomLeft: Radius.circular(18),
                            ),
                            child: Image.network(
                              branch.image,
                              width: 110,
                              height: 130,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 110,
                                  height: 130,
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    color: Colors.grey.shade400,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      branch.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.grey.shade800,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 16,
                                          color: Color(0xFF0891B2),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            branch.address,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          branch.rating.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Badge để chỉ ra có thể tap
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0891B2).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.navigation_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Chỉ đường',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedBranchCard() {
    if (_selectedBranch == null) return const SizedBox.shrink();
    return SlideTransition(
      position: _cardAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0891B2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF0891B2),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedBranch!.name,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedBranch!.address,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.grey.shade700),
                      onPressed: () async {
                        if (!mounted) return;
                        
                        try {
                          _cardAnimationController.reverse();
                          
                          if (!mounted) return;
                          await _mapController.clearAllRoads();
                          
                          // Refresh markers để bỏ highlight
                          await Future.delayed(const Duration(milliseconds: 100));
                          if (mounted) {
                            setState(() {
                              _selectedBranch = null;
                            });
                            await _refreshBranchMarkers();
                          }
                        } catch (e) {
                          debugPrint("❌ Lỗi khi đóng card: $e");
                          if (mounted) {
                            setState(() {
                              _selectedBranch = null;
                            });
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _launchMaps(_selectedBranch!),
                  icon: const Icon(Icons.directions_car_rounded, size: 22),
                  label: const Text(
                    'Chỉ đường đến đây',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF0891B2).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}