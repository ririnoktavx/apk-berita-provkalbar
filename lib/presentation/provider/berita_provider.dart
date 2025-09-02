import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../domain/entity/berita.dart';
import '../../../domain/usecase/get_berita.dart';
import '../../../data/model/berita_model.dart';
import '../../../data/datasource/simpan_local_data_source.dart';

class BeritaProvider extends ChangeNotifier {
  final GetBerita getBerita;

  BeritaProvider(this.getBerita);

  List<Berita> _beritaList = [];
  List<Berita> get beritaList => _beritaList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isOffline = false; // 👈 tambahan
  bool get isOffline => _isOffline;

  List<Berita> cachedBeritaList = [];

  Future<void> fetchBerita([String keyword = '']) async {
    _isLoading = true;
    _isOffline = false; // reset dulu
    notifyListeners();

    try {
      final connectivity = await Connectivity().checkConnectivity();

      if (connectivity != ConnectivityResult.none) {
        // ONLINE → API
        final result = await getBerita.execute(keyword);
        _beritaList = result;
        cachedBeritaList = result;

        final db = SimpanLocalDataSource.instance;
        await db.clearCache();
        for (final berita in result) {
          final model = BeritaModel.fromEntity(berita);
          await db.insertCacheBerita(model.toJson());
        }
      } else {
        // OFFLINE → Cache
        _isOffline = true; // 👈 tandai kalau offline
        await loadFromLocalCache();
      }
    } catch (e) {
      _isOffline = true; // 👈 fallback offline
      await loadFromLocalCache();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFromLocalCache() async {
    final db = SimpanLocalDataSource.instance;
    final data = await db.getCachedBerita();

    _beritaList = data.map((json) => BeritaModel.fromJson(json).toEntity()).toList();
    cachedBeritaList = _beritaList;
  }

  void loadFromMemoryCache() {
    _beritaList = cachedBeritaList;
    _isLoading = false;
    notifyListeners();
  }
}
