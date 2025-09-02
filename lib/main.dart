import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'data/datasource/berita_remote_data_source.dart';
import 'data/repository/berita_repository_impl.dart';
import 'domain/usecase/get_berita.dart';
import 'presentation/provider/berita_provider.dart';

import 'data/datasource/bookmark_remote_data_source.dart';
import 'data/repository/bookmark_repository_impl.dart';
import 'domain/usecase/save_bookmark.dart';
import 'domain/usecase/delete_bookmark.dart';
import 'domain/usecase/is_bookmarked.dart';
import 'domain/usecase/get_bookmarks.dart';
import 'presentation/provider/bookmark_provider.dart';

import 'data/datasource/simpan_local_data_source.dart';
import 'data/repository/simpan_repository_impl.dart';
import 'domain/usecase/save_simpan.dart'; 
import 'domain/usecase/delete_simpan.dart';
import 'domain/usecase/is_simpan.dart';
import 'domain/usecase/get_simpan.dart';
import 'presentation/provider/simpan_provider.dart';

import 'presentation/pages/navigation_page.dart';




void main() {

  // Setup dependency
  final remoteDataSource = BeritaRemoteDataSource();
  final beritaRepository = BeritaRepositoryImpl(remoteDataSource);
  final getBerita = GetBerita(beritaRepository);

  final bookmarkLocalDataSource = BookmarkDataSource.instance;
  final bookmarkRepository = BookmarkRepositoryImpl(bookmarkLocalDataSource);
  final saveBookmark = SaveBookmark(bookmarkRepository);
  final deleteBookmark = DeleteBookmark(bookmarkRepository);
  final isBookmarked = IsBookmarked(bookmarkRepository);

  final simpanLocalDataSource = SimpanLocalDataSource.instance;
  final simpanRepository = SimpanRepositoryImpl(simpanLocalDataSource);
  final saveSimpan = SaveBerita(simpanRepository);
  final deleteSimpan = DeleteSimpan(simpanRepository);
  final isSaved = IsSave(simpanRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BeritaProvider(getBerita)..fetchBerita(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookmarkProvider(
            saveBookmark: saveBookmark,
            deleteBookmark: deleteBookmark,
            isBookmarkedUseCase: isBookmarked,
            getBookmarks: GetBookmarks(bookmarkRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SimpanProvider(
            saveSimpan: saveSimpan,
            deleteSimpan: deleteSimpan,
            isSavedUseCase: isSaved,
            getSimpan: GetSimpan(simpanRepository),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Berita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NavigationPage(),
    );
  }
}
