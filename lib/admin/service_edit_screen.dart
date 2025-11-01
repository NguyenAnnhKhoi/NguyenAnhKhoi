// lib/admin/service_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service.dart';
import '../services/firestore_service.dart';

class ServiceEditScreen extends StatefulWidget {
  final Service? service;

  const ServiceEditScreen({super.key, this.service});

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _featuredOrderCtrl = TextEditingController(text: '999');

  // Danh sách loại dịch vụ cố định
  final List<Map<String, String>> _serviceCategories = [
    {'name': 'Cắt tóc', 'icon': '✂️'},
    {'name': 'Cắt + Gội', 'icon': '💇'},
    {'name': 'Nhuộm tóc', 'icon': '🎨'},
    {'name': 'Uốn tóc', 'icon': '🌀'},
    {'name': 'Gội đầu', 'icon': '💈'},
    {'name': 'Massage', 'icon': '💆'},
    {'name': 'Chăm sóc da mặt', 'icon': '🧴'},
    {'name': 'Cạo râu', 'icon': '🪒'},
    {'name': 'Tạo kiểu', 'icon': '💫'},
    {'name': 'Combo đặc biệt', 'icon': '⭐'},
    {'name': 'Dịch vụ VIP', 'icon': '👑'},
  ];

  String? _selectedCategoryName;
  bool _isLoading = false;
  bool _isFeatured = false;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.service!.name;
      _priceCtrl.text = widget.service!.price.toStringAsFixed(0);
      _durationCtrl.text = widget.service!.duration;
      _ratingCtrl.text = widget.service!.rating.toString();
      _imageCtrl.text = widget.service!.image;
      _isFeatured = widget.service!.isFeatured;
      _featuredOrderCtrl.text = widget.service!.featuredOrder.toString();

      // Load category name nếu có
      _selectedCategoryName = widget.service!.categoryName;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _ratingCtrl.dispose();
    _imageCtrl.dispose();
    _featuredOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra user đã đăng nhập chưa
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần đăng nhập để thực hiện thao tác này!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Reload user để lấy token mới nhất
    try {
      await currentUser.reload();
      await FirebaseAuth.instance.currentUser?.getIdToken(
        true,
      ); // Force refresh token
      debugPrint('✅ User token refreshed');
    } catch (e) {
      debugPrint('⚠️ Error refreshing token: $e');
    }

    setState(() => _isLoading = true);

