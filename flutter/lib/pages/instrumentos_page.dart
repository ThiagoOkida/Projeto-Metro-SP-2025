import 'package:flutter/material.dart';

class InstrumentosPage extends StatelessWidget {
  const InstrumentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A); // Cor Padrão

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TÍTULOS DA PÁGINA E BOTÃO NOVO INSTRUMENTO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Coluna para os textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instrumentos Técnicos',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Controle de retirada, devolução e calibração de instrumentos',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // Espaço entre o texto e o botão
                  // Botão de Novo Instrumento
                  ElevatedButton.icon(
                    onPressed: () {
                      // Ação para adicionar novo instrumento
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Novo Instrumento',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: metroBlue, // Cor do Metrô
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- SEÇÃO DE RESUMO DE INSTRUMENTOS (4 CARTÕES) ---
              _buildInstrumentSummary(context),
              const SizedBox(height: 24),

              // --- SEÇÃO DE FILTROS E BUSCA ---
              _buildFiltersAndSearch(context),
              const SizedBox(height: 24),

              // --- LISTA DE INSTRUMENTOS (TABELA) ---
              Text(
                'Lista de Instrumentos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 16),
              const _InstrumentTable(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO DE SEÇÕES ---

  Widget _buildInstrumentSummary(BuildContext context) {
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
            _SummaryCard(
              title: 'Total de Instrumentos',
              value: '686',
              details: 'Instrumentos cadastrados',
              icon: Icons.info_outline,
              iconColor: Colors.grey,
            ),
            _SummaryCard(
              title: 'Disponíveis',
              value: '524',
              details: '76.4% do total',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            ),
            _SummaryCard(
              title: 'Em Campo',
              value: '117',
              details: '17.1% do total',
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange,
            ),
            _SummaryCard(
              title: 'Calibração Vencida',
              value: '45',
              details: '6.5% do total',
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
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por patrimônio...',
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
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Todos os status',
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
                      DropdownMenuItem(value: 'disponivel', child: Text('Disponível')),
                      DropdownMenuItem(value: 'em_campo', child: Text('Em Campo')),
                      DropdownMenuItem(value: 'em_uso', child: Text('Em Uso')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Todas as categorias',
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
                      DropdownMenuItem(value: 'multimetro', child: Text('Multímetro')),
                      DropdownMenuItem(value: 'osciloscopio', child: Text('Osciloscópio')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Todas as calibrações',
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
                      DropdownMenuItem(value: 'ok', child: Text('OK')),
                      DropdownMenuItem(value: 'vencida', child: Text('Vencida')),
                      DropdownMenuItem(value: 'vencendo', child: Text('Vencendo')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    // Ação para limpar filtros
                  },
                  icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                  label: Text('Limpar Filtros', style: TextStyle(color: Colors.grey[700])),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS DE SUPORTE (PRIVADOS) ---

/// Card de Resumo (usado nos 4 cartões de cima)
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String details;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
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

/// Tabela de Instrumentos (com dados mockados)
class _InstrumentTable extends StatelessWidget {
  const _InstrumentTable();

  // Dados de exemplo para a tabela
  static const List<Map<String, String>> _instruments = [
    {
      'patrimonio': 'MT-4527',
      'descricao': 'Multímetro Digital Fluke 87V',
      'modelo': 'Fluke 87V',
      'status': 'Disponível',
      'responsavel': '-',
      'local': 'Base Jabaquara',
      'calibracao': 'OK',
      'proxima': '2025-12-15'
    },
    {
      'patrimonio': 'OSC-1234',
      'descricao': 'Osciloscópio Digital 100MHz',
      'modelo': 'Tektronix TBS1104',
      'status': 'Em Campo',
      'responsavel': 'João Silva',
      'local': 'Linha 1 - Estação Sé',
      'calibracao': 'Vencendo',
      'proxima': '2025-10-20'
    },
    {
      'patrimonio': 'MG-5678',
      'descricao': 'Megôhmetro 5kV',
      'modelo': 'Hioki IR4057',
      'status': 'Em Uso',
      'responsavel': 'Maria Santos',
      'local': 'Base Bresser',
      'calibracao': 'Vencida',
      'proxima': '2025-08-10'
    },
    {
      'patrimonio': 'TC-9812',
      'descricao': 'Alicate Amperímetro 1000A',
      'modelo': 'Fluke 376',
      'status': 'Disponível',
      'responsavel': '-',
      'local': 'Base Paraíso',
      'calibracao': 'OK',
      'proxima': '2026-03-15'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A);
    // Para telas muito pequenas, use uma Tabela rolável horizontalmente
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
                    columnSpacing: 16, 
                    dataRowMinHeight: 50,
                    dataRowMaxHeight: 65,
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) => Colors.grey[50]),
                    headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                    columns: const [
                      DataColumn(label: Text('PATRIMÔNIO')),
                      DataColumn(label: Text('DESCRIÇÃO')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('RESPONSÁVEL')),
                      DataColumn(label: Text('LOCAL ATUAL')),
                      DataColumn(label: Text('CALIBRAÇÃO')),
                      DataColumn(label: Text('PRÓXIMA CALIBRAÇÃO')),
                      DataColumn(label: Text('AÇÕES')),
                    ],
                    rows: _instruments.map((instrument) {
                      // Lógica para cor do Status
                      Color statusColor;
                      Color statusBgColor;
                      switch (instrument['status']) {
                        case 'Disponível':
                          statusColor = Colors.green[700]!;
                          statusBgColor = Colors.green[100]!;
                          break;
                        case 'Em Campo':
                          statusColor = Colors.orange[700]!;
                          statusBgColor = Colors.orange[100]!;
                          break;
                        case 'Em Uso':
                          statusColor = Colors.blue[700]!;
                          statusBgColor = Colors.blue[100]!;
                          break;
                        default:
                          statusColor = Colors.grey[700]!;
                          statusBgColor = Colors.grey[100]!;
                      }
                      
                      // Lógica para cor da Calibração
                      Color calColor;
                      switch (instrument['calibracao']) {
                        case 'OK':
                          calColor = Colors.green;
                          break;
                        case 'Vencendo':
                          calColor = Colors.orange;
                          break;
                        case 'Vencida':
                          calColor = Colors.red;
                          break;
                        default:
                          calColor = Colors.grey;
                      }

                      return DataRow(cells: [
                        DataCell(Text(instrument['patrimonio']!)),
                        DataCell(
                          SizedBox(
                            width: 200, 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  instrument['descricao']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  instrument['modelo']!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                        ),
                        DataCell(
                          Chip(
                            label: Text(
                              instrument['status']!,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: statusBgColor,
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        DataCell(Text(instrument['responsavel']!)),
                        DataCell(Text(instrument['local']!)),
                        DataCell(
                          Row(children: [
                            Icon(Icons.circle, color: calColor, size: 10),
                            const SizedBox(width: 8),
                            Text(instrument['calibracao']!),
                          ],)
                        ),
                        DataCell(Text(instrument['proxima']!)),
                        DataCell(
                          Row(
                            children: [
                              // Lógica de botões
                              if (instrument['status'] == 'Disponível')
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Retirar'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: metroBlue,
                                    side: BorderSide(color: metroBlue),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              if (instrument['status'] != 'Disponível')
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Devolver'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(color: Colors.orange),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {}, 
                                child: Text('Detalhes', style: TextStyle(color: metroBlue, decoration: TextDecoration.underline)),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero
                                ),
                              ),
                            ],
                          )
                        ),
                      ]);
                    }).toList(),
                  ),
                  // Paginação (igual à da tela de Materiais)
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '1-4 of 686', 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.grey),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.grey),
                        onPressed: () {},
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