import 'package:flutter/material.dart';
import '../core/dependencies.dart';
import '../models/pessoa.dart';
import '../stores/pessoa_store.dart';
import '../repositories/i_pessoas_repository.dart';

// UI (CRUD), Store e DI

class PessoasPage extends StatefulWidget {
  final IPessoasRepository repo;
  const PessoasPage({super.key, required this.repo});

  State<PessoasPage> createState() => _PessoasPageState();
}

class FakeRepo implements IPessoasRepository {
  final List<Pessoa> _data = [];

  @override
  Future<List<Pessoa>> getAll() async {
    return _data;
  }

  @override
  Future<int> insert(Pessoa p) async {
    _data.add(p);
    return 1;
  }

  @override
  Future<int> update(Pessoa p) async {
    return 1;
  }

  @override
  Future<int> delete(int id) async {
    _data.removeWhere((p) => p.id == id);
    return 1;
  }
}


class _PessoasPageState extends State<PessoasPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();

  // Store via DI
  late final PessoaStore _store;

  @override
  void initState() {
    super.initState();
    _store = getIt<PessoaStore>();
    _store.addListener(_onStoreChanged);
    _loadData();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});

      // Atualiza formulário
      if (_store.isEditing && _store.editingPessoa != null) {
        _nomeCtrl.text = _store.editingPessoa!.nome;
        _idadeCtrl.text = _store.editingPessoa!.idade.toString();
      }

      // Limpa formulário
      if (!_store.isEditing) {
        _nomeCtrl.clear();
        _idadeCtrl.clear();
      }
    }
  }

  void _loadData() {
    _store.loadPessoas();
  }

  void _limparFormulario() {
    _formKey.currentState?.reset();
    _nomeCtrl.clear();
    _idadeCtrl.clear();
    _store.cancelEditing();

    // desfoca teclado
    FocusScope.of(context).unfocus();
  }

  Future<void> _refresh() async {
    _store.loadPessoas();
  }

  Future<void> _salvar() async {
    if (_store.isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final nome = _nomeCtrl.text.trim();
    final idade = int.parse(_idadeCtrl.text.trim());

    await _store.savePessoa(nome, idade);

    // mensagem se houver erro
    if (_store.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_store.errorMessage!)));
        _store.clearError();
      }
    } else {
      // mensagem de sucesso
      if (mounted) {
        final message = _store.isEditing
            ? 'Pessoa atualizada!'
            : 'Pessoa adicionada!';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _apagar(int id) async {
    await _store.deletePessoa(id);

    if (_store.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_store.errorMessage!)));
        _store.clearError();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pessoa removida.')));
      }
    }
  }

  void _carregarParaEdicao(Pessoa p) {
    _store.startEditing(p);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _store.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas (SQLite + DI)'),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------------------
            // Formulário
            // ---------------------------
            Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v?.trim().isEmpty == true)
                          ? 'Nome obrigatório'
                          : null,
                      onFieldSubmitted: (_) {
                        if (!_store.isLoading) _salvar();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _idadeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Idade',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v?.trim().isEmpty == true)
                          return 'Idade obrigatória';
                        final idade = int.tryParse(v!);
                        if (idade == null || idade < 0 || idade > 150) {
                          return 'Idade inválida (0-150)';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!_store.isLoading) _salvar();
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _store.isLoading ? null : _salvar,
                            icon: _store.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(isEditing ? Icons.edit : Icons.add),
                            label: Text(isEditing ? 'Salvar' : 'Adicionar'),
                          ),
                        ),
                        if (isEditing) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _limparFormulario,
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            // ---------------------------
            // Lista
            // ---------------------------
            Expanded(
              child: _store.isLoading && _store.pessoas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _store.pessoas.isEmpty
                  ? const Center(child: Text('Nenhuma pessoa cadastrada.'))
                  : ListView.separated(
                      itemCount: _store.pessoas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = _store.pessoas[index];
                        return Dismissible(
                          key: ValueKey(p.id ?? '${p.nome}-${p.idade}-$index'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Remover registro'),
                                    content: Text('Deseja remover ${p.nome}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Remover'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          },
                          onDismissed: (_) => _apagar(p.id!),
                          child: ListTile(
                            title: Text('${p.nome} (${p.idade})'),
                            subtitle: Text('ID: ${p.id ?? '-'}'),
                            onTap: () => _carregarParaEdicao(p),
                            trailing: IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit),
                              onPressed: () => _carregarParaEdicao(p),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
