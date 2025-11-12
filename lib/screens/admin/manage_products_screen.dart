// lib/screens/admin/manage_products_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/product.dart';
import '../../models/product_category.dart';
import '../../services/firestore_service.dart';
import 'admin_ui.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  Product? _editingProduct;
  String? _selectedCategoryId;
  bool _isActive = true;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _existingImageUrl;

      // Upload ảnh nếu người dùng chọn ảnh mới
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      final now = DateTime.now();
      final productData = Product(
        id: _editingProduct?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: imageUrl,
        categoryId: _selectedCategoryId ?? '',
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
        isActive: _isActive,
        rating: _editingProduct?.rating,
        reviewCount: _editingProduct?.reviewCount ?? 0,
        createdAt: _editingProduct?.createdAt ?? now,
        updatedAt: now,
      );

      if (_editingProduct != null) {
        await _firestoreService.updateProduct(productData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật sản phẩm thành công!')),
          );
        }
      } else {
        await _firestoreService.addProduct(productData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm sản phẩm thành công!')),
          );
        }
      }

      _clearForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}';
      final reference = FirebaseStorage.instance.ref().child(
        'products/$fileName',
      );

      await reference.putFile(imageFile);
      final imageUrl = await reference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      throw Exception('Lỗi upload ảnh: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
      _editingProduct = null;
      _selectedCategoryId = null;
      _isActive = true;
    });
  }

  void _editProduct(Product product) {
    setState(() {
      _editingProduct = product;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
      _existingImageUrl = product.imageUrl;
      _selectedImage = null;
      _selectedCategoryId = product.categoryId.isNotEmpty
          ? product.categoryId
          : null;
      _isActive = product.isActive;
    });
  }

  Future<void> _deleteProduct(String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteProduct(productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa sản phẩm thành công!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Quản lý sản phẩm',
      floatingActionButton: FloatingActionButton(
        onPressed: _clearForm,
        backgroundColor: AdminColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Form
            AdminSection(
              title: _editingProduct != null
                  ? 'Chỉnh sửa sản phẩm'
                  : 'Thêm sản phẩm mới',
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: adminInputDecoration(
                        'Tên sản phẩm',
                        hintText: 'Nhập tên sản phẩm',
                        prefixIcon: const Icon(
                          Icons.shopping_bag,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng nhập tên sản phẩm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCategorySelector(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: adminInputDecoration(
                        'Mô tả',
                        hintText: 'Nhập mô tả sản phẩm',
                        prefixIcon: const Icon(
                          Icons.description,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng nhập mô tả';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: adminInputDecoration(
                              'Giá (VNĐ)',
                              hintText: '100000',
                              prefixIcon: const Icon(
                                Icons.attach_money,
                                color: AdminColors.success,
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập giá';
                              }
                              if (double.tryParse(value!) == null) {
                                return 'Giá không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: adminInputDecoration(
                              'Số lượng tồn kho',
                              hintText: '100',
                              prefixIcon: const Icon(
                                Icons.inventory,
                                color: AdminColors.info,
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập số lượng';
                              }
                              if (int.tryParse(value!) == null) {
                                return 'Số lượng không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Hình ảnh sản phẩm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Image preview
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AdminColors.border,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (_existingImageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          _existingImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 48,
                                                    color: AdminColors
                                                        .textSecondary,
                                                  ),
                                                );
                                              },
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 48,
                                          color: AdminColors.textSecondary,
                                        ),
                                      )),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Chọn ảnh từ máy'),
                        ),
                        if (_selectedImage != null) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Bỏ chọn ảnh'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Trạng thái:',
                          style: TextStyle(
                            color: AdminColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() => _isActive = value);
                          },
                          activeColor: AdminColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isActive ? 'Đang bán' : 'Ngừng bán',
                          style: TextStyle(
                            color: _isActive
                                ? AdminColors.success
                                : AdminColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: AdminPrimaryButton(
                            label: _editingProduct != null
                                ? 'Cập nhật'
                                : 'Thêm mới',
                            icon: _editingProduct != null
                                ? Icons.save
                                : Icons.add,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _addOrUpdateProduct,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_editingProduct != null)
                          Expanded(
                            child: AdminDangerButton(
                              label: 'Hủy',
                              icon: Icons.close,
                              onPressed: _clearForm,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // List
            const SizedBox(height: 24),
            AdminSection(
              title: 'Danh sách sản phẩm',
              child: StreamBuilder<List<Product>>(
                stream: _firestoreService.getAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AdminLoadingCard(
                      message: 'Đang tải danh sách sản phẩm...',
                    );
                  }

                  if (snapshot.hasError) {
                    return AdminEmptyState(
                      title: 'Có lỗi xảy ra',
                      subtitle:
                          'Không thể tải danh sách sản phẩm: ${snapshot.error}',
                      icon: Icons.error_outline,
                      action: AdminPrimaryButton(
                        label: 'Thử lại',
                        icon: Icons.refresh,
                        onPressed: () => setState(() {}),
                      ),
                    );
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return AdminEmptyState(
                      title: 'Chưa có sản phẩm nào',
                      subtitle: 'Hãy thêm sản phẩm đầu tiên để bắt đầu',
                      icon: Icons.shopping_bag,
                      action: AdminPrimaryButton(
                        label: 'Thêm sản phẩm',
                        icon: Icons.add,
                        onPressed: _clearForm,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return AdminCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Product Image
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AdminColors.border,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child:
                                      product.imageUrl != null &&
                                          product.imageUrl!.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: AdminColors.surfaceAlt,
                                                  child: const Icon(
                                                    Icons.shopping_bag,
                                                    color: AdminColors
                                                        .textSecondary,
                                                    size: 30,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          color: AdminColors.surfaceAlt,
                                          child: const Icon(
                                            Icons.shopping_bag,
                                            color: AdminColors.textSecondary,
                                            size: 30,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Product Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AdminColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: product.isActive
                                                ? AdminColors.success
                                                      .withOpacity(0.1)
                                                : AdminColors.danger
                                                      .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            product.isActive
                                                ? 'Đang bán'
                                                : 'Ngừng bán',
                                            style: TextStyle(
                                              color: product.isActive
                                                  ? AdminColors.success
                                                  : AdminColors.danger,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.description,
                                      style: const TextStyle(
                                        color: AdminColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.attach_money,
                                          size: 16,
                                          color: AdminColors.success,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${product.price.toStringAsFixed(0)} VNĐ',
                                          style: const TextStyle(
                                            color: AdminColors.textSecondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.inventory,
                                          size: 16,
                                          color: AdminColors.info,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Tồn kho: ${product.stock}',
                                          style: const TextStyle(
                                            color: AdminColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (product.rating != null) ...[
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color: AdminColors.warning,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${product.rating!.toStringAsFixed(1)} (${product.reviewCount})',
                                            style: const TextStyle(
                                              color: AdminColors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Actions
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AdminColors.info.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AdminColors.info,
                                      ),
                                      onPressed: () => _editProduct(product),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AdminColors.danger.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: AdminColors.danger,
                                      ),
                                      onPressed: () =>
                                          _deleteProduct(product.id),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return StreamBuilder<List<ProductCategory>>(
      stream: _firestoreService.getAllProductCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AdminColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.border),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final categories = snapshot.data!;
        if (categories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AdminColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.border),
            ),
            child: const Text(
              'Chưa có danh mục nào. Vui lòng tạo danh mục trước.',
              style: TextStyle(color: AdminColors.textSecondary),
            ),
          );
        }

        final validSelectedId =
            _selectedCategoryId != null &&
                categories.any((cat) => cat.id == _selectedCategoryId)
            ? _selectedCategoryId
            : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AdminColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: validSelectedId != null
                  ? AdminColors.accent
                  : AdminColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text(
                'Chọn danh mục *',
                style: TextStyle(color: AdminColors.textSecondary),
              ),
              value: validSelectedId,
              dropdownColor: AdminColors.surface,
              style: const TextStyle(color: AdminColors.textPrimary),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
