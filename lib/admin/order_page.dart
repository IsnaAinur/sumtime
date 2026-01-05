import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../login.dart';
import 'pemesanan.dart';
import 'nav._bottom.dart';
import '../services/order_service.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const Color kRed = Color(0xFFDD0303);

  int selectedTab = 0; // 0: Berlangsung, 1: Selesai

  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      return await _orderService.getOrdersFormatted(isAdmin: true);
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

  // Method untuk mengubah status pesanan di database
  Future<void> _updateOrderStatus(String orderId, int newStatus) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      _refreshOrders(); // Refresh data setelah update
    } catch (e) {
      debugPrint('Error updating order status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // Method untuk menampilkan dialog logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(
              color: Color(0xFFDD0303),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog

                // Clear session data
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Navigate ke halaman login
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDD0303),
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Order Page',
          style: TextStyle(
            color: kRed,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshOrders,
            icon: const Icon(Icons.refresh, color: kRed),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout, color: kRed),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
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
                        return status < 3; // Berlangsung (0, 1, 2)
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

                    return RefreshIndicator(
                      onRefresh: () async => _refreshOrders(),
                      color: kRed,
                      child: ListView.separated(
                        itemCount: filteredOrders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final orderId = order['id'] as String? ?? '';
                          final orderNumber = order['orderId'] as String? ?? 'N/A';
                          final status = order['status'] as int? ?? 0;

                          return _OrderCard(
                            red: kRed,
                            orderId: orderNumber,
                            priceText: order['priceText'] ?? 'Rp. 0',
                            status: status,
                            isUpdating: _isUpdating,
                            onAccept: () async {
                              // Logic untuk update status
                              String message;
                              int newStatus;

                              if (status == 0) {
                                newStatus = 1;
                                message = 'Pesanan $orderNumber diterima dan sedang diproses!';
                              } else if (status == 1) {
                                newStatus = 2;
                                message = 'Pesanan $orderNumber siap untuk pengantaran!';
                              } else if (status == 2) {
                                newStatus = 3;
                                message = 'Pesanan $orderNumber telah selesai!';
                              } else {
                                return; // Already complete
                              }

                              await _updateOrderStatus(orderId, newStatus);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
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
                                  builder: (context) => PemesananPage(
                                    orderItems: orderItems,
                                    shippingCost: order['shippingCost'] ?? 10000,
                                    orderNumber: orderNumber,
                                    currentStatus: status,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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
  final int status;
  final bool isUpdating;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;

  const _OrderCard({
    required this.red,
    required this.orderId,
    required this.priceText,
    required this.status,
    this.isUpdating = false,
    this.onTap,
    this.onAccept,
  });

  String _getStatusText() {
    switch (status) {
      case 0:
        return 'Terima';
      case 1:
        return 'Proses';
      case 2:
        return 'Antar';
      case 3:
        return 'Selesai';
      default:
        return 'Unknown';
    }
  }

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
          child: Stack(
            children: [
              Column(
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
              // Tombol berdasarkan status
              Positioned(
                bottom: 0,
                right: 0,
                child: _buildStatusButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton() {
    // Status 3 = Selesai, don't show action button
    if (status == 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '✓ Selesai',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    }

    // Status 0, 1, 2 = Action buttons
    return ElevatedButton(
      onPressed: isUpdating ? null : onAccept,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: red,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: isUpdating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              _getStatusText(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
    );
  }
}
