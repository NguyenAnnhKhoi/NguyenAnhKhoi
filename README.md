# 💇‍♂️ BeeRom - Salon Booking App

<div align="center">
  <img src="assets/images/logo.png" alt="BeeRom Logo" width="120"/>
  
  <p><strong>Ứng dụng đặt lịch cắt tóc hiện đại với thanh toán VietQR</strong></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

## 📋 Mục Lục

- [Giới Thiệu](#-giới-thiệu)
- [Tính Năng](#-tính-năng)
- [Kiến Trúc](#-kiến-trúc)
- [Cài Đặt](#-cài-đặt)
- [Sử Dụng](#-sử-dụng)
- [Tài Liệu](#-tài-liệu)
- [Đóng Góp](#-đóng-góp)

## 🌟 Giới Thiệu

**BeeRom** là ứng dụng đặt lịch cắt tóc hiện đại, được xây dựng với Flutter và Firebase. Ứng dụng cung cấp trải nghiệm đặt lịch mượt mà, thanh toán online qua VietQR, và quản lý lịch sử giao dịch chi tiết.

### 🎯 Mục Tiêu Dự Án
- ✨ Cung cấp trải nghiệm đặt lịch nhanh chóng và tiện lợi
- 💳 Hỗ trợ thanh toán online an toàn qua VietQR
- 📱 Giao diện đẹp mắt, hiện đại và dễ sử dụng
- 🔔 Thông báo nhắc lịch hẹn tự động
- 📊 Quản lý lịch sử đặt chỗ và giao dịch

## ✨ Tính Năng

### 👤 Dành Cho Khách Hàng

#### 🔐 Xác Thực
- Đăng ký/Đăng nhập bằng Email & Password
- Đăng nhập nhanh với Google Sign-In
- Quên mật khẩu và khôi phục tài khoản
- Xác thực email tự động

#### 📅 Đặt Lịch
- **Đặt lịch thường**: Chọn dịch vụ → Chi nhánh → Stylist → Ngày giờ
- **Đặt lịch nhanh**: Flow ngược lại cho sự tiện lợi
- Chọn phương thức thanh toán (Online/Tại quầy)
- Xem lịch đã đặt với trạng thái realtime

#### 💰 Thanh Toán
- **VietQR Integration**: Thanh toán online qua QR code
- Hiển thị thông tin thanh toán chi tiết
- Tự động cập nhật trạng thái sau thanh toán
- Badge trạng thái thanh toán rõ ràng

#### 📊 Quản Lý
- Xem lịch sử đặt chỗ với filter
- Theo dõi lịch sử giao dịch
- Quản lý dịch vụ yêu thích
- Cập nhật thông tin cá nhân
- Đổi mật khẩu

#### 🔔 Thông Báo
- Nhắc lịch hẹn tự động
- Thông báo trạng thái booking
- Cập nhật khuyến mãi

### 🔧 Dành Cho Admin

- Quản lý dịch vụ (CRUD)
- Quản lý stylist
- Quản lý chi nhánh
- Xem thống kê booking
- Quản lý người dùng

## 🏗️ Kiến Trúc

### Tech Stack

```
Frontend:
├── Flutter 3.0+
├── Dart 3.0+
└── Material Design 3

Backend:
├── Firebase Authentication
├── Cloud Firestore
├── Firebase Storage
└── Cloud Functions (Optional)

Payment:
└── VietQR API

State Management:
└── StatefulWidget + StreamBuilder

Notifications:
└── Flutter Local Notifications
```

### Project Structure

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── booking.dart
│   ├── service.dart
│   ├── stylist.dart
│   └── branch.dart
├── screens/                  # UI Screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home_screen.dart
│   ├── booking_screen.dart
│   ├── payment_screen.dart
│   └── profile/
├── services/                 # Business Logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
├── widgets/                  # Reusable Widgets
└── theme/                    # Theme Config
```

## 🚀 Cài Đặt

### Yêu Cầu

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase CLI
- Android Studio / VS Code
- Git

### Các Bước Cài Đặt

1. **Clone Repository**
```bash
git clone https://github.com/yourusername/beerom.git
cd beerom
```

2. **Cài Đặt Dependencies**
```bash
flutter pub get
```

3. **Cấu Hình Firebase**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
flutterfire configure
```

4. **Chạy Ứng Dụng**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

### Cấu Hình Firebase

1. Tạo project trên [Firebase Console](https://console.firebase.google.com)
2. Enable các service:
   - Authentication (Email/Password & Google)
   - Cloud Firestore
   - Firebase Storage (nếu cần)
3. Tải `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
4. Đặt vào thư mục tương ứng

## 💻 Sử Dụng

### Chạy Ứng Dụng

```bash
# Development
flutter run

# Specific device
flutter run -d chrome
flutter run -d android
flutter run -d ios

# Build
flutter build apk --release
flutter build ios --release
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Coverage
flutter test --coverage
```

### Code Analysis

```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Check for outdated packages
flutter pub outdated
```

## 📚 Tài Liệu

Xem thêm tài liệu chi tiết:

- [📋 Code Optimization Summary](CODE_OPTIMIZATION_SUMMARY.md)
- [🏗️ Architecture Guide](ARCHITECTURE_GUIDE.md)
- [🎨 Design Guide](DESIGN_GUIDE.md)

### API Documentation

#### AuthService
```dart
// Đăng ký
await AuthService().signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
  username: 'John Doe',
);

// Đăng nhập
await AuthService().signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Đăng xuất
await AuthService().signOut();
```

#### FirestoreService
```dart
// Thêm booking
await FirestoreService().addBooking(booking);

// Lấy bookings
Stream<List<Booking>> bookings = FirestoreService()
    .getUserBookings(userId);
```

## 🤝 Đóng Góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng làm theo các bước:

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

### Coding Standards

- Follow [Flutter Style Guide](https://docs.flutter.dev/development/tools/formatting)
- Xem [ARCHITECTURE_GUIDE.md](ARCHITECTURE_GUIDE.md) để biết best practices
- Viết tests cho code mới
- Comment code khi cần thiết
- Cập nhật documentation

## 📝 Changelog

### Version 1.0.0 (Current)
- ✅ Đăng ký/Đăng nhập với Email & Google
- ✅ Đặt lịch với 2 flow (thường & nhanh)
- ✅ Thanh toán VietQR
- ✅ Lịch sử booking & giao dịch
- ✅ Quản lý profile
- ✅ Thông báo lịch hẹn
- ✅ Admin panel

### Upcoming Features
- [ ] Chat với stylist
- [ ] Rating & Review
- [ ] Loyalty points
- [ ] Voucher system
- [ ] Dark mode
- [ ] Multi-language

## 🐛 Bug Reports

Nếu bạn tìm thấy bug, vui lòng tạo issue với:
- Mô tả chi tiết bug
- Các bước để reproduce
- Screenshots (nếu có)
- Device & OS version
- App version

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: Nguyen Anh Khoi
- **Supervisor**: [Supervisor Name]
- **Institution**: [School/University Name]

## 📞 Contact

- **Email**: contact@beerom.com
- **Website**: https://beerom.com
- **GitHub**: https://github.com/yourusername/beerom

## 🙏 Acknowledgments

- Flutter Team
- Firebase Team
- VietQR Payment Gateway
- Open Source Community

---

<div align="center">
  <p>Made with ❤️ by Team lor</p>
  <p>© 2024 Hehe. All rights reserved.</p>
</div>
