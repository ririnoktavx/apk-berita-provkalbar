import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:html/parser.dart' as html_parser;




Future<void> deleteOldSavedDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'simpan.db');
  await deleteDatabase(path);
}


class SimpanLocalDataSource {
  static final SimpanLocalDataSource instance = SimpanLocalDataSource._init();
  static Database? _database;

  SimpanLocalDataSource._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('simpan_berita.db');

    return _database!;
  }


  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
    path,
    version: 16, // ubah versi
    onCreate: _createDB,
    onUpgrade: (db, oldVersion, newVersion) async {
      await db.execute('DROP TABLE IF EXISTS simpan');
      await db.execute('DROP TABLE IF EXISTS cache');
      

      await _createDB(db, newVersion);
    },
  );

  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE simpan (
        id TEXT PRIMARY KEY,
        title TEXT,
        url TEXT,
        content TEXT,
        contentLocal TEXT,
        date TEXT,
        author TEXT,
        thumbnail TEXT,
        thumbnailLocal TEXT
        
        
        
      )
    ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS cache  (
    id TEXT PRIMARY KEY,
    title TEXT,
    url TEXT,
    content TEXT,
    contentLocal TEXT,
    date TEXT,
    author TEXT,
    thumbnail TEXT,
    thumbnailLocal TEXT
    
    
   
  )
''');

  }


Future<bool> isSaved(String id) async {
    final db = await instance.database;
    final maps = await db.query('simpan', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }
  
  Future<void> insertBerita(Map<String, dynamic> berita) async {
    final db = await instance.database;
    await db.insert('simpan', berita, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String> downloadAndSaveThumbnail(String imageUrl, String fileName) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  } catch (e) {
    throw Exception('Gagal simpan thumbnail: $e');
  }
}

Future<String> processContentAndSaveImages(String content, String beritaId) async {
  try {
    final document = html_parser.parse(content);

    final images = document.getElementsByTagName('img');
    for (var img in images) {
      final url = img.attributes['src'];
      if (url != null && url.startsWith('http')) {
        try {
          final localPath = await _downloadAndSaveContentImage(url, beritaId);
          img.attributes['src'] = localPath; // ganti src ke file lokal
        } catch (e) {
          print("Gagal download gambar konten: $e");
        }
      }
    }

    return document.outerHtml;
  } catch (e) {
    throw Exception("Gagal memproses content: $e");
  }
}

Future<String> _downloadAndSaveContentImage(String url, String beritaId) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${beritaId}_${url.hashCode}.jpg';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  } else {
    throw Exception("Gagal download gambar dari $url");
  }
}








 
  Future<List<Map<String, dynamic>>> getBerita() async {
    final db = await instance.database;
    return await db.query('simpan');
  }


   Future<void> deleteBerita(String id) async {
    final db = await instance.database;
    await db.delete('simpan', where: 'id = ?', whereArgs: [id]);
  }




Future<void> updateThumbnailPath(String id, String path) async {
  final db = await database;
  await db.update(
    'berita',
    {'thumbnailLocal': path},
    where: 'id = ?',
    whereArgs: [id],
  );
}


Future<void> clearSavedBerita() async {
    final db = await instance.database;
    await db.delete('simpan');
  }

  Future<void> deleteBeritaById(String id) async {
  final db = await database;
  await db.delete('berita', where: 'id = ?', whereArgs: [id]);
}






  

  









  Future<void> insertCacheBerita(Map<String, dynamic> berita) async {
  final db = await instance.database;
  await db.insert('cache', berita, conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<Map<String, dynamic>>> getCachedBerita() async {
  final db = await instance.database;
  return await db.query('cache');
}

Future<void> clearCache() async {
  final db = await instance.database;
  await db.delete('cache');
}


}
