import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/instrumentos_repository.dart';
import '../providers/data_providers.dart';

/// Dialog para devolver um instrumento
class DevolverInstrumentoDialog extends ConsumerStatefulWidget {
  const DevolverInstrumentoDialog({super.key});

  @override
  ConsumerState<DevolverInstrumentoDialog> createState() => _DevolverInstrumentoDialogState();
}

class _DevolverInstrumentoDialogState extends ConsumerState<DevolverInstrumentoDialog> {
  Instrumento? _instrumentoSelecionado;
  List<Instrumento> _instrumentosEmprestados = [];
  bool _carregando = false;
  bool _carregandoInstrumentos = true;

  @override
  void initState() {
    super.initState();
    _carregarInstrumentosEmprestados();
  }

  Future<void> _carregarInstrumentosEmprestados() async {
    try {
      final repository = InstrumentosRepository();
      final instrumentosStream = repository.getInstrumentosEmprestados();
      await for (final instrumentos in instrumentosStream) {
        if (mounted) {
          setState(() {
            _instrumentosEmprestados = instrumentos;
            _carregandoInstrumentos = false;
          });
          break; // Pega apenas o primeiro snapshot
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregandoInstrumentos = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar instrumentos: $e')),
        );
      }
    }
  }

  Future<void> _devolverInstrumento() async {
    if (_instrumentoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um instrumento')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final repository = InstrumentosRepository();
      final instrumentoNome = _instrumentoSelecionado!.nome;
      final instrumentoPatrimonio = _instrumentoSelecionado!.patrimonio;
      await repository.devolverInstrumento(_instrumentoSelecionado!.id);

      // Envia notificação por email para gestores e admins
      try {
        final emailService = ref.read(emailNotificationServiceProvider);
        await emailService.enviarNotificacao(
          assunto: 'Instrumento Devolvido',
          mensagem: 'Um instrumento foi devolvido ao estoque.',
          tipoAlteracao: 'atualizar',
          entidade: 'instrumento',
          detalhes: 'Instrumento: $instrumentoNome\n'
              'Patrimônio: ${instrumentoPatrimonio ?? "N/A"}',
        );
      } catch (e) {
        debugPrint('Erro ao enviar notificação por email: $e');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$instrumentoNome devolvido com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao devolver instrumento: $e'),
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
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_return, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Devolver Instrumento',
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
            
            if (_carregandoInstrumentos)
              const Center(child: CircularProgressIndicator())
            else if (_instrumentosEmprestados.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nenhum instrumento emprestado no momento.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              DropdownButtonFormField<Instrumento>(
                initialValue: _instrumentoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Instrumento *',
                  border: OutlineInputBorder(),
                ),
                items: _instrumentosEmprestados.map((instrumento) {
                  final responsavel = instrumento.responsavel ?? 'N/A';
                  final numeroSerie = instrumento.numeroSerie != null ? ' - ${instrumento.numeroSerie}' : '';
                  return DropdownMenuItem(
                    value: instrumento,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${instrumento.nome}$numeroSerie'),
                        Text(
                          'Responsável: $responsavel',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _instrumentoSelecionado = value);
                },
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
                  onPressed: _carregando || _instrumentoSelecionado == null || _instrumentosEmprestados.isEmpty
                      ? null
                      : _devolverInstrumento,
                  child: _carregando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Devolver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

