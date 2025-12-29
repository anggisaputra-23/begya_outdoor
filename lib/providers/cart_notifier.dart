import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/repositories/cart_repository.dart';

/// 🛒 CART NOTIFIER - State Management untuk Keranjang Belanja
///
/// Mengelola:
/// - Daftar item di keranjang
/// - Tambah/hapus/update quantity item
/// - Hitung subtotal, ongkir, total
/// - Loading & error states
///
/// Digunakan di: HomeScreen, ProductDetailScreen, CartScreen, CheckoutScreen
class CartNotifier extends ChangeNotifier {
  // 🔒 PRIVATE STATE VARIABLES
  List<CartItem> _cartItems = []; // Daftar item di keranjang
  bool _isLoading = false; // Loading indicator
  String? _error; // Error message

  final CartRepository _cartRepository;

  CartNotifier(this._cartRepository);

  // 📤 PUBLIC GETTERS - Akses data dari UI
  List<CartItem> get cartItems => _cartItems; // Semua item di keranjang
  bool get isLoading => _isLoading; // Sedang loading?
  String? get error => _error; // Error message
  int get itemCount => _cartItems.length; // Jumlah item unik

  /// 💰 SUBTOTAL - Total harga barang saja (tanpa ongkir)
  /// Rumus: Σ (harga x quantity) untuk semua item
  double get subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// 🚚 SHIPPING COST - Biaya pengiriman (FIXED = Rp 50.000)
  double get shippingCost => 50000;

  /// 💵 TOTAL - Total harga akhir yang harus dibayar
  /// Rumus: Subtotal + Shipping Cost
  double get total => subtotal + shippingCost;

  /// 📥 LOAD CART - Ambil item keranjang dari storage
  ///
  /// Fungsi: Fetch semua item keranjang saat app dibuka
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query keranjang dari repository
  /// 3. Jika berhasil: set _cartItems dengan hasil query
  /// 4. Notify listeners untuk update UI
  Future<void> loadCart() async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _cartRepository.getCartItems();

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (items) {
          _cartItems = items;
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

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
  Future<bool> addToCart({
    required String productId,
    required String productName,
    required double productPrice,
    required String productImage,
    required int quantity,
  }) async {
    _error = null;

    try {
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cartId: 'temp-cart', // Will be set when synced with DB
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        productImage: productImage,
        quantity: quantity,
        createdAt: DateTime.now(),
      );

      final result = await _cartRepository.addItemToCart(cartItem);

      result.fold(
        (exception) {
          _error = exception.toString();
          return false;
        },
        (item) {
          // Check if item already exists
          final existingIndex = _cartItems.indexWhere(
            (i) => i.productId == productId,
          );
          if (existingIndex != -1) {
            // Update quantity
            _cartItems[existingIndex] = CartItem(
              id: _cartItems[existingIndex].id,
              cartId: _cartItems[existingIndex].cartId,
              productId: productId,
              productName: productName,
              productPrice: productPrice,
              productImage: productImage,
              quantity: _cartItems[existingIndex].quantity + quantity,
              createdAt: _cartItems[existingIndex].createdAt,
            );
          } else {
            // Add new item
            _cartItems.add(cartItem);
          }
          notifyListeners();
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// ❌ REMOVE FROM CART - Hapus item dari keranjang
  ///
  /// Parameter:
  /// - itemId: ID cart item yang akan dihapus
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Kirim request hapus ke repository
  /// 2. Jika berhasil: hapus dari local list _cartItems
  /// 3. Notify listeners untuk update UI (total harga berubah)
  Future<bool> removeFromCart(String itemId) async {
    _error = null;

    try {
      final result = await _cartRepository.removeItemFromCart(itemId);

      result.fold(
        (exception) {
          _error = exception.toString();
          return false;
        },
        (_) {
          _cartItems.removeWhere((item) => item.id == itemId);
          notifyListeners();
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 🔢 UPDATE QUANTITY - Ubah jumlah item di keranjang
  ///
  /// Parameter:
  /// - itemId: ID cart item yang quantity-nya diupdate
  /// - newQuantity: Jumlah item baru (harus > 0)
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Jika newQuantity < 1: hapus item (bukan update)
  /// 2. Jika newQuantity >= 1: update quantity di repository
  /// 3. Update local list dengan quantity baru
  /// 4. Notify listeners (subtotal & total berubah)
  Future<bool> updateQuantity(String itemId, int newQuantity) async {
    _error = null;

    if (newQuantity < 1) {
      return await removeFromCart(itemId);
    }

    try {
      final result = await _cartRepository.updateItemQuantity(
        itemId: itemId,
        quantity: newQuantity,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          return false;
        },
        (_) {
          final index = _cartItems.indexWhere((i) => i.id == itemId);
          if (index != -1) {
            // Update quantity locally after successful API call
            final currentItem = _cartItems[index];
            _cartItems[index] = currentItem.copyWith(quantity: newQuantity);
          }
          notifyListeners();
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 🗑️ CLEAR CART - Kosongkan semua item di keranjang
  ///
  /// Fungsi: Hapus semua item sekaligus (biasa dipanggil setelah checkout berhasil)
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Kirim request clear ke repository
  /// 2. Jika berhasil: set _cartItems = [] (kosong)
  /// 3. Notify listeners untuk update UI
  Future<bool> clearCart() async {
    _error = null;

    try {
      final result = await _cartRepository.clearCart();

      result.fold(
        (exception) {
          _error = exception.toString();
          return false;
        },
        (_) {
          _cartItems = [];
          notifyListeners();
          return true;
        },
      );

      return _error == null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
}
