# ✅ SETUP ADMIN APP - 3 BƯỚC ĐƠN GIẢN

## 📋 Bạn Đã Có
- ✅ Tài khoản admin app (email + password)
- ✅ Rules đã fix (chỉ admin app write)

## 🚀 Cần Làm Ngay

### Bước 1️⃣: Lấy UID Của Tài Khoản Admin

1. **Vào Firebase Console**: https://console.firebase.google.com
2. Chọn project **DoAnMobile**
3. Menu trái → **Authentication**
4. Tìm **email của tài khoản admin app**
5. **Click vào email** → bên phải sẽ hiển thị **User UID**
6. **Copy UID** (ví dụ: `A0kF9jZ2xL5mN8qP`)

```
⚠️  Lưu lại UID này - dùng ở bước tiếp theo
```

---

### Bước 2️⃣: Tạo Document `users` Với `isAdmin: true`

1. **Firestore** (vẫn trong Firebase Console)
2. **Collections** → tìm **`users`** collection
3. Click **"Add document"**
4. **Document ID**: Paste UID từ bước 1
5. Click **"Save"**

Sau đó **thêm field**:
- Click **"Add field"**
- **Field**: `isAdmin`
- **Type**: `Boolean`
- **Value**: `true` ✅
- Click **"Save"**

```
Document của bạn sẽ có:
{
  "isAdmin": true
}
```

---

### Bước 3️⃣: Deploy Rules

**Cách A: Qua Firebase Console (Nếu không muốn dùng CLI)**

1. Firebase Console → **Cloud Firestore** → **Rules** tab
2. **Xóa toàn bộ** rules cũ
3. **Copy file `firestore.rules`** từ VS Code
4. **Paste** vào Firebase Console
5. Click **"Publish"**

**Cách B: Qua CLI (Nếu đã cài Firebase CLI)**

```bash
cd c:\DACN\NguyenAnhKhoi
firebase deploy --only firestore
```

---

### ✅ Bước 4️⃣: Test

1. **Refresh app** (đóng hoàn toàn rồi mở lại)
2. **Đăng nhập bằng tài khoản admin**
3. **Admin Dashboard** → **Quản Lý Danh Mục Sản Phẩm**
4. **Thêm danh mục**:
   - Tên: "Test"
   - Mô tả: "Test"
   - Upload ảnh
   - Click "Thêm mới"

✅ **Nếu không có lỗi** → **Thành công!** 🎉

---

## 🔐 Quyền Hạn Sau Setup

| User | Thêm Danh Mục | Sửa Danh Mục | Xóa Danh Mục | Xem |
|------|---------|---------|---------|------|
| **Admin App** | ✅ | ✅ | ✅ | ✅ |
| **Customers** | ❌ | ❌ | ❌ | ✅ |

---

## ⚠️ Quan Trọng

- **UID phải đúng** - copy từ Authentication
- **Field phải là `isAdmin`** - chữ cái, không thể `is_admin`
- **Type phải là `Boolean`** - value là `true` không phải `"true"`
- **Deploy xong refresh app** - rules cần apply

---

## ❌ Nếu Vẫn Lỗi

1. Kiểm tra UID có match không?
2. Kiểm tra field `isAdmin: true` trong Firestore
3. Kiểm tra rules đã deploy/publish?
4. Restart app (đóng hoàn toàn rồi mở)

---

**Xong!** Giờ chỉ admin app mới thêm/sửa/xóa danh mục được 🔐
