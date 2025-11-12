import 'package:flutter/material.dart';

class MaterialsPage extends StatelessWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const SizedBox(height: 8),
                        Text(
                          'Gestão e controle de materiais de consumo e específicos',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Novo Material',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003C8A), 
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStockSummary(context),
              const SizedBox(height: 24),
              _buildFiltersAndSearch(context),
              const SizedBox(height: 24),
              Text(
                'Lista de Materiais',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 16),
              const _MaterialTable(), 
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStockSummary(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        double childAspectRatio = 2.0;

        if (constraints.maxWidth < 1200 && constraints.maxWidth >= 700) {
          crossAxisCount = 2;
          childAspectRatio = 2.5;
        } else if (constraints.maxWidth < 700) {
          crossAxisCount = 1;
          childAspectRatio = 3.5;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: const [
            _MaterialSummaryCard(
              title: 'Total de Materiais',
              value: '1.372',
              details: 'Tipos cadastrados',
              icon: Icons.info_outline,
              iconColor: Colors.grey,
            ),
            _MaterialSummaryCard(
              title: 'Em Estoque Normal',
              value: '1.285',
              details: '93.7% do total',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            ),
            _MaterialSummaryCard(
              title: 'Estoque Baixo',
              value: '67',
              details: '4.9% do total',
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange,
            ),
            _MaterialSummaryCard(
              title: 'Crítico',
              value: '20',
              details: '1.4% do total',
              icon: Icons.error_outline,
              iconColor: Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersAndSearch(BuildContext context) {
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
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por código ou descrição...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Tipo de Material',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), 
                    ),
                    value: null,
                    items: const [
                      DropdownMenuItem(value: 'consumo', child: Text('Consumo Regular')),
                      DropdownMenuItem(value: 'especifico', child: Text('Consumo Específico')),
                    ],
                    onChanged: (value) {
                      // Ação ao mudar o tipo
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Status do Estoque',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), 
                    ),
                    value: null,
                    items: const [
                      DropdownMenuItem(value: 'normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'baixo', child: Text('Baixo')),
                      DropdownMenuItem(value: 'critico', child: Text('Crítico')),
                    ],
                    onChanged: (value) {
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                },
                icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                label: Text('Limpar Filtros', style: TextStyle(color: Colors.grey[700])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _MaterialSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String details;
  final IconData icon;
  final Color iconColor;

  const _MaterialSummaryCard({
    required this.title,
    required this.value,
    required this.details,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                ),
                const Spacer(),
                Icon(icon, color: iconColor),
              ],
            ),
            Text(
              value,
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              details,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialTable extends StatelessWidget {
  const _MaterialTable();
  static const List<Map<String, String>> _materials = [
    {
      'code': '0000000001024659',
      'description': 'PROTETOR AUDITIVO DO TIPO CONCHA, CONSTITUIDO POR DU...',
      'type': 'Material de Consumo Regular',
      'unit': 'Peça',
      'balance': '234',
      'min_stock': '50',
      'status': 'Normal'
    },
    {
      'code': '0000000001024460',
      'description': 'ACELERADOR DE CHOQUE CONJUNTO PARA DISJUNTOR HBS480...',
      'type': 'Material de Consumo Específico',
      'unit': 'Peça',
      'balance': '8',
      'min_stock': '15',
      'status': 'Estoque Baixo'
    },
    {
      'code': '0000000001024461',
      'description': 'ABSORVEDOR DE CHOQUE PARA DISJUNTOR HBS45 DA SECHER...',
      'type': 'Material de Consumo Regular',
      'unit': 'Peça',
      'balance': '156',
      'min_stock': '30',
      'status': 'Normal'
    },
    {
      'code': '0000000001024462',
      'description': 'JUNTA DE ACABAMENTO DA GRELHA DO SISTEMA DE AR CONDI...',
      'type': 'Material de Consumo Regular',
      'unit': 'Peça',
      'balance': '2',
      'min_stock': '20',
      'status': 'Crítico'
    },
    {
      'code': '0000000001024650',
      'description': 'PARAFUSO SEXTAVADO M8X20 INOX',
      'type': 'Material de Consumo Regular',
      'unit': 'Unidade',
      'balance': '500',
      'min_stock': '100',
      'status': 'Normal'
    },
    {
      'code': '0000000001024651',
      'description': 'GRAXA LÍTIO MP2 500G',
      'type': 'Material de Consumo Específico',
      'unit': 'Pote',
      'balance': '10',
      'min_stock': '5',
      'status': 'Estoque Baixo'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  DataTable(
                    columnSpacing: 20, 
                    dataRowMinHeight: 50,
                    dataRowMaxHeight: 60,
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) => Colors.grey[50]),
                    headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                    columns: const [
                      DataColumn(label: Text('CÓDIGO')),
                      DataColumn(label: Text('DESCRIÇÃO')),
                      DataColumn(label: Text('TIPO')),
                      DataColumn(label: Text('UNIDADE')),
                      DataColumn(label: Text('SALDO TOTAL')),
                      DataColumn(label: Text('STATUS')),
                    ],
                    rows: _materials.map((material) {
                      Color statusColor;
                      Color statusBgColor;
                      switch (material['status']) {
                        case 'Normal':
                          statusColor = Colors.green[700]!;
                          statusBgColor = Colors.green[100]!;
                          break;
                        case 'Estoque Baixo':
                          statusColor = Colors.orange[700]!;
                          statusBgColor = Colors.orange[100]!;
                          break;
                        case 'Crítico':
                          statusColor = Colors.red[700]!;
                          statusBgColor = Colors.red[100]!;
                          break;
                        default:
                          statusColor = Colors.grey[700]!;
                          statusBgColor = Colors.grey[100]!;
                      }
    
                      return DataRow(cells: [
                        DataCell(Text(material['code']!)),
                        DataCell(SizedBox(
                          width: 250, 
                          child: Text(
                            material['description']!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        )),
                        DataCell(Text(material['type']!)),
                        DataCell(Text(material['unit']!)),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              material['balance']!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Min: ${material['min_stock']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        )),
                        DataCell(
                          Chip(
                            label: Text(
                              material['status']!,
                              style: TextStyle(color: statusColor, fontSize: 12),
                            ),
                            backgroundColor: statusBgColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            labelPadding: EdgeInsets.zero,
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '1-6 of 1.372', 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.grey),
                        onPressed: () {
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.grey),
                        onPressed: () {
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}