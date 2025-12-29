# 📋 Database Setup Guide - Begya Outdoor App

## ✅ Complete Database Schema

### Step 1: Create Categories Table

```sql
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert hardcoded categories
INSERT INTO categories (id, name) VALUES 
('tenda', 'Tenda'),
('tas', 'Tas'),
('sepatu', 'Sepatu'),
('survival', 'Survival')
ON CONFLICT (id) DO NOTHING;
```

### Step 2: Create Products Table

```sql
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id TEXT NOT NULL REFERENCES categories(id),
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
```

### Step 3: Create Users Table (Public)

```sql
-- If you need a public users table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name TEXT,
  role TEXT DEFAULT 'customer',
  email TEXT UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔐 Row Level Security (RLS) Policies

### Products RLS

```sql
-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Anyone can read products
CREATE POLICY "Anyone can read products"
ON products FOR SELECT
USING (true);

-- Only owner can insert/update/delete their products
CREATE POLICY "Owners can insert their own products"
ON products FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Owners can update their own products"
ON products FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Owners can delete their own products"
ON products FOR DELETE
USING (auth.uid() = user_id);
```

### Categories RLS

```sql
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read categories"
ON categories FOR SELECT
USING (true);
```

## 👤 Test Users Setup

### Owner User (Penjual)

```sql
-- Create user via auth (use Supabase Auth UI)
-- Email: anggi@gmail.com
-- Password: anggi123

-- Then insert into public.users:
INSERT INTO public.users (id, full_name, role, email) 
VALUES (
  '7950fad4-521b-40dd-9308-9d652d87719f',
  'Anggi',
  'owner',
  'anggi@gmail.com'
)
ON CONFLICT (id) DO NOTHING;
```

### Customer User (Pembeli)

```sql
-- Create user via auth (use Supabase Auth UI)
-- Email: resi@gmail.com
-- Password: resi123

