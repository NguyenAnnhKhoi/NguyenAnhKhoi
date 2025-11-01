// lib/providers/services_provider.dart
import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';

/// Provider quản lý services, stylists, branches
class ServicesProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Service> _services = [];
  List<Stylist> _stylists = [];
  List<Branch> _branches = [];

  bool _isLoadingServices = false;
  bool _isLoadingStylists = false;
  bool _isLoadingBranches = false;

  String? _errorMessage;

  // Getters
  List<Service> get services => _services;
  List<Stylist> get stylists => _stylists;
  List<Branch> get branches => _branches;

  bool get isLoadingServices => _isLoadingServices;
  bool get isLoadingStylists => _isLoadingStylists;
  bool get isLoadingBranches => _isLoadingBranches;

  String? get errorMessage => _errorMessage;

  /// Load all services
  Future<void> loadServices() async {
    try {
      _isLoadingServices = true;
      _errorMessage = null;
      notifyListeners();

      // Add timeout to prevent infinite loading
      _services = await _firestoreService.getServices().first.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Services loading timeout - returning empty list');
          return [];
        },
      );

      print('Loaded ${_services.length} services');
      _isLoadingServices = false;
      notifyListeners();
    } catch (e) {
      print('Error loading services: $e');
      _errorMessage = 'Không thể tải dịch vụ: ${e.toString()}';
      _isLoadingServices = false;
      _services = []; // Set empty list on error
      notifyListeners();
    }
  }

  /// Load all stylists
  Future<void> loadStylists() async {
    try {
      _isLoadingStylists = true;
      _errorMessage = null;
      notifyListeners();

      _stylists = await _firestoreService.getStylists().first.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Stylists loading timeout - returning empty list');
          return [];
        },
      );

      print('Loaded ${_stylists.length} stylists');
      _isLoadingStylists = false;
      notifyListeners();
    } catch (e) {
      print('Error loading stylists: $e');
      _errorMessage = 'Không thể tải stylist: ${e.toString()}';
      _isLoadingStylists = false;
      _stylists = [];
      notifyListeners();
    }
  }

  /// Load all branches
  Future<void> loadBranches() async {
    try {
      _isLoadingBranches = true;
      _errorMessage = null;
      notifyListeners();

      _branches = await _firestoreService.getBranches().first.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Branches loading timeout - returning empty list');
          return [];
        },
      );

      print('Loaded ${_branches.length} branches');
      _isLoadingBranches = false;
      notifyListeners();
    } catch (e) {
      print('Error loading branches: $e');
      _errorMessage = 'Không thể tải chi nhánh: ${e.toString()}';
      _isLoadingBranches = false;
      _branches = [];
      notifyListeners();
    }
  }

  /// Load all data
  Future<void> loadAllData() async {
    await Future.wait([loadServices(), loadStylists(), loadBranches()]);
  }

  /// Get service by ID
  Service? getServiceById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get stylist by ID
  Stylist? getStylistById(String id) {
    try {
      return _stylists.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get branch by ID
  Branch? getBranchById(String id) {
    try {
      return _branches.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search services
  List<Service> searchServices(String query) {
    final lowerQuery = query.toLowerCase();
    return _services
        .where((s) => s.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Search stylists
  List<Stylist> searchStylists(String query) {
    final lowerQuery = query.toLowerCase();
    return _stylists
        .where(
          (s) =>
              s.name.toLowerCase().contains(lowerQuery) ||
              s.experience.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Get top rated services
  List<Service> getTopRatedServices({int limit = 5}) {
    final sorted = List<Service>.from(_services)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  /// Get top rated stylists
  List<Stylist> getTopRatedStylists({int limit = 5}) {
    final sorted = List<Stylist>.from(_stylists)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
