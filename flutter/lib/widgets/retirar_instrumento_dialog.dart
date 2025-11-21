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
  final _responsavelController = TextEditingController();
  final _localizacaoController = TextEditingController();
  DateTime? _dataDevolucaoPrevista;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _responsavelController.dispose();
    _localizacaoController.dispose();
    super.dispose();
  }

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
    if (_formKey.currentState!.validate() && _dataDevolucaoPrevista != null) {
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
          responsavelNome: _responsavelController.text,
          localizacao: _localizacaoController.text,
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
                'Responsável: ${_responsavelController.text}\n'
                'Localização: ${_localizacaoController.text.isEmpty ? "Não informada" : _localizacaoController.text}\n'
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
              TextFormField(
                controller: _responsavelController,
                decoration: const InputDecoration(
                  labelText: 'Responsável *',
                  border: OutlineInputBorder(),
                  hintText: 'Nome do responsável',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o responsável.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _localizacaoController,
                decoration: const InputDecoration(
                  labelText: 'Localização *',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Base Jabaquara, Base Sé',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a localização.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de Devolução Prevista *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dataDevolucaoPrevista != null
                        ? DateFormat('dd/MM/yyyy').format(_dataDevolucaoPrevista!)
                        : 'Selecione uma data',
                    style: TextStyle(
                      color: _dataDevolucaoPrevista != null ? Colors.black87 : Colors.grey[600],
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
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Confirmar Retirada'),
        ),
      ],
    );
  }
}

