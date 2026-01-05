import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'rincianpesanan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final int shippingCost;

  const PaymentPage({
    super.key,
    required this.cart,
    required this.shippingCost,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  File? _paymentProofFile;
  Uint8List? _paymentProofBytes;
  final ImagePicker _picker = ImagePicker();

  int _calculateTotalAmount() {
    int total = widget.shippingCost;

    for (final item in widget.cart) {
      final harga = (item['harga'] ?? item['price'] ?? 0) as int;
      final qty = (item['quantity'] ?? item['qty'] ?? 1) as int;

      total += harga * qty;
    }

    return total;
  }

  Future<String?> _uploadProofToSupabase(String orderNumber) async {
    try {
      setState(() => _isLoading = true);

      final fileName =
          "bukti-$orderNumber-${DateTime.now().millisecondsSinceEpoch}.jpg";
      final filePath = "bukti/$fileName";

      if (kIsWeb && _paymentProofBytes != null) {
        await supabase.storage
            .from('payment')
            .uploadBinary(
              filePath,
              _paymentProofBytes!,
              fileOptions: const FileOptions(
                upsert: false,
                cacheControl: '3600',
              ),
            );
      } else if (_paymentProofFile != null) {
        await supabase.storage
            .from('payment')
            .upload(
              filePath,
              _paymentProofFile!,
              fileOptions: const FileOptions(
                upsert: false,
                cacheControl: '3600',
              ),
            );
      } else {
        return null;
      }

      final proofUrl = supabase.storage.from('payment').getPublicUrl(filePath);

      return proofUrl;
    } catch (e) {
      debugPrint("Upload proof error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload error: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }

      return null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _saveProofToDatabase(String orderNumber, String proofUrl) async {
    try {
      final userId = supabase.auth.currentUser?.id;

      await supabase.from('orders').upsert({
        'order_id': orderNumber,
        'user_id': userId,
        'total_amount': _calculateTotalAmount(),
        'payment_proof_url': proofUrl,
        'payment_status': 'menunggu',
      }, onConflict: 'order_id');

      return true;
    } catch (e) {
      debugPrint("Save DB error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("DB error: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }

      return false;
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _paymentProofBytes = bytes;
          _paymentProofFile = null;
        });
      } else {
        setState(() {
          _paymentProofFile = File(pickedFile.path);
          _paymentProofBytes = null;
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bukti ${pickedFile.name} berhasil diunggah.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unggah bukti pembayaran dibatalkan.'),
          backgroundColor: Color(0xFFE94E4E),
        ),
      );
    }
  }

  Future<void> _processPayment() async {
    if (_paymentProofFile == null && _paymentProofBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap unggah bukti pembayaran terlebih dahulu.'),
          backgroundColor: Color(0xFFDD0303),
        ),
      );
      return;
    }

    final orderNumber =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final proofUrl = await _uploadProofToSupabase(orderNumber);

    if (proofUrl == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload bukti pembayaran gagal.'),
          backgroundColor: Color(0xFFE94E4E),
        ),
      );
      return;
    }

    final saved = await _saveProofToDatabase(orderNumber, proofUrl);

    if (!saved) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan bukti ke database.'),
          backgroundColor: Color(0xFFE94E4E),
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RincianPesananPage(
              orderItems: widget.cart,
              shippingCost: widget.shippingCost,
              orderNumber: orderNumber,
              orderDate: DateTime.now(),
              currentStatus: 1,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFDD0303);
    const Color backgroundColor = Color(0xFFFAFAFA);

    bool isImageSelected =
        _paymentProofFile != null || _paymentProofBytes != null;
    String labelText =
        isImageSelected
            ? 'Bukti Pembayaran Terpilih'
            : 'Input Bukti Pembayaran';

    Widget? imagePreview;
    if (isImageSelected) {
      Widget imageWidget;
      if (kIsWeb && _paymentProofBytes != null) {
        imageWidget = Image.memory(_paymentProofBytes!, fit: BoxFit.cover);
      } else if (_paymentProofFile != null) {
        imageWidget = Image.file(_paymentProofFile!, fit: BoxFit.cover);
      } else {
        imageWidget = Container();
      }

      imagePreview = Container(
        height: 600,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor, width: 3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Scan QRIS Barcode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryColor.withAlpha(128),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha(51),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 150,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arahkan kamera ke QR Code',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Add Bukti Pembayaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isImageSelected ? primaryColor : Colors.grey.shade400,
                    width: isImageSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color:
                      isImageSelected
                          ? primaryColor.withAlpha(26)
                          : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        labelText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              isImageSelected ? primaryColor : Colors.black87,
                          fontSize: 16,
                          fontWeight:
                              isImageSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (imagePreview != null) imagePreview,
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 8,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
