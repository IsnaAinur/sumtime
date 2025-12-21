import 'package:flutter/material.dart';

class InfoMenuPage extends StatefulWidget {
  final String namaMenu;
  final String deskripsi;
  final int harga;
  final String fotoAsset; // bisa berupa asset path atau URL

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

  // Helper function untuk format harga dengan pemisah ribuan
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ==================== APP BAR ======================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFDD0303),
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Menu",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDD0303),
          ),
        ),
      ),

      // ==================== BODY ======================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO MENU
            Center(
              child: Container(
                height: 400,
                width: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFFDD0303),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.fotoAsset.startsWith('http')
                      ? Image.network(
                          widget.fotoAsset,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          widget.fotoAsset,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // NAMA MENU
            Text(
              widget.namaMenu,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // DESKRIPSI
            Text(widget.deskripsi, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 30),

            // HARGA + COUNTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rp ${_formatPrice(widget.harga)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Row(
                  children: [
                    // MIN
                    GestureDetector(
                      onTap: () {
                        if (jumlah > 1) {
                          setState(() {
                            jumlah--;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Icon(Icons.remove, size: 18),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // ANGKA
                    Text(
                      jumlah.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // PLUS
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          jumlah++;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Icon(Icons.add, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      // ==================== BOTTOM BAR ======================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        height: 90,
        decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: Colors.black12)),
          color: Colors.grey.shade100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // TOTAL HARGA
            Text(
              "Rp ${_formatPrice(widget.harga * jumlah)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // BUTTON CHECKOUT
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDD0303),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Format harga dengan format ribuan
                String formattedPrice = 'Rp ${_formatPrice(widget.harga)}';
                
                // Kembalikan data ke beranda dengan jumlah yang dipilih
                Navigator.pop(context, {
                  'name': widget.namaMenu,
                  'price': formattedPrice,
                  'harga': widget.harga,
                  'image': widget.fotoAsset,
                  'deskripsi': widget.deskripsi,
                  'jumlah': jumlah,
                });
              },
              child: const Text(
                "CHECKOUT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}