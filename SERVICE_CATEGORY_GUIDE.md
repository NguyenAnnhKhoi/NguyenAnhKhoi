# Hệ thống Quản lý Loại Dịch Vụ

## Tổng quan
Hệ thống đã được cập nhật để hỗ trợ phân loại dịch vụ thành nhiều danh mục khác nhau như: Cắt tóc, Nhuộm tóc, Uốn tóc, Gội đầu massage, v.v.

## Các Thay Đổi Chính

### 1. Model Mới: ServiceCategory
- **File**: `lib/models/service_category.dart`
- **Chức năng**: Quản lý thông tin loại dịch vụ
- **Thuộc tính**:
  - `id`: ID duy nhất
  - `name`: Tên loại dịch vụ (VD: "Cắt tóc", "Nhuộm tóc")
  - `description`: Mô tả chi tiết
  - `icon`: Icon emoji để hiển thị (VD: ✂️, 💇, 🎨)
  - `sortOrder`: Thứ tự hiển thị
  - `isActive`: Trạng thái hiển thị

### 2. Model Service Được Cập Nhật
- **File**: `lib/models/service.dart`
- **Thêm thuộc tính**:
  - `categoryId`: ID của loại dịch vụ
  - `categoryName`: Tên loại dịch vụ (lưu để truy vấn nhanh)

### 3. Màn Hình Quản Lý Loại Dịch Vụ (Admin)
- **File**: `lib/admin/manage_service_categories_screen.dart`
- **Chức năng**:
  - Thêm/sửa/xóa loại dịch vụ
  - Chọn icon từ danh sách emoji có sẵn
  - Sắp xếp thứ tự hiển thị
  - Bật/tắt hiển thị loại dịch vụ
  - Kiểm tra xem có dịch vụ nào đang sử dụng loại này trước khi xóa

### 4. Màn Hình Thêm/Sửa Dịch Vụ (Admin)
- **File**: `lib/admin/service_edit_screen.dart`
- **Cập nhật**:
  - Thêm dropdown chọn loại dịch vụ
  - Dropdown chỉ hiển thị các loại đang active
  - Bắt buộc phải chọn loại dịch vụ khi thêm/sửa

### 5. Admin Dashboard
- **File**: `lib/admin/admin_home_screen.dart`
- **Cập nhật**: Thêm nút "Quản lý Loại dịch vụ"

## Cách Sử Dụng

### Bước 1: Tạo Loại Dịch Vụ (Admin)
1. Đăng nhập tài khoản Admin
2. Chọn "Quản lý Loại dịch vụ"
3. Nhấn nút "Thêm loại dịch vụ"
4. Điền thông tin:
   - Tên loại dịch vụ
   - Mô tả
   - Chọn icon
   - Thứ tự hiển thị (số nhỏ hơn sẽ hiển thị trước)
   - Chọn "Hiển thị" để kích hoạt
5. Nhấn "Thêm"

**Ví dụ loại dịch vụ:**
- ✂️ Cắt tóc - Các dịch vụ cắt tóc nam
- 💇 Nhuộm tóc - Nhuộm, tẩy, highlight
- 🎨 Uốn tóc - Uốn xoăn, duỗi thẳng
- 💈 Gội đầu - Gội đầu massage thư giãn
- 🧴 Chăm sóc - Dưỡng tóc, ủ tóc

### Bước 2: Thêm Dịch Vụ với Loại
1. Chọn "Quản lý Dịch vụ"
2. Nhấn "Thêm dịch vụ mới" hoặc chỉnh sửa dịch vụ có sẵn
3. **Chọn loại dịch vụ từ dropdown** (bắt buộc)
4. Điền thông tin dịch vụ còn lại
5. Lưu

### Bước 3: Cập Nhật Dịch Vụ Cũ
- Tất cả dịch vụ cũ cần được cập nhật để gán vào loại dịch vụ phù hợp
- Admin cần vào chỉnh sửa từng dịch vụ và chọn loại tương ứng

## Cấu Trúc Database Firestore

### Collection: `service_categories`
```json
{
  "name": "Cắt tóc",
  "description": "Các dịch vụ cắt tóc nam",
  "icon": "✂️",
  "sortOrder": 0,
  "isActive": true
}
```

### Collection: `services` (cập nhật)
```json
{
  "name": "Cắt tóc Basic",
  "price": 150000,
  "duration": "30 phút",
  "rating": 4.5,
  "image": "https://...",
  "categoryId": "abc123",
  "categoryName": "Cắt tóc"
}
```

## Các Tính Năng Sắp Tới

### 1. Lọc Dịch Vụ Theo Loại (User)
- Cập nhật `home_screen.dart` để thêm tabs/filter theo loại dịch vụ
- Người dùng có thể xem dịch vụ theo từng danh mục

### 2. Hiển Thị Nhóm
- Group các dịch vụ theo loại khi hiển thị
- Thêm header cho mỗi nhóm

### 3. Thống Kê
- Thống kê số lượng dịch vụ theo loại
- Dịch vụ phổ biến nhất mỗi loại

## Lưu Ý Quan Trọng

1. **Không xóa được loại dịch vụ** nếu có dịch vụ đang sử dụng
2. **categoryId và categoryName** được lưu cùng service để tối ưu truy vấn
3. Khi đổi tên loại dịch vụ, cần cập nhật lại tất cả services thuộc loại đó (có thể thêm Cloud Function)
4. Icon sử dụng emoji nên không cần asset bổ sung

## Checklist Triển Khai

- [x] Tạo model ServiceCategory
- [x] Cập nhật model Service
- [x] Tạo màn hình quản lý loại dịch vụ
- [x] Cập nhật màn hình thêm/sửa dịch vụ
- [x] Thêm nút vào Admin Dashboard
- [ ] Cập nhật home_screen để lọc theo loại
- [ ] Cập nhật UI hiển thị dịch vụ theo nhóm
- [ ] Thêm validation và error handling
- [ ] Testing toàn diện

## Hỗ Trợ

Nếu có vấn đề, kiểm tra:
1. Firestore Rules có cho phép đọc/ghi collection `service_categories`
2. Tất cả services đã có categoryId
3. Dropdown category có hiển thị đầy đủ danh sách
