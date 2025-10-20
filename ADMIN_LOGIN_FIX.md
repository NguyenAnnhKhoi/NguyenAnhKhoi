# Hướng dẫn sử dụng hệ thống Admin đã sửa

## Vấn đề đã được sửa

### 1. Lỗi đăng nhập Admin
**Vấn đề:** Tài khoản admin được tạo với ID cố định 'admin' nhưng khi kiểm tra quyền admin lại sử dụng UID thực tế từ Firebase Auth.

**Giải pháp:** 
- Cập nhật `AdminService.createDefaultAdmin()` để sử dụng UID thực tế từ Firebase Auth
- Tài khoản admin được lưu với UID thực tế thay vì ID cố định
- Cập nhật logic kiểm tra quyền admin để sử dụng đúng UID

### 2. Cải thiện giao diện User

#### Home Screen
- **Màu sắc mới:** Chuyển từ màu tối sang gradient xanh cyan đẹp mắt
- **Header:** Gradient xanh cyan với shadow đẹp hơn
- **Search bar:** Bo tròn hơn với shadow mềm mại
- **Top buttons:** Màu sắc đa dạng với icon màu phù hợp
- **Service cards:** Shadow xanh cyan thay vì đen, bo tròn hơn
- **Price:** Màu xanh cyan thay vì vàng

#### Login Screen
- **Background:** Gradient xanh cyan thay vì đen
- **Form:** Bo tròn hơn với shadow đẹp
- **Input fields:** Màu focus xanh cyan
- **Buttons:** Màu xanh cyan với shadow
- **Links:** Màu trắng thay vì vàng

## Cách sử dụng

### 1. Đăng nhập Admin
1. Chạy ứng dụng
2. Nhấn "Đăng nhập"
3. Nhập email: `admin@gmail.com`
4. Nhập mật khẩu: `@123456`
5. Nhấn "Đăng nhập"

**Lưu ý:** Tài khoản admin sẽ được tạo tự động khi khởi động ứng dụng lần đầu.

### 2. Kiểm tra quyền Admin
- Hệ thống sẽ tự động kiểm tra quyền admin sau khi đăng nhập
- Nếu là admin: chuyển đến Admin Dashboard
- Nếu là user thường: chuyển đến Main Screen

### 3. Tính năng Admin Dashboard
- **Quản lý dịch vụ:** Thêm/sửa/xóa dịch vụ
- **Quản lý chi nhánh:** Thêm/sửa/xóa chi nhánh với tọa độ
- **Quản lý stylist:** Thêm/sửa/xóa stylist
- **Quản lý đơn đặt lịch:** Xem, lọc, cập nhật trạng thái đơn đặt lịch

## Cấu trúc dữ liệu

### Collection `users`
```json
{
  "id": "firebase_uid",
  "email": "admin@gmail.com",
  "displayName": "Admin",
  "photoURL": null,
  "isAdmin": true,
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp"
}
```

## Lưu ý quan trọng

1. **Tài khoản admin:** Được tạo tự động với UID thực tế từ Firebase Auth
2. **Phân quyền:** Kiểm tra dựa trên field `isAdmin` trong Firestore
3. **Giao diện:** Đã được cải thiện với màu sắc xanh cyan hiện đại
4. **Responsive:** Giao diện tương thích với nhiều kích thước màn hình

## Troubleshooting

### Nếu không thể đăng nhập admin:
1. Kiểm tra kết nối mạng
2. Xóa cache ứng dụng và thử lại
3. Kiểm tra console log để xem lỗi chi tiết

### Nếu không chuyển đến Admin Dashboard:
1. Kiểm tra field `isAdmin` trong Firestore
2. Đảm bảo tài khoản được tạo đúng với UID thực tế
3. Restart ứng dụng và thử lại

Hệ thống admin đã được sửa lỗi và cải thiện giao diện, sẵn sàng sử dụng!
