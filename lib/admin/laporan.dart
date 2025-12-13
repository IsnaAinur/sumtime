import 'package:flutter/material.dart';

class ReportItem {
  final int no;
  final String date;
  final String orderId;
  final String totalHarga;

  ReportItem(this.no, this.date, this.orderId, this.totalHarga);
}

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final int _totalPenjualan = 20;
  final String _totalPendapatan = 'Rp 300.000';
  final String _rataRataPendapatan = 'Rp 300.000';
  
  String? _selectedBulan = 'Bulan'; 
  String? _selectedTahun = 'Tahun'; 
  int _selectedIndex = 2; 

  final List<ReportItem> _reportData = [
    ReportItem(1, '22/11', 'ORD-001', 'Rp 50.000'),
    ReportItem(2, '22/11', 'ORD-002', 'Rp 25.000'),
    ReportItem(3, '22/11', 'ORD-003', 'Rp 60.000'),
    ReportItem(4, '22/11', 'ORD-004', 'Rp 30.000'),
  ];

  void _fetchReportData() {
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Ringkasan
  Widget _buildSummaryBox(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5), 
        borderRadius: BorderRadius.circular(0), 
        color: const Color(0xFFF0F0F0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown Filter
  Widget _buildFilterDropdown(String label, String? selectedValue, List<String> items, Function(String?) onChanged) {
    List<String> displayItems = [label, ...items];
    String? displayValue = selectedValue != null && items.contains(selectedValue) ? selectedValue : label;

    return Container(
      height: 30, 
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5), 
        borderRadius: BorderRadius.circular(5), 
        color: const Color(0xFFF0F0F0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: displayValue,
          iconSize: 18,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          items: displayItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
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

  // Tabel Laporan
  Widget _buildReportTable(List<ReportItem> data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.0),
          1: FlexColumnWidth(2.0),
          2: FlexColumnWidth(3.0),
          3: FlexColumnWidth(3.5),
          4: FlexColumnWidth(3.0), // Kolom Aksi
        },
        border: TableBorder.all(color: Colors.black, width: 1.0),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFD6D0D0)),
            children: [
              TableCell(child: Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))))),
              TableCell(child: Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Tgl', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))))),
              TableCell(child: Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('ID ORDER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))))),
              TableCell(child: Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Total Harga', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))))),
              TableCell(child: Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))))),
            ],
          ),
          ...data.map((item) => TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF0F0F0)),
            children: [
              TableCell(child: Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(item.no.toString(), style: const TextStyle(color: Colors.black))))),
              TableCell(child: Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(item.date, style: const TextStyle(color: Colors.black))))),
              TableCell(child: Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(item.orderId, style: const TextStyle(color: Colors.black))))),
              TableCell(child: Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(item.totalHarga, style: const TextStyle(color: Colors.black))))),
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigasi ke detail_laporan.dart
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Detail laporan untuk ${item.orderId}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDD0303),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Detail Laporan'),
                    ),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color mainBackgroundColor = Color(0xFFDD0303); 

    return Scaffold(
      backgroundColor: mainBackgroundColor, 
      
      appBar: AppBar(
        title: const Text(
          'DASHBOARD',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: mainBackgroundColor,
        foregroundColor: Colors.white, 
        elevation: 0, 
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                _buildFilterDropdown(
                  'Bulan',
                  _selectedBulan,
                  const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'],
                  (String? newValue) {
                    setState(() {
                      _selectedBulan = newValue;
                    });
                    _fetchReportData();
                  },
                ),
                _buildFilterDropdown(
                  'Tahun',
                  _selectedTahun,
                  const ['2024', '2025', '2026'],
                  (String? newValue) {
                    setState(() {
                      _selectedTahun = newValue;
                    });
                    _fetchReportData();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 15),

            _buildSummaryBox('Total penjualan', '$_totalPenjualan'),
            _buildSummaryBox('Total pendapatan', _totalPendapatan),
            _buildSummaryBox('Rata-rata pendapatan', _rataRataPendapatan),

            const SizedBox(height: 25),

            const Text(
              'LAPORAN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),

            _buildReportTable(_reportData),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long, color: _selectedIndex == 0 ? mainBackgroundColor : Colors.grey),
            label: 'ORDERAN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view, color: _selectedIndex == 1 ? mainBackgroundColor : Colors.grey),
            label: 'ADD ITEM',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, color: _selectedIndex == 2 ? mainBackgroundColor : Colors.grey),
            label: 'LAPORAN',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: mainBackgroundColor, 
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true, 
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, 
        backgroundColor: Colors.white, 
      ),
    );
  }
}