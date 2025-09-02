// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:projec_pkl/API/api_service.dart';
// import 'package:projec_pkl/detail_berita.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   int selectedIndex = 0;
//   late final ApiService apiService;
//   List<dynamic> _beritaTerbaru = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     apiService = ApiService('https://awdiv2.kalbarprov.go.id/api/all_kalbar_article');
//     _fetchBeritaTerbaru();
//   }

//   Future<void> _fetchBeritaTerbaru() async {
//     try {
//       final data = await apiService.fetchArticles();
//       setState(() {
//         // Ambil 5 berita terbaru untuk carousel, atau sesuaikan jumlahnya
//         _beritaTerbaru = data.take(5).toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       // Handle error fetching data for carousel
//       print('Error fetching latest news for carousel: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
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
//                 "Berita Terkini",
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
//       body: Column(
//         children: [
//           _isLoading
//               ? const SizedBox(height: 213, child: Center(child: CircularProgressIndicator()))
//               : CarouselSlider(
//                   options: CarouselOptions(
//                     height: 213,
//                     enlargeCenterPage: true,
//                     autoPlay: true,
//                     autoPlayInterval: const Duration(seconds: 3),
//                     viewportFraction: 0.8,
//                   ),
//                   items: _beritaTerbaru.map((berita) {
//                     return GestureDetector(
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => DetailPage(
//                             title: berita['title'] ?? '',
//                             author: berita['author'] ?? '',
//                             publishedAt: berita['date'] ?? '',
//                             content: berita['content'] ?? '',
//                             urlToImage: getThumbnailUrl(berita['thumbnail']),
//                           ),
//                         ),
//                       ),
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 5),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
                         
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Stack(
//                             fit: StackFit.expand,
//                             children: [
//                               Image.network(
//                                 getThumbnailUrl(berita['thumbnail']),
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Image.network('https://via.placeholder.com/400', fit: BoxFit.cover), // Placeholder jika gambar error
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [
//                                       Colors.transparent,           // Atas transparan
//                                       Color(0xCC013D20),
//                                     ]
//                                   )
//                                 ),
//                               ),
//                               Align(
//                                 alignment: Alignment.bottomLeft,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(10),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         berita['date'] ?? '',
//                                         style: GoogleFonts.istokWeb(
//                                           color: Colors.white70,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                    const SizedBox(height: 4),
//                                   Text(
//                                     berita['title'] ?? '',
//                                     style: GoogleFonts.istokWeb(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10,),
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                     ],
//                                 ),
//                                 ),

//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//           const SizedBox(height: 10),
//           // _buildUncontainedCarousel(), // Ini tetap dikomentari sesuai kode asli Anda
//           const SizedBox(height: 20),
//           Expanded(
//             child: _buildScrollableList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIconButton(IconData icon) {
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

//   // Widget _buildUncontainedCarousel() {
//   //   final List<String> customTexts = [
//   //     'Semua',
//   //     'Teknologi',
//   //     'Pendidikan',
//   //     'Kesehatan',
//   //     'Budaya',
//   //   ];

//   //   return CarouselSlider(
//   //     options: CarouselOptions(
//   //       height: 29,
//   //       viewportFraction: 0.2,
//   //     ),
//   //     items: List<Widget>.generate(customTexts.length, (int index) {
//   //       return GestureDetector(
//   //         onTap: () {
//   //           setState(() {
//   //             selectedIndex = index;
//   //           });
//   //         },
//   //         child: Container(
//   //           margin: const EdgeInsets.symmetric(horizontal: 5.0),
//   //           decoration: BoxDecoration(
//   //             borderRadius: BorderRadius.circular(15),
//   //             color: selectedIndex == index
//   //                 ? const Color(0xFF355F53)
//   //                 : const Color(0xFFF4F4F4),
//   //           ),
//   //           child: Center(
//   //             child: Text(
//   //               customTexts[index],
//   //               style: GoogleFonts.istokWeb(
//   //                 color: selectedIndex == index
//   //                     ? const Color(0xFFFFFFFF)
//   //                     : const Color(0xFFBEBEBE),
//   //                 fontSize: 10,
//   //                 fontWeight: FontWeight.bold,
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       );
//   //     }),
//   //   );
//   // }

//   String getThumbnailUrl(String? thumbnail) {
//     if (thumbnail == null || thumbnail.isEmpty) {
//       // Menggunakan placeholder yang lebih umum atau yang sesuai dengan desain Anda
//       return 'https://via.placeholder.com/100x85'; // Contoh placeholder
//     }
//     // Memastikan URL adalah absolut
//     return thumbnail.startsWith('http') ? thumbnail : 'https://kalbarprov.go.id/berita/thumbnails/$thumbnail';
//   }

//   Widget _buildScrollableList() {
//     return Column(
//       children: [
//         Align(
//           alignment: Alignment.topRight,
//           child: Padding(
//             padding: const EdgeInsets.only(right: 8.0, top: 4.0),
//             child: Text(
//               'Tampilkan Semua',
//               style: GoogleFonts.istokWeb(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: FutureBuilder(
//             future: apiService.fetchArticles(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               } else if (!snapshot.hasData || snapshot.data == null || (snapshot.data as List).isEmpty) {
//                 return const Center(child: Text('Tidak ada data'));
//               } else {
//                 final List<dynamic> articles = snapshot.data as List<dynamic>;
//                 return ListView.builder(
//                   itemCount: articles.length,
//                   itemBuilder: (context, index) {
//                     final article = articles[index];
//                     return ListTile(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DetailPage(
//                               title: article['title'] ?? '',
//                               author: article['author'] ?? '',
//                               publishedAt: article['date'] ?? '',
//                               content: article['content'] ?? '',
//                               urlToImage: getThumbnailUrl(article['thumbnail']),
//                             ),
//                           ),
//                         );
//                       },
//                       leading: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.network(
//                           getThumbnailUrl(article['thumbnail']),
//                           width: 100,
//                           height: 85,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Icon(Icons.broken_image, size: 85), // Placeholder jika gambar error
//                         ),
//                       ),
//                       title: Text(
//                         article['title'] ?? '',
//                         style: GoogleFonts.istokWeb(
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               const Icon(Icons.date_range, size: 16, color: Color(0xFFBEBEBE)),
//                               const SizedBox(width: 8),
//                               Text(
//                                 article['date'] ?? '',
//                                 style: GoogleFonts.istokWeb(
//                                   fontSize: 9,
//                                   color: const Color(0xFFBEBEBE),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               const Icon(Icons.person, size: 16, color: Color(0xFFBEBEBE)),
//                               const SizedBox(width: 8),
//                               Text(
//                                 article['author'] ?? '',
//                                 style: GoogleFonts.istokWeb(
//                                   fontSize: 9,
//                                   color: const Color(0xFFBEBEBE),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }