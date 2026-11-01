import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/case_model.dart';

class DBService {
  static final DBService instance = DBService._init();
  static Database? _database;

  DBService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lawyer_diary.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        court TEXT,
        stage TEXT,
        notes TEXT,
        hearingDate TEXT,
        reminderTime TEXT
      )
    ''');
  }

  Future<int> insertCase(CaseModel c) async {
    final db = await instance.database;
    return await db.insert('cases', c.toMap());
  }

  Future<List<CaseModel>> getAllCases() async {
    final db = await instance.database;
    final result = await db.query('cases', orderBy: 'hearingDate ASC');
    return result.map((m) => CaseModel.fromMap(m)).toList();
  }

  Future<int> updateCase(CaseModel c) async {
    final db = await instance.database;
    return await db.update('cases', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> deleteCase(int id) async {
    final db = await instance.database;
    return await db.delete('cases', where: 'id = ?', whereArgs: [id]);
  }
}