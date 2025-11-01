# Hướng Dẫn Sử Dụng Hệ Thống Dịch Vụ Nổi Bật và Phân Loại

## 📋 Tổng Quan Cập Nhật

Hệ thống đã được cập nhật với 2 tính năng chính:
1. **Dịch vụ Nổi Bật**: Đánh dấu và hiển thị dịch vụ quan trọng ở đầu trang
2. **Phân Loại Dịch Vụ**: Tổ chức dịch vụ theo danh mục

## 🎯 Tính Năng Mới

### 1. Dịch Vụ Nổi Bật (Featured Services)

**Cho Admin:**
- Khi thêm/sửa dịch vụ, có checkbox "Đánh dấu là nổi bật"
- Nếu tick, có thể nhập thứ tự hiển thị (số nhỏ hơn hiển thị trước)
- Dịch vụ nổi bật sẽ xuất hiện trong section riêng ở đầu trang chủ

**Cho User:**
- Section "Dịch vụ nổi bật" hiển thị đầu tiên
- Có badge vàng ⭐ "Nổi bật" trên ảnh dịch vụ
- Swipe ngang để xem các dịch vụ nổi bật khác

### 2. Phân Loại Dịch Vụ Theo Danh Mục

**Cho User:**
- Sau section nổi bật, dịch vụ được nhóm theo loại
- Mỗi loại có icon, tên và mô tả riêng
- Dễ dàng tìm kiếm dịch vụ theo nhu cầu

## 📱 Giao Diện Home Screen Mới

```
┌─────────────────────────────────┐
│  Header (User Info + Search)    │
├─────────────────────────────────┤
│  Voucher Carousel               │
├─────────────────────────────────┤
│  🌟 Dịch vụ nổi bật             │
│  [Service 1] [Service 2] [...]  │
├─────────────────────────────────┤
│  ✂️ Cắt tóc                      │
│  Các dịch vụ cắt tóc nam        │
│  [Service] [Service] [...]      │
├─────────────────────────────────┤
│  💇 Nhuộm tóc                    │
│  Nhuộm, tẩy, highlight          │
│  [Service] [Service] [...]      │
├─────────────────────────────────┤
│  ... (các loại khác)            │
└─────────────────────────────────┘
```

## 🔧 Hướng Dẫn Sử Dụng Cho Admin

### Bước 1: Tạo Loại Dịch Vụ (Nếu Chưa Có)

1. Đăng nhập Admin Panel
2. Chọn "Quản lý Loại dịch vụ"
3. Nhấn "Thêm loại dịch vụ"
4. Điền thông tin:
   - **Tên**: VD: "Cắt tóc", "Nhuộm tóc"
   - **Mô tả**: VD: "Các dịch vụ cắt tóc nam"
   - **Icon**: Chọn emoji phù hợp ✂️ 💇 🎨
   - **Thứ tự**: 0, 1, 2,... (thứ tự hiển thị)
   - **Hiển thị**: Tick để kích hoạt

**Gợi ý các loại dịch vụ:**
- ✂️ Cắt tóc - Các dịch vụ cắt tóc nam
- 💇 Nhuộm tóc - Nhuộm, tẩy, highlight
- 🎨 Uốn tóc - Uốn xoăn, duỗi thẳng
- 💈 Gội đầu - Gội đầu massage thư giãn
- 🧴 Chăm sóc - Dưỡng tóc, ủ tóc
- 🪒 Cạo râu - Cạo râu và tạo kiểu râu

### Bước 2: Thêm Dịch Vụ với Đánh Dấu Nổi Bật

1. Chọn "Quản lý Dịch vụ"
2. Nhấn "Thêm dịch vụ mới"
3. Điền thông tin cơ bản:
   - **Loại dịch vụ**: Chọn từ dropdown (bắt buộc)
   - Tên, giá, thời lượng, đánh giá, ảnh

4. **Phần Dịch Vụ Nổi Bật** (màu cam):
   - Tick vào "Đánh dấu là nổi bật" nếu muốn
   - Nhập thứ tự hiển thị (VD: 1, 2, 3...)
   - Số nhỏ hơn sẽ hiển thị trước

5. Nhấn "Thêm mới" hoặc "Cập nhật"

### Bước 3: Quản Lý Dịch Vụ Nổi Bật

**Lựa chọn dịch vụ nào nên nổi bật:**
- Dịch vụ mới
- Dịch vụ khuyến mãi
- Dịch vụ bán chạy
- Dịch vụ đặc biệt theo mùa

