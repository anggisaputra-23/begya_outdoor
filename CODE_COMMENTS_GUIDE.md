# 📝 CODE COMMENTS GUIDE - Penjelasan Komentar di Kode

Dokumentasi ini menjelaskan dimana komentar sudah ditambahkan dan apa yang dijelaskan pada setiap file.

---

## 🔥 FILE-FILE DENGAN KOMENTAR LENGKAP

### 1. **[lib/main.dart](lib/main.dart)** - Entry Point Aplikasi

#### Komentar ditambahkan:

**✅ main() function** (Line ~15-33)
```dart
/// 🚀 ENTRY POINT APLIKASI BEGYA OUTDOOR
/// 
/// Fungsi main():
/// 1. Inisialisasi Flutter bindings
/// 2. Setup Supabase backend
/// 3. Setup SharedPreferences untuk local storage
/// 4. Run aplikasi dengan MultiProvider
```

**Penjelasan:**
- Alasan diperlukan `WidgetsFlutterBinding.ensureInitialized()`
- Alasan Supabase perlu di-inisialisasi
- Alasan SharedPreferences untuk wishlist
- Urutan eksekusi

**✅ MyApp class** (Line ~35-80)
```dart
// 🔧 SETUP LAYANAN & REPOSITORY
// Menginisialisasi semua layanan yang dibutuhkan untuk akses data
```

**Penjelasan:**
- Apa itu datasource dan repository
- Fungsi setiap repository (auth, product, cart, order, wishlist)
- Kenapa menggunakan MultiProvider
- Apa yang dilakukan setiap provider

---

### 2. **[lib/providers/auth_notifier.dart](lib/providers/auth_notifier.dart)** - Autentikasi

#### Komentar ditambahkan:

**✅ Class declaration** (Line ~6-27)
```dart
/// 🔐 AUTH NOTIFIER - State Management untuk Autentikasi
/// 
/// Mengelola:
/// - Login/Register user
/// - User session (isAuthenticated)
/// - Current user data
/// - Loading & error states
```

**✅ signUp() method** (Line ~31-54)
```dart
/// 📝 SIGN UP - Daftar akun baru
/// 
/// Parameter:
/// - email: Email pengguna
/// - password: Password (minimal 6 karakter)
/// - name: Nama lengkap
/// - phone: Nomor telepon (opsional)
/// - role: 'customer' atau 'owner'
/// 
/// Return: true jika berhasil, false jika gagal
/// 
/// Alur:
/// 1. Set loading = true, clear error
/// 2. Kirim ke repository untuk create user di Supabase Auth & DB
/// 3. Jika berhasil: simpan user data & notify listeners
/// 4. Jika gagal: tampilkan error
```

**✅ signIn() method**
```dart
/// 🔓 SIGN IN - Login dengan email & password
/// 
/// Parameter:
/// - email: Email akun
/// - password: Password akun
/// 
/// Return: true jika berhasil login, false jika gagal
/// 
/// Alur:
/// 1. Set loading = true, clear error
/// 2. Kirim email & password ke repository untuk autentikasi
/// 3. Jika berhasil: simpan user data & notify listeners (auto redirect ke home)
/// 4. Jika gagal: tampilkan error (email tidak terdaftar, password salah, dll)
```

**✅ getCurrentUser() method**
```dart
/// 👤 GET CURRENT USER - Ambil data user saat ini dari database
/// 
/// Fungsi:
/// - Refresh data user dari Supabase
/// - Digunakan saat app start untuk check session
/// - Update _currentUser dengan data terbaru dari database
```

**✅ signOut() method**
```dart
/// 🚪 SIGN OUT - Logout user
/// 
/// Fungsi:
/// - Hapus session Supabase Auth
/// - Clear _currentUser dari state
/// - Auto redirect ke login screen
```

