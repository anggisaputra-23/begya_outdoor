# 📱 BEGYA OUTDOOR - Project Overview

## 🎯 Tujuan Proyek
**Begya Outdoor** adalah aplikasi Flutter untuk **e-commerce perlengkapan outdoor** dengan fitur dual-role (Customer dan Owner/Penjual). Aplikasi ini memungkinkan pelanggan membeli peralatan outdoor dan penjual mengelola inventaris produk mereka.

---

## 🏗️ Arsitektur Proyek
Proyek ini menggunakan **Clean Architecture** dengan:
- **State Management**: Provider
- **Backend**: Supabase (Database & Authentication)
- **Networking**: HTTP/Dio
- **Local Storage**: SharedPreferences
- **Navigation**: GoRouter

```
lib/
├── main.dart                    # Entry point aplikasi
├── core/                        # Core resources
│   ├── constants/              # Konstanta dan routes
│   ├── services/               # Layanan (Supabase)
│   ├── theme/                  # Theme & styling
│   ├── utils/                  # Utility functions
│   └── widgets/                # Reusable widgets
├── data/                        # Data layer
│   ├── datasources/            # API & database calls
│   ├── models/                 # Data models
│   └── repositories/           # Repository implementations
├── presentation/                # UI layer
│   ├── auth/                   # Login/Register screens
│   ├── home/                   # Home screen
│   ├── product/                # Product detail
│   ├── cart/                   # Shopping cart
│   ├── checkout/               # Checkout process
│   ├── order/                  # Order management
│   ├── owner/                  # Owner dashboard
│   ├── wishlist/               # Wishlist feature
│   └── splash/                 # Splash screen
├── providers/                   # State management (Notifiers)
└── routes/                      # Routing configuration
```

---

## ✨ FITUR UTAMA APLIKASI

### 1️⃣ AUTHENTICATION (Autentikasi)
**📁 Lokasi**: [presentation/auth/](presentation/auth/)

#### File-file:
- **[login_screen.dart](presentation/auth/login_screen.dart)** - Layar login pelanggan
- **[register_screen.dart](presentation/auth/register_screen.dart)** - Layar registrasi pengguna

#### Notifier:
- **[providers/auth_notifier.dart](providers/auth_notifier.dart)** - State management autentikasi
  ```dart
  // FITUR AUTENTIKASI:
  // - signIn(email, password)      : Login dengan email & password
  // - signUp(...)                  : Register user baru (customer/owner)
  // - signOut()                    : Logout user
  // - refreshUser()                : Refresh data user dari server
  // - isAuthenticated              : Cek apakah user sudah login
  // - currentUser                  : Ambil data user saat ini
  ```

#### Repository:
- **[data/repositories/auth_repository.dart](data/repositories/auth_repository.dart)** - Implementasi autentikasi
  ```dart
  // Fungsi utama:
  // - signIn(email, password)      : Autentikasi dengan Supabase Auth
  // - signUp(...)                  : Buat user baru di Supabase
  // - signOut()                    : Logout & hapus session
  // - getCurrentUser()             : Ambil user dari database
  ```

**Fitur**:
- ✅ Login dengan email & password
- ✅ Registrasi user (Customer/Owner)
- ✅ Validasi input form
- ✅ Error handling
- ✅ Role-based redirect (Customer → Home, Owner → Dashboard)

---

### 2️⃣ PRODUCT MANAGEMENT (Manajemen Produk)
**📁 Lokasi**: [presentation/product/](presentation/product/) & [presentation/owner/](presentation/owner/)

#### File-file Customer:
- **[product/product_detail_screen.dart](presentation/product/product_detail_screen.dart)** - Tampilkan detail produk

#### File-file Owner:
- **[owner/product_management_screen.dart](presentation/owner/product_management_screen.dart)** - List produk penjual
- **[owner/add_product_screen.dart](presentation/owner/add_product_screen.dart)** - Tambah produk baru
- **[owner/owner_dashboard_screen.dart](presentation/owner/owner_dashboard_screen.dart)** - Dashboard penjual

