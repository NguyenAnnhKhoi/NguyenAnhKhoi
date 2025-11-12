// lib/services/cart_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static const String _cartKey = 'cart_items';
  static SharedPreferences? _prefs;

  // ← NEW: Khởi tạo SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ← NEW: Lấy giỏ hàng từ SharedPreferences
  static Future<List<CartItem>> getCart() async {
    await init();
    final cartJson = _prefs?.getString(_cartKey);
    if (cartJson == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(cartJson);
      // Parse từ JSON
      return jsonList.map((item) {
        final product = Product(
          id: item['product']['id'],
          name: item['product']['name'],
          description: item['product']['description'],
          price: (item['product']['price'] as num).toDouble(),
          imageUrl: item['product']['imageUrl'],
          categoryId: item['product']['categoryId'],
          stock: item['product']['stock'],
          isActive: item['product']['isActive'] ?? true,
          rating: item['product']['rating']?.toDouble(),
          reviewCount: item['product']['reviewCount'] ?? 0,
          createdAt: DateTime.parse(item['product']['createdAt']),
          updatedAt: DateTime.parse(item['product']['updatedAt']),
        );
        return CartItem(product: product, quantity: item['quantity']);
      }).toList();
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  // ← NEW: Thêm sản phẩm vào giỏ
  static Future<void> addToCart(Product product, int quantity) async {
    await init();
    final cart = await getCart();

    // Kiểm tra xem sản phẩm đã có trong giỏ không
    final existingIndex = cart.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Tăng số lượng nếu đã tồn tại
      cart[existingIndex] = cart[existingIndex].copyWith(
        quantity: cart[existingIndex].quantity + quantity,
      );
    } else {
      // Thêm sản phẩm mới
      cart.add(CartItem(product: product, quantity: quantity));
    }

    // Lưu vào SharedPreferences
    await _saveCart(cart);
  }

  // ← NEW: Xóa sản phẩm khỏi giỏ
  static Future<void> removeFromCart(String productId) async {
    await init();
    final cart = await getCart();
    cart.removeWhere((item) => item.product.id == productId);
    await _saveCart(cart);
  }

  // ← NEW: Cập nhật số lượng
  static Future<void> updateQuantity(String productId, int quantity) async {
    await init();
    final cart = await getCart();
    final index = cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        cart.removeAt(index);
      } else {
        cart[index] = cart[index].copyWith(quantity: quantity);
      }
      await _saveCart(cart);
    }
  }

  // ← NEW: Xóa toàn bộ giỏ hàng
  static Future<void> clearCart() async {
    await init();
    await _prefs?.remove(_cartKey);
  }

  // ← NEW: Lưu giỏ hàng vào SharedPreferences
  static Future<void> _saveCart(List<CartItem> cart) async {
    await init();
    final cartJson = jsonEncode(
      cart
          .map(
            (item) => {
              'product': {
                'id': item.product.id,
                'name': item.product.name,
                'description': item.product.description,
                'price': item.product.price,
                'imageUrl': item.product.imageUrl,
                'categoryId': item.product.categoryId,
                'stock': item.product.stock,
                'isActive': item.product.isActive,
                'rating': item.product.rating,
                'reviewCount': item.product.reviewCount,
                'createdAt': item.product.createdAt.toIso8601String(),
                'updatedAt': item.product.updatedAt.toIso8601String(),
              },
              'quantity': item.quantity,
            },
          )
          .toList(),
    );
    await _prefs?.setString(_cartKey, cartJson);
  }

  // ← NEW: Lấy số lượng item trong giỏ
  static Future<int> getCartCount() async {
    final cart = await getCart();
    return cart.length;
  }
}
