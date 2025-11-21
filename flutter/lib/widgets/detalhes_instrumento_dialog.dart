import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/instrumentos_repository.dart';

/// Dialog para exibir detalhes de um instrumento
class DetalhesInstrumentoDialog extends StatelessWidget {
  final Instrumento instrumento;

  const DetalhesInstrumentoDialog({
    super.key,
    required this.instrumento,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalhes do Instrumento',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              _buildInfoRow(context, 'Patrimônio', instrumento.patrimonio ?? 'N/A'),
              if (instrumento.numeroSerie != null)
                _buildInfoRow(context, 'Número de Série', instrumento.numeroSerie!),
              _buildInfoRow(context, 'Nome', instrumento.nome),
              _buildInfoRow(context, 'Categoria', instrumento.categoria ?? 'N/A'),
              _buildInfoRow(context, 'Status', _getStatusLabel(instrumento.status)),
              _buildInfoRow(context, 'Localização', instrumento.localizacao ?? 'N/A'),
              if (instrumento.responsavel != null)
                _buildInfoRow(context, 'Responsável', instrumento.responsavel!),
              if (instrumento.dataEmprestimo != null)
                _buildInfoRow(
                  context,
                  'Data de Empréstimo',
                  DateFormat('dd/MM/yyyy HH:mm').format(instrumento.dataEmprestimo!),
                ),
              if (instrumento.dataDevolucaoPrevista != null)
                _buildInfoRow(
                  context,
                  'Data de Devolução Prevista',
                  DateFormat('dd/MM/yyyy').format(instrumento.dataDevolucaoPrevista!),
                ),
              if (instrumento.dataCalibracao != null)
                _buildInfoRow(
                  context,
                  'Data de Calibração',
                  DateFormat('dd/MM/yyyy').format(instrumento.dataCalibracao!),
                ),
              if (instrumento.proximaCalibracao != null)
                _buildInfoRow(
                  context,
                  'Próxima Calibração',
                  DateFormat('dd/MM/yyyy').format(instrumento.proximaCalibracao!),
                ),
              _buildInfoRow(context, 'Status de Calibração', _getCalibracaoLabel(instrumento.statusCalibracao)),
              if (instrumento.observacoes != null && instrumento.observacoes!.isNotEmpty)
                _buildInfoRow(context, 'Observações', instrumento.observacoes!),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'disponivel':
        return 'Disponível';
      case 'emprestado':
        return 'Emprestado';
      case 'em_uso':
        return 'Em Uso';
      case 'manutencao':
        return 'Em Manutenção';
      case 'indisponivel':
        return 'Indisponível';
      default:
        return status;
    }
  }

  String _getCalibracaoLabel(String status) {
    switch (status.toLowerCase()) {
      case 'ok':
        return 'OK';
      case 'vencendo':
        return 'Vencendo';
      case 'vencida':
        return 'Vencida';
      default:
        return 'Desconhecido';
    }
  }
}

