import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';
import '../repositories/materiais_repository.dart' as repo show Material;
import '../widgets/novo_material_dialog.dart';

class MateriaisPage extends ConsumerStatefulWidget {
  const MateriaisPage({super.key});

  @override
  ConsumerState<MateriaisPage> createState() => _MateriaisPageState();
}

class _MateriaisPageState extends ConsumerState<MateriaisPage> {
  final _searchController = TextEditingController();
  String? _tipoFiltro;
  String? _statusFiltro;
  List<String> _categorias = [];
  final List<String> _status = ['Normal', 'Estoque Baixo', 'Crítico'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _limparFiltros() {
    setState(() {
      _searchController.clear();
      _tipoFiltro = null;
      _statusFiltro = null;
    });
  }

  List<repo.Material> _filtrarMateriais(List<repo.Material> materiais) {
    var filtrados = materiais;
    if (_searchController.text.isNotEmpty) {
      final busca = _searchController.text.toLowerCase();
      filtrados = filtrados.where((m) {
        final codigo = m.codigo?.toLowerCase() ?? '';
        final descricao = m.descricao?.toLowerCase() ?? m.nome.toLowerCase();
        return codigo.contains(busca) || descricao.contains(busca);
      }).toList();
    }

    if (_tipoFiltro != null) {
      filtrados = filtrados.where((m) {
        return (m.categoria == _tipoFiltro) || (m.tipo == _tipoFiltro);
      }).toList();
    }

    if (_statusFiltro != null) {
      filtrados = filtrados.where((m) {
        switch (_statusFiltro) {
          case 'Normal':
            return m.estoqueNormal;
          case 'Estoque Baixo':
            return m.estoqueBaixo;
          case 'Crítico':
            return m.estoqueCritico;
          default:
            return true;
        }
      }).toList();
    }

    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    final materiaisAsync = ref.watch(materiaisProvider);
    materiaisAsync.whenData((materiais) {
      final categoriasUnicas = materiais
          .where((m) => m.categoria != null && m.categoria!.isNotEmpty)
          .map((m) => m.categoria!)
          .toSet()
          .toList()
        ..sort();
      
      if (categoriasUnicas.join(',') != _categorias.join(',')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _categorias = categoriasUnicas;
            });
          }
        });
      }
    });

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
                        'Catálogo de Materiais',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestão e controle de materiais de consumo e específicos',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => const NovoMaterialDialog(),
                    );
                    if (result == true) {
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Novo Material'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            materiaisAsync.when(
              data: (materiais) {
                final total = materiais.length;
                final normais = materiais.where((m) => m.estoqueNormal).length;
                final baixos = materiais.where((m) => m.estoqueBaixo).length;
                final criticos = materiais.where((m) => m.estoqueCritico).length;

                return _buildSummaryCards(context, total, normais, baixos, criticos);
              },
              loading: () => _buildSummaryCardsLoading(context),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),
            _buildFiltros(context),
            const SizedBox(height: 16),
            materiaisAsync.when(
              data: (materiais) {
                final filtrados = _filtrarMateriais(materiais);
                return _buildTabelaMateriais(context, filtrados);
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
                          'Erro ao carregar materiais: $error',
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
    int normais,
    int baixos,
    int criticos,
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
              title: 'Total de Materiais',
              value: total.toString(),
              subtitle: 'tipos cadastrados',
              icon: Icons.inventory_2_outlined,
              color: Colors.blue,
            ),
            _SummaryCard(
              title: 'Em Estoque Normal',
              value: normais.toString(),
              subtitle: total > 0 ? '${((normais / total) * 100).toStringAsFixed(1)}% do total' : '0% do total',
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            _SummaryCard(
              title: 'Estoque Baixo',
              value: baixos.toString(),
              subtitle: total > 0 ? '${((baixos / total) * 100).toStringAsFixed(1)}% do total' : '0% do total',
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
            ),
            _SummaryCard(
              title: 'Crítico',
              value: criticos.toString(),
              subtitle: total > 0 ? '${((criticos / total) * 100).toStringAsFixed(1)}% do total' : '0% do total',
              icon: Icons.error_outline,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;
        
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
                if (isSmallScreen) ...[
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por código ou descrição...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _tipoFiltro,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Material',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ..._categorias.map((categoria) => DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      )),
                    ],
                    onChanged: (value) => setState(() => _tipoFiltro = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _statusFiltro,
                    decoration: InputDecoration(
                      labelText: 'Status do Estoque',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ..._status.map((status) => DropdownMenuItem(value: status, child: Text(status))),
                    ],
                    onChanged: (value) => setState(() => _statusFiltro = value),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _limparFiltros,
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: const Text('Limpar Filtros'),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar por código ou descrição...',
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
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _tipoFiltro,
                          decoration: InputDecoration(
                            labelText: 'Tipo de Material',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Todos')),
                            ..._categorias.map((categoria) => DropdownMenuItem(
                              value: categoria,
                              child: Text(categoria),
                            )),
                          ],
                          onChanged: (value) => setState(() => _tipoFiltro = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _statusFiltro,
                          decoration: InputDecoration(
                            labelText: 'Status do Estoque',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Todos')),
                            ..._status.map((status) => DropdownMenuItem(value: status, child: Text(status))),
                          ],
                          onChanged: (value) => setState(() => _statusFiltro = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _limparFiltros,
                        icon: const Icon(Icons.filter_alt_outlined),
                        label: const Text('Limpar Filtros'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabelaMateriais(BuildContext context, List<repo.Material> materiais) {
    if (materiais.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum material encontrado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Lista de Materiais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materiais.length,
                itemBuilder: (context, index) {
                  return _buildMaterialCard(context, materiais[index]);
                },
              ),
            ],
          );
        }
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Lista de Materiais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Código')),
                    DataColumn(label: Text('Descrição')),
                    DataColumn(label: Text('Tipo')),
                    DataColumn(label: Text('Unidade')),
                    DataColumn(label: Text('Saldo Total')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: materiais.map((repo.Material material) {
                    return DataRow(
                      cells: [
                        DataCell(Text(material.codigo ?? material.id)),
                        DataCell(
                          SizedBox(
                            width: 300,
                            child: Text(
                              material.descricao ?? material.nome,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(material.tipo ?? material.categoria ?? '-')),
                        DataCell(Text(material.unidade ?? 'Peça')),
                        DataCell(Text(
                          '${material.quantidade}${material.quantidadeMinima != null ? ' (Min: ${material.quantidadeMinima})' : ''}',
                        )),
                        DataCell(_buildStatusChip(material.statusEstoque)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaterialCard(BuildContext context, repo.Material material) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.descricao ?? material.nome,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Código: ${material.codigo ?? material.id}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(material.statusEstoque),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildInfoItem(
                  context,
                  Icons.category,
                  'Tipo',
                  material.tipo ?? material.categoria ?? '-',
                ),
                _buildInfoItem(
                  context,
                  Icons.scale,
                  'Unidade',
                  material.unidade ?? 'Peça',
                ),
                _buildInfoItem(
                  context,
                  Icons.inventory,
                  'Saldo Total',
                  '${material.quantidade}',
                ),
                if (material.quantidadeMinima != null)
                  _buildInfoItem(
                    context,
                    Icons.warning_amber_rounded,
                    'Mínimo',
                    '${material.quantidadeMinima}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'normal':
        color = Colors.green;
        label = 'Normal';
        break;
      case 'baixo':
        color = Colors.orange;
        label = 'Estoque Baixo';
        break;
      case 'critico':
        color = Colors.red;
        label = 'Crítico';
        break;
      default:
        color = Colors.grey;
        label = 'Desconhecido';
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
