import '../entity/berita.dart';
import '../repository/bookmark_repository.dart';

class GetBookmarks {
  final BookmarkRepository repository;

  GetBookmarks(this.repository);

  Future<List<Berita>> execute() {
    return repository.getBookmarks();
  }
}
