import 'package:flutter/material.dart';
import '../../../domain/entity/berita.dart';
import '../../../domain/usecase/save_simpan.dart';
import '../../../domain/usecase/delete_simpan.dart';
import '../../../domain/usecase/is_simpan.dart';
import '../../../domain/usecase/get_simpan.dart';

class SimpanProvider extends ChangeNotifier {
  final SaveBerita saveSimpan;
  final DeleteSimpan deleteSimpan;
  final IsSave isSavedUseCase;
  final GetSimpan getSimpan;

  SimpanProvider({
    required this.saveSimpan,
    required this.deleteSimpan,
    required this.isSavedUseCase,
    required this.getSimpan,
  });

  List<Berita> _beritaTersimpan = [];
  bool _isLoading = false;

  List<Berita> get beritaTersimpan => _beritaTersimpan;
  bool get isLoading => _isLoading;

  Future<void> simpanBerita(Berita berita) async {
    await saveSimpan.call(berita);
    await loadSavedArticles();
    notifyListeners();
  }

  Future<void> hapusBerita(String id) async {
    await deleteSimpan.execute(id);
    await loadSavedArticles();
    notifyListeners();
  }

  Future<bool> isBeritaTersimpan(String id) async {
    return await isSavedUseCase.execute(id);
   
  }

 Future<void> loadSavedArticles() async {
    _isLoading = true;
    notifyListeners();

    _beritaTersimpan = await getSimpan.execute();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> hapusSemuaBerita() async {
    for (final berita in _beritaTersimpan) {
      await deleteSimpan.execute(berita.id);
      notifyListeners();
    }
    await loadSavedArticles();
    
    notifyListeners();
  }
  

}