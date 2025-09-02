import '../../domain/entity/berita.dart';
import '../../domain/repository/berita_repository.dart';
import '../datasource/berita_remote_data_source.dart';
// import '../model/berita_model.dart';

class BeritaRepositoryImpl implements BeritaRepository {
  final BeritaRemoteDataSource remoteDataSource;

  BeritaRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Berita>> getBerita([String keyword = '']) async {
    final beritaModelList = await remoteDataSource.fetchBerita(keyword);
    return beritaModelList.map((model) => model.toEntity()).toList();
  }
  
}