**Thứ tự hiển thị:**
- 1-5: Ưu tiên cao nhất
- 10-20: Ưu tiên trung bình
- 999: Mặc định (hiển thị cuối)

## 🎨 Thiết Kế UI

### Service Card Nổi Bật
```
┌─────────────────────┐
│ [⭐ Nổi bật]    [♥] │
│                     │
│   [Ảnh dịch vụ]     │
│                     │
├─────────────────────┤
│ Tên dịch vụ         │
│ ⭐ 4.5 | 30 phút    │
│ 150,000₫            │
└─────────────────────┘
```

### Service Card Thường
```
┌─────────────────────┐
│                [♥]  │
│   [Ảnh dịch vụ]     │
│                     │
├─────────────────────┤
│ Tên dịch vụ         │
│ ⭐ 4.5 | 30 phút    │
│ 150,000₫            │
└─────────────────────┘
```

## 📊 Cấu Trúc Database

### Collection: `services` (đã cập nhật)

```json
{
  "name": "Cắt tóc Undercut",
  "price": 150000,
  "duration": "30 phút",
  "rating": 4.8,
  "image": "https://...",
  "categoryId": "cat001",
  "categoryName": "Cắt tóc",
  "isFeatured": true,
  "featuredOrder": 1
}
```

**Các trường mới:**
- `isFeatured`: Boolean - Dịch vụ có nổi bật không
- `featuredOrder`: Number - Thứ tự hiển thị (default: 999)

## 🚀 Workflow Hoàn Chỉnh

### 1. Setup Ban Đầu (Làm 1 lần)

```
Admin Login
  ↓
Tạo Loại Dịch Vụ
  ├─ ✂️ Cắt tóc
  ├─ 💇 Nhuộm tóc
  ├─ 🎨 Uốn tóc
  └─ ... (các loại khác)
```

### 2. Thêm Dịch Vụ Mới

```
Quản lý Dịch vụ
  ↓
Thêm dịch vụ mới
  ├─ Chọn loại: ✂️ Cắt tóc
  ├─ Điền thông tin
  ├─ Tick "Nổi bật" (nếu cần)
  └─ Lưu
```

### 3. Cập Nhật Dịch Vụ Cũ

Tất cả dịch vụ cũ cần:
1. Gán vào loại dịch vụ phù hợp
2. Cân nhắc đánh dấu nổi bật cho dịch vụ quan trọng

## ⚠️ Lưu Ý Quan Trọng

### Firestore Rules
Đảm bảo rules cho phép đọc `service_categories`:
```javascript
match /service_categories/{docId} {
  allow read: if true;
  allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}
```

### Performance
- Chỉ đánh dấu 3-5 dịch vụ nổi bật
- Quá nhiều dịch vụ nổi bật sẽ làm mất ý nghĩa

### UX Best Practices
- Cập nhật dịch vụ nổi bật thường xuyên (hàng tuần)
- Luân phiên các dịch vụ để khách hàng không thấy nhàm chán
- Dịch vụ mới nên đánh dấu nổi bật 1-2 tuần đầu

## 🔍 Testing Checklist

- [ ] Tạo được loại dịch vụ mới
- [ ] Thêm dịch vụ với loại và đánh dấu nổi bật
- [ ] Home screen hiển thị section "Dịch vụ nổi bật"
- [ ] Badge "Nổi bật" xuất hiện trên card
- [ ] Dịch vụ được nhóm theo loại
- [ ] Icon và mô tả loại hiển thị đúng
- [ ] Swipe ngang hoạt động mượt
- [ ] Thứ tự featured đúng (số nhỏ trước)
- [ ] Có thể bật/tắt featured cho dịch vụ
- [ ] Cập nhật dịch vụ cũ không bị lỗi

## 📞 Troubleshooting

**Không thấy section nổi bật:**
- Kiểm tra đã tick "Đánh dấu là nổi bật" chưa
- Reload lại app

**Dịch vụ không nhóm theo loại:**
- Kiểm tra đã chọn loại dịch vụ chưa
- Kiểm tra loại đó có `isActive = true` không

**Thứ tự không đúng:**
- Kiểm tra `featuredOrder`: số nhỏ hơn hiển thị trước

## 🎉 Kết Quả Mong Đợi

Sau khi setup xong:
1. Home screen hiển thị đẹp, có tổ chức
2. Khách hàng dễ tìm dịch vụ theo nhu cầu
3. Dịch vụ quan trọng được highlight
4. Tăng conversion rate do UX tốt hơn

---

**Phiên bản:** 2.0  
**Ngày cập nhật:** 1/11/2025  
**Liên hệ hỗ trợ:** [Thông tin support của bạn]
