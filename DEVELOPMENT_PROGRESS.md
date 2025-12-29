# 📱 Dokumentasi Begya Outdoor Mobile App

## 🎯 Status Implementasi

### ✅ SUDAH SELESAI:

1. **pubspec.yaml** - Semua dependencies sudah ditambahkan:
   - `supabase_flutter` untuk backend
   - `provider` untuk state management
   - `image_picker` & `cached_network_image` untuk image handling
   - `lottie` untuk animasi
   - `equatable` & `dartz` untuk clean code patterns
   - Dan lainnya

2. **Core Theme & Colors** (`lib/core/theme/`)
   - `app_colors.dart` - Palet warna lengkap (hijau #27391C, hitam, putih)
   - `app_theme.dart` - ThemeData Material3 design
   - `text_styles.dart` - Typography yang konsisten

3. **Core Constants** (`lib/core/constants/`)
   - `app_constants.dart` - Supabase config, messages, routes
   - `routes.dart` - Semua route paths

4. **Core Services** (`lib/core/services/`)
   - `supabase_service.dart` - Singleton untuk manage Supabase connection

5. **Data Models** (`lib/data/models/`)
   - `user_model.dart` - User dengan role owner/customer
   - `category_model.dart` - Kategori produk
   - `product_model.dart` - Product dengan detail lengkap
   - `product_image_model.dart` - Multiple images per product
   - `cart_item_model.dart` - Item di keranjang
   - `cart_model.dart` - Keranjang belanja
   - `order_model.dart` - Pesanan dengan status tracking

6. **Data Datasource** (`lib/data/datasources/`)
   - `supabase_datasource.dart` - Semua CRUD operations

7. **Repository Layer** (`lib/data/repositories/`)
   - `product_repository.dart` - Abstract + Implementation dengan error handling

### 🔄 PERLU DILANJUTKAN:

#### **TAHAP 1: Repository Layer (Remaining)**
- [ ] `auth_repository.dart` - Sign up, sign in, sign out, getCurrentUser
- [ ] `order_repository.dart` - Create, get, update orders
- [ ] `cart_repository.dart` - Manage cart items

#### **TAHAP 2: State Management (Provider)**
- [ ] `providers/auth_provider.dart` - User authentication state
- [ ] `providers/product_provider.dart` - Product list & detail state
- [ ] `providers/cart_provider.dart` - Cart management state
- [ ] `providers/order_provider.dart` - Order state

#### **TAHAP 3: Screens (Presentation Layer)**
- [ ] `screens/splash_screen.dart` - Splash dengan animasi
- [ ] `screens/login_screen.dart` - Login form
- [ ] `screens/register_screen.dart` - Register form
- [ ] `screens/home_screen.dart` - Product listing dengan filter
- [ ] `screens/product_detail_screen.dart` - Detail produk + hero animation
- [ ] `screens/cart_screen.dart` - Keranjang belanja
- [ ] `screens/checkout_screen.dart` - Form checkout
- [ ] `screens/payment_proof_screen.dart` - Upload bukti transfer
- [ ] `screens/order_history_screen.dart` - Riwayat pesanan
- [ ] `screens/order_detail_screen.dart` - Detail pesanan

#### **TAHAP 4: Owner Dashboard**
- [ ] `screens/owner_dashboard_screen.dart` - Dashboard owner
- [ ] `screens/product_management_screen.dart` - List produk milik owner
- [ ] `screens/add_product_screen.dart` - Form tambah produk
- [ ] `screens/edit_product_screen.dart` - Form edit produk
- [ ] `screens/order_management_screen.dart` - Pesanan masuk

#### **TAHAP 5: Widgets & Components**
- [ ] Reusable button widgets
- [ ] Product card dengan hero animation
- [ ] Loading & error widgets
- [ ] Bottom sheets, dialogs

#### **TAHAP 6: App Router & Main**
- [ ] `routes/app_router.dart` - GoRouter configuration
- [ ] Update `main.dart` - App initialization

---

## 📊 Struktur Database Supabase

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  role TEXT NOT NULL CHECK (role IN ('owner', 'customer')),
  profile_image_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- Categories table
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL(12, 2) NOT NULL CHECK (price > 0),
  stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  main_image_url TEXT,
  rating INTEGER,
  review_count INTEGER,
  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP,
  CONSTRAINT valid_rating CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5))
);

-- Product Images table
CREATE TABLE product_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  "order" INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(product_id, "order")
);

-- Carts table
CREATE TABLE carts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- Cart Items table
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  product_name TEXT NOT NULL,
  product_price DECIMAL(12, 2) NOT NULL,
  product_image TEXT,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(cart_id, product_id)
);