**Penjelasan detail:**
- Apa itu result pattern (Either type)
- Bagaimana fold() menangani success dan failure
- Kenapa perlu notifyListeners()
- Cara handle error dengan user-friendly messages

---

### 3. **[lib/providers/cart_notifier.dart](lib/providers/cart_notifier.dart)** - Keranjang Belanja

#### Komentar ditambahkan:

**✅ Class declaration** (Line ~6-30)
```dart
/// 🛒 CART NOTIFIER - State Management untuk Keranjang Belanja
/// 
/// Mengelola:
/// - Daftar item di keranjang
/// - Tambah/hapus/update quantity item
/// - Hitung subtotal, ongkir, total
/// - Loading & error states
```

**✅ Getter properties** (Line ~33-48)
```dart
/// 💰 SUBTOTAL - Total harga barang saja (tanpa ongkir)
/// Rumus: Σ (harga x quantity) untuk semua item

/// 🚚 SHIPPING COST - Biaya pengiriman (FIXED = Rp 50.000)

/// 💵 TOTAL - Total harga akhir yang harus dibayar
/// Rumus: Subtotal + Shipping Cost
```

**✅ loadCart() method**
```dart
/// 📥 LOAD CART - Ambil item keranjang dari storage
/// 
/// Fungsi: Fetch semua item keranjang saat app dibuka
```

**✅ addToCart() method**
```dart
/// ➕ ADD TO CART - Tambah produk ke keranjang
/// 
/// Alur:
/// 1. Buat CartItem baru dengan data produk
/// 2. Cek apakah produk sudah ada di keranjang
///    - Jika ada: update quantity (tambah)
///    - Jika belum: tambah item baru ke list
/// 3. Notify listeners untuk update UI
```

**✅ removeFromCart() method**
```dart
/// ❌ REMOVE FROM CART - Hapus item dari keranjang
/// 
/// Alur:
/// 1. Kirim request hapus ke repository
/// 2. Jika berhasil: hapus dari local list _cartItems
/// 3. Notify listeners untuk update UI (total harga berubah)
```

**✅ updateQuantity() method**
```dart
/// 🔢 UPDATE QUANTITY - Ubah jumlah item di keranjang
/// 
/// Alur:
/// 1. Jika newQuantity < 1: hapus item (bukan update)
/// 2. Jika newQuantity >= 1: update quantity di repository
/// 3. Update local list dengan quantity baru
/// 4. Notify listeners (subtotal & total berubah)
```

**✅ clearCart() method**
```dart
/// 🗑️ CLEAR CART - Kosongkan semua item di keranjang
/// 
/// Fungsi: Hapus semua item sekaligus (biasa dipanggil setelah checkout berhasil)
```

---

### 4. **[lib/providers/product_notifier.dart](lib/providers/product_notifier.dart)** - Produk

#### Komentar ditambahkan:

**✅ Class declaration** (Line ~6-36)
```dart
/// 📦 PRODUCT NOTIFIER - State Management untuk Produk
/// 
/// Mengelola:
/// - Daftar semua produk & kategori
/// - Search & filter produk
/// - Detail produk individual
/// - CRUD produk (owner only)
/// - Upload gambar produk
```

**✅ getProducts() method**
```dart
/// 📋 GET PRODUCTS - Ambil daftar produk dengan filter optional
/// 
/// Parameter:
/// - categoryId: Filter berdasarkan kategori (opsional)
/// - searchQuery: Filter berdasarkan nama/deskripsi (opsional)
```

**✅ getProductById() method**
```dart
/// 🔍 GET PRODUCT BY ID - Ambil detail produk tertentu
/// 
/// Alur:
/// 1. Set loading = true
/// 2. Query produk berdasarkan ID dari repository
/// 3. Jika berhasil: simpan di _selectedProduct
/// 4. Update UI dengan detail produk (harga, stok, rating, deskripsi)
```

