import 'package:flutter/material.dart';
import 'order_page.dart';
import 'add_item_main.dart';

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
        // TODO: Implementasi halaman laporan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Laporan akan segera hadir')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: (index) => _onItemTapped(index, context),
      backgroundColor: Colors.white,
      selectedItemColor: redColor,
      unselectedItemColor: redColor.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
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
    );
  }
}
