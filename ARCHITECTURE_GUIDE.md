# 🏗️ Architecture & Best Practices Guide

## 📐 Project Architecture

### Folder Structure
```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
│
├── models/                   # Data models
│   ├── booking.dart
│   ├── service.dart
│   ├── stylist.dart
│   └── branch.dart
│
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── booking_screen.dart
│   ├── quick_booking_screen.dart
│   ├── payment_screen.dart
│   ├── my_bookings_screen.dart
│   ├── account_screen.dart
│   ├── branch_screen.dart
│   ├── forgot_password_screen.dart
│   └── profile/             # Profile-related screens
│       ├── profile_info_screen.dart
│       ├── transaction_history_screen.dart
│       ├── favorite_services_screen.dart
│       └── ...
│
├── services/                # Business logic & API
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
│
├── widgets/                 # Reusable widgets
│   └── service_card_shimmer.dart
│
├── theme/                   # Theme configuration
│   └── app_theme.dart
│
└── admin/                   # Admin functionality
    ├── admin_login_screen.dart
    ├── admin_home_screen.dart
    └── ...
```

## 🎯 Coding Standards

### 1. File Organization

#### Import Order
```dart
// 1. Dart/Flutter packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 2. Third-party packages
import 'package:flutter_easyloading/flutter_easyloading.dart';

// 3. App imports - grouped by type
import '../models/booking.dart';
import '../models/service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
```

#### Class Structure
```dart
class MyScreen extends StatefulWidget {
  // 1. Constructor parameters
  final String title;
  final Function? onCallback;

  // 2. Constructor
  const MyScreen({
    super.key,
    required this.title,
    this.onCallback,
  });

  // 3. createState
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // 1. Services (final)
  final AuthService _authService = AuthService();
  
  // 2. Controllers
  final TextEditingController _controller = TextEditingController();
  
  // 3. State variables
  bool _isLoading = false;
  String? _selectedValue;
  
  // 4. Animation controllers
  late AnimationController _animationController;
  
  // 5. Lifecycle methods
  @override
  void initState() {
    super.initState();
    // Initialization logic
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  // 6. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
  
  // 7. Helper methods (private)
  Widget _buildHeader() {...}
  
  // 8. Event handlers (private)
  Future<void> _handleSubmit() async {...}
}
```

### 2. Naming Conventions

#### Variables & Methods
```dart
// ✅ Good
final TextEditingController _emailController;
bool _isLoading = false;
Future<void> _handleLogin() async {...}

// ❌ Bad
final TextEditingController emailCtrl;
bool loading = false;
Future<void> login() async {...}
```

#### Classes
```dart
// ✅ Good - PascalCase
class UserProfile {}
class PaymentScreen extends StatefulWidget {}

// ❌ Bad
class userProfile {}
class payment_screen extends StatefulWidget {}
```

#### Constants
```dart
// ✅ Good
static const Color kPrimaryColor = Color(0xFF0891B2);
static const double kDefaultPadding = 16.0;

// ❌ Bad
final Color primaryColor = Color(0xFF0891B2);
double padding = 16.0;
```

### 3. Widget Best Practices

#### Use Const Constructors
```dart
// ✅ Good
const SizedBox(height: 20)
const Text('Hello')
const Icon(Icons.home)

// ❌ Bad
SizedBox(height: 20)
Text('Hello')
Icon(Icons.home)
```

#### Extract Widgets
```dart
// ✅ Good - Extracted widget
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(...);
  }
}

// Use in main widget
Widget build(BuildContext context) {
  return Column(
    children: [
      _HeaderSection(),
      // other widgets
    ],
  );
}

// ❌ Bad - Everything in build()
Widget build(BuildContext context) {
  return Column(
    children: [
      Container(...), // 50 lines of header code
      Container(...), // More nested widgets
    ],
  );
}
```

#### Method Extraction
```dart
// ✅ Good
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(),
      _buildBody(),
      _buildFooter(),
    ],
  );
}

Widget _buildHeader() => Container(...);
Widget _buildBody() => ListView(...);
Widget _buildFooter() => Row(...);
```

### 4. State Management

#### Loading States
```dart
// ✅ Good
Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    await _service.submit(_data);
    if (!mounted) return;
    
    // Show success
    ScaffoldMessenger.of(context).showSnackBar(...);
  } catch (e) {
    if (!mounted) return;
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(...);
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

#### Check Mounted Before setState
```dart
// ✅ Good
if (!mounted) return;
setState(() => _data = newData);

// ❌ Bad
setState(() => _data = newData); // Can cause errors if widget unmounted
```

### 5. Error Handling

#### Try-Catch Pattern
```dart
// ✅ Good
try {
  final result = await _service.fetchData();
  if (!mounted) return;
  
  setState(() => _data = result);
} on FirebaseException catch (e) {
  // Handle specific Firebase errors
  debugPrint('Firebase error: ${e.code}');
  if (!mounted) return;
  _showError('Lỗi kết nối: ${e.message}');
} catch (e) {
  // Handle general errors
  debugPrint('Error: $e');
  if (!mounted) return;
  _showError('Đã có lỗi xảy ra');
}
```

#### User-Friendly Messages
```dart
// ✅ Good
void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
```

### 6. Navigation

#### Clean Navigation
```dart
// ✅ Good - Named routes
Navigator.pushNamed(context, '/profile');

