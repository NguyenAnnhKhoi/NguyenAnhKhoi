# 📦 Provider Integration Guide

## 🎯 Overview

Provider đã được tích hợp hoàn toàn vào dự án để quản lý state hiệu quả hơn!

---

## 📁 Provider Structure

```
lib/providers/
├── auth_provider.dart          # Quản lý authentication state
├── booking_provider.dart       # Quản lý booking flow state
├── services_provider.dart      # Quản lý services, stylists, branches
└── favorites_provider.dart     # Quản lý favorite services
```

---

## 🔧 Providers Created

### 1. **AuthProvider** (`auth_provider.dart`)

**Purpose:** Quản lý trạng thái authentication

**Features:**
- ✅ Listen to auth state changes
- ✅ Sign in with email/password
- ✅ Sign up with email/password
- ✅ Sign in with Google
- ✅ Send password reset email
- ✅ Sign out
- ✅ Loading states
- ✅ Error handling

**Usage Example:**
```dart
// Get provider
final authProvider = Provider.of<AuthProvider>(context);

// Sign in
await authProvider.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Check auth status
if (authProvider.isAuthenticated) {
  // User is logged in
}

// Access current user
final user = authProvider.user;

// Sign out
await authProvider.signOut();
```

**Properties:**
- `User? user` - Current user
- `bool isLoading` - Loading state
- `String? errorMessage` - Error message
- `bool isAuthenticated` - Auth status

---

### 2. **BookingProvider** (`booking_provider.dart`)

**Purpose:** Quản lý toàn bộ booking flow

**Features:**
- ✅ Select service, stylist, branch
- ✅ Select date and time
- ✅ Set payment method and note
- ✅ Create booking
- ✅ Get user bookings stream
- ✅ Cancel booking
- ✅ Validation
- ✅ Auto-reset after booking

**Usage Example:**
```dart
// Get provider
final bookingProvider = Provider.of<BookingProvider>(context);

// Set booking details
bookingProvider.setService(selectedService);
bookingProvider.setStylist(selectedStylist);
bookingProvider.setBranch(selectedBranch);
bookingProvider.setDate(DateTime.now());
bookingProvider.setTime('10:00');
bookingProvider.setPaymentMethod('Online');

// Check if ready
if (bookingProvider.isBookingComplete) {
  // Create booking
  final success = await bookingProvider.createBooking(
    customerName: 'John Doe',
    customerPhone: '0123456789',
  );
}

// Get bookings stream
Stream<List<Booking>> bookings = bookingProvider.getUserBookings();

// Reset after completion
bookingProvider.resetBooking();
```

**Properties:**
- `Service? selectedService`
- `Stylist? selectedStylist`
- `Branch? selectedBranch`
- `DateTime? selectedDate`
- `String? selectedTime`
- `String paymentMethod`
- `String note`
- `bool isBookingComplete`
- `double totalPrice`

---

### 3. **ServicesProvider** (`services_provider.dart`)

**Purpose:** Quản lý danh sách services, stylists, branches

**Features:**
- ✅ Load all services, stylists, branches
- ✅ Cache data locally
- ✅ Search functionality
- ✅ Get by ID
- ✅ Get top rated items
- ✅ Auto-load on app start

**Usage Example:**
```dart
// Get provider (auto-loaded on app start)
final servicesProvider = Provider.of<ServicesProvider>(context);

// Access data
List<Service> services = servicesProvider.services;
List<Stylist> stylists = servicesProvider.stylists;
List<Branch> branches = servicesProvider.branches;

// Search
List<Service> results = servicesProvider.searchServices('cắt tóc');

// Get by ID
Service? service = servicesProvider.getServiceById('service123');

// Get top rated
List<Service> topServices = servicesProvider.getTopRatedServices(limit: 5);

// Reload data
await servicesProvider.loadAllData();
```

**Properties:**
- `List<Service> services`
- `List<Stylist> stylists`
- `List<Branch> branches`
- `bool isLoadingServices`
- `bool isLoadingStylists`
- `bool isLoadingBranches`

---

### 4. **FavoritesProvider** (`favorites_provider.dart`)

**Purpose:** Quản lý favorite services

**Features:**
- ✅ Toggle favorite status
- ✅ Check if service is favorite
- ✅ Get favorites stream
- ✅ Auto-sync with Firestore
- ✅ Clear on logout

**Usage Example:**
```dart
// Get provider
final favoritesProvider = Provider.of<FavoritesProvider>(context);

// Check if favorite
bool isFav = favoritesProvider.isFavorite('service123');

// Toggle favorite
await favoritesProvider.toggleFavorite('service123');

// Get favorites stream
Stream<List<Service>> favorites = favoritesProvider.getFavoriteServicesStream();

// Load favorites
await favoritesProvider.loadFavorites();
```

**Properties:**
- `Set<String> favoriteIds`
- `bool isLoading`
- `String? errorMessage`

---

## 🚀 Integration in main.dart

```dart
@override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      // Auth Provider
      ChangeNotifierProvider(create: (_) => app_provider.AuthProvider()),
      
      // Services Provider (auto-load data)
      ChangeNotifierProvider(
        create: (_) => ServicesProvider()..loadAllData(),
      ),
      
      // Booking Provider
      ChangeNotifierProvider(create: (_) => BookingProvider()),
      
      // Favorites Provider
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
    ],
    child: MaterialApp(
      // ...app config
    ),
  );
}
```

