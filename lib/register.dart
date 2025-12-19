import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin/order_page.dart';

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

    if (!email.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gunakan email yang valid!")),
      );
      return;
    }

    // Cek apakah email sudah terdaftar
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    
    if (!mounted) return;
    
    if (savedEmail != null && savedEmail == email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email sudah terdaftar!")),
      );
      return;
    }

    // Simpan data ke SharedPreferences
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('password', password);

    // Tampilkan pesan sukses
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi berhasil!"),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Jika valid, pindah ke halaman sesuai role
    if (mounted) {
      final bool isAdmin = email == 'admin@gmail.com';

      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderPage()),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/beranda');
      }
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