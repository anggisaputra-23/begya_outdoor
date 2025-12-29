/// Konstanta aplikasi Begya Outdoor
class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://ilovpuvrezassnwtmssg.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlsb3ZwdXZyZXphc3Nud3Rtc3NnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0MTg1MTUsImV4cCI6MjA4MDk5NDUxNX0.xzuQPmcAiUYoyqiLvKKWqXSy1vdGA-4oD7ZmCVrmVBI';

  // API Configuration
  static const int requestTimeoutMs = 30000;
  static const int connectTimeoutMs = 15000;

  // App Configuration
  static const String appName = 'Begya Outdoor';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Katalog dan Penjualan Alat Outdoor';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxProductImages = 5;

  // Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Currency
  static const String currencySymbol = 'Rp';
  static const String currencyCode = 'IDR';

  // Shipping
  static const double shippingCost = 50000; // Biaya pengiriman

  // Order Status
  static const Map<String, String> orderStatus = {
    'pending': 'Menunggu Pembayaran',
    'paid': 'Dibayar',
    'shipped': 'Dikirim',
    'delivered': 'Selesai',
    'cancelled': 'Dibatalkan',
  };

  // User Roles
  static const String roleOwner = 'owner';
  static const String roleCustomer = 'customer';

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration shortCacheDuration = Duration(minutes: 5);

  // Error Messages
  static const String errorNetworkConnection = 'Tidak ada koneksi internet';
  static const String errorServerError = 'Terjadi kesalahan server';
  static const String errorUnauthorized = 'Anda tidak memiliki akses';
  static const String errorNotFound = 'Data tidak ditemukan';
  static const String errorValidation = 'Data tidak valid';
  static const String errorUnknown = 'Terjadi kesalahan yang tidak diketahui';

  // Success Messages
  static const String successLogin = 'Login berhasil';
  static const String successRegister = 'Registrasi berhasil';
  static const String successLogout = 'Logout berhasil';
  static const String successAddToCart = 'Produk ditambahkan ke keranjang';
  static const String successCheckout = 'Pesanan berhasil dibuat';
  static const String successProductCreated = 'Produk berhasil ditambahkan';
  static const String successProductUpdated = 'Produk berhasil diperbarui';
  static const String successProductDeleted = 'Produk berhasil dihapus';

  // Validation Errors
  static const String errorEmailInvalid = 'Email tidak valid';
  static const String errorPasswordTooShort = 'Password minimal 6 karakter';
  static const String errorPasswordMismatch = 'Password tidak cocok';
  static const String errorNameEmpty = 'Nama tidak boleh kosong';
  static const String errorPriceInvalid = 'Harga harus lebih dari 0';
  static const String errorStockInvalid = 'Stok harus angka positif';
}
