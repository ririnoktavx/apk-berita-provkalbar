import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:share_plus/share_plus.dart';
import 'package:html/parser.dart' as html_parser; 
import '../../data/datasource/bookmark_remote_data_source.dart';
import '../../../data/datasource/simpan_local_data_source.dart';
import '../provider/bookmark_provider.dart';
import 'package:provider/provider.dart';
import '../../../domain/entity/berita.dart';
import 'package:html/dom.dart' as dom;


List<Widget> parseContentToWidgets(String htmlContent, double fontSize) {
  var document = html_parser.parse(htmlContent);
  List<Widget> widgets = [];

  for (var node in document.body!.nodes) {
    if (node is dom.Element) {
      if (node.localName == 'p') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              node.text.trim(),
              style: GoogleFonts.istokWeb(fontSize: fontSize),
              textAlign: TextAlign.justify,
            ),
          ),
        );
      } else if (node.localName == 'figure') {
        var img = node.querySelector('img');
        if (img != null) {
          var src = img.attributes['src'];
          if (src != null && src.isNotEmpty) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.network(src),
              ),
            );
          }
        }
      } else if (node.localName == 'img') {
        var src = node.attributes['src'];
        if (src != null && src.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Image.network(src),
            ),
          );
        }
      }
    }
  }

  return widgets;
}



class DetailPage extends StatefulWidget {
   final Berita berita;

  const DetailPage({super.key, required this.berita});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isBookmarked = false;
  bool isSelected = false;
  int commentCount = 0;
  double _downloadProgress = 0.0;
  double _fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  void _checkBookmarkStatus() async {
    final provider = Provider.of<BookmarkProvider>(context, listen: false);
    final status = await provider.isBookmarked(widget.berita.id); 
    setState(() {
      isBookmarked = status;
  });
  }

  String parseHtmlString(String htmlString) {
    var document = html_parser.parse(htmlString);
    return document.body!.text;
  }


  @override
  Widget build(BuildContext context) {
    final imageUrl = getThumbnailUrl(widget.berita.thumbnail );
    return Scaffold(
      appBar: AppBar(
        leading: _buildCircleIcon(Icons.arrow_back, () => Navigator.pop(context)),
        title: Text(
          widget.berita.title,
          overflow: TextOverflow.ellipsis, // biar gak meluber kalau judul panjang
        ),
        actions: [
          _buildCircleIcon(Icons.share, () {
            final title = widget.berita.title;
            final url = widget.berita.url;
            if (title.isNotEmpty && url.isNotEmpty) {
              Share.share('$title\nhttps://kalbarprov.go.id${url}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak bisa membagikan berita kosong')),
              );
            }
          }),

          const SizedBox(width: 5),
          _buildTombolSimpan(Icons.save, 'Simpan', () async {
            final isSaved = await SimpanLocalDataSource.instance.isSaved(widget.berita.id);

                if (!isSaved) {
                  try {
                    // Tampilkan loading dulu biar UI responsif
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    final localPath = await SimpanLocalDataSource.instance.downloadAndSaveThumbnail(
                      widget.berita.thumbnail,
                      widget.berita.id,
                    );

                    final processedContent = await SimpanLocalDataSource.instance.processContentAndSaveImages(
                      widget.berita.content,
                      widget.berita.id,
                    );

                    final beritaMap = {
                      'id': widget.berita.id,
                      'title': widget.berita.title,
                      'url': widget.berita.url,
                      'content': widget.berita.content,
                      'contentLocal': processedContent,
                      'date': widget.berita.date,
                      'author': widget.berita.author,
                      'thumbnail': widget.berita.thumbnail,
                      'thumbnailLocal': localPath,
                    };

                    await SimpanLocalDataSource.instance.insertBerita(beritaMap);
                  

                    if (context.mounted) {
                      Navigator.of(context).pop(); // Tutup loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Berita berhasil disimpan untuk dibaca offline')),
                      );

                      // Baru update state setelah semua proses selesai
                      setState(() {
                        isSelected = true;
                      });
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Tutup loading kalau gagal
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan berita: $e')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berita sudah pernah disimpan')),
                  );
                }
              }),


               const SizedBox(width: 5),

                 Consumer<BookmarkProvider>(
  builder: (context, bookmarkProvider, _) {
    final berita = widget.berita;

    return _buildCircleIcon(
      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
      () async {
        final berita = widget.berita;

        if (isBookmarked) {
          await bookmarkProvider.removeBookmark(berita.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil dihapus dari bookmark'),
            ),
          );
        } else {
          await bookmarkProvider.addBookmark(berita);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berita Berhasil ditambahkan ke bookmark'),
            ),
          );
        }

        // Update icon berdasarkan status terbaru
        final status = await bookmarkProvider.isBookmarked(berita.id);
        setState(() {
          isBookmarked = status;
        });
      },
    );
  },
),

                  const SizedBox(width: 10),

    _buildCircleIcon(Icons.remove, () {
      setState(() {
        if (_fontSize > 10) _fontSize -= 2;
      });
    }),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        "A",
        style: TextStyle(fontSize: _fontSize),
      ),
    ),
    _buildCircleIcon(Icons.add, () {
      setState(() {
        if (_fontSize < 30) _fontSize += 2;
      });
    }),
    const SizedBox(width: 5),
  

          ],
        ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(
            widget.berita.title,
            style: GoogleFonts.istokWeb(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                widget.berita.date,
                style: GoogleFonts.istokWeb(fontSize: 14, color: const Color(0xFFBEBEBE)),
              ),
              const SizedBox(width: 5),
              Text(
                widget.berita.author,
                style: GoogleFonts.istokWeb(fontSize: 14, color: const Color(0xFFBEBEBE)),
              ),
            ],
          ),
          const SizedBox(height: 10),
        Stack(
          children: [
            widget.berita.thumbnail.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: imageUrl == null
                        ? Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          )
                        : InteractiveViewer(
                            minScale: 0.5, // batas zoom out
                            maxScale: 4.0, // batas zoom in
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[300],
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                      size: 50,
                    ),
                  ),
          ],
        ),

          const SizedBox(height: 10),

          // Ini bagian yang baru:
        ...parseContentToWidgets(
          widget.berita.contentLocal.isNotEmpty 
              ? widget.berita.contentLocal 
              : widget.berita.content,
          _fontSize,
        ),



          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: Text(
              widget.berita.url,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],

                  ),
                ),
              ),
            );
          }

  Widget _buildCircleIcon(IconData icon, VoidCallback onTap) {
  return Material(
    color: const Color(0xFFF4F4F4),      
    shape: const CircleBorder(),          
    child: InkWell(
      customBorder: const CircleBorder(), 
      splashColor: const Color(0xFF03a055),   
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, size: 24, color: const Color(0xFF03a055)),
      ),
    ),
  );
}
  Widget _buildTombolSimpan(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF4F4F4),
        foregroundColor: const Color(0xFF03a055),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
