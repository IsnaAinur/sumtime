import 'package:flutter/material.dart';
import 'beranda.dart';

class RincianPesananPage extends StatefulWidget {
  final List<Map<String, dynamic>>? orderItems;
  final int? shippingCost;
  final String? orderNumber;
  final DateTime? orderDate;

  const RincianPesananPage({
    super.key,
    this.orderItems,
    this.shippingCost,
    this.orderNumber,
    this.orderDate,
  });

  @override
  State<RincianPesananPage> createState() => _RincianPesananPageState();
}

class _RincianPesananPageState extends State<RincianPesananPage> {
  // Sample data jika tidak ada data yang diteruskan
  late List<Map<String, dynamic>> _orderItems;
  late int _shippingCost;
  late String _orderNumber;
  late DateTime _orderDate;
  int _currentStatus = 1; // 0: Diterima, 1: Dibuatkan, 2: Pengantaran, 3: Selesai

  // Status labels
  final List<String> _statusLabels = [
    'Pesanan Diterima',
    'Pesanan Dibuatkan',
    'Makanan dalam Pengantaran',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    // Gunakan data yang diteruskan atau sample data
    _orderItems = widget.orderItems ?? [
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
    ];
    _shippingCost = widget.shippingCost ?? 10000;
    _orderNumber = widget.orderNumber ?? 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _orderDate = widget.orderDate ?? DateTime.now();
  }

  int _calculateSubtotal() {
    int subtotal = 0;
    for (var item in _orderItems) {
      final int harga = (item['harga'] ?? 0) as int;
      final int qty = (item['quantity'] ?? 1) as int;
      subtotal += harga * qty;
    }
    return subtotal;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFDD0303);
    const Color backgroundColor = Color(0xFFFAFAFA);

    // Kelompokkan item berdasarkan nama untuk menampilkan qty
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final item in _orderItems) {
      final String name = (item['name'] ?? 'Menu').toString();
      if (!grouped.containsKey(name)) {
        grouped[name] = {
          'item': item,
          'qty': item['quantity'] ?? 1,
        };
      } else {
        grouped[name]!['qty'] = (grouped[name]!['qty'] as int) + (item['quantity'] ?? 1);
      }
    }
    final entries = grouped.entries.toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Rincian Pesanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === INFO NOTA ===
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nomor Pesanan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _orderNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tanggal Pesanan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${_orderDate.day}/${_orderDate.month}/${_orderDate.year} ${_orderDate.hour.toString().padLeft(2, '0')}:${_orderDate.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // === INFO PESANAN SECTION ===
            const Text(
              'Info Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Progress indicator dengan label status
            Column(
              children: [
                // Progress boxes dan lines
                Row(
                  children: [
                    _buildProgressBox(0, primaryColor),
                    _buildProgressLine(0),
                    _buildProgressBox(1, primaryColor),
                    _buildProgressLine(1),
                    _buildProgressBox(2, primaryColor),
                    _buildProgressLine(2),
                    _buildProgressBox(3, primaryColor),
                  ],
                ),
                const SizedBox(height: 12),
                // Labels di bawah progress
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusLabel(0, _statusLabels[0]),
                    ),
                    Expanded(
                      child: _buildStatusLabel(1, _statusLabels[1]),
                    ),
                    Expanded(
                      child: _buildStatusLabel(2, _statusLabels[2]),
                    ),
                    Expanded(
                      child: _buildStatusLabel(3, _statusLabels[3]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kami akan memberi tahu saat Pesanan diantar',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // === ITEM DETAILS SECTION ===
            const Text(
              'Item Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Container untuk daftar item
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: entries.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada item',
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < entries.length; i++) ...[
                          _buildOrderItem(
                            itemName: entries[i].key,
                            price: (entries[i].value['item']['price'] ?? 'Rp 0').toString(),
                            quantity: entries[i].value['qty'] as int,
                          ),
                          if (i != entries.length - 1)
                            const Divider(height: 24),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 32),

            // === RINGKASAN BIAYA ===
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Rp ${_formatPrice(_calculateSubtotal())}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Biaya Pengiriman
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Biaya Pengiriman',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Rp ${_formatPrice(_shippingCost)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Rp ${_formatPrice(_calculateSubtotal() + _shippingCost)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDD0303),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Status Pembayaran
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Lunas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // === TOMBOL KEMBALI KE BERANDA ===
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Kembali ke beranda dengan menghapus semua halaman sebelumnya
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const BerandaPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDD0303),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Kembali ke Beranda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat kotak progress indicator
  Widget _buildProgressBox(int index, Color color) {
    final bool isActive = index <= _currentStatus;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.transparent,
        border: Border.all(
          color: isActive ? color : Colors.grey.shade400,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isActive
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            )
          : null,
    );
  }

  // Widget untuk membuat garis progress indicator
  Widget _buildProgressLine(int index) {
    final bool isActive = index < _currentStatus;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFFDD0303) : Colors.grey.shade300,
      ),
    );
  }

  // Widget untuk label status
  Widget _buildStatusLabel(int index, String label) {
    final bool isActive = index <= _currentStatus;
    return Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        color: isActive ? const Color(0xFFDD0303) : Colors.grey.shade600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Widget untuk membuat tampilan satu item pesanan
  Widget _buildOrderItem({
    required String itemName,
    required String price,
    required int quantity,
  }) {
    return Row(
      children: [
        // Placeholder gambar (kotak kecil)
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: const Icon(Icons.image, color: Colors.grey),
        ),
        const SizedBox(width: 12),

        // Nama dan harga item
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),

        // Quantity indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            quantity.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Kotak kecil tambahan (sesuai sketsa)
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
