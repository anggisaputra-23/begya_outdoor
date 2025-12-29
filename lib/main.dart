import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/wishlist_repository_impl.dart';
import 'data/datasources/supabase_datasource.dart';
import 'providers/providers.dart';
import 'routes/app_router.dart';

/// 🚀 ENTRY POINT APLIKASI BEGYA OUTDOOR
///
/// Fungsi main():
/// 1. Inisialisasi Flutter bindings
/// 2. Setup Supabase backend
/// 3. Setup SharedPreferences untuk local storage
/// 4. Run aplikasi dengan MultiProvider
void main() async {
  // ✅ Pastikan Flutter binding sudah siap sebelum async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 🔌 INISIALISASI SUPABASE
  // Menghubungkan ke backend Supabase untuk database & authentication
  try {
    await SupabaseService().initialize();
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize Supabase: $e');
  }

  // 💾 INISIALISASI SHARED PREFERENCES
  // Digunakan untuk menyimpan wishlist secara lokal di device
  final prefs = await SharedPreferences.getInstance();

  // 🎯 Jalankan aplikasi dengan penyediaan semua providers
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // 🔧 SETUP LAYANAN & REPOSITORY
    // Menginisialisasi semua layanan yang dibutuhkan untuk akses data
    final supabaseService = SupabaseService();
    final supabaseDatasource = SupabaseDataSource(supabaseService);

    // Repository - Menangani business logic dan komunikasi dengan database
    final authRepository = AuthRepositoryImpl(supabaseDatasource);
    final productRepository = ProductRepositoryImpl(supabaseDatasource);
    final cartRepository = CartRepositoryImpl();
    final orderRepository = OrderRepositoryImpl(supabaseDatasource);
    final wishlistRepository = WishlistRepositoryImpl(prefs);

    return MultiProvider(
      // 📱 PROVIDER STACK - State management untuk seluruh aplikasi
      // Setiap provider bertanggung jawab untuk state management satu feature
      providers: [
        // 🔐 AUTH PROVIDER - Mengelola login/register/user state
        ChangeNotifierProvider(create: (_) => AuthNotifier(authRepository)),

        // 📦 PRODUCT PROVIDER - Mengelola produk, kategori, search
        ChangeNotifierProvider(
          create: (_) => ProductNotifier(productRepository),
        ),

        // 🛒 CART PROVIDER - Mengelola keranjang belanja
        ChangeNotifierProvider(create: (_) => CartNotifier(cartRepository)),

        // 📋 ORDER PROVIDER - Mengelola pesanan
        ChangeNotifierProvider(create: (_) => OrderNotifier(orderRepository)),

        // ❤️ WISHLIST PROVIDER - Mengelola daftar ingin dibeli
        ChangeNotifierProvider(
          create: (_) => WishlistNotifier(wishlistRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'Begya Outdoor',
        // 🎨 THEME SETUP
        theme: AppTheme.lightTheme, // Light mode theme
        darkTheme: AppTheme.darkTheme, // Dark mode theme
        themeMode: ThemeMode.light, // Gunakan light mode sebagai default
        // 🐛 DEBUG
        debugShowCheckedModeBanner: false,

        // 🗺️ ROUTING SETUP
        // GoRouter menangani navigasi dengan deep linking support
        routerConfig: appRouter,
      ),
    );
  }
}
