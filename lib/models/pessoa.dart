// 1) MODELO

class Pessoa {
  final int? id; // id opcional para permitir AUTOINCREMENT
  final String nome;
  final int idade;

  const Pessoa({this.id, required this.nome, required this.idade});

  Pessoa copyWith({int? id, String? nome, int? idade}) {
    return Pessoa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      idade: idade ?? this.idade,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nome': nome,
      'idade': idade,
    };
    if (id != null) map['id'] = id; // só inclui se existir
    return map;
  }

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    return Pessoa(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      idade: (map['idade'] as num).toInt(),
    );
  }

  @override
  String toString() => 'Pessoa(id: $id, nome: $nome, idade: $idade)';
}

