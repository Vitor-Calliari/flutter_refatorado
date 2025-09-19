import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import 'database_factory.dart';
import '../data/database_helper.dart';
import '../data/pessoa_dao.dart';
import '../repositories/pessoa_repository.dart';
import '../repositories/pessoa_repository_impl.dart';
import '../stores/pessoa_store.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Database Factory
  getIt.registerLazySingleton<DatabaseFactory>(
    () => DatabaseFactoryProvider.instance,
  );

  // DatabaseHelper agora recebe a factory injetada
  getIt.registerLazySingleton<DatabaseHelper>(
    () => DatabaseHelper(getIt<DatabaseFactory>()),
  );

  // DAO
  getIt.registerLazySingleton<PessoaDao>(
    () => PessoaDao(getIt<DatabaseHelper>()),
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

void resetDependencies() {
  getIt.reset();
}
