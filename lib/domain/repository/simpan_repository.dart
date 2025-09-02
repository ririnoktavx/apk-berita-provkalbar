import '../entity/berita.dart';

abstract class SimpanRepository {
Future<List<Berita>> getBerita();
  Future<void> simpanBerita(Berita berita);
  Future<bool> isBeritaTersimpan(String id);
  Future<void> hapusBerita(String id);
  Future<void> hapusSemuaBerita();
  Future<String> downloadAndSaveThumbnail(String url, String id);
}


