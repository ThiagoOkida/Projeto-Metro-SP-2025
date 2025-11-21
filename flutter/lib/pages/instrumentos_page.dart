import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';
import '../repositories/instrumentos_repository.dart' as repo;
import '../widgets/devolver_instrumento_dialog.dart';
import '../widgets/retirar_instrumento_dialog.dart';
import '../widgets/detalhes_instrumento_dialog.dart';

class InstrumentosPage extends ConsumerStatefulWidget {
  const InstrumentosPage({super.key});

  @override
  ConsumerState<InstrumentosPage> createState() => _InstrumentosPageState();
}

class _InstrumentosPageState extends ConsumerState<InstrumentosPage> {
  final _searchController = TextEditingController();
  String? _statusFiltro;
  String? _calibracaoFiltro;

  final List<String> _status = [
    'Disponível',
    'Em Campo',
    'Em Uso',
    'Em Manutenção'
  ];
  final List<String> _calibracoes = ['OK', 'Vencendo', 'Vencida'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _limparFiltros() {
    setState(() {
      _searchController.clear();
      _statusFiltro = null;
      _calibracaoFiltro = null;
    });
  }

  List<repo.Instrumento> _filtrarInstrumentos(
      List<repo.Instrumento> instrumentos) {
    var filtrados = instrumentos;

    // Filtro de busca
    if (_searchController.text.isNotEmpty) {
      final busca = _searchController.text.toLowerCase();
      filtrados = filtrados.where((inst) {
        final patrimonio = inst.patrimonio?.toLowerCase() ??
            inst.numeroSerie?.toLowerCase() ??
            '';
        final nome = inst.nome.toLowerCase();
        return patrimonio.contains(busca) || nome.contains(busca);
      }).toList();
    }

    // Filtro de status
    if (_statusFiltro != null) {
      filtrados = filtrados.where((inst) {
        switch (_statusFiltro) {
          case 'Disponível':
            return inst.isDisponivel;
          case 'Em Campo':
            return inst.status == 'emprestado';
          case 'Em Uso':
            return inst.status == 'em_uso';
          case 'Em Manutenção':
            return inst.status == 'manutencao';
          default:
            return true;
        }
      }).toList();
    }

    // Filtro de calibração
    if (_calibracaoFiltro != null) {
      filtrados = filtrados.where((inst) {
        switch (_calibracaoFiltro) {
          case 'OK':
            return inst.statusCalibracao == 'ok';
          case 'Vencendo':
            return inst.statusCalibracao == 'vencendo';
          case 'Vencida':
            return inst.statusCalibracao == 'vencida';
          default:
            return true;
        }
      }).toList();
    }

    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    final instrumentosAsync = ref.watch(instrumentosProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com título e botão
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instrumentos Técnicos',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Controle de retirada, devolução e calibração de instrumentos',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Funcionalidade em desenvolvimento')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Novo Instrumento'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cards de Resumo
            instrumentosAsync.when(
              data: (instrumentos) {
                final total = instrumentos.length;
                final disponiveis =
                    instrumentos.where((inst) => inst.isDisponivel).length;
                final emCampo = instrumentos
                    .where((inst) =>
                        inst.status == 'emprestado' || inst.status == 'em_uso')
                    .length;
                final calibracaoVencida =
                    instrumentos.where((inst) => inst.calibracaoVencida).length;

                return _buildSummaryCards(
                    context, total, disponiveis, emCampo, calibracaoVencida);
              },
              loading: () => _buildSummaryCardsLoading(context),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // Filtros e Busca
            _buildFiltros(context),

            const SizedBox(height: 16),

            // Tabela de Instrumentos
            instrumentosAsync.when(
              data: (instrumentos) {
                final filtrados = _filtrarInstrumentos(instrumentos);
                return _buildTabelaInstrumentos(context, filtrados);
              },
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
                          'Erro ao carregar instrumentos: $error',
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

  Widget _buildSummaryCards(
    BuildContext context,
    int total,
    int disponiveis,
    int emCampo,
    int calibracaoVencida,
  ) {
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
          childAspectRatio: 2.2,
          children: [
            _SummaryCard(
              title: 'Total de Instrumentos',
              value: total.toString(),
              subtitle: 'instrumentos cadastrados',
              icon: Icons.build_outlined,
              color: Colors.blue,
            ),
            _SummaryCard(
              title: 'Disponíveis',
              value: disponiveis.toString(),
              subtitle: total > 0
                  ? '${((disponiveis / total) * 100).toStringAsFixed(1)}% do total'
                  : '0% do total',
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            _SummaryCard(
              title: 'Em Campo',
              value: emCampo.toString(),
              subtitle: total > 0
                  ? '${((emCampo / total) * 100).toStringAsFixed(1)}% do total'
                  : '0% do total',
              icon: Icons.access_time,
              color: Colors.orange,
            ),
            _SummaryCard(
              title: 'Calibração Vencida',
              value: calibracaoVencida.toString(),
              subtitle: total > 0
                  ? '${((calibracaoVencida / total) * 100).toStringAsFixed(1)}% do total'
                  : '0% do total',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
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
          childAspectRatio: 2.2,
          children: List.generate(4, (index) => const _SummaryCardLoading()),
        );
      },
    );
  }

  Widget _buildFiltros(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros e Busca',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Busca
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por patrimônio',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                // Status
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _statusFiltro,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Todos os status')),
                      ..._status.map((status) =>
                          DropdownMenuItem(value: status, child: Text(status))),
                    ],
                    onChanged: (value) => setState(() => _statusFiltro = value),
                  ),
                ),
                const SizedBox(width: 16),
                // Calibração
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _calibracaoFiltro,
                    decoration: InputDecoration(
                      labelText: 'Calibração',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Todas as calibrações')),
                      ..._calibracoes.map((cal) =>
                          DropdownMenuItem(value: cal, child: Text(cal))),
                    ],
                    onChanged: (value) =>
                        setState(() => _calibracaoFiltro = value),
                  ),
                ),
                const SizedBox(width: 16),
                // Limpar Filtros
                OutlinedButton.icon(
                  onPressed: _limparFiltros,
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text('Limpar Filtros'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabelaInstrumentos(
      BuildContext context, List<repo.Instrumento> instrumentos) {
    if (instrumentos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.build_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum instrumento encontrado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Lista de Instrumentos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24.0,
              horizontalMargin: 16.0,
              headingRowHeight: 56.0,
              dataRowMinHeight: 64.0,
              dataRowMaxHeight: 80.0,
              columns: const [
                DataColumn(
                    label: Text('Patrimônio',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Descrição',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Status',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Responsável',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Local Atual',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Data Devolução Prevista',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Status Devolução',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Calibração',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Próxima Calibração',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Ações',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: instrumentos.map((repo.Instrumento instrumento) {
                return DataRow(
                  cells: [
                    DataCell(Text(instrumento.patrimonio ??
                        instrumento.numeroSerie ??
                        instrumento.id)),
                    DataCell(
                      SizedBox(
                        width: 250,
                        child: Text(
                          instrumento.nome,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(_buildStatusChip(instrumento.status)),
                    DataCell(
                      instrumento.responsavel != null &&
                              instrumento.dataEmprestimo != null
                          ? Text(
                              '${instrumento.responsavel}\n${_formatDate(instrumento.dataEmprestimo!)}',
                              style: const TextStyle(fontSize: 12),
                            )
                          : const Text('-'),
                    ),
                    DataCell(Text(instrumento.localizacao ?? '-')),
                    DataCell(
                      instrumento.dataDevolucaoPrevista != null
                          ? Text(
                              _formatDate(instrumento.dataDevolucaoPrevista!))
                          : const Text('-'),
                    ),
                    DataCell(_buildStatusDevolucaoChip(
                        instrumento.dataDevolucaoPrevista)),
                    DataCell(
                        _buildCalibracaoChip(instrumento.statusCalibracao)),
                    DataCell(
                      instrumento.proximaCalibracao != null
                          ? Text(_formatDate(instrumento.proximaCalibracao!))
                          : const Text('-'),
                    ),
                    DataCell(_buildAcoes(context, instrumento)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'disponivel':
        color = Colors.green;
        label = 'Disponível';
        break;
      case 'emprestado':
      case 'em_uso':
        color = Colors.orange;
        label = status == 'emprestado' ? 'Em Campo' : 'Em Uso';
        break;
      case 'manutencao':
        color = Colors.blue;
        label = 'Em Manutenção';
        break;
      default:
        color = Colors.grey;
        label = 'Indisponível';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusDevolucaoChip(DateTime? dataDevolucaoPrevista) {
    if (dataDevolucaoPrevista == null) {
      return const Text('-');
    }

    final agora = DateTime.now();
    final dataDevolucao = DateTime(
      dataDevolucaoPrevista.year,
      dataDevolucaoPrevista.month,
      dataDevolucaoPrevista.day,
    );
    final hoje = DateTime(agora.year, agora.month, agora.day);

    final diasAtraso = hoje.difference(dataDevolucao).inDays;

    Color color;
    String label;

    if (diasAtraso > 0) {
      // Atrasado
      color = Colors.red;
      label = 'Atrasado ${diasAtraso}d';
    } else if (diasAtraso == 0) {
      // Vence hoje
      color = Colors.orange;
      label = 'Vence hoje';
    } else {
      // Ainda não venceu
      final diasRestantes = -diasAtraso;
      if (diasRestantes <= 3) {
        color = Colors.orange;
        label = 'Vence em ${diasRestantes}d';
      } else {
        color = Colors.green;
        label = 'No prazo';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCalibracaoChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'ok':
        color = Colors.green;
        label = 'OK';
        break;
      case 'vencendo':
        color = Colors.orange;
        label = 'Vencendo';
        break;
      case 'vencida':
        color = Colors.red;
        label = 'Vencida';
        break;
      default:
        color = Colors.grey;
        label = '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAcoes(BuildContext context, repo.Instrumento instrumento) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (instrumento.isDisponivel)
          TextButton(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) =>
                    RetirarInstrumentoDialog(instrumento: instrumento),
              );
              if (result == true) {
                // Instrumento retirado com sucesso
              }
            },
            child: const Text('Retirar', style: TextStyle(fontSize: 12)),
          ),
        if (instrumento.isEmprestado)
          TextButton(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => const DevolverInstrumentoDialog(),
              );
              if (result == true) {
                // Instrumento devolvido
              }
            },
            child: const Text('Devolver', style: TextStyle(fontSize: 12)),
          ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  DetalhesInstrumentoDialog(instrumento: instrumento),
            );
          },
          child: const Text('Detalhes', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
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
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
