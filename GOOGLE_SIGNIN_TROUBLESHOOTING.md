# Hướng dẫn khắc phục lỗi Google Sign-In

## 🚨 **Lỗi hiện tại:**
- Google Sign-In thất bại trên Android
- Warning: `clientId is not supported on Android and is interpreted as serverClientId`

## 🔧 **Các bước khắc phục:**

### 1. **Cập nhật Firebase Console**

#### Bước 1: Vào Firebase Console
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project `doanmobile-6c221`

#### Bước 2: Cấu hình Authentication
1. Vào **Authentication** > **Sign-in method**
2. Bật **Google** provider
3. Thêm **Web SDK configuration**:
   - Web client ID: `571999879235-mo6utir6lpt2ktf7tfpghfcneebi4f3o.apps.googleusercontent.com`

#### Bước 3: Cấu hình OAuth consent screen
1. Vào [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project `doanmobile-6c221`
3. Vào **APIs & Services** > **OAuth consent screen**
4. Cấu hình:
   - App name: `Gentlemen's Grooming`
   - User support email: email của bạn
   - Developer contact: email của bạn

#### Bước 4: Thêm OAuth 2.0 Client IDs
1. Vào **APIs & Services** > **Credentials**
2. Tạo **OAuth 2.0 Client ID** mới:
   - Application type: **Android**
   - Package name: `com.doan.doanmonhoc`
   - SHA-1: `B4:DA:F9:97:B2:8B:BA:98:C3:F2:8F:62:E7:24:8B:67:CE:EB:B5:EB`

### 2. **Kiểm tra cấu hình hiện tại**

#### Thông tin cần thiết:
- **Package Name**: `com.doan.doanmonhoc`
- **SHA-1 (Debug)**: `B4:DA:F9:97:B2:8B:BA:98:C3:F2:8F:62:E7:24:8B:67:CE:EB:B5:EB`
- **SHA-1 (Release)**: Cần lấy từ release keystore
- **Web Client ID**: `571999879235-mo6utir6lpt2ktf7tfpghfcneebi4f3o.apps.googleusercontent.com`

### 3. **Lấy SHA-1 Release (nếu cần)**

```bash
# Lấy SHA-1 từ release keystore
keytool -list -v -keystore path/to/release-keystore.jks -alias your-key-alias
```

### 4. **Test cấu hình**

#### Chạy app và kiểm tra console:
```bash
flutter run --debug
```

#### Kiểm tra log:
- ✅ `Status: ✅ VALID` - Cấu hình OK
- ❌ `Status: ❌ INVALID` - Cần sửa cấu hình

### 5. **Các lỗi thường gặp**

#### Lỗi: "Sign in failed"
- **Nguyên nhân**: SHA-1 không khớp
- **Giải pháp**: Thêm SHA-1 đúng vào Firebase Console

#### Lỗi: "Client ID not found"
- **Nguyên nhân**: OAuth client chưa được tạo
- **Giải pháp**: Tạo OAuth client trong Google Cloud Console

#### Lỗi: "Package name mismatch"
- **Nguyên nhân**: Package name không khớp
- **Giải pháp**: Cập nhật package name trong Firebase Console

### 6. **Kiểm tra cuối cùng**

#### Trong Firebase Console:
1. **Authentication** > **Users** - Xem có user nào được tạo không
2. **Authentication** > **Sign-in method** - Đảm bảo Google được bật
3. **Project Settings** > **General** - Kiểm tra SHA-1 fingerprints

#### Trong Google Cloud Console:
1. **APIs & Services** > **Credentials** - Kiểm tra OAuth clients
2. **APIs & Services** > **OAuth consent screen** - Kiểm tra cấu hình

## 🎯 **Kết quả mong đợi:**

Sau khi cấu hình đúng:
- ✅ Không có warning về clientId
- ✅ Google Sign-In popup hiển thị
- ✅ Đăng nhập thành công
- ✅ User được tạo trong Firebase Authentication

## 📞 **Hỗ trợ:**

Nếu vẫn gặp lỗi, hãy:
1. Chạy `flutter clean && flutter pub get`
2. Xóa app khỏi thiết bị
3. Rebuild và cài đặt lại
4. Kiểm tra log console để xem lỗi cụ thể