**✅ getProductsByOwner() method**
```dart
/// 🏬 GET PRODUCTS BY OWNER - Ambil semua produk milik penjual tertentu (owner only)
/// 
/// Fungsi: Digunakan di Owner Dashboard untuk menampilkan produk mereka sendiri
```

**✅ getCategories() method**
```dart
/// 🏷️ GET CATEGORIES - Ambil semua kategori produk
/// 
/// Fungsi: Digunakan di HomeScreen untuk menampilkan filter kategori
```

**✅ searchProducts() method**
```dart
/// 🔎 SEARCH PRODUCTS - Cari produk berdasarkan nama/deskripsi (client-side)
/// 
/// Note: Ini adalah client-side filtering (lebih cepat, pakai _products lokal)
```

**✅ filterByCategory() method**
```dart
/// 🏷️ FILTER BY CATEGORY - Filter produk berdasarkan kategori
```

**✅ createProduct() method**
```dart
/// ➕ CREATE PRODUCT - Tambah produk baru TANPA gambar (owner only)
/// 
/// Note: Fallback jika upload gambar gagal, owner bisa save produk dulu
```

**✅ createProductWithImage() method**
```dart
/// ➕ CREATE PRODUCT WITH IMAGE - Tambah produk + upload gambar dari File
/// 
/// Keuntungan: Support mobile platform dengan File API
```

**✅ updateProduct() method**
```dart
/// ✏️ UPDATE PRODUCT - Edit produk (owner only)
/// 
/// Note: Hanya bisa update field tertentu, tidak bisa replace gambar di sini
```

**✅ updateProductWithImageBytes() method**
```dart
/// ✏️ UPDATE PRODUCT WITH IMAGE BYTES - Edit produk + ganti gambar (owner only)
/// 
/// Note: Otomatis mengganti gambar lama (tidak ada cleanup manual)
```

**✅ deleteProduct() method**
```dart
/// ❌ DELETE PRODUCT - Hapus produk (owner only)
/// 
/// Alur (Optimistic UI):
/// 1. Hapus LANGSUNG dari _products (UI update instant)
/// 2. Clear _selectedProduct jika produk yang dihapus sedang dilihat
/// 3. Notify listeners untuk refresh UI
/// 4. Di background: delete dari database
/// 5. Jika delete di database gagal: tampilkan error
/// 
/// Keuntungan: UI terasa lebih responsif, tidak perlu tunggu server
/// Risiko: Jika gagal, perlu refresh manual atau undo
```

---

### 5. **[lib/providers/order_notifier.dart](lib/providers/order_notifier.dart)** - Pesanan

#### Komentar ditambahkan:

**✅ Class declaration**
```dart
/// 📋 ORDER NOTIFIER - State Management untuk Pesanan
/// 
/// Mengelola:
/// - Membuat pesanan baru
/// - Riwayat pesanan customer
/// - Detail pesanan individual
/// - Status pesanan (Menunggu → Dibayar → Dikirim → Selesai)
/// - Upload bukti pembayaran
```

**✅ createOrder() method**
```dart
/// 📝 CREATE ORDER - Buat pesanan baru
/// 
/// Alur:
/// 1. Set loading = true
/// 2. Kirim data ke repository untuk buat pesanan baru
/// 3. Create Order record + OrderItem records di database
/// 4. Jika berhasil: 
///    - Insert pesanan baru ke depan _orders list
///    - Clear cart setelah pesanan berhasil
///    - Notify listeners & redirect ke order detail
/// 5. Jika gagal: tampilkan error (validasi, server error, dll)
/// 
/// Status awal pesanan: 'menunggu' (waiting for payment)
```

**✅ getOrderById() method**
```dart
/// 🔍 GET ORDER BY ID - Ambil detail pesanan tertentu
/// 
/// Note: Juga bisa tampilkan OrderItem yang terkait dengan pesanan ini
```

**✅ getCustomerOrders() method**
```dart
/// 👥 GET CUSTOMER ORDERS - Ambil semua pesanan customer tertentu
/// 
/// Fungsi: Digunakan di OrderHistoryScreen untuk tampilkan pesanan user
```

