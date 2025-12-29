# 🚀 BEGYA OUTDOOR - NEXT STEPS IMPLEMENTATION GUIDE

## Langkah 1: Database Setup (5 menit)

### ✅ TODO:
1. Login ke Supabase: https://app.supabase.com
2. Pilih project: ilovpuvrezassnwtmssg
3. Buka SQL Editor
4. Copy semua SQL queries dari `DEVELOPMENT_PROGRESS.md`
5. Run semua queries

### 🔗 SQL Queries (Copy dari DEVELOPMENT_PROGRESS.md):
```sql
-- Create users table
-- Create categories table
-- Create products table
-- Create product_images table
-- Create carts table
-- Create cart_items table
-- Create orders table
-- Create indexes
```

---

## Langkah 2: Test Flutter Setup (10 menit)

### ✅ Terminal Commands:
```bash
# 1. Go to project directory
cd D:\Begya_outdoor\begya_outdoor

# 2. Get all dependencies
flutter pub get

# 3. Run app
flutter run

# 4. Test on emulator/device
```

### 🔍 Expected Output:
```
✓ Supabase initialized successfully
✓ Splash screen animates
✓ Can navigate to login screen
✓ Login/Register forms functional
✓ Home screen loads
✓ Product detail shows hero animation
```

---

## Langkah 3: State Management Setup (Priority: HIGH)

### 📁 Files to Create:

#### 1️⃣ `lib/providers/auth_provider.dart`
```dart
// Create AuthNotifier extends ChangeNotifier
// Methods:
// - signUp(email, password, name, role)
// - signIn(email, password)
// - signOut()
// - getCurrentUser()
// - isAuthenticated getter
```

**Implementation Template:**
```dart
import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/repositories/auth_repository.dart';
import '../core/services/supabase_service.dart';

class AuthNotifier extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  Future<bool> signUp({required String email, ...}) async {
    // Implementation
  }

  Future<bool> signIn({required String email, ...}) async {
    // Implementation
  }

  Future<void> signOut() async {
    // Implementation
  }

  Future<void> getCurrentUser() async {
    // Implementation
  }
}
```

#### 2️⃣ `lib/providers/product_provider.dart`
```dart
// Create ProductNotifier extends ChangeNotifier
// Methods:
// - getProducts(categoryId, searchQuery)
// - getProductById(productId)
// - getProductsByOwner(ownerId)
// - createProduct(...)
// - updateProduct(...)
// - deleteProduct(...)
// - getCategories()

// Properties:
// - products: List<Product>
// - selectedProduct: Product?
// - categories: List<Category>
// - isLoading: bool
```

#### 3️⃣ `lib/providers/cart_provider.dart`
```dart
// Create CartNotifier extends ChangeNotifier
// Methods:
// - addToCart(CartItem)
// - removeFromCart(itemId)
// - updateQuantity(itemId, quantity)
// - clearCart()
// - getCartItems()
// - calculateTotal()

// Properties:
// - cartItems: List<CartItem>
// - totalPrice: double
// - itemCount: int
```

#### 4️⃣ `lib/providers/order_provider.dart`
```dart
// Create OrderNotifier extends ChangeNotifier
// Methods:
// - createOrder(items, subtotal, shipping, customer info)
// - getOrderById(orderId)
// - getCustomerOrders(customerId)
// - getAllOrders()
// - updateOrderStatus(orderId, status)
// - uploadPaymentProof(orderId, filePath)

// Properties:
// - orders: List<Order>
// - selectedOrder: Order?
// - isLoading: bool
```

### 🔧 Update `main.dart`:
```dart
// Add MultiProvider
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthNotifier(AuthRepositoryImpl(...)),
      ),
      ChangeNotifierProvider(
        create: (_) => ProductNotifier(ProductRepositoryImpl(...)),
      ),
      ChangeNotifierProvider(
        create: (_) => CartNotifier(CartRepositoryImpl()),
      ),
      ChangeNotifierProvider(
        create: (_) => OrderNotifier(OrderRepositoryImpl(...)),
      ),
    ],
    child: MyApp(),
  ),
);
```

---

## Langkah 4: Build Remaining Screens

### 📁 Cart Screen (`lib/presentation/cart/cart_screen.dart`)

**Features:**
- [x] Display cart items
- [x] Edit quantity
- [x] Remove item
- [x] Calculate totals
- [ ] Promo code input (optional)
- [x] Checkout button

**Code Template:**
```dart
class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keranjang')),
      body: Consumer<CartNotifier>(
        builder: (context, cartNotifier, _) {
          if (cartNotifier.cartItems.isEmpty) {
            return EmptyWidget(
              title: 'Keranjang Kosong',
              actionLabel: 'Belanja Sekarang',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartNotifier.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartNotifier.cartItems[index];
                    return _buildCartItem(item, cartNotifier);
                  },
                ),
              ),
              _buildCheckoutSection(context, cartNotifier),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartNotifier cartNotifier) {
    // Build cart item card with quantity controls
  }

  Widget _buildCheckoutSection(BuildContext context, CartNotifier cartNotifier) {
    // Build pricing summary and checkout button
  }
}
```

### 📁 Checkout Screen (`lib/presentation/checkout/checkout_screen.dart`)

**Features:**
- [x] Customer info form (name, email, phone, address)
- [x] Shipping method selection
- [x] Payment method selection
- [x] Order summary
- [x] Create order button

**Form Fields:**
```dart
CustomTextField(
  label: 'Nama Lengkap',
  controller: _nameController,
  validator: FormValidator.validateName,
)
// ... phone, address, email

// Shipping Selection
RadioListTile(title: Text('Reguler (5-7 hari) - Rp 50.000'))
RadioListTile(title: Text('Express (1-2 hari) - Rp 100.000'))

// Payment Method Selection
RadioListTile(title: Text('Bank Transfer'))
RadioListTile(title: Text('E-Wallet'))
```

