import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'nav._bottom.dart';

class AddItemMainPage extends StatefulWidget {
  const AddItemMainPage({super.key});

  @override
  State<AddItemMainPage> createState() => _AddItemMainPageState();
}

class _AddItemMainPageState extends State<AddItemMainPage> {
  static const Color red = Color(0xFFDD0303);

  int selectedTab = 0; // 0: Add Poster, 1: Add Menu

  // Controllers untuk form Add Menu
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // State variables untuk menyimpan gambar yang dipilih
  File? _posterImage;
  File? _menuImage;

  // Dynamic list untuk menyimpan menu yang ditambahkan admin
  List<Map<String, dynamic>> _daftarMenu = [];

  // State untuk mode edit
  bool _isEditMode = false;
  int? _editingIndex;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih gambar poster dari galeri
  Future<void> _pickPosterImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _posterImage = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poster berhasil dipilih')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih gambar: $e')),
      );
    }
  }

  // Fungsi untuk memilih gambar menu dari galeri
  Future<void> _pickMenuImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _menuImage = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar menu berhasil dipilih')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih gambar: $e')),
      );
    }
  }

  // Fungsi untuk menambahkan menu baru ke daftar
  void _addMenuItem() {
    if (_namaController.text.isNotEmpty && _hargaController.text.isNotEmpty) {
      setState(() {
        _daftarMenu.add({
          "nama": _namaController.text,
          "harga": _hargaController.text,
          "gambar": _menuImage, // Simpan referensi gambar
        });

        // Clear form setelah menambah menu
        _namaController.clear();
        _deskripsiController.clear();
        _hargaController.clear();
        _menuImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu "${_namaController.text}" berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama menu dan harga harus diisi')),
      );
    }
  }

  // Fungsi untuk mulai edit menu
  void _startEditMenu(int index) {
    final item = _daftarMenu[index];
    setState(() {
      _isEditMode = true;
      _editingIndex = index;
      _namaController.text = item["nama"] ?? "";
      _deskripsiController.text = ""; // Deskripsi tidak disimpan sebelumnya
      _hargaController.text = item["harga"] ?? "";
      _menuImage = item["gambar"];
    });
  }

  // Fungsi untuk menyimpan perubahan edit
  void _saveEditedMenu() {
    if (_namaController.text.isNotEmpty && _hargaController.text.isNotEmpty && _editingIndex != null) {
      setState(() {
        _daftarMenu[_editingIndex!] = {
          "nama": _namaController.text,
          "harga": _hargaController.text,
          "gambar": _menuImage,
        };

        // Reset edit mode
        _isEditMode = false;
        _editingIndex = null;

        // Clear form
        _namaController.clear();
        _deskripsiController.clear();
        _hargaController.clear();
        _menuImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama menu dan harga harus diisi')),
      );
    }
  }

  // Fungsi untuk membatalkan edit
  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _editingIndex = null;
      _namaController.clear();
      _deskripsiController.clear();
      _hargaController.clear();
      _menuImage = null;
    });
  }

  // Fungsi untuk menghapus menu dari daftar
  void _deleteMenuItem(int index) {
    setState(() {
      _daftarMenu.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add Item',
                  style: TextStyle(
                    color: red,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Tabs(
                red: red,
                selectedIndex: selectedTab,
                onChanged: (i) => setState(() => selectedTab = i),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: selectedTab == 0 ? _buildPosterTab() : _buildMenuTab(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  Widget _buildPosterTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Judul
        const Text(
          "Upload Poster Menu",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Pilih gambar poster yang menarik untuk menu restoran Anda",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // Area Upload Poster
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _pickPosterImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: _posterImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: kIsWeb
                        ? Image.network(
                            _posterImage!.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.file(
                            _posterImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Colors.black45,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Tap untuk upload poster",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Format: JPG, PNG, Max: 5MB",
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // Preview Poster
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Preview Poster",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _posterImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                _posterImage!.path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.file(
                                _posterImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                      )
                    : const Center(
                        child: Text(
                          "Poster akan muncul di sini",
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tombol Simpan
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implementasi simpan poster
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Poster berhasil disimpan')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Simpan Poster",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Edit Mode Indicator
        if (_isEditMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sedang mengedit menu: ${_daftarMenu[_editingIndex!]["nama"]}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _cancelEdit,
                  child: Icon(Icons.close, color: Colors.blue.shade700, size: 20),
                ),
              ],
            ),
          ),

        // Input: Nama Menu
        _BlackTextField(
          hint: _isEditMode ? "Edit nama menu" : "Add nama menu",
          controller: _namaController,
        ),
        const SizedBox(height: 10),

        // Input: Deskripsi Menu
        _BlackTextField(
          hint: _isEditMode ? "Edit deskripsi menu" : "Add deskripsi menu",
          controller: _deskripsiController,
          maxLines: 2,
        ),
        const SizedBox(height: 10),

        // Upload gambar menu
        Text(
          _isEditMode ? "Edit gambar menu" : "Add gambar menu",
          style: const TextStyle(
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
            child: _menuImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: kIsWeb
                        ? Image.network(
                            _menuImage!.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.file(
                            _menuImage!,
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
          hint: _isEditMode ? "Edit harga menu" : "Add harga menu",
          controller: _hargaController,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 18),

        // Tombol untuk Add/Edit Menu
        Row(
          children: [
            if (_isEditMode) ...[
              // Tombol Cancel Edit
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _cancelEdit,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isEditMode ? _saveEditedMenu : _addMenuItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditMode ? "Simpan Perubahan" : "Tambah Menu",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        const Text(
          "Daftar Menu",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),

        // Grid daftar menu (dinamis - kosong pada awalnya)
        _daftarMenu.isEmpty
            ? Container(
                padding: const EdgeInsets.all(40),
                child: const Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Belum ada menu yang ditambahkan",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tambahkan menu baru menggunakan form di atas",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _daftarMenu.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, i) {
                  final item = _daftarMenu[i];
                  return _MenuCard(
                    nama: item["nama"] ?? "-",
                    harga: item["harga"] ?? "-",
                    gambar: item["gambar"],
                    onEdit: () => _startEditMenu(i),
                    onDelete: () => _deleteMenuItem(i),
                  );
                },
              ),

      ],
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
              label: 'Add Poster',
              red: red,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Container(width: 3, color: red),
          Expanded(
            child: _TabButton(
              label: 'Add Menu',
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
                fontSize: 16,
              ),
            ),
          ),
        ),
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

class _MenuCard extends StatelessWidget {
  final String nama;
  final String harga;
  final File? gambar;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MenuCard({
    required this.nama,
    required this.harga,
    this.gambar,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Card dengan GestureDetector untuk Edit
        GestureDetector(
          onTap: onEdit,
          child: Container(
            // === STYLE KOTAK LUAR (CARD) ===
            decoration: BoxDecoration(
              color: Colors.white, // background-color: white
              borderRadius: BorderRadius.circular(12), // border-radius: 12px
              border: Border.all(color: Colors.grey.shade300), // border: 1px solid #E0E0E0
              boxShadow: [ // box-shadow: 0px 2px 4px rgba(0,0,0,0.1)
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === BAGIAN GAMBAR ===
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      // Membuat sudut atas melengkung
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: gambar != null
                          ? (kIsWeb
                              ? Image.network(
                                  gambar!.path,
                                  fit: BoxFit.cover, // object-fit: cover
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : Image.file(
                                  gambar!,
                                  fit: BoxFit.cover, // object-fit: cover
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    );
                                  },
                                ))
                          : const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),

                // === BAGIAN TEKS ===
                Padding(
                  padding: const EdgeInsets.all(8.0), // padding: 8px
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Style Nama Menu
                      Text(
                        nama,
                        style: const TextStyle( // === CSS UNTUK FONT ===
                          fontSize: 14, // font-size: 14px
                          fontWeight: FontWeight.w600, // font-weight: 600
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // text-overflow: ellipsis
                      ),
                      const SizedBox(height: 4),

                      // Style Harga
                      Text(
                        harga,
                        style: TextStyle(
                          fontSize: 12, // font-size: 12px
                          color: Colors.grey.shade700, // color: #616161
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tombol Delete di pojok kanan atas
        if (onDelete != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

        // Edit indicator
        if (onEdit != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Tap to edit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