    try {
      // Kiểm tra categoryName đã được chọn chưa
      if (_selectedCategoryName == null || _selectedCategoryName!.isEmpty) {
        throw Exception('Vui lòng chọn loại dịch vụ');
      }

      final serviceData = Service(
        id: _isEditing ? widget.service!.id : '',
        name: _nameCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        duration: _durationCtrl.text.trim(),
        rating: double.tryParse(_ratingCtrl.text) ?? 0.0,
        image: _imageCtrl.text.trim(),
        categoryId: null, // Không dùng categoryId nữa
        categoryName: _selectedCategoryName,
        isFeatured: _isFeatured,
        featuredOrder: int.tryParse(_featuredOrderCtrl.text) ?? 999,
      );

      debugPrint('=== Saving Service ===');
      debugPrint('Current User: ${FirebaseAuth.instance.currentUser?.email}');
      debugPrint('User UID: ${FirebaseAuth.instance.currentUser?.uid}');
      debugPrint('Service data: ${serviceData.toJson()}');
      debugPrint('Is editing: $_isEditing');

      if (_isEditing) {
        await _firestoreService.updateService(serviceData);
      } else {
        await _firestoreService.addService(serviceData);
      }

      debugPrint('Service saved successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Cập nhật dịch vụ thành công!'
                  : 'Thêm dịch vụ mới thành công!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Error saving service: $e');
      debugPrint('Error type: ${e.runtimeType}');

      if (mounted) {
        // Hiển thị error message rõ ràng hơn
        String errorMessage = 'Lỗi: $e';

        // Kiểm tra nếu là permission error
        if (e.toString().contains('permission-denied')) {
          final userEmail =
              FirebaseAuth.instance.currentUser?.email ?? 'unknown';
          final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

          errorMessage =
              '🔒 Lỗi quyền truy cập!\n\n'
              '👤 User: $userEmail\n'
              '🆔 UID: $userId\n\n'
              '⚠️ Giải pháp:\n'
              '1. Đăng xuất và đăng nhập lại\n'
              '2. Kiểm tra Firestore: users/$userId có role="admin"\n'
              '3. Thử lại sau vài giây';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa Dịch vụ' : 'Thêm Dịch vụ mới'),
        backgroundColor: const Color(0xFF0891B2),
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: _saveForm,
              tooltip: 'Lưu',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdown chọn loại dịch vụ (cố định)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategoryName,
                        decoration: const InputDecoration(
                          labelText: 'Loại dịch vụ',
                          prefixIcon: Icon(
                            Icons.category_rounded,
                            color: Color(0xFF0891B2),
                          ),
                          border: InputBorder.none,
                        ),
                        items: _serviceCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['name']!,
                            child: Row(
                              children: [
                                Text(
                                  category['icon']!,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(category['name']!),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryName = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn loại dịch vụ';
                          }
                          return null;
                        },
                      ),
                    ),
                    _buildTextFormField(
                      controller: _nameCtrl,
                      label: 'Tên dịch vụ',
                      icon: Icons.content_cut_rounded,
                    ),
                    _buildTextFormField(
                      controller: _priceCtrl,
                      label: 'Giá',
                      icon: Icons.attach_money_rounded,
                      hint: 'Ví dụ: 150000',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _durationCtrl,
                      label: 'Thời lượng',
                      icon: Icons.schedule_outlined,
                      hint: 'Ví dụ: 30 phút',
                    ),
                    _buildTextFormField(
                      controller: _ratingCtrl,
                      label: 'Đánh giá',
                      icon: Icons.star_outline,
                      hint: 'Ví dụ: 4.5',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _imageCtrl,
                      label: 'Link ảnh (URL)',
                      icon: Icons.image_outlined,
                      hint: 'https://example.com/image.jpg',
                    ),

                    // Featured Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Dịch vụ nổi bật',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            value: _isFeatured,
                            onChanged: (value) {
                              setState(() {
                                _isFeatured = value ?? false;
                              });
                            },
                            title: const Text('Đánh dấu là nổi bật'),
                            subtitle: const Text(
                              'Dịch vụ sẽ hiển thị ở đầu trang chủ',
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.orange.shade700,
                          ),
                          if (_isFeatured) ...[
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _featuredOrderCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Thứ tự hiển thị',
                                hintText: 'Số nhỏ hơn sẽ hiển thị trước',
                                prefixIcon: Icon(
                                  Icons.sort,
                                  color: Colors.orange.shade700,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (_isFeatured &&
                                    (value == null || value.trim().isEmpty)) {
                                  return 'Vui lòng nhập thứ tự';
                                }
                                if (value != null &&
                                    value.isNotEmpty &&
                                    int.tryParse(value) == null) {
                                  return 'Vui lòng nhập số hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    if (_imageCtrl.text.isNotEmpty) ...[
                      Text(
                        'Xem trước ảnh:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _imageCtrl.text,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Không thể tải ảnh',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveForm,
                      icon: Icon(_isEditing ? Icons.update : Icons.add),
                      label: Text(_isEditing ? 'Cập nhật' : 'Thêm mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF0891B2)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Vui lòng nhập $label';
          }
          if (label == 'Giá' || label == 'Đánh giá') {
            if (double.tryParse(value) == null) {
              return 'Vui lòng nhập số hợp lệ';
            }
          }
          return null;
        },
        onChanged: (value) {
          if (label == 'Link ảnh (URL)') {
            setState(() {});
          }
        },
      ),
    );
  }
}
