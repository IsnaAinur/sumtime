import 'package:flutter/material.dart';
import 'rincianpesanan.dart';
import 'services/order_service.dart';

class HistoryPesananPage extends StatefulWidget {
  const HistoryPesananPage({super.key});

  @override
  State<HistoryPesananPage> createState() => _HistoryPesananPageState();
}

class _HistoryPesananPageState extends State<HistoryPesananPage> {
  static const Color kRed = Color(0xFFDD0303);

  int selectedTab = 0; // 0: Berlangsung, 1: Selesai
  int _currentIndex = 1; // Bottom nav index, 1 = History

  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      return await _orderService.getOrdersFormatted();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kRed),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'History Pesanan',
          style: TextStyle(color: kRed, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kRed),
            onPressed: _refreshOrders,
            tooltip: 'Refresh',
          ),
        ],
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
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _ordersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: kRed),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: kRed, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat pesanan',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _refreshOrders,
                              style: ElevatedButton.styleFrom(backgroundColor: kRed),
                              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }

                    final allOrders = snapshot.data ?? [];

                    // Filter orders based on selected tab
                    // Berlangsung: status < 3, Selesai: status == 3
                    final filteredOrders = allOrders.where((order) {
                      final status = order['status'] as int? ?? 0;
                      if (selectedTab == 0) {
                        return status < 3; // Berlangsung
                      } else {
                        return status == 3; // Selesai
                      }
                    }).toList();

                    if (filteredOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedTab == 0 ? Icons.pending_actions : Icons.check_circle_outline,
                              color: Colors.grey[400],
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedTab == 0
                                  ? 'Tidak ada pesanan berlangsung'
                                  : 'Belum ada pesanan selesai',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _OrderCard(
                          red: kRed,
                          orderId: order['orderId'] ?? 'N/A',
                          priceText: order['priceText'] ?? 'Rp. 0',
                          onTap: () {
                            // Parse orderDate
                            DateTime orderDate;
                            final dateValue = order['orderDate'];
                            if (dateValue is DateTime) {
                              orderDate = dateValue;
                            } else if (dateValue is String) {
                              orderDate = DateTime.tryParse(dateValue) ?? DateTime.now();
                            } else {
                              orderDate = DateTime.now();
                            }

                            // Convert orderItems to required format
                            final orderItems = (order['orderItems'] as List<dynamic>? ?? [])
                                .map((item) => Map<String, dynamic>.from(item as Map))
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RincianPesananPage(
                                  orderItems: orderItems,
                                  shippingCost: order['shippingCost'] ?? 10000,
                                  orderNumber: order['orderId'] ?? 'N/A',
                                  orderDate: orderDate,
                                  currentStatus: order['status'] ?? 0,
                                ),
                              ),
                            );
                          },
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: kRed,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
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
                priceText,
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