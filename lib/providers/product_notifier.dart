import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import '../data/models/models.dart';
import '../data/repositories/product_repository.dart';

/// 📦 PRODUCT NOTIFIER - State Management untuk Produk
///
/// Mengelola:
/// - Daftar semua produk & kategori
/// - Search & filter produk
/// - Detail produk individual
/// - CRUD produk (owner only)
/// - Upload gambar produk
///
/// Digunakan di: HomeScreen, ProductDetailScreen, ProductManagementScreen, AddProductScreen
class ProductNotifier extends ChangeNotifier {
  // 🔒 PRIVATE STATE VARIABLES
  List<Product> _products = []; // Semua produk dari database
  List<Product> _filteredProducts = []; // Hasil filter/search
  List<Category> _categories = []; // Daftar kategori
  Product? _selectedProduct; // Produk yang sedang dilihat detail-nya
  bool _isLoading = false; // Loading indicator
  String? _error; // Error message

  final ProductRepository _productRepository;

  ProductNotifier(this._productRepository);

  // 📤 PUBLIC GETTERS - Akses data dari UI
  /// Tampilkan produk filtered jika ada, kalau tidak tampilkan semua produk
  List<Product> get products =>
      _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get allProducts => _products; // Semua produk (tanpa filter)
  List<Category> get categories => _categories; // Daftar kategori
  Product? get selectedProduct =>
      _selectedProduct; // Produk yang dilihat detail-nya
  bool get isLoading => _isLoading; // Sedang loading?
  String? get error => _error; // Error message

