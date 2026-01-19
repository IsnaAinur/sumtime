import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Cache for admin status
  bool? _cachedIsAdmin;
  String? _cachedUserId;
  DateTime? _adminStatusCacheTime;

  // Cache duration (10 minutes for admin status)
  static const Duration _adminCacheDuration = Duration(minutes: 10);

  // Clear admin cache
  void clearAdminCache() {
    _cachedIsAdmin = null;
    _cachedUserId = null;
    _adminStatusCacheTime = null;
  }

  // Check if cache is valid for admin status
  bool _isAdminCacheValid() {
    return _cachedIsAdmin != null &&
           _cachedUserId != null &&
           _adminStatusCacheTime != null &&
           _client.auth.currentUser?.id == _cachedUserId &&
           DateTime.now().difference(_adminStatusCacheTime!) < _adminCacheDuration;
  }

  // ======================
  // SIGN UP (DIPERBARUI)
  // ======================
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    // Kita mengirim 'username' lewat parameter 'data' (metadata).
    // Trigger di database akan otomatis mengambil ini dan memasukkannya ke tabel 'users'.
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username, 
      },
    );

    // KITA HAPUS INSERT MANUAL DI SINI AGAR TIDAK ERROR "DUPLICATE KEY"
    
    return response;
  }

  // ======================
  // SIGN IN
  // ======================
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ======================
  // UPDATE PASSWORD
  // ======================
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ======================
  // UPDATE PROFILE (Username)
  // ======================
  Future<void> updateProfile({String? username}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (username != null) {
      await _client
          .from('users')
          .update({'username': username})
          .eq('id', user.id);
      
      // Update metadata as well
      await _client.auth.updateUser(
        UserAttributes(data: {'username': username}),
      );
    }
  }

  // ======================
  // CURRENT USER
  // ======================
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // ======================
  // GET USER PROFILE
  // ======================
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = getCurrentUser();
    if (user == null) return null;

    final response = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  // ======================
  // CHECK ADMIN ROLE
  // ======================
  Future<bool> isAdmin() async {
    // Return cached value if valid
    if (_isAdminCacheValid()) {
      return _cachedIsAdmin!;
    }

    final profile = await getUserProfile();
    final isAdmin = profile?['role'] == 'admin';

    // Cache the result
    _cachedIsAdmin = isAdmin;
    _cachedUserId = _client.auth.currentUser?.id;
    _adminStatusCacheTime = DateTime.now();

    return isAdmin;
  }

  // ======================
  // SIGN OUT
  // ======================
  Future<void> signOut() async {
    await _client.auth.signOut();
    // Clear admin cache on logout
    clearAdminCache();
  }
}