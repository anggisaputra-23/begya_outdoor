import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/repositories/wishlist_repository.dart';

/// ❤️ WISHLIST NOTIFIER - State Management untuk Daftar Ingin Dibeli
///
/// Mengelola:
/// - Tambah/hapus produk ke wishlist
/// - Menyimpan wishlist secara lokal (SharedPreferences)
/// - Check apakah produk sudah di wishlist
/// - Loading & error states
///
/// Digunakan di: HomeScreen, ProductDetailScreen, WishlistScreen
///
/// Note: Wishlist disimpan LOKAL di device (tidak di database)
/// Keuntungan: Cepat, tidak perlu internet
/// Kekurangan: Tidak sinkron antar device
class WishlistNotifier extends ChangeNotifier {
  // 🔒 PRIVATE STATE VARIABLES
  List<Product> _wishlists = []; // Daftar produk favorit
  bool _isLoading = false; // Loading indicator
  String? _error; // Error message

  final WishlistRepository _wishlistRepository;

  WishlistNotifier(this._wishlistRepository);

  // 📤 PUBLIC GETTERS - Akses data dari UI
  List<Product> get wishlists => _wishlists; // Semua produk di wishlist
  bool get isLoading => _isLoading; // Sedang loading?
  String? get error => _error; // Error message
  int get itemCount => _wishlists.length; // Jumlah item di wishlist

  /// 🔍 CHECK IF PRODUCT IN WISHLIST - Cek apakah produk sudah di wishlist
  ///
  /// Parameter:
  /// - productId: ID produk yang dicek
  ///
  /// Return: true jika produk ada di wishlist, false jika tidak
  ///
  /// Fungsi: Digunakan untuk show/hide heart icon di UI
  /// Contoh: Jika true, tampilkan filled heart (❤️), jika false tampilkan outline (🤍)
  bool isInWishlist(String productId) {
    return _wishlists.any((item) => item.id == productId);
  }

  /// 📥 LOAD WISHLIST - Muat daftar wishlist dari local storage
  ///
  /// Fungsi: Panggil ini saat app start atau saat navigate ke wishlist screen
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query wishlist dari SharedPreferences
  /// 3. Jika berhasil: simpan di _wishlists
  /// 4. Jika kosong: _wishlists = [] (wishlist belum ada)
  /// 5. Notify listeners untuk update UI
  ///
  /// Note: SharedPreferences membaca dari local storage, sangat cepat
  Future<void> loadWishlist() async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _wishlistRepository.getWishlistItems();

      result.fold(
        (exception) {
          _error = exception.toString();
          debugPrint('[WishlistNotifier] Error loading wishlist: $_error');
          _setLoading(false);
        },
        (items) {
          _wishlists = items;
          debugPrint(
            '[WishlistNotifier] Loaded ${items.length} wishlist items',
          );
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('[WishlistNotifier] Exception loading wishlist: $e');
      _setLoading(false);
    }

    notifyListeners();
  }

  /// ➕ ADD TO WISHLIST - Tambah produk ke daftar favorit
  ///
  /// Parameter:
  /// - product: Produk yang akan ditambahkan (Product object lengkap)
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Cek apakah produk sudah ada di wishlist
  ///    - Jika sudah ada: return true (no action)
  ///    - Jika belum ada: lanjut ke step 2
  /// 2. Kirim ke repository untuk simpan ke SharedPreferences
  /// 3. Jika berhasil:
  ///    - Tambah produk ke _wishlists
  ///    - Notify listeners (heart icon berubah jadi filled)
  /// 4. Jika gagal: set error
  ///
  /// Note: Produk disimpan dengan ID unik, tidak bisa duplikat
  Future<bool> addToWishlist(Product product) async {
    _error = null;

    try {
      // Check if already exists
      if (isInWishlist(product.id)) {
        debugPrint(
          '[WishlistNotifier] Product ${product.id} already in wishlist',
        );
        return true;
      }

      debugPrint('[WishlistNotifier] Adding product ${product.id} to wishlist');
      final result = await _wishlistRepository.addToWishlist(product);

      return result.fold(
        (exception) {
          _error = exception.toString();
          debugPrint('[WishlistNotifier] Error adding to wishlist: $_error');
          notifyListeners();
          return false;
        },
        (_) {
          _wishlists.add(product);
          debugPrint(
            '[WishlistNotifier] Product added. Total items: ${_wishlists.length}',
          );
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('[WishlistNotifier] Exception adding to wishlist: $e');
      notifyListeners();
      return false;
    }
  }

  /// ❌ REMOVE FROM WISHLIST - Hapus produk dari daftar favorit
  ///
  /// Parameter:
  /// - productId: ID produk yang akan dihapus
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Kirim request hapus ke repository (update SharedPreferences)
  /// 2. Jika berhasil:
  ///    - Hapus produk dari _wishlists by ID
  ///    - Notify listeners (heart icon berubah jadi outline)
  /// 3. Jika gagal: set error
  ///
  /// Note: Data produk tetap di database, hanya dihapus dari wishlist user
  Future<bool> removeFromWishlist(String productId) async {
    _error = null;

    try {
      final result = await _wishlistRepository.removeFromWishlist(productId);

      return result.fold(
        (exception) {
          _error = exception.toString();
          debugPrint(
            '[WishlistNotifier] Error removing from wishlist: $_error',
          );
          notifyListeners();
          return false;
        },
        (_) {
          _wishlists.removeWhere((item) => item.id == productId);
          debugPrint(
            '[WishlistNotifier] Product removed. Total items: ${_wishlists.length}',
          );
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('[WishlistNotifier] Exception removing from wishlist: $e');
      notifyListeners();
      return false;
    }
  }

  /// 🔄 TOGGLE WISHLIST - Tambah/hapus produk dari wishlist (auto detect)
  ///
  /// Parameter:
  /// - product: Produk yang akan di-toggle
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Fungsi: Smart toggle - otomatis tambah jika belum ada, hapus jika sudah ada
  ///
  /// Alur:
  /// 1. Cek apakah produk sudah di wishlist
  /// 2. Jika sudah ada: hapus dengan removeFromWishlist()
  /// 3. Jika belum ada: tambah dengan addToWishlist()
  ///
  /// Keuntungan: Hanya perlu 1 method untuk handle add/remove di button
  /// Contoh: onPressed: () => wishlistNotifier.toggleWishlist(product)
  Future<bool> toggleWishlist(Product product) async {
    if (isInWishlist(product.id)) {
      return await removeFromWishlist(product.id);
    } else {
      return await addToWishlist(product);
    }
  }

  // 🔧 HELPER METHOD - Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
  }
}
