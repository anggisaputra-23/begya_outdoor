import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/repositories/order_repository.dart';

/// 📋 ORDER NOTIFIER - State Management untuk Pesanan
///
/// Mengelola:
/// - Membuat pesanan baru
/// - Riwayat pesanan customer
/// - Detail pesanan individual
/// - Status pesanan (Menunggu → Dibayar → Dikirim → Selesai)
/// - Upload bukti pembayaran
///
/// Digunakan di: CheckoutScreen, OrderHistoryScreen, OrderDetailScreen
class OrderNotifier extends ChangeNotifier {
  // 🔒 PRIVATE STATE VARIABLES
  List<Order> _orders = []; // Daftar pesanan (customer atau owner)
  Order? _selectedOrder; // Pesanan yang sedang dilihat detail-nya
  bool _isLoading = false; // Loading indicator
  String? _error; // Error message

  final OrderRepository _orderRepository;

  OrderNotifier(this._orderRepository);

  // 📤 PUBLIC GETTERS - Akses data dari UI
  List<Order> get orders => _orders; // Semua pesanan
  Order? get selectedOrder => _selectedOrder; // Pesanan yang dilihat
  Order? get currentOrder =>
      _orders.isNotEmpty ? _orders.first : null; // Pesanan terbaru
  bool get isLoading => _isLoading; // Sedang loading?
  String? get error => _error; // Error message

