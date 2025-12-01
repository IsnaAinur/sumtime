import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  /// List keranjang dengan struktur yang sama seperti di `beranda.dart`
  /// Contoh item: { 'name': 'Dimsum Ayam', 'price': 'Rp 25.000', 'image': '...' }
  final List<Map<String, dynamic>> cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Controller untuk mengambil teks dari input field (opsional untuk saat ini)
  final TextEditingController _outletController =
      TextEditingController(text: 'Jl. Bhayangkara No.55, Tipes');
  final TextEditingController _deliveryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup agar tidak memory leak
    _outletController.dispose();
    _deliveryController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Membuka Google Maps dengan rute dari outlet tetap ke alamat tujuan user.
  ///
  /// [destination] adalah alamat yang diisi user (lokasi pengiriman).
  Future<void> _openInMaps(String destination) async {
    // Alamat outlet tetap (origin)
    const String origin = 'Jl. Bhayangkara No.55, Tipes';

    final encodedOrigin = Uri.encodeComponent(origin);
    final encodedDestination = Uri.encodeComponent(destination);
    // Format URL directions Google Maps
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$encodedOrigin'
      '&destination=$encodedDestination'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kelompokkan item berdasarkan nama untuk menampilkan qty (sama seperti di beranda.dart)
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final product in widget.cart) {
      final String name = (product['name'] ?? 'Menu').toString();
      if (!grouped.containsKey(name)) {
        grouped[name] = {
          'product': product,
          'qty': 1,
        };
      } else {
        grouped[name]!['qty'] = (grouped[name]!['qty'] as int) + 1;
      }
    }
    final entries = grouped.entries.toList();

    // Menggunakan Scaffold sebagai kerangka dasar halaman
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Menghilangkan bayangan di bawah AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFDD0303)),
          onPressed: () {
            // Aksi saat tombol kembali ditekan (kembali ke halaman sebelumnya)
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(
            color: Color(0xFFDD0303),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // Judul di kiri sesuai gambar
      ),
      // Menggunakan SingleChildScrollView agar halaman bisa discroll
      // jika keyboard muncul atau isinya panjang
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === BAGIAN DELIVERY ===
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDD0303), width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFFEBEE),
              ),
              child: const Text(
                'Delivery',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFDD0303),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Input Field Lokasi Outlet (tidak bisa diubah, dummy lokasi)
            _buildTextField(
              label: 'Lokasi outlet',
              controller: _outletController,
              readOnly: true,
            ),
            const SizedBox(height: 15),

            // Input Field Lokasi Pengiriman (bisa ketik + pilih dari Maps)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Lokasi Pengiriman',
                    controller: _deliveryController,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_deliveryController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Isi alamat pengiriman terlebih dahulu atau ketuk di Maps.',
                            ),
                          ),
                        );
                        return;
                      }
                      await _openInMaps(_deliveryController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDD0303),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.map),
                    label: const Text(
                      'Pilih',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Input Field No. HP
            _buildTextField(
              label: 'No. HP',
              controller: _phoneController,
              keyboardType: TextInputType.phone, // Keyboard khusus angka
            ),

            const SizedBox(height: 30),

            // === BAGIAN PESANAN ===
            const Text(
              'Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDD0303),
              ),
            ),
            const SizedBox(height: 10),

            // Kotak pembungkus daftar pesanan (diisi dari keranjang seperti di beranda.dart)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDD0303)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: entries.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada pesanan',
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < entries.length; i++) ...[
                          Builder(
                            builder: (context) {
                              final entry = entries[i];
                              final product = entry.value['product']
                                  as Map<String, dynamic>;
                              final int qty = entry.value['qty'] as int;
                              final String price =
                                  (product['price'] ?? '-').toString();

                              return _buildOrderItem(
                                itemName: entry.key,
                                price: price,
                                quantity: qty,
                              );
                            },
                          ),
                          if (i != entries.length - 1)
                            const Divider(height: 30), // Garis pemisah antar item
                        ],
                      ],
                    ),
            ),

            const SizedBox(height: 30),

            // === BAGIAN CATATAN ===
            const Text(
              'Catatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDD0303),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3, // Membuat area teks lebih tinggi untuk catatan
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan untuk pesanan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDD0303)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDD0303)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFDD0303),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 30),

            // === BAGIAN TOTAL BIAYA ===
            // Biaya Pengiriman
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Biaya pengiriman',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Rp 10.000',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDD0303),
                  ),
                ), // Dummy
              ],
            ),
            const SizedBox(height: 15),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDD0303),
                  ),
                ),
                Text(
                  'Rp 35.000', // Dummy Total (15 + (5*2) + 10)
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDD0303),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // === TOMBOL BAYAR SEKARANG ===
            SizedBox(
              width: double.infinity, // Tombol selebar layar
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi ketika tombol ditekan
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Melanjutkan ke pembayaran...'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDD0303),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Jarak aman di bawah tombol
          ],
        ),
      ),
    );
  }

  // --- WIDGET PEMBANTU (Helper Widgets) ---
  // Ini adalah fungsi-fungsi kecil untuk membuat kodingan di atas lebih rapi

  // Widget untuk membuat TextField seragam
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label, // Label yang melayang di atas saat diketik
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDD0303)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDD0303)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFFDD0303),
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        isDense: true,
      ),
    );
  }

  // Widget untuk membuat tampilan satu baris item pesanan (Gambar, Nama, Harga, Qty)
  Widget _buildOrderItem({
    required String itemName,
    required String price,
    required int quantity,
  }) {
    return Row(
      children: [
        // Placeholder Kotak Gambar (sesuai wireframe)
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300], // Warna abu-abu sebagai placeholder gambar
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: const Icon(Icons.image, color: Colors.grey), // Ikon sementara
        ),
        const SizedBox(width: 15),

        // Kolom Nama dan Harga (di tengah)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                price,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),

        // Row untuk kontrol kuantitas (- 1 +) (di kanan)
        Row(
          children: [
            // Tombol Kurang (-)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.remove, size: 18),
            ),
            // Angka Kuantitas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                quantity.toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            // Tombol Tambah (+)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}