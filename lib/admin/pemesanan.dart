import 'package:flutter/material.dart';

class PemesananPage extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final int shippingCost;
  final String orderNumber;
  final int currentStatus;

  const PemesananPage({
    super.key,
    required this.orderItems,
    required this.shippingCost,
    required this.orderNumber,
    required this.currentStatus,
  });

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  static const Color primaryColor = Color(0xFFDD0303);
  static const Color accentColor = Colors.black;
  static const Color cardColor = Colors.white;

  late int currentStatusIndex; // State lokal untuk status saat ini

  final List<Map<String, dynamic>> statusData = [
    {'title': 'ORDER', 'icon': Icons.list_alt},
    {'title': 'PROSES', 'icon': Icons.hourglass_bottom},
    {'title': 'KIRIM', 'icon': Icons.local_shipping},
    {'title': 'TIBA', 'icon': Icons.check_circle},
  ];

  @override
  void initState() {
    super.initState();
    currentStatusIndex = widget.currentStatus; // Initialize dengan status dari widget
  }

  // Calculate total price from order items
  int getTotalPrice() {
    int total = 0;
    for (var item in widget.orderItems) {
      total += (item['harga'] as int) * (item['quantity'] as int);
    }
    return total + widget.shippingCost;
  }

  // Format currency helper
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }


  // Update Status - bisa update ke step manapun
  void _updateStatus(int targetIndex) {
    setState(() {
      currentStatusIndex = targetIndex; // Update status lokal
    });

    // Note: In a real app, this would update the status in a backend/database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status berhasil diperbarui menjadi: ${statusData[targetIndex]['title']}'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
    // Dalam implementasi nyata, status akan disimpan ke backend/database
  }

  // Tahapan Proses
  Widget _buildProcessStepWithButton(Map<String, dynamic> data, int index) {
    bool isActive = index <= currentStatusIndex;
    Color color = isActive ? Colors.white : Colors.white70;
    const double buttonAreaHeight = 40;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            color: isActive ? Colors.white.withAlpha(51) : Colors.transparent,
          ),
          child: Icon(
            data['icon'] as IconData,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data['title'] as String,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
        ),
        const SizedBox(height: 8),

        // Tombol update - muncul untuk semua step
        SizedBox(
          height: buttonAreaHeight,
          child: OutlinedButton(
            onPressed: () => _updateStatus(index),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('UPDATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // Pesanan
  Widget _buildOrderItem(String name, String price, int quantity) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container( 
                width: 50, height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor),
                    ),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '${quantity.toString()}x', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE0E0E0)) 
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> timelineWidgets = [];
    for (int i = 0; i < statusData.length; i++) {
      timelineWidgets.add(_buildProcessStepWithButton(statusData[i], i));
      if (i < statusData.length - 1) {
        bool isActiveLine = i < currentStatusIndex;
        Color lineColor = isActiveLine ? Colors.white : Colors.white70;

        timelineWidgets.add(
          Expanded(
            child: Container(
              height: 2,
              color: lineColor,
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: primaryColor, 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Proses Pesanan', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            
            // Header Info Pesanan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              color: primaryColor,
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white70, size: 20),
                  const SizedBox(width: 10),
                  const Text('Order ID:', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold,)),
                  Expanded(
                    child: Text(
                      ' ${widget.orderNumber}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // Timeline Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: timelineWidgets,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            Container(
              decoration: const BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Pengiriman
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Informasi Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                            const Divider(height: 20, thickness: 1.5, color: Color(0xFFEEEEEE)),
                            const SizedBox(height: 10),

                            // Lokasi Pengiriman
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: primaryColor, size: 20),
                                const SizedBox(width: 10),
                                const Text('Lokasi Pengiriman:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: accentColor)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: const Text(
                                'Jl. Contoh No. 123, Kelurahan ABC, Kecamatan XYZ, Kota Jakarta',
                                style: TextStyle(fontSize: 14, color: accentColor),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // No HP
                            Row(
                              children: [
                                const Icon(Icons.phone, color: primaryColor, size: 20),
                                const SizedBox(width: 10),
                                const Text('No HP:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: accentColor)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: const Text(
                                '0812-3456-7890',
                                style: TextStyle(fontSize: 14, color: accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detail Pesanan
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Detail Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                            const Divider(height: 20, thickness: 1.5, color: Color(0xFFEEEEEE)),
                            
                            // Daftar Item Pesanan
                            ...widget.orderItems.map((item) {
                              return _buildOrderItem(item['name'] as String, item['price'] as String, item['quantity'] as int);
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Catatan
                    const Text('Catatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor)),
                    const SizedBox(height: 5),
                    const TextField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Tambahkan catatan...',
                        contentPadding: EdgeInsets.all(8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Biaya Pengiriman
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Pengiriman', style: TextStyle(fontSize: 16, color: accentColor)),
                        Text(
                          'Rp ${_formatCurrency(widget.shippingCost)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor)
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Total Biaya
                    const Text('Total Biaya', style: TextStyle(fontSize: 16, color: accentColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Container(
                      width: 130,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Rp ${_formatCurrency(getTotalPrice())}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text('Lunas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 30),

                    // Tombol Selesai
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Kembali ke halaman order_page (beranda admin)
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pesanan ${widget.orderNumber} telah diselesaikan.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Selesai', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}