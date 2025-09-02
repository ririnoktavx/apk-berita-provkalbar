import '../entity/berita.dart';

abstract class BeritaRepository {
  Future<List<Berita>> getBerita([String keyword = '']);
 
}
