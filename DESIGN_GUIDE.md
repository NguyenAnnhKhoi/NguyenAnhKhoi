# 🎨 Hướng Dẫn Thiết Kế Giao Diện Gen Z

## 📋 Tổng Quan

Ứng dụng **Gentlemen's Grooming** được thiết kế theo phong cách Gen Z hiện đại, tập trung vào:
- **Độ tuổi mục tiêu**: 18-40 tuổi
- **Phong cách**: Trẻ trung, năng động, dễ tiếp cận
- **Trải nghiệm**: Mượt mà, trực quan, thú vị

---

## 🎨 Bảng Màu Chính

### Primary Colors (Cyan/Teal)
```dart
Primary:        #0891B2  // Cyan 600 - Màu chủ đạo
Primary Light:  #06B6D4  // Cyan 500 - Màu phụ
Primary Lighter:#22D3EE  // Cyan 400 - Highlight
Primary Dark:   #0E7490  // Cyan 700 - Accent
```

### Gradient Colors
```dart
Gradient Pink:   [#FF6B9D, #FFA06B]  // Ưu đãi, Hot deals
Gradient Cyan:   [#0891B2, #06B6D4]  // Primary actions
Gradient Purple: [#8B5CF6, #C084FC]  // Premium features
Gradient Orange: [#FFA500, #FF6B35]  // Warnings
Gradient Green:  [#10B981, #34D399]  // Success states
```

### Background & Surface
```dart
Background Light: #F8FAFC  // Slate 50 - Nền chính
Background White: #FFFFFF  // Cards, Dialogs
Background Gray:  #F1F5F9  // Slate 100 - Sections
```

### Text Colors
```dart
Text Primary:    #0F172A  // Slate 900 - Tiêu đề chính
Text Secondary:  #475569  // Slate 600 - Nội dung
Text Tertiary:   #64748B  // Slate 500 - Phụ
Text Light:      #94A3B8  // Slate 400 - Disabled
```

---

## 📐 Spacing System

Sử dụng hệ thống spacing nhất quán:

```dart
XS:  4px   // Khoảng cách rất nhỏ (margins, paddings)
SM:  8px   // Khoảng cách nhỏ
MD:  16px  // Khoảng cách trung bình (mặc định)
LG:  24px  // Khoảng cách lớn
XL:  32px  // Khoảng cách rất lớn
XXL: 48px  // Khoảng cách cực lớn (sections)
```

---

## 🔲 Border Radius

Góc bo tròn tạo cảm giác mềm mại, thân thiện:

```dart
SM:   8px   // Input fields nhỏ
MD:   12px  // Buttons, small cards
LG:   16px  // Standard cards, inputs
XL:   20px  // Large cards
XXL:  24px  // Dialogs, bottom sheets
FULL: 9999px // Pills, badges
```

---

## ✏️ Typography

### Headings
- **H1**: 32px, FontWeight.w900 - Hero titles
- **H2**: 28px, FontWeight.w800 - Page titles
- **H3**: 22px, FontWeight.w800 - Section titles
- **H4**: 18px, FontWeight.w700 - Card titles

### Body Text
- **Body Large**: 16px, FontWeight.w500 - Emphasized content
- **Body Medium**: 15px, FontWeight.w400 - Standard text
- **Body Small**: 14px, FontWeight.w400 - Secondary info

### Special
- **Caption**: 13px, FontWeight.w600 - Labels
- **Button**: 16px, FontWeight.w700 - CTA text

---

## 🎯 Nguyên Tắc Thiết Kế Gen Z

### 1. **Visual Hierarchy** (Thứ bậc thị giác)
- Sử dụng size, color, weight để tạo độ tương phản
- Highlight những thông tin quan trọng
- Giảm thiểu clutter (lộn xộn)

### 2. **Gradients & Colors**
- Sử dụng gradient cho buttons, headers để tạo điểm nhấn
- Màu sắc tươi sáng nhưng không chói mắt
- Consistent color usage (màu nhất quán)

### 3. **Shadows & Depth**
- Soft shadows (shadow mềm) thay vì hard borders
- Elevation levels (mức độ nổi) rõ ràng
- Hover/Active states có feedback

