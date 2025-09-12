import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';

// DAO
class PessoaDao {
  static const String _table = 'pessoas';
  
  // CREATE
  Future<int> insert(Map<String, dynamic> pessoa) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert(_table, pessoa, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // READ by id
  Future<Map<String, dynamic>?> findById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      _table, 
      where: 'id = ?', 
      whereArgs: [id], 
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  // READ all
  Future<List<Map<String, dynamic>>> findAll() async {
    final db = await DatabaseHelper.instance.database;
    return db.query(_table, orderBy: 'id DESC');
  }

  // READ by name
  Future<List<Map<String, dynamic>>> findByName(String nome) async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      _table,
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
      orderBy: 'nome ASC',
    );
  }

  // UPDATE
  Future<int> update(int id, Map<String, dynamic> pessoa) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      _table, 
      pessoa, 
      where: 'id = ?', 
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> deleteById(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  // COUNT
  Future<int> count() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // EXISTS
  Future<bool> exists(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      _table,
      columns: ['1'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
