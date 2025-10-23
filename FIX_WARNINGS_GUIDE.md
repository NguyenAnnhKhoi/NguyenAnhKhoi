# 🔧 Hướng Dẫn Fix Warnings - Quick Reference

## 🎯 Priority 1: Critical Fixes

### 1. Fix `use_build_context_synchronously` (14 warnings)

#### Problem
Sử dụng `BuildContext` sau async operations có thể gây crash nếu widget đã bị dispose.

#### Solution Pattern
```dart
// ❌ BEFORE (Có warning)
await someAsyncOperation();
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(snackBar);

// ✅ AFTER (Đã fix)
await someAsyncOperation();
if (!mounted) return;
Navigator.pop(context);
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(snackBar);
```

#### Files Cần Fix
1. **lib/screens/my_bookings_screen.dart** (4 lần)
   - Line 577: `Navigator.pop(context);`
   - Line 578: `ScaffoldMessenger.of(context).showSnackBar(...);`
   - Line 591: `Navigator.pop(context);`
   - Line 592: `ScaffoldMessenger.of(context).showSnackBar(...);`

2. **lib/screens/profile/profile_info_screen.dart** (4 lần)
   - Line 80: `Navigator.pop(context);`
   - Line 82: `ScaffoldMessenger.of(context).showSnackBar(...);`
   - Line 102: `Navigator.pop(context);`
   - Line 105: `ScaffoldMessenger.of(context).showSnackBar(...);`

3. **lib/screens/payment_screen.dart** (2 lần)
   - Line 224: `Navigator.of(context).pop();`
   - Line 225: `Navigator.of(context).pushReplacement(...);`

4. **lib/screens/quick_booking_screen.dart** (1 lần)
   - Line 107: `context` usage

5. **lib/screens/profile/change_password_screen.dart** (1 lần)
   - Line 58: `context` usage

#### Cách Fix Nhanh
Thêm helper method vào base class hoặc extension:

```dart
// lib/utils/context_extensions.dart
extension SafeContext on BuildContext {
  void showSnackBarSafe(SnackBar snackBar) {
    if (mounted) {
      ScaffoldMessenger.of(this).showSnackBar(snackBar);
    }
  }
  
  void popSafe() {
    if (mounted) {
      Navigator.pop(this);
    }
  }
}
```

---

### 2. Remove `print()` Statements (7 warnings)

#### Problem
`print()` không nên dùng trong production code.

#### Solution
```dart
// ❌ BEFORE
print('Debug message: $value');

// ✅ AFTER
debugPrint('Debug message: $value');

// 🌟 BEST PRACTICE
import 'package:logger/logger.dart';
final logger = Logger();
logger.d('Debug message: $value'); // debug
logger.i('Info message'); // info
logger.w('Warning'); // warning
logger.e('Error'); // error
```

#### Files Cần Fix
1. **lib/screens/map_screen.dart**
   - Line 159: `print('Branch selected: $_selectedBranch');`
   - Line 177: `print('Tọa độ: $lat, $long');`

2. **lib/services/firestore_service.dart**
   - Line 73: `print('Error: ...');`

3. **lib/services/auth_service.dart**
   - Line 81: `print('Error: ...');`

4. **lib/services/notification_service.dart**
   - Line 41: `print('FCM Token: ...');`
   - Line 65: `print('Background message: ...');`
   - Line 67: `print('Error: ...');`
   - Line 73: `print('Message: ...');`

#### Cách Fix Nhanh
Find & Replace trong project:
- Find: `print\(`
- Replace: `debugPrint(`

---

### 3. Fix Unused Imports (1 warning)

#### lib/screens/forgot_password_screen.dart
```dart
// ❌ Remove this line (Line 2)
import 'package:firebase_auth/firebase_auth.dart';

// Không sử dụng trong file này
```

---

### 4. Fix Curly Braces (4 warnings) - lib/screens/login_screen.dart

```dart
// ❌ BEFORE
if (value == null || value.isEmpty) return 'Vui lòng nhập email';
if (!value.contains('@')) return 'Email không hợp lệ';

// ✅ AFTER
if (value == null || value.isEmpty) {
  return 'Vui lòng nhập email';
}
if (!value.contains('@')) {
  return 'Email không hợp lệ';
}
```

**Locations:**
- Line 267
- Line 270
- Line 320
- Line 322

---

## 🔄 Priority 2: Deprecated APIs

