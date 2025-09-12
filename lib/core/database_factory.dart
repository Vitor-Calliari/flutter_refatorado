import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:io' show Platform;

import 'package:sqflite_common_ffi/sqflite_ffi.dart' show sqfliteFfiInit, databaseFactoryFfi;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' show databaseFactoryFfiWeb;

// DATABASE FACTORY

enum DatabasePlatform {
  web,
  mobile,
  desktop,
}

abstract class DatabaseFactoryProvider {
  static DatabaseFactory? _instance;
  static DatabasePlatform? _currentPlatform;
  
  static DatabaseFactory get instance {
    if (_instance != null) return _instance!;
    
    _instance = _createFactory();
    return _instance!;
  }
  
  static DatabasePlatform get currentPlatform {
    if (_currentPlatform != null) return _currentPlatform!;
    
    _currentPlatform = _detectPlatform();
    return _currentPlatform!;
  }
  
  static DatabasePlatform _detectPlatform() {
    if (kIsWeb) {
      return DatabasePlatform.web;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return DatabasePlatform.desktop;
    } else {
      return DatabasePlatform.mobile;
    }
  }
  
  static DatabaseFactory _createFactory() {
    final platform = currentPlatform;
    
    switch (platform) {
      case DatabasePlatform.web:
        // Web: sqflite_common_ffi_web para WASM
        if (kDebugMode) {
          print('DatabaseFactory: Inicializando para Web (WASM)');
        }
        return databaseFactoryFfiWeb;
        
      case DatabasePlatform.desktop:
        // Desktop: sqflite_common_ffi
        if (kDebugMode) {
          print('DatabaseFactory: Inicializando para Desktop (FFI)');
        }
        sqfliteFfiInit();
        return databaseFactoryFfi;
        
      case DatabasePlatform.mobile:
        // Mobile: sqflite
        if (kDebugMode) {
          print('DatabaseFactory: Inicializando para Mobile (SQLite nativo)');
        }
        return databaseFactory;
    }
  }
  
  // resetar a factory
  static void reset() {
    _instance = null;
    _currentPlatform = null;
  }
  
  // verificar se a plataforma suporta banco de dados
  static bool get isSupported {
    try {
      instance;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // obter informações da plataforma
  static String get platformInfo {
    final platform = currentPlatform;
    switch (platform) {
      case DatabasePlatform.web:
        return 'Web (sqflite_common_ffi_web)';
      case DatabasePlatform.desktop:
        return 'Desktop (sqflite_common_ffi)';
      case DatabasePlatform.mobile:
        return 'Mobile (sqflite)';
    }
  }
}
