import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

/// Supabase Service untuk mengelola koneksi database
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  /// Initialize Supabase
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  /// Get Supabase Client
  SupabaseClient get client => Supabase.instance.client;

  /// Get Auth Client
  GoTrueClient get auth => Supabase.instance.client.auth;

  /// Get Database Client
  SupabaseQueryBuilder Function(String) get db => Supabase.instance.client.from;

  /// Get Storage Client
  SupabaseStorageClient get storage => Supabase.instance.client.storage;

  /// Check if user is authenticated
  bool get isAuthenticated => auth.currentSession != null;

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Get current user ID
  String? get currentUserId => auth.currentUser?.id;

  /// Sign out
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Get current session
  Session? get currentSession => auth.currentSession;

  /// Check if token is expired
  bool get isTokenExpired {
    final session = currentSession;
    if (session == null) return true;
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(
      DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000),
    );
  }

  /// Refresh token if expired
  Future<void> refreshTokenIfNeeded() async {
    if (isTokenExpired) {
      try {
        await auth.refreshSession();
      } catch (e) {
        throw Exception('Failed to refresh token: $e');
      }
    }
  }
}
