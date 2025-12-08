import 'package:flutter/material.dart';

class HistoryPesananPage extends StatefulWidget {
  const HistoryPesananPage({super.key});

  @override
  State<HistoryPesananPage> createState() => _HistoryPesananPageState();
}

class _HistoryPesananPageState extends State<HistoryPesananPage> {
  static const Color kRed = Color(0xFFDD0303);

  int selectedTab = 0; // 0: Berlangsung, 1: Selesai

  final List<OrderItem> berlangsung = const [
    OrderItem(orderId: 'ORD-1001', priceText: 'Rp. 25.000'),
    OrderItem(orderId: 'ORD-1002', priceText: 'Rp. 110.000'),
    OrderItem(orderId: 'ORD-1003', priceText: 'Rp. 57.500'),
  ];

  final List<OrderItem> selesai = const [
    OrderItem(orderId: 'ORD-0901', priceText: 'Rp. 89.000'),
    OrderItem(orderId: 'ORD-0902', priceText: 'Rp. 40.000'),
  ];

  @override
  Widget build(BuildContext context) {
    final items = selectedTab == 0 ? berlangsung : selesai;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        // supaya title ada di samping tombol back
        centerTitle: false,

        // tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kRed),
          onPressed: () => Navigator.maybePop(context),
        ),

        // title samping tombol
        title: const Text(
          'History Pesanan',
          style: TextStyle(color: kRed, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Tabs(
                red: kRed,
                selectedIndex: selectedTab,
                onChanged: (i) => setState(() => selectedTab = i),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final it = items[index];
                    return _OrderCard(
                      red: kRed,
                      orderId: it.orderId,
                      priceText: it.priceText,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Klik ${it.orderId}')),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final Color red;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _Tabs({
    required this.red,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: red, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Berlangsung',
              red: red,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Container(width: 3, color: red),
          Expanded(
            child: _TabButton(
              label: 'Selesai',
              red: red,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final Color red;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.red,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? red : Colors.white;
    final textColor = selected ? Colors.white : red;

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Color red;
  final String orderId;
  final String priceText;
  final VoidCallback? onTap;

  const _OrderCard({
    required this.red,
    required this.orderId,
    required this.priceText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: red,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                orderId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Rp. $priceText'.replaceFirst('Rp. Rp.', 'Rp. '),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderItem {
  final String orderId;
  final String priceText;
  const OrderItem({required this.orderId, required this.priceText});
}
