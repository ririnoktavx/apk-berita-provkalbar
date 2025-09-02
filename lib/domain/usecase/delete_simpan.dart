import '../repository/simpan_repository.dart';

class DeleteSimpan {
  final SimpanRepository repository;

  DeleteSimpan(this.repository);

  Future<void> execute(String id) {
    return repository.hapusBerita(id);
  }
  Future<void> deleteAllSavedArticles() {
    return repository.hapusSemuaBerita();
  }
}
