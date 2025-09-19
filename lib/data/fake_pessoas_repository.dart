import 'package:exemplo/models/pessoa.dart';
import 'package:collection/collection.dart';
import 'package:exemplo/repositories/i_pessoas_repository.dart';

class FakePessoasRepository implements IPessoasRepository {
  final List<Pessoa> _data = [];

  @override
  Future<List<Pessoa>> getAll() async => _data;

  @override
  Future<int> insert(Pessoa p) async {
    _data.add(p);
    return 1;
  }

  @override
  Future<int> update(Pessoa p) async {
    final index = _data.indexWhere((element) => element.id == p.id);
    if (index != -1) _data[index] = p;
    return 1;
  }

  @override
  Future<int> delete(int id) async {
    _data.removeWhere((element) => element.id == id);
    return 1;
  }
}
