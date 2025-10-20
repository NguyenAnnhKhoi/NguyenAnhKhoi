// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isGoogleSigningIn = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleSigningIn) return;
    
    setState(() {
      _isGoogleSigningIn = true;
    });
    
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && mounted) {
        EasyLoading.showSuccess('Đăng nhập thành công!');
        await Future.delayed(const Duration(milliseconds: 500));
        // Điều hướng qua AuthWrapper để phân quyền admin/user
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
      // Nếu userCredential == null, người dùng đã hủy đăng nhập
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('network')) {
          errorMessage = 'Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.';
        } else if (errorMessage.contains('popup-closed-by-user')) {
          errorMessage = 'Bạn đã hủy đăng nhập.';
        } else if (errorMessage.contains('sign_in_failed')) {
          errorMessage = 'Đăng nhập Google thất bại. Vui lòng thử lại.';
        }
        EasyLoading.showError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSigningIn = false;
        });
      }
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    await EasyLoading.show(
      status: 'Đang đăng nhập...',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: false,
    );
    try {
      await _authService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) {
        // Điều hướng qua AuthWrapper để phân quyền admin/user
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        EasyLoading.showError(e.toString());
      }
    } finally {
      await EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0891B2),
              Color(0xFF06B6D4),
              Color(0xFF22D3EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container với hiệu ứng đẹp
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/gg.png', // Logo của bạn
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.content_cut_rounded,
                              size: 100,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Title
                      Text(
                        'GENTLEMEN\'S',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      Text(
                        'GROOMING',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chào mừng trở lại',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Card Form
                      Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'your@email.com',
                                    labelStyle: TextStyle(color: Color(0xFF6B7280)),
                                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0891B2)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFF0891B2), width: 2),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  ),
                                  validator: (v) {
                                    final value = v?.trim() ?? '';
                                    if (value.isEmpty) return 'Vui lòng nhập email';
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) 
                                      return 'Email không hợp lệ';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                // Password Field
                                TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu',
                                    hintText: '••••••••',
                                    labelStyle: TextStyle(color: Color(0xFF6B7280)),
                                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: Color(0xFF6B7280),
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFF0891B2), width: 2),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                                    if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                
                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                                    child: const Text(
                                      'Quên mật khẩu?',
                                      style: TextStyle(
                                        color: Color(0xFF0891B2),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Login Button
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _handleEmailSignIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0891B2),
                                      foregroundColor: Colors.white,
                                      elevation: 6,
                                      shadowColor: const Color(0xFF0891B2).withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      'Đăng nhập',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Divider
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Color(0xFFD1D5DB))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'HOẶC',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Color(0xFFD1D5DB))),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Google Sign In
                                GoogleSignInButton(
                                  onPressed: _handleGoogleSignIn,
                                  isLoading: _isGoogleSigningIn,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Chưa có tài khoản? ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/register'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text(
                              'Đăng ký ngay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}