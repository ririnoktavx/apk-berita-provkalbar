import '../repository/simpan_repository.dart';

class IsSave {
  final SimpanRepository repository;

  IsSave(this.repository);

  Future<bool> execute(String id) {
    return repository.isBeritaTersimpan(id);
  }
}