// ✅ Good - With data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DetailScreen(data: item),
  ),
);

// ✅ Good - Replace (no back)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => HomeScreen()),
);

// ✅ Good - Pop with result
final result = await Navigator.push<bool>(...);
if (result == true) {
  // Handle result
}
```

### 7. Forms & Validation

#### Form Pattern
```dart
class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    // Process form
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
```

### 8. Animations

#### Basic Animation Pattern
```dart
class _AnimatedScreenState extends State<AnimatedScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: YourWidget(),
    );
  }
}
```

## 🎨 UI/UX Best Practices

### 1. Consistent Spacing
```dart
// Use consistent spacing constants
static const double kSmallPadding = 8.0;
static const double kMediumPadding = 16.0;
static const double kLargePadding = 24.0;

// Apply consistently
Padding(
  padding: EdgeInsets.all(kMediumPadding),
  child: ...
)
```

### 2. Responsive Design
```dart
// ✅ Good - Use MediaQuery
final screenWidth = MediaQuery.of(context).size.width;
final isSmallScreen = screenWidth < 600;

// Adapt UI
Container(
  width: isSmallScreen ? screenWidth * 0.9 : 400,
  child: ...
)
```

### 3. Theme Usage
```dart
// ✅ Good - Use theme colors
Text(
  'Hello',
  style: Theme.of(context).textTheme.headlineMedium,
)

Container(
  color: Theme.of(context).primaryColor,
)

// ❌ Bad - Hard-coded colors
Text(
  'Hello',
  style: TextStyle(fontSize: 24, color: Colors.black),
)
```

## 🔐 Security Best Practices

### 1. Input Validation
```dart
// Always validate user input
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email là bắt buộc';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Email không hợp lệ';
  }
  return null;
}
```

### 2. Secure Data Handling
```dart
// ✅ Good - Trim inputs
final email = _emailController.text.trim();
final password = _passwordController.text; // Don't trim passwords

// ✅ Good - Check authentication
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  Navigator.pushReplacementNamed(context, '/login');
  return;
}
```

## 📱 Firebase Integration

### 1. Firestore Queries
```dart
// ✅ Good - Use StreamBuilder
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('bookings')
      .where('userId', isEqualTo: userId)
      .orderBy('dateTime', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return ErrorWidget(snapshot.error.toString());
    }
    
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingWidget();
    }
    
    final bookings = snapshot.data!.docs
        .map((doc) => Booking.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) => BookingCard(booking: bookings[index]),
    );
  },
)
```

### 2. Error Handling
```dart
try {
  await _authService.signIn(email, password);
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'user-not-found':
      _showError('Không tìm thấy người dùng');
      break;
    case 'wrong-password':
      _showError('Mật khẩu không đúng');
      break;
    default:
      _showError('Lỗi đăng nhập: ${e.message}');
  }
} catch (e) {
  _showError('Đã có lỗi xảy ra');
}
```

## 🧪 Testing Guidelines

### 1. Widget Tests
```dart
testWidgets('Login button should be disabled when loading', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Find button
  final button = find.byType(ElevatedButton);
  expect(button, findsOneWidget);
  
  // Verify initial state
  expect(tester.widget<ElevatedButton>(button).enabled, isTrue);
});
```

### 2. Unit Tests
```dart
test('Email validation should return error for invalid email', () {
  final validator = EmailValidator();
  expect(validator.validate('invalid'), isNotNull);
  expect(validator.validate('test@test.com'), isNull);
});
```

## 📝 Documentation

### 1. Code Comments
```dart
// ✅ Good - Explain complex logic
/// Calculates the total price including tax and discount.
/// 
/// [basePrice] is the original price before adjustments
/// [taxRate] is the tax percentage (e.g., 0.1 for 10%)
/// [discountCode] is optional and applies a percentage discount
/// 
/// Returns the final price after all calculations
double calculateFinalPrice(
  double basePrice,
  double taxRate,
  String? discountCode,
) {
  // Implementation
}
```

### 2. TODO Comments
```dart
// TODO(username): Implement pagination for better performance
// FIXME: Handle edge case when date is null
// NOTE: This is a temporary solution until API v2 is ready
```

## 🚀 Performance Tips

### 1. Lazy Loading
```dart
// ✅ Good - Load data when needed
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(items[index]),
)

// ❌ Bad - Load everything at once
ListView(
  children: items.map((item) => ItemCard(item)).toList(),
)
```

### 2. Use const
```dart
// ✅ Good
const Text('Static text')
const SizedBox(height: 20)

// Reuse const widgets
static const Widget _divider = Divider(height: 1);
```

### 3. Avoid Rebuilds
```dart
// ✅ Good - Extract to separate widget
class _StaticHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(...);
  }
}

// Use in parent
Widget build(BuildContext context) {
  return Column(
    children: [
      const _StaticHeader(), // Won't rebuild
      _DynamicContent(), // Only this rebuilds
    ],
  );
}
```

---

**Remember:** 
- Write clean, readable code
- Comment complex logic
- Test your changes
- Follow Flutter/Dart conventions
- Keep files under 500 lines when possible
- Extract reusable components
- Handle errors gracefully
- Think about the user experience

**Happy Coding! 🎉**
