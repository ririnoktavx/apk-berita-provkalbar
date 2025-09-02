import '../entity/berita.dart';
import '../repository/berita_repository.dart';

class GetBerita {
  final BeritaRepository repository;

  GetBerita(this.repository);

  Future<List<Berita>> execute([String keyword = ''])  {
    return repository.getBerita(keyword);
  }
}