### 1. Update `withOpacity()` to `withValues()` (93 warnings)

#### Note
⚠️ **Chờ Flutter stable hỗ trợ đầy đủ** - Có thể skip trong production hiện tại.

#### When Ready
```dart
// ❌ OLD
Colors.black.withOpacity(0.5)

// ✅ NEW
Colors.black.withValues(alpha: 0.5)
```

#### Batch Replace Command
```bash
# Tìm tất cả withOpacity trong project
grep -r "withOpacity" lib/ --include="*.dart"

# Có thể viết script Python/Dart để auto-replace sau
```

---

### 2. Fix Other Deprecations

#### lib/screens/profile/notifications_screen.dart (Line 60)
```dart
// ❌ OLD
Switch(
  activeColor: Colors.blue,
  value: _emailNotifications,
  onChanged: (value) => setState(() => _emailNotifications = value),
)

// ✅ NEW
Switch(
  activeThumbColor: Colors.blue,
  value: _emailNotifications,
  onChanged: (value) => setState(() => _emailNotifications = value),
)
```

#### lib/screens/profile/profile_info_screen.dart (Line 179)
```dart
// ❌ OLD
TextFormField(
  value: _nameController.text,
  // ...
)

// ✅ NEW
TextFormField(
  initialValue: _nameController.text,
  // ...
)
```

---

## 📝 Priority 3: Code Style

### 1. Sort Child Properties Last

#### lib/screens/payment_screen.dart (Line 269-272)
```dart
// ❌ BEFORE
Container(
  child: Text('...'),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(...),
)

// ✅ AFTER
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(...),
  child: Text('...'),
)
```

---

### 2. Use Super Parameters

#### lib/screens/payment_screen.dart (Line 8)
```dart
// ❌ BEFORE
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key, required this.booking}) : super(key: key);
  final Map<String, dynamic> booking;
  // ...
}

// ✅ AFTER
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.booking});
  final Map<String, dynamic> booking;
  // ...
}
```

---

### 3. Fix Constant Naming (lib/services/vietqr_generator.dart)

```dart
// ❌ BEFORE
static const String BANK_ID = 'MB';
static const String ACCOUNT_NO = '0123456789';
static const String ACCOUNT_NAME = 'NGUYEN VAN A';

// ✅ AFTER
static const String bankId = 'MB';
static const String accountNo = '0123456789';
static const String accountName = 'NGUYEN VAN A';
```

---

## 🚀 Quick Fix Script

Tạo file `fix_warnings.sh`:

```bash
#!/bin/bash

echo "🔧 Fixing common warnings..."

# 1. Replace print with debugPrint
echo "📝 Replacing print() with debugPrint()..."
find lib -name "*.dart" -type f -exec sed -i '' 's/print(/debugPrint(/g' {} \;

# 2. Remove unused import from forgot_password_screen.dart
echo "🗑️ Removing unused imports..."
sed -i '' "/import 'package:firebase_auth\/firebase_auth.dart';/d" lib/screens/forgot_password_screen.dart

# 3. Run dart format
echo "✨ Formatting code..."
dart format lib/

# 4. Run flutter analyze
echo "🔍 Analyzing code..."
flutter analyze

echo "✅ Done!"
```

Make executable:
```bash
chmod +x fix_warnings.sh
./fix_warnings.sh
```

---

## 📊 Progress Tracker

### Before
- ❌ Errors: 0
- ⚠️ Warnings: 112

### After Quick Fixes (Priority 1)
- ✅ Errors: 0
- ⚠️ Warnings: ~30-40 (giảm 60-70%)

### After Full Fixes (All Priorities)
- ✅ Errors: 0
- ⚠️ Warnings: ~5-10 (chỉ còn style preferences)

---

## 🎯 Recommendation

**Làm ngay:**
1. ✅ Fix `use_build_context_synchronously` (14 warnings) - 30 phút
2. ✅ Replace `print()` với `debugPrint()` (7 warnings) - 10 phút
3. ✅ Remove unused import (1 warning) - 2 phút
4. ✅ Fix curly braces (4 warnings) - 5 phút

**Tổng thời gian: ~45 phút**

**Làm sau:**
- Deprecation warnings khi Flutter stable support
- Code style improvements theo nhu cầu team

---

## 🔗 Resources

- [Flutter Lint Rules](https://dart.dev/tools/linter-rules)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/development/ui/layout/constraints)

---

**👨‍💻 Happy Coding!**
