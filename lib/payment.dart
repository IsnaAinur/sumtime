import 'package:flutter/material.dart';
import 'dart:io'; 
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  File? _paymentProofFile;
  Uint8List? _paymentProofBytes; 
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

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

  void _processPayment() {
    if (_paymentProofFile != null || _paymentProofBytes != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pembayaran diproses!'),
          backgroundColor: Colors.blue.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap unggah bukti pembayaran terlebih dahulu.'),
          backgroundColor: Color(0xFFDD0303),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFDD0303);
    const Color backgroundColor = Color(0xFFFAFAFA);

    bool isImageSelected = _paymentProofFile != null || _paymentProofBytes != null;
    String labelText = isImageSelected 
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor.withAlpha(128), width: 1),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickImageFromGallery, 
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isImageSelected ? primaryColor : Colors.grey.shade400, 
                    width: isImageSelected ? 2 : 1
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: isImageSelected 
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
                          color: isImageSelected ? primaryColor : Colors.black87,
                          fontSize: 16,
                          fontWeight: isImageSelected ? FontWeight.w600 : FontWeight.normal,
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
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 8,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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