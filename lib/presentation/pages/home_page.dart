import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../../domain/entity/berita.dart';
import '../provider/berita_provider.dart';


import 'detail_page.dart';
import 'offline_page_bookmark.dart';
import 'search_page.dart';

// import '../provider/bookmark_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/datasource/simpan_local_data_source.dart';




class Home extends StatefulWidget {
  const Home({super.key});
  

  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {
  int _currentPage = 0;
  int _itemsPerPage = 20;
   int _pageGroupStart = 0;
  final int _maxVisiblePages = 3;
  late StreamSubscription<ConnectivityResult> _subscription;
  bool isOffline = false;



  @override
  void initState() {
    super.initState();
     _checkInitialConnectivity();

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isOffline = result == ConnectivityResult.none;
      });
    });
      WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadBeritaAwal();
  });
    Future.microtask(() =>
        Provider.of<BeritaProvider>(context, listen: false).fetchBerita());
  }
 Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = result == ConnectivityResult.none;
    });
  }
  

  
  void _loadBeritaAwal() async {
  final provider = Provider.of<BeritaProvider>(context, listen: false);
  await provider.fetchBerita(); 
}




List<Berita> get _paginatedBerita {
  
    final beritaProvider = Provider.of<BeritaProvider>(context, listen: false);
    final list = beritaProvider.beritaList;

    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= list.length) return [];

    return list.sublist(start, end > list.length ? list.length : end);
  }

  int get _totalPages {
  final beritaProvider = Provider.of<BeritaProvider>(context, listen: false);
  final list = beritaProvider.beritaList;
  return (list.length / _itemsPerPage).ceil();
}



void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Row(
        children: const [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Expanded(child: Text('Menyimpan berita...')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); 
          },
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}

