import 'package:flutter/material.dart';

class InfoMenuPage extends StatefulWidget {
  final String namaMenu;
  final String deskripsi;
  final int harga;
  final String fotoAsset;

  const InfoMenuPage({
    super.key,
    required this.namaMenu,
    required this.deskripsi,
    required this.harga,
    required this.fotoAsset,
  });

  @override
  State<InfoMenuPage> createState() => _InfoMenuPageState();
}

class _InfoMenuPageState extends State<InfoMenuPage> {
  int jumlah = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaMenu),
        backgroundColor: const Color(0xFFDD0303),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar menu
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: widget.fotoAsset.startsWith('http')
                    ? DecorationImage(
                        image: NetworkImage(widget.fotoAsset),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: widget.fotoAsset.startsWith('http') ? null : Colors.grey.shade300,
              ),
              child: widget.fotoAsset.startsWith('http')
                  ? null
                  : const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Nama menu
            Text(
              widget.namaMenu,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Harga
            Text(
              'Rp ${widget.harga}',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFFDD0303),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.deskripsi,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Counter jumlah
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (jumlah > 1) {
                      setState(() => jumlah--);
                    }
                  },
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFDD0303),
                    foregroundColor: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDD0303)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    jumlah.toString(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => jumlah++);
                  },
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFDD0303),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tombol pesan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Kembali dengan data jumlah pesanan
                  Navigator.pop(context, {
                    'name': widget.namaMenu,
                    'harga': widget.harga,
                    'image': widget.fotoAsset,
                    'deskripsi': widget.deskripsi,
                    'jumlah': jumlah,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDD0303),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tambah ke Keranjang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
