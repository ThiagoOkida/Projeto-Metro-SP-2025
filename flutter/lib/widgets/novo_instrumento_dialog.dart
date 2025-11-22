import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/data_providers.dart';

/// Dialog para adicionar um novo instrumento
class NovoInstrumentoDialog extends ConsumerStatefulWidget {
  const NovoInstrumentoDialog({super.key});

  @override
  ConsumerState<NovoInstrumentoDialog> createState() => _NovoInstrumentoDialogState();
}

class _NovoInstrumentoDialogState extends ConsumerState<NovoInstrumentoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _patrimonioController = TextEditingController();
  final _numeroSerieController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _observacoesController = TextEditingController();
  DateTime? _dataCalibracao;
  DateTime? _proximaCalibracao;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _patrimonioController.dispose();
    _numeroSerieController.dispose();
    _categoriaController.dispose();
    _localizacaoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(String tipo) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: tipo == 'calibracao' 
            ? (_dataCalibracao ?? now)
            : (_proximaCalibracao ?? now.add(const Duration(days: 365))),
        firstDate: tipo == 'calibracao' ? now.subtract(const Duration(days: 3650)) : now,
        lastDate: now.add(const Duration(days: 3650)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
              dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
      
      if (picked != null && mounted) {
        setState(() {
          if (tipo == 'calibracao') {
            _dataCalibracao = picked;
          } else {
            _proximaCalibracao = picked;
          }
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final instrumentosRepository = ref.read(instrumentosRepositoryProvider);
        await instrumentosRepository.criarInstrumento(
          nome: _nomeController.text.trim(),
          patrimonio: _patrimonioController.text.trim().isEmpty 
              ? null 
              : _patrimonioController.text.trim(),
          numeroSerie: _numeroSerieController.text.trim().isEmpty 
              ? null 
              : _numeroSerieController.text.trim(),
          categoria: _categoriaController.text.trim().isEmpty 
              ? null 
              : _categoriaController.text.trim(),
          localizacao: _localizacaoController.text.trim().isEmpty 
              ? null 
              : _localizacaoController.text.trim(),
          dataCalibracao: _dataCalibracao,
          proximaCalibracao: _proximaCalibracao,
          observacoes: _observacoesController.text.trim().isEmpty 
              ? null 
              : _observacoesController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Instrumento "${_nomeController.text}" criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar instrumento: ${e.toString()}'),
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
      title: const Text('Novo Instrumento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do Instrumento *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.build),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o nome do instrumento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patrimonioController,
                decoration: InputDecoration(
                  labelText: 'Patrimônio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.tag),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroSerieController,
                decoration: InputDecoration(
                  labelText: 'Número de Série',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.numbers),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.category),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _localizacaoController,
                decoration: InputDecoration(
                  labelText: 'Localização',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.location_on),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate('calibracao'),
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data de Calibração',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: const Icon(Icons.calendar_today),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: Text(
                    _dataCalibracao != null
                        ? DateFormat('dd/MM/yyyy').format(_dataCalibracao!)
                        : 'Selecione uma data',
                    style: TextStyle(
                      color: _dataCalibracao != null ? Colors.black87 : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate('proxima'),
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Próxima Calibração',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: const Icon(Icons.calendar_today),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: Text(
                    _proximaCalibracao != null
                        ? DateFormat('dd/MM/yyyy').format(_proximaCalibracao!)
                        : 'Selecione uma data',
                    style: TextStyle(
                      color: _proximaCalibracao != null ? Colors.black87 : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoesController,
                decoration: InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.note),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                maxLines: 3,
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
                    Text('Criar Instrumento'),
                  ],
                ),
        ),
      ],
    );
  }
}

