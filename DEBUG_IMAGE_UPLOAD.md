# 🔍 DEBUG - Analisis Masalah Image Upload & Loading

## 📋 Situasi Saat Ini

Foto produk tidak muncul setelah optimasi dengan CachedNetworkImage. Ada 2 kemungkinan:

1. **main_image_url di database NULL/kosong** → Gambar tidak ter-upload
2. **main_image_url ada tapi URL tidak accessible** → Supabase Storage permission issue

---

## 🔬 ANALISIS KODE

### **1. Upload Process** (supabase_datasource.dart line 181-245)

```dart
// Lokasi file di storage:
final fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

// Upload:
await supabaseService.client.storage
    .from('products')
    .uploadBinary(fileName, imageBytes);

// Generate public URL:
imageUrl = supabaseService.client.storage
    .from('products')
    .getPublicUrl(fileName);
```

**Debuggable logs di upload:**
- ✅ `📸 Starting image upload for user: $userId`
- ✅ `📸 Image size: ${imageBytes.length} bytes`
- ✅ `📸 Uploading to bucket: products, file: $fileName`
- ✅ `✅ Upload successful, generating public URL...`
- ✅ `✅ Image URL generated: $imageUrl`
- ❌ `❌ Storage upload failed: $storageError`

**Kemungkinan error:**
- Bucket 'products' tidak exist
- Bucket permission read-only
- Storage quota exceeded

---

### **2. Database Mapping** (product_model.dart line 133)

```dart
mainImageUrl: (json['main_image_url'] as String?)?.isEmpty ?? true
    ? null
    : json['main_image_url'] as String,
```

**Yang terjadi:**
- Jika `main_image_url` di database = NULL → `mainImageUrl` = null ✅
- Jika `main_image_url` di database = "" (kosong) → `mainImageUrl` = null ✅  
- Jika `main_image_url` di database = "https://..." → `mainImageUrl` = URL ✅

**TIDAK ADA MASALAH DI MAPPING** ✅

---

### **3. Display Logic** (product_detail_screen.dart line 499-510)

```dart
if (product.mainImageUrl != null && product.mainImageUrl!.isNotEmpty)
  // Tampilkan image
else
  // Tampilkan "Belum ada gambar"
```

**Dengan debug logging:**
```dart
debugPrint('🖼️ Product: ${product.name}');
debugPrint('🖼️ Image URL: ${product.mainImageUrl}');
debugPrint('🖼️ URL is empty: ${product.mainImageUrl?.isEmpty ?? true}');
debugPrint('🖼️ URL is null: ${product.mainImageUrl == null}');
```

---

## 🎯 KEMUNGKINAN MASALAH & SOLUSI

### **Kemungkinan 1: Upload Gagal (Logs akan tampilkan ❌)**

**Tanda:**
- Saat create product, lihat log `❌ Storage upload failed:`
- Database: `main_image_url` = NULL
- Display: "Belum ada gambar"

**Penyebab:**
- ❌ Bucket 'products' tidak ada
- ❌ Storage permission issue (bucket is private)
- ❌ Storage quota exceeded
- ❌ File path invalid (Supabase tidak allow 'product_images/' prefix?)

**Solusi:**
1. Buka Supabase dashboard
2. Cek Storage → apakah bucket 'products' ada?
3. Jika tidak ada, create bucket
4. Set bucket public atau add RLS policy

---

### **Kemungkinan 2: Upload Success Tapi URL Invalid**

**Tanda:**
- Log uploads show: `✅ Image URL generated: https://...`
- Database: `main_image_url` = URL value
- Display: Tetap "Belum ada gambar"

**Penyebab:**
- ❌ getPublicUrl() return wrong format
- ❌ URL valid tapi file tidak accessible (permission)
- ❌ CachedNetworkImage error handling

**Solusi:**
1. Copy URL dari log
2. Buka di browser - apakah gambar muncul?
3. Jika error 403 → set bucket to PUBLIC
4. Jika error 404 → file tidak ter-upload

---

### **Kemungkinan 3: CachedNetworkImage Issue**

**Tanda:**
- Log shows URL ada
- Database ada
- Tapi CachedNetworkImage tetap error

**Penyebab:**
- ❌ URL format tidak valid
- ❌ Network issue
- ❌ Shimmer error

**Solusi:**
1. Revert ke Image.network untuk test:
   ```dart
   Image.network(product.mainImageUrl!)
   ```
2. Jika muncul → issue di CachedNetworkImage setup
3. Jika tetap tidak muncul → issue di URL

