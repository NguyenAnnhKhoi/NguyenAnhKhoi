# 🚀 Deployment Guide - BeeRom App

## 📋 Pre-Deployment Checklist

### 1. Code Quality
- [x] All features tested and working
- [x] No compilation errors
- [x] No lint warnings
- [x] Code reviewed and optimized
- [x] Documentation complete

### 2. Firebase Setup
- [x] Firebase project configured
- [x] Authentication enabled (Email/Password, Google)
- [x] Firestore database created
- [x] Security rules configured
- [x] Firebase Analytics (optional)

### 3. App Configuration
- [x] App name finalized
- [x] Package name/Bundle ID set
- [x] Version number set
- [x] App icons prepared
- [x] Splash screen configured

## 🤖 Android Deployment

### 1. Prepare Keystore

```bash
# Generate keystore (if not exists)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### 2. Configure Signing

Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
```

### 3. Update `android/app/build.gradle`

```gradle
// Add before android block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 4. Build APK/AAB

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### 5. Google Play Console

1. Create app on [Google Play Console](https://play.google.com/console)
2. Fill in app details:
   - Title: BeeRom
   - Short description
   - Full description
   - Screenshots
   - Feature graphic
   - App icon
3. Set up content rating
4. Set pricing & distribution
5. Upload AAB file
6. Submit for review

### APK Location
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 🍎 iOS Deployment

### 1. Configure Xcode

```bash
# Open iOS project in Xcode
open ios/Runner.xcworkspace
```

### 2. Update Settings

In Xcode:
1. Select `Runner` project
2. Go to `Signing & Capabilities`
3. Select your Team
4. Update Bundle Identifier: `com.yourdomain.beerom`
5. Enable capabilities:
   - Push Notifications (if needed)
   - Sign in with Apple (if using)

### 3. Update Info.plist

```xml
<key>CFBundleDisplayName</key>
<string>BeeRom</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### 4. Build IPA

```bash
# Build iOS release
flutter build ios --release

# Or build with Xcode
# Product → Archive → Distribute App
```

### 5. App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app
3. Fill in app information:
   - Name: BeeRom
   - Subtitle
   - Description
   - Keywords
   - Screenshots (iPhone, iPad)
   - App Preview videos
4. Upload IPA via Xcode or Transporter
5. Submit for review

## 🌐 Web Deployment

### 1. Build Web

```bash
# Build for web
flutter build web --release
```

### 2. Deploy to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting

# Deploy
firebase deploy --only hosting
```

### 3. Deploy to Other Platforms

#### Netlify
```bash
# Build
flutter build web --release

# Deploy build/web folder via Netlify UI
```

#### GitHub Pages
```bash
# Build
flutter build web --release --base-href="/your-repo/"

# Push build/web to gh-pages branch
```

## 📱 Version Management

### Update Version

In `pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ^major.minor.patch+build
```

### Version Naming Convention
- **Major**: Breaking changes
- **Minor**: New features
- **Patch**: Bug fixes
- **Build**: Internal build number

Example progression:
- 1.0.0+1 (Initial release)
- 1.0.1+2 (Bug fix)
- 1.1.0+3 (New feature)
- 2.0.0+4 (Major update)

## 🔧 Build Optimization

### 1. Code Optimization

```bash
# Analyze code
flutter analyze

# Format code
flutter format .
```

### 2. Asset Optimization

- Compress images (TinyPNG, ImageOptim)
- Remove unused assets
- Use vector icons where possible

### 3. Package Optimization

```bash
# Remove unused dependencies
flutter pub deps

