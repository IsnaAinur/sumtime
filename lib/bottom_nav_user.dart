import 'package:flutter/material.dart';

class BottomNavUser extends StatelessWidget {
  final int currentIndex;
  final List<Map<String, dynamic>>? cart; // Optional cart for showing checkout bar
  final VoidCallback? onCheckoutTap; // Callback when checkout bar is tapped
  final Function(int)? onNavigate; // Custom navigation callback

  const BottomNavUser({
    super.key,
    required this.currentIndex,
    this.cart,
    this.onCheckoutTap,
    this.onNavigate,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Don't navigate if already on the same page

    // Use custom navigation callback if provided
    if (onNavigate != null) {
      onNavigate!(index);
      return;
    }

    // Default navigation using named routes
    String routeName;
    switch (index) {
      case 0:
        routeName = '/beranda';
        break;
      case 1:
        routeName = '/history';
        break;
      case 2:
        routeName = '/profile';
        break;
      default:
        return;
    }

    Navigator.pushReplacementNamed(context, routeName);
  }

  Widget _buildCheckoutBar() {
    if (cart == null || cart!.isEmpty || onCheckoutTap == null) return const SizedBox.shrink();

    final int itemCount = cart!.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GestureDetector(
        onTap: onCheckoutTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFDD0303),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Checkout $itemCount menu',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cart != null) _buildCheckoutBar(),
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          selectedItemColor: const Color(0xFFDD0303),
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
      ],
    );
  }
}
