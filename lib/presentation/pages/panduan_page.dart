import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PanduanPage extends StatelessWidget {
  const PanduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Image.asset('assets/images/prov-logo.png', height: 28, width: 21),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PEMERINTAH PROVINSI",
                  style: GoogleFonts.istokWeb(
                    fontSize: 12,
                    color: const Color(0xFF03a055),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "KALIMANTAN BARAT",
                  style: GoogleFonts.istokWeb(
                    fontSize: 12,
                    color: const Color(0xFF03a055),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Panduan",
                style: GoogleFonts.istokWeb(
                  fontSize: 20,
                  color: const Color(0xFF03a055),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PanduanItem(
            icon: Icons.bookmark,
            title: 'Bookmark',
            description:
                'Bookmark digunakan untuk menandai berita yang ingin dibaca nanti secara online.\n\n'
                'Cara menggunakan:\n'
                '1. Buka berita yang kamu suka.\n'
                '2. Tekan ikon bookmark di kanan tombol simpan.\n'
                '3. Berita akan masuk ke halaman Bookmark.\n'
                '4. Pastikan kamu terhubung internet saat ingin membacanya.',
          ),
          SizedBox(height: 16),
          PanduanItem(
            icon: Icons.save, 
            title: 'Simpan',
            description:
                'Fitur Simpan memungkinkan kamu membaca berita meskipun tidak terhubung internet.\n\n'
                'Cara menggunakan:\n'
                '1. Buka berita yang ingin kamu simpan.\n'
                '2. Tekan tombol yang bertulisan "simpan" di atas berita.\n'
                '3. Berita akan masuk ke halaman Simpan.\n'
                '4. Bisa dibaca kapan saja, bahkan saat tidak ada koneksi internet.\n'
          ),
        ],
      ),
    );
  }
}

class PanduanItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const PanduanItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.green.shade50, 
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.green.shade800, 
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
