import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/product/product_detail_screen.dart';
import '../presentation/cart/cart_screen.dart';
import '../presentation/wishlist/wishlist_screen.dart';
import '../presentation/checkout/checkout_screen.dart';
import '../presentation/order/order_history_screen.dart';
import '../presentation/order/order_detail_screen.dart';
import '../presentation/owner/owner_dashboard_screen.dart';
import '../presentation/owner/product_management_screen.dart';
import '../presentation/owner/add_product_screen.dart';
import '../providers/auth_notifier.dart';

/// 🗺️ APP ROUTER - Konfigurasi navigasi aplikasi
///
/// Menggunakan GoRouter untuk:
/// - Navigation dengan deep linking support
/// - Route guards (redirect based on auth status & role)
/// - Named routes untuk navigation yang clean
/// - Parameter passing (product id, order id, dll)
///
/// Flow:
/// 1. User start app → splash screen
/// 2. Check auth status via redirect()
/// 3. Jika belum login → login/register screen
/// 4. Jika sudah login:
///    - Role 'customer' → home screen (customer features)
///    - Role 'owner' → owner dashboard (management features)
///
/// Fitur:
/// - Automatic logout redirect ke login
/// - Parameterized routes (/product/:id, /order/:id, dll)
/// - Nested routing untuk bottom navigation
final GoRouter appRouter = GoRouter(
  // 🏠 INITIAL LOCATION - Route pertama saat app dibuka
  initialLocation: '/splash',

  /// 🔐 REDIRECT LOGIC - Guard untuk handle navigasi based on auth & role
  ///
  /// Panggil otomatis sebelum navigasi ke route
  ///
  /// Logic:
  /// 1. Ambil auth state dari AuthNotifier
  /// 2. Cek apakah user sudah login (isAuthenticated)
  /// 3. Cek route tujuan (state.matchedLocation)
  /// 4. Apply rules:
  ///    - Jika belum login & bukan di splash/login/register → redirect ke login
  ///    - Jika sudah login & menuju login/register → redirect ke home atau owner dashboard
  ///    - Selain itu: allow navigasi (return null = no redirect)
  ///
  /// Return: null = allow navigasi, string = redirect ke route itu
  redirect: (context, state) {
    final authNotifier = context.read<AuthNotifier>();
    final isLoggedIn = authNotifier.isAuthenticated;
    final isGoingToSplash = state.matchedLocation == '/splash';
    final isGoingToAuth =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // ❌ NOT LOGGED IN - Arahkan ke login jika belum login
    if (!isLoggedIn && !isGoingToSplash && !isGoingToAuth) {
      return '/login';
    }

    // ✅ LOGGED IN - Jika sudah login & mencoba ke auth screen, redirect ke home
    if (isLoggedIn && isGoingToAuth) {
      final userRole = authNotifier.currentUser?.role;
      // Role-based redirect: owner ke dashboard, customer ke home
      return userRole == 'owner' ? '/owner-dashboard' : '/home';
    }

    // 🔄 ALLOW NAVIGATION - Tidak ada kondisi yang match, allow navigasi
    return null;
  },

  /// 📍 ROUTES - Daftar semua route aplikasi
  routes: [
    // ===== SPLASH & AUTH ROUTES =====

    /// 🎬 SPLASH SCREEN - Loading/intro screen saat app start
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

    /// 🔓 LOGIN SCREEN - Login dengan email & password
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    /// 📝 REGISTER SCREEN - Daftar akun baru (customer/owner)
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // ===== CUSTOMER ROUTES =====

    /// 🏠 HOME SCREEN - Main screen menampilkan produk
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    /// 📦 PRODUCT DETAIL SCREEN - Detail produk tertentu
    /// Parameter: :id = productId
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),

    /// 🛒 CART SCREEN - Tampilkan keranjang belanja
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),

    /// ❤️ WISHLIST SCREEN - Tampilkan daftar produk favorit
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),

    /// 💳 CHECKOUT SCREEN - Proses checkout & pembayaran
    GoRoute(
      path: '/checkout',
      builder: (context, state) =>
          const CheckoutScreen(cartItems: [], subtotal: 0, shippingCost: 50000),
    ),

    /// 📋 ORDER HISTORY SCREEN - Riwayat pesanan customer
    GoRoute(
      path: '/order-history',
      builder: (context, state) => const OrderHistoryScreen(),
    ),

    /// 📄 ORDER DETAIL SCREEN - Detail pesanan tertentu
    /// Parameter: :id = orderId
    GoRoute(
      path: '/order/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),

    // ===== OWNER ROUTES =====

    /// 🏪 OWNER DASHBOARD - Dashboard penjual (manage produk & pesanan)
    GoRoute(
      path: '/owner-dashboard',
      builder: (context, state) => const OwnerDashboardScreen(),
    ),

    /// 📊 PRODUCT MANAGEMENT SCREEN - Kelola daftar produk penjual
    GoRoute(
      path: '/product-management',
      builder: (context, state) => const ProductManagementScreen(),
    ),

    /// ➕ ADD PRODUCT SCREEN - Form tambah produk baru
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddProductScreen(),
    ),

    /// ✏️ EDIT PRODUCT SCREEN - Form edit produk
    /// Parameter: :id = productId
    GoRoute(
      path: '/edit-product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return AddProductScreen(key: ValueKey(productId));
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Halaman tidak ditemukan'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    ),
  ),
);
