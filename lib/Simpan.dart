// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:projec_pkl/db_helper.dart';
// import 'package:projec_pkl/detail_berita.dart';

// class simpan extends StatefulWidget {
//   const simpan({super.key});

//   @override
//   State<simpan> createState() => _simpanState();
// }

// class _simpanState extends State<simpan> {
//   List<Map<String, dynamic>> _savedArticles = [];

// @override
// void initState() {
//   super.initState();
//   _loadSavedArticles();
// }

// void _loadSavedArticles() async {
//   final dbHelper = DBHelper();
//   final data = await dbHelper.getArticles();
//   setState(() {
//     _savedArticles = data;
//   });
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//     appBar: AppBar(
//         title: Row(
//           children: [
//             Image.asset(
//               'assets/images/prov-logo.png',
//               height: 28,
//               width: 21,
//             ),
//             const SizedBox(width: 8),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "PEMERINTAH PROVINSI",
//                   style: GoogleFonts.istokWeb(
//                     fontSize: 12,
//                     color: const Color(0xFF355F53),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   "KALIMANTAN BARAT",
//                   style: GoogleFonts.istokWeb(
//                     fontSize: 12,
//                     color: const Color(0xFF355F53),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             // SizedBox(height: 20) ini tidak perlu di dalam Row ini, karena akan memakan tempat vertikal
//             const Spacer(),
//             Row(
//               children: [
//                 _buildIconButton(Icons.search),
//                 const SizedBox(width: 15),
//                 _buildIconButton(Icons.notification_add_outlined),
//               ],
//             ),
//           ],
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(50),
//           child: Padding(
//             padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Baca Offline",
//                 style: GoogleFonts.istokWeb(
//                   fontSize: 20,
//                   color: const Color(0xFF355F53),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),
      
//       ),
//       body:  _buildScrollableList()
//     );  
//   }

// Widget _buildIconButton(IconData icon) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: const BoxDecoration(
//             color: Color(0xFFF4F4F4),
//             shape: BoxShape.circle,
//           ),
//         ),
//         Icon(icon, size: 24, color: const Color(0xFF355F53)),
//       ],
//     );
//   }

// Widget _buildScrollableList() {
//   if (_savedArticles.isEmpty) {
//     return Center(child: Text("Belum ada berita yang disimpan."));
//   }
//   return ListView.builder(
//     itemCount: _savedArticles.length,
//     itemBuilder: (context, index) {
//       final article = _savedArticles[index];
//       return ListTile(
//         title: Text(article['title']),
//         subtitle: Text(article['author'] ?? ''),
//         leading: article['urlToImage'] != null
//             ? Image.network(article['urlToImage'], width: 60, height: 60, fit: BoxFit.cover)
//             : Icon(Icons.image),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DetailPage(
//                 title: article['title'],
//                 url: article['url'],
//                 content: article['content'],
//                 publishedAt: article['publishedAt'],
//                 author: article['author'],
//                 urlToImage: article['urlToImage'],
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }




// }