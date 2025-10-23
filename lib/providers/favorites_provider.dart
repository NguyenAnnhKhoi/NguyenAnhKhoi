// lib/providers/favorites_provider.dart
import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../services/firestore_service.dart';

/// Provider quản lý favorite services
class FavoritesProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Set<String> _favoriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if service is favorite
  bool isFavorite(String serviceId) {
    return _favoriteIds.contains(serviceId);
  }

  /// Load favorite IDs from Firestore
  Future<void> loadFavorites() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get user's favorite services
      final favorites = await _firestoreService.getFavoriteServices().first;
      _favoriteIds = favorites.map((s) => s.id).toSet();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String serviceId) async {
    try {
      await _firestoreService.toggleFavoriteService(serviceId);

      if (_favoriteIds.contains(serviceId)) {
        _favoriteIds.remove(serviceId);
      } else {
        _favoriteIds.add(serviceId);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Get favorite services stream
  Stream<List<Service>> getFavoriteServicesStream() {
    return _firestoreService.getFavoriteServices();
  }

  /// Clear all favorites (for logout)
  void clearFavorites() {
    _favoriteIds.clear();
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
