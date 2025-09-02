import '../repository/bookmark_repository.dart';

class DeleteBookmark {
  final BookmarkRepository repository;

  DeleteBookmark(this.repository);

  Future<void> execute(String id) {
    return repository.deleteBookmark(id);
  }
  Future<void> deleteAllBookmarks() {
    return repository.deleteAllBookmarks();
  }
}