### 4. **Micro-interactions**
- Animations mượt mà (200-400ms)
- Loading states rõ ràng
- Feedback ngay lập tức khi user tương tác

### 5. **Emoji & Icons**
- Sử dụng emoji để tạo cảm xúc, gần gũi
- Icons rõ ràng, dễ hiểu
- Consistent icon style

### 6. **Whitespace**
- Không sợ để trống (negative space)
- Breathing room cho elements
- Tạo focus vào content quan trọng

### 7. **Mobile-First**
- Thumb-friendly zones (vùng dễ chạm)
- Buttons đủ lớn (min 44x44px)
- Bottom navigation thay vì top menu

---

## 🎭 Components Gen Z

### Buttons
```dart
// Primary Action
GradientButton(
  text: 'Đặt lịch ngay',
  icon: Icons.add_circle_outline,
  gradientColors: AppColors.gradientCyan,
)

// Secondary Action
OutlinedButton với border mềm, hover effect
```

### Cards
```dart
// Service Cards: Rounded corners, soft shadow, hover effect
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    boxShadow: AppShadows.medium,
  ),
)
```

### Empty States
```dart
EmptyState(
  emoji: '📅',
  title: 'Chưa có lịch hẹn nào',
  subtitle: 'Bắt đầu đặt lịch ngay! ✨',
  buttonText: 'Đặt lịch',
)
```

### Status Badges
```dart
StatusBadge(
  text: 'Hot',
  color: Colors.red,
  icon: Icons.local_fire_department,
)
```

---

## 📱 Screen Patterns

### 1. **Headers với Gradient**
- Gradient background
- Large, bold title với emoji
- Subtle icon decoration
- Smooth transition khi scroll

### 2. **Tab Navigation**
- Pills style thay vì underline
- Active tab có gradient background
- Smooth animation khi switch

### 3. **Lists & Grids**
- Card-based layout
- Consistent spacing
- Image với badge overlay
- Hover/tap feedback

### 4. **Forms**
- Grouped fields
- Icon prefixes
- Clear labels
- Inline validation
- Visual feedback

### 5. **Dialogs & Modals**
- Bottom sheets thay vì center dialogs
- Swipe to dismiss
- Large, clear actions
- Emoji headers

---

## ✅ Checklist Thiết Kế

Khi thiết kế màn hình mới, check:

- [ ] Có sử dụng spacing system nhất quán?
- [ ] Border radius phù hợp với component size?
- [ ] Shadow levels hợp lý?
- [ ] Colors contrast đủ (accessibility)?
- [ ] Buttons đủ lớn cho mobile?
- [ ] Loading states rõ ràng?
- [ ] Error states được xử lý?
- [ ] Empty states có hướng dẫn?
- [ ] Animations không quá nhanh/chậm?
- [ ] Typography hierarchy rõ ràng?

---

## 🚀 Tips & Best Practices

### DO ✅
- Sử dụng emoji để tạo personality
- Gradient cho CTAs (Call-to-Actions)
- Soft shadows thay vì borders
- Whitespace generous
- Clear visual hierarchy
- Consistent spacing
- Smooth animations

### DON'T ❌
- Quá nhiều màu sắc
- Text quá nhỏ (<14px cho body)
- Buttons quá nhỏ (<44x44px)
- Quá nhiều animations
- Inconsistent spacing
- Hard borders everywhere
- Center-aligned paragraphs

---

## 📚 Resources

### Fonts
- **Primary**: Roboto (system font)
- **Weights**: 400 (Regular), 500 (Medium), 600 (Semi-Bold), 700 (Bold), 800 (Extra Bold), 900 (Black)

### Icons
- Material Icons (built-in)
- Size: 18px (small), 24px (standard), 32px (large)

### Shadows
- Small: 4px blur, 2px offset
- Medium: 12px blur, 4px offset
- Large: 16px blur, 6px offset

---

## 🎨 Color Psychology

- **Cyan/Teal**: Trust, calm, professional nhưng vẫn fresh
- **Pink**: Fun, friendly, approachable
- **Purple**: Premium, creative, innovative
- **Orange**: Energetic, attention-grabbing
- **Green**: Success, positive, growth

---

## 📞 Contact

Nếu có câu hỏi về design system, liên hệ team design!

**Happy Designing! 🎨✨**
