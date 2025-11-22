import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/instrumentos_repository.dart';
import '../providers/data_providers.dart';

/// Dialog para retirar um instrumento
class RetirarInstrumentoDialog extends ConsumerStatefulWidget {
  final Instrumento instrumento;

  const RetirarInstrumentoDialog({
    super.key,
    required this.instrumento,
  });

  @override
  ConsumerState<RetirarInstrumentoDialog> createState() => _RetirarInstrumentoDialogState();
}

class _RetirarInstrumentoDialogState extends ConsumerState<RetirarInstrumentoDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _responsavelSelecionado;
  String? _baseOperacionalSelecionada;
  DateTime? _dataDevolucaoPrevista;
  bool _isSubmitting = false;

  // Lista de bases operacionais
  final List<String> _basesOperacionais = [
    'Base Sé',
    'Base Jabaquara',
    'Base Vila Madalena',
  ];

  Future<void> _selectDate() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime initialDate = _dataDevolucaoPrevista ?? now.add(const Duration(days: 7));
      final DateTime firstDate = now;
      final DateTime lastDate = now.add(const Duration(days: 365));
      
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
      
      if (picked != null && mounted) {
        setState(() {
          _dataDevolucaoPrevista = picked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && 
        _responsavelSelecionado != null && 
        _baseOperacionalSelecionada != null &&
        _dataDevolucaoPrevista != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final instrumentosRepository = ref.read(instrumentosRepositoryProvider);
        // Obtém o usuário atual para usar como responsavelId
        final user = FirebaseAuth.instance.currentUser;
        await instrumentosRepository.retirarInstrumento(
          instrumentoId: widget.instrumento.id,
          responsavelId: user?.uid ?? 'unknown',
          responsavelNome: _responsavelSelecionado!,
          localizacao: _baseOperacionalSelecionada!,
          dataDevolucaoPrevista: _dataDevolucaoPrevista!,
        );

        // Envia notificação por email para gestores e admins
        try {
          final emailService = ref.read(emailNotificationServiceProvider);
          await emailService.enviarNotificacao(
            assunto: 'Instrumento Retirado',
            mensagem: 'Um instrumento foi retirado do estoque.',
            tipoAlteracao: 'atualizar',
            entidade: 'instrumento',
            detalhes: 'Instrumento: ${widget.instrumento.nome}\n'
                'Patrimônio: ${widget.instrumento.patrimonio ?? "N/A"}\n'
                'Responsável: ${_responsavelSelecionado ?? "Não informado"}\n'
                'Base Operacional: ${_baseOperacionalSelecionada ?? "Não informada"}\n'
                'Devolução prevista: ${_dataDevolucaoPrevista != null ? DateFormat('dd/MM/yyyy').format(_dataDevolucaoPrevista!) : "Não informada"}',
          );
        } catch (e) {
          debugPrint('Erro ao enviar notificação por email: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Instrumento "${widget.instrumento.nome}" retirado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao retirar instrumento: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Retirar Instrumento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instrumento: ${widget.instrumento.nome}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Patrimônio: ${widget.instrumento.patrimonio}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              // Selection box para Responsável
              Consumer(
                builder: (context, ref, child) {
                  final usuariosAsync = ref.watch(usuariosProvider);
                  
                  return usuariosAsync.when(
                    data: (usuarios) {
                      // Filtra apenas usuários ativos
                      final usuariosAtivos = usuarios.where((u) => u.ativo).toList();
                      
                      return DropdownButtonFormField<String>(
                        value: _responsavelSelecionado,
                        decoration: InputDecoration(
                          labelText: 'Responsável *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(Icons.person),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        hint: const Text('Selecione o responsável'),
                        items: usuariosAtivos.map((usuario) {
                          return DropdownMenuItem<String>(
                            value: usuario.nome,
                            child: Text('${usuario.nome}${usuario.email.isNotEmpty ? " (${usuario.email})" : ""}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _responsavelSelecionado = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecione o responsável.';
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.bodyLarge,
                      );
                    },
                    loading: () => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Responsável *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      hint: const Text('Carregando usuários...'),
                      items: const [],
                      onChanged: (_) {},
                    ),
                    error: (error, stack) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Responsável *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      hint: Text('Erro ao carregar: $error'),
                      items: const [],
                      onChanged: (_) {},
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Selection box para Base Operacional
              DropdownButtonFormField<String>(
                value: _baseOperacionalSelecionada,
                decoration: InputDecoration(
                  labelText: 'Base Operacional *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.location_on),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                hint: const Text('Selecione a base operacional'),
                items: _basesOperacionais.map((base) {
                  return DropdownMenuItem<String>(
                    value: base,
                    child: Text(base),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _baseOperacionalSelecionada = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a base operacional.';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data de Devolução Prevista *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: const Icon(Icons.calendar_today),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: Text(
                    _dataDevolucaoPrevista != null
                        ? DateFormat('dd/MM/yyyy').format(_dataDevolucaoPrevista!)
                        : 'Selecione uma data',
                    style: TextStyle(
                      color: _dataDevolucaoPrevista != null ? Colors.black87 : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (_dataDevolucaoPrevista == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Por favor, selecione uma data de devolução.',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Confirmar Retirada'),
                  ],
                ),
        ),
      ],
    );
  }
}

