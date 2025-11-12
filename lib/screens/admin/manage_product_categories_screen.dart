// lib/screens/admin/manage_product_categories_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/product_category.dart';
import '../../services/firestore_service.dart';
import 'admin_ui.dart';

class ManageProductCategoriesScreen extends StatefulWidget {
  const ManageProductCategoriesScreen({super.key});

  @override
  State<ManageProductCategoriesScreen> createState() =>
      _ManageProductCategoriesScreenState();
}

class _ManageProductCategoriesScreenState
    extends State<ManageProductCategoriesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  ProductCategory? _editingCategory;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _existingImageUrl;

      // Upload ảnh nếu người dùng chọn ảnh mới
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      final now = DateTime.now();
      final categoryData = ProductCategory(
        id: _editingCategory?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: imageUrl,
        isActive: _editingCategory?.isActive ?? true,
        createdAt: _editingCategory?.createdAt ?? now,
      );

      if (_editingCategory != null) {
        await _firestoreService.updateProductCategory(categoryData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật danh mục thành công!')),
          );
        }
      } else {
        await _firestoreService.addProductCategory(categoryData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm danh mục thành công!')),
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
        'product_categories/$fileName',
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
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
      _editingCategory = null;
    });
  }

  void _editCategory(ProductCategory category) {
    setState(() {
      _editingCategory = category;
      _nameController.text = category.name;
      _descriptionController.text = category.description ?? '';
      _existingImageUrl = category.imageUrl;
      _selectedImage = null;
    });
  }

  Future<void> _deleteCategory(String categoryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa danh mục này?'),
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
        await _firestoreService.deleteProductCategory(categoryId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa danh mục thành công!')),
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
      title: 'Quản lý danh mục sản phẩm',
      body: Row(
        children: [
          // Form Section
          Expanded(
            flex: 1,
            child: AdminCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _editingCategory != null
                          ? 'Chỉnh sửa danh mục'
                          : 'Thêm danh mục mới',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên danh mục *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên danh mục';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Hình ảnh danh mục',
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
                    const SizedBox(height: 24),
                    AdminPrimaryButton(
                      label: _editingCategory != null ? 'Cập nhật' : 'Thêm mới',
                      icon: _editingCategory != null ? Icons.update : Icons.add,
                      onPressed: _isLoading ? null : _addOrUpdateCategory,
                      isLoading: _isLoading,
                    ),
                    if (_editingCategory != null) ...[
                      const SizedBox(height: 12),
                      AdminDangerButton(
                        label: 'Hủy',
                        icon: Icons.cancel,
                        onPressed: _clearForm,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // List Section
          Expanded(
            flex: 1,
            child: StreamBuilder<List<ProductCategory>>(
              stream: _firestoreService.getAllProductCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AdminCard(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return AdminCard(
                    child: AdminEmptyState(
                      title: 'Lỗi',
                      subtitle: snapshot.error.toString(),
                      icon: Icons.error_outline,
                    ),
                  );
                }

                final categories = snapshot.data ?? [];

                if (categories.isEmpty) {
                  return AdminCard(
                    child: AdminEmptyState(
                      title: 'Chưa có danh mục',
                      subtitle: 'Thêm danh mục mới để bắt đầu',
                      icon: Icons.category_outlined,
                    ),
                  );
                }

                return AdminCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách danh mục',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return AdminCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Category Icon
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: AdminColors.accent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AdminColors.border,
                                          width: 2,
                                        ),
                                      ),
                                      child: category.imageUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                category.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons.category,
                                                        color: Colors.white,
                                                        size: 30,
                                                      );
                                                    },
                                              ),
                                            )
                                          : const Icon(
                                              Icons.category,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Category Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AdminColors.textPrimary,
                                            ),
                                          ),
                                          if (category.description != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              category.description!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color:
                                                    AdminColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Actions
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AdminColors.info.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: AdminColors.info,
                                            ),
                                            onPressed: () =>
                                                _editCategory(category),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AdminColors.danger
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: AdminColors.danger,
                                            ),
                                            onPressed: () =>
                                                _deleteCategory(category.id),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
