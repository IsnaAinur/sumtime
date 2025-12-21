import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;

  // =============================================================================
  // AUTHENTICATION METHODS
  // =============================================================================

  // Login dengan email dan password
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Register user baru
  Future<AuthResponse> signUp(String email, String password, String username) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      // Jika signup berhasil, buat profile
      if (response.user != null) {
        await _createUserProfile(response.user!.id, username, email);
      }

      return response;
    } catch (e) {
      // Jika error karena user sudah ada, coba login langsung
      if (e.toString().contains('already') || e.toString().contains('registered')) {
        // User sudah terdaftar, coba login
        return await signIn(email, password);
      }
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // =============================================================================
  // USER PROFILE METHODS
  // =============================================================================

  // Buat profile user baru
  Future<void> _createUserProfile(String userId, String username, String email) async {
    await _client.from('profiles').insert({
      'user_id': userId,
      'full_name': username,
      'phone': null,
      'address': null,
    });
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .single();

    return response;
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _client
        .from('profiles')
        .update(data)
        .eq('user_id', userId);
  }

  // =============================================================================
  // PRODUCTS METHODS
  // =============================================================================

  // Get all active products dengan kategori
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _client
        .from('products')
        .select('*, categories(*)')
        .eq('is_available', true)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  // Get products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) async {
    final response = await _client
        .from('products')
        .select('*, categories(*)')
        .eq('category_id', categoryId)
        .eq('is_available', true)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  // Get categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    return List<Map<String, dynamic>>.from(response);
  }

  // =============================================================================
  // POSTERS METHODS
  // =============================================================================

  // Get active posters
  Future<List<Map<String, dynamic>>> getActivePosters() async {
    final response = await _client
        .from('posters')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    return List<Map<String, dynamic>>.from(response);
  }

  // =============================================================================
  // ORDERS METHODS
  // =============================================================================

  // Create new order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final response = await _client
        .from('orders')
        .insert(orderData)
        .select()
        .single();

    return response;
  }

  // Add order items
  Future<void> addOrderItems(List<Map<String, dynamic>> orderItems) async {
    await _client.from('order_items').insert(orderItems);
  }

  // Get user orders
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('order_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get order details
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*, products(*))')
        .eq('id', orderId)
        .single();

    return response;
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, int status) async {
    await _client
        .from('orders')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', orderId);
  }

  // =============================================================================
  // PAYMENT METHODS
  // =============================================================================

  // Create payment record
  Future<void> createPayment(Map<String, dynamic> paymentData) async {
    await _client.from('payments').insert(paymentData);
  }

  // =============================================================================
  // ADMIN METHODS
  // =============================================================================

  // Get all orders (admin only)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final response = await _client
        .from('orders')
        .select('*, profiles(full_name), order_items(count)')
        .order('order_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _client
        .from('users')
        .select('*, profiles(*)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Add new product (admin only)
  Future<void> addProduct(Map<String, dynamic> productData) async {
    await _client.from('products').insert(productData);
  }

  // Update product (admin only)
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _client
        .from('products')
        .update(data)
        .eq('id', productId);
  }

  // Add new poster (admin only)
  Future<void> addPoster(Map<String, dynamic> posterData) async {
    await _client.from('posters').insert(posterData);
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  // Generate order number
  Future<String> generateOrderNumber() async {
    final response = await _client.rpc('generate_order_number');
    return response as String;
  }

  // Upload image to storage
  Future<String> uploadImage(String bucket, String fileName, dynamic file) async {
    await _client.storage.from(bucket).upload(fileName, file);
    return _client.storage.from(bucket).getPublicUrl(fileName);
  }
}
