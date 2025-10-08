// lib/services/auth_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Đăng nhập bằng Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      await _saveUserSession(
        username: user?.displayName ?? 'Google User',
        email: user?.email ?? '',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Lỗi đăng nhập Google: ${e.toString()}';
    }
  }

  /// Đăng nhập bằng Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        
        final userCredential = await _auth.signInWithCredential(credential);
        final userData = await FacebookAuth.instance.getUserData(fields: "name,email");
        await _saveUserSession(
          username: userData['name'] ?? 'Facebook User',
          email: userData['email'] ?? '',
        );
        return userCredential;
      }
      return null; // User cancelled
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Lỗi đăng nhập Facebook: ${e.toString()}';
    }
  }

  /// Đăng nhập bằng Email & Password
  Future<UserCredential> signInWithEmail({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      await _saveUserSession(
        username: user?.displayName ?? email.split('@')[0],
        email: email,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Đăng ký bằng Email & Password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.sendEmailVerification();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Gửi email quên mật khẩu
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
        await FacebookAuth.instance.logOut();
      }
      await _auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('username');
      await prefs.remove('email');
    } catch (e) {
      // Bỏ qua lỗi
    }
  }

  // Hàm private để lưu session
  Future<void> _saveUserSession({required String username, required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
  }

  // Hàm private để xử lý lỗi
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Không có kết nối mạng, vui lòng thử lại.';
      case 'popup-closed-by-user':
        return 'Bạn đã đóng cửa sổ đăng nhập.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hoá.';
      case 'account-exists-with-different-credential':
        return 'Email này đã được liên kết với một nhà cung cấp khác.';
      case 'invalid-credential':
      case 'wrong-password':
        return 'Email hoặc mật khẩu không chính xác.';
      case 'user-not-found':
        return 'Không tìm thấy người dùng với email này.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng bởi một tài khoản khác.';
      default:
        return 'Lỗi xác thực: ${e.message ?? e.code}';
    }
  }
}