### 📁 Order History Screen (`lib/presentation/order/order_history_screen.dart`)

**Features:**
- [x] List customer orders
- [x] Filter by status
- [x] Order status badge
- [x] Tap to view details

```dart
class OrderHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Pesanan')),
      body: Consumer<OrderNotifier>(
        builder: (context, orderNotifier, _) {
          return ListView.builder(
            itemCount: orderNotifier.orders.length,
            itemBuilder: (context, index) {
              final order = orderNotifier.orders[index];
              return Card(
                child: ListTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text(order.createdAt.formatDate()),
                  trailing: _buildStatusBadge(order.status),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    // Build status badge with appropriate color
  }
}
```

### 📁 Order Detail Screen (`lib/presentation/order/order_detail_screen.dart`)

**Features:**
- [x] Order info
- [x] Items list
- [x] Payment proof section
- [x] Status timeline
- [x] Confirm delivery button

---

## Langkah 5: Owner Dashboard

### 📁 Owner Dashboard (`lib/presentation/owner/owner_dashboard_screen.dart`)

**Components:**
- Overview cards (total sales, total orders, total products)
- Recent orders
- Quick actions

### 📁 Product Management (`lib/presentation/owner/product_management_screen.dart`)

- List products
- Edit/Delete buttons
- Add product button

### 📁 Add/Edit Product (`lib/presentation/owner/add_product_screen.dart`)

```dart
Form Fields:
- Product name
- Category dropdown
- Description
- Price
- Stock
- Multiple images picker
- Submit button
```

---

## Langkah 6: App Router Setup

### 📁 `lib/routes/app_router.dart`

```dart
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    // ... more routes
  ],
);
```

### Update `main.dart`:
```dart
MaterialApp.router(
  routerConfig: appRouter,
  ...
)
```

---

## Checklist Implementation Order

### Priority 1: State Management (CRITICAL)
- [ ] Create auth_provider.dart
- [ ] Create product_provider.dart
- [ ] Create cart_provider.dart
- [ ] Create order_provider.dart
- [ ] Update main.dart with MultiProvider
- [ ] Test all providers

### Priority 2: Remaining Screens
- [ ] Cart screen
- [ ] Checkout screen
- [ ] Order history screen
- [ ] Order detail screen
- [ ] Payment proof screen

### Priority 3: Owner Features
- [ ] Owner dashboard
- [ ] Product management screen
- [ ] Add/edit product screen
- [ ] Order management screen

### Priority 4: Router & Navigation
- [ ] Setup app_router.dart
- [ ] Update all screen navigation
- [ ] Test navigation flows

### Priority 5: Polish & Testing
- [ ] Test all features
- [ ] Error handling
- [ ] Loading states
- [ ] Empty states
- [ ] Form validation
- [ ] Image upload
- [ ] Payment proof upload

---

## Code Snippets for Quick Reference

### Consumer Widget Usage:
```dart
Consumer<CartNotifier>(
  builder: (context, cartNotifier, _) {
    return Text('Items: ${cartNotifier.itemCount}');
  },
)
```

### Multi-Provider Access:
```dart
final authNotifier = context.read<AuthNotifier>();
final cartNotifier = context.read<CartNotifier>();
```

### Format Currency:
```dart
double price = 450000;
print(price.toCurrency()); // Rp 450.000
```

### Navigate with Named Route:
```dart
Navigator.pushNamed(context, '/product/:id', arguments: {'id': '123'});
```

### Show Snackbar:
```dart
context.showSuccessSnackBar('Produk ditambahkan ke keranjang');
context.showErrorSnackBar('Terjadi kesalahan');
```

---

## Testing Commands

```bash
# Run with verbose output
flutter run -v

# Run on specific device
flutter run -d emulator-5554

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Run tests
flutter test
```

---

## Troubleshooting

### Issue: "Unhandled Exception: Failed to initialize Supabase"
**Solution:** Check Supabase URL dan Anon Key di app_constants.dart

### Issue: "RenderFlex overflowed"
**Solution:** Wrap Column/Row dengan Expanded atau SingleChildScrollView

### Issue: "Provider not found"
**Solution:** Make sure MultiProvider wraps all child widgets

### Issue: "Hero animation not working"
**Solution:** Ensure Hero tags are unique

---

## Performance Tips

1. **Use const constructors** for static widgets
2. **Dispose controllers** properly in State.dispose()
3. **Use ListView.builder** for long lists (not Column)
4. **Cache images** dengan cached_network_image
5. **Lazy load** products with pagination
6. **Debounce search** input

---

## Estimated Timeline

| Task | Duration | Status |
|------|----------|--------|
| Providers Setup | 1-2 hours | ⏳ TODO |
| Cart + Checkout | 2-3 hours | ⏳ TODO |
| Order Screens | 2-3 hours | ⏳ TODO |
| Owner Dashboard | 2-3 hours | ⏳ TODO |
| Router Setup | 1 hour | ⏳ TODO |
| Testing & Polish | 2-3 hours | ⏳ TODO |
| **TOTAL** | **11-15 hours** | **50% Done** |

---

## Resources

- [Supabase Flutter Documentation](https://supabase.com/docs/reference/flutter/auth-sign-up)
- [Provider Documentation](https://pub.dev/packages/provider)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)

---

**Ready to implement? Choose your starting point!** 🚀

1. Start with State Management → Build Providers
2. Start with Screens → Build Cart & Checkout
3. Start with Router → Setup Navigation First

Which one would you like me to implement next? 😊
