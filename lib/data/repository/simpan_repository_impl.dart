import '../../domain/entity/berita.dart';
import '../../domain/repository/simpan_repository.dart';
import '../datasource/simpan_local_data_source.dart';
import '../model/berita_model.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SimpanRepositoryImpl implements SimpanRepository {
  final SimpanLocalDataSource localDataSource;

  SimpanRepositoryImpl(this.localDataSource);

  @override
  @override
  Future<List<Berita>> getBerita() async {
    final listMap = await localDataSource.getBerita();
    final models = listMap.map((json) => BeritaModel.fromJson(json)).toList();
    return models.map((model) => model.toEntity()).toList();
  }

@override
Future<void> simpanBerita(Berita berita) async {
  final model = BeritaModel.fromEntity(berita);
  try {
    await localDataSource.insertBerita(model.toJson());
  } catch (e) {
    if (e.toString().contains('Disk full') || e.toString().contains('No space left')) {
      throw Exception('Memori perangkat penuh, tidak bisa menyimpan berita.');
    }
    throw Exception('Gagal menyimpan berita: $e');
  }
}

@override
Future<String> downloadAndSaveThumbnail(String url, String id) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/thumbnail_$id.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    }
    throw Exception("Gagal download gambar");
  } catch (e) {
    if (e.toString().contains('Disk full') || e.toString().contains('No space left')) {
      throw Exception('Memori perangkat penuh, tidak bisa menyimpan thumbnail.');
    }
    throw Exception("Error download thumbnail: $e");
  }
}


  @override
  Future<void> hapusBerita(String id) async {
    await localDataSource.deleteBerita(id);
  }

  @override
  Future<void> hapusSemuaBerita() async {
    await localDataSource.clearSavedBerita();
  }

  @override
  Future<bool> isBeritaTersimpan(String id) async {
    return await localDataSource.isSaved(id);
  }


  


 



  
}
