import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'nav._bottom.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class AddItemMainPage extends StatefulWidget {
  const AddItemMainPage({super.key});

  @override
  State<AddItemMainPage> createState() => _AddItemMainPageState();
}

class _AddItemMainPageState extends State<AddItemMainPage> {
  static const Color red = Color(0xFFDD0303);

  int selectedTab = 0; // 0: Add Poster, 1: Add Menu
  bool _isLoading = false;

  // Controllers untuk form Add Menu
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // State variables untuk menyimpan gambar yang dipilih
  Uint8List? _posterImageBytes;
  Uint8List? _menuImageBytes;

  // Dynamic list untuk menyimpan menu yang ditambahkan admin
  List<Map<String, dynamic>> _daftarMenu = [];

  // State untuk mode edit
  bool _isEditMode = false;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadMenuFromSupabase();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih gambar poster dari galeri
  Future<void> _pickPosterImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (pickedFile != null) {
    final bytes = await pickedFile.readAsBytes();

    setState(() {
      _posterImageBytes = bytes;
    });
  }
}

Future<void> _loadMenuFromSupabase() async {
  try {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('menu_items')
        .select('id, name, description, price, image_url')
        .order('created_at', ascending: false);

    setState(() {
      _daftarMenu = response.map<Map<String, dynamic>>((item) {
        return {
          "id": item['id'],
          "nama": item['name'],
          "harga": item['price'].toString(),
          "deskripsi": item['description'],
          "image_url": item['image_url'],
        };
      }).toList();
    });
  } catch (e) {
    debugPrint('ERROR LOAD MENU: $e');
  }
}

  Future<void> _savePoster() async {
  if (_posterImageBytes == null) return;

  setState(() => _isLoading = true);

  try {
    final supabase = Supabase.instance.client;
    final fileName = 'posters/${const Uuid().v4()}.jpg';
    await supabase.storage.from('posters').uploadBinary(
      fileName,
      _posterImageBytes!,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: false,
      ),
    );

    // Ambil PUBLIC URL
    final imageUrl =
        supabase.storage.from('posters').getPublicUrl(fileName);

    // Simpan ke tabel posters
    await supabase.from('posters').insert({
      'title': 'Poster Menu',
      'image_url': imageUrl,
      'is_active': true,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Poster berhasil disimpan')),
    );

    setState(() {
      _posterImageBytes = null;
    });
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menyimpan poster: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  // Fungsi untuk memilih gambar menu dari galeri
  Future<void> _pickMenuImage() async {
  final picked = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (picked == null) return;

  final bytes = await picked.readAsBytes();

  setState(() {
    _menuImageBytes = bytes;
  });
}

  // Fungsi untuk menambahkan menu baru ke daftar
  Future<void> _addMenuItem() async {
  if (_namaController.text.isEmpty ||
      _hargaController.text.isEmpty ||
      _menuImageBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nama, harga, dan gambar wajib diisi')),
    );
    return;
  }

  try {
    final supabase = Supabase.instance.client;

    // 1️⃣ Upload image ke storage
    final fileName = 'menu/${const Uuid().v4()}.jpg';

    await supabase.storage.from('menu').uploadBinary(
      fileName,
      _menuImageBytes!,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
      ),
    );

    // 2️⃣ Ambil public URL
    final imageUrl =
        supabase.storage.from('menu').getPublicUrl(fileName);

    // 3️⃣ Insert ke database
    await supabase.from('menu_items').insert({
      'name': _namaController.text.trim(),
      'description': _deskripsiController.text.trim(),
      'price': int.parse(_hargaController.text),
      'image_url': imageUrl,
      'is_available': true,
    });

    // Load daftar menu
    _menuImageBytes = null;
    await _loadMenuFromSupabase();

    // Clear form
    _namaController.clear();
    _deskripsiController.clear();
    _hargaController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu berhasil disimpan')),
    );
  } catch (e) {
    debugPrint('ERROR SIMPAN MENU: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal simpan menu')),
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
      _deskripsiController.text = item["deskripsi"] ?? "";
      _menuImageBytes = null; 
      _hargaController.text = item["harga"] ?? "";
    });
  }

  // Fungsi untuk menyimpan perubahan edit
  Future<void> _saveEditedMenu() async {
  if (_editingIndex == null) return;

  final supabase = Supabase.instance.client;

  final menu = _daftarMenu[_editingIndex!]; // ✅ FIX
  final menuId = menu['id'];

  String imageUrl = menu['image_url']; // ✅ gambar lama

  try {
    // Jika pilih gambar baru
    if (_menuImageBytes != null) {
      final fileName = 'menu/${const Uuid().v4()}.jpg';

      await supabase.storage.from('menu').uploadBinary(
        fileName,
        _menuImageBytes!,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
        ),
      );

      imageUrl = supabase.storage.from('menu').getPublicUrl(fileName);
    }

    // Update database
    await supabase.from('menu_items').update({
      'name': _namaController.text.trim(),
      'description': _deskripsiController.text.trim(),
      'price': int.parse(_hargaController.text),
      'image_url': imageUrl, // ✅ GAMBAR TIDAK HILANG
    }).eq('id', menuId);

    await _loadMenuFromSupabase();

    if (!mounted) return;

    setState(() {
      _isEditMode = false;
      _editingIndex = null;
      _menuImageBytes = null;
    });

    _namaController.clear();
    _deskripsiController.clear();
    _hargaController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu berhasil diperbarui')),
    );
  } catch (e) {
    debugPrint('ERROR UPDATE MENU: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal memperbarui menu')),
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
    });
  }

Future<void> _deleteMenuFromSupabase(int index) async {
  final supabase = Supabase.instance.client;
  final menu = _daftarMenu[index];
  final menuId = menu['id'];
  final imageUrl = menu['image_url'];

  try {
    // 1️⃣ Hapus gambar dari Storage (jika ada)
    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;
      await supabase.storage.from('menu').remove([fileName]);
    }

    // 2️⃣ Hapus data dari DB
    await supabase.from('menu_items').delete().eq('id', menuId);

    // 3️⃣ Reload menu
    await _loadMenuFromSupabase();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu berhasil dihapus')),
    );
  } catch (e) {
    debugPrint('ERROR DELETE MENU: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal menghapus menu')),
    );
  }
}

void _showDeleteConfirmation(int index) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Menu'),
      content: const Text('Yakin ingin menghapus menu ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(context);
            _deleteMenuFromSupabase(index);
          },
          child: const Text('Hapus'),
        ),
      ],
    ),
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
                  child: _posterImageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          _posterImageBytes!,
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
                child: _posterImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        _posterImageBytes!,
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
            onPressed: _isLoading ? null : _savePoster,
            style: ElevatedButton.styleFrom(
              backgroundColor: red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                : const Text(
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
                    imageUrl: item["image_url"],
                    onEdit: () => _startEditMenu(i),
                    onDelete: () => _showDeleteConfirmation(i),
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
  final String? imageUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MenuCard({
    required this.nama,
    required this.harga,
    this.imageUrl,
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
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
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
