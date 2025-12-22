import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Sign up user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        // Create user profile in users table
        await _client.from('users').insert({
          'id': response.user!.id,
          'username': username,
          'email': email,
          'password_hash': password, // In production, hash the password
          'role': _determineRole(email),
        });
      }

      return response;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign in user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final response = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? username,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (phone != null) updates['phone'] = phone;
      if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;

      await _client
          .from('users')
          .update(updates)
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Determine user role based on email
  String _determineRole(String email) {
    final adminEmails = [
      'admin@sumtime.com',
      'administrator@gmail.com',
    ];

    if (adminEmails.contains(email.toLowerCase()) ||
        email.toLowerCase().contains('admin')) {
      return 'admin';
    }
    return 'user';
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final profile = await getUserProfile();
      return profile?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }
}
