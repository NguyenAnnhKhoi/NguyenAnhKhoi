# Hướng dẫn Khắc phục Lỗi (Troubleshooting)

## 🔥 Lỗi Permission Denied khi lưu dịch vụ

### Triệu chứng:
```
Lỗi: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

### Nguyên nhân có thể:

#### 1. ⚠️ Chưa đăng nhập hoặc session hết hạn
**Giải pháp:**
- Đăng xuất và đăng nhập lại
- Kiểm tra trong console log có message: "Bạn cần đăng nhập để thực hiện thao tác này!"

#### 2. ⚠️ Tài khoản không có quyền admin
**Kiểm tra:**
```dart
// Trong Firestore database:
users/{userId} {
  role: "admin"  // ← Phải có field này
}
```

**Giải pháp:**
- Vào Firebase Console → Firestore Database
- Tìm collection `users` → document với UID của bạn
- Thêm field `role` với value `admin`

#### 3. ⚠️ Firestore Rules chưa đúng
**Kiểm tra file `firestore.rules`:**
```javascript
match /services/{serviceId} {
  allow read: if true;
  allow write: if request.auth != null;  // ← Cần có dòng này
}
```

**Giải pháp:**
```bash
# Deploy lại Firestore rules
firebase deploy --only firestore:rules
```

#### 4. ⚠️ Chưa chọn loại dịch vụ
**Triệu chứng:** Error message: "Vui lòng chọn loại dịch vụ"

**Giải pháp:**
- Đảm bảo đã chọn loại dịch vụ từ dropdown trước khi lưu
- Dropdown phải có giá trị, không được bỏ trống

---

## 🔍 Cách Debug

### 1. Kiểm tra Console Log
Khi save dịch vụ, sẽ có log:
```
=== Saving Service ===
Service data: {name: ..., categoryName: ..., ...}
Is editing: false
Service saved successfully!
```

### 2. Kiểm tra Authentication Status
```dart
// Thêm vào màn hình admin
print('Current user: ${FirebaseAuth.instance.currentUser?.email}');
print('User UID: ${FirebaseAuth.instance.currentUser?.uid}');
```

### 3. Kiểm tra Firestore Rules (Firebase Console)
1. Mở Firebase Console
2. Vào **Firestore Database** → **Rules**
3. Xem tab **Simulator** để test rules

---

## 📋 Checklist Kiểm tra

Khi gặp lỗi permission-denied, hãy kiểm tra:

- [ ] **User đã đăng nhập?**
  - Kiểm tra: Có thấy email trong admin panel không?
  - Log: `FirebaseAuth.instance.currentUser != null`

- [ ] **User có role admin?**
  - Vào Firestore → `users/{userId}` → kiểm tra field `role`
  - Phải có: `role: "admin"`

- [ ] **Firestore Rules cho phép write?**
  - Check file `firestore.rules`
  - Services collection: `allow write: if request.auth != null;`

- [ ] **Đã chọn loại dịch vụ?**
  - Dropdown "Loại dịch vụ" phải có giá trị
  - Không được để trống

- [ ] **Internet connection ổn định?**
  - Kiểm tra wifi/4G
  - Thử reload app

- [ ] **Firebase project đúng?**
  - Check `firebase_options.dart`
  - Đúng project ID không?

---

## 🛠️ Giải pháp nhanh

### Fix 1: Đăng xuất và đăng nhập lại
```
1. Admin Panel → Nhấn nút Logout (icon 🚪)
2. Đăng nhập lại bằng tài khoản admin
3. Thử lại
```

### Fix 2: Cấp quyền admin trong Firestore
```
1. Firebase Console → Firestore Database
2. Tìm collection "users"
3. Tìm document với UID của bạn (copy từ Authentication)
4. Add field:
   - Field: role
   - Type: string
   - Value: admin
5. Save và thử lại
```

### Fix 3: Deploy lại Firestore Rules
```bash
cd "/Users/thanquangtuan/Documents/Moblie/Đồ án/NguyenAnhKhoi/nguyenanhkhoi1"
firebase deploy --only firestore:rules
```

### Fix 4: Clean và rebuild app
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📞 Lỗi khác

### Lỗi: "Vui lòng chọn loại dịch vụ"
**Nguyên nhân:** Chưa chọn category từ dropdown

**Giải pháp:** Chọn 1 trong 11 loại dịch vụ trước khi save

---

### Lỗi: Network error / Timeout
**Nguyên nhân:** Mất kết nối internet hoặc Firebase slow

**Giải pháp:**
1. Kiểm tra internet
2. Thử lại sau vài giây
3. Restart app

---

### Lỗi: "Invalid data"
**Nguyên nhân:** Dữ liệu nhập vào không hợp lệ

**Giải pháp:**
- Giá phải là số (VD: 50000, không phải "50k")
- Rating phải từ 0-5 (VD: 4.5)
- URL ảnh phải hợp lệ (bắt đầu bằng http:// hoặc https://)

---

## 🔧 Debug Mode

Để xem thêm thông tin debug:

1. Chạy app trong debug mode:
```bash
flutter run --debug
```

2. Xem console log trong VS Code hoặc Terminal

3. Log sẽ hiển thị:
   - Authentication status
   - Service data trước khi save
   - Error details nếu có

---

## 📚 Tài liệu tham khảo

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)

---

**Cập nhật:** Tháng 1, 2025  
**Version:** 2.0