#### Notifier:
- **[providers/product_notifier.dart](providers/product_notifier.dart)** - State management produk
  ```dart
  // FITUR PRODUK:
  // - getProducts(categoryId, searchQuery)  : Ambil semua produk
  // - getProductById(id)                    : Ambil detail produk
  // - getCategories()                       : Ambil daftar kategori
  // - searchProducts(query)                 : Cari produk
  // - addProduct(...)                       : Tambah produk baru
  // - updateProduct(...)                    : Edit produk
  // - deleteProduct(id)                     : Hapus produk
  // - uploadProductImage(file)              : Upload gambar produk
  // - filterByCategory(categoryId)          : Filter produk by kategori
  ```

#### Models:
- **[data/models/product_model.dart](data/models/product_model.dart)** - Struktur data produk
  ```dart
  // FIELDS:
  // - id                  : ID unik produk
  // - categoryId          : ID kategori
  // - name                : Nama produk
  // - description         : Deskripsi lengkap
  // - price               : Harga produk
  // - stock               : Stok tersedia
  // - mainImageUrl        : URL gambar utama
  // - rating              : Rating produk (1-5)
  // - reviewCount         : Jumlah review
  // - ownerId             : ID penjual
  // - createdAt/updatedAt : Timestamp
  ```

- **[data/models/category_model.dart](data/models/category_model.dart)** - Struktur data kategori

#### Repository:
- **[data/repositories/product_repository.dart](data/repositories/product_repository.dart)** - Repository produk
  ```dart
  // Fungsi utama:
  // - getProducts()       : Fetch semua produk dari Supabase
  // - getProductById()    : Fetch produk by ID
  // - addProduct()        : Simpan produk baru
  // - updateProduct()     : Update data produk
  // - deleteProduct()     : Hapus produk
  // - getCategories()     : Fetch semua kategori
  ```

**Fitur**:
- ✅ Tampilkan daftar produk dengan pagination
- ✅ Filter produk by kategori
- ✅ Cari produk (search)
- ✅ Lihat detail produk (harga, stok, rating, deskripsi)
- ✅ Owner bisa tambah/edit/hapus produk
- ✅ Upload gambar produk
- ✅ Manajemen stok produk
- ✅ Rating & review produk

---

### 3️⃣ SHOPPING CART (Keranjang Belanja)
**📁 Lokasi**: [presentation/cart/](presentation/cart/)

#### File:
- **[cart/cart_screen.dart](presentation/cart/cart_screen.dart)** - Tampilkan keranjang belanja

#### Notifier:
- **[providers/cart_notifier.dart](providers/cart_notifier.dart)** - State management keranjang
  ```dart
  // FITUR KERANJANG:
  // - addToCart(productId, quantity)       : Tambah item ke keranjang
  // - removeFromCart(cartItemId)           : Hapus item dari keranjang
  // - updateQuantity(cartItemId, qty)      : Update jumlah item
  // - loadCart()                           : Load keranjang dari storage
  // - clearCart()                          : Kosongkan keranjang
  // - getCartItems()                       : Ambil semua item keranjang
  // - subtotal                             : Total harga sebelum ongkir
  // - shippingCost                         : Biaya pengiriman (Rp 50.000)
  // - total                                : Total harga (subtotal + ongkir)
  ```

#### Models:
- **[data/models/cart_item_model.dart](data/models/cart_item_model.dart)** - Item dalam keranjang
- **[data/models/cart_model.dart](data/models/cart_model.dart)** - Model keranjang

#### Repository:
- **[data/repositories/cart_repository.dart](data/repositories/cart_repository.dart)** - Repository keranjang
  ```dart
  // Fungsi utama:
  // - addItemToCart()     : Simpan item ke keranjang
  // - getCartItems()      : Ambil semua item keranjang
  // - removeItem()        : Hapus item dari keranjang
  // - updateItemQuantity(): Update jumlah item
  ```

**Fitur**:
- ✅ Tambah produk ke keranjang
- ✅ Lihat detail item di keranjang
- ✅ Update jumlah item (quantity)
- ✅ Hapus item dari keranjang
- ✅ Hitung subtotal & total harga
- ✅ Tampilkan biaya pengiriman (Rp 50.000)
- ✅ Lanjut ke checkout

---

### 4️⃣ CHECKOUT & PAYMENT (Proses Checkout & Pembayaran)
**📁 Lokasi**: [presentation/checkout/](presentation/checkout/)

#### File:
- **[checkout/checkout_screen.dart](presentation/checkout/checkout_screen.dart)** - Proses checkout

