import 'package:flutter/material.dart';
import 'order_page.dart';
import 'add_item_main.dart';
import 'laporan.dart';

class AdminBottomNav extends StatefulWidget {
  final int currentIndex;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  static const Color redColor = Color(0xFFDD0303);

  void _onItemTapped(int index, BuildContext context) {
    if (index == widget.currentIndex) return; // Sudah di halaman yang sama

    switch (index) {
      case 0: // Orderan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderPage()),
        );
        break;
      case 1: // Add Item
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AddItemMainPage()),
        );
        break;
      case 2: // Laporan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LaporanPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (index) => _onItemTapped(index, context),
        backgroundColor: Colors.white,
        selectedItemColor: redColor,
        unselectedItemColor: redColor.withAlpha((0.6 * 255).round()),
        type: BottomNavigationBarType.fixed,
        elevation: 0.0, // Set to 0 karena kita menggunakan Container shadow
        showUnselectedLabels: true, // Memastikan label selalu terlihat
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orderan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add Item',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}
