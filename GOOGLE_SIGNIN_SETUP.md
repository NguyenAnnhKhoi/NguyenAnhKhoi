# Hướng dẫn cấu hình Google Sign-In

## Các bước đã thực hiện

### 1. Cấu hình Firebase
- ✅ Đã cấu hình `google-services.json` cho Android
- ✅ Đã cấu hình `GoogleService-Info.plist` cho iOS
- ✅ Đã thêm Google Services plugin vào `build.gradle`

### 2. Cấu hình Dependencies
- ✅ Đã thêm `google_sign_in: ^6.2.1` vào `pubspec.yaml`
- ✅ Đã thêm `firebase_auth: ^5.1.2` vào `pubspec.yaml`
- ✅ Đã thêm `play-services-auth:20.7.0` vào Android dependencies

### 3. Cải thiện Code
- ✅ Tạo `GoogleSignInButton` widget tùy chỉnh
- ✅ Cải thiện xử lý lỗi trong `AuthService`
- ✅ Thêm loading state cho Google Sign-In
- ✅ Tạo `GoogleSignInConfig` để quản lý client IDs

## Cấu hình Client IDs

### Android
- Client ID: `571999879235-g83qcl9amq64o0s4itra1733srf66khe.apps.googleusercontent.com`
- Package Name: `com.doan.doanmonhoc`
- SHA-1: `B4:DA:F9:97:B2:8B:BA:98:C3:F2:8F:62:E7:24:8B:67:CE:EB:B5:EB`
- App ID: `1:571999879235:android:a216d06160162d89d394f6`

### iOS
- Client ID: `571999879235-rs14boa1fqbcu78aosaevbva9m3qn9ke.apps.googleusercontent.com`
- Bundle ID: `com.doan.doanmonhoc`

### Web
- Client ID: `571999879235-mo6utir6lpt2ktf7tfpghfcneebi4f3o.apps.googleusercontent.com`

## Cách sử dụng

### 1. Trong Login Screen
```dart
GoogleSignInButton(
  onPressed: _handleGoogleSignIn,
  isLoading: _isGoogleSigningIn,
)
```

### 2. Trong AuthService
```dart
final userCredential = await _authService.signInWithGoogle();
if (userCredential != null) {
  // Đăng nhập thành công
}
```

## Xử lý lỗi

Các lỗi phổ biến và cách xử lý:

1. **Network Error**: Kiểm tra kết nối internet
2. **Popup Closed**: Người dùng hủy đăng nhập
3. **Sign In Failed**: Lỗi cấu hình hoặc token không hợp lệ
4. **Account Exists**: Email đã được liên kết với provider khác

## Kiểm tra cấu hình

Để kiểm tra xem Google Sign-In có được cấu hình đúng:

```dart
if (GoogleSignInConfig.isConfigured) {
  print('Google Sign-In đã được cấu hình đúng');
} else {
  print('Cần cấu hình Google Sign-In');
}
```

## Lưu ý quan trọng

1. **SHA-1 Certificate**: Đảm bảo SHA-1 của certificate khớp với cấu hình trong Firebase Console
2. **Package Name**: Package name phải khớp với cấu hình trong Firebase
3. **OAuth Consent Screen**: Cần cấu hình OAuth consent screen trong Google Cloud Console
4. **Testing**: Test trên thiết bị thật, không test trên emulator cho Google Sign-In

## Troubleshooting

### Lỗi "Sign in failed"
- Kiểm tra SHA-1 certificate
- Kiểm tra package name
- Kiểm tra OAuth client configuration

### Lỗi "Network error"
- Kiểm tra kết nối internet
- Kiểm tra firewall/proxy settings

### Lỗi "Popup blocked"
- Cho phép popup trong browser settings
- Sử dụng redirect flow thay vì popup flow
