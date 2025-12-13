import 'package:flutter/material.dart';
import 'nav._bottom.dart';
import 'detail_laporan.dart';

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
  final String _periode = 'Hari Ini';

  // Data dummy untuk laporan
  final List<ReportItem> _reportData = [
    ReportItem(1, '13 Dec 2025', 'ORD-001', 'Rp 40.000'),
    ReportItem(2, '13 Dec 2025', 'ORD-002', 'Rp 35.000'),
    ReportItem(3, '12 Dec 2025', 'ORD-003', 'Rp 50.000'),
    ReportItem(4, '12 Dec 2025', 'ORD-004', 'Rp 25.000'),
    ReportItem(5, '11 Dec 2025', 'ORD-005', 'Rp 45.000'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          "Laporan Penjualan",
          style: TextStyle(
            color: Color(0xFFDD0303),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDD0303),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Penjualan $_periode',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_totalPenjualan Pesanan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter Dropdown
              Row(
                children: [
                  const Text(
                    'Filter Periode: ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildDropdown(
                    'Hari Ini',
                    ['Hari Ini', '7 Hari Terakhir', '30 Hari Terakhir'],
                    (value) {
                      setState(() {
                        // TODO: Update data berdasarkan filter
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tabel Laporan
              Expanded(
                child: _buildReportTable(_reportData),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }

  Widget _buildDropdown(String displayValue, List<String> displayItems, Function(String) onChanged) {
    return Container(
      height: 30,
      margin: const EdgeInsets.only(left: 8),
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
            if (newValue != null && newValue != displayValue) {
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DetailLaporanPage()),
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
}
