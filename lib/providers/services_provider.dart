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
      notifyListeners();

      _services = await _firestoreService.getServices().first;

      _isLoadingServices = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  /// Load all stylists
  Future<void> loadStylists() async {
    try {
      _isLoadingStylists = true;
      notifyListeners();

      _stylists = await _firestoreService.getStylists().first;

      _isLoadingStylists = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingStylists = false;
      notifyListeners();
    }
  }

  /// Load all branches
  Future<void> loadBranches() async {
    try {
      _isLoadingBranches = true;
      notifyListeners();

      _branches = await _firestoreService.getBranches().first;

      _isLoadingBranches = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingBranches = false;
      notifyListeners();
    }
  }

  /// Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadServices(),
      loadStylists(),
      loadBranches(),
    ]);
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
    return _services.where((s) => 
      s.name.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Search stylists
  List<Stylist> searchStylists(String query) {
    final lowerQuery = query.toLowerCase();
    return _stylists.where((s) => 
      s.name.toLowerCase().contains(lowerQuery) ||
      s.experience.toLowerCase().contains(lowerQuery)
    ).toList();
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
