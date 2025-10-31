// lib/data/image_placeholder.dart

/// A placeholder for image URLs to avoid using Firebase Storage in development.
/// Returns empty strings to use the app's built-in placeholder images instead.
class ImagePlaceholder {
  /// Returns empty string to use app's default placeholder
  static String get serviceImageUrl => '';

  /// Returns empty string to use app's default placeholder
  static String get stylistImageUrl => '';

  /// Returns empty string to use app's default placeholder
  static String get branchImageUrl => '';

  /// Returns empty string to use app's default placeholder for service
  static String forService(String serviceName) {
    return '';
  }

  /// Returns empty string to use app's default placeholder for stylist
  static String forStylist() {
    return '';
  }

  /// Returns empty string to use app's default placeholder for branch
  static String forBranch() {
    return '';
  }
}