**✅ getAllOrders() method**
```dart
/// 🏪 GET ALL ORDERS - Ambil semua pesanan (owner/admin only)
/// 
/// Note: Hanya owner yang bisa akses endpoint ini (RLS policy)
```

**✅ updateOrderStatus() method**
```dart
/// 🔄 UPDATE ORDER STATUS - Ubah status pesanan (owner only)
/// 
/// Status flow:
/// 1. 'menunggu' → Customer belum bayar, tunggu bukti transfer
/// 2. 'dibayar' → Bukti pembayaran sudah diterima, siap dikirim
/// 3. 'dikirim' → Barang sudah dikirim ke customer
/// 4. 'selesai' → Barang diterima & transaksi selesai
```

**✅ uploadPaymentProof() method**
```dart
/// 💳 UPLOAD PAYMENT PROOF - Upload bukti pembayaran untuk pesanan
/// 
/// File support: JPG, PNG, PDF (max 5MB)
/// 
/// Setelah upload berhasil, owner bisa lihat bukti & approve pesanan
```

**✅ getOrdersByStatus() method**
```dart
/// 🔎 GET ORDERS BY STATUS - Filter pesanan berdasarkan status (client-side)
/// 
/// Note: Lebih cepat dari server-side filter kalau data sudah load di memory
```

---

### 6. **[lib/providers/wishlist_notifier.dart](lib/providers/wishlist_notifier.dart)** - Wishlist

#### Komentar ditambahkan:

**✅ Class declaration**
```dart
/// ❤️ WISHLIST NOTIFIER - State Management untuk Daftar Ingin Dibeli
/// 
/// Note: Wishlist disimpan LOKAL di device (tidak di database)
/// Keuntungan: Cepat, tidak perlu internet
/// Kekurangan: Tidak sinkron antar device
```

**✅ isInWishlist() method**
```dart
/// 🔍 CHECK IF PRODUCT IN WISHLIST - Cek apakah produk sudah di wishlist
/// 
/// Fungsi: Digunakan untuk show/hide heart icon di UI
/// Contoh: Jika true, tampilkan filled heart (❤️), jika false tampilkan outline (🤍)
```

**✅ loadWishlist() method**
```dart
/// 📥 LOAD WISHLIST - Muat daftar wishlist dari local storage
/// 
/// Note: SharedPreferences membaca dari local storage, sangat cepat
```

**✅ addToWishlist() method**
```dart
/// ➕ ADD TO WISHLIST - Tambah produk ke daftar favorit
/// 
/// Alur:
/// 1. Cek apakah produk sudah ada di wishlist
///    - Jika sudah ada: return true (no action)
///    - Jika belum ada: lanjut ke step 2
/// 2. Kirim ke repository untuk simpan ke SharedPreferences
/// 3. Jika berhasil: 
///    - Tambah produk ke _wishlists
///    - Notify listeners (heart icon berubah jadi filled)
```

**✅ removeFromWishlist() method**
```dart
/// ❌ REMOVE FROM WISHLIST - Hapus produk dari daftar favorit
/// 
/// Note: Data produk tetap di database, hanya dihapus dari wishlist user
```

**✅ toggleWishlist() method**
```dart
/// 🔄 TOGGLE WISHLIST - Tambah/hapus produk dari wishlist (auto detect)
/// 
/// Keuntungan: Hanya perlu 1 method untuk handle add/remove di button
```

---

### 7. **[lib/routes/app_router.dart](lib/routes/app_router.dart)** - Routing

#### Komentar ditambahkan:

**✅ GoRouter setup** (Line ~18-80)
```dart
/// 🗺️ APP ROUTER - Konfigurasi navigasi aplikasi
/// 
/// Menggunakan GoRouter untuk:
/// - Navigation dengan deep linking support
/// - Route guards (redirect based on auth status & role)
/// - Named routes untuk navigation yang clean
/// - Parameter passing (product id, order id, dll)
```