-- Orders table
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  customer_address TEXT NOT NULL,
  items JSONB NOT NULL,
  subtotal DECIMAL(12, 2) NOT NULL,
  shipping_cost DECIMAL(12, 2) NOT NULL,
  total DECIMAL(12, 2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled')),
  payment_method TEXT,
  payment_proof_url TEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- Indexes untuk performance
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_owner_id ON products(owner_id);
CREATE INDEX idx_product_images_product_id ON product_images(product_id);
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX idx_cart_items_product_id ON cart_items(product_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
```

---

## 🏗️ Struktur Folder Current

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart ✅
│   │   ├── app_theme.dart ✅
│   │   └── text_styles.dart ✅
│   ├── constants/
│   │   ├── app_constants.dart ✅
│   │   └── routes.dart ✅
│   └── services/
│       └── supabase_service.dart ✅
│
├── data/
│   ├── models/
│   │   ├── user_model.dart ✅
│   │   ├── category_model.dart ✅
│   │   ├── product_model.dart ✅
│   │   ├── product_image_model.dart ✅
│   │   ├── cart_item_model.dart ✅
│   │   ├── cart_model.dart ✅
│   │   ├── order_model.dart ✅
│   │   └── models.dart ✅ (export file)
│   ├── datasources/
│   │   └── supabase_datasource.dart ✅
│   └── repositories/
│       ├── product_repository.dart ✅
│       ├── auth_repository.dart (TODO)
│       ├── order_repository.dart (TODO)
│       └── cart_repository.dart (TODO)
│
├── presentation/
│   ├── auth/ (TODO)
│   ├── home/ (TODO)
│   ├── product/ (TODO)
│   ├── cart/ (TODO)
│   ├── order/ (TODO)
│   ├── owner/ (TODO)
│   └── widgets/ (TODO)
│
├── providers/ (TODO)
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   └── order_provider.dart
│
├── routes/
│   └── app_router.dart (TODO)
│
└── main.dart (TODO)
```

---

## 🚀 Langkah Selanjutnya (Next Steps)

### Klik di setiap tahap untuk melihat detail implementasi:

### TAHAP 1: Selesaikan Repository Layer
**File yang perlu dibuat:**
- `lib/data/repositories/auth_repository.dart` - Abstract + Impl
- `lib/data/repositories/order_repository.dart` - Abstract + Impl
- `lib/data/repositories/cart_repository.dart` - Abstract + Impl

### TAHAP 2: Setup Provider (State Management)
Membuat providers untuk manage state aplikasi secara terpusat

### TAHAP 3-4: Membuat semua screens dengan UI yang responsif

### TAHAP 5: Widget components yang reusable

### TAHAP 6: App router configuration

### TAHAP 7: Update main.dart dengan Supabase initialization

---

## 💡 Tips Implementasi

1. **Untuk setiap screen**, ikuti pattern:
   - StatefulWidget / Consumer<Provider>
   - Build UI dengan theme colors & text styles
   - Handle loading, error, dan success states

2. **Hero Animation** untuk product detail transition:
   ```dart
   Hero(
     tag: 'product_${productId}',
     child: Image.network(imageUrl),
   )
   ```

3. **Provider untuk Cart:**
   - Simpan cart items di local state
   - Validasi stock sebelum checkout
   - Clear cart setelah order sukses

4. **Owner CRUD:**
   - Upload image ke Supabase Storage
   - Validate form sebelum submit
   - Show success/error snackbar

---

## 🎨 UI/UX Guidelines (SUDAH DITERAPKAN)

✅ **Color Scheme:**
- Primary: #27391C (Hijau Alam)
- Secondary: #4CAF50 (Hijau Muda)
- Accent: Hitam & Putih

✅ **Typography:**
- Heading: fontSize 20-32, fontWeight w700-w900
- Body: fontSize 12-16, fontWeight w400-w600
- Button: fontSize 14, fontWeight w600, uppercase

✅ **Spacing & Radius:**
- Padding: 12, 16, 24, 32
- BorderRadius: 8, 12, 16

✅ **Animations:**
- Fade In/Out untuk list
- Hero Animation untuk product detail
- Smooth transitions antara screens

---

## 📝 Environment Setup

**Supabase Project:**
- URL: https://ilovpuvrezassnwtmssg.supabase.co
- Anon Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (sudah di app_constants.dart)

**Run Flutter App:**
```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios
```

---

## ✨ Next Actions

Tinggal kita lanjutkan dengan:
1. ✅ Datasource & Repository (Product) - SELESAI
2. ⏳ Repository untuk Auth & Order
3. ⏳ State Management dengan Provider
4. ⏳ UI Screens

Mau lanjut ke tahap mana dulu? 😊
