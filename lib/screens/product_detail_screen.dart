// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/product_review.dart';
import '../models/order.dart' as order_model;
import '../models/order_item.dart';
import '../services/firestore_service.dart';
import '../services/cart_service.dart';
import '../main.dart';
import 'product_payment_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _quantity = 1;
  final TextEditingController _reviewCommentController =
      TextEditingController();
  int _selectedRating = 5;

  @override
  void dispose() {
    _reviewCommentController.dispose();
    super.dispose();
  }

  void _addToCart() async {
    if (widget.product.stock < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số lượng sản phẩm không đủ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ← CHANGED: Lưu vào SharedPreferences qua CartService
    try {
      await CartService.addToCart(widget.product, _quantity);

      if (mounted) {
        // Cập nhật badge
        MainScreenState.instance?.updateCartCount(
          await CartService.getCartCount(),
        );

        // Hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${_quantity} sản phẩm vào giỏ hàng'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Quay lại trang cửa hàng
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ← NEW: Method "Mua ngay" - Thanh toán luôn
  void _buyNow() {
    if (widget.product.stock < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số lượng sản phẩm không đủ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tạo order item
    final orderItem = OrderItem(
      productId: widget.product.id,
      productName: widget.product.name,
      productImageUrl: widget.product.imageUrl,
      price: widget.product.price,
      quantity: _quantity,
    );

    // Tính tổng tiền
    final total = widget.product.price * _quantity;

    // Tạo order
    final order = order_model.Order(
      id: '',
      userId: user.uid,
      customerName: user.displayName ?? '',
      customerPhone: '',
      customerAddress: null,
      items: [orderItem],
      subtotal: total,
      discountAmount: null,
      voucherCode: null,
      total: total,
      status: 'pending',
      paymentMethod: 'VietQR',
      isPaid: false,
      createdAt: DateTime.now(),
    );

    // Navigate to payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPaymentScreen(order: order),
      ),
    );
  }

  void _showReviewDialog() {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đánh giá'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá sản phẩm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chọn số sao:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewCommentController,
              decoration: const InputDecoration(
                labelText: 'Bình luận (tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final userName = user.displayName ?? 'Người dùng';

                final review = ProductReview(
                  id: '',
                  productId: widget.product.id,
                  userId: user.uid,
                  userName: userName,
                  rating: _selectedRating,
                  comment: _reviewCommentController.text.trim().isEmpty
                      ? null
                      : _reviewCommentController.text.trim(),
                  createdAt: DateTime.now(),
                );

                await _firestoreService.addProductReview(review);
                if (mounted) {
                  Navigator.pop(context);
                  _reviewCommentController.clear();
                  _selectedRating = 5;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đánh giá thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        backgroundColor: const Color(0xFF0891B2),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child:
                  widget.product.imageUrl != null &&
                      widget.product.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.shopping_bag,
                          size: 80,
                          color: Colors.grey,
                        );
                      },
                    )
                  : const Icon(
                      Icons.shopping_bag,
                      size: 80,
                      color: Colors.grey,
                    ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.product.rating != null) ...[
                        ...List.generate(5, (index) {
                          return Icon(
                            index < widget.product.rating!.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.product.rating!.toStringAsFixed(1)} (${widget.product.reviewCount} đánh giá)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.product.price.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0891B2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Mô tả',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Tồn kho: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.product.stock} sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.product.stock > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quantity selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Số lượng: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _quantity > 1
                            ? () {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _quantity < widget.product.stock
                            ? () {
                                setState(() {
                                  _quantity++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reviews section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Đánh giá',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showReviewDialog,
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Viết đánh giá'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<ProductReview>>(
                    stream: _firestoreService.getProductReviews(
                      widget.product.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text('Lỗi: ${snapshot.error}');
                      }

                      final reviews = snapshot.data ?? [];

                      if (reviews.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('Chưa có đánh giá nào'),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        review.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: List.generate(5, (i) {
                                          return Icon(
                                            i < review.rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  if (review.comment != null) ...[
                                    const SizedBox(height: 8),
                                    Text(review.comment!),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // ← NEW: Nút "Thêm giỏ hàng" (bên trái)
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.product.stock > 0 ? _addToCart : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF0891B2), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Thêm giỏ hàng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0891B2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ← NEW: Nút "Mua ngay" (bên phải)
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.product.stock > 0 ? _buyNow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.product.stock > 0 ? 'Mua ngay' : 'Hết hàng',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