**Fitur**:
- ✅ Input detail pengiriman (nama, alamat, telepon)
- ✅ Pilih metode pembayaran
- ✅ Lihat ringkasan pesanan
- ✅ Upload bukti pembayaran
- ✅ Konfirmasi pesanan
- ✅ Validasi form checkout

---

### 5️⃣ ORDER MANAGEMENT (Manajemen Pesanan)
**📁 Lokasi**: [presentation/order/](presentation/order/)

#### File:
- **[order/order_history_screen.dart](presentation/order/order_history_screen.dart)** - Riwayat pesanan customer
- **[order/order_detail_screen.dart](presentation/order/order_detail_screen.dart)** - Detail pesanan

#### Notifier:
- **[providers/order_notifier.dart](providers/order_notifier.dart)** - State management pesanan
  ```dart
  // FITUR PESANAN:
  // - createOrder(...)                : Buat pesanan baru
  // - getOrderHistory(userId)         : Ambil riwayat pesanan user
  // - getOrderById(orderId)           : Ambil detail pesanan
  // - updateOrderStatus(...)          : Update status pesanan
  // - uploadPaymentProof(...)         : Upload bukti pembayaran
  // - getAllOrders()                  : Ambil semua pesanan (owner)
  // - getOrdersByStatus(status)       : Filter pesanan by status
  ```

#### Models:
- **[data/models/order_model.dart](data/models/order_model.dart)** - Model pesanan
  ```dart
  // FIELDS:
  // - id                  : ID unik pesanan
  // - userId              : ID pelanggan
  // - totalPrice          : Total harga pesanan
  // - status              : Status pesanan (menunggu/dibayar/dikirim/selesai)
  // - proofPayment        : URL bukti pembayaran
  // - createdAt           : Waktu pemesanan
  // - customerName        : Nama penerima
  // - customerPhone       : No. telepon penerima
  // - customerAddress     : Alamat pengiriman
  // - subtotal            : Subtotal sebelum ongkir
  // - shippingCost        : Biaya pengiriman
  ```

- **[data/models/order_item_model.dart](data/models/order_item_model.dart)** - Item dalam pesanan

#### Repository:
- **[data/repositories/order_repository.dart](data/repositories/order_repository.dart)** - Repository pesanan
  ```dart
  // Fungsi utama:
  // - createOrder()       : Buat pesanan baru di Supabase
  // - getOrderHistory()   : Fetch riwayat pesanan user
  // - getOrderById()      : Fetch detail pesanan
  // - updateOrderStatus() : Update status pesanan
  // - uploadPayment()     : Upload bukti pembayaran ke storage
  ```

**Fitur**:
- ✅ Lihat riwayat pesanan
- ✅ Lihat detail pesanan (items, total, status)
- ✅ Status pesanan (Menunggu → Dibayar → Dikirim → Selesai)
- ✅ Upload bukti pembayaran
- ✅ Tracking status pesanan
- ✅ Owner bisa lihat semua pesanan & update status

---

### 6️⃣ WISHLIST (Daftar Ingin Dibeli)
**📁 Lokasi**: [presentation/wishlist/](presentation/wishlist/)

#### File:
- **[wishlist/wishlist_screen.dart](presentation/wishlist/wishlist_screen.dart)** - Tampilkan wishlist

#### Notifier:
- **[providers/wishlist_notifier.dart](providers/wishlist_notifier.dart)** - State management wishlist
  ```dart
  // FITUR WISHLIST:
  // - addToWishlist(productId)         : Tambah produk ke wishlist
  // - removeFromWishlist(productId)    : Hapus produk dari wishlist
  // - toggleWishlist(productId)        : Toggle wishlist
  // - getWishlist()                    : Ambil semua item wishlist
  // - isInWishlist(productId)          : Cek apakah produk di wishlist
  // - getWishlistCount()               : Hitung jumlah item wishlist
  ```

#### Repository:
- **[data/repositories/wishlist_repository.dart](data/repositories/wishlist_repository.dart)** - Repository wishlist
  ```dart
  // Fungsi utama:
  // - addToWishlist()     : Simpan ke wishlist (SharedPreferences)
  // - removeFromWishlist(): Hapus dari wishlist
  // - getWishlist()       : Ambil semua wishlist
  // - isInWishlist()      : Cek status wishlist
  ```