@override
  void dispose() {
    _subscription.cancel(); // jangan lupa cancel subscription
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final beritaProvider = Provider.of<BeritaProvider>(context);
    final isLoading = beritaProvider.isLoading;
    final listBerita = beritaProvider.beritaList;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/prov-logo.png',
              height: 28,
              width: 21,
            ),
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
            const Spacer(),
            
                    Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(Icons.search, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(),
                        ),

                      
                      );
                    }),
                const SizedBox(width: 15),
                
                 _buildTombolSimpan(Icons.save, 'Simpan Semua', () async {
                final beritaProvider = Provider.of<BeritaProvider>(context, listen: false);
                final semuaBerita = beritaProvider.beritaList;


                bool adaYangDisimpan = false;
                bool dibatalkan = false;
                bool dihentikan = false;

                ValueNotifier<String> progressText = ValueNotifier("Mengecek koneksi...");
                List<String> beritaTersimpanSementara = [];

                

                 // Cek apakah semua berita sudah tersimpan
                bool semuaSudahTersimpan = true;
                for (final berita in semuaBerita) {
                  final isSaved = await SimpanLocalDataSource.instance.isSaved(berita.id);
                  if (!isSaved) {
                    semuaSudahTersimpan = false;
                    break;
                  }
                }

                if (semuaSudahTersimpan) {
                  // Jika semua sudah tersimpan, langsung tampilkan pesan dan keluar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berita sudah pernah disimpan')),
                  );
                  return;
                }

                // KONFIRMASI AWAL
                final lanjutSimpan = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Konfirmasi"),
                    content: const Text("Apakah anda yakin ingin menyimpan semua berita? Proses ini membutuhkan waktu relatif lama."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yakin")),
                    ],
                  ),
                );

                if (lanjutSimpan != true) return;

                

                // SHOW DIALOG PROSES
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => StatefulBuilder(
                    builder: (context, dialogSetState) => AlertDialog(
                      content: ValueListenableBuilder(
                        valueListenable: progressText,
                        builder: (context, value, child) {
                          return Row(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(width: 20),
                              Expanded(child: Text(value)),
                            ],
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final konfirmasiBatal = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Batalkan Penyimpanan"),
                                content: const Text("Yakin ingin membatalkan? Berita yang sudah disimpan akan dihapus."),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
                                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yakin")),
                                ],
                              ),
                            );
                            if (konfirmasiBatal == true) {
                            dibatalkan = true;
                            progressText.value = "Menghapus berita yang sudah disimpan...";

                            // Tunggu proses penghapusan selesai dulu
                                for (String id in beritaTersimpanSementara) {
                                  await SimpanLocalDataSource.instance.deleteBerita(id);
                                }

                                // Setelah penghapusan selesai, baru tutup dialog
                                Navigator.of(context).pop(); // Tutup dialog loading

                                }
                              },
                              child: const Text("Batalkan"),
                            ),
                            TextButton(
                              onPressed: () {
                                dihentikan = true;
                                Navigator.of(context).pop(); // Tutup dialog loading
                              },
                              child: const Text("Berhenti"),
                            ),
                          ],
                        ),
                      ),
                    );

                    int index = 0;
                    while (index < semuaBerita.length) {
                      if (dibatalkan || dihentikan) break;

                      final connectivity = await Connectivity().checkConnectivity();
                      if (connectivity == ConnectivityResult.none) {
                        progressText.value = "Menunggu koneksi internet...";
                        await Future.delayed(const Duration(seconds: 2));
                        continue;
                      }

                      final berita = semuaBerita[index];
                      progressText.value = "Menyimpan ${index + 1}/${semuaBerita.length}...";

                      final isSaved = await SimpanLocalDataSource.instance.isSaved(berita.id);
                      if (!isSaved) {
                        try {
                          final localPath = await SimpanLocalDataSource.instance.downloadAndSaveThumbnail(
                            berita.thumbnail,
                            berita.id,
                          );
                          
                          final processedContent = await SimpanLocalDataSource.instance.processContentAndSaveImages(
                              berita.content,
                              berita.id,
                            );
            

                          final beritaMap = {
                            'id': berita.id,
                            'title': berita.title,
                            'url': berita.url,
                            'content': berita.content, 
                            'contentLocal': berita.contentLocal,
                            'date': berita.date,
                            'author': berita.author,
                            'thumbnail': berita.thumbnail,
                            'thumbnailLocal': localPath,
                          };

                          // INSERT DENGAN HANDLING MEMORI PENUH
                    //       try {
                    //         await SimpanLocalDataSource.instance.insertBerita(beritaMap);
                    //         beritaTersimpanSementara.add(berita.id);
                    //         adaYangDisimpan = true;
                    //       } catch (e) {
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           SnackBar(
                    //             content: Text(e.toString()),
                    //             // Text("Gagal menyimpan: memori perangkat penuh")),
                    //           ),
                    //         );
                    //         break; // hentikan loop karena storage penuh
                    //       }
                    //     } catch (e) {
                    //       // Error lain, misal download thumbnail
                    //     }
                    //   }

                    //   index++;
                    // }


                   

                     try {
                            await SimpanLocalDataSource.instance.insertBerita(beritaMap);
                            beritaTersimpanSementara.add(berita.id);
                            adaYangDisimpan = true;
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      
                                      Text("Gagal menyimpan: memori perangkat penuh")),
                            );
                            break; // hentikan loop karena storage penuh
                          }
                        } catch (e) {
                          // Error lain, misal download thumbnail
                        }
                      }

                      index++;
                    }

                    // Jika dibatalkan, hapus berita yang sempat disimpan
                    if (dibatalkan) {
                      for (String id in beritaTersimpanSementara) {
                        await SimpanLocalDataSource.instance.deleteBerita(id);
                      }
                    }

                    if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(); 
                  }
                    // Pesan
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          dibatalkan
                              ? 'Penyimpanan dibatalkan dan data dihapus'
                              : dihentikan
                                  ? 'Penyimpanan dihentikan. Sebagian data berhasil disimpan.'
                                  : adaYangDisimpan
                                      ? 'Berita berhasil disimpan semua'
                                      : 'Berita sudah pernah disimpan',
                        ),
                      ),
                    );

                    setState(() {});
                  }),




                    ],
                  ),


          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Berita Terkini",
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
      body: Column(
        children: [
           if (isOffline)
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Colors.red[100],
        child: Text(
          "Tidak ada koneksi internet",
          textAlign: TextAlign.center,
          style: GoogleFonts.istokWeb(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
          isLoading
              ? const SizedBox(
                  height: 213, child: Center(child: CircularProgressIndicator()))
              : CarouselSlider(
                  options: CarouselOptions(
                    height: 213,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    viewportFraction: 0.8,
                  ),
                  items: listBerita.take(5).map((berita) {
                    return GestureDetector(
                      onTap: () async {
                          final connectivityResult = await Connectivity().checkConnectivity();
                          final isOnline = connectivityResult != ConnectivityResult.none;

                          if (isOnline) {
                          
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DetailPage(berita: berita)),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => OfflinePage()),
                            );
                          }
                        },

                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                getThumbnailUrl(berita.thumbnail),
                                width: 100,
                                height: 85,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 85),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xCC013D20),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        berita.date,
                                        style: GoogleFonts.istokWeb(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        berita.title,
                                        style: GoogleFonts.istokWeb(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 20),
          Expanded(
  child: Column(
    children: [

      Row(

       
        children: [

          const SizedBox(width: 16),
          const Text(
            'Semua Berita',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF03a055),
            ),
          ),
          const Spacer(),
          
          const SizedBox(width: 16),
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
                  const SizedBox(width: 16),
                ],
      ),
      const SizedBox(height: 10),
      Expanded(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _paginatedBerita.length,
                itemBuilder: (context, index) {
                  final berita = _paginatedBerita[index];
                  return ListTile(
                    onTap: () async {
                      final connectivityResult =
                          await Connectivity().checkConnectivity();
                      final isOnline = connectivityResult != ConnectivityResult.none;
                      if (isOnline) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailPage(berita: berita)),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OfflinePage()),
                        );
                      }
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        getThumbnailUrl(berita.thumbnail),
                        width: 100,
                        height: 85,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 60,
                            color: Colors.grey[300],
                          );
                        },
                      ),
                    ),
                    title: Text(
                      berita.title,
                      style: GoogleFonts.istokWeb(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.date_range, size: 16, color: Color(0xFFBEBEBE)),
                            const SizedBox(width: 8),
                            Text(
                              berita.date,
                              style: GoogleFonts.istokWeb(
                                fontSize: 9,
                                color: const Color(0xFFBEBEBE),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Color(0xFFBEBEBE)),
                            const SizedBox(width: 8),
                            Text(
                              berita.author,
                              style: GoogleFonts.istokWeb(
                                fontSize: 9,
                                color: const Color(0xFFBEBEBE),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    ],
  ),
),

        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: const BoxDecoration(
            color: Color(0xFFF4F4F4),
            shape: BoxShape.circle,
          ),
        ),
        Icon(icon, size: 23, color: const Color(0xFF03a055)),
      ],
    ),
  );
}

Widget _buildTombolSimpan(IconData icon, String label, VoidCallback onTap) {
  return ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 18),
    label: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      softWrap: true,
      overflow: TextOverflow.visible,
      maxLines: 2, // agar bisa turun baris
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF4F4F4),
      foregroundColor: const Color(0xFF03a055),
      elevation: 0,
      minimumSize: const Size(100, 40), // ukuran background tombol
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}


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


  





 String getThumbnailUrl(String? thumbnail) {
  if (thumbnail == null || thumbnail.isEmpty) {
    return '';
  }

  return thumbnail.startsWith('http')
      ? thumbnail
      : 'https://$thumbnail'; 



}

}