---

## 📝 How to Use in Screens

### Method 1: Provider.of (Simple)

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get provider
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Use data
    return Text('User: ${authProvider.user?.displayName}');
  }
}
```

### Method 2: Consumer (Recommended)

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return CircularProgressIndicator();
        }
        
        return Text('User: ${authProvider.user?.displayName}');
      },
    );
  }
}
```

### Method 3: Selector (Performance)

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, bool>(
      selector: (_, provider) => provider.isAuthenticated,
      builder: (context, isAuthenticated, child) {
        return Text(isAuthenticated ? 'Logged In' : 'Logged Out');
      },
    );
  }
}
```

### Method 4: context.read/watch (Simple & Clean)

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch for changes (rebuilds on change)
    final authProvider = context.watch<AuthProvider>();
    
    // Read once (no rebuild)
    // final authProvider = context.read<AuthProvider>();
    
    return Text('User: ${authProvider.user?.displayName}');
  }
}
```

---

## 🎯 Best Practices

### 1. **Use `listen: false` for Actions**

```dart
// ❌ Wrong (will rebuild on every change)
onPressed: () {
  Provider.of<BookingProvider>(context).resetBooking();
}

// ✅ Correct (no rebuild)
onPressed: () {
  Provider.of<BookingProvider>(context, listen: false).resetBooking();
}

// ✅ Or use context.read
onPressed: () {
  context.read<BookingProvider>().resetBooking();
}
```

### 2. **Use Consumer for Specific Parts**

```dart
// ✅ Only rebuild price widget when price changes
Consumer<BookingProvider>(
  builder: (context, provider, _) {
    return Text('Total: ${provider.totalPrice}đ');
  },
)
```

### 3. **Use Selector for Single Properties**

```dart
// ✅ Only rebuild when isLoading changes
Selector<AuthProvider, bool>(
  selector: (_, provider) => provider.isLoading,
  builder: (_, isLoading, __) {
    return isLoading ? LoadingWidget() : ContentWidget();
  },
)
```

### 4. **Handle Errors Gracefully**

```dart
Consumer<AuthProvider>(
  builder: (context, provider, _) {
    if (provider.errorMessage != null) {
      // Show error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
        provider.clearError();
      });
    }
    
    return YourWidget();
  },
)
```

---

## 🔄 Migration Guide

### Before (Without Provider)

```dart
class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Service? selectedService;
  Stylist? selectedStylist;
  bool isLoading = false;
  
  void selectService(Service service) {
    setState(() {
      selectedService = service;
    });
  }
  
  Future<void> createBooking() async {
    setState(() => isLoading = true);
    // ... booking logic
    setState(() => isLoading = false);
  }
}
```

### After (With Provider)

```dart
class BookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            ServiceSelector(
              onSelect: provider.setService,
            ),
            StylistSelector(
              onSelect: provider.setStylist,
            ),
            if (provider.isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  await provider.createBooking(
                    customerName: 'John',
                    customerPhone: '0123456789',
                  );
                },
                child: Text('Book Now'),
              ),
          ],
        );
      },
    );
  }
}
```

---

## 📊 Benefits

### ✅ **Centralized State Management**
- Tất cả state ở một nơi
- Dễ debug và maintain

### ✅ **Separation of Concerns**
- UI code tách biệt với business logic
- Provider handles logic, Widget handles UI

### ✅ **Performance**
- Chỉ rebuild widgets cần thiết
- Selector và Consumer giúp optimize

### ✅ **Code Reusability**
- Logic được reuse across screens
- Không cần duplicate code

### ✅ **Easy Testing**
- Provider có thể test độc lập
- Mock providers cho unit tests

### ✅ **Type Safety**
- TypeScript-like type safety
- Less runtime errors

---

## 🐛 Common Issues & Solutions

### Issue 1: "Could not find the correct Provider"

**Solution:**
```dart
// Make sure MultiProvider wraps MaterialApp
return MultiProvider(
  providers: [...],
  child: MaterialApp(...),
);
```

### Issue 2: "Tried to listen to a value exposed with provider, from outside of the widget tree"

**Solution:**
```dart
// Use context.read() for actions in callbacks
onPressed: () {
  context.read<BookingProvider>().resetBooking();
}
```

### Issue 3: "Unnecessary rebuilds"

**Solution:**
```dart
// Use Selector or Consumer instead of Provider.of
Selector<BookingProvider, Service?>(
  selector: (_, p) => p.selectedService,
  builder: (_, service, __) => ServiceWidget(service),
)
```

---

## 🎓 Learning Resources

- [Provider Official Docs](https://pub.dev/packages/provider)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [Provider Pattern](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)

---

## ✅ Next Steps

1. **Test providers** - Verify all providers work correctly
2. **Migrate screens** - Update existing screens to use providers
3. **Add more features** - Extend providers as needed
4. **Write tests** - Add unit tests for providers

---

**🎉 Provider integration complete! Your app now has professional state management!**
