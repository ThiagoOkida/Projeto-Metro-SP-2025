import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/materiais_repository.dart' hide Material;
import '../repositories/materiais_repository.dart' as repo show Material;
import '../repositories/requisicoes_repository.dart';
import '../providers/data_providers.dart';

/// Dialog para criar uma nova requisição de material
class NovaRequisicaoDialog extends ConsumerStatefulWidget {
  const NovaRequisicaoDialog({super.key});

  @override
  ConsumerState<NovaRequisicaoDialog> createState() => _NovaRequisicaoDialogState();
}

class _NovaRequisicaoDialogState extends ConsumerState<NovaRequisicaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();
  
  repo.Material? _materialSelecionado;
  int? _quantidadeSelecionada;
  String? _baseOperacionalSelecionada;
  List<repo.Material> _materiais = [];
  bool _carregando = false;

  // Lista de bases operacionais (apenas as 3 especificadas)
  final List<String> _basesOperacionais = [
    'Base Sé',
    'Base Jabaquara',
    'Base Vila Madalena',
  ];

  @override
  void initState() {
    super.initState();
    _carregarMateriais();
  }

  Future<void> _carregarMateriais() async {
    try {
      final repository = MateriaisRepository();
      final materiaisStream = repository.getMateriais();
      await for (final materiais in materiaisStream) {
        if (mounted) {
          setState(() {
            _materiais = materiais;
          });
          break; // Pega apenas o primeiro snapshot
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar materiais: $e')),
        );
      }
    }
  }

  Future<void> _criarRequisicao() async {
    if (!_formKey.currentState!.validate() || 
        _materialSelecionado == null || 
        _quantidadeSelecionada == null) {
      if (_materialSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um material')),
        );
      } else if (_quantidadeSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma quantidade')),
        );
      }
      return;
    }

    setState(() => _carregando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Busca nome do usuário no Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      
      final userName = userDoc.data()?['nome'] ?? user.email?.split('@')[0] ?? 'Usuário';

      final repository = RequisicoesRepository();
      await repository.criarRequisicao(
        materialId: _materialSelecionado!.id,
        materialNome: _materialSelecionado!.nome,
        quantidade: _quantidadeSelecionada!,
        solicitanteId: user.uid,
        solicitanteNome: userName,
        baseOperacional: _baseOperacionalSelecionada,
        observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
      );

      // Envia notificação por email para gestores e admins
      try {
        final emailService = ref.read(emailNotificationServiceProvider);
        await emailService.enviarNotificacao(
          assunto: 'Nova Requisição de Material',
          mensagem: 'Uma nova requisição foi criada no sistema.',
          tipoAlteracao: 'criar',
          entidade: 'requisicao',
          detalhes: 'Material: ${_materialSelecionado!.nome}\n'
              'Quantidade: $_quantidadeSelecionada\n'
              'Solicitante: $userName\n'
              'Base Operacional: ${_baseOperacionalSelecionada ?? "Não informada"}',
        );
      } catch (e) {
        // Não interrompe o fluxo se o email falhar
        debugPrint('Erro ao enviar notificação por email: $e');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Requisição criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar requisição: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle_outline, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Nova Requisição',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Seleção de Material
              DropdownButtonFormField<repo.Material>(
                initialValue: _materialSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Material *',
                  border: OutlineInputBorder(),
                ),
                items: _materiais.map((material) {
                  return DropdownMenuItem(
                    value: material,
                    child: Text('${material.nome} (Estoque: ${material.quantidade})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _materialSelecionado = value;
                    // Reseta a quantidade se for maior que o estoque disponível
                    if (value != null && _quantidadeSelecionada != null) {
                      if (_quantidadeSelecionada! > value.quantidade) {
                        _quantidadeSelecionada = null;
                      }
                    }
                  });
                },
                validator: (value) => value == null ? 'Selecione um material' : null,
              ),
              const SizedBox(height: 16),

              // Quantidade
              DropdownButtonFormField<int>(
                initialValue: _quantidadeSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Quantidade *',
                  border: OutlineInputBorder(),
                ),
                items: () {
                  // Gera lista de quantidades de 1 até o estoque disponível
                  if (_materialSelecionado == null || _materialSelecionado!.quantidade <= 0) {
                    return <DropdownMenuItem<int>>[];
                  }
                  
                  final estoqueDisponivel = _materialSelecionado!.quantidade;
                  final quantidadesDisponiveis = List.generate(
                    estoqueDisponivel,
                    (index) => index + 1,
                  );
                  
                  return quantidadesDisponiveis.map((qty) {
                    return DropdownMenuItem(
                      value: qty,
                      child: Text('$qty'),
                    );
                  }).toList();
                }(),
                onChanged: (value) {
                  setState(() => _quantidadeSelecionada = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione uma quantidade';
                  }
                  if (_materialSelecionado != null && value > _materialSelecionado!.quantidade) {
                    return 'Estoque insuficiente (máx: ${_materialSelecionado!.quantidade})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Base Operacional
              DropdownButtonFormField<String>(
                initialValue: _baseOperacionalSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Base Operacional',
                  border: OutlineInputBorder(),
                  hintText: 'Selecione uma base',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Nenhuma'),
                  ),
                  ..._basesOperacionais.map((base) {
                    return DropdownMenuItem(
                      value: base,
                      child: Text(base),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _baseOperacionalSelecionada = value);
                },
              ),
              const SizedBox(height: 16),

              // Observações
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _carregando ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _carregando ? null : _criarRequisicao,
                    child: _carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Criar Requisição'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

