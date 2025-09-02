import '../entity/berita.dart';

abstract class BookmarkRepository {
  Future<void> saveBookmark(Berita berita);
  Future<void> deleteBookmark(String id);
  Future<bool> isBookmarked(String id);
  Future<List<Berita>> getBookmarks();
  Future<void> deleteAllBookmarks();
}
