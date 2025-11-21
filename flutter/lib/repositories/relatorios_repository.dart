import 'package:cloud_firestore/cloud_firestore.dart';
import 'materiais_repository.dart' as repo;

/// Dados de movimentação mensal
class MovimentacaoMensal {
  final String mes;
  final int entradas;
  final int saidas;

  MovimentacaoMensal({
    required this.mes,
    required this.entradas,
    required this.saidas,
  });
}

/// Material por consumo
class MaterialConsumo {
  final String nome;
  final int unidades;
  final double variacaoPercentual; // Positivo = aumento, Negativo = diminuição

  MaterialConsumo({
    required this.nome,
    required this.unidades,
    required this.variacaoPercentual,
  });
}

/// Estatísticas de Relatórios
class RelatoriosStats {
  final int totalMovimentacoes;
  final double variacaoMovimentacoes; // Percentual em relação ao mês anterior
  final int materiaisCriticos;
  final double taxaUso; // Percentual
  final double variacaoTaxaUso; // Percentual
  final double valorTotalEstoque; // Em reais
  final List<MovimentacaoMensal> movimentacoesMensais;
  final List<MaterialConsumo> topMateriais;

  RelatoriosStats({
    required this.totalMovimentacoes,
    required this.variacaoMovimentacoes,
    required this.materiaisCriticos,
    required this.taxaUso,
    required this.variacaoTaxaUso,
    required this.valorTotalEstoque,
    required this.movimentacoesMensais,
    required this.topMateriais,
  });
}

/// Repositório para relatórios
class RelatoriosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca estatísticas de relatórios
  Future<RelatoriosStats> getStats({int dias = 30}) async {
    final agora = DateTime.now();
    final inicioPeriodo = agora.subtract(Duration(days: dias));
    final mesAnterior = inicioPeriodo.subtract(const Duration(days: 30));

    // Busca requisições do período
    final requisicoesSnapshot = await _firestore
        .collection('requisicoes')
        .where('criadoEm', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioPeriodo))
        .get();

    // Busca requisições do mês anterior para comparação
    // Nota: Firestore não permite múltiplos where no mesmo campo sem índice composto
    // Buscamos todas e filtramos no cliente
    final todasRequisicoes = await _firestore
        .collection('requisicoes')
        .where('criadoEm', isGreaterThanOrEqualTo: Timestamp.fromDate(mesAnterior))
        .get();
    
    final requisicoesMesAnterior = todasRequisicoes.docs.where((doc) {
      final data = doc.data()['criadoEm'] as Timestamp?;
      if (data == null) return false;
      final criadoEm = data.toDate();
      return criadoEm.isBefore(inicioPeriodo);
    }).toList();

    final totalMovimentacoes = requisicoesSnapshot.docs.length;
    final movimentacoesMesAnterior = requisicoesMesAnterior.length;
    final variacaoMovimentacoes = movimentacoesMesAnterior > 0
        ? ((totalMovimentacoes - movimentacoesMesAnterior) / movimentacoesMesAnterior) * 100
        : 0.0;

    // Busca materiais críticos
    final materiaisCriticosSnapshot = await _firestore
        .collection('materiais')
        .where('quantidade', isLessThan: 10)
        .get();
    final materiaisCriticos = materiaisCriticosSnapshot.docs.length;

    // Calcula taxa de uso (instrumentos em uso / total)
    final totalInstrumentos = await _firestore.collection('instrumentos').count().get();
    final instrumentosEmUso = await _firestore
        .collection('instrumentos')
        .where('status', whereIn: ['emprestado', 'em_uso'])
        .count()
        .get();
    
    final totalCount = totalInstrumentos.count ?? 0;
    final emUsoCount = instrumentosEmUso.count ?? 0;
    final taxaUso = totalCount > 0 ? (emUsoCount / totalCount) * 100 : 0.0;

    // Taxa de uso do período anterior (simulado - pode melhorar)
    const variacaoTaxaUso = 5.0; // TODO: Calcular baseado em dados históricos

    // Valor total do estoque (simulado - pode melhorar com preços reais)
    final materiaisSnapshot = await _firestore.collection('materiais').get();
    double valorTotal = 0.0;
    for (var doc in materiaisSnapshot.docs) {
      final quantidade = doc.data()['quantidade'] as int? ?? 0;
      // Valor médio estimado por unidade (pode ser substituído por campo real)
      valorTotal += quantidade * 50.0;
    }

    // Movimentações mensais (últimos 6 meses)
    final movimentacoesMensais = await _calcularMovimentacoesMensais();

    // Top materiais por consumo
    final topMateriais = await _calcularTopMateriais();

    return RelatoriosStats(
      totalMovimentacoes: totalMovimentacoes,
      variacaoMovimentacoes: variacaoMovimentacoes,
      materiaisCriticos: materiaisCriticos,
      taxaUso: taxaUso,
      variacaoTaxaUso: variacaoTaxaUso,
      valorTotalEstoque: valorTotal,
      movimentacoesMensais: movimentacoesMensais,
      topMateriais: topMateriais,
    );
  }

  Future<List<MovimentacaoMensal>> _calcularMovimentacoesMensais() async {
    final agora = DateTime.now();
    final meses = <MovimentacaoMensal>[];

    for (int i = 5; i >= 0; i--) {
      final mes = agora.subtract(Duration(days: 30 * i));
      final inicioMes = DateTime(mes.year, mes.month, 1);
      final fimMes = DateTime(mes.year, mes.month + 1, 0, 23, 59, 59);

      final requisicoes = await _firestore
          .collection('requisicoes')
          .where('criadoEm', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioMes))
          .where('criadoEm', isLessThanOrEqualTo: Timestamp.fromDate(fimMes))
          .get();

      // Simula entradas e saídas baseado nas requisições
      final entradas = (requisicoes.docs.length * 1.2).round(); // Simulado
      final saidas = requisicoes.docs.length;

      meses.add(MovimentacaoMensal(
        mes: _getNomeMes(mes.month),
        entradas: entradas,
        saidas: saidas,
      ));
    }

    return meses;
  }

  Future<List<MaterialConsumo>> _calcularTopMateriais() async {
    final materiaisSnapshot = await _firestore.collection('materiais').get();
    final materiais = materiaisSnapshot.docs
        .map((doc) => repo.Material.fromFirestore(doc))
        .toList();

    // Ordena por quantidade (maior consumo)
    materiais.sort((a, b) => b.quantidade.compareTo(a.quantidade));

    // Pega os top 4 e simula variação percentual
    final top = materiais.take(4).toList();
    return top.asMap().entries.map((entry) {
      final index = entry.key;
      final material = entry.value;
      // Simula variação percentual (pode ser substituído por cálculo real)
      final variacao = [12.0, -8.0, 5.0, -3.0][index % 4];
      
      return MaterialConsumo(
        nome: material.nome,
        unidades: material.quantidade,
        variacaoPercentual: variacao,
      );
    }).toList();
  }

  String _getNomeMes(int mes) {
    const meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return meses[mes - 1];
  }
}

