import '../models/pessoa.dart';
import '../data/database_helper.dart';
abstract class IPessoasRepository {
  Future<List<Pessoa>> getAll();
  Future<int> insert(Pessoa p);
  Future<int> update(Pessoa p);
  Future<int> delete(int id);
}

