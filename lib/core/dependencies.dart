import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import 'database_factory.dart';
import '../data/database_helper.dart';
import '../data/pessoa_dao.dart';
import '../repositories/pessoa_repository.dart';
import '../repositories/pessoa_repository_impl.dart';
import '../stores/pessoa_store.dart';

// DEPENDENCY INJECTION

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Database Factory
  getIt.registerLazySingleton<DatabaseFactory>(
    () => DatabaseFactoryProvider.instance,
  );
  
  // DAO
  getIt.registerLazySingleton<PessoaDao>(
    () => PessoaDao(DatabaseHelper.instance),
  );
  
  // Repository
  getIt.registerLazySingleton<PessoaRepository>(
    () => PessoaRepositoryImpl(getIt<PessoaDao>()),
  );
  
  // Store
  getIt.registerLazySingleton<PessoaStore>(
    () => PessoaStore(getIt<PessoaRepository>()),
  );
}

// Método para limpar dependências
void resetDependencies() {
  getIt.reset();
}
