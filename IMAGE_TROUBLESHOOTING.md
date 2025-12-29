# 🖼️ TROUBLESHOOTING - Foto Tidak Muncul

## ❓ Masalah: Foto Produk Tidak Muncul

Jika foto produk tidak tampil, ikuti checklist di bawah:

---

## ✅ CHECKLIST DEBUGGING

### 1. **🔍 Cek URL di Console/Logcat**
   
**Jalankan app dan buka Logcat:**
```bash
flutter run
```

**Cari log dengan keyword:**
- `🖼️ Product:`
- `🖼️ Image URL:`
- `❌ Image load error:`

**Log akan tampilkan:**
```
🖼️ Product: Tenda XYZ
🖼️ Image URL: https://abcd1234.supabase.co/storage/v1/object/public/products/image.jpg
```

Jika URL kosong atau null → **Masalah ada di database atau upload**

---

### 2. **📋 Cek Database - Produk punya mainImageUrl?**

**Buka Supabase Console:**
1. Ke https://supabase.com/dashboard
2. Pilih project Anda
3. Klik **Database** → **products**
4. Lihat kolom `main_image_url`
5. Apakah ada value atau NULL?

**Hasil:**
- ✅ Ada URL → Masalah di image loading code
- ❌ NULL/kosong → Masalah di upload atau create product

---

### 3. **🔐 Cek Supabase Storage Permissions**

**Jika URL ada tapi image tetap error:**

1. Buka Supabase Console
2. Klik **Storage**
3. Pilih bucket **products**
4. Klik **Policies** (tab di atas)
5. Cari policy yang allow PUBLIC READ

**Policy harus ada seperti ini:**
```
SELECT (auth.role() = 'anon'::text OR auth.role() = 'authenticated'::text)
```

Jika belum ada:
1. Klik **New Policy**
2. Pilih **For SELECT**
3. Pilih **Without any restrictions** (untuk public)
4. Save

---

### 4. **📱 Cek URL Format**

URL yang benar dari Supabase harus seperti:
```
https://[PROJECT_ID].supabase.co/storage/v1/object/public/[BUCKET]/[FILE_PATH]
```

Contoh:
```
https://abcd1234.supabase.co/storage/v1/object/public/products/product_images/1234567890.jpg
```

**Jika URL tidak sesuai format:**
- ❌ Cek nama bucket di code (harus **products**)
- ❌ Cek path file di code

---

### 5. **🔄 Solusi Untuk Berbagai Kasus**

#### **Kasus A: URL NULL di Database**

Produk dibuat tanpa gambar. Solusi:

**Option 1: Edit produk dan upload gambar**
```dart
// Di owner dashboard, owner bisa edit produk
// Edit screen seharusnya allow upload image
```

**Option 2: Delete dan buat ulang dengan image**

---

#### **Kasus B: URL ada tapi error 403 (Permission Denied)**

Bucket privacy setting salah.

**Solusi:**
1. Buka Supabase Storage
2. Klik bucket **products**
3. Klik icon menu (3 titik) → **Edit bucket**
4. Ubah ke **Public**
5. Save

---

#### **Kasus C: URL ada tapi 404 (Not Found)**

File path salah di database atau file sudah dihapus.

**Solusi:**
1. Upload ulang gambar
2. Catat exact path dari upload
3. Simpan path yang benar ke database

---

### 6. **🧪 Test Image URL Langsung**

Copy URL dari error message, buka di browser:

**Contoh:**
```
https://abcd1234.supabase.co/storage/v1/object/public/products/product_images/1234567890.jpg
```

**Hasil:**
- ✅ Gambar muncul di browser → Masalah di Flutter code
- ❌ Error 403/404 → Masalah di Supabase storage
- ❌ Halaman kosong → Masalah di file atau path

---

### 7. **💡 Quick Fixes**

#### **Fix #1: Clear Cache**
```bash
# Stop app dulu
flutter clean
flutter pub get
flutter run
```

#### **Fix #2: Hard Refresh (tidak cache)**
Edit CachedNetworkImage properties:
```dart
CachedNetworkImage(
  imageUrl: product.mainImageUrl!,
  cacheKey: '${product.id}_${product.updatedAt}', // Unique key
  memCacheHeight: 300,
  memCacheWidth: 400,
)
```

#### **Fix #3: Add Error Details**
Sekarang UI sudah menampilkan URL yang failed di error screen.

---

## 📊 DEBUGGING FLOW CHART

```
Foto tidak muncul?
    ↓
Buka Logcat, cari "🖼️ Image URL"
    ↓
├─ URL NULL/kosong?
│   ├─ Check Database (main_image_url NULL?)
│   │   ├─ Ya → Produk dibuat tanpa image
│   │   │   └─ Solusi: Upload image saat edit produk
│   │   └─ Tidak → Bug di code
│   │       └─ Solusi: Debug Product.fromJson()
│   └─ 
├─ URL ada tapi error?
│   ├─ Error 403? → Storage permission issue
│   │   └─ Solusi: Set bucket ke PUBLIC
│   ├─ Error 404? → File not found
│   │   └─ Solusi: Check path atau upload ulang
│   └─ Error lain? → Network issue
│       └─ Solusi: Check internet connection
│
└─ URL valid & storage ok? → Flutter code issue
    ├─ Check imports (cached_network_image, shimmer)
    ├─ Check CachedNetworkImage setup
    └─ Solusi: flutter clean + rebuild
```

---

## 🛠️ DEBUGGING CODE YANG SUDAH DITAMBAHKAN

File `product_detail_screen.dart` sekarang punya logging di `_buildImageGallery()`:

```dart
debugPrint('🖼️ Product: ${product.name}');
debugPrint('🖼️ Image URL: ${product.mainImageUrl}');
debugPrint('🖼️ URL is empty: ${product.mainImageUrl?.isEmpty ?? true}');
debugPrint('🖼️ URL is null: ${product.mainImageUrl == null}');
```

**Cara membaca log:**
- `URL is null: true` → mainImageUrl = null
- `URL is empty: true` → mainImageUrl = "" (kosong)
- `URL is null: false, is empty: false` → Ada URL, tapi error loading

Jika ada error saat load image:
```dart
debugPrint('❌ Image load error: $error');
debugPrint('❌ Tried URL: $url');
```

---

## 🚨 COMMON ISSUES & SOLUTIONS

| Issue | Penyebab | Solusi |
|-------|---------|--------|
| "Belum ada gambar" | mainImageUrl = null | Upload image saat create/edit product |
| "Gambar tidak tersedia" + 403 | Storage privacy | Set bucket to PUBLIC |
| "Gambar tidak tersedia" + 404 | File not found | Upload ulang image |
| Shimmer terus loading | URL invalid | Check URL di console |
| Error message tidak informatif | Missing logging | Update ke versi terbaru |

---

## ✅ NEXT STEPS

1. **Jalankan app** → `flutter run`
2. **Buka Logcat** → search "🖼️"
3. **Screenshot error** (kalau ada)
4. **Follow checklist** di atas
5. **Report jika masih error** dengan log details

---

**Last Updated:** December 29, 2025

Sekarang error handling & logging sudah lebih baik untuk debugging! 🔍
