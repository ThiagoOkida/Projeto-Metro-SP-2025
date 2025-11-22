import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;
import 'dart:convert' show utf8;
import 'package:path_provider/path_provider.dart';
import '../repositories/relatorios_repository.dart';

/// Serviço para exportar dados em diferentes formatos
/// Funciona em todas as plataformas: Web, Mobile e Desktop
class ExportService {
  /// Exporta relatórios em formato CSV
  /// Funciona em todas as plataformas: Web, Mobile e Desktop
  Future<void> exportarRelatorioCSV(RelatoriosStats stats, int periodoDias) async {
    try {
      final csv = _gerarCSVRelatorio(stats, periodoDias);
      final filename = 'relatorio_${_getNomeArquivo()}.csv';
      
      await _shareFile(csv, filename);
    } catch (e) {
      throw Exception('Erro ao exportar relatório: $e');
    }
  }

  String _gerarCSVRelatorio(RelatoriosStats stats, int periodoDias) {
    final buffer = StringBuffer();
    
    // Cabeçalho
    buffer.writeln('RELATÓRIO DE ESTOQUE E MOVIMENTAÇÕES');
    buffer.writeln('Período: Últimos $periodoDias dias');
    buffer.writeln('Data de geração: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('');
    
    // Resumo Executivo
    buffer.writeln('RESUMO EXECUTIVO');
    buffer.writeln('Métrica,Valor');
    buffer.writeln('Total de Movimentações,${stats.totalMovimentacoes}');
    buffer.writeln('Variação de Movimentações,${stats.variacaoMovimentacoes.toStringAsFixed(2)}%');
    buffer.writeln('Materiais Críticos,${stats.materiaisCriticos}');
    buffer.writeln('Taxa de Uso,${stats.taxaUso.toStringAsFixed(2)}%');
    buffer.writeln('Variação Taxa de Uso,${stats.variacaoTaxaUso.toStringAsFixed(2)}%');
    buffer.writeln('Valor Total do Estoque,${_formatCurrency(stats.valorTotalEstoque)}');
    buffer.writeln('');
    
    // Movimentações Mensais
    buffer.writeln('MOVIMENTAÇÕES MENSAIS');
    buffer.writeln('Mês,Entradas,Saídas,Total');
    for (var mov in stats.movimentacoesMensais) {
      final total = mov.entradas + mov.saidas;
      buffer.writeln('${mov.mes},${mov.entradas},${mov.saidas},$total');
    }
    buffer.writeln('');
    
    // Top Materiais por Consumo
    buffer.writeln('TOP MATERIAIS POR CONSUMO');
    buffer.writeln('Material,Unidades,Variação Percentual');
    for (var material in stats.topMateriais) {
      final variacao = material.variacaoPercentual >= 0 
          ? '+${material.variacaoPercentual.toStringAsFixed(2)}%'
          : '${material.variacaoPercentual.toStringAsFixed(2)}%';
      buffer.writeln('${_escapeCSV(material.nome)},${material.unidades},$variacao');
    }
    
    return buffer.toString();
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _getNomeArquivo() {
    final agora = DateTime.now();
    return DateFormat('yyyyMMdd_HHmmss').format(agora);
  }

  /// Compartilha arquivo usando share_plus (funciona em todas as plataformas)
  Future<void> _shareFile(String content, String filename) async {
    try {
      if (kIsWeb) {
        // Para web, cria XFile a partir dos bytes UTF-8 em memória
        final bytes = Uint8List.fromList(utf8.encode(content));
        final xFile = XFile.fromData(
          bytes,
          mimeType: 'text/csv',
          name: filename,
        );
        await Share.shareXFiles(
          [xFile],
          text: 'Relatório de Estoque e Movimentações',
          subject: filename,
        );
      } else {
        // Para mobile/desktop, salva o arquivo temporariamente e compartilha
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);
        
        // Compartilha o arquivo
        final xFile = XFile(file.path);
        await Share.shareXFiles(
          [xFile],
          text: 'Relatório de Estoque e Movimentações',
          subject: filename,
        );
        
        // Limpa o arquivo temporário após um delay
        // (dá tempo para o sistema de compartilhamento processar)
        Future.delayed(const Duration(seconds: 5), () async {
          try {
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            // Ignora erros ao deletar arquivo temporário
          }
        });
      }
    } catch (e) {
      throw Exception('Erro ao compartilhar arquivo: $e');
    }
  }
}
