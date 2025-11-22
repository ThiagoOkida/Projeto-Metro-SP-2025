import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../repositories/relatorios_repository.dart';
import '../providers/data_providers.dart';
import '../services/export_service.dart';

class RelatoriosPage extends ConsumerStatefulWidget {
  const RelatoriosPage({super.key});

  @override
  ConsumerState<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends ConsumerState<RelatoriosPage> {

  int _selectedPeriodDays = 30;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(relatoriosStatsProvider(_selectedPeriodDays));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Relatórios',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Análises e estatísticas do sistema',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
                DropdownButton<int>(
                  value: _selectedPeriodDays,
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('Últimos 7 dias')),
                    DropdownMenuItem(value: 30, child: Text('Últimos 30 dias')),
                    DropdownMenuItem(value: 90, child: Text('Últimos 90 dias')),
                    DropdownMenuItem(value: 365, child: Text('Último ano')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPeriodDays = value);
                    }
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _exportarRelatorio(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            statsAsync.when(
              data: (stats) => _buildSummaryCards(context, stats),
              loading: () => _buildSummaryCardsLoading(context),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 24),
            statsAsync.when(
              data: (stats) => _buildChartsAndList(context, stats),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Erro ao carregar relatórios: $error',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, RelatoriosStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 1200) crossAxisCount = 2;
        if (constraints.maxWidth < 600) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.0,
          children: [
            _SummaryCard(
              title: 'Total de Movimentações',
              value: stats.totalMovimentacoes.toString(),
              subtitle: stats.variacaoMovimentacoes >= 0
                  ? '+${stats.variacaoMovimentacoes.toStringAsFixed(0)}% em relação ao mês anterior'
                  : '${stats.variacaoMovimentacoes.toStringAsFixed(0)}% em relação ao mês anterior',
              icon: Icons.trending_up,
              color: Colors.blue,
              variacao: stats.variacaoMovimentacoes,
            ),
            _SummaryCard(
              title: 'Materiais Críticos',
              value: stats.materiaisCriticos.toString(),
              subtitle: 'Requerem atenção imediata',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
            ),
            _SummaryCard(
              title: 'Taxa de Uso',
              value: '${stats.taxaUso.toStringAsFixed(0)}%',
              subtitle: stats.variacaoTaxaUso >= 0
                  ? '+${stats.variacaoTaxaUso.toStringAsFixed(0)}% comparado ao período anterior'
                  : '${stats.variacaoTaxaUso.toStringAsFixed(0)}% comparado ao período anterior',
              icon: Icons.percent,
              color: Colors.green,
              variacao: stats.variacaoTaxaUso,
            ),
            _SummaryCard(
              title: 'Valor Total',
              value: _formatCurrency(stats.valorTotalEstoque),
              subtitle: 'Em estoque atual',
              icon: Icons.attach_money,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCardsLoading(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 1200) crossAxisCount = 2;
        if (constraints.maxWidth < 600) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.0,
          children: List.generate(4, (index) => const _SummaryCardLoading()),
        );
      },
    );
  }

  Widget _buildChartsAndList(BuildContext context, RelatoriosStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1200) {
          return Column(
            children: [
              _buildMovimentacoesMensais(context, stats.movimentacoesMensais),
              const SizedBox(height: 16),
              _buildTopMateriais(context, stats.topMateriais),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildMovimentacoesMensais(context, stats.movimentacoesMensais),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildTopMateriais(context, stats.topMateriais),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMovimentacoesMensais(BuildContext context, List<MovimentacaoMensal> movimentacoes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Movimentações Mensais',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ...movimentacoes.map((mov) => _buildBarraMovimentacao(context, mov, movimentacoes)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarraMovimentacao(BuildContext context, MovimentacaoMensal mov, List<MovimentacaoMensal> todasMovimentacoes) {
    final total = mov.entradas + mov.saidas;
    final maxTotal = todasMovimentacoes.map((m) => m.entradas + m.saidas).reduce((a, b) => a > b ? a : b);
    final largura = maxTotal > 0 ? (total / maxTotal) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  mov.mes,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: largura,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Entradas: ${mov.entradas} | Saídas: ${mov.saidas}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildTopMateriais(BuildContext context, List<MaterialConsumo> topMateriais) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Materiais por Consumo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ...topMateriais.map((material) => _buildItemMaterial(context, material)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemMaterial(BuildContext context, MaterialConsumo material) {
    final isAumento = material.variacaoPercentual >= 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.nome,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${material.unidades} unidades',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                isAumento ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isAumento ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '${isAumento ? '+' : ''}${material.variacaoPercentual.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: isAumento ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}K';
    }
    return 'R\$ ${value.toStringAsFixed(0)}';
  }

  Future<void> _exportarRelatorio(BuildContext context) async {
    final statsAsync = ref.read(relatoriosStatsProvider(_selectedPeriodDays));
    
    if (statsAsync.isLoading) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aguarde o carregamento dos dados e tente novamente'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (statsAsync.hasError) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${statsAsync.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final stats = statsAsync.value;
    if (stats == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados não disponíveis para exportação'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('Gerando relatório...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      final exportService = ExportService();
      await exportService.exportarRelatorioCSV(stats, _selectedPeriodDays);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório exportado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stack) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar relatório: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      debugPrint('Erro ao exportar relatório: $e\n$stack');
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? variacao;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.variacao,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const Spacer(),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (variacao != null && variacao! >= 0)
                  const Icon(Icons.trending_up, size: 16, color: Colors.green),
                if (variacao != null && variacao! < 0)
                  const Icon(Icons.trending_down, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: variacao != null
                          ? (variacao! >= 0 ? Colors.green : Colors.red)
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCardLoading extends StatelessWidget {
  const _SummaryCardLoading();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 150,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
