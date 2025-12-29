import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/repositories/auth_repository.dart';

/// 🔐 AUTH NOTIFIER - State Management untuk Autentikasi
///
/// Mengelola:
/// - Login/Register user
/// - User session (isAuthenticated)
/// - Current user data
/// - Loading & error states
///
/// Digunakan di: LoginScreen, RegisterScreen, semua screen yang butuh auth check
class AuthNotifier extends ChangeNotifier {
  // 🔒 PRIVATE STATE VARIABLES
  User? _currentUser; // Data user yang sedang login
  bool _isLoading = false; // Loading indicator
  String? _error; // Error message

  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository);

  // 📤 PUBLIC GETTERS - Akses data dari UI
  User? get currentUser => _currentUser; // Data user saat ini
  bool get isLoading => _isLoading; // Cek sedang loading?
  bool get isAuthenticated => _currentUser != null; // Cek sudah login?
  String? get error => _error; // Ambil error message

  /// 📝 SIGN UP - Daftar akun baru
  ///
  /// Parameter:
  /// - email: Email pengguna
  /// - password: Password (minimal 6 karakter)
  /// - name: Nama lengkap
  /// - phone: Nomor telepon (opsional)
  /// - role: 'customer' atau 'owner'
  ///
  /// Return: true jika berhasil, false jika gagal
  ///
  /// Alur:
  /// 1. Set loading = true, clear error
  /// 2. Kirim ke repository untuk create user di Supabase Auth & DB
  /// 3. Jika berhasil: simpan user data & notify listeners
  /// 4. Jika gagal: tampilkan error
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          return false;
        },
        (user) {
          _currentUser = user;
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

  /// 🔓 SIGN IN - Login dengan email & password
  ///
  /// Parameter:
  /// - email: Email akun
  /// - password: Password akun
  ///
  /// Return: true jika berhasil login, false jika gagal
  ///
  /// Alur:
  /// 1. Set loading = true, clear error
  /// 2. Kirim email & password ke repository untuk autentikasi
  /// 3. Jika berhasil: simpan user data & notify listeners (auto redirect ke home)
  /// 4. Jika gagal: tampilkan error (email tidak terdaftar, password salah, dll)
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
          return false;
        },
        (user) {
          _currentUser = user;
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

  /// 👤 GET CURRENT USER - Ambil data user saat ini dari database
  ///
  /// Fungsi:
  /// - Refresh data user dari Supabase
  /// - Digunakan saat app start untuk check session
  /// - Update _currentUser dengan data terbaru dari database
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Query user dari database menggunakan Supabase Auth session
  /// 3. Jika berhasil: update _currentUser
  /// 4. Jika gagal: set error, _currentUser = null (tidak login)
  Future<void> getCurrentUser() async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _authRepository.getCurrentUser();

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (user) {
          _currentUser = user;
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 🚪 SIGN OUT - Logout user
  ///
  /// Fungsi:
  /// - Hapus session Supabase Auth
  /// - Clear _currentUser dari state
  /// - Auto redirect ke login screen
  ///
  /// Alur:
  /// 1. Set loading = true
  /// 2. Panggil signOut di repository (hapus Supabase session)
  /// 3. Set _currentUser = null
  /// 4. Notify listeners (trigger redirect ke login)
  Future<void> signOut() async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _authRepository.signOut();

      result.fold(
        (exception) {
          _error = exception.toString();
          _setLoading(false);
        },
        (_) {
          _currentUser = null;
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }

    notifyListeners();
  }

  // 🔧 HELPER METHOD - Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
  }

  /// 🗑️ CLEAR ERROR - Hapus error message dari UI
  /// Panggil ini setelah menampilkan error dialog ke user
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
