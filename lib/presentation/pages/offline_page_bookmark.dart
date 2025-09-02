import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Offline',
          style: GoogleFonts.istokWeb(
            color: const Color(0xFF03a055),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF03a055)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.grey.shade600),
            const SizedBox(height: 20),
            Text(
              'Tidak ada koneksi internet',
              style: GoogleFonts.istokWeb(
                fontSize: 18,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Silakan sambungkan ke internet\nuntuk membaca berita ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.istokWeb(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03a055),
              ),
            )
          ],
        ),
      ),
    );
  }
}
