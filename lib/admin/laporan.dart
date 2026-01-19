import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nav._bottom.dart';
import 'detail_laporan.dart';


class ReportItem {
  final int no;
  final DateTime date;
  final String orderId; // Display ID (ORD-XXX)
  final String uuid;    // Database UUID
  final String totalHarga;

  ReportItem(this.no, this.date, this.orderId, this.uuid, this.totalHarga);

  String get formattedDate => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String? _selectedBulan = 'Bulan';
  String? _selectedTahun = 'Tahun';
  bool _isLoading = true;

  // All report data fetched from database
  List<ReportItem> _allReportData = [];

  // Filtered data (will be updated based on selected filters)
  List<ReportItem> _filteredReportData = [];

  int get _totalPenjualan => _filteredReportData.length;
  String get _totalPendapatan => _calculateTotalPendapatan();
  String get _rataRataPendapatan => _calculateRataRataPendapatan();

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .order('order_date', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      
      List<ReportItem> items = [];
      for (int i = 0; i < data.length; i++) {
        final order = data[i];
        final orderDate = DateTime.parse(order['order_date']);
        final totalAmount = order['total_amount'] as int;
        
        items.add(ReportItem(
          i + 1,
          orderDate,
          order['order_id'] ?? 'UNKNOWN',
          order['id'], // UUID
          'Rp ${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
        ));
      }

      setState(() {
        _allReportData = items;
        _filteredReportData = List.from(_allReportData);
        _isLoading = false;
      });
      
      // Apply existing filters if any
      _applyFilters();
      
    } catch (e) {
      debugPrint('Error fetching report data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data laporan: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredReportData = _allReportData.where((item) {
        bool monthMatch = true;
        bool yearMatch = true;

        // Filter by month
        if (_selectedBulan != null && _selectedBulan != 'Bulan') {
          final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                         'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
          final selectedMonthIndex = months.indexOf(_selectedBulan!) + 1;
          monthMatch = item.date.month == selectedMonthIndex;
        }

        // Filter by year
        if (_selectedTahun != null && _selectedTahun != 'Tahun') {
          yearMatch = item.date.year.toString() == _selectedTahun;
        }

        return monthMatch && yearMatch;
      }).toList();

      // Update item numbers after filtering
      for (int i = 0; i < _filteredReportData.length; i++) {
        // We re-create items to update the 'No.' field dynamically based on filtered view
        _filteredReportData[i] = ReportItem(
          i + 1,
          _filteredReportData[i].date,
          _filteredReportData[i].orderId,
          _filteredReportData[i].uuid,
          _filteredReportData[i].totalHarga,
        );
      }
    });
  }



  String _calculateTotalPendapatan() {
    int total = 0;
    for (var item in _filteredReportData) {
      // Extract number from string like 'Rp 50.000'
      final amountString = item.totalHarga.replaceAll('Rp ', '').replaceAll('.', '');
      final amount = int.tryParse(amountString) ?? 0;
      total += amount;
    }
    return 'Rp ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _calculateRataRataPendapatan() {
    if (_filteredReportData.isEmpty) return 'Rp 0';
    final totalAmount = _calculateTotalPendapatan();
    final totalNumeric = int.parse(totalAmount.replaceAll('Rp ', '').replaceAll('.', ''));
    final average = totalNumeric ~/ _filteredReportData.length;
    return 'Rp ${average.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Modern Summary Card
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
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

  // Modern Filter Dropdown
  Widget _buildModernDropdown(String label, String? selectedValue, List<String> items, Function(String?) onChanged) {
    List<String> displayItems = [label, ...items];
    String? displayValue = selectedValue != null && items.contains(selectedValue) ? selectedValue : label;

    return Container(
      height: 48,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: displayValue,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          iconSize: 24,
          style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          items: displayItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  color: value == label ? Colors.grey[500] : Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != label) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  // Modern Report Table
  Widget _buildModernReportTable(List<ReportItem> data) {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(color: Color(0xFFDD0303)),
      ));
    }
    
    if (data.isEmpty) {
       return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada data laporan',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDD0303).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Text(
                'Detail Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDD0303),
                ),
              ),
            ),

            // Table Content
            Container(
              padding: const EdgeInsets.all(12),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.3),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(2.8),
                  3: FlexColumnWidth(2.5),
                  4: FlexColumnWidth(2.5),
                },
                border: TableBorder.all(
                  color: Colors.grey[300]!,
                  width: 1,
                  borderRadius: BorderRadius.circular(8),
                ),
                children: [
                  // Header Row
                  TableRow(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDD0303).withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    children: [
                      _buildTableHeaderCell('No.'),
                      _buildTableHeaderCell('Tanggal', textAlign: TextAlign.left),
                      _buildTableHeaderCell('ID Order', textAlign: TextAlign.left),
                      _buildTableHeaderCell('Total Harga'),
                      _buildTableHeaderCell('Aksi'),
                    ],
                  ),
                  // Data Rows
                  ...data.map((item) => TableRow(
                    decoration: BoxDecoration(
                      color: data.indexOf(item) % 2 == 0 ? Colors.white : Colors.grey[50],
                    ),
                    children: [
                      _buildTableDataCell(item.no.toString(), isBold: true),
                      _buildTableDataCell(item.formattedDate, textAlign: TextAlign.left),
                      _buildTableDataCell(item.orderId, isBold: true, textAlign: TextAlign.left),
                      _buildTableDataCell(item.totalHarga, color: const Color(0xFF10B981), isBold: true),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DetailLaporanPage(orderUuid: item.uuid)),
                              );
                            },
                            child: const Text('Detail'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDD0303),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 1,
                              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Table Header Cell
  Widget _buildTableHeaderCell(String text, {TextAlign textAlign = TextAlign.center}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFDD0303),
            fontSize: 13,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }

  // Table Data Cell
  Widget _buildTableDataCell(String text, {bool isBold = false, Color? color, TextAlign textAlign = TextAlign.center}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchReportData,
          color: const Color(0xFFDD0303),
          child: CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                automaticallyImplyLeading: false,
                title: const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        _buildModernDropdown(
                          'Bulan',
                          _selectedBulan,
                          const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'],
                          (String? newValue) {
                            setState(() {
                              _selectedBulan = newValue;
                            });
                            _applyFilters();
                          },
                        ),
                        _buildModernDropdown(
                          'Tahun',
                          _selectedTahun,
                          const ['2024', '2025', '2026'],
                          (String? newValue) {
                            setState(() {
                              _selectedTahun = newValue;
                            });
                            _applyFilters();
                          },
                        ),
                        // Reset Filter Button
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedBulan = 'Bulan';
                              _selectedTahun = 'Tahun';
                              _fetchReportData(); // Re-fetch to normalize
                            });
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Reset'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Summary Cards Grid
                    GridView.count(
                      crossAxisCount: 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 3.5,
                      mainAxisSpacing: 16,
                      children: [
                        _buildSummaryCard(
                          'Total Penjualan',
                          '$_totalPenjualan',
                          Icons.shopping_cart,
                          const Color(0xFFDD0303),
                        ),
                        _buildSummaryCard(
                          'Total Pendapatan',
                          _totalPendapatan,
                          Icons.attach_money,
                          const Color(0xFF10B981),
                        ),
                        _buildSummaryCard(
                          'Rata-rata Pendapatan',
                          _rataRataPendapatan,
                          Icons.trending_up,
                          const Color(0xFFF59E0B),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Report Table
                    _buildModernReportTable(_filteredReportData),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}
