import 'package:flutter/material.dart';
import 'profile.dart';
import 'info_menu.dart';
import 'checkout.dart';
import 'history_pesanan.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final String _posterUrl = 'https://media.istockphoto.com/id/96655791/id/foto/dim-sum.jpg?s=2048x2048&w=is&k=20&c=5C9ssVnd-_pcyOz9z2uCu3P3KbqbnSqov5juSDbjN44='; // Isi dengan URL poster kamu
  bool _isSearching = false;
  String _selectedCategory = 'Semua'; // 'Semua', 'Dimsum', 'Minuman'
  final List<Map<String, dynamic>> _cart = []; // Keranjang pesanan

  // Sample data for products
  final List<Map<String, dynamic>> _allProducts = [
    {
      'name': 'Dimsum Ayam',
      'price': 'Rp 25.000',
      'harga': 25000,
      'image': 'https://media.istockphoto.com/id/2194538076/id/foto/siomai-kukus-lezat-dalam-kukusan-kayu.jpg?s=2048x2048&w=is&k=20&c=SrJjmcH_9uqDU4KRJxdiavA-_m2wZOGzacZAwkdZ968=',
      'deskripsi': 'Dimsum ayam yang lezat dengan isian daging ayam pilihan, dibungkus dengan kulit yang tipis dan lembut. Dimasak dengan teknik steaming yang sempurna untuk menghasilkan tekstur yang kenyal dan rasa yang gurih.',
    },
    {
      'name': 'Dimsum Udang',
      'price': 'Rp 28.000',
      'harga': 28000,
      'image': 'https://media.istockphoto.com/id/1498163044/id/foto/siu-mai-siomai.jpg?s=2048x2048&w=is&k=20&c=wxatLTu9JGcom6T40qIykCMzXPYOMw_xIM60l-okWZM=',
      'deskripsi': 'Dimsum udang premium dengan isian udang segar yang melimpah. Dibuat dengan resep tradisional yang menghasilkan cita rasa yang autentik dan nikmat.',
    },
    {
      'name': 'Es Jeruk',
      'price': 'Rp 15.000',
      'harga': 15000,
      'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=800&auto=format&fit=crop',
      'deskripsi': 'Es jeruk segar yang menyegarkan, dibuat dari jeruk peras asli tanpa pengawet. Sempurna untuk menemani hidangan dimsum Anda.',
    },
    {
      'name': 'Es Teh',
      'price': 'Rp 12.000',
      'harga': 12000,
      'image': 'https://cdn.pixabay.com/photo/2025/05/26/18/24/ai-generated-9623931_1280.jpg',
      'deskripsi': 'Es teh manis yang segar, dibuat dari teh pilihan dengan takaran gula yang pas. Minuman klasik yang selalu cocok untuk segala suasana.',
    },
  ];

  // List produk yang akan ditampilkan (hasil filter)
  late List<Map<String, dynamic>> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filteredProducts = List<Map<String, dynamic>>.from(_allProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo and Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Logo
                  Row(
                    children: [
                      // Logo Image dengan ukuran disesuaikan dengan font
                      Image.asset(
                        'assets/logoatas.png',
                        height: 28, // Ukuran disesuaikan dengan fontSize 20
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback jika logo tidak ditemukan
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDD0303),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Cari menu',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFFDD0303),
                        ),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Color(0xFFDD0303),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isSearching) ...[
                        // Poster Section
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFDD0303),
                              width: 2,
                            ),
                          ),
                          child: _posterUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    _posterUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'Poster',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFDD0303),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Kategori Section
                        const Text(
                          'Kategori',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCategoryButton(
                                'Dimsum',
                                Icons.restaurant,
                                isSelected: _selectedCategory == 'Dimsum',
                                onTap: () => _onCategorySelected('Dimsum'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCategoryButton(
                                'Minuman',
                                Icons.local_drink,
                                isSelected: _selectedCategory == 'Minuman',
                                onTap: () => _onCategorySelected('Minuman'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Product Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(_filteredProducts[index]);
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _buildCheckoutBar(),
            ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1) {
                // Navigasi ke halaman riwayat pesanan
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPesananPage()),
                );
              } else if (index == 2) {
                // Navigasi ke halaman profil
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
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
      ),
    );
  }

  Widget _buildCategoryButton(
    String label,
    IconData icon, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFDD0303) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFFDD0303),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFDD0303)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _navigateToInfoMenu(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
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
          // Product Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
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
                child: product['image'] != null && product['image'].toString().startsWith('http')
                    ? Image.network(
                        product['image'],
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
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product['name'] ?? 'Nama menu',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Price
                Text(
                  product['price'] ?? 'Harga',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                // Add Button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      _addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product['name']} ditambahkan ke keranjang'),
                          duration: const Duration(milliseconds: 500),
                          backgroundColor: const Color(0xFFDD0303),
                        ),
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDD0303),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _navigateToInfoMenu(Map<String, dynamic> product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoMenuPage(
          namaMenu: product['name'] ?? 'Menu',
          deskripsi: product['deskripsi'] ?? 'Deskripsi menu tidak tersedia.',
          harga: product['harga'] ?? 0,
          fotoAsset: product['image'] ?? '',
        ),
      ),
    );

    // Jika ada result dari checkout, tambahkan ke cart sesuai jumlahnya
    if (result != null && result is Map<String, dynamic>) {
      final int jumlah = result['jumlah'] ?? 1;
      final Map<String, dynamic> itemToAdd = {
        'name': result['name'],
        'price': result['price'],
        'harga': result['harga'],
        'image': result['image'],
        'deskripsi': result['deskripsi'],
      };

      // Tambahkan item ke cart sebanyak jumlah yang dipilih
      setState(() {
        for (int i = 0; i < jumlah; i++) {
          _cart.add(Map<String, dynamic>.from(itemToAdd));
        }
      });

      // Tampilkan snackbar konfirmasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${jumlah}x ${result['name']} ditambahkan ke keranjang'),
            duration: const Duration(milliseconds: 800),
            backgroundColor: const Color(0xFFDD0303),
          ),
        );
      }
    }
  }

  Widget _buildCheckoutBar() {
    final int itemCount = _cart.length;

    return GestureDetector(
      onTap: _showCheckout,
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
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _applyFilters();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    // Mulai dari semua produk
    Iterable<Map<String, dynamic>> products = _allProducts;

    // Filter berdasarkan kategori
    if (_selectedCategory == 'Dimsum') {
      products = products.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        return name.contains('dimsum');
      });
    } else if (_selectedCategory == 'Minuman') {
      products = products.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        // Di data sekarang, minuman adalah yang diawali "Es"
        return name.startsWith('es ');
      });
    }

    // Filter berdasarkan pencarian
    if (query.isNotEmpty) {
      products = products.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      });
    }

    _filteredProducts = products.toList();
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cart.add(product);
    });
  }

  void _showCheckout() {
    if (_cart.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutPage(cart: _cart),
      ),
    );
  }
}
