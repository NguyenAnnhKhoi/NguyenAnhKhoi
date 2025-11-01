# Hướng dẫn Loại dịch vụ Cố định (Predefined Service Categories)

## Tổng quan

Hệ thống đã được đơn giản hóa để sử dụng danh sách loại dịch vụ cố định thay vì quản lý động qua Firestore. Điều này giúp:
- ✅ Tránh lỗi quyền truy cập Firestore
- ✅ Đơn giản hóa quy trình quản lý
- ✅ Cải thiện hiệu suất (không cần query Firestore)
- ✅ Dễ bảo trì và mở rộng

## Danh sách Loại dịch vụ

### Các loại dịch vụ có sẵn:

1. **✂️ Cắt tóc** - Dịch vụ cắt tóc cơ bản
2. **💇 Cắt + Gội** - Combo cắt tóc kèm gội đầu
3. **🎨 Nhuộm tóc** - Dịch vụ nhuộm màu tóc
4. **🌀 Uốn tóc** - Dịch vụ uốn tóc các kiểu
5. **💈 Gội đầu** - Gội đầu thông thường
6. **💆 Massage** - Massage thư giãn đầu vai gáy
7. **🧴 Chăm sóc da mặt** - Dịch vụ chăm sóc da
8. **🪒 Cạo râu** - Cạo râu chuyên nghiệp
9. **💫 Tạo kiểu** - Tạo kiểu tóc đặc biệt
10. **⭐ Combo đặc biệt** - Các gói combo nhiều dịch vụ
11. **👑 Dịch vụ VIP** - Dịch vụ cao cấp dành cho VIP

## Cách thêm dịch vụ mới

### Trong Admin Panel:

1. Mở **Admin Panel** → **Quản lý Dịch vụ**
2. Nhấn nút **Thêm dịch vụ mới** (+)
3. Chọn **Loại dịch vụ** từ dropdown (11 loại có sẵn)
4. Điền thông tin:
   - Tên dịch vụ
   - Giá (VNĐ)
   - Thời lượng (ví dụ: "30 phút")
   - Đánh giá (0-5 sao)
   - Link ảnh URL
5. (Tùy chọn) Đánh dấu **Dịch vụ nổi bật**:
   - Check vào ô "Hiển thị trong danh sách nổi bật"
   - Nhập thứ tự ưu tiên (số nhỏ = ưu tiên cao)
6. Nhấn **Lưu**

### Ví dụ dịch vụ:

```
Loại: Cắt tóc
Tên: Cắt tóc nam cơ bản
Giá: 80000
Thời lượng: 30 phút
Đánh giá: 4.5
Link ảnh: https://example.com/haircut.jpg
```

## Hiển thị trên Home Screen

### Dịch vụ được nhóm theo loại:

```
📱 Home Screen
├── 🌟 Dịch vụ nổi bật (Featured Services)
│   └── Các dịch vụ có isFeatured = true
│
├── ✂️ Cắt tóc
│   ├── Cắt tóc nam cơ bản
│   └── Cắt tóc nữ cao cấp
│
├── 💇 Cắt + Gội
│   └── Combo cắt + gội massage
│
├── 🎨 Nhuộm tóc
│   ├── Nhuộm thời trang
│   └── Nhuộm phủ bạc
│
└── ... (các loại khác)
```

## Cách thêm loại dịch vụ mới

Nếu cần thêm loại dịch vụ mới vào hệ thống:

### 1. Cập nhật danh sách trong `service_edit_screen.dart`:

```dart
final List<Map<String, String>> _serviceCategories = [
  {'name': 'Cắt tóc', 'icon': '✂️'},
  {'name': 'Cắt + Gội', 'icon': '💇'},
  // ... các loại hiện có
  {'name': 'Loại mới của bạn', 'icon': '🎭'}, // THÊM VÀO ĐÂY
];
```

### 2. Cập nhật icon mapping trong `home_screen.dart`:

```dart
String _getCategoryIcon(String categoryName) {
  final name = categoryName.toLowerCase();
  
  // Exact matches first
  if (name == 'loại mới của bạn') return '🎭'; // THÊM VÀO ĐÂY
  
  // ... các loại hiện có
}
```

## Thay đổi so với phiên bản trước

### ❌ Đã loại bỏ:
- Screen quản lý loại dịch vụ (`manage_service_categories_screen.dart`)
- Collection `service_categories` trong Firestore
- Import `ServiceCategory` model trong các screen
- Nút "Quản lý Loại dịch vụ" trong Admin Panel

### ✅ Thay thế bằng:
- Danh sách cố định trong code
- Dropdown đơn giản với 11 loại có sẵn
- Không cần query Firestore
- Tự động gán icon dựa trên tên loại

## Cấu trúc dữ liệu Service

```dart
Service {
  id: String
  name: String
  price: double
  duration: String
  rating: double
  image: String
  categoryId: null              // Không sử dụng nữa
  categoryName: String          // "Cắt tóc", "Nhuộm tóc", etc.
  isFeatured: bool              // true/false
  featuredOrder: int            // Thứ tự ưu tiên (0-999)
}
```

## Lưu ý kỹ thuật

1. **Không cần Firestore rules cho service_categories** - Không còn collection này
2. **categoryId = null** - Field này giữ lại để tương thích nhưng luôn là null
3. **categoryName** - Sử dụng trường này để nhóm dịch vụ
4. **Icon tự động** - Hệ thống tự gán icon dựa trên categoryName

## Migration từ hệ thống cũ

Nếu đã có dữ liệu dịch vụ với categoryId:

1. Dữ liệu cũ vẫn hoạt động (categoryName đã có)
2. Dịch vụ mới sẽ có categoryId = null
3. Không cần migrate dữ liệu, hệ thống tự động nhóm theo categoryName

## Support

Nếu gặp vấn đề:
- Kiểm tra categoryName có khớp với danh sách 11 loại không
- Xem log để debug icon assignment
- Đảm bảo Firestore rules cho collection `services` hợp lệ

---

**Cập nhật:** Tháng 1, 2025
**Phiên bản:** 2.0 (Predefined Categories)
