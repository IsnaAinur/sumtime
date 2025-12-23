import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

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
    final profile = await getUserProfile();
    return profile?['role'] == 'admin';
  }

  // ======================
  // SIGN OUT
  // ======================
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}