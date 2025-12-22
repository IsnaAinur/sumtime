import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class OrderService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Create new order
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required int shippingCost,
    required String deliveryAddress,
    required String phone,
    String? notes,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Group cart items by name to calculate quantities
      final Map<String, Map<String, dynamic>> groupedItems = {};
      for (final item in cartItems) {
        final name = item['name'] as String;
        if (!groupedItems.containsKey(name)) {
          groupedItems[name] = {
            'name': name,
            'harga': item['harga'] as int,
            'quantity': 1,
          };
        } else {
          groupedItems[name]!['quantity'] = (groupedItems[name]!['quantity'] as int) + 1;
        }
      }

      final groupedList = groupedItems.values.toList();

      // Calculate total amount
      int totalAmount = groupedList.fold(0, (sum, item) {
        final harga = item['harga'] as int;
        final quantity = item['quantity'] as int;
        return sum + (harga * quantity);
      });
      totalAmount += shippingCost;

      // Create order
      final orderResponse = await _client.from('orders').insert({
        'user_id': user.id,
        'total_amount': totalAmount,
        'shipping_cost': shippingCost,
        'delivery_address': deliveryAddress,
        'phone': phone,
        'notes': notes,
        'status': 0, // Diterima
      }).select().single();

      final orderId = orderResponse['id'];

      // Add order items
      final orderItems = groupedList.map((item) => {
        'order_id': orderId,
        'item_name': item['name'] as String,
        'item_price': item['harga'] as int,
        'quantity': item['quantity'] as int,
      }).toList();

      await _client.from('order_items').insert(orderItems);

      // Return order with items
      return await getOrderDetails(orderId);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user orders
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get orders first
      final ordersResponse = await _client
          .from('orders')
          .select('*')
          .eq('user_id', user.id)
          .order('order_date', ascending: false);

      final orders = List<Map<String, dynamic>>.from(ordersResponse);

      // Get order items for each order
      for (var order in orders) {
        final itemsResponse = await _client
            .from('order_items')
            .select('item_name, item_price, quantity')
            .eq('order_id', order['id']);

        order['order_items'] = List<Map<String, dynamic>>.from(itemsResponse);
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  // Get all orders (admin only)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      // Get orders with user info
      final ordersResponse = await _client
          .from('orders')
          .select('*, users(username, email)')
          .order('order_date', ascending: false);

      final orders = List<Map<String, dynamic>>.from(ordersResponse);

      // Get order items for each order
      for (var order in orders) {
        final itemsResponse = await _client
            .from('order_items')
            .select('item_name, item_price, quantity')
            .eq('order_id', order['id']);

        order['order_items'] = List<Map<String, dynamic>>.from(itemsResponse);
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to get all orders: $e');
    }
  }

  // Get order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      // Get order with user info
      final orderResponse = await _client
          .from('orders')
          .select('*, users(username, email)')
          .eq('id', orderId)
          .single();

      // Get order items
      final itemsResponse = await _client
          .from('order_items')
          .select('item_name, item_price, quantity')
          .eq('order_id', orderId);

      final order = Map<String, dynamic>.from(orderResponse);
      order['order_items'] = List<Map<String, dynamic>>.from(itemsResponse);

      return order;
    } catch (e) {
      throw Exception('Failed to get order details: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, int newStatus) async {
    try {
      await _client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Get orders by status (for admin dashboard)
  Future<List<Map<String, dynamic>>> getOrdersByStatus(int status) async {
    try {
      // Get orders with user info
      final ordersResponse = await _client
          .from('orders')
          .select('*, users(username, email)')
          .eq('status', status)
          .order('order_date', ascending: false);

      final orders = List<Map<String, dynamic>>.from(ordersResponse);

      // Get order items for each order
      for (var order in orders) {
        final itemsResponse = await _client
            .from('order_items')
            .select('item_name, item_price, quantity')
            .eq('order_id', order['id']);

        order['order_items'] = List<Map<String, dynamic>>.from(itemsResponse);
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  // Get order statistics (for admin)
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      // Get all orders for counting
      final allOrders = await _client
          .from('orders')
          .select('id, status, total_amount');

      final orders = List<Map<String, dynamic>>.from(allOrders);

      // Count orders by status
      final statusCounts = <String, int>{};
      int totalRevenue = 0;

      for (final order in orders) {
        final status = order['status'] as int;
        statusCounts['status_$status'] = (statusCounts['status_$status'] ?? 0) + 1;

        // Calculate revenue from completed orders (status 3)
        if (status == 3) {
          totalRevenue += order['total_amount'] as int;
        }
      }

      return {
        'total_orders': orders.length,
        'completed_orders': statusCounts['status_3'] ?? 0,
        'pending_orders': (statusCounts['status_0'] ?? 0) + (statusCounts['status_1'] ?? 0) + (statusCounts['status_2'] ?? 0),
        'total_revenue': totalRevenue,
        'status_breakdown': statusCounts,
      };
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  // Helper method to convert database order to OrderItem format
  Future<List<Map<String, dynamic>>> getOrdersFormatted({bool isAdmin = false}) async {
    try {
      final orders = isAdmin ? await getAllOrders() : await getUserOrders();

      return orders.map((order) {
        final orderItems = (order['order_items'] as List<dynamic>? ?? [])
            .map((item) => {
                  'name': item['item_name'],
                  'price': 'Rp. ${item['item_price'].toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      )}',
                  'harga': item['item_price'],
                  'quantity': item['quantity'],
                })
            .toList();

        final totalAmount = order['total_amount'] as int;
        final shippingCost = order['shipping_cost'] as int;

        return {
          'id': order['id'],
          'orderId': order['order_id'],
          'priceText': 'Rp. ${(totalAmount).toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]}.',
              )}',
          'orderItems': orderItems,
          'shippingCost': shippingCost,
          'orderDate': order['order_date'],
          'status': order['status'],
          'deliveryAddress': order['delivery_address'],
          'phone': order['phone'],
          'notes': order['notes'],
          'customerName': order['users']?['username'],
          'customerEmail': order['users']?['email'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get formatted orders: $e');
    }
  }

  // Get pending orders count for admin
  Future<int> getPendingOrdersCount() async {
    try {
      final stats = await getOrderStatistics();
      return stats['pending_orders'] as int;
    } catch (e) {
      return 0;
    }
  }

  // Get orders for admin dashboard (ongoing vs completed)
  Future<List<Map<String, dynamic>>> getOrdersForAdmin({required bool isCompleted}) async {
    try {
      final ordersResponse = await _client
          .from('orders')
          .select('*, users(username, email)')
          .eq('status', isCompleted ? 3 : 0) // First get one status, then filter manually
          .order('order_date', ascending: false);

      // For ongoing orders, we need multiple statuses, so get all and filter
      final orders = isCompleted
          ? List<Map<String, dynamic>>.from(ordersResponse)
          : await _client
              .from('orders')
              .select('*, users(username, email)')
              .inFilter('status', [0, 1, 2])
              .order('order_date', ascending: false);

      // Get order items for each order
      for (var order in orders) {
        final itemsResponse = await _client
            .from('order_items')
            .select('item_name, item_price, quantity')
            .eq('order_id', order['id']);

        order['order_items'] = List<Map<String, dynamic>>.from(itemsResponse);
      }

      return orders.map((order) {
        final orderItems = (order['order_items'] as List<dynamic>)
            .map((item) => {
                  'name': item['item_name'],
                  'price': 'Rp. ${item['item_price'].toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      )}',
                  'harga': item['item_price'],
                  'quantity': item['quantity'],
                })
            .toList();

        final totalAmount = order['total_amount'] as int;

        return {
          'id': order['id'],
          'orderId': order['order_id'],
          'priceText': 'Rp. ${totalAmount.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]}.',
              )}',
          'orderItems': orderItems,
          'shippingCost': order['shipping_cost'],
          'orderDate': order['order_date'],
          'status': order['status'],
          'deliveryAddress': order['delivery_address'],
          'phone': order['phone'],
          'notes': order['notes'],
          'customerName': order['users']?['username'],
          'customerEmail': order['users']?['email'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get orders for admin: $e');
    }
  }
}
