import '../../domain/repository/bookmark_repository.dart';
import '../../domain/entity/berita.dart';
import '../datasource/bookmark_remote_data_source.dart';
import '../model/berita_model.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkDataSource localDataSource;

  BookmarkRepositoryImpl(this.localDataSource);

  @override
Future<void> saveBookmark(Berita berita) async {
  final model = BeritaModel(
    id: berita.id,
    title: berita.title,
    author: berita.author,
    date: berita.date,
    thumbnail: berita.thumbnail,
    url: berita.url,
    content: berita.content,
  );
  await localDataSource.insertBookmark(model.toJson());
}


  @override
  Future<void> deleteBookmark(String id) async {
    await localDataSource.deleteBookmark(id);
  }

  @override
  Future<bool> isBookmarked(String id) async {
    return await localDataSource.isBookmarked(id);
  }

  @override
  Future<List<Berita>> getBookmarks() async {
    final data = await localDataSource.getBookmarks();
    return data.map((json) => BeritaModel.fromJson(json).toEntity()).toList();
  }
  @override
  Future<void> deleteAllBookmarks() async {
    await localDataSource.clearBookmarks();
  }
}