  /// 📋 GET PRODUCTS - Ambil daftar produk dengan filter optional
  ///
  /// Parameter:
  /// - categoryId: Filter berdasarkan kategori (opsional)
  /// - searchQuery: Filter berdasarkan nama/deskripsi (opsional)
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query produk dari repository dengan filter yang diberikan
  /// 3. Jika berhasil: simpan di _products, clear _filteredProducts
  /// 4. Jika gagal: set error
  /// 5. Notify listeners untuk update UI
  Future<void> getProducts({String? categoryId, String? searchQuery}) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _productRepository.getProducts(
        categoryId: categoryId,
        searchQuery: searchQuery,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (products) {
          _products = products;
          _filteredProducts = [];
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 🔍 GET PRODUCT BY ID - Ambil detail produk tertentu
  ///
  /// Parameter:
  /// - productId: ID produk yang ingin dilihat
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query produk berdasarkan ID dari repository
  /// 3. Jika berhasil: simpan di _selectedProduct
  /// 4. Update UI dengan detail produk (harga, stok, rating, deskripsi)
  /// 5. Notify listeners
  Future<void> getProductById(String productId) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _productRepository.getProductById(productId);

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (product) {
          _selectedProduct = product;
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 🏬 GET PRODUCTS BY OWNER - Ambil semua produk milik penjual tertentu (owner only)
  ///
  /// Parameter:
  /// - ownerId: ID penjual
  ///
  /// Fungsi: Digunakan di Owner Dashboard untuk menampilkan produk mereka sendiri
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query produk yang ownerId-nya sesuai
  /// 3. Jika berhasil: simpan di _products (ini adalah produk milik owner)
  /// 4. Notify listeners
  Future<void> getProductsByOwner(String ownerId) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _productRepository.getProductsByOwner(ownerId);

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (products) {
          _products = products;
          _filteredProducts = [];
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 🏷️ GET CATEGORIES - Ambil semua kategori produk
  ///
  /// Fungsi: Digunakan di HomeScreen untuk menampilkan filter kategori
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query semua kategori dari repository
  /// 3. Jika berhasil: simpan di _categories
  /// 4. Update UI dengan kategori (biasanya dalam horizontal list)
  /// 5. Notify listeners
  Future<void> getCategories() async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _productRepository.getCategories();

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (categories) {
          _categories = categories;
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 🔎 SEARCH PRODUCTS - Cari produk berdasarkan nama/deskripsi (client-side)
  ///
  /// Parameter:
  /// - query: Kata kunci pencarian (case-insensitive)
  ///
  /// Fungsi: Real-time search saat user mengetik di search bar
  ///
  /// Alur:
  /// 1. Jika query kosong: clear _filteredProducts (tampilkan semua)
  /// 2. Jika ada query: filter _products berdasarkan nama atau deskripsi
  /// 3. Simpan hasil di _filteredProducts
  /// 4. Notify listeners untuk update UI
  ///
  /// Note: Ini adalah client-side filtering (lebih cepat, pakai _products lokal)
  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = [];
    } else {
      _filteredProducts = _products
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  /// 🏷️ FILTER BY CATEGORY - Filter produk berdasarkan kategori
  ///
  /// Parameter:
  /// - categoryId: ID kategori yang dipilih
  ///
  /// Alur:
  /// 1. Jika categoryId kosong: tampilkan semua produk
  /// 2. Jika ada categoryId: filter _products yang categoryId-nya sesuai
  /// 3. Simpan hasil di _filteredProducts
  /// 4. Notify listeners untuk update UI (product list berubah)
  void filterByCategory(String categoryId) {
    if (categoryId.isEmpty) {
      _filteredProducts = [];
    } else {
      _filteredProducts = _products
          .where((product) => product.categoryId == categoryId)
          .toList();
    }
    notifyListeners();
  }

  /// ➕ CREATE PRODUCT - Tambah produk baru TANPA gambar (owner only)
  ///
  /// Parameter:
  /// - name: Nama produk
  /// - description: Deskripsi lengkap
  /// - price: Harga satuan
  /// - stock: Jumlah stok awal
  /// - categoryId: ID kategori
  /// - mainImageUrl: URL gambar (opsional, bisa ditambah nanti)
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Kirim data ke repository untuk disimpan ke database
  /// 3. Jika berhasil: tambah produk ke _products, notify listeners
  /// 4. Jika gagal: tampilkan error
  ///
  /// Note: Fallback jika upload gambar gagal, owner bisa save produk dulu
  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    String? mainImageUrl,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _productRepository.createProduct(
        name: name,
        description: description,
        price: price,
        stock: stock,
        categoryId: categoryId,
        mainImageUrl: mainImageUrl,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          return false;
        },
        (product) {
          _products.add(product);
          _setLoading(false);
          notifyListeners();
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// ➕ CREATE PRODUCT WITH IMAGE BYTES - Tambah produk baru + upload gambar
  ///
  /// Parameter:
  /// - name, description, price, stock, categoryId: Data produk
  /// - imageBytes: Byte data gambar (Uint8List) - support web & mobile
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Kompres gambar (opsional)
  /// 3. Upload gambar ke Supabase Storage
  /// 4. Dapatkan URL gambar yang sudah diupload
  /// 5. Simpan produk + URL gambar ke database
  /// 6. Jika berhasil: tambah ke _products, notify listeners
  /// 7. Jika gagal: tampilkan error
  ///
  /// Keuntungan: Support web platform (tidak pakai File API)
  Future<bool> createProductWithImageBytes({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    required Uint8List imageBytes,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _productRepository.createProductWithImageBytes(
        name: name,
        description: description,
        price: price,
        stock: stock,
        categoryId: categoryId,
        imageBytes: imageBytes,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          return false;
        },
        (product) {
          _products.add(product);
          _setLoading(false);
          notifyListeners();
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// ➕ CREATE PRODUCT WITH IMAGE - Tambah produk + upload gambar dari File
  ///
  /// Parameter:
  /// - name, description, price, stock, categoryId: Data produk
  /// - imageFile: File gambar dari device (File object)
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Kompres gambar untuk menghemat storage
  /// 3. Upload gambar ke Supabase Storage (folder: product-images/)
  /// 4. Dapatkan URL gambar public
  /// 5. Simpan produk dengan URL gambar ke database
  /// 6. Jika berhasil: tambah ke _products, notify listeners
  /// 7. Jika gagal: rollback (hapus file yang sudah diupload)
  ///
  /// Keuntungan: Support mobile platform dengan File API
  Future<bool> createProductWithImage({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    required File imageFile,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _productRepository.createProductWithImage(
        name: name,
        description: description,
        price: price,
        stock: stock,
        categoryId: categoryId,
        imageFile: imageFile,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          return false;
        },
        (product) {
          _products.add(product);
          _setLoading(false);
          notifyListeners();
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// ✏️ UPDATE PRODUCT - Edit produk (owner only)
  ///
  /// Parameter:
  /// - productId: ID produk yang diedit
  /// - name, description, price, stock, categoryId: Data produk yang diupdate
  /// - mainImageUrl: URL gambar baru (opsional)
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Kirim update ke repository (update di database)
  /// 3. Jika berhasil: update di _products list, update _selectedProduct
  /// 4. Notify listeners untuk refresh UI
  ///
  /// Note: Hanya bisa update field tertentu, tidak bisa replace gambar di sini
  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    String? mainImageUrl,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _productRepository.updateProduct(
        productId: productId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        categoryId: categoryId,
        mainImageUrl: mainImageUrl,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          return false;
        },
        (product) {
          final index = _products.indexWhere((p) => p.id == productId);
          if (index != -1) {
            _products[index] = product;
          }
          _selectedProduct = product;
          _setLoading(false);
          notifyListeners();
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// ✏️ UPDATE PRODUCT WITH IMAGE BYTES - Edit produk + ganti gambar (owner only)
  ///
  /// Parameter:
  /// - productId: ID produk yang diedit
  /// - name, description, price, stock, categoryId: Data produk
  /// - imageBytes: Byte data gambar baru
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Kompres gambar baru
  /// 3. Upload gambar ke Supabase Storage
  /// 4. Dapatkan URL gambar baru
  /// 5. Update produk dengan URL gambar baru di database
  /// 6. Jika berhasil: update _products & _selectedProduct, notify listeners
  /// 7. Jika gagal: rollback
  ///
  /// Note: Otomatis mengganti gambar lama (tidak ada cleanup manual)
  Future<bool> updateProductWithImageBytes({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    required Uint8List imageBytes,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _productRepository.updateProductWithImageBytes(
        productId: productId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        categoryId: categoryId,
        imageBytes: imageBytes,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          return false;
        },
        (product) {
          final index = _products.indexWhere((p) => p.id == productId);
          if (index != -1) {
            _products[index] = product;
          }
          _selectedProduct = product;
          _setLoading(false);
          notifyListeners();
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// ❌ DELETE PRODUCT - Hapus produk (owner only)
  ///
  /// Parameter:
  /// - productId: ID produk yang akan dihapus
  ///
  /// Return: true jika berhasil, false jika gagal
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
  Future<bool> deleteProduct(String productId) async {
    // Delete immediately from UI without waiting
    _products.removeWhere((p) => p.id == productId);
    if (_selectedProduct?.id == productId) {
      _selectedProduct = null;
    }
    notifyListeners();

    // Then delete from database in background
    _error = null;

    try {
      final result = await _productRepository.deleteProduct(productId);

      result.fold(
        (exception) {
          // If delete failed, restore the product locally
          _error = exception.toString();
          debugPrint('[ProductNotifier] Delete failed: $_error');
          return false;
        },
        (_) {
          // Success - already removed from UI above
          debugPrint('[ProductNotifier] Product deleted successfully');
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      debugPrint('[ProductNotifier] Delete exception: $e');
      return false;
    }
  }

  // 🔧 HELPER METHOD - Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
  }

  /// 🗑️ CLEAR ERROR - Hapus error message
  /// Panggil ini setelah menampilkan error ke user
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 🧹 CLEAR SELECTED - Clear produk yang sedang dilihat detail-nya
  /// Panggil ini saat user navigate away dari product detail screen
  void clearSelected() {
    _selectedProduct = null;
    notifyListeners();
  }
}