**✅ initialLocation** (Line ~85)
```dart
/// 🏠 INITIAL LOCATION - Route pertama saat app dibuka
```

**✅ redirect() logic** (Line ~87-130)
```dart
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
```

**✅ Routes definition** (Line ~136+)
```dart
/// 📍 ROUTES - Daftar semua route aplikasi

// ===== SPLASH & AUTH ROUTES =====

/// 🎬 SPLASH SCREEN - Loading/intro screen saat app start

/// 🔓 LOGIN SCREEN - Login dengan email & password

/// 📝 REGISTER SCREEN - Daftar akun baru (customer/owner)

// ===== CUSTOMER ROUTES =====

/// 🏠 HOME SCREEN - Main screen menampilkan produk

/// 📦 PRODUCT DETAIL SCREEN - Detail produk tertentu
/// Parameter: :id = productId

/// 🛒 CART SCREEN - Tampilkan keranjang belanja

/// ❤️ WISHLIST SCREEN - Tampilkan daftar produk favorit

/// 💳 CHECKOUT SCREEN - Proses checkout & pembayaran

/// 📋 ORDER HISTORY SCREEN - Riwayat pesanan customer

/// 📄 ORDER DETAIL SCREEN - Detail pesanan tertentu
/// Parameter: :id = orderId

// ===== OWNER ROUTES =====

/// 🏪 OWNER DASHBOARD - Dashboard penjual

/// 📊 PRODUCT MANAGEMENT SCREEN - Kelola daftar produk penjual

/// ➕ ADD PRODUCT SCREEN - Form tambah produk baru

/// ✏️ EDIT PRODUCT SCREEN - Form edit produk
/// Parameter: :id = productId
```

---

## 📖 CARA MEMBACA KOMENTAR

### Format Komentar:

```dart
/// 🎨 SECTION TITLE - Deskripsi singkat
/// 
/// Penjelasan detail tentang apa yang dilakukan method/class ini
/// 
/// Parameter:
/// - param1: Apa itu param1
/// - param2: Apa itu param2
/// 
/// Return: Apa yang dikembalikan
/// 
/// Alur/Langkah:
/// 1. Step pertama
/// 2. Step kedua
/// 3. Step ketiga
/// 
/// Note: Catatan khusus atau warning
```

### Emoji yang Digunakan:

| Emoji | Arti |
|-------|------|
| 🔐 | Authentication/Security |
| 📦 | Products |
| 🛒 | Cart/Shopping |
| ❤️ | Wishlist/Favorites |
| 📋 | Orders |
| 💳 | Payment |
| 🏪 | Owner/Shop |
| 🗺️ | Routing/Navigation |
| 🎬 | Splash/Screen |
| 🔓 | Login |
| 📝 | Registration/Sign up |
| 🏠 | Home |
| 💰 | Money/Price |
| 🚚 | Shipping |
| 💵 | Total/Amount |
| ➕ | Add/Create |
| ❌ | Remove/Delete |
| 🔢 | Quantity |
| 📥 | Load/Input |
| ✏️ | Edit/Update |
| 🔍 | Search/Find |
| 🔄 | Toggle/Update |
| 🎯 | Goal/Purpose |
| 🔧 | Helper/Tool |
| 🗑️ | Clear/Delete |
| 🧹 | Cleanup |

---

## 🎓 CONTOH PENGGUNAAN KOMENTAR SAAT CODING

### Contoh 1: Membaca signUp() method

