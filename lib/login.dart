import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'services/supabase_service.dart';
import 'beranda.dart';
import 'admin/order_page.dart' as admin_order;
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }


  Future<void> _validateLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
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

    try {
      // Login menggunakan Supabase
      final supabaseService = SupabaseService();
      final response = await supabaseService.signIn(email, password);

      if (!mounted) return;

      if (response.user != null) {
        // Cek role user dari database
        final userData = await SupabaseConfig.client
            .from('users')
            .select('role')
            .eq('id', response.user!.id)
            .single();

        final bool isAdmin = userData['role'] == 'admin';
        final String roleMessage = isAdmin ? "Login berhasil sebagai Admin!" : "Login berhasil!";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(roleMessage),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 800),
          ),
        );

        // Navigasi berdasarkan role
        if (isAdmin) {
          // Admin navigasi ke halaman admin order
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const admin_order.OrderPage()),
          );
        } else {
          // User navigasi ke halaman beranda user
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BerandaPage()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = "Terjadi kesalahan saat login";
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = "Email atau password salah!";
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = "Silakan konfirmasi email Anda terlebih dahulu";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = _getColorFromHex('DD0303');
    final Color secondaryColor = _getColorFromHex('B00020'); 
    const Color onPrimaryColor = Colors.white;

    final Color highContrastButtonColor = Colors.amber.shade700;
    const Color onButtonColor = Colors.black;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              secondaryColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.login_rounded,
                    size: 80,
                    color: onPrimaryColor,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "SELAMAT DATANG",
                    style: TextStyle(
                      fontSize: 14,
                      color: onPrimaryColor,
                    ),
                  ),
                  const Text(
                    "Silahkan Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: onPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 50),

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
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.email, color: primaryColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                          prefixIcon: Icon(Icons.lock, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primaryColor,
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
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _validateLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: highContrastButtonColor,
                        elevation: 15,
                      ),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          fontSize: 18,
                          color: onButtonColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Belum punya akun? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        child: const Text(
                          "Daftar disini",
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}