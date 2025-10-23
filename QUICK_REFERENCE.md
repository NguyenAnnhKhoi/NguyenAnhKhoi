# 📋 Quick Reference - Nguyễn Anh Khôi Salon App

## 🚀 Quick Start

```bash
# Clone & Setup
git clone <repo-url>
cd nguyenanhkhoi1
flutter pub get

# Run App
flutter run

# Build
flutter build apk          # Android
flutter build ios          # iOS
```

---

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase config
├── screens/                  # All UI screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── booking_screen.dart
│   ├── payment_screen.dart
│   ├── my_bookings_screen.dart
│   ├── account_screen.dart
│   └── profile/              # Profile screens
├── admin/                    # Admin panel
│   ├── admin_app.dart
│   ├── admin_home_screen.dart
│   ├── stylist_edit_screen.dart
│   ├── service_edit_screen.dart
│   └── branch_edit_screen.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── vietqr_generator.dart
├── models/                   # Data models
├── widgets/                  # Reusable widgets
└── theme/                    # Theme & styling
```

---

## 🎨 Design System

### Colors
```dart
Primary:    Color(0xFF00BCD4)  // Cyan
Accent:     Color(0xFF009688)  // Teal
Error:      Colors.red
Success:    Colors.green
Warning:    Colors.orange
```

### Spacing
```dart
Small:      8.0
Medium:     16.0
Large:      24.0
XLarge:     32.0
```

### Border Radius
```dart
Cards:      16.0
Buttons:    12.0
Input:      12.0
```

---

## 🔐 Firebase Collections

```
users/
  {userId}/
    - name
    - email
    - phone
    - avatar
    - favorites[]
    - createdAt

bookings/
  {bookingId}/
    - userId
    - serviceId
    - stylistId
    - branchId
    - date
    - time
    - paymentMethod
    - paymentStatus
    - status
    - createdAt

services/
  {serviceId}/
    - name
    - price
    - duration
    - imageUrl
    - category
    - isActive

stylists/
  {stylistId}/
    - name
    - phone
    - imageUrl
    - rating
    - experience
    - specialty
    - isActive

branches/
  {branchId}/
    - name
    - address
    - phone
    - imageUrl
    - latitude
    - longitude
    - workingHours
    - isActive
```

---

## 📱 Key Features

### User App
- ✅ Email/Google Sign-In
- ✅ Regular & Quick Booking
- ✅ VietQR Payment
- ✅ Booking History
- ✅ Profile Management

### Admin Panel
- ✅ Manage Services
- ✅ Manage Stylists
- ✅ Manage Branches
- ✅ View Bookings

---

## 🐛 Common Issues & Fixes

### Issue: Build Failed
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Firebase Not Connected
```bash
# Re-download google-services.json (Android)
# Re-download GoogleService-Info.plist (iOS)
# Place in correct directories
```

### Issue: Hot Reload Not Working
```bash
# Stop and restart
flutter run
```

---

## ⚠️ Known Warnings

**Total: 112 non-critical warnings**

### Priority Fixes (Optional)
1. `use_build_context_synchronously` (14) - Add mounted checks
2. `print()` usage (7) - Replace with debugPrint
3. Unused imports (1) - Remove from forgot_password_screen.dart
4. Missing curly braces (4) - Add to if statements

**See:** [FIX_WARNINGS_GUIDE.md](./FIX_WARNINGS_GUIDE.md)

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| **README.md** | Project overview |
| **FINAL_SUMMARY.md** | Complete summary |
| **CODE_QUALITY_REPORT.md** | Quality analysis |
| **FIX_WARNINGS_GUIDE.md** | Fix instructions |
| **ARCHITECTURE_GUIDE.md** | Architecture details |
| **DEPLOYMENT_GUIDE.md** | Deployment steps |
| **PROJECT_CHECKLIST.md** | Feature checklist |

---

## 🔧 Useful Commands

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Check outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade

# Generate icon
flutter pub run flutter_launcher_icons:main

# Build release
flutter build apk --release
flutter build ios --release

# Run tests
flutter test

# Clean build
flutter clean
```

---

## 🎯 Quick Navigation

### User Flow
```
Login → Home → Booking → Payment → History
           ↓
        Account → Profile Screens
```

### Admin Flow
```
Admin Login → Dashboard → Manage Services/Stylists/Branches
```

---

## 📊 Status

```
✅ Errors:          0
⚠️  Warnings:       112 (non-critical)
✅ Features:        100% complete
✅ Documentation:   100% complete
✅ Production:      READY
```

---

## 🚀 Deployment Steps

1. **Test Locally**
   ```bash
   flutter run
   ```

2. **Build Release**
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

3. **Test Release Build**
   - Install APK on Android device
   - Test all features

4. **Deploy**
   - Upload to Google Play Console
   - Upload to App Store Connect

**Full guide:** [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)

---

## 💡 Quick Tips

### For Development
- Use hot reload (`r`) for fast iteration
- Use hot restart (`R`) for state reset
- Check console for errors
- Use Flutter DevTools for debugging

### For Production
- Test on real devices
- Test different screen sizes
- Test network edge cases
- Monitor Firebase usage
- Set up crash analytics

### Code Quality
- Run `flutter analyze` before commits
- Format code with `dart format`
- Follow naming conventions
- Add comments for complex logic
- Keep functions small and focused

---

## 🆘 Help & Resources

### Official Docs
- Flutter: https://flutter.dev
- Firebase: https://firebase.google.com
- Dart: https://dart.dev

### Community
- Flutter Community: https://flutter.dev/community
- Stack Overflow: [flutter] tag
- GitHub Issues: Check project repo

---

## 📞 Contact

**Project:** Nguyễn Anh Khôi Salon Booking App  
**Status:** Production Ready  
**Version:** 1.0.0  
**Last Updated:** 2024

---

**Keep this card handy for quick reference!** 📌
