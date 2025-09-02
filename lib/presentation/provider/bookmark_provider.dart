import 'package:flutter/material.dart';
import '../../../domain/entity/berita.dart';
import '../../../domain/usecase/save_bookmark.dart';
import '../../../domain/usecase/delete_bookmark.dart';
import '../../../domain/usecase/is_bookmarked.dart';
import '../../../domain/usecase/get_bookmarks.dart';

class BookmarkProvider extends ChangeNotifier {
  final SaveBookmark saveBookmark;
  final DeleteBookmark deleteBookmark;
  final IsBookmarked isBookmarkedUseCase;
  final GetBookmarks getBookmarks;

  BookmarkProvider({
    required this.saveBookmark,
    required this.deleteBookmark,
    required this.isBookmarkedUseCase,
    required this.getBookmarks,
  });

  List<Berita> _bookmarkedArticles = [];
  List<Berita> get bookmarkedArticles => _bookmarkedArticles;

  Future<void> addBookmark(Berita berita) async {
    await saveBookmark.execute(berita);
    await loadBookmarks();
  }

  Future<void> removeBookmark(String id) async {
    await deleteBookmark.execute(id);
    await loadBookmarks();
  }

  Future<bool> isBookmarked(String id) async {
    return await isBookmarkedUseCase.execute(id);
  }

  Future<void> loadBookmarks() async {
    _bookmarkedArticles = await getBookmarks.execute();
    notifyListeners();
  }
  Future<void> deleteAllBookmarks() async {
    for (final berita in _bookmarkedArticles) {
      await deleteBookmark.execute(berita.id);
    }
    await loadBookmarks();
  }
}
