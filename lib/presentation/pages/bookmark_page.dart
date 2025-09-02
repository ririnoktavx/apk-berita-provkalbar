import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_page.dart';
import '../../data/datasource/bookmark_remote_data_source.dart';
import '../../../domain/entity/berita.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_page_bookmark.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({super.key});

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  List<Map<String, dynamic>> _bookmarkedArticles = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final int _perPage = 10;
  int _pageGroupStart = 0;
  final int _maxVisiblePages = 3;

  int get _totalPages => (_bookmarkedArticles.length / _perPage).ceil();

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final data = await BookmarkDataSource.instance.getBookmarks();
    setState(() {
      _bookmarkedArticles = data;
      _currentPage = 0;
      _isLoading = false;
    });
  }

  Future<void> deleteBookmark(String id) async {
    await BookmarkDataSource.instance.deleteBookmark(id);
    await _loadBookmarks();
  }

  Future<void> deleteAllBookmarks() async {
    await BookmarkDataSource.instance.clearBookmarks();
    await _loadBookmarks();
  }

  Future<bool> _isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  List<Map<String, dynamic>> get _paginatedArticles {
    final start = _currentPage * _perPage;
    final end = (_currentPage + 1) * _perPage;
    return _bookmarkedArticles.sublist(
      start,
      end > _bookmarkedArticles.length ? _bookmarkedArticles.length : end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/prov-logo.png', height: 28, width: 21),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PEMERINTAH PROVINSI",
                    style: GoogleFonts.istokWeb(
                        fontSize: 12,
                        color: const Color(0xFF03a055),
                        fontWeight: FontWeight.bold)),
                Text("KALIMANTAN BARAT",
                    style: GoogleFonts.istokWeb(
                        fontSize: 12,
                        color: const Color(0xFF03a055),
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
             child:Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 15),
                _buildIconButtonHapusSemua(context, "Hapus Semua", () async {
                  
                 await deleteAllBookmarks();
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Semua bookmark dihapus')),
                  // );
                  // await _loadBookmarks();

                  
                  
                
                }),
                const SizedBox(width: 5),
                
              ],
             ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bookmark",
                  style: GoogleFonts.istokWeb(
                    fontSize: 20,
                    color: const Color(0xFF03a055),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                children: [
                  // Tombol sebelumnya
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF03a055),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                      color: _currentPage > 0 ? Colors.white : Colors.grey,
                      padding: EdgeInsets.zero,
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Nomor halaman dengan "..." style
                  Row(
                    children: [
                      // Page 1
                      _buildPageButton(0),

                      if (_currentPage > 2) const Text("..."),

                      // Halaman sekitar current
                      for (int i = _currentPage - 1; i <= _currentPage + 1; i++)
                        if (i > 0 && i < _totalPages - 1) _buildPageButton(i),

                      if (_currentPage < _totalPages - 3) const Text("..."),

                      // Page terakhir
                      if (_totalPages > 1) _buildPageButton(_totalPages - 1),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Tombol selanjutnya
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF03a055),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      color: _currentPage < _totalPages - 1 ? Colors.white : Colors.grey,
                      onPressed: _currentPage < _totalPages - 1
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarkedArticles.isEmpty
              ? const Center(child: Text("Belum ada bookmark"))
              : FutureBuilder<bool>(
                  future: _isConnected(),
                  builder: (context, snapshot) {
                    final isOnline = snapshot.data ?? true;

                    if (!isOnline) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "Kamu sedang offline",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Bookmark hanya tersedia saat online",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    final articles = _paginatedArticles;

                    return ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];

                        final berita = Berita(
                          id: article['id'] ?? '',
                          title: article['title'] ?? '',
                          url: article['url'] ?? '',
                          content: article['content'] ?? '',
                          contentLocal: article['contentLocal'] ?? '',
                          date: article['date'] ?? '',
                          author: article['author'] ?? '',
                          thumbnail: article['thumbnail'] ?? '',
                          thumbnailLocal: article['thumbnailLocal'] ?? '',
                        );

                        return ListTile(
                          title: Text(
                            berita.title,
                            style: GoogleFonts.istokWeb(fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 2,
                          ),
                          subtitle: Text(berita.date, style: GoogleFonts.istokWeb(fontSize: 10)),
                          trailing: IconButton(
                            icon: const Icon(Icons.bookmark, color: Color(0xFF03a055)),
                            onPressed: () async {
                              final confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text("Konfirmasi"),
                                    content: const Text("Apakah Anda yakin ingin menghapus bookmark ini?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop(false); // Tutup dialog
                                        },
                                        child: const Text("Batal"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop(true); // Tutup dialog dan konfirmasi
                                        },
                                        child: const Text("Hapus", 
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirmDelete == true) {
                              await deleteBookmark(berita.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Dihapus dari bookmark')),
                              );
                              }
                            },
                          ),
                          
                          leading: SizedBox(
                            width: 100,
                            height: 100,
                            child: berita.thumbnail.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      getThumbnailUrl(berita.thumbnail),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(color: Colors.grey[300]);
                                      },
                                    ),
                                  )
                                : const Icon(Icons.image),
                          ),
                          onTap: () async {
                            final online = await _isConnected();
                            if (online) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => DetailPage(berita: berita)),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const OfflinePage()),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }

  // Fungsi untuk thumbnail image
  String getThumbnailUrl(String? thumbnail) {
    if (thumbnail == null || thumbnail.isEmpty) {
      return '';
    }

    return thumbnail.startsWith('http') ? thumbnail : 'https://$thumbnail';
  }

  // Icon lingkaran (optional, bisa diaktifkan)
  Widget _buildIconButton(IconData icon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF4F4F4),
            shape: BoxShape.circle,
          ),
        ),
        Icon(icon, size: 24, color: const Color(0xFF03a055)),
      ],
    );
  }

 Widget _buildIconButtonHapusSemua(BuildContext context, String label, VoidCallback onConfirmed) {
  return ElevatedButton.icon(
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Konfirmasi"),
            content: const Text("Apakah Anda yakin ingin menghapus semua berita?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Tutup dialog
                },
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Tutup dialog
                  onConfirmed(); // Panggil aksi hapus
                },
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    },
    icon: const Icon(Icons.bookmark, color: Color(0xFF03a055)), 
    label :Text(label, ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF4F4F4),
      foregroundColor: const Color(0xFF03a055),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

// Tambahin helper function biar gak duplikat
Widget _buildPageButton(int pageIndex) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: InkWell(
      onTap: () {
        setState(() {
          _currentPage = pageIndex;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _currentPage == pageIndex
              ? const Color(0xFF03a055)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${pageIndex + 1}',
          style: TextStyle(
            color: _currentPage == pageIndex ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

}
