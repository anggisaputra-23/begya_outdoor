# Supabase RLS Policy Setup untuk Image Upload

## Problem
Gambar tidak terupload ke bucket 'products' meski bucket sudah public.

## Solution
Anda perlu set RLS (Row Level Security) Policy di bucket 'products' untuk mengizinkan authenticated users upload.

### Steps di Supabase Dashboard:

1. **Go to Storage → Policies**
2. **Select bucket 'products'**
3. **Create new policy untuk upload:**
   - Click "New Policy" button
   - Select "For INSERT"
   - Template: "Authenticated users can upload"
   - Di bagian "WITH CHECK" expression, paste:
   ```sql
   auth.role() = 'authenticated'
   ```
   - Click "Review" then "Save policy"

4. **Create policy untuk download/public access:**
   - Click "New Policy" button
   - Select "For SELECT"  
   - Template: "Anyone can download/view"
   - Di bagian WHERE expression:
   ```sql
   true
   ```
   - Click "Review" then "Save policy"

### Atau bisa pakai SQL langsung di Supabase SQL Editor:

```sql
-- Allow authenticated users to upload
CREATE POLICY "Allow authenticated users to upload"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'products' 
  AND auth.role() = 'authenticated'
);

-- Allow public download
CREATE POLICY "Allow public access to images"
ON storage.objects
FOR SELECT
USING (
  bucket_id = 'products'
);
```

## Verification
Setelah policy ditambah:
1. Coba buat produk baru dengan foto
2. Cek bucket 'products' - foto seharusnya ada
3. Cek table 'products' - main_image_url seharusnya terisi

## Jika masih error
Check console logs yang dimulai dengan emoji 📸, ❌, atau ✅ untuk melihat:
- 📸 Upload process details
- ✅ Success messages
- ❌ Error messages dengan error type spesifik
