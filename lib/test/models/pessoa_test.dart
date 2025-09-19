import 'package:flutter_test/flutter_test.dart';
import 'package:exemplo/models/pessoa.dart';

void main() {
  group('Pessoa model', () {
    test('toMap/fromMap should work correctly', () {
      final p = Pessoa(id: 1, nome: 'Ana', idade: 30);
      final map = p.toMap();
      expect(map['nome'], 'Ana');
      expect(map['idade'], 30);

      final p2 = Pessoa.fromMap({'id': 1, 'nome': 'Ana', 'idade': 30});
      expect(p2.nome, 'Ana');
      expect(p2.idade, 30);
      expect(p2.id, 1);
    });

    test('copyWith should override fields', () {
      final p = Pessoa(nome: 'Ana', idade: 30);
      final p2 = p.copyWith(nome: 'Bia', idade: 25);
      expect(p2.nome, 'Bia');
      expect(p2.idade, 25);
      expect(p2.id, isNull);
    });
  });
}
