# Hướng dẫn sửa Google Sign-In cho Android

## 🎯 **Tập trung vào Android**

### **Thông tin cấu hình Android:**
- **Package Name**: `com.doan.doanmonhoc`
- **App ID**: `1:571999879235:android:a216d06160162d89d394f6`
- **SHA-1**: `B4:DA:F9:97:B2:8B:BA:98:C3:F2:8F:62:E7:24:8B:67:CE:EB:B5:EB`
- **Project ID**: `doanmobile-6c221`

## 🔧 **Các bước sửa lỗi:**

### **Bước 1: Cấu hình Firebase Console**

#### 1.1. Vào Firebase Console
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project `doanmobile-6c221`

#### 1.2. Bật Google Sign-In
1. Vào **Authentication** > **Sign-in method**
2. Tìm **Google** và nhấn **Enable**
3. Thêm **Web SDK configuration**:
   - **Web client ID**: `571999879235-mo6utir6lpt2ktf7tfpghfcneebi4f3o.apps.googleusercontent.com`
4. **Save**

#### 1.3. Kiểm tra SHA-1 fingerprints
1. Vào **Project Settings** (⚙️)
2. Tab **General**
3. Tìm Android app `doan`
4. Kiểm tra **SHA certificate fingerprints**:
   - ✅ `B4:DA:F9:97:B2:8B:BA:98:C3:F2:8F:62:E7:24:8B:67:CE:EB:B5:EB`

### **Bước 2: Cấu hình Google Cloud Console**

#### 2.1. Vào Google Cloud Console
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project `doanmobile-6c221`

#### 2.2. Tạo OAuth 2.0 Client ID
1. Vào **APIs & Services** > **Credentials**
2. Nhấn **+ CREATE CREDENTIALS** > **OAuth 2.0 Client ID**
3. Chọn **Android**
4. Điền thông tin:
   - **Package name**: `com.doan.doanmonhoc`
   - **SHA-1**: `B4:DA:F9:97:B2:8B:BA:98:C3:F2:8F:62:E7:24:8B:67:CE:EB:B5:EB`
5. **Create**

#### 2.3. Cấu hình OAuth Consent Screen
1. Vào **APIs & Services** > **OAuth consent screen**
2. Điền thông tin:
   - **App name**: `Gentlemen's Grooming`
   - **User support email**: `lionjoki08@gmail.com`
   - **Developer contact**: `lionjoki08@gmail.com`
3. **Save and Continue**

### **Bước 3: Test cấu hình**

#### 3.1. Chạy app
```bash
flutter clean
flutter pub get
flutter run --debug
```

#### 3.2. Kiểm tra console log
Bạn sẽ thấy:
```
=== GOOGLE SIGN-IN VALIDATION ===
Status: ✅ VALID
=== ANDROID FIREBASE CONFIG CHECK ===
Platform: Android
Package Name: com.doan.doanmonhoc
App ID: 1:571999879235:android:a216d06160162d89d394f6
SHA-1: B4:DA:F9:97:B2:8B:BA:98:C3:F2:8F:62:E7:24:8B:67:CE:EB:B5:EB
Project ID: doanmobile-6c221
```

#### 3.3. Test đăng nhập Google
1. Nhấn nút "Đăng nhập với Google"
2. Chọn tài khoản Google
3. Kiểm tra xem có đăng nhập thành công không

## 🚨 **Các lỗi thường gặp:**

### **Lỗi: "Sign in failed"**
- **Nguyên nhân**: SHA-1 không khớp
- **Giải pháp**: Kiểm tra SHA-1 trong Firebase Console

### **Lỗi: "Client ID not found"**
- **Nguyên nhân**: OAuth client chưa được tạo
- **Giải pháp**: Tạo OAuth client trong Google Cloud Console

### **Lỗi: "Package name mismatch"**
- **Nguyên nhân**: Package name không khớp
- **Giải pháp**: Kiểm tra package name trong Firebase Console

## ✅ **Kết quả mong đợi:**

Sau khi cấu hình đúng:
- ✅ Không có warning về clientId
- ✅ Google Sign-In popup hiển thị
- ✅ Đăng nhập thành công
- ✅ User được tạo trong Firebase Authentication

## 📱 **Lưu ý quan trọng:**

1. **Test trên thiết bị thật** - Google Sign-In hoạt động tốt nhất trên thiết bị thật
2. **Emulator có thể gặp vấn đề** - Nếu test trên emulator, đảm bảo có Google Play Services
3. **Kiểm tra kết nối mạng** - Cần có internet để đăng nhập Google

## 🎯 **Tóm tắt:**

Chỉ cần tập trung vào:
1. ✅ **Firebase Console** - Bật Google Sign-In
2. ✅ **Google Cloud Console** - Tạo OAuth client
3. ✅ **Test** - Chạy app và test đăng nhập

Bỏ qua iOS, chỉ tập trung vào Android! 🚀

