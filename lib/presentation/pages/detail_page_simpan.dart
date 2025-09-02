import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart'; 
// import 'package:share_plus/share_plus.dart';
import 'package:html/parser.dart' as html_parser; 
import 'dart:io';
import 'package:html/dom.dart' as dom;

import '../../../domain/entity/berita.dart';


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
      } else if (node.localName == 'img' || node.localName == 'figure') {
        var img = node.localName == 'figure' ? node.querySelector('img') : node;
        if (img != null) {
          var src = img.attributes['src'];
          if (src != null && src.isNotEmpty) {
            if (src.startsWith('http')) {
              widgets.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.network(src),
                ),
              );
            } else {
              widgets.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.file(File(src)),
                ),
              );
            }
          }
        }
      }
    }
  }
  return widgets;
}



class DetailPageSimpan extends StatefulWidget {
   final Berita berita;

  const DetailPageSimpan({super.key, required this.berita});

  @override
  _DetailPageSimpanState createState() => _DetailPageSimpanState();
}

class _DetailPageSimpanState extends State<DetailPageSimpan> {
  bool isSelected = false;
  int commentCount = 0;
  double _fontSize = 14.0;
  

  @override
  void initState() {
    super.initState();
   
  }
  

  String parseHtmlString(String htmlString) {
    var document = html_parser.parse(htmlString);
    return document.body!.text;
  }



  @override
  Widget build(BuildContext context) {
   final String? imageUrl = widget.berita.thumbnailLocal.isNotEmpty
    ? widget.berita.thumbnailLocal
    : getThumbnailUrl(widget.berita.thumbnail);

    return Scaffold(
      appBar: AppBar(
        
      actions: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            setState(() {
              if (_fontSize > 10) _fontSize -= 2;
            });
          },
        ),
        Center(
          child: Text(
            "A",
            style: TextStyle(fontSize: _fontSize),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              if (_fontSize < 30) _fontSize += 2;
            });
          },
        ),
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
    widget.berita.thumbnailLocal.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: InteractiveViewer(
              minScale: 0.5, // batas zoom out
              maxScale: 4.0, // batas zoom in
              child: Image.file(
                File(widget.berita.thumbnailLocal),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
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
  ],),

        const SizedBox(height: 10),

        // Parsing konten dengan teks dan gambar, bisa dari offline lokal juga
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
        IconButton(
          icon: Icon(icon, size: 24, color: const Color(0xFF03a055)),
          onPressed: onTap,
        ),
      ],
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

