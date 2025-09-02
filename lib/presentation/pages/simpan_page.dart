import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/datasource/simpan_local_data_source.dart';
import '../../../presentation/pages/detail_page_simpan.dart';
import '../../../domain/entity/berita.dart';
import 'dart:io';
import '../provider/simpan_provider.dart';
import 'package:provider/provider.dart';



class SimpanPage extends StatefulWidget {
  const SimpanPage({super.key});

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {

  
  int _currentPage = 0;
  final int _perPage = 10;
  int _pageGroupStart = 0;
  final int _maxVisiblePages = 3;
  int get _totalPages {
    final totalData =
        Provider.of<SimpanProvider>(context, listen: false).beritaTersimpan.length;
    return (totalData / _perPage).ceil();
  }



  @override
  void initState() {
    super.initState();
    // _loadSavedArticles();
     Future.microtask(() {
    Provider.of<SimpanProvider>(context, listen: false).loadSavedArticles();
  });
  
  }



 
  List<Berita> _getPaginatedArticles(List<Berita> allData) {
  final startIndex = _currentPage * _perPage;
  final endIndex = (_currentPage + 1) * _perPage;
  return allData.sublist(
    startIndex,
    endIndex > allData.length ? allData.length : endIndex,
  );
}

  Future<void> deleteBerita(String id) async {
    await SimpanLocalDataSource.instance.deleteBerita(id);
    // await _loadSavedArticles();
    
  }

  Future<void> deleteAllSavedArticles() async {
    await SimpanLocalDataSource.instance.clearSavedBerita();
    // await _loadSavedArticles();
  }


//   List<Map<String, dynamic>> get _paginatedArticles {
//   final startIndex = _currentPage * _perPage;
//   final endIndex = (_currentPage + 1) * _perPage;
//   return _savedArticles.sublist(
//     startIndex,
//     endIndex > _savedArticles.length ? _savedArticles.length : endIndex,
//   );
// }




  @override
  Widget build(BuildContext context) {
    final simpanProvider = Provider.of<SimpanProvider>(context);
    final allArticles = simpanProvider.beritaTersimpan;
    final paginatedArticles = _getPaginatedArticles(allArticles);
    final totalPages = (allArticles.length / _perPage).ceil();

    
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
                        fontSize: 12, color: const Color(0xFF03a055), fontWeight: FontWeight.bold)),
                Text("KALIMANTAN BARAT",
                    style: GoogleFonts.istokWeb(
                        fontSize: 12, color: const Color(0xFF03a055), fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 15),
              _buildIconButtonHapusSemua(context, "Hapus Semua", () async {
              // Panggil fungsi hapus semua berita di provider
              await Provider.of<SimpanProvider>(context, listen: false).hapusSemuaBerita();

              // Set ulang currentPage dan pageGroupStart supaya tidak error
              setState(() {
                _currentPage = 0;
                _pageGroupStart = 0;
              });

              // Setelah hapus semua, load ulang artikel untuk memastikan UI update
              await Provider.of<SimpanProvider>(context, listen: false).loadSavedArticles();
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Baca Offline",
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
     body: simpanProvider.isLoading
    ? const Center(child: CircularProgressIndicator())
    : simpanProvider.beritaTersimpan.isEmpty
        ? const Center(child: Text("Belum ada berita yang disimpan."))
        : Column(
            children: [
              // Tombol navigasi dan lainnya

              Expanded(
                child: ListView.builder(
                 itemCount: paginatedArticles.length,
                  itemBuilder: (context, index) {
                    final article = paginatedArticles[index];
                    return ListTile(
                      title: Text(
                        article.title,
                        style: GoogleFonts.istokWeb(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFF03a055)),
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Konfirmasi Hapus"),
                                content: const Text("Apakah Anda yakin ingin menghapus berita ini?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Batal"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmDelete == true) {
                            await simpanProvider.hapusBerita(article.id);
                          }
                        },
                      ),
                      subtitle: Text(
                        article.date,
                        style: GoogleFonts.istokWeb(fontSize: 10),
                      ),
                      leading: SizedBox(
                        width: 100,
                        height: 100,
                        child: Builder(
                          builder: (_) {
                            final localPath = article.thumbnailLocal;
                            final thumbnailUrl = article.thumbnail;

                            if (localPath.isNotEmpty && File(localPath).existsSync()) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(localPath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return fallbackImage(thumbnailUrl);
                                  },
                                ),
                              );
                            } else if (thumbnailUrl.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return fallbackImage(null);
                                  },
                                ),
                              );
                            } else {
                              return fallbackImage(null);
                            }
                          },
                        ),
                      ),
                    
                  
                     onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPageSimpan(
                            berita: article, 
                          ),
                        ),
                      );
                    },
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }

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
                  Navigator.of(dialogContext).pop(); 
                },
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); 
                  onConfirmed(); 
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
    icon: const Icon(Icons.delete, color: Color(0xFF03a055)), 
    label: Text(label),
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


  Widget fallbackImage(String? url) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
  );
}




 String getThumbnailUrl(String? thumbnail) {
  if (thumbnail == null || thumbnail.isEmpty) {
    return '';
  }

  return thumbnail.startsWith('http')
      ? thumbnail
      : 'https://$thumbnail'; 

}

}
