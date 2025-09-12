import '../core/result.dart';
import '../models/pessoa.dart';

// Interface do Repository 
abstract class PessoaRepository {
  Future<Result<int>> save(Pessoa pessoa);
  Future<Result<Pessoa?>> findById(int id);
  Future<Result<List<Pessoa>>> findAll();
  Future<Result<List<Pessoa>>> findByName(String nome);
  Future<Result<bool>> update(Pessoa pessoa);
  Future<Result<bool>> delete(int id);
  Future<Result<int>> count();
  Future<Result<bool>> exists(int id);
}
