import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'login.dart';
import 'beranda.dart';
import 'admin/order_page.dart' as admin_order;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  // Fungsi untuk menentukan role berdasarkan email
  bool _isAdmin(String email) {
    // Admin jika email mengandung 'admin' atau email admin khusus
    return email.toLowerCase().contains('admin') ||
           email.toLowerCase() == 'admin@sumtime.com' ||
           email.toLowerCase() == 'administrator@gmail.com';
  }

  Future<void> _validateRegister() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tolong lengkapi semua kolom")),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gunakan email yang valid!")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 6 karakter!")),
      );
      return;
    }

    try {
      // Register menggunakan Supabase
      final supabaseService = SupabaseService();
      final response = await supabaseService.signUp(email, password, username);

      if (!mounted) return;

      if (response.user != null) {
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Anda dapat login sekarang."),
            backgroundColor: Colors.green,
          ),
        );

        // Tunggu sebentar untuk user melihat pesan sukses
        await Future.delayed(const Duration(seconds: 2));

        // Navigate kembali ke login page
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = "Terjadi kesalahan saat registrasi";

      final errorString = e.toString().toLowerCase();
      if (errorString.contains('user already registered') ||
          errorString.contains('already been registered')) {
        errorMessage = "Email sudah terdaftar! Silakan gunakan email lain.";
      } else if (errorString.contains('password') ||
                 errorString.contains('weak')) {
        errorMessage = "Password terlalu lemah. Gunakan kombinasi huruf dan angka.";
      } else if (errorString.contains('invalid email')) {
        errorMessage = "Format email tidak valid.";
      } else if (errorString.contains('network') ||
                 errorString.contains('connection')) {
        errorMessage = "Masalah koneksi internet. Periksa koneksi Anda.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFDD0303);
    const Color darkRed = Color(0xFFB00020);

    return Scaffold(
      backgroundColor: primaryRed, // Background color untuk menghindari putih
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryRed,
              darkRed,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Icon pendaftaran
                  const Center(
                    child: Icon(
                      Icons.app_registration_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Judul
                  const Center(
                    child: Text(
                      "Buat Akun Baru",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Input Username
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.person, color: primaryRed),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Email
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.email, color: primaryRed),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Password
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.lock, color: primaryRed),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primaryRed,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tombol Daftar
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _validateRegister,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.amber.shade700,
                        elevation: 15,
                      ),
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Link ke Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sudah punya akun? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Masuk disini",
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Padding bottom untuk menghindari white space
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}