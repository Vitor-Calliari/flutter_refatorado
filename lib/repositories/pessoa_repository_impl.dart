import '../core/result.dart';
import '../data/pessoa_dao.dart';
import '../models/pessoa.dart';
import 'pessoa_repository.dart';

// Implementação do Repository
class PessoaRepositoryImpl implements PessoaRepository {
  final PessoaDao _dao;

  const PessoaRepositoryImpl(this._dao);

  @override
  Future<Result<int>> save(Pessoa pessoa) async {
    try {
      if (pessoa.nome.trim().isEmpty) {
        return const Failure('Nome não pode estar vazio');
      }
      if (pessoa.idade < 0 || pessoa.idade > 150) {
        return const Failure('Idade deve estar entre 0 e 150 anos');
      }

      final id = await _dao.insert(pessoa.toMap());
      return Success(id);
    } catch (e) {
      return Failure('Erro ao salvar pessoa: ${e.toString()}', Exception(e.toString()));
    }
  }

  @override
  Future<Result<Pessoa?>> findById(int id) async {
    try {
      if (id <= 0) {
        return const Failure('ID deve ser maior que zero');
      }

      final map = await _dao.findById(id);
      if (map == null) {
        return const Success(null);
      }

      final pessoa = Pessoa.fromMap(map);
      return Success(pessoa);
    } catch (e) {
      return Failure('Erro ao buscar pessoa por ID: ${e.toString()}', Exception(e.toString()));
    }
  }

  @override
  Future<Result<List<Pessoa>>> findAll() async {
    try {
      final maps = await _dao.findAll();
      final pessoas = maps.map((map) => Pessoa.fromMap(map)).toList();
      return Success(pessoas);
    } catch (e) {
      return Failure('Erro ao buscar todas as pessoas: ${e.toString()}', Exception(e.toString()));
    }
  }

  @override
  Future<Result<List<Pessoa>>> findByName(String nome) async {
    try {
      if (nome.trim().isEmpty) {
        return const Failure('Nome para busca não pode estar vazio');
      }

      final maps = await _dao.findByName(nome.trim());
      final pessoas = maps.map((map) => Pessoa.fromMap(map)).toList();
      return Success(pessoas);
    } catch (e) {
      return Failure('Erro ao buscar pessoas por nome: ${e.toString()}', Exception(e.toString()));
    }
  }

  @override
  Future<Result<bool>> update(Pessoa pessoa) async {
    try {
      if (pessoa.id == null || pessoa.id! <= 0) {
        return const Failure('ID inválido para atualização');
      }
      if (pessoa.nome.trim().isEmpty) {
        return const Failure('Nome não pode estar vazio');
      }
      if (pessoa.idade < 0 || pessoa.idade > 150) {
        return const Failure('Idade deve estar entre 0 e 150 anos');
      }

      final exists = await _dao.exists(pessoa.id!);
      if (!exists) {
        return const Failure('Pessoa não encontrada para atualização');
      }

      final rowsAffected = await _dao.update(pessoa.id!, pessoa.toMap());
      return Success(rowsAffected > 0);
    } catch (e) {
      return Failure('Erro ao atualizar pessoa: ${e.toString()}', Exception(e.toString()));
    }
  }

  @override
  Future<Result<bool>> delete(int id) async {
    try {
      if (id <= 0) {
        return const Failure('ID deve ser maior que zero');
      }

      final exists = await _dao.exists(id);
      if (!exists) {
        return const Failure('Pessoa não encontrada para exclusão');
      }

      final rowsAffected = await _dao.deleteById(id);
      return Success(rowsAffected > 0);
    } catch (e) {
      return Failure('Erro ao deletar pessoa: ${e.toString()}', Exception(e.toString()));
    }
  }

  @override
  Future<Result<int>> count() async {
    try {
      final total = await _dao.count();
      return Success(total);
    } catch (e) {
      return Failure('Erro ao contar pessoas: ${e.toString()}', Exception(e.toString()));
    }
  }

  @override
  Future<Result<bool>> exists(int id) async {
    try {
      if (id <= 0) {
        return const Failure('ID deve ser maior que zero');
      }

      final exists = await _dao.exists(id);
      return Success(exists);
    } catch (e) {
      return Failure('Erro ao verificar se pessoa existe: ${e.toString()}', Exception(e.toString()));
    }
  }
}
