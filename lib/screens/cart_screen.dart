// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart' as order_model;
import '../models/order_item.dart';
import '../models/voucher.dart';
import '../services/firestore_service.dart';
import '../services/cart_service.dart';
import 'product_payment_screen.dart';
import '../main.dart';

class CartScreen extends StatefulWidget {
  final Product? initialProduct;
  final int? initialQuantity;

  const CartScreen({super.key, this.initialProduct, this.initialQuantity});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _voucherController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<CartItem> _cartItems = [];
  Voucher? _appliedVoucher;
  bool _isLoadingVoucher = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCartFromService();
  }

  // ← NEW: Load cart từ CartService
  Future<void> _loadCartFromService() async {
    try {
      final savedCart = await CartService.getCart();
      if (mounted) {
        setState(() {
          _cartItems = savedCart;
          _updateBadge();
        });
      }
    } catch (e) {
      print('Error loading cart from service: $e');
    }
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = userDoc.data();
        if (mounted) {
          setState(() {
            _nameController.text =
                data?['displayName'] ?? user.displayName ?? '';
            _phoneController.text =
                data?['phoneNumber'] ?? user.phoneNumber ?? '';
            _addressController.text = data?['address'] ?? '';
          });
        }
      } catch (e) {
        print('Error loading user info: $e');
      }
    }
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
      return;
    }
    if (newQuantity > _cartItems[index].product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số lượng sản phẩm không đủ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      _updateBadge();
    });
    // ← NEW: Cập nhật CartService
    CartService.updateQuantity(_cartItems[index].product.id, newQuantity);
  }

  void _removeItem(int index) {
    final productId = _cartItems[index].product.id;
    setState(() {
      _cartItems.removeAt(index);
      _updateBadge();
    });
    // ← NEW: Cập nhật CartService
    CartService.removeFromCart(productId);
  }

  // ← NEW: Method cập nhật badge số lượng item
  void _updateBadge() {
    try {
      MainScreenState.instance?.updateCartCount(_cartItems.length);
    } catch (e) {
      print('Error updating badge: $e');
    }
  }

  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double get _discountAmount {
    if (_appliedVoucher == null) return 0;
    return _appliedVoucher!.calculateDiscount(_subtotal);
  }

  double get _total {
    return _subtotal - _discountAmount;
  }

  Future<void> _applyVoucher() async {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã voucher'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoadingVoucher = true);

    try {
      final voucher = await _firestoreService.getVoucherByCode(code);
      if (voucher == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mã voucher không tồn tại'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Kiểm tra voucher có áp dụng cho sản phẩm không
      final productIds = _cartItems.map((item) => item.product.id).toList();
      if (!voucher.canApplyToOrder(productIds) &&
          voucher.voucherType == 'product') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voucher không áp dụng cho sản phẩm này'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (!voucher.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voucher đã hết hạn hoặc hết số lượng'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (_subtotal < voucher.minOrderValue) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đơn hàng tối thiểu ${voucher.minOrderValue.toStringAsFixed(0)}đ để áp dụng voucher',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _appliedVoucher = voucher;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Áp dụng voucher thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingVoucher = false);
      }
    }
  }

  void _removeVoucher() {
    setState(() {
      _appliedVoucher = null;
      _voucherController.clear();
    });
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giỏ hàng trống'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số điện thoại'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Tạo order items
    final orderItems = _cartItems.map((cartItem) {
      return OrderItem(
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        productImageUrl: cartItem.product.imageUrl,
        price: cartItem.product.price,
        quantity: cartItem.quantity,
      );
    }).toList();

    // Tạo order
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

    final order = order_model.Order(
      id: '',
      userId: user.uid,
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      customerAddress: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      items: orderItems,
      subtotal: _subtotal,
      discountAmount: _discountAmount > 0 ? _discountAmount : null,
      voucherCode: _appliedVoucher?.code,
      total: _total,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: const Color(0xFF0891B2),
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Giỏ hàng trống',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cart items
                  ...List.generate(_cartItems.length, (index) {
                    final item = _cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child:
                                  item.product.imageUrl != null &&
                                      item.product.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.product.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.shopping_bag),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.product.price.toStringAsFixed(0)}đ',
                                    style: const TextStyle(
                                      color: Color(0xFF0891B2),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () =>
                                      _updateQuantity(index, item.quantity - 1),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () =>
                                      _updateQuantity(index, item.quantity + 1),
                                ),
                              ],
                            ),
                            // Remove
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Customer info
                  const Text(
                    'Thông tin giao hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ tên *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ (tùy chọn)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  // Voucher
                  const Text(
                    'Mã giảm giá',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _voucherController,
                          decoration: const InputDecoration(
                            labelText: 'Nhập mã voucher',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _appliedVoucher == null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_appliedVoucher == null)
                        ElevatedButton(
                          onPressed: _isLoadingVoucher ? null : _applyVoucher,
                          child: _isLoadingVoucher
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Áp dụng'),
                        )
                      else
                        ElevatedButton(
                          onPressed: _removeVoucher,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Hủy'),
                        ),
                    ],
                  ),

                  if (_appliedVoucher != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Voucher: ${_appliedVoucher!.code} - Giảm ${_appliedVoucher!.discount}%',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tạm tính:'),
                            Text('${_subtotal.toStringAsFixed(0)}đ'),
                          ],
                        ),
                        if (_discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Giảm giá:',
                                style: TextStyle(color: Colors.green[700]),
                              ),
                              Text(
                                '-${_discountAmount.toStringAsFixed(0)}đ',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng cộng:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_total.toStringAsFixed(0)}đ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0891B2),
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
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : Container(
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
                child: ElevatedButton(
                  onPressed: _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Thanh toán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
    );
  }
}
