import '../repository/simpan_repository.dart';
import '../entity/berita.dart';
class SaveBerita {
  final SimpanRepository repository;

  SaveBerita(this.repository);
  Future<void> call(Berita berita) async {
    await repository.simpanBerita(berita);
  }
}
