# 🚀 Quick Start Guide - Begya Outdoor

## ⚡ 5-Minute Setup

### 1. Database Setup (Supabase)

Copy & paste these SQL scripts into Supabase SQL Editor:

**Script 1: Create Tables**
```sql
-- Categories
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO categories (id, name) VALUES 
('tenda', 'Tenda'),
('tas', 'Tas'),
('sepatu', 'Sepatu'),
('survival', 'Survival')
ON CONFLICT (id) DO NOTHING;

-- Products
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

CREATE INDEX idx_products_user_id ON products(user_id);
CREATE INDEX idx_products_category_id ON products(category_id);

-- Public Users (optional)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name TEXT,
  role TEXT DEFAULT 'customer',
  email TEXT UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Script 2: Enable RLS & Create Policies**
```sql
-- Products RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read products"
ON products FOR SELECT USING (true);

CREATE POLICY "Owners can insert"
ON products FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Owners can update"
ON products FOR UPDATE USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Owners can delete"
ON products FOR DELETE USING (auth.uid() = user_id);

-- Categories RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read categories"
ON categories FOR SELECT USING (true);
```

### 2. Create Storage Bucket

In Supabase Storage:
- Create bucket named `products`
- Set to Public (for image URLs)

### 3. Create Test Users

**Via Supabase Auth:**
1. Create user: `anggi@gmail.com` / `anggi123`
2. Create user: `resi@gmail.com` / `resi123`

**Note down their UUIDs, then run Script 3:**

**Script 3: Add Users to public.users table**
```sql
INSERT INTO public.users (id, full_name, role, email) 
VALUES 
  ('UUID_OF_ANGGI_USER', 'Anggi', 'owner', 'anggi@gmail.com'),
  ('UUID_OF_RESI_USER', 'Resi', 'customer', 'resi@gmail.com')
ON CONFLICT (id) DO NOTHING;
```

### 4. Insert Test Products

```sql
INSERT INTO products (category_id, name, description, price, stock, user_id) 
VALUES 
(
  'tenda',
  'Tenda Camping 2 Orang',
  'Tenda berkualitas tinggi dengan fitur waterproof',
  450000,
  10,
  'UUID_OF_ANGGI_USER'  -- Replace with actual UUID
),
(
  'tas',
  'Tas Hiking 50L',
  'Tas hiking kapasitas 50 liter dengan banyak kantong',
  350000,
  5,
  'UUID_OF_ANGGI_USER'  -- Replace with actual UUID
),
(
  'sepatu',
  'Sepatu Hiking Waterproof',
  'Sepatu dengan teknologi waterproof terbaru',
  550000,
  8,
  'UUID_OF_ANGGI_USER'  -- Replace with actual UUID
),
(
  'survival',
  'Kit Survival 15 in 1',
  'Kit survival lengkap dengan 15 item',
  150000,
  20,
  'UUID_OF_ANGGI_USER'  -- Replace with actual UUID
);
```

---

## 🎮 Run the App

```bash
flutter run
```

---

## 📱 Test Flow

### As Owner (anggi@gmail.com / anggi123)
1. Login → See "Kelola Produk"
2. Click "Kelola Produk" → See products you added
3. Click "Tambah Produk" → Add new product
4. Edit/Delete products

### As Customer (resi@gmail.com / resi123)
1. Login → See Home with all products
2. Click product → See detail from database
3. Add to Wishlist → ❤️ appears
4. Add to Cart → Shows in cart screen
5. Click Cart → See all items with correct prices
6. Checkout → Complete order

---

## ✅ Checklist

- [ ] Supabase project created
- [ ] SQL scripts executed (all 3)
- [ ] Storage bucket 'products' created
- [ ] Test users created (anggi & resi)
- [ ] Products inserted with correct owner UUID
- [ ] `AppConstants` has correct Supabase URL and key
- [ ] App runs: `flutter run`
- [ ] Owner can add products
- [ ] Customer sees products
- [ ] Product detail shows real data
- [ ] Wishlist works
- [ ] Cart shows correct data
- [ ] Checkout works

---

## 🆘 Troubleshooting

### Products not showing
- Check: Products inserted? → Check Supabase database
- Check: RLS policies enabled? → Verify SELECT policy exists
- Check: Category ID correct? → Should be: tenda, tas, sepatu, survival

### Can't add products
- Check: User role is 'owner'? → Check public.users table
- Check: Logged in? → Check AuthNotifier state
- Check: Storage bucket exists? → Create 'products' bucket

### Product detail blank
- Check: Product has correct user_id? → Verify in database
- Check: Home screen loads products? → See if filtering works
- Check: Console for errors? → Check Flutter logs

### Wishlist not saving
- Check: Using SharedPreferences → Data persists in session
- Check: Local storage file? → Data stored in device

### Cart calculations wrong
- Check: Product prices are NUMERIC? → Not STRING
- Check: Quantity calculation? → Should be price × quantity
- Check: Shipping cost? → Fixed at 50000

---

## 📚 Documentation

- **DATABASE_SETUP_GUIDE.md** - Complete database setup
- **TESTING_WORKFLOW.md** - Detailed test scenarios
- **FIXES_SUMMARY.md** - All fixes applied

---

## 🎯 What's Working Now

✅ **Owner Features:**
- Login with email/password
- View products they created
- Add new products (with categories: tenda, tas, sepatu, survival)
- Edit product details
- Delete products
- Optional image upload

✅ **Customer Features:**
- Login with email/password
- Browse all products
- Filter by category
- Search products
- View real product details (from database)
- Add to wishlist
- Add to cart with correct pricing
- Adjust quantities
- Remove from cart
- Proceed to checkout

✅ **Data Integrity:**
- Product names, prices, stock loaded from database
- Category IDs match database (tenda, tas, sepatu, survival)
- Owner information displayed
- Wishlist stored locally
- Cart data stored in memory
- All calculations correct

---

**Status:** ✅ Ready for Production  
**Last Updated:** December 27, 2025
