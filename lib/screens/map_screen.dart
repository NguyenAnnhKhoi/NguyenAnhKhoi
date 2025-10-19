import 'dart:async';
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
    if (!mounted) return;
    await _checkAndRequestLocationPermission();
    await _getCurrentLocation();
    await _addBranchMarkers();

    // --- THÊM MỚI: Tự động vẽ đường đi nếu có chi nhánh đích ---
    await _drawInitialRouteIfNeeded();

    if (mounted) {
      setState(() => _isLoading = false);
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

      if (mounted) {
        setState(() {
          _userLocation = GeoPoint(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        });

        await _mapController.moveTo(_userLocation!);
        await _mapController.setZoom(zoomLevel: 16.0);

        await _mapController.addMarker(
          _userLocation!,
          markerIcon: MarkerIcon(
            iconWidget: _buildUserLocationMarker(),
          ),
        );
      }
    } catch (e) {
      print("Lỗi khi lấy vị trí: $e");
    }
  }

  Future<void> _addBranchMarkers() async {
    for (var branch in widget.branches) {
      GeoPoint branchPoint = GeoPoint(
        latitude: branch.latitude,
        longitude: branch.longitude,
      );
      try {
        await _mapController.addMarker(
          branchPoint,
          markerIcon: MarkerIcon(
            iconWidget: _buildBranchMarker(),
          ),
        );
      } catch (e) {
        print("Lỗi khi thêm marker chi nhánh: $e");
      }
    }
  }

  Future<void> _drawRoute(Branch destinationBranch) async {
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

    setState(() {
      _selectedBranch = destinationBranch;
    });
    _cardAnimationController.forward();

    await _mapController.clearAllRoads();

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
    _mapController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_userLocation != null) {
            _mapController.moveTo(_userLocation!);
            _mapController.setZoom(zoomLevel: 16.0);
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

  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0891B2).withOpacity(0.3),
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0891B2),
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchMarker() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.storefront_rounded,
        color: Colors.white,
        size: 24,
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
                onTap: () {
                  _mapController.moveTo(
                    GeoPoint(
                      latitude: branch.latitude,
                      longitude: branch.longitude,
                    ),
                  );
                  _mapController.setZoom(zoomLevel: 16.5);
                  _drawRoute(branch);
                },
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        child: Image.network(
                          branch.image,
                          width: 110,
                          height: 130,
                          fit: BoxFit.cover,
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
                      onPressed: () {
                        _cardAnimationController.reverse();
                        _mapController.clearAllRoads();
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            setState(() {
                              _selectedBranch = null;
                            });
                          }
                        });
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