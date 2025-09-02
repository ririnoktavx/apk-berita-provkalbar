import '../repository/bookmark_repository.dart';

class IsBookmarked {
  final BookmarkRepository repository;

  IsBookmarked(this.repository);

  Future<bool> execute(String id) {
    return repository.isBookmarked(id);
  }
}
