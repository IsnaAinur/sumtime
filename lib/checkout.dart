import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'payment.dart';

class CheckoutPage extends StatefulWidget {

  final List<Map<String, dynamic>> cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // State untuk menyimpan item yang dikelompokkan dan jumlahnya
  List<Map<String, dynamic>> _groupedItems = [];

  // Controller untuk mengambil teks dari input field (opsional untuk saat ini)
  final TextEditingController _outletController =
      TextEditingController(text: 'Jl. Bhayangkara No.55, Tipes');
  final TextEditingController _deliveryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _groupCartItems();
  }

  void _groupCartItems() {
    final Map<String, Map<String, dynamic>> tempGrouped = {};
    for (final product in widget.cart) {
      final String name = (product['name'] ?? 'Menu').toString();
      if (!tempGrouped.containsKey(name)) {
        tempGrouped[name] = {
          'product': product,
          'qty': 1,
        };
      } else {
        tempGrouped[name]!['qty'] = (tempGrouped[name]!['qty'] as int) + 1;
      }
    }
    _groupedItems = tempGrouped.values.toList();
  }

  void _incrementQty(int index) {
    setState(() {
      _groupedItems[index]['qty'] = (_groupedItems[index]['qty'] as int) + 1;
    });
  }

  void _decrementQty(int index) {
    setState(() {
      int currentQty = _groupedItems[index]['qty'] as int;
      if (currentQty > 0) {
        if (currentQty == 1) {
          _groupedItems.removeAt(index);
        } else {
          _groupedItems[index]['qty'] = currentQty - 1;
        }
      }
    });
  }

  List<Map<String, dynamic>> _getFlatCart() {
    List<Map<String, dynamic>> flat = [];
    for (var item in _groupedItems) {
      int qty = item['qty'] as int;
      var product = item['product'];
      for (int i = 0; i < qty; i++) {
        flat.add(product);
      }
    }
    return flat;
  }

  Future<void> _fillCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan lokasi tidak aktif. Aktifkan GPS terlebih dahulu.'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin lokasi ditolak. Tidak bisa mengambil lokasi.'),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak permanen. Ubah izin di pengaturan aplikasi.',
            ),
          ),
        );
        return;
      }

      // Izin sudah diberikan, ambil posisi sekarang.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Konversi koordinat menjadi alamat yang lebih mudah dibaca user.
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String formatted = '';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
       
        final street = place.street;
        final subLocality = place.subLocality;
        final locality = place.locality;
        final administrativeArea = place.administrativeArea;

        final parts = <String>[
          if (street != null && street.isNotEmpty) street,
          if (subLocality != null && subLocality.isNotEmpty) subLocality,
          if (locality != null && locality.isNotEmpty) locality,
          if (administrativeArea != null && administrativeArea.isNotEmpty)
            administrativeArea,
        ];

        formatted = parts.join(', ');
      }

      // Jika reverse geocoding gagal atau alamat kosong, fallback ke koordinat.
      if (formatted.isEmpty) {
        formatted =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      }

      setState(() {
        _deliveryController.text = formatted;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil lokasi: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup agar tidak memory leak
    _outletController.dispose();
    _deliveryController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  int _calculateSubtotal() {
    int total = 0;
    for (final item in _groupedItems) {
      final product = item['product'];
      final int qty = item['qty'] as int;
      final int harga = (product['harga'] ?? 0) as int;
      total += harga * qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Item sudah dikelompokkan di _groupedItems pada initState

    // Hitung total
    final int subtotal = _calculateSubtotal();
    const int deliveryFee = 10000;
    final int total = subtotal + deliveryFee;

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

            // Input Field Lokasi Pengiriman (bisa ketik atau pakai lokasi saat ini)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Lokasi Pengiriman',
                    controller: _deliveryController,
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol untuk ambil lokasi saat ini
                SizedBox(
                  height: 56,
                  child: IconButton(
                    onPressed: _fillCurrentLocation,
                    icon: const Icon(Icons.my_location, color: Color(0xFFDD0303)),
                    tooltip: 'Gunakan lokasi saya',
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
              child: _groupedItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada pesanan',
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < _groupedItems.length; i++) ...[
                          Builder(
                            builder: (context) {
                              final item = _groupedItems[i];
                              final product = item['product']
                                  as Map<String, dynamic>;
                              final int qty = item['qty'] as int;
                              final String name = (product['name'] ?? 'Menu').toString();
                              final String price =
                                  (product['price'] ?? '-').toString();

                              final String? image = product['image'];

                              return _buildOrderItem(
                                itemName: name,
                                price: price,
                                quantity: qty,
                                imageUrl: image,
                                onIncrement: () => _incrementQty(i),
                                onDecrement: () => _decrementQty(i),
                              );
                            },
                          ),
                          if (i != _groupedItems.length - 1)
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
              children: [
                const Text(
                  'Biaya pengiriman',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Rp ${_formatPrice(deliveryFee)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDD0303),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDD0303),
                  ),
                ),
                Text(
                  'Rp ${_formatPrice(total)}',
                  style: const TextStyle(
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
                  // Validate inputs
                  if (_deliveryController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap isi lokasi pengiriman.'),
                        backgroundColor: Color(0xFFDD0303),
                      ),
                    );
                    return;
                  }
                  if (_phoneController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap isi nomor HP.'),
                        backgroundColor: Color(0xFFDD0303),
                      ),
                    );
                    return;
                  }

                  // Navigate ke halaman pembayaran dengan data cart dan delivery info
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        cart: _getFlatCart(),
                        shippingCost: deliveryFee,
                        deliveryAddress: _deliveryController.text.trim(),
                        phone: _phoneController.text.trim(),
                        notes: _notesController.text.trim(),
                      ),
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
    String? imageUrl,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      children: [
        // Placeholder Kotak Gambar (sesuai wireframe)
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300], // Warna abu-abu sebagai placeholder
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.grey);
                    },
                  ),
                )
              : const Icon(Icons.image, color: Colors.grey),
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

        // Tampilan Kuantitas dengan Tombol + dan -
        Row(
          children: [
            InkWell(
              onTap: onDecrement,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.remove_circle_outline,
                  color: Color(0xFFDD0303),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onIncrement,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFFDD0303),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}