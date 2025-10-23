// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Lắng nghe sự thay đổi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Đăng nhập bằng Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Người dùng đã hủy

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Lỗi đăng nhập Google: ${e.toString()}';
    }
  }

  /// Đăng nhập bằng Email & Password
  Future<UserCredential> signInWithEmail({required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      }
      await _auth.signOut();
    } catch (e) {
      // Bỏ qua lỗi nếu có
      debugPrint("Lỗi khi đăng xuất: $e");
    }
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