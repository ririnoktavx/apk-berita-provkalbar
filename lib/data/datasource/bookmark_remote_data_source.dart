// File: lib/data/datasource/bookmark_local_data_source.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> deleteOldDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'bookmark.db');
  await deleteDatabase(path);
}

class BookmarkDataSource {
  static final BookmarkDataSource instance = BookmarkDataSource._init();
  static Database? _database;

  BookmarkDataSource._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookmark.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

   return await openDatabase(
    path,
    version: 15, 
    onCreate: _createDB,
    onUpgrade: (db, oldVersion, newVersion) async {
      
      await db.execute('DROP TABLE IF EXISTS bookmarks');
      await _createDB(db, newVersion);
    },
  );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        title TEXT,
        name TEXT,
        url TEXT,
        author TEXT,
        date TEXT,
        thumbnail TEXT,
        thumbnailLocal TEXT,
        content TEXT,
        contentLocal TEXT
      )
    ''');
  }

  Future<void> insertBookmark(Map<String, dynamic> article) async {
    final db = await instance.database;
    await db.insert('bookmarks', article, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteBookmark(String id) async {
    final db = await instance.database;
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isBookmarked(String id) async {
    final db = await instance.database;
    final maps = await db.query('bookmarks', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await instance.database;
    return await db.query('bookmarks');
  }
  Future<void> clearBookmarks() async {
    final db = await instance.database;
    await db.delete('bookmarks');
  }

 

}
