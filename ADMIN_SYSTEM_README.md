# Hệ thống Admin - Gentlemen's Grooming

## Tổng quan
Hệ thống admin được tích hợp vào ứng dụng Gentlemen's Grooming để quản lý các thành phần chính của ứng dụng.

## Tài khoản Admin mặc định
- **Email**: admin@gmail.com
- **Mật khẩu**: @123456

## Chức năng Admin

### 1. Dashboard Admin
- Giao diện tổng quan với các card quản lý
- Hiển thị thông tin admin hiện tại
- Điều hướng đến các màn hình quản lý

### 2. Quản lý Dịch vụ
- Thêm mới dịch vụ
- Chỉnh sửa thông tin dịch vụ
- Xóa dịch vụ
- Xem danh sách tất cả dịch vụ

**Thông tin dịch vụ bao gồm:**
- Tên dịch vụ
- Giá (VNĐ)
- Thời gian thực hiện
- Đánh giá (0-5 sao)
- URL hình ảnh

### 3. Quản lý Chi nhánh
- Thêm mới chi nhánh
- Chỉnh sửa thông tin chi nhánh
- Xóa chi nhánh
- Xem danh sách tất cả chi nhánh

**Thông tin chi nhánh bao gồm:**
- Tên chi nhánh
- Địa chỉ
- Giờ hoạt động
- Đánh giá (0-5 sao)
- Tọa độ (vĩ độ, kinh độ)
- URL hình ảnh

### 4. Quản lý Stylist
- Thêm mới stylist
- Chỉnh sửa thông tin stylist
- Xóa stylist
- Xem danh sách tất cả stylist

**Thông tin stylist bao gồm:**
- Tên stylist
- Kinh nghiệm
- Đánh giá (0-5 sao)
- URL hình ảnh

### 5. Quản lý Đơn đặt lịch
- Xem danh sách tất cả đơn đặt lịch
- Lọc theo trạng thái
- Cập nhật trạng thái đơn đặt lịch
- Xóa đơn đặt lịch

**Trạng thái đơn đặt lịch:**
- Chờ xác nhận
- Đã xác nhận
- Đang thực hiện
- Hoàn thành
- Đã hủy

## Cách sử dụng

### Đăng nhập Admin
1. Mở ứng dụng
2. Nhấn "Đăng nhập"
3. Nhập email: `admin@gmail.com`
4. Nhập mật khẩu: `@123456`
5. Nhấn "Đăng nhập"

Sau khi đăng nhập thành công, hệ thống sẽ tự động chuyển đến Dashboard Admin.

### Quản lý dữ liệu
1. Từ Dashboard Admin, chọn mục cần quản lý
2. Sử dụng form để thêm mới hoặc chỉnh sửa
3. Nhấn "Thêm mới" hoặc "Cập nhật" để lưu
4. Sử dụng nút "Xóa" để xóa dữ liệu

## Cấu trúc dữ liệu

### Collection `users`
```json
{
  "id": "string",
  "email": "string",
  "displayName": "string",
  "photoURL": "string",
  "isAdmin": "boolean",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp"
}
```

### Collection `services`
```json
{
  "name": "string",
  "price": "number",
  "duration": "string",
  "rating": "number",
  "image": "string"
}
```

### Collection `branches`
```json
{
  "name": "string",
  "address": "string",
  "hours": "string",
  "rating": "number",
  "image": "string",
  "latitude": "number",
  "longitude": "number"
}
```

### Collection `stylists`
```json
{
  "name": "string",
  "image": "string",
  "rating": "number",
  "experience": "string"
}
```

### Collection `bookings`
```json
{
  "serviceName": "string",
  "stylistName": "string",
  "customerName": "string",
  "customerPhone": "string",
  "branchName": "string",
  "dateTime": "timestamp",
  "status": "string",
  "note": "string",
  "paymentMethod": "string"
}
```

## Lưu ý
- Tài khoản admin được tạo tự động khi khởi động ứng dụng
- Chỉ có tài khoản admin mới có thể truy cập vào hệ thống quản lý
- Tất cả dữ liệu được lưu trữ trên Firebase Firestore
- Hệ thống hỗ trợ real-time updates cho tất cả dữ liệu
