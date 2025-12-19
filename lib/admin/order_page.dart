import 'package:flutter/material.dart';
import 'nav._bottom.dart';
import 'pemesanan.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int selectedTab = 0; // 0: Berlangsung, 1: Selesai
  static const Color kRed = Color(0xFFDD0303);

  final List<Map<String, dynamic>> orders = [
    {"id": "ORD-001", "price": 20000, "status": "ongoing", "accepted": false},
    {"id": "ORD-002", "price": 20000, "status": "ongoing", "accepted": true},
    {"id": "ORD-003", "price": 20000, "status": "completed", "accepted": true},
    {"id": "ORD-004", "price": 20000, "status": "completed", "accepted": true},
  ];

  List<Map<String, dynamic>> get filteredOrders {
    return orders.where((order) {
      final status = order['status'];
      if (selectedTab == 1) { // Selesai
        return status == 'completed';
      } else { // Berlangsung
        return status == 'ongoing';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        // title samping tombol
        title: const Text(
          'List Orderan',
          style: TextStyle(color: kRed, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Tabs(
                red: kRed,
                selectedIndex: selectedTab,
                onChanged: (i) => setState(() => selectedTab = i),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _OrderCard(
                      red: kRed,
                      orderId: order['id'],
                      priceText: order['price'].toString(),
                      accepted: order['accepted'],
                      showButtons: selectedTab == 0, // Only show buttons for "Berlangsung" tab
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PemesananPage()),
                        );
                      },
                      onAccept: () {
                        setState(() {
                          order['accepted'] = true;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }
}

class _Tabs extends StatelessWidget {
  final Color red;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _Tabs({
    required this.red,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: red, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Berlangsung',
              red: red,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Container(width: 3, color: red),
          Expanded(
            child: _TabButton(
              label: 'Selesai',
              red: red,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final Color red;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.red,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? red : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Color red;
  final String orderId;
  final String priceText;
  final bool accepted;
  final bool showButtons;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;

  const _OrderCard({
    required this.red,
    required this.orderId,
    required this.priceText,
    required this.accepted,
    required this.showButtons,
    this.onTap,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: red,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ID',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (showButtons)
                    GestureDetector(
                      onTap: accepted ? null : onAccept,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          accepted ? 'Sedang di proses' : 'Terima',
                          style: TextStyle(
                            color: accepted ? Colors.grey : const Color(0xFFDD0303),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                orderId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Rp. $priceText',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

