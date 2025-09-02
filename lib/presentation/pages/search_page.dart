import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../../../domain/entity/berita.dart';
import '../provider/berita_provider.dart';
import '../pages/detail_page.dart';
import '../pages/offline_page_bookmark.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final beritaProvider = Provider.of<BeritaProvider>(context, listen: false);
      beritaProvider.fetchBerita(); 
    });
  }

  Future<bool> _isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    final beritaProvider = Provider.of<BeritaProvider>(context);
    final beritaList = beritaProvider.beritaList;
    final isLoading = beritaProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari berita...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            beritaProvider.fetchBerita(value); 
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : beritaList.isEmpty
              ? const Center(child: Text('Berita tidak ditemukan.'))
              : ListView.builder(
                    itemCount: beritaList.length,
                    itemBuilder: (context, index) {
                      final berita = beritaList[index];
                      final imageUrl = getThumbnailUrl(berita.thumbnail);
                      return ListTile(
                       onTap: () async {
                         final isOnline = await _isConnected();
                         if (isOnline) {
                          // Jika online, navigasi ke halaman detail
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(berita: berita),
                            ),
                          );
                          } else {
                            // Jika offline, tampilkan pesan
                            Navigator.push(context, MaterialPageRoute(builder: (_) => OfflinePage()));
                            
                          }
                      },
                        leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl == null
                        ? Container(
                            width: 100,
                            height: 85,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          )
                        : Image.network(
                            imageUrl,
                            width: 100,
                            height: 85,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 85,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                  ),
                  title: Text(
                    berita.title,
                    style: GoogleFonts.istokWeb(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    berita.author,
                    style: GoogleFonts.istokWeb(
                      fontSize: 10,
                      color: const Color(0xFFBEBEBE),
                    ),
                  ),
                );
              },
            ),
);
                       
  }
  String? getThumbnailUrl(String? thumbnail) {
  if (thumbnail == null || thumbnail.isEmpty) {
    return null;
  }

  return thumbnail.startsWith('http')
      ? thumbnail
      : 'https://$thumbnail'; 



}
}