**Fitur**:
- ✅ Tambah/hapus produk dari wishlist
- ✅ Tampilkan semua produk di wishlist
- ✅ Wishlist disimpan secara lokal (SharedPreferences)
- ✅ Tombol wishlist di setiap produk
- ✅ Pindah wishlist ke keranjang

---

### 7️⃣ HOME SCREEN (Layar Utama)
**📁 Lokasi**: [presentation/home/](presentation/home/)

#### File:
- **[home/home_screen.dart](presentation/home/home_screen.dart)** - Layar home customer

**Fitur**:
- ✅ Tampilkan list produk populer/terbaru
- ✅ Banner/carousel produk featured
- ✅ Kategori produk
- ✅ Search bar untuk cari produk
- ✅ Tombol filter & sort
- ✅ Bottom navigation (Home, Cart, Wishlist, Profile)

---

### 8️⃣ SPLASH SCREEN (Layar Pembuka)
**📁 Lokasi**: [presentation/splash/](presentation/splash/)

#### File:
- **[splash/splash_screen.dart](presentation/splash/splash_screen.dart)** - Layar splash/loading

**Fitur**:
- ✅ Tampilkan splash screen saat app start
- ✅ Inisialisasi Supabase
- ✅ Check user session
- ✅ Redirect ke halaman sesuai login status & role

---

## 🔧 CORE RESOURCES

### Services
**📁 Lokasi**: [core/services/](core/services/)

- **[supabase_service.dart](core/services/supabase_service.dart)** - Singleton service untuk Supabase
  ```dart
  // FUNGSI UTAMA:
  // - initialize()        : Inisialisasi Supabase client
  // - getClient()         : Ambil instance Supabase client
  // - getUser()           : Ambil user saat ini
  // - uploadFile()        : Upload file ke storage
  ```

### Datasources
**📁 Lokasi**: [data/datasources/](data/datasources/)

- **[supabase_datasource.dart](data/datasources/supabase_datasource.dart)** - Datasource untuk API calls
  ```dart
  // FUNGSI UTAMA:
  // - signUp/signIn/signOut : Autentikasi
  // - getProducts()         : Fetch produk
  // - createOrder()         : Buat pesanan
  // - uploadImage()         : Upload gambar
  ```

### Theme
**📁 Lokasi**: [core/theme/](core/theme/)

- **[app_colors.dart](core/theme/app_colors.dart)** - Palet warna aplikasi
- **[app_theme.dart](core/theme/app_theme.dart)** - Theme Material (light & dark)
- **[text_styles.dart](core/theme/text_styles.dart)** - Style teks reusable

### Utils
**📁 Lokasi**: [core/utils/](core/utils/)

- **[form_validator.dart](core/utils/form_validator.dart)** - Validasi form (email, password, dll)
- **[extensions.dart](core/utils/extensions.dart)** - Extension untuk String, DateTime, dll

### Constants
**📁 Lokasi**: [core/constants/](core/constants/)

- **[routes.dart](core/constants/routes.dart)** - Daftar semua route aplikasi
- **[app_constants.dart](core/constants/app_constants.dart)** - Konstanta global

### Widgets
**📁 Lokasi**: [core/widgets/](core/widgets/)

- **[widgets.dart](core/widgets/widgets.dart)** - Custom widgets reusable
  - Custom buttons
  - Custom text fields
  - Loading indicators
  - Error widgets
  - dll

---

## 🗺️ ROUTING / NAVIGASI

**📁 Lokasi**: [routes/app_router.dart](routes/app_router.dart)

```dart
// ROUTE PATHS:

// AUTH ROUTES:
'/splash'          → Splash screen
'/login'           → Login screen
'/register'        → Register screen

// CUSTOMER ROUTES:
'/home'            → Home screen
'/product/:id'     → Detail produk
'/cart'            → Keranjang belanja
'/wishlist'        → Daftar wishlist
'/checkout'        → Checkout form
'/order-history'   → Riwayat pesanan
'/order/:id'       → Detail pesanan

// OWNER ROUTES:
'/owner-dashboard'     → Dashboard penjual
'/product-management'  → Kelola produk
'/add-product'         → Tambah produk baru
'/edit-product/:id'    → Edit produk
'/order-management'    → Kelola pesanan

// COMMON:
'/profile'         → Profil pengguna
'/settings'        → Pengaturan
```

