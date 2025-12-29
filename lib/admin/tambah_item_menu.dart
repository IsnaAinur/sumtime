import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nav._bottom.dart';
import 'dart:typed_data';

class TambahItemMenuPage extends StatefulWidget {
  const TambahItemMenuPage({super.key});

  @override
  State<TambahItemMenuPage> createState() => _TambahItemMenuPageState();
}

class _TambahItemMenuPageState extends State<TambahItemMenuPage> {
  static const Color red = Color(0xFFDD0303);
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  Uint8List? _menuImageBytes;

  Future<void> _submitMenu() async {
  if (_namaController.text.isEmpty ||
      _hargaController.text.isEmpty ||
      _menuImageBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nama, harga & gambar wajib diisi')),
    );
    return;
  }

  try {
    final supabase = Supabase.instance.client;
    final fileName = 'menu/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage.from('menu').uploadBinary(
      fileName,
      _menuImageBytes!,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
      ),
    );

    final imageUrl =
        supabase.storage.from('menu').getPublicUrl(fileName);

    await supabase.from('menu_items').insert({
      'name': _namaController.text,
      'description': _deskripsiController.text,
      'price': int.parse(_hargaController.text),
      'image_url': imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu berhasil ditambahkan')),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal simpan menu: $e')),
    );
  }
}

Future<void> _pickMenuImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (picked == null) return;

  final bytes = await picked.readAsBytes();

  setState(() {
    _menuImageBytes = bytes;
  });
}

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: red,
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          "Tambah Item",
          style: TextStyle(color: red, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tombol Add Poster & Add Menu
              Row(
                children: [
                  Expanded(
                    child: _RedButton(
                      text: "Add Poster",
                      onTap: () {
                        // TODO: pick image poster
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RedButton(
                      text: "Add Menu",
                      onTap: _submitMenu,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Input: Nama Menu
              _BlackTextField(
                hint: "Add nama menu",
                controller: _namaController,
              ),
              const SizedBox(height: 10),

              // Input: Deskripsi Menu
              _BlackTextField(
                hint: "Add deskripsi menu",
                controller: _deskripsiController,
                maxLines: 2,
              ),
              const SizedBox(height: 10),

              // Upload gambar menu (placeholder)
              const Text(
                "Add gambar menu",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickMenuImage,
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12, width: 1),
                  ),
                  child: _menuImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(
                            _menuImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: Colors.black45,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // Input: Harga Menu
              _BlackTextField(
                hint: "Add harga menu",
                controller: _hargaController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 18),

              const Text(
                "Daftar Menu",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}

class _RedButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  static const Color red = Color(0xFFDD0303);

  const _RedButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _BlackTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  const _BlackTextField({
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}

class _MenuCardRed extends StatelessWidget {
  final String nama;
  final String harga;
  final Color red;

  const _MenuCardRed({
    required this.nama,
    required this.harga,
    required this.red,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: red,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Placeholder gambar kecil (putih biar kontras)
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.fastfood_outlined, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nama,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            harga,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}