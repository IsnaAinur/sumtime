import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'login.dart';
import 'services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditMode = false;
  bool _isPasswordVisible = false;
  File? _profileImage;
  Uint8List? _profileImageBytes;
  int _currentIndex = 2; // Bottom nav index, 2 = Profile
  
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

  // Load data dari Supabase & SharedPreferences
  Future<void> _loadProfileData() async {
    try {
      final authService = AuthService();
      final user = authService.getCurrentUser();
      
      // Get Username from Supabase users table
      String username = 'Nama Pengguna';
      final profile = await authService.getUserProfile();
      if (profile != null && profile['username'] != null) {
        username = profile['username'];
      }
      
      // Get Email from Auth User
      String email = user?.email ?? 'user@gmail.com';

      // Load Image Path from SharedPreferences (Persist Local Path)
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_path_${user?.id}');

      // Set State
      if (mounted) {
        setState(() {
          _usernameController.text = username;
          _emailController.text = email;
          _passwordController.text = '••••••••';
          
          if (imagePath != null && File(imagePath).existsSync()) {
            _profileImage = File(imagePath);
          } else if (kIsWeb) {
            final base64Image = prefs.getString('profile_image_base64_${user?.id}');
            if (base64Image != null) {
              _profileImageBytes = base64Decode(base64Image);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  // Simpan data ke Supabase
  Future<void> _saveProfileData() async {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username tidak boleh kosong!'), backgroundColor: _primaryColor),
      );
      return;
    }

    try {
      final authService = AuthService();
      
      // 1. Update Username
      await authService.updateProfile(username: _usernameController.text);
      
      // 2. Update Password if changed
      if (_passwordController.text != '••••••••' && _passwordController.text.isNotEmpty) {
        if (_passwordController.text.length < 6) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password minimal 6 karakter!'), backgroundColor: _primaryColor),
          );
          return;
        }
        await authService.updatePassword(_passwordController.text);
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $e'), backgroundColor: _primaryColor),
      );
    }
  }

  // Logic Pilih & Simpan Gambar (Sama seperti payment.dart)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source, imageQuality: 80);
      
      if (pickedFile != null) {
        if (kIsWeb) {
          // Untuk web, simpan sebagai bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _profileImageBytes = bytes;
            _profileImage = null;
          });
          
          // Simpan bytes ke SharedPreferences (base64)
          final prefs = await SharedPreferences.getInstance();
          // Simpan base64 string
          final authService = AuthService();
          final user = authService.getCurrentUser();
          final base64Image = base64Encode(bytes);
          await prefs.setString('profile_image_base64_${user?.id}', base64Image);
          await prefs.setBool('has_profile_image', true);
        } else {
          // Untuk mobile, simpan sebagai File
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
          
          setState(() {
            _profileImage = savedImage;
            _profileImageBytes = null;
          });
          
          // Save path consistently
          final authService = AuthService();
          final user = authService.getCurrentUser();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image_path_${user?.id}', savedImage.path);
        }
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto profil berhasil diunggah.'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } else {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unggah foto profil dibatalkan.'),
            backgroundColor: Color(0xFFE94E4E),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  // Fungsi logout
  Future<void> _logout() async {
    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: _primaryColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final authService = AuthService();
        await authService.signOut();

        // Clear local SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Navigate kembali ke login
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false, // Hapus semua route sebelumnya
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout gagal: $e')),
          );
        }
      }
    }
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
            // Avatar Section (Sama seperti payment.dart)
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120, 
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _primaryColor, width: 3),
                    ),
                    child: ClipOval(
                      child: _getProfileImageWidget(),
                    ),
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

            const SizedBox(height: 20),

            // Tombol Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: _primaryColor, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _logout,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: _primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            // Navigasi ke halaman beranda
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // Navigasi ke halaman history pesanan
            Navigator.pushNamed(context, '/history-pesanan');
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
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

  // Widget untuk menampilkan gambar profil (Sama seperti payment.dart)
  Widget _getProfileImageWidget() {
    if (kIsWeb && _profileImageBytes != null) {
      return Image.memory(_profileImageBytes!, fit: BoxFit.cover);
    } else if (_profileImage != null) {
      return Image.file(_profileImage!, fit: BoxFit.cover);
    } else {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }
  }

}