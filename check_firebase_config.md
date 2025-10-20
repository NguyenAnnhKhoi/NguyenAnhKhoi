# Kiểm tra cấu hình Firebase Console

## 🔍 **Các bước kiểm tra cần thiết:**

### 1. **Firebase Console - Authentication**
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project `doanmobile-6c221`
3. Vào **Authentication** > **Sign-in method**
4. **Kiểm tra:**
   - ✅ Google provider được **BẬT**
   - ✅ Web client ID: `571999879235-mo6utir6lpt2ktf7tfpghfcneebi4f3o.apps.googleusercontent.com`

### 2. **Firebase Console - Project Settings**
1. Vào **Project Settings** (⚙️)
2. Vào tab **General**
3. Trong phần **Your apps**:
   - ✅ Android app: `com.doan.doanmonhoc`
   - ✅ SHA-1: `B4:DA:F9:97:B2:8B:BA:98:C3:F2:8F:62:E7:24:8B:67:CE:EB:B5:EB`

### 3. **Google Cloud Console - OAuth Clients**
1. Vào [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project `doanmobile-6c221`
3. Vào **APIs & Services** > **Credentials**
4. **Kiểm tra có OAuth 2.0 Client ID:**
   - ✅ Android: `com.doan.doanmonhoc`
   - ✅ Web: `571999879235-mo6utir6lpt2ktf7tfpghfcneebi4f3o.apps.googleusercontent.com`

### 4. **Google Cloud Console - OAuth Consent Screen**
1. Vào **APIs & Services** > **OAuth consent screen**
2. **Kiểm tra:**
   - ✅ App name: `Gentlemen's Grooming`
   - ✅ User support email: đã điền
   - ✅ Developer contact: đã điền

## 🚨 **Nếu thiếu cấu hình:**

### Tạo OAuth Client ID mới:
1. Vào **APIs & Services** > **Credentials**
2. Nhấn **+ CREATE CREDENTIALS** > **OAuth 2.0 Client ID**
3. Chọn **Android**
4. Điền:
   - **Package name**: `com.doan.doanmonhoc`
   - **SHA-1**: `B4:DA:F9:97:B2:8B:BA:98:C3:F2:8F:62:E7:24:8B:67:CE:EB:B5:EB`

### Bật Google Sign-In:
1. Vào Firebase Console > **Authentication** > **Sign-in method**
2. Nhấn **Google**
3. Bật **Enable**
4. Thêm **Web SDK configuration**:
   - **Web client ID**: `571999879235-mo6utir6lpt2ktf7tfpghfcneebi4f3o.apps.googleusercontent.com`

## ✅ **Sau khi cấu hình xong:**
1. Chạy `flutter clean && flutter pub get`
2. Chạy `flutter run --debug`
3. Kiểm tra console log
4. Test đăng nhập Google

## 📱 **Test trên thiết bị thật:**
- Google Sign-In hoạt động tốt nhất trên thiết bị thật
- Emulator có thể gặp vấn đề với Google Play Services

