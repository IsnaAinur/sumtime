import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class MenuService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Get all menu items
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    try {
      final response = await _client
          .from('menu_items')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get menu items: $e');
    }
  }

  // Add new menu item
  Future<void> addMenuItem({
    required String name,
    required int price,
    String? description,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, 'menu');
      }

      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('menu_items').insert({
        'name': name,
        'price': price,
        'description': description,
        'image_url': imageUrl,
        'created_by': user.id,
      });
    } catch (e) {
      throw Exception('Failed to add menu item: $e');
    }
  }

  // Update menu item
  Future<void> updateMenuItem({
    required String itemId,
    String? name,
    int? price,
    String? description,
    File? imageFile,
    bool? isAvailable,
  }) async {
    try {
      String? imageUrl;

      // Upload new image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, 'menu');
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (price != null) updates['price'] = price;
      if (description != null) updates['description'] = description;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (isAvailable != null) updates['is_available'] = isAvailable;

      await _client
          .from('menu_items')
          .update(updates)
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  // Delete menu item
  Future<void> deleteMenuItem(String itemId) async {
    try {
      await _client
          .from('menu_items')
          .delete()
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to delete menu item: $e');
    }
  }

  // Get posters
  Future<List<Map<String, dynamic>>> getPosters() async {
    try {
      final response = await _client
          .from('posters')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get posters: $e');
    }
  }

  // Add poster
  Future<void> addPoster({
    required File imageFile,
    String? title,
    String? description,
  }) async {
    try {
      final imageUrl = await _uploadImage(imageFile, 'posters');

      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('posters').insert({
        'title': title,
        'image_url': imageUrl,
        'description': description,
        'created_by': user.id,
      });
    } catch (e) {
      throw Exception('Failed to add poster: $e');
    }
  }

  // Upload image to Supabase Storage
  Future<String> _uploadImage(File imageFile, String bucket) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final filePath = '$bucket/$fileName';

      await _client.storage
          .from(bucket)
          .upload(filePath, imageFile);

      final imageUrl = _client.storage
          .from(bucket)
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
