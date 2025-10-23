# 🚀 Provider Quick Reference Card

## 📦 Available Providers

```dart
AuthProvider          // Quản lý authentication & user
ServicesProvider      // Quản lý services, stylists, branches
BookingProvider       // Quản lý bookings
FavoritesProvider     // Quản lý favorites
```

---

## 🎯 Common Patterns

### 1. Sử dụng Provider cho UI (Auto-rebuild)

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    final user = authProvider.user;
    return Text(user?.displayName ?? 'Guest');
  },
)
```

### 2. Sử dụng Provider cho Actions (No rebuild)

```dart
// Trong async function
await context.read<AuthProvider>().signOut();

// Trong button onPressed
ElevatedButton(
  onPressed: () => context.read<AuthProvider>().signOut(),
  child: Text('Logout'),
)
```

### 3. Load Data trong initState

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<ServicesProvider>().loadServices();
  });
}
```

### 4. Check Loading State

```dart
Consumer<ServicesProvider>(
  builder: (context, provider, child) {
    if (provider.isLoadingServices) {
      return CircularProgressIndicator();
    }
    return ListView.builder(...);
  },
)
```

### 5. Handle Errors

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.errorMessage != null) {
      return Text('Error: ${authProvider.errorMessage}');
    }
    // Normal UI
  },
)
```

---

## 📋 AuthProvider Methods

```dart
// Login
await context.read<AuthProvider>().signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

await context.read<AuthProvider>().signInWithGoogle();

// Register
await context.read<AuthProvider>().signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
  username: 'John Doe',
);

// Logout
await context.read<AuthProvider>().signOut();

// Reset Password
await context.read<AuthProvider>().resetPassword(
  email: 'user@example.com',
);

// Update Profile
await context.read<AuthProvider>().updateProfile(
  displayName: 'New Name',
  photoURL: 'https://...',
);

// Get current user
final user = context.watch<AuthProvider>().user;
final isLoggedIn = context.watch<AuthProvider>().isAuthenticated;
```

---

## 📋 ServicesProvider Methods

```dart
// Load services
await context.read<ServicesProvider>().loadServices();

// Load stylists
await context.read<ServicesProvider>().loadStylists();

// Load branches
await context.read<ServicesProvider>().loadBranches();

// Get data
final services = context.watch<ServicesProvider>().services;
final stylists = context.watch<ServicesProvider>().stylists;
final branches = context.watch<ServicesProvider>().branches;

// Check loading
final isLoading = context.watch<ServicesProvider>().isLoadingServices;
```

---

## 📋 BookingProvider Methods

```dart
// Create booking
await context.read<BookingProvider>().createBooking(booking);

// Load user bookings
await context.read<BookingProvider>().loadUserBookings();

// Cancel booking
await context.read<BookingProvider>().cancelBooking(bookingId);

// Get bookings
final bookings = context.watch<BookingProvider>().bookings;

// Filter by status
final pending = context.watch<BookingProvider>().pendingBookings;
final confirmed = context.watch<BookingProvider>().confirmedBookings;
final completed = context.watch<BookingProvider>().completedBookings;
```

---

## 📋 FavoritesProvider Methods

```dart
// Load favorites
await context.read<FavoritesProvider>().loadFavorites();

// Toggle favorite
await context.read<FavoritesProvider>().toggleFavorite(serviceId);

// Check if favorite
final isFav = context.watch<FavoritesProvider>().isFavorite(serviceId);

// Get favorite IDs
final favIds = context.watch<FavoritesProvider>().favoriteIds;

