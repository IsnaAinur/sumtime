import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'info_menu.dart';
import 'checkout.dart';

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

  // Products loaded from database
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  // List produk yang akan ditampilkan (hasil filter)
  late List<Map<String, dynamic>> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final supabaseService = SupabaseService();

      // Load products dan categories secara paralel
      final results = await Future.wait([
        supabaseService.getProducts(),
        supabaseService.getCategories(),
      ]);

      setState(() {
        _allProducts = results[0] as List<Map<String, dynamic>>;
        _categories = results[1] as List<Map<String, dynamic>>;
        _filteredProducts = List<Map<String, dynamic>>.from(_allProducts);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
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
                      if (_isLoading) ...[
                        // Loading indicator
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFFDD0303),
                            ),
                          ),
                        ),
                      ] else if (!_isSearching) ...[
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
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            // Semua category button
                            Expanded(
                              child: _buildCategoryButton(
                                'Semua',
                                Icons.all_inclusive,
                                isSelected: _selectedCategory == 'Semua',
                                onTap: () => _onCategorySelected('Semua'),
                              ),
                            ),
                            // Dynamic category buttons dari database
                            ..._categories.map((category) {
                              final categoryName = category['name'] as String;
                              IconData iconData;
                              switch (categoryName.toLowerCase()) {
                                case 'dimsum':
                                  iconData = Icons.restaurant;
                                  break;
                                case 'minuman':
                                  iconData = Icons.local_drink;
                                  break;
                                default:
                                  iconData = Icons.category;
                              }

                              return Expanded(
                                child: _buildCategoryButton(
                                  categoryName,
                                  iconData,
                                  isSelected: _selectedCategory == categoryName,
                                  onTap: () => _onCategorySelected(categoryName),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Product Grid
                      if (_isLoading) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFFDD0303),
                            ),
                          ),
                        ),
                      ] else ...[
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
                      ],
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
                Navigator.pushNamed(context, '/history-pesanan');
              } else if (index == 2) {
                // Navigasi ke halaman profil
                Navigator.pushNamed(context, '/profile');
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
                child: product['image_url'] != null && product['image_url'].toString().startsWith('http')
                    ? Image.network(
                        product['image_url'],
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
                  _formatPrice(product['price'] ?? 0),
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
          fotoAsset: product['image_url'] ?? '',
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
        'image_url': result['image_url'],
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
    if (_selectedCategory != 'Semua') {
      final selectedCategoryData = _categories.firstWhere(
        (cat) => cat['name'] == _selectedCategory,
        orElse: () => <String, dynamic>{},
      );

      if (selectedCategoryData.isNotEmpty) {
        final categoryId = selectedCategoryData['id'];
        products = products.where((product) {
          return product['category_id'] == categoryId;
        });
      }
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

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}