**Fitur**:
- ✅ Redirect otomatis berdasarkan login status
- ✅ Role-based routing (Customer vs Owner)
- ✅ Deep linking support
- ✅ Parameterized routes

---

## 📊 STATE MANAGEMENT (Provider)

**📁 Lokasi**: [providers/](providers/)

Aplikasi menggunakan **Provider** untuk state management dengan notifier pattern:

```
providers/
├── auth_notifier.dart       → AuthNotifier (login, register, user state)
├── product_notifier.dart    → ProductNotifier (produk, kategori, search)
├── cart_notifier.dart       → CartNotifier (keranjang belanja)
├── order_notifier.dart      → OrderNotifier (pesanan, riwayat)
├── wishlist_notifier.dart   → WishlistNotifier (wishlist)
└── providers.dart           → Export semua provider
```

Setiap Notifier menangani:
- State data
- Loading state
- Error handling
- Business logic

---

## 🔄 DATA FLOW ARCHITECTURE

```
UI Layer (Presentation)
    ↓
State Management (Provider/Notifier)
    ↓
Repository Layer (Abstraction)
    ↓
Datasource Layer (API/Database)
    ↓
Backend (Supabase)
```

---

## 🎨 UI/UX FEATURES

**📁 Lokasi**: [presentation/](presentation/)

- ✅ Material Design UI
- ✅ Shimmer loading effects
- ✅ Lottie animations
- ✅ Responsive design
- ✅ Error & empty states
- ✅ Loading indicators
- ✅ Toast notifications
- ✅ Modal dialogs
- ✅ Bottom sheets
- ✅ Custom form inputs

---

## 🔐 BACKEND / DATABASE (Supabase)

**Database Tables**:
1. `users` - Data pengguna (email, password, role, dll)
2. `products` - Katalog produk
3. `categories` - Kategori produk
4. `cart_items` - Item keranjang
5. `orders` - Pesanan
6. `order_items` - Item dalam pesanan
7. `product_images` - Gambar produk

**Storage Buckets**:
- `product-images` - Gambar produk
- `payment-proofs` - Bukti pembayaran
- `user-avatars` - Avatar pengguna

---

## 📦 DEPENDENCIES

**Main Dependencies** (dari pubspec.yaml):
- `flutter` - UI framework
- `provider` - State management
- `supabase_flutter` - Backend & database
- `go_router` - Navigation
- `http` & `dio` - HTTP client
- `image_picker` - Image selection
- `cached_network_image` - Image caching
- `lottie` - Animations
- `shimmer` - Loading effects
- `shared_preferences` - Local storage
- `intl` - Internationalization
- `equatable` - Equality checks

---

## ✅ RINGKASAN FITUR

| Fitur | Customer | Owner | Status |
|-------|----------|-------|--------|
| Login/Register | ✅ | ✅ | ✓ |
| Browse Produk | ✅ | - | ✓ |
| Detail Produk | ✅ | - | ✓ |
| Cari Produk | ✅ | - | ✓ |
| Filter Kategori | ✅ | - | ✓ |
| Wishlist | ✅ | - | ✓ |
| Keranjang Belanja | ✅ | - | ✓ |
| Checkout | ✅ | - | ✓ |
| Pesanan | ✅ | - | ✓ |
| Kelola Produk | - | ✅ | ✓ |
| Tambah Produk | - | ✅ | ✓ |
| Kelola Pesanan | - | ✅ | ✓ |
| Upload Gambar | ✅ | ✅ | ✓ |
| Rating & Review | ✅ | - | ⏳ |

---

## 🚀 CARA MENGGUNAKAN PROJECT INI

1. **Clone/Extract project**
2. **Install dependencies**: `flutter pub get`
3. **Setup Supabase**:
   - Buat project di supabase.com
   - Setup tables & RLS policies
   - Update credentials di `core/services/supabase_service.dart`
4. **Run app**: `flutter run`

---

## 📝 CATATAN PENTING

- Semua notifier menggunakan **result pattern** (Either type dari dartz)
- Error handling dilakukan di setiap layer
- Loading states ditampilkan di UI
- Local storage untuk wishlist menggunakan SharedPreferences
- Payment system (upload bukti) terintegrasi dengan Supabase Storage

---

**Last Updated**: December 2025
**Project Status**: 🔄 Development In Progress
