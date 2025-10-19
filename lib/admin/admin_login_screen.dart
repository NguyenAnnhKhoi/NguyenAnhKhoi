import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  final String? errorMessage;
  const AdminLoginScreen({super.key, this.errorMessage});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.errorMessage != null) {
      // Hiển thị lỗi nếu bị từ chối quyền
      WidgetsBinding.instance.addPostFrameCallback((_) {
        EasyLoading.showError(widget.errorMessage!, duration: Duration(seconds: 3));
      });
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    await EasyLoading.show(status: 'Đang đăng nhập...');
    try {
      await _authService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      // Không cần điều hướng, StreamBuilder trong AdminApp sẽ tự xử lý
      await EasyLoading.dismiss();
    } catch (e) {
      await EasyLoading.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E7490),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'ADMIN PANEL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Vui lòng nhập email' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                           validator: (v) =>
                              (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _handleEmailSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0E7490),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}