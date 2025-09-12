import 'package:flutter/foundation.dart';
import '../core/result.dart';
import '../models/pessoa.dart';
import '../repositories/pessoa_repository.dart';

// STORE

class PessoaStore extends ChangeNotifier {
  final PessoaRepository _repository;
  
  PessoaStore(this._repository);
  
  // Estado
  List<Pessoa> _pessoas = [];
  bool _isLoading = false;
  String? _errorMessage;
  Pessoa? _editingPessoa;
  
  // Getters
  List<Pessoa> get pessoas => List.unmodifiable(_pessoas);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Pessoa? get editingPessoa => _editingPessoa;
  bool get isEditing => _editingPessoa != null;
  
  // Métodos
  Future<void> loadPessoas() async {
    _setLoading(true);
    _clearError();
    
    final result = await _repository.findAll();
    result.fold(
      onSuccess: (pessoas) {
        _pessoas = pessoas;
        notifyListeners();
      },
      onFailure: (message, _) {
        _setError('Erro ao carregar pessoas: $message');
      },
    );
    
    _setLoading(false);
  }
  
  Future<void> savePessoa(String nome, int idade) async {
    if (nome.trim().isEmpty) {
      _setError('Nome não pode estar vazio');
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      if (_editingPessoa == null) {
        // Adicionar nova pessoa
        final pessoa = Pessoa(nome: nome, idade: idade);
        final result = await _repository.save(pessoa);
        
        result.fold(
          onSuccess: (_) {
            _clearEditing();
            loadPessoas(); // Recarrega a lista
          },
          onFailure: (message, _) {
            _setError('Erro ao salvar: $message');
          },
        );
      } else {
        // Atualizar pessoa existente
        final pessoaAtualizada = _editingPessoa!.copyWith(
          nome: nome,
          idade: idade,
        );
        
        final result = await _repository.update(pessoaAtualizada);
        
        result.fold(
          onSuccess: (success) {
            if (success) {
              _clearEditing();
              loadPessoas(); // Recarrega a lista
            } else {
              _setError('Nenhum registro foi atualizado');
            }
          },
          onFailure: (message, _) {
            _setError('Erro ao atualizar: $message');
          },
        );
      }
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> deletePessoa(int id) async {
    _setLoading(true);
    _clearError();
    
    final pessoaParaRemover = _pessoas.where((p) => p.id == id).firstOrNull;
    if (pessoaParaRemover != null) {
      _pessoas.removeWhere((p) => p.id == id);
      notifyListeners(); // Atualiza a UI
    }
    
    try {
      final result = await _repository.delete(id);
      
      result.fold(
        onSuccess: (success) {
          if (!success) {
            if (pessoaParaRemover != null) {
              _pessoas.add(pessoaParaRemover);
              _pessoas.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0)); // Ordena por ID DESC
              notifyListeners();
            }
            _setError('Nenhum registro foi removido');
          }
        },
        onFailure: (message, _) {
          if (pessoaParaRemover != null) {
            _pessoas.add(pessoaParaRemover);
            _pessoas.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0)); // Ordena por ID DESC
            notifyListeners();
          }
          _setError('Erro ao remover: $message');
        },
      );
    } catch (e) {
      if (pessoaParaRemover != null) {
        _pessoas.add(pessoaParaRemover);
        _pessoas.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0)); // Ordena por ID DESC
        notifyListeners();
      }
      _setError('Erro inesperado: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  void startEditing(Pessoa pessoa) {
    _editingPessoa = pessoa;
    _clearError();
    notifyListeners();
  }
  
  void cancelEditing() {
    _clearEditing();
  }
  
  void _clearEditing() {
    _editingPessoa = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
