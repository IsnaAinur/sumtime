import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'splash.dart';
import 'login.dart';
import 'register.dart';
import 'beranda.dart';
import 'checkout.dart';
import 'profile.dart';
import 'info_menu.dart';
import 'history_pemesanan.dart';
import 'rincianpesanan.dart';
import 'test_supabase_connection.dart';
import 'admin/order_page.dart' as admin_order;
import 'admin/laporan.dart' as admin_laporan;
import 'admin/detail_laporan.dart' as admin_detail_laporan;
import 'admin/pemesanan.dart' as admin_pemesanan;
import 'admin/add_item_main.dart' as admin_add_item;
import 'admin/add_item_poster.dart' as admin_add_poster;
import 'admin/tambah_item_menu.dart' as admin_tambah_menu;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await SupabaseConfig.initialize();

  runApp(const SumTimeApp());
}

class SumTimeApp extends StatelessWidget {
  const SumTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SumTime',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // Halaman awal adalah splash, kemudian akan redirect ke login
      initialRoute: '/',
      routes: {
        // Main routes
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/test-connection': (context) => const TestSupabaseConnection(),

        // User routes
        '/home': (context) => const BerandaPage(),
        '/checkout': (context) => CheckoutPage(cart: const []), // Note: cart should be passed from previous page
        '/profile': (context) => const ProfilePage(),
        '/info-menu': (context) => InfoMenuPage(namaMenu: '', deskripsi: '', harga: 0, fotoAsset: ''), // Placeholder parameters
        '/history-pesanan': (context) => const HistoryPesananPage(),
        '/rincian-pesanan': (context) => RincianPesananPage(orderItems: const [], shippingCost: 0, orderNumber: '', currentStatus: 0), // Placeholder parameters

        // Admin routes
        '/admin/order': (context) => const admin_order.OrderPage(),
        '/admin/laporan': (context) => const admin_laporan.LaporanPage(),
        '/admin/detail-laporan': (context) => const admin_detail_laporan.DetailLaporanPage(),
        '/admin/pemesanan': (context) => admin_pemesanan.PemesananPage(orderItems: const [], shippingCost: 0, orderNumber: '', currentStatus: 0), // Placeholder parameters
        '/admin/add-item': (context) => const admin_add_item.AddItemMainPage(),
        '/admin/add-poster': (context) => const admin_add_poster.AddItemPosterPage(),
        '/admin/tambah-menu': (context) => const admin_tambah_menu.TambahItemMenuPage(),
      },
    );
  }
}