```dart
/// 📝 SIGN UP - Daftar akun baru
/// 
/// Parameter:
/// - email: Email pengguna
/// - password: Password (minimal 6 karakter)
/// - name: Nama lengkap
/// - phone: Nomor telepon (opsional)
/// - role: 'customer' atau 'owner'

Future<bool> signUp({
  required String email,
  required String password,
  required String name,
  required String phone,
  required String role,
}) async {
  // Bagian ini menjelaskan apa yang akan terjadi:
  // 1. Set loading = true, clear error
  // 2. Kirim ke repository untuk create user di Supabase Auth & DB
  // 3. Jika berhasil: simpan user data & notify listeners
  // 4. Jika gagal: tampilkan error
}
```

**Cara membaca:**
1. Lihat emoji 📝 → ini tentang signup/registration
2. Baca parameter apa yang dibutuhkan
3. Ikuti alur di bawah untuk paham logic-nya
4. Tahu bahwa role bisa 'customer' atau 'owner'

### Contoh 2: Membaca addToCart() method

```dart
/// ➕ ADD TO CART - Tambah produk ke keranjang
/// 
/// Parameter:
/// - productId: ID produk yang ditambahkan
/// - productName: Nama produk (untuk display)
/// - productPrice: Harga satuan
/// - productImage: URL gambar produk
/// - quantity: Jumlah item yang ditambahkan
/// 
/// Return: true jika berhasil, false jika gagal
/// 
/// Alur:
/// 1. Buat CartItem baru dengan data produk
/// 2. Cek apakah produk sudah ada di keranjang
///    - Jika ada: update quantity (tambah)
///    - Jika belum: tambah item baru ke list
/// 3. Notify listeners untuk update UI
```

**Cara membaca:**
1. Emoji ➕ → ini tentang menambah/create
2. Lihat semua parameter yang diperlukan
3. Ikuti alur logic: create item → cek exist → update atau insert
4. Tahu bahwa jika produk duplikat, akan update quantity bukan add duplikat

---

## 💡 TIPS MENGGUNAKAN KOMENTAR

### 1. **Saat Developing**
Baca komentar di method sebelum menggunakannya. Ini lebih cepat daripada baca semua badan function.

### 2. **Saat Debugging**
Jika ada bug, baca alur di komentar lalu bandingkan dengan eksekusi aktual.

### 3. **Saat Refactoring**
Komentar jelaskan intent, bukan implementation. Jadi bisa refactor code tapi intent tetap sama.

### 4. **Saat Code Review**
Gunakan komentar untuk paham logic sebelum discuss dengan team.

### 5. **Saat Learning**
Jika baru dengan codebase, baca komentar dulu sebelum baca kode detail.

---

## 🔗 MAPPING NOTIFIER → SCREEN

Untuk cepat tahu notifier mana yang dipakai screen mana:

| Notifier | Screens |
|----------|---------|
| **AuthNotifier** | LoginScreen, RegisterScreen, SplashScreen |
| **ProductNotifier** | HomeScreen, ProductDetailScreen, ProductManagementScreen, AddProductScreen |
| **CartNotifier** | HomeScreen, CartScreen, CheckoutScreen |
| **OrderNotifier** | CheckoutScreen, OrderHistoryScreen, OrderDetailScreen |
| **WishlistNotifier** | HomeScreen, ProductDetailScreen, WishlistScreen |

---

## 📚 FILE SUMMARY

Total file dengan komentar:
- ✅ lib/main.dart
- ✅ lib/providers/auth_notifier.dart
- ✅ lib/providers/product_notifier.dart
- ✅ lib/providers/cart_notifier.dart
- ✅ lib/providers/order_notifier.dart
- ✅ lib/providers/wishlist_notifier.dart
- ✅ lib/routes/app_router.dart

**Estimasi:**
- ~500+ baris komentar ditambahkan
- Setiap method memiliki penjelasan detail
- Setiap class memiliki header penjelasan
- Setiap parameter dijelaskan
- Setiap alur dijelaskan step-by-step

---

**Last Updated**: December 29, 2025

Semua komentar ditulis dalam Bahasa Indonesia untuk kemudahan pemahaman oleh tim lokal! 🇮🇩