---

## 📋 TROUBLESHOOTING STEPS

### **Step 1: Jalankan App & Cek Logs**

```bash
flutter run
```

**Cari log patterns:**

```
# Upload berhasil:
📸 Starting image upload for user: abc123
📸 Image size: 45678 bytes
📸 Uploading to bucket: products, file: product_images/1234567890.jpg
✅ Upload successful, generating public URL...
✅ Image URL generated: https://abcd.supabase.co/storage/v1/object/public/products/product_images/1234567890.jpg

# Upload gagal:
❌ Storage upload failed: [error message]

# Display:
🖼️ Product: Tenda XYZ
🖼️ Image URL: https://...
🖼️ URL is empty: false
🖼️ URL is null: false

# atau:
🖼️ Image URL: null
🖼️ URL is null: true
```

**Catat hasilnya:**
- [ ] Upload success log visible?
- [ ] URL format correct?
- [ ] mainImageUrl null atau ada value?

---

### **Step 2: Check Database**

Buka Supabase Console → Database → products table

**Lihat kolom main_image_url:**
- [ ] Ada data (URL) di baris produk?
- [ ] Atau NULL?
- [ ] Atau kosong string ("")?

---

### **Step 3: Check Storage**

Buka Supabase Console → Storage → products bucket

**Apakah ada folder product_images?**
- [ ] Ada
- [ ] Tidak ada

**Apakah ada file di dalamnya?**
- [ ] Ada (.jpg files)
- [ ] Tidak ada

---

### **Step 4: Test URL di Browser**

Copy URL dari log, buka di browser (Chrome):

```
https://abcd1234.supabase.co/storage/v1/object/public/products/product_images/1234567890.jpg
```

**Hasil:**
- ✅ Gambar muncul → Storage OK, issue di Flutter
- ❌ Error 403 → Bucket permission issue
- ❌ Error 404 → File tidak ada / path salah
- ❌ Error 500 → Supabase server issue

---

## 🛠️ QUICK FIX CHECKLIST

Jika sudah tahu masalahnya:

### **Jika: Upload Gagal (❌)**
1. Buka Supabase Storage
2. Create bucket 'products' (jika belum ada)
3. Buka bucket settings
4. Set privacy ke PUBLIC
5. Re-create product dengan image

### **Jika: URL Ada Tapi 403**
1. Buka Supabase Storage → products bucket
2. Klik menu (3 titik) → Edit bucket
3. Set to PUBLIC
4. Clear app cache: `flutter clean`
5. Re-run: `flutter run`

### **Jika: URL Ada Tapi 404**
1. Check apakah file ada di Storage
2. Jika tidak ada → upload gagal (check disk space, permissions)
3. Jika ada tapi salah path → update database record

### **Jika: CachedNetworkImage Issue**
1. Test dengan Image.network dulu
2. Bersihkan cache: `flutter clean`
3. Rebuild package: `flutter pub get`
4. Run: `flutter run`

---

## 🧪 TEST KODE

Untuk test image loading lebih detail, bisa tambah:

```dart
// Di product_detail_screen.dart
CachedNetworkImage(
  imageUrl: product.mainImageUrl!,
  progressIndicatorBuilder: (context, url, progress) {
    debugPrint('🔄 Loading: ${progress.progress * 100}%');
    return Shimmer.fromColors(...);
  },
  errorWidget: (context, url, error) {
    debugPrint('❌ Error loading: $url');
    debugPrint('❌ Error: $error');
    debugPrint('❌ Error type: ${error.runtimeType}');
    return ErrorWidget(...);
  },
)
```

---

## 🎯 ROOT CAUSE MOST LIKELY

Berdasarkan code review:

**Most likely problem:** 🏆 **Upload failed silently**

Alasan:
1. Storage upload error di-catch dengan `imageUrl = null`
2. Product dibuat WITHOUT main_image_url (line 231)
3. Database: main_image_url = NULL
4. Display: "Belum ada gambar" ✅ (benar, sesuai logic)

**Verifikasi:**
- Cek log saat create product - apakah ada error?
- Cek database - main_image_url NULL?
- Jika ya → Storage bucket issue

---

## 📞 NEXT ACTION

1. ✅ Buat IMAGE_TROUBLESHOOTING.md (DONE)
2. 🔄 Run app dan cek logs
3. 🔄 Follow troubleshooting steps
4. 🔄 Report findings
5. 🔄 Apply specific fix

---

**Updated:** December 29, 2025
