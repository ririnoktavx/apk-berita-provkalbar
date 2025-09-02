import '../entity/berita.dart';
import '../repository/simpan_repository.dart';

class GetSimpan {
  final SimpanRepository repository;

  GetSimpan(this.repository);

  Future<List<Berita>> execute() {
    return repository.getBerita();
  }

}
