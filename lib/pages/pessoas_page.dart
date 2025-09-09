import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/pessoa.dart';

// 4) UI (CRUD)

class PessoasPage extends StatefulWidget {
  const PessoasPage({super.key});

  @override
  State<PessoasPage> createState() => _PessoasPageState();
}

class _PessoasPageState extends State<PessoasPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();

  int? _editingId; // se != null, estamos editando
  late Future<List<Pessoa>> _futurePessoas;
  bool _isSaving = false;
  int _reloadTick = 0; // <--- NOVO  

  @override
  void initState() {
    super.initState();
    _futurePessoas = DatabaseHelper.instance.getAll();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    super.dispose();
  }

  void _limparFormulario() {
    _formKey.currentState?.reset();
    _nomeCtrl.clear();
    _idadeCtrl.clear();
    _editingId = null;

    // desfoca teclado (especialmente no Web)
    FocusScope.of(context).unfocus();

    // avisa a UI que mudou (para atualizar botão/estado)
    setState(() {});
  }

  Future<void> _refresh() async {
    setState(() {
      _futurePessoas = DatabaseHelper.instance.getAll();
      _reloadTick++; // muda a key e força rebuild do FutureBuilder
    });
  }

  Future<void> _salvar() async {
    if (_isSaving) return;             // evita duplo clique / enter+clique
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final nome = _nomeCtrl.text.trim();
      final idade = int.parse(_idadeCtrl.text.trim());

      if (_editingId == null) {
        await DatabaseHelper.instance.insert(Pessoa(nome: nome, idade: idade));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pessoa adicionada!')),
        );
      } else {
        await DatabaseHelper.instance.update(
          Pessoa(id: _editingId, nome: nome, idade: idade),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pessoa atualizada!')),
        );
      }

      _limparFormulario();
      // deixa a UI respirar, e o FutureBuilder atualiza assim que o Future completar
      _refresh();                   // dispara o FutureBuilder atualizar
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _apagar(int id) async {
    await DatabaseHelper.instance.delete(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pessoa removida.')),
    );
    await _refresh();
  }

  void _carregarParaEdicao(Pessoa p) {
    setState(() {
      _editingId = p.id;
      _nomeCtrl.text = p.nome;
      _idadeCtrl.text = p.idade.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas (SQLite)'),
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
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe o nome';
                        }
                        if (v.trim().length < 2) {
                          return 'Nome muito curto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _idadeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Idade',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe a idade';
                        }
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 0 || n > 150) {
                          return 'Idade inválida';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!_isSaving) _salvar();
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _salvar,
                            icon: _isSaving ? const SizedBox(
                              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2),
                            ) : Icon(isEditing ? Icons.save : Icons.add),
                            label: Text(isEditing ? 'Salvar alterações' : 'Adicionar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (isEditing)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _limparFormulario,
                              icon: const Icon(Icons.close),
                              label: const Text('Cancelar edição'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // ---------------------------
            // Lista
            // ---------------------------
            Expanded(
              child: FutureBuilder<List<Pessoa>>(
                key: ValueKey(_reloadTick), // <- força rebuild quando _reloadTick muda                
                future: _futurePessoas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  final pessoas = snapshot.data ?? const <Pessoa>[];
                  if (pessoas.isEmpty) {
                    return const Center(child: Text('Nenhuma pessoa cadastrada.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: pessoas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = pessoas[index];
                      return Dismissible(
                        key: ValueKey(p.id ?? '${p.nome}-${p.idade}-$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Remover registro'),
                                  content: Text('Deseja remover ${p.nome}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Remover'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (_) => _apagar(p.id!),
                        child: ListTile(
                          tileColor: Colors.grey.withValues(alpha: 0.06),
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
