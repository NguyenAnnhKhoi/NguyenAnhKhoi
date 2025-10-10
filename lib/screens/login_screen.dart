// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();

  bool _isLoadingGoogle = false;
  bool _isLoadingEmail = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // --- HÀM MỚI CHO ĐĂNG NHẬP GOOGLE ---
  Future<void> _handleGoogleSignIn() async {
    if (_isLoadingGoogle) return;
    setState(() => _isLoadingGoogle = true);

    try {
      final userCredential = await _authService.signInWithGoogle();
      // CHỈ ĐIỀU HƯỚNG NẾU ĐĂNG NHẬP THÀNH CÔNG (KHÔNG BỊ HUỶ)
      if (userCredential != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      // Nếu userCredential là null (người dùng huỷ), không làm gì cả, ở lại màn hình login.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  // --- HÀM MỚI CHO ĐĂNG NHẬP EMAIL ---
  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoadingEmail = true);

    try {
      await _authService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoadingEmail = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    const spacing = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const FlutterLogo(size: 72),
                spacing,
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Vui lòng nhập email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      spacing,
                      TextFormField(
                        controller: _passCtrl,
                        decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                          if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                          return null;
                        },
                      ),
                      spacing,
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _isLoadingEmail ? null : _handleEmailSignIn,
                          child: _isLoadingEmail
                              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                              : const Text('Đăng nhập'),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    // Gọi hàm mới
                    onPressed: _isLoadingGoogle ? null : _handleGoogleSignIn,
                    icon: _isLoadingGoogle 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(Icons.g_mobiledata),
                    label: const Text('Đăng nhập với Google'),
                  ),
                ),
                spacing,
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản?'),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/register'),
                      child: const Text('Đăng ký ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}