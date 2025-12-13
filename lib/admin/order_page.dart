import 'package:flutter/material.dart';
import 'nav._bottom.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {

  final List<Map<String, dynamic>> orders = [
    {"id": "ORD-001", "price": 20000},
    {"id": "ORD-002", "price": 20000},
    {"id": "ORD-003", "price": 20000},
    {"id": "ORD-004", "price": 20000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: orders.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: const [
                    SizedBox(height: 8),
                    Center(
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
                    SizedBox(height: 8),
                  ],
                );
              }

              // Kartu Order
              final order = orders[index - 1];
              return OrderCard(
                orderId: order['id'],
                price: order['price'],
                onAccept: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order ${order['id']} diterima')),
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
