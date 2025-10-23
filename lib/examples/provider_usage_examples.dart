// lib/examples/provider_usage_examples.dart
// 📝 File này chứa các ví dụ sử dụng Provider
// Không dùng trong production, chỉ để tham khảo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_provider;
import '../providers/booking_provider.dart';
import '../providers/services_provider.dart';
import '../providers/favorites_provider.dart';

/// ============================================
/// EXAMPLE 1: Auth Provider Usage
/// ============================================

class AuthProviderExample extends StatelessWidget {
  const AuthProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Provider Example')),
      body: Consumer<app_provider.AuthProvider>(
        builder: (context, authProvider, child) {
          // Show loading
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error
          if (authProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${authProvider.errorMessage}'),
                  ElevatedButton(
                    onPressed: authProvider.clearError,
                    child: const Text('Clear Error'),
                  ),
                ],
              ),
            );
          }

          // Show auth status
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display user info
                if (authProvider.isAuthenticated) ...[
                  Text('Welcome, ${authProvider.user?.displayName ?? "User"}!'),
                  Text('Email: ${authProvider.user?.email}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await authProvider.signOut();
                    },
                    child: const Text('Sign Out'),
                  ),
                ] else ...[
                  const Text('Not logged in'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Example sign in
                      await authProvider.signInWithEmail(
                        email: 'test@example.com',
                        password: 'password123',
                      );
                    },
                    child: const Text('Sign In'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ============================================
/// EXAMPLE 2: Booking Provider Usage
/// ============================================

class BookingProviderExample extends StatelessWidget {
  const BookingProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Provider Example')),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show selected items
                Text('Selected Service: ${bookingProvider.selectedService?.name ?? "None"}'),
                Text('Selected Stylist: ${bookingProvider.selectedStylist?.name ?? "None"}'),
                Text('Selected Branch: ${bookingProvider.selectedBranch?.name ?? "None"}'),
                Text('Selected Date: ${bookingProvider.selectedDate?.toString() ?? "None"}'),
                Text('Selected Time: ${bookingProvider.selectedTime ?? "None"}'),
                Text('Payment Method: ${bookingProvider.paymentMethod}'),
                const SizedBox(height: 20),

                // Show booking status
                Text(
                  'Booking Complete: ${bookingProvider.isBookingComplete}',
                  style: TextStyle(
                    color: bookingProvider.isBookingComplete ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Total Price: ${bookingProvider.totalPrice}đ'),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: bookingProvider.isBookingComplete
                          ? () async {
                              final success = await bookingProvider.createBooking(
                                customerName: 'John Doe',
                                customerPhone: '0123456789',
                              );
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Booking created!' : 'Failed to create booking'),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: const Text('Create Booking'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        bookingProvider.resetBooking();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),

                // Loading indicator
                if (bookingProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // Error message
                if (bookingProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Error: ${bookingProvider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ============================================
/// EXAMPLE 3: Services Provider Usage
/// ============================================

class ServicesProviderExample extends StatelessWidget {
  const ServicesProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services Provider Example')),
      body: Consumer<ServicesProvider>(
        builder: (context, servicesProvider, child) {
          // Show loading
          if (servicesProvider.isLoadingServices ||
              servicesProvider.isLoadingStylists ||
              servicesProvider.isLoadingBranches) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Services count
                Text(
                  'Services: ${servicesProvider.services.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                // List services
                ...servicesProvider.services.take(3).map((service) => ListTile(
                  title: Text(service.name),
                  subtitle: Text('${service.price}đ'),
                  trailing: Text('⭐ ${service.rating}'),
                )),
                const Divider(),

                // Stylists count
                Text(
                  'Stylists: ${servicesProvider.stylists.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // List stylists
                ...servicesProvider.stylists.take(3).map((stylist) => ListTile(
                  title: Text(stylist.name),
                  subtitle: Text(stylist.experience),
                  trailing: Text('⭐ ${stylist.rating}'),
                )),
                const Divider(),

                // Branches count
                Text(
                  'Branches: ${servicesProvider.branches.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // List branches
                ...servicesProvider.branches.take(3).map((branch) => ListTile(
                  title: Text(branch.name),
                  subtitle: Text(branch.address),
                )),
                const SizedBox(height: 20),

                // Search example
                ElevatedButton(
                  onPressed: () {
                    final results = servicesProvider.searchServices('cắt');
                    debugPrint('Found ${results.length} services');
                  },
                  child: const Text('Search "cắt"'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ============================================
/// EXAMPLE 4: Favorites Provider Usage
/// ============================================

class FavoritesProviderExample extends StatelessWidget {
  const FavoritesProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites Provider Example')),
      body: Consumer2<FavoritesProvider, ServicesProvider>(
        builder: (context, favoritesProvider, servicesProvider, child) {
          return ListView.builder(
            itemCount: servicesProvider.services.length,
            itemBuilder: (context, index) {
              final service = servicesProvider.services[index];
              final isFavorite = favoritesProvider.isFavorite(service.id);

              return ListTile(
                title: Text(service.name),
                subtitle: Text('${service.price}đ'),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () async {
                    await favoritesProvider.toggleFavorite(service.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ============================================
/// EXAMPLE 5: Using context.read and context.watch
/// ============================================

class ContextExtensionExample extends StatelessWidget {
  const ContextExtensionExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes (rebuilds when data changes)
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Context Extension Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total: ${bookingProvider.totalPrice}đ'),
            const SizedBox(height: 20),
            
            // Use context.read for actions (no rebuild)
            ElevatedButton(
              onPressed: () {
                // ✅ Correct: use context.read for actions
                context.read<BookingProvider>().resetBooking();
              },
              child: const Text('Reset Booking'),
            ),
            
            ElevatedButton(
              onPressed: () {
                // ✅ Correct: use context.read for one-time access
                final provider = context.read<BookingProvider>();
                debugPrint('Payment method: ${provider.paymentMethod}');
              },
              child: const Text('Log Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// EXAMPLE 6: Using Selector for Performance
/// ============================================

class SelectorExample extends StatelessWidget {
  const SelectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selector Example')),
      body: Column(
        children: [
          // Only rebuilds when isAuthenticated changes
          Selector<app_provider.AuthProvider, bool>(
            selector: (_, provider) => provider.isAuthenticated,
            builder: (_, isAuthenticated, __) {
              return Text(
                isAuthenticated ? 'Logged In' : 'Logged Out',
                style: const TextStyle(fontSize: 24),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Only rebuilds when totalPrice changes
          Selector<BookingProvider, double>(
            selector: (_, provider) => provider.totalPrice,
            builder: (_, totalPrice, __) {
              return Text(
                'Total: ${totalPrice}đ',
                style: const TextStyle(fontSize: 24),
              );
            },
          ),
        ],
      ),
    );
  }
}
