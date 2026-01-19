import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class DetailLaporanPage extends StatefulWidget {
  final String orderUuid;

  const DetailLaporanPage({super.key, required this.orderUuid});

  @override
  State<DetailLaporanPage> createState() => _DetailLaporanPageState();
}

class _DetailLaporanPageState extends State<DetailLaporanPage> {
  static const Color primaryColor = Color(0xFFDD0303);
  final OrderService _orderService = OrderService();

  bool _isLoading = true;
  Map<String, dynamic>? _orderData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    try {
      final data = await _orderService.getOrderDetails(widget.orderUuid);
      if (mounted) {
        setState(() {
          _orderData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_errorMessage.isNotEmpty || _orderData == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text('Gagal memuat detail laporan: $_errorMessage'),
        ),
      );
    }

    final order = _orderData!;
    final orderId = order['order_id'] ?? '-';
    final customerName = order['users']?['username'] ?? 'Tamu';
    final customerEmail = order['users']?['email'] ?? '-';
    final deliveryLocation = order['delivery_address'] ?? '-';
    final phoneNumber = order['phone'] ?? '-';
    final notes = order['notes'] ?? '-';
    final deliveryFee = order['shipping_cost'] as int? ?? 0;
    final totalAmount = order['total_amount'] as int? ?? 0;
    final orderItems = List<Map<String, dynamic>>.from(order['order_items'] ?? []);

    // Calculate subtotal from items
    int subtotal = 0;
    for (var item in orderItems) {
      subtotal += (item['item_price'] as int) * (item['quantity'] as int);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: primaryColor,
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          "Detail Laporan",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan Order ID
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order ID',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Informasi Pelanggan
              _buildInfoSection(
                title: 'Informasi Pelanggan',
                children: [
                  _buildInfoRow('Nama', customerName),
                  _buildInfoRow('Email', customerEmail),
                  _buildInfoRow('Lokasi Pengiriman', deliveryLocation),
                  _buildInfoRow('No. HP', phoneNumber),
                ],
              ),

              const SizedBox(height: 16),

              // Daftar Pesanan
              _buildOrderItemsSection(orderItems),

              const SizedBox(height: 16),

              // Catatan
              if (notes != null && notes.toString().isNotEmpty) 
              _buildInfoSection(
                title: 'Catatan',
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      notes,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              if (notes != null && notes.toString().isNotEmpty)
              const SizedBox(height: 16),

              // Ringkasan Pembayaran
              _buildPaymentSummary(subtotal, deliveryFee, totalAmount),

              const SizedBox(height: 24),

              // Status LUNAS (Hanya jika status == 3 / Selesai, atau sesuaikan)
              if (order['status'] == 3)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: const Center(
                  child: Text(
                    'LUNAS',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(List<Map<String, dynamic>> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Pesanan',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
             final itemTotal = (item['item_price'] ?? 0) * (item['quantity'] ?? 0);
             return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['item_name'] ?? 'Item',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${item['quantity']}x @ ${_formatCurrency(item['item_price'] ?? 0)}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(itemTotal),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(int subtotal, int deliveryFee, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          const Text(
            'Ringkasan Pembayaran',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentRow('Subtotal Pesanan', _formatCurrency(subtotal)),
          _buildPaymentRow('Biaya Pengiriman', _formatCurrency(deliveryFee)),
          const Divider(height: 16, color: Colors.black26),
          _buildPaymentRow('Total', _formatCurrency(total), isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.black54,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isTotal ? primaryColor : Colors.black87,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
