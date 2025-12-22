class OrderItem {
  final String id;
  final String orderId;
  final String priceText;
  final List<OrderItemDetail> orderItems;
  final int shippingCost;
  final DateTime orderDate;
  final int status; // 0: Diterima, 1: Dibuatkan, 2: Pengantaran, 3: Selesai
  final String? deliveryAddress;
  final String? phone;
  final String? notes;
  final String? customerName;
  final String? customerEmail;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.priceText,
    required this.orderItems,
    required this.shippingCost,
    required this.orderDate,
    required this.status,
    this.deliveryAddress,
    this.phone,
    this.notes,
    this.customerName,
    this.customerEmail,
  });

  // Factory constructor to create OrderItem from Supabase response
  factory OrderItem.fromSupabase(Map<String, dynamic> data) {
    final orderItems = (data['order_items'] as List<dynamic>? ?? [])
        .map((item) => OrderItemDetail.fromMap(item))
        .toList();

    final user = data['users'];
    final totalAmount = data['total_amount'] as int? ?? 0;
    final shippingCost = data['shipping_cost'] as int? ?? 10000;

    // Calculate price text
    final subtotal = orderItems.fold(0, (sum, item) => sum + (item.harga * item.quantity));
    final total = subtotal + shippingCost;

    return OrderItem(
      id: data['id'],
      orderId: data['order_id'] ?? '',
      priceText: 'Rp. ${total.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}',
      orderItems: orderItems,
      shippingCost: shippingCost,
      orderDate: DateTime.parse(data['order_date']),
      status: data['status'] ?? 0,
      deliveryAddress: data['delivery_address'],
      phone: data['phone'],
      notes: data['notes'],
      customerName: user?['username'],
      customerEmail: user?['email'],
    );
  }

  // Convert to map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'priceText': priceText,
      'orderItems': orderItems.map((item) => item.toMap()).toList(),
      'shippingCost': shippingCost,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'deliveryAddress': deliveryAddress,
      'phone': phone,
      'notes': notes,
      'customerName': customerName,
      'customerEmail': customerEmail,
    };
  }

  // Factory constructor from local storage
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      priceText: map['priceText'] ?? '',
      orderItems: (map['orderItems'] as List<dynamic>? ?? [])
          .map((item) => OrderItemDetail.fromMap(item))
          .toList(),
      shippingCost: map['shippingCost'] ?? 10000,
      orderDate: DateTime.parse(map['orderDate']),
      status: map['status'] ?? 0,
      deliveryAddress: map['deliveryAddress'],
      phone: map['phone'],
      notes: map['notes'],
      customerName: map['customerName'],
      customerEmail: map['customerEmail'],
    );
  }

  // Copy with method for updating
  OrderItem copyWith({
    String? id,
    String? orderId,
    String? priceText,
    List<OrderItemDetail>? orderItems,
    int? shippingCost,
    DateTime? orderDate,
    int? status,
    String? deliveryAddress,
    String? phone,
    String? notes,
    String? customerName,
    String? customerEmail,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      priceText: priceText ?? this.priceText,
      orderItems: orderItems ?? this.orderItems,
      shippingCost: shippingCost ?? this.shippingCost,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
    );
  }
}

class OrderItemDetail {
  final String name;
  final String price; // Display price
  final int harga; // Numeric price
  final int quantity;

  const OrderItemDetail({
    required this.name,
    required this.price,
    required this.harga,
    required this.quantity,
  });

  factory OrderItemDetail.fromMap(Map<String, dynamic> map) {
    return OrderItemDetail(
      name: map['name'] ?? map['item_name'] ?? '',
      price: map['price'] ?? 'Rp ${map['item_price'] ?? 0}',
      harga: map['harga'] ?? map['item_price'] ?? 0,
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'harga': harga,
      'quantity': quantity,
    };
  }
}
