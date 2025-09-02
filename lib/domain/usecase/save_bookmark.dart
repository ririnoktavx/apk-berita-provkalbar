import '../repository/bookmark_repository.dart';
import '../entity/berita.dart';

class SaveBookmark {
  final BookmarkRepository repository;

  SaveBookmark(this.repository);

  Future<void> execute(Berita berita) async {
    return repository.saveBookmark(berita);
  }
  

    

}
