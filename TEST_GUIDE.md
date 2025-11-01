# Hướng dẫn Test Sau Khi Fix

## 🧪 Các bước test

### Bước 1: Hot Restart App
```bash
# Trong VS Code, nhấn:
Shift + Command + R (macOS)
# Hoặc
Ctrl + Shift + R (Windows/Linux)

# Hoặc trong terminal app đang chạy, nhấn:
R (uppercase R)
```

### Bước 2: Đăng xuất và đăng nhập lại
1. Mở app
2. Vào **Admin Panel**
3. Nhấn nút **Logout** (icon 🚪)
4. Đăng nhập lại với email: **khoi@gmail.com**

### Bước 3: Thử thêm dịch vụ
1. Vào **Quản lý Dịch vụ**
2. Nhấn **Thêm dịch vụ mới** (+)
3. Chọn loại: **Cắt + Gội** 💇
4. Điền thông tin:
   - Tên: `Test Service`
   - Giá: `50000`
   - Thời lượng: `40 phút`
   - Đánh giá: `4.9`
   - Link ảnh: (URL bất kỳ)
5. Nhấn **Save** (icon 💾)

### Bước 4: Xem Console Log
Trong VS Code Debug Console, bạn sẽ thấy:

```
=== Saving Service ===
Current User: khoi@gmail.com
User UID: cb3oobcS22T9dXOmafKX
✅ User token refreshed
Service data: {name: Test Service, categoryName: Cắt + Gội, ...}
Is editing: false
Service saved successfully!
```

### Bước 5: Kiểm tra kết quả

#### ✅ Nếu thành công:
- Thấy thông báo: **"Thêm dịch vụ mới thành công!"** (màu xanh)
- Quay về màn hình Quản lý Dịch vụ
- Thấy dịch vụ mới trong danh sách

#### ❌ Nếu vẫn lỗi:
- Thấy error message chi tiết với User ID
- Check console log để xem error cụ thể
- Xem phần **Troubleshooting** bên dưới

---

## 🔍 Console Logs Quan Trọng

### Log khi thành công:
```
✅ User token refreshed
=== Saving Service ===
Current User: khoi@gmail.com
User UID: cb3oobcS22T9dXOmafKX
Service data: {...}
Is editing: false
Service saved successfully!
```

### Log khi lỗi permission:
```
✅ User token refreshed
=== Saving Service ===
Current User: khoi@gmail.com
User UID: cb3oobcS22T9dXOmafKX
❌ Error saving service: [cloud_firestore/permission-denied] ...
Error type: FirebaseException
```

---

## 🛠️ Troubleshooting

### Vấn đề 1: Vẫn lỗi permission-denied

**Kiểm tra:**
1. Copy UID từ error message
2. Vào Firebase Console → Firestore → `users/{UID}`
3. Đảm bảo có field: `role: "admin"`
4. Nếu UID khác với `cb3oobcS22T9dXOmafKX`, cần add role cho UID mới

**Giải pháp nhanh:**
```bash
# Deploy lại rules (nếu cần)
cd "/Users/thanquangtuan/Documents/Moblie/Đồ án/NguyenAnhKhoi/nguyenanhkhoi1"
firebase deploy --only firestore:rules
```

### Vấn đề 2: Token không refresh

**Triệu chứng:** Không thấy log "✅ User token refreshed"

**Giải pháp:**
1. Kill app hoàn toàn (force quit)
2. Chạy lại từ đầu: `flutter run`
3. Đăng nhập lại

### Vấn đề 3: Error "Vui lòng chọn loại dịch vụ"

**Nguyên nhân:** Chưa chọn loại từ dropdown

**Giải pháp:** Nhớ chọn loại dịch vụ trước khi Save

---

## 📊 Thay Đổi Đã Thực Hiện

### 1. Service Edit Screen (`service_edit_screen.dart`)
✅ Thêm: Force refresh Firebase Auth token trước khi save
✅ Thêm: Debug log với User email và UID
✅ Thêm: Error message chi tiết với thông tin user
✅ Thêm: Duration tăng lên 8 giây để đọc error

### 2. Firestore Rules (`firestore.rules`)
✅ Thêm: Helper function `isAdmin()`
✅ Cập nhật: Rules vẫn cho phép user đã login write (tạm thời)
✅ Deploy: Rules đã được deploy lên Firebase

### 3. Error Handling
✅ Hiển thị: User email và UID trong error message
✅ Gợi ý: Hướng dẫn cụ thể cách fix
✅ Debug: Log chi tiết error type

---

## 🎯 Expected Behavior

### Trước khi fix:
```
❌ Lỗi: [cloud_firestore/permission-denied] ...
```

### Sau khi fix:
```
✅ User token refreshed
✅ Service saved successfully!
✅ "Thêm dịch vụ mới thành công!"
```

---

## 📞 Nếu vẫn không work

### Option 1: Test với user khác
Thử tạo user mới và add role admin

### Option 2: Simplify rules (test only)
Tạm thời đổi rules thành:
```javascript
match /services/{serviceId} {
  allow read, write: if true; // ⚠️ KHÔNG an toàn, chỉ để test
}
```

Deploy: `firebase deploy --only firestore:rules`

Nếu work → Vấn đề là ở rules
Nếu vẫn lỗi → Vấn đề là ở code/auth

---

## ✅ Success Criteria

Test được coi là thành công khi:
1. ✅ Không có error permission-denied
2. ✅ Thấy thông báo màu xanh "Thành công!"
3. ✅ Dịch vụ mới xuất hiện trong danh sách
4. ✅ Dịch vụ hiển thị đúng trên Home screen
5. ✅ Console log hiển thị "Service saved successfully!"

---

**Last Updated:** Tháng 1, 2025  
**Status:** Ready for Testing ✅
