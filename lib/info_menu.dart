import 'package:flutter/material.dart';

class InfoMenuPage extends StatefulWidget {
  final String namaMenu;
  final String deskripsi;
  final int harga;
  final String fotoAsset; // misalnya: "assets/images/nasigoreng.jpg"

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
      backgroundColor: Colors.white,

      // ==================== APP BAR ======================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Menu",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(widget.fotoAsset),
                    fit: BoxFit.cover,
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
                  "Rp ${widget.harga}",
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
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ICON HOME
            const Icon(Icons.home, size: 30),

            // TOTAL HARGA
            Text(
              "Rp ${widget.harga * jumlah}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // BUTTON CHECKOUT
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // aksi checkout
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