  /// 📝 CREATE ORDER - Buat pesanan baru
  ///
  /// Parameter:
  /// - customerName, customerEmail, customerPhone, customerAddress: Data penerima
  /// - items: Daftar CartItem yang dipesan
  /// - subtotal: Total harga barang (tanpa ongkir)
  /// - shippingCost: Biaya pengiriman
  /// - paymentMethod: Metode pembayaran (bank transfer, e-wallet, dll)
  /// - notes: Catatan pesanan (opsional)
  /// - shippingMethod: Metode pengiriman (opsional)
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Kirim data ke repository untuk buat pesanan baru
  /// 3. Create Order record + OrderItem records di database
  /// 4. Jika berhasil:
  ///    - Insert pesanan baru ke depan _orders list
  ///    - Clear cart setelah pesanan berhasil
  ///    - Notify listeners & redirect ke order detail
  /// 5. Jika gagal: tampilkan error (validasi, server error, dll)
  ///
  /// Status awal pesanan: 'menunggu' (waiting for payment)
  Future<bool> createOrder({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required List<CartItem> items,
    required double subtotal,
    required double shippingCost,
    required String paymentMethod,
    String? notes,
    String? shippingMethod,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _orderRepository.createOrder(
        items: items,
        subtotal: subtotal,
        shippingCost: shippingCost,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          return false;
        },
        (order) {
          _orders.insert(0, order);
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

  /// 🔍 GET ORDER BY ID - Ambil detail pesanan tertentu
  ///
  /// Parameter:
  /// - orderId: ID pesanan yang ingin dilihat
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query pesanan berdasarkan ID dari repository
  /// 3. Jika berhasil: simpan di _selectedOrder
  /// 4. UI tampilkan detail pesanan (items, total, status, alamat pengiriman)
  /// 5. Notify listeners
  ///
  /// Note: Juga bisa tampilkan OrderItem yang terkait dengan pesanan ini
  Future<void> getOrderById(String orderId) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _orderRepository.getOrderById(orderId);

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (order) {
          _selectedOrder = order;
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 👥 GET CUSTOMER ORDERS - Ambil semua pesanan customer tertentu
  ///
  /// Parameter:
  /// - customerId: ID customer
  ///
  /// Fungsi: Digunakan di OrderHistoryScreen untuk tampilkan pesanan user
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query pesanan yang userId-nya sesuai dari database
  /// 3. Jika berhasil: simpan di _orders (sorted by date, newest first)
  /// 4. UI tampilkan list pesanan dengan status & tanggal
  /// 5. Notify listeners
  ///
  /// Data yang ditampilkan: ID, status, total, tanggal, ringkas items
  Future<void> getCustomerOrders(String customerId) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _orderRepository.getCustomerOrders(customerId);

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (orders) {
          _orders = orders;
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 🏪 GET ALL ORDERS - Ambil semua pesanan (owner/admin only)
  ///
  /// Fungsi: Digunakan di Owner Dashboard untuk kelola pesanan yang masuk
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query semua pesanan dari database (tidak filter by user)
  /// 3. Jika berhasil: simpan di _orders (sorted by date, newest first)
  /// 4. UI tampilkan list pesanan dari berbagai customer
  /// 5. Owner bisa lihat & update status pesanan
  /// 6. Notify listeners
  ///
  /// Note: Hanya owner yang bisa akses endpoint ini (RLS policy)
  Future<void> getAllOrders() async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _orderRepository.getAllOrders();

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (orders) {
          _orders = orders;
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 🔄 UPDATE ORDER STATUS - Ubah status pesanan (owner only)
  ///
  /// Parameter:
  /// - orderId: ID pesanan yang status-nya diupdate
  /// - status: Status baru (menunggu / dibayar / dikirim / selesai)
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Status flow:
  /// 1. 'menunggu' → Customer belum bayar, tunggu bukti transfer
  /// 2. 'dibayar' → Bukti pembayaran sudah diterima, siap dikirim
  /// 3. 'dikirim' → Barang sudah dikirim ke customer
  /// 4. 'selesai' → Barang diterima & transaksi selesai
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Kirim update ke repository (update status di database)
  /// 3. Jika berhasil:
  ///    - Update di _orders list (find by orderId & update status)
  ///    - Update _selectedOrder jika sedang dilihat
  ///    - Notify listeners (UI refresh dengan status baru)
  /// 4. Jika gagal: tampilkan error
  ///
  /// Note: Hanya owner yang bisa mengubah status (RLS policy)
  Future<bool> updateOrderStatus(String orderId, String status) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _orderRepository.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          notifyListeners();
        },
        (order) {
          final index = _orders.indexWhere((o) => o.id == orderId);
          if (index != -1) {
            _orders[index] = order;
          }
          if (_selectedOrder?.id == orderId) {
            _selectedOrder = order;
          }
          _setLoading(false);
          notifyListeners();
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

  /// 💳 UPLOAD PAYMENT PROOF - Upload bukti pembayaran untuk pesanan
  ///
  /// Parameter:
  /// - orderId: ID pesanan
  /// - filePath: Path file bukti pembayaran (foto/PDF transfer)
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Upload file ke Supabase Storage (folder: payment-proofs/)
  /// 3. Dapatkan URL file yang sudah diupload
  /// 4. Simpan URL ke order.proofPayment di database
  /// 5. Jika berhasil: update _orders dengan URL bukti
  /// 6. Notify listeners
  ///
  /// File support: JPG, PNG, PDF (max 5MB)
  ///
  /// Setelah upload berhasil, owner bisa lihat bukti & approve pesanan
  Future<bool> uploadPaymentProof(String orderId, String filePath) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _orderRepository.uploadPaymentProof(
        orderId: orderId,
        filePath: filePath,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          return false;
        },
        (proofUrl) {
          // Payment proof uploaded successfully, URL returned
          // Optionally fetch updated order from server
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

  /// 🔎 GET ORDERS BY STATUS - Filter pesanan berdasarkan status (client-side)
  ///
  /// Parameter:
  /// - status: Status yang dicari (menunggu / dibayar / dikirim / selesai)
  ///
  /// Return: List pesanan dengan status yang sesuai
  ///
  /// Fungsi: Client-side filtering, tidak query ke server
  /// Contoh penggunaan:
  /// - Lihat pesanan yang belum dibayar: getOrdersByStatus('menunggu')
  /// - Lihat pesanan yang sudah dikirim: getOrdersByStatus('dikirim')
  /// - Lihat pesanan selesai: getOrdersByStatus('selesai')
  ///
  /// Note: Lebih cepat dari server-side filter kalau data sudah load di memory
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
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

  /// 🧹 CLEAR SELECTED - Clear pesanan yang sedang dilihat detail-nya
  /// Panggil ini saat user navigate away dari order detail screen
  void clearSelected() {
    _selectedOrder = null;
    notifyListeners();
  }
}