-- Then insert into public.users:
INSERT INTO public.users (id, full_name, role, email) 
VALUES (
  'd8cde6c3-c305-410f-bb8c-d53d8f63e56c',
  'Resi',
  'customer',
  'resi@gmail.com'
)
ON CONFLICT (id) DO NOTHING;
```

## 📦 Sample Products (For Testing)

```sql
-- Insert test products by owner (anggi@gmail.com)
INSERT INTO products (category_id, name, description, price, stock, user_id) 
VALUES 
(
  'tenda',
  'Tenda Camping 2 Orang',
  'Tenda berkualitas tinggi dengan material tahan lama. Cocok untuk pendakian gunung, camping, dan outdoor lainnya. Fitur waterproof dan ventilasi udara yang baik.',
  450000,
  10,
  '7950fad4-521b-40dd-9308-9d652d87719f'
),
(
  'tas',
  'Tas Hiking 50L',
  'Tas hiking kapasitas 50 liter dengan banyak kantong dan tali yang nyaman. Material berkualitas tinggi yang tahan air.',
  350000,
  5,
  '7950fad4-521b-40dd-9308-9d652d87719f'
),
(
  'sepatu',
  'Sepatu Hiking Waterproof',
  'Sepatu hiking dengan teknologi waterproof terbaru. Nyaman digunakan untuk medan berat dan berkerikil.',
  550000,
  8,
  '7950fad4-521b-40dd-9308-9d652d87719f'
),
(
  'survival',
  'Kit Survival 15 in 1',
  'Kit survival lengkap dengan 15 item penting untuk outdoor. Termasuk compass, whistle, fire starter, dan lainnya.',
  150000,
  20,
  '7950fad4-521b-40dd-9308-9d652d87719f'
);
```

## 🧪 Testing Workflow

### 1. **Login as Owner (anggi@gmail.com)**
   - Email: `anggi@gmail.com`
   - Password: `anggi123`
   - Navigate to "Kelola Produk"
   - Verify all products appear correctly
   - Try to edit/delete a product

### 2. **Add New Product as Owner**
   - Click "Tambah Produk"
   - Fill form:
     - Nama: "Produk Test"
     - Kategori: Select one (tenda/tas/sepatu/survival)
     - Harga: 100000
     - Stok: 5
     - Deskripsi: "Deskripsi test"
   - Upload image (optional)
   - Click "Simpan"
   - Verify product appears in "Kelola Produk"

### 3. **Logout and Login as Customer (resi@gmail.com)**
   - Email: `resi@gmail.com`
   - Password: `resi123`
   - Navigate to Home
   - Verify all owner's products appear in product list
   - Test category filter (Semua, Tenda, Tas, Sepatu, Survival)

### 4. **Product Detail Screen**
   - Click on any product
   - Verify:
     - ✅ Product name displays correctly
     - ✅ Price shows correctly
     - ✅ Stock status shows correctly
     - ✅ Category badge displays
     - ✅ Owner info displays (ownerId)
     - ✅ Quantity selector works
   - Add to wishlist → Check ❤️ button turns red
   - Add to cart → Verify snackbar shows

### 5. **Wishlist Feature**
   - Click wishlist icon on product detail
   - Navigate to Wishlist (heart icon in app bar)
   - Verify added product appears
   - Remove product from wishlist
   - Verify it disappears from wishlist

### 6. **Cart & Checkout**
   - Add multiple products to cart
   - Click cart icon in app bar
   - Verify:
     - ✅ All products display with correct data
     - ✅ Product names correct
     - ✅ Prices correct
     - ✅ Images load (or show placeholder)
     - ✅ Quantity controls work
     - ✅ Total calculation correct
   - Click "Lanjut ke Checkout"
   - Fill shipping address
   - Verify order summary correct
   - Click "Bayar Sekarang"

### 7. **Owner View (Kelola Produk)**
   - Login as owner again
   - Navigate to "Kelola Produk"
   - Verify all products they added appear
   - Edit a product → change price/stock
   - Verify changes saved
   - Delete a product → confirm deletion

## 🔧 Common Issues & Solutions

### Issue: Products not showing in home screen
**Solution:** 
- Verify products are inserted with correct `user_id`
- Check RLS policies allow SELECT
- Verify products have valid `category_id` from categories table

### Issue: Can't add products as owner
**Solution:**
- Verify user role is 'owner' in public.users table
- Check user_id is UUID format
- Verify storage bucket 'products' exists for image upload

### Issue: Products not appearing in "Kelola Produk"
**Solution:**
- Verify user is logged in with correct ID
- Check `getProductsByOwner()` query uses `user_id` field
- Verify products exist in database with matching `user_id`

### Issue: Wishlist not persisting
**Solution:**
- Wishlist uses SharedPreferences (local device storage)
- Data persists within app session
- Clear app data to reset wishlist

### Issue: Cart calculations wrong
**Solution:**
- Verify CartNotifier correctly multiplies quantity × price
- Check shippingCost = 50000 (fixed)
- Verify all product prices are NUMERIC type in database

## 📊 Database Schema Summary

| Table | Fields | Purpose |
|-------|--------|---------|
| **categories** | id, name, created_at | Product categories (tenda, tas, sepatu, survival) |
| **products** | id, category_id, name, description, price, stock, user_id, created_at | Products added by owners |
| **public.users** | id, full_name, role, email, created_at | User information (owner/customer) |

## 🚀 Deployment Checklist

- [ ] Create all tables with correct schema
- [ ] Enable RLS on products & categories tables
- [ ] Create RLS policies (read for all, write only by owner)
- [ ] Create storage bucket 'products' for image uploads
- [ ] Insert 4 categories (tenda, tas, sepatu, survival)
- [ ] Create test users (owner & customer)
- [ ] Insert sample products by owner user
- [ ] Test complete workflow (login → browse → add wishlist → cart → checkout)
- [ ] Verify all product data flows correctly through UI

---

**Last Updated:** December 27, 2025
**Status:** Ready for Production Testing
