import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'change_password_screen.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String? _gender;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _user = _auth.currentUser;
    if (_user != null) {
      // Lấy dữ liệu từ Firestore, nếu chưa có sẽ trả về null
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      final data = doc.data();

      // Điền dữ liệu vào các controller, ưu tiên dữ liệu từ Firestore
      _nameController.text = data?['displayName'] ?? _user!.displayName ?? '';
      _phoneController.text = data?['phoneNumber'] ?? _user!.phoneNumber ?? '';
      _dobController.text = data?['dateOfBirth'] ?? '';
      _gender = data?['gender'];
      _photoUrl = data?['photoURL'] ?? _user!.photoURL;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return; // Chỉ cho phép chọn ảnh khi đang ở chế độ chỉnh sửa
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    setState(() => _isLoading = true);
    
    try {
      final ref = _storage.ref().child('profile_pictures').child('${_user!.uid}.jpg');
      await ref.putFile(file);
      final newPhotoUrl = await ref.getDownloadURL();
      
      await _firestore.collection('users').doc(_user!.uid).set({'photoURL': newPhotoUrl}, SetOptions(merge: true));
      await _user!.updatePhotoURL(newPhotoUrl);

      setState(() => _photoUrl = newPhotoUrl);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải ảnh: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(_user!.uid).set({
        'displayName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'dateOfBirth': _dobController.text.trim(),
        'gender': _gender,
      }, SetOptions(merge: true));

      if (_user!.displayName != _nameController.text.trim()) {
        await _user!.updateDisplayName(_nameController.text.trim());
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thông tin thành công!')));
      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa thông tin' : 'Thông tin cá nhân'),
        backgroundColor: primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              children: [
                // --- AVATAR SECTION ---
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                        child: _photoUrl == null ? Icon(Icons.person, size: 60, color: Colors.grey.shade400) : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2)
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _nameController.text.isEmpty ? (_user?.displayName ?? 'Chưa có tên') : _nameController.text,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_user?.metadata.creationTime != null)
                Center(
                  child: Text(
                    'Thành viên từ ${_user!.metadata.creationTime!.month}/${_user!.metadata.creationTime!.year}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 32),
                
                // --- INFO FORM ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildTextField(label: 'Họ và tên', controller: _nameController),
                      _buildTextField(label: 'Số điện thoại', controller: _phoneController, keyboardType: TextInputType.phone),
                      TextFormField(
                        readOnly: true,
                        initialValue: _user?.email ?? 'Không có email',
                        style: TextStyle(color: _isEditing ? Colors.black : Colors.grey[600]),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: const OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Ngày sinh', 
                        controller: _dobController,
                        readOnly: true,
                        onTap: () async {
                          if (!_isEditing) return;
                          DateTime? picked = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1950), lastDate: DateTime.now());
                          if (picked != null) {
                            _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        onChanged: _isEditing ? (value) => setState(() => _gender = value) : null,
                        decoration: const InputDecoration(labelText: 'Giới tính', border: OutlineInputBorder()),
                        items: ['Nam', 'Nữ', 'Khác'].map((label) => DropdownMenuItem(child: Text(label), value: label)).toList(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isEditing ? _saveChanges : () => setState(() => _isEditing = true),
                          child: Text(_isEditing ? 'Lưu thay đổi' : 'Chỉnh sửa thông tin'),
                        ),
                      ),
                    ],
                  )
                ),
                
                const SizedBox(height: 40),

                // --- ACCOUNT SECURITY SECTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text('Bảo mật tài khoản', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 16),
                       Card(
                         child: ListTile(
                           title: const Text('Đổi mật khẩu'),
                           leading: const Icon(Icons.lock_outline),
                           trailing: const Icon(Icons.arrow_forward_ios),
                           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())), 
                         ),
                       )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, TextInputType? keyboardType, VoidCallback? onTap, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(color: _isEditing ? Colors.black : Colors.grey[600]),
        decoration: InputDecoration(
          labelText: label,
          filled: !_isEditing,
          fillColor: Colors.grey[200],
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}