// Stream favorites
StreamBuilder(
  stream: context.read<FavoritesProvider>().getFavoriteServicesStream(),
  builder: (context, snapshot) {
    // Build UI
  },
)
```

---

## 🔄 context.read() vs context.watch()

### Use `context.read<T>()` when:
- ✅ Calling methods (actions)
- ✅ One-time data access
- ✅ Inside callbacks (onPressed, async functions)
- ✅ Don't need to rebuild when data changes

```dart
// ✅ GOOD
ElevatedButton(
  onPressed: () => context.read<AuthProvider>().signOut(),
  child: Text('Logout'),
)
```

### Use `context.watch<T>()` when:
- ✅ Need to rebuild when data changes
- ✅ Inside build method
- ✅ Accessing data for display

```dart
// ✅ GOOD
@override
Widget build(BuildContext context) {
  final user = context.watch<AuthProvider>().user;
  return Text(user?.displayName ?? 'Guest');
}
```

### Use `Consumer<T>` when:
- ✅ Need fine-grained rebuild control
- ✅ Part of widget tree needs to rebuild
- ✅ Want to optimize performance

```dart
// ✅ GOOD - Only rebuilds Text, not entire Column
Column(
  children: [
    ExpensiveWidget(), // Won't rebuild
    Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Text(auth.user?.displayName ?? 'Guest'); // Will rebuild
      },
    ),
  ],
)
```

---

## ⚠️ Common Mistakes

### ❌ DON'T use context.watch() in callbacks

```dart
// ❌ BAD
ElevatedButton(
  onPressed: () {
    context.watch<AuthProvider>().signOut(); // ❌ ERROR
  },
  child: Text('Logout'),
)

// ✅ GOOD
ElevatedButton(
  onPressed: () {
    context.read<AuthProvider>().signOut(); // ✅ OK
  },
  child: Text('Logout'),
)
```

### ❌ DON'T call context.read() in build for display

```dart
// ❌ BAD - Won't rebuild when user changes
@override
Widget build(BuildContext context) {
  final user = context.read<AuthProvider>().user; // ❌ Won't update
  return Text(user?.displayName ?? 'Guest');
}

// ✅ GOOD
@override
Widget build(BuildContext context) {
  final user = context.watch<AuthProvider>().user; // ✅ Will update
  return Text(user?.displayName ?? 'Guest');
}
```

### ❌ DON'T wrap entire build with Consumer if not needed

```dart
// ❌ BAD - Rebuilds entire screen
@override
Widget build(BuildContext context) {
  return Consumer<AuthProvider>(
    builder: (context, auth, child) {
      return Scaffold(
        appBar: AppBar(...),
        body: Column(
          children: [
            ExpensiveWidget1(),
            ExpensiveWidget2(),
            Text(auth.user?.displayName ?? 'Guest'), // Only this needs auth
          ],
        ),
      );
    },
  );
}

// ✅ GOOD - Only rebuilds Text
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(...),
    body: Column(
      children: [
        ExpensiveWidget1(),
        ExpensiveWidget2(),
        Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return Text(auth.user?.displayName ?? 'Guest');
          },
        ),
      ],
    ),
  );
}
```

---

## 🎯 Best Practices

1. **Load data once in initState**
   ```dart
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<ServicesProvider>().loadServices();
     });
   }
   ```

2. **Check loading state before displaying data**
   ```dart
   if (provider.isLoadingServices) {
     return CircularProgressIndicator();
   }
   ```

3. **Handle errors gracefully**
   ```dart
   if (provider.errorMessage != null) {
     return ErrorWidget(provider.errorMessage!);
   }
   ```

4. **Use Consumer for fine-grained control**
   ```dart
   Consumer<AuthProvider>(
     builder: (context, auth, child) {
       // Only this part rebuilds
     },
   )
   ```

5. **Clear providers on logout**
   ```dart
   await context.read<AuthProvider>().signOut();
   context.read<BookingProvider>().clearBookings();
   context.read<FavoritesProvider>().clearFavorites();
   ```

---

## 📖 More Resources

- [PROVIDER_INTEGRATION_GUIDE.md](./PROVIDER_INTEGRATION_GUIDE.md) - Full guide
- [PROVIDER_MIGRATION_SUMMARY.md](./PROVIDER_MIGRATION_SUMMARY.md) - Migration details
- [PROVIDER_MIGRATION_COMPLETE.md](./PROVIDER_MIGRATION_COMPLETE.md) - Completion summary
- [lib/examples/provider_usage_examples.dart](./lib/examples/provider_usage_examples.dart) - Code examples

---

**Quick tip:** Print this card and keep it near your desk! 📌
