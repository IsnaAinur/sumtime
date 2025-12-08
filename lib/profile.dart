import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditMode = false;
  bool _isPasswordVisible = false;
  File? _profileImage;
  
  // Controller
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imagePicker = ImagePicker();

  // Warna Konstan
  final Color _primaryColor = const Color(0xFFDD0303);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load data lebih singkat
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? 'Nama Pengguna';
      _emailController.text = prefs.getString('email') ?? 'user@gmail.com';
      _passwordController.text = prefs.getString('password') ?? '••••••••';
      
      final path = prefs.getString('image_path');
      if (path != null && File(path).existsSync()) {
        _profileImage = File(path);
      }
    });
  }

  // Simpan data text
  Future<void> _saveProfileData() async {
    if (_usernameController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data tidak valid!'), backgroundColor: _primaryColor),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    // Simpan password asli jika diubah, jangan simpan dots
    if (_passwordController.text != '••••••••') {
      await prefs.setString('password', _passwordController.text);
    }

    setState(() {
      _isEditMode = false;
      if (_passwordController.text.isNotEmpty) _passwordController.text = '••••••••';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan'), backgroundColor: Colors.green),
      );
    }
  }

  // Logic Pilih & Simpan Gambar (Lebih Ringkas & Aman)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source, imageQuality: 80);
      if (pickedFile == null) return;

      // Ambil direktori permanen aplikasi
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      // Simpan Path ke Prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_path', savedImage.path);

      setState(() => _profileImage = savedImage);
      
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourceDialog() {
    if (!_isEditMode) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ganti Foto Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo, color: _primaryColor),
              title: const Text('Galeri'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: _primaryColor),
              title: const Text('Kamera'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Section
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _primaryColor, width: 3),
                      image: _profileImage != null
                          ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _profileImage == null 
                      ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                      : null,
                  ),
                  if (_isEditMode)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Form Fields
            _buildTextField('Username', _usernameController, Icons.person),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, Icons.email, isEmail: true),
            const SizedBox(height: 16),
            _buildTextField('Password', _passwordController, Icons.lock, isPassword: true),

            const SizedBox(height: 30),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditMode ? Colors.grey : _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditMode = !_isEditMode;
                        if (!_isEditMode) _loadProfileData(); // Reset jika batal
                        if (_isEditMode && _passwordController.text == '••••••••') {
                          _passwordController.clear();
                        }
                      });
                    },
                    child: Text(_isEditMode ? 'Batal' : 'Edit Profil', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                if (_isEditMode) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveProfileData,
                      child: const Text('Simpan', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, 
      {bool isPassword = false, bool isEmail = false}) {
    return TextField(
      controller: controller,
      enabled: _isEditMode,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primaryColor),
        filled: true,
        fillColor: _isEditMode ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: isPassword && _isEditMode
            ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: _primaryColor),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
      ),
    );
  }
}