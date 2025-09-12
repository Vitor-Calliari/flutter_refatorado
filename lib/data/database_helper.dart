import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kDebugMode;
import '../core/database_factory.dart';

// DATABASE HELPER

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'meu_banco.db';
  static const String _table = 'pessoas';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    
    if (kDebugMode) {
      print('DatabaseHelper: Inicializando banco de dados...');
      print('DatabaseHelper: Plataforma atual: ${DatabaseFactoryProvider.platformInfo}');
    }
    
    _db = await _initDB();
    
    if (kDebugMode) {
      print('DatabaseHelper: Banco de dados inicializado com sucesso');
    }
    
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

  final factory = DatabaseFactoryProvider.instance;
  final dbDir = await factory.getDatabasesPath();
  final path = p.join(dbDir, _dbName);
  
  return await factory.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: _onCreate,
    ),
  );
}

  // Método para fechar a conexão (se necessário)
  Future<void> close() async {
    if (_db != null) {
      if (kDebugMode) {
        print('DatabaseHelper: Fechando conexão com o banco de dados');
      }
      await _db!.close();
      _db = null;
    }
  }
  
  // Método para verificar se o banco está conectado
  bool get isConnected => _db != null && _db!.isOpen;
  
  // Método para obter informações da plataforma do banco
  String get platformInfo => DatabaseFactoryProvider.platformInfo;
}
