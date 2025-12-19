import 'package:flutter/material.dart';
import 'rincianpesanan.dart';
import 'bottom_nav_user.dart';
import 'beranda.dart';
import 'profile.dart';

class HistoryPesananPage extends StatefulWidget {
  const HistoryPesananPage({super.key});

  @override
  State<HistoryPesananPage> createState() => _HistoryPesananPageState();
}

class _HistoryPesananPageState extends State<HistoryPesananPage> {
  static const Color kRed = Color(0xFFDD0303);

  int selectedTab = 0; // 0: Berlangsung, 1: Selesai

  // Data pesanan berlangsung (status 0-2)
  final List<OrderItem> berlangsung = [
    OrderItem(
      orderId: 'ORD-1001',
      priceText: 'Rp. 81.000',
      orderItems: [
        {
          'name': 'Dimsum Ayam',
          'price': 'Rp 25.000',
          'harga': 25000,
          'quantity': 1,
        },
        {
          'name': 'Dimsum Udang',
          'price': 'Rp 28.000',
          'harga': 28000,
          'quantity': 2,
        },
      ],
      shippingCost: 10000,
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
      status: 1, // Pesanan Dibuatkan
    ),
    OrderItem(
      orderId: 'ORD-1002',
      priceText: 'Rp. 120.000',
      orderItems: [
        {
          'name': 'Dimsum Ayam',
          'price': 'Rp 25.000',
          'harga': 25000,
          'quantity': 3,
        },
        {
          'name': 'Es Jeruk',
          'price': 'Rp 15.000',
          'harga': 15000,
          'quantity': 3,
        },
      ],
      shippingCost: 10000,
      orderDate: DateTime.now().subtract(const Duration(hours: 5)),
      status: 2, // Makanan dalam Pengantaran
    ),
    OrderItem(
      orderId: 'ORD-1003',
      priceText: 'Rp. 67.500',
      orderItems: [
        {
          'name': 'Dimsum Udang',
          'price': 'Rp 28.000',
          'harga': 28000,
          'quantity': 1,
        },
        {
          'name': 'Es Teh',
          'price': 'Rp 12.000',
          'harga': 12000,
          'quantity': 1,
        },
      ],
      shippingCost: 10000,
      orderDate: DateTime.now().subtract(const Duration(minutes: 30)),
      status: 0, // Pesanan Diterima
    ),
  ];

  // Data pesanan selesai (status 3)
  final List<OrderItem> selesai = [
    OrderItem(
      orderId: 'ORD-0901',
      priceText: 'Rp. 99.000',
      orderItems: [
        {
          'name': 'Dimsum Ayam',
          'price': 'Rp 25.000',
          'harga': 25000,
          'quantity': 2,
        },
        {
          'name': 'Dimsum Udang',
          'price': 'Rp 28.000',
          'harga': 28000,
          'quantity': 1,
        },
        {
          'name': 'Es Jeruk',
          'price': 'Rp 15.000',
          'harga': 15000,
          'quantity': 1,
        },
      ],
      shippingCost: 10000,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 3, // Selesai
    ),
    OrderItem(
      orderId: 'ORD-0902',
      priceText: 'Rp. 50.000',
      orderItems: [
        {
          'name': 'Dimsum Ayam',
          'price': 'Rp 25.000',
          'harga': 25000,
          'quantity': 1,
        },
        {
          'name': 'Es Teh',
          'price': 'Rp 12.000',
          'harga': 12000,
          'quantity': 1,
        },
      ],
      shippingCost: 10000,
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      status: 3, // Selesai
    ),
  ];

  void _onNavigate(int index) {
    if (index == 1) return; // Already on history

    Widget page;
    switch (index) {
      case 0:
        page = const BerandaPage();
        break;
      case 2:
        page = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = selectedTab == 0 ? berlangsung : selesai;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        // title samping tombol
        title: const Text(
          'History Pesanan',
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
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final it = items[index];
                    return _OrderCard(
                      red: kRed,
                      orderId: it.orderId,
                      priceText: it.priceText,
                      onTap: () {
                        // Navigasi ke halaman rincian pesanan dengan data lengkap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RincianPesananPage(
                              orderItems: it.orderItems,
                              shippingCost: it.shippingCost,
                              orderNumber: it.orderId,
                              orderDate: it.orderDate,
                              currentStatus: it.status,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavUser(
        currentIndex: 1, // 1 for History Pesanan
        onNavigate: _onNavigate,
      ),
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
    final bgColor = selected ? red : Colors.white;
    final textColor = selected ? Colors.white : red;

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
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
  final VoidCallback? onTap;

  const _OrderCard({
    required this.red,
    required this.orderId,
    required this.priceText,
    this.onTap,
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
              Text(
                'Order ID',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w700,
                ),
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
                'Rp. $priceText'.replaceFirst('Rp. Rp.', 'Rp. '),
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

class OrderItem {
  final String orderId;
  final String priceText;
  final List<Map<String, dynamic>> orderItems;
  final int shippingCost;
  final DateTime orderDate;
  final int status; // 0: Diterima, 1: Dibuatkan, 2: Pengantaran, 3: Selesai

  const OrderItem({
    required this.orderId,
    required this.priceText,
    required this.orderItems,
    required this.shippingCost,
    required this.orderDate,
    required this.status,
  });
}
