import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/pessoa.dart';


// 2) DATABASE HELPER (Singleton)

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'meu_banco.db';
  static const String _table = 'pessoas';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

Future<Database> _initDB() async {
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_table(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        idade INTEGER NOT NULL
      )
    ''');
  }

  if (kIsWeb) {
    // Web: usar apenas o NOME do banco (IndexedDB). Sem paths.
    return await databaseFactory.openDatabase(
      _dbName, // ex.: "meu_banco.db"
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  } else {
    // Android/iOS/desktop: usar caminho em getDatabasesPath()
    final dbDir = await getDatabasesPath();
    final path = p.join(dbDir, _dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
}

  // CREATE
  Future<int> insert(Pessoa p) async {
    final db = await database;
    return db.insert(_table, p.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // READ by id
  Future<Pessoa?> getById(int id) async {
    final db = await database;
    final result = await db.query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return Pessoa.fromMap(result.first);
  }

  // READ all
  Future<List<Pessoa>> getAll() async {
    final db = await database;
    final maps = await db.query(_table, orderBy: 'id DESC');
    return maps.map((m) => Pessoa.fromMap(m)).toList();
  }

  // UPDATE
  Future<int> update(Pessoa p) async {
    if (p.id == null) return 0;
    final db = await database;
    return db.update(_table, p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
