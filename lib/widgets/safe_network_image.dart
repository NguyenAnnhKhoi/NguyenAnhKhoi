import 'package:flutter/material.dart';

/// Widget hiển thị ảnh từ network với xử lý lỗi an toàn
/// Tự động phát hiện và bỏ qua các URL không hợp lệ (Facebook CDN, etc.)
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra URL có hợp lệ không
    if (_isInvalidUrl(imageUrl)) {
      return _buildErrorWidget();
    }

    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildLoadingWidget(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        // Không log lỗi để tránh spam console
        return _buildErrorWidget();
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  bool _isInvalidUrl(String url) {
    if (url.isEmpty) return true;
    
    // Danh sách các domain không hợp lệ hoặc bị chặn
    final invalidDomains = [
      'fbcdn.net',
      'facebook.com',
      'fb.com',
    ];

    return invalidDomains.any((domain) => url.contains(domain));
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / 
                loadingProgress.expectedTotalBytes!
              : null,
          color: const Color(0xFFFF6B9D),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[200]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: (height ?? 100) * 0.3,
        color: Colors.grey[400],
      ),
    );
  }
}

/// Extension cho CircleAvatar với SafeNetworkImage
class SafeCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? child;
  final Color? backgroundColor;

  const SafeCircleAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu không có URL hoặc URL không hợp lệ, dùng child hoặc icon mặc định
    if (imageUrl == null || _isInvalidUrl(imageUrl!)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: child ?? Icon(
          Icons.person,
          size: radius,
          color: Colors.grey[600],
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      backgroundImage: NetworkImage(imageUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        // Không log lỗi để tránh spam console
      },
      child: Container(), // Empty container để tránh hiển thị child khi ảnh load thành công
    );
  }

  bool _isInvalidUrl(String url) {
    if (url.isEmpty) return true;
    
    final invalidDomains = [
      'fbcdn.net',
      'facebook.com',
      'fb.com',
    ];

    return invalidDomains.any((domain) => url.contains(domain));
  }
}