# Update packages
flutter pub upgrade
```

### 4. Build Flags

```bash
# Obfuscate code (Android/iOS)
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Target ABI (smaller APKs)
flutter build apk --release --split-per-abi
```

## 📊 Post-Deployment

### 1. Analytics Setup

Add Firebase Analytics or Google Analytics:
```dart
FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// Log events
analytics.logEvent(
  name: 'booking_created',
  parameters: {'service': serviceName},
);
```

### 2. Crash Reporting

Setup Firebase Crashlytics:
```bash
flutter pub add firebase_crashlytics
```

### 3. Performance Monitoring

Enable Firebase Performance:
```bash
flutter pub add firebase_performance
```

### 4. App Updates

Setup in-app updates:
- Android: Google Play In-App Updates
- iOS: App Store auto-updates

## 🔒 Security Checklist

### Before Release
- [ ] Remove debug prints
- [ ] Remove test credentials
- [ ] Secure API keys
- [ ] Enable ProGuard/R8 (Android)
- [ ] Enable code obfuscation
- [ ] Configure Firebase security rules
- [ ] Enable SSL pinning (if needed)
- [ ] Implement root/jailbreak detection (if needed)

### Firebase Security Rules Example

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Bookings
    match /bookings/{bookingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                               resource.data.userId == request.auth.uid;
    }
    
    // Services (public read)
    match /services/{serviceId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

## 📝 App Store Descriptions

### Short Description (80 characters)
```
Đặt lịch cắt tóc nhanh chóng với thanh toán VietQR tiện lợi
```

### Full Description

```
🌟 BEEROM - ỨNG DỤNG ĐẶT LỊCH CẮT TÓC HIỆN ĐẠI

Trải nghiệm đặt lịch cắt tóc nhanh chóng, tiện lợi với BeeRom - ứng dụng đặt lịch salon chuyên nghiệp với thanh toán VietQR.

✨ TÍNH NĂNG NỔI BẬT:

📅 Đặt Lịch Dễ Dàng
• Chọn dịch vụ yêu thích
• Chọn stylist ưa thích
• Chọn chi nhánh gần nhất
• Chọn thời gian phù hợp

💳 Thanh Toán Tiện Lợi
• Thanh toán online qua VietQR
• Thanh toán tại quầy
• Lịch sử giao dịch chi tiết
• Trạng thái thanh toán rõ ràng

👤 Quản Lý Cá Nhân
• Lịch sử đặt chỗ
• Dịch vụ yêu thích
• Thông tin cá nhân
• Thông báo nhắc lịch

🔔 Thông Báo Thông Minh
• Nhắc lịch hẹn tự động
• Cập nhật trạng thái booking
• Thông báo khuyến mãi

🔒 An Toàn & Bảo Mật
• Xác thực email
• Đăng nhập Google
• Bảo mật thông tin cá nhân
• Thanh toán an toàn

TẢI NGAY BEEROM - ĐẶT LỊCH NHANH, THANH TOÁN DỄ!
```

### Keywords (iOS)
```
cắt tóc, salon, đặt lịch, beauty, barber, hair, vietqr, thanh toán, booking
```

## 🎯 Marketing Assets Needed

### Screenshots (Required)
- iPhone 6.5" (1242 x 2688)
- iPhone 5.5" (1242 x 2208)
- iPad Pro 12.9" (2048 x 2732)
- Android Phone (Various sizes)

### Screenshots to Include:
1. Home screen with services
2. Booking screen
3. Payment screen with QR
4. Booking history
5. Profile screen

### Feature Graphic (Google Play)
- Size: 1024 x 500
- Design: App logo + tagline

### App Icon
- iOS: 1024 x 1024 (no transparency)
- Android: 512 x 512 (can have transparency)

## 🚀 Launch Strategy

### Soft Launch (Week 1)
- [ ] Beta testing with select users
- [ ] Gather feedback
- [ ] Fix critical bugs
- [ ] Monitor analytics

### Full Launch (Week 2)
- [ ] Submit to App Store
- [ ] Submit to Play Store
- [ ] Prepare marketing materials
- [ ] Social media announcement

### Post-Launch (Week 3+)
- [ ] Monitor reviews
- [ ] Respond to feedback
- [ ] Plan updates
- [ ] Marketing campaigns

## 📞 Support & Monitoring

### Monitor Daily
- Crash reports
- User reviews
- Analytics data
- Server logs
- Firebase usage

### Weekly Tasks
- Review analytics
- Plan updates
- Respond to reviews
- Fix bugs

### Monthly Tasks
- Feature updates
- Performance optimization
- User surveys
- Marketing review

## 🎉 Congratulations!

Your app is ready for deployment! 🚀

Remember to:
- Test thoroughly on real devices
- Monitor analytics after launch
- Respond to user feedback
- Keep app updated
- Maintain good ratings

Good luck with your launch! 🍀

---

**Need Help?**
- Firebase: https://firebase.google.com/support
- Flutter: https://flutter.dev/community
- Play Console: https://support.google.com/googleplay
- App Store: https://developer.apple.com/support
