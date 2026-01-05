import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class OrderService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Cache for order data
  List<Map<String, dynamic>>? _cachedAllOrders;
  List<Map<String, dynamic>>? _cachedUserOrders;
  Map<String, dynamic>? _cachedStatistics;
  DateTime? _ordersCacheTime;
  DateTime? _userOrdersCacheTime;
  DateTime? _statisticsCacheTime;

  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Clear all caches
  void clearCache() {
    _cachedAllOrders = null;
    _cachedUserOrders = null;
    _cachedStatistics = null;
    _ordersCacheTime = null;
    _userOrdersCacheTime = null;
    _statisticsCacheTime = null;
  }

  // Check if cache is valid
  bool _isCacheValid(DateTime? cacheTime) {
    return cacheTime != null &&
           DateTime.now().difference(cacheTime) < _cacheDuration;
  }

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

      // Clear caches since new order was created
      clearCache();

      // Return order with items
      return await getOrderDetails(orderId);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user orders
  Future<List<Map<String, dynamic>>> getUserOrders({int? limit, int? offset}) async {
    // Return cached data if valid
    if (_cachedUserOrders != null && _isCacheValid(_userOrdersCacheTime)) {
      return _cachedUserOrders!;
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get orders first
      var query = _client
          .from('orders')
          .select('*')
          .eq('user_id', user.id)
          .order('order_date', ascending: false);

      // Apply pagination if provided
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }

      final ordersResponse = await query;

      final orders = List<Map<String, dynamic>>.from(ordersResponse);

      if (orders.isEmpty) {
        _cachedUserOrders = orders;
        _userOrdersCacheTime = DateTime.now();
        return orders;
      }

      // Get all order IDs
      final orderIds = orders.map((order) => order['id']).toList();

      // Batch fetch all order items for all orders in one query
      final itemsResponse = await _client
          .from('order_items')
          .select('order_id, item_name, item_price, quantity')
          .inFilter('order_id', orderIds);

      // Group items by order_id
      final Map<String, List<Map<String, dynamic>>> itemsByOrderId = {};
      for (final item in itemsResponse) {
        final orderId = item['order_id'];
        if (!itemsByOrderId.containsKey(orderId)) {
          itemsByOrderId[orderId] = [];
        }
        itemsByOrderId[orderId]!.add({
          'item_name': item['item_name'],
          'item_price': item['item_price'],
          'quantity': item['quantity'],
        });
      }

      // Attach items to orders
      for (var order in orders) {
        final orderId = order['id'];
        order['order_items'] = itemsByOrderId[orderId] ?? [];
      }

      // Cache the result
      _cachedUserOrders = orders;
      _userOrdersCacheTime = DateTime.now();

      return orders;
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  // Get all orders (admin only)
  Future<List<Map<String, dynamic>>> getAllOrders({int? limit, int? offset}) async {
    // Return cached data if valid
    if (_cachedAllOrders != null && _isCacheValid(_ordersCacheTime)) {
      return _cachedAllOrders!;
    }

    try {
      // Get all orders with user info in one query
      var query = _client
          .from('orders')
          .select('*, users(username, email)')
          .order('order_date', ascending: false);

      // Apply pagination if provided
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }

      final ordersResponse = await query;

      final orders = List<Map<String, dynamic>>.from(ordersResponse);

      if (orders.isEmpty) {
        _cachedAllOrders = orders;
        _ordersCacheTime = DateTime.now();
        return orders;
      }

      // Get all order IDs
      final orderIds = orders.map((order) => order['id']).toList();

      // Batch fetch all order items for all orders in one query
      final itemsResponse = await _client
          .from('order_items')
          .select('order_id, item_name, item_price, quantity')
          .inFilter('order_id', orderIds);

      // Group items by order_id
      final Map<String, List<Map<String, dynamic>>> itemsByOrderId = {};
      for (final item in itemsResponse) {
        final orderId = item['order_id'];
        if (!itemsByOrderId.containsKey(orderId)) {
          itemsByOrderId[orderId] = [];
        }
        itemsByOrderId[orderId]!.add({
          'item_name': item['item_name'],
          'item_price': item['item_price'],
          'quantity': item['quantity'],
        });
      }

      // Attach items to orders
      for (var order in orders) {
        final orderId = order['id'];
        order['order_items'] = itemsByOrderId[orderId] ?? [];
      }

      // Cache the result
      _cachedAllOrders = orders;
      _ordersCacheTime = DateTime.now();

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

      // Clear caches since order data has changed
      clearCache();
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Get orders by status (for admin dashboard)
  Future<List<Map<String, dynamic>>> getOrdersByStatus(int status) async {
    try {
      // Get orders with user info in one query
      final ordersResponse = await _client
          .from('orders')
          .select('*, users(username, email)')
          .eq('status', status)
          .order('order_date', ascending: false);

      final orders = List<Map<String, dynamic>>.from(ordersResponse);

      if (orders.isEmpty) return orders;

      // Get all order IDs
      final orderIds = orders.map((order) => order['id']).toList();

      // Batch fetch all order items for all orders in one query
      final itemsResponse = await _client
          .from('order_items')
          .select('order_id, item_name, item_price, quantity')
          .inFilter('order_id', orderIds);

      // Group items by order_id
      final Map<String, List<Map<String, dynamic>>> itemsByOrderId = {};
      for (final item in itemsResponse) {
        final orderId = item['order_id'];
        if (!itemsByOrderId.containsKey(orderId)) {
          itemsByOrderId[orderId] = [];
        }
        itemsByOrderId[orderId]!.add({
          'item_name': item['item_name'],
          'item_price': item['item_price'],
          'quantity': item['quantity'],
        });
      }

      // Attach items to orders
      for (var order in orders) {
        final orderId = order['id'];
        order['order_items'] = itemsByOrderId[orderId] ?? [];
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  // Get order statistics (for admin)
  Future<Map<String, dynamic>> getOrderStatistics() async {
    // Return cached data if valid
    if (_cachedStatistics != null && _isCacheValid(_statisticsCacheTime)) {
      return _cachedStatistics!;
    }

    try {
      // Get all orders in one query with only necessary fields
      final allOrders = await _client
          .from('orders')
          .select('status, total_amount');

      final orders = List<Map<String, dynamic>>.from(allOrders);

      // Count orders by status and calculate revenue in memory
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

      final statistics = {
        'total_orders': orders.length,
        'completed_orders': statusCounts['status_3'] ?? 0,
        'pending_orders': (statusCounts['status_0'] ?? 0) + (statusCounts['status_1'] ?? 0) + (statusCounts['status_2'] ?? 0),
        'total_revenue': totalRevenue,
        'status_breakdown': statusCounts,
      };

      // Cache the result
      _cachedStatistics = statistics;
      _statisticsCacheTime = DateTime.now();

      return statistics;
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  // Helper method to convert database order to OrderItem format
  Future<List<Map<String, dynamic>>> getOrdersFormatted({bool isAdmin = false, int? limit, int? offset}) async {
    try {
      final orders = isAdmin ? await getAllOrders(limit: limit, offset: offset) : await getUserOrders(limit: limit, offset: offset);

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
      // Get orders with user info in one query
      final ordersResponse = await _client
          .from('orders')
          .select('*, users(username, email)')
          .inFilter('status', isCompleted ? [3] : [0, 1, 2])
          .order('order_date', ascending: false);

      final orders = List<Map<String, dynamic>>.from(ordersResponse);

      if (orders.isEmpty) return orders;

      // Get all order IDs
      final orderIds = orders.map((order) => order['id']).toList();

      // Batch fetch all order items for all orders in one query
      final itemsResponse = await _client
          .from('order_items')
          .select('order_id, item_name, item_price, quantity')
          .inFilter('order_id', orderIds);

      // Group items by order_id
      final Map<String, List<Map<String, dynamic>>> itemsByOrderId = {};
      for (final item in itemsResponse) {
        final orderId = item['order_id'];
        if (!itemsByOrderId.containsKey(orderId)) {
          itemsByOrderId[orderId] = [];
        }
        itemsByOrderId[orderId]!.add({
          'item_name': item['item_name'],
          'item_price': item['item_price'],
          'quantity': item['quantity'],
        });
      }

      // Attach items to orders
      for (var order in orders) {
        final orderId = order['id'];
        order['order_items'] = itemsByOrderId[orderId] ?? [];
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
