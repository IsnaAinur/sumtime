import 'package:flutter/material.dart';
import 'nav._bottom.dart';
import 'pemesanan.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool _showCompletedOrders = false; // false = Pesanan Berlangsung, true = Selesai

  final List<Map<String, dynamic>> orders = [
    {"id": "ORD-001", "price": 20000, "status": "ongoing"},
    {"id": "ORD-002", "price": 20000, "status": "ongoing"},
    {"id": "ORD-003", "price": 20000, "status": "completed"},
    {"id": "ORD-004", "price": 20000, "status": "completed"},
  ];

  List<Map<String, dynamic>> _getFilteredOrders() {
    return orders.where((order) {
      final status = order['status'];
      if (_showCompletedOrders) {
        return status == 'completed'; // Tampilkan yang selesai
      } else {
        return status == 'ongoing'; // Tampilkan yang berlangsung
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: _getFilteredOrders().length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Center(
                            child: Text(
                              'List Orderan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFDD0303),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Berlangsung',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: _showCompletedOrders,
                                onChanged: (value) {
                                  setState(() {
                                    _showCompletedOrders = value;
                                  });
                                },
                                activeColor: const Color(0xFFDD0303),
                                activeTrackColor: const Color(0xFFDD0303).withOpacity(0.3),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Selesai',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }

              // Kartu Order
              final filteredOrders = _getFilteredOrders();
              final order = filteredOrders[index - 1];
              return OrderCard(
                orderId: order['id'],
                price: order['price'],
                onAccept: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PemesananPage()),
                  );
                },
              );
            },
          ),
        ),
      ),

      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderId,
    required this.price,
    required this.onAccept,
  });

  // Order Card
  final String orderId;
  final int price;
  final VoidCallback onAccept;

  static const Color redColor = Color(0xFFDD0303);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: redColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID: $orderId',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp $price',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Terima'),
            ),
          ),
        ],
      ),
    );
  }
}
