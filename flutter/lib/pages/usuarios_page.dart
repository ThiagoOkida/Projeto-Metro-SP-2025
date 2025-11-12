import 'package:flutter/material.dart';

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //---------------------- TÍTULO ----------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gerenciamento de Usuários",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Controle de acesso e permissões dos usuários do sistema",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Novo Usuário",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: metroBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            //---------------------- RESUMO SUPERIOR ----------------------
            _buildUserSummary(context),

            const SizedBox(height: 24),

            //---------------------- FILTROS ----------------------
            _buildFiltersAndSearch(context),

            const SizedBox(height: 32),

            //---------------------- LISTA DE USUÁRIOS ----------------------
            Text(
              "Lista de Usuários",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 16),

            const _UserTable(),
          ],
        ),
      ),
    );
  }

  // =======================================================================
  // RESUMO SUPERIOR (3 CARDS)
  // =======================================================================

  Widget _buildUserSummary(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int cross = 3;
        double ratio = 2.4;

        if (constraints.maxWidth < 900 && constraints.maxWidth >= 600) {
          cross = 2;
        } else if (constraints.maxWidth < 600) {
          cross = 1;
          ratio = 3.2;
        }

        return GridView.count(
          crossAxisCount: cross,
          childAspectRatio: ratio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            _SummaryCard(
              title: "Total de Usuários",
              value: "48",
              details: "Contas cadastradas",
              icon: Icons.people_outline,
              iconColor: Colors.grey,
            ),
            _SummaryCard(
              title: "Usuários Ativos",
              value: "45",
              details: "93.7% do total",
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            ),
            _SummaryCard(
              title: "Administradores",
              value: "3",
              details: "Contas com privilégios",
              icon: Icons.admin_panel_settings_outlined,
              iconColor: Colors.blue,
            ),
          ],
        );
      },
    );
  }

  // =======================================================================
  // FILTROS
  // =======================================================================

  Widget _buildFiltersAndSearch(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 900;

            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  _buildNivelDropdown(),
                  const SizedBox(height: 16),
                  _buildStatusDropdown(),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text("Limpar filtros"),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 3, child: _buildSearchField()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildNivelDropdown()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildStatusDropdown()),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close, color: Colors.grey),
                  label: Text(
                    "Limpar Filtros",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- Widgets dos filtros ----

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar por nome ou matrícula...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      ),
    );
  }

  Widget _buildNivelDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _dropdownDecoration(),
      items: const [
        DropdownMenuItem(value: 'admin', child: Text("Administrador")),
        DropdownMenuItem(value: 'tecnico', child: Text("Técnico")),
        DropdownMenuItem(value: 'gestor', child: Text("Gestor")),
      ],
      onChanged: (v) {},
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _dropdownDecoration(),
      items: const [
        DropdownMenuItem(value: 'ativo', child: Text("Ativo")),
        DropdownMenuItem(value: 'inativo', child: Text("Inativo")),
      ],
      onChanged: (v) {},
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      hintText: "Selecione",
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}

// =======================================================================
// CARD DE RESUMO
// =======================================================================

class _SummaryCard extends StatelessWidget {
  final String title, value, details;
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
    final theme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ),
                Icon(icon, color: iconColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              details,
              style: theme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// TABELA DE USUÁRIOS
// =======================================================================

class _UserTable extends StatelessWidget {
  const _UserTable();

  static const List<Map<String, String>> users = [
    {
      'nome': 'João C. Silva',
      'matricula': '12345-6',
      'email': 'joao.silva@metro.sp.gov.br',
      'nivel': 'Administrador',
      'status': 'Ativo',
    },
    {
      'nome': 'Maria Santos',
      'matricula': '54321-0',
      'email': 'maria.santos@metro.sp.gov.br',
      'nivel': 'Técnico',
      'status': 'Ativo',
    },
    {
      'nome': 'Paulo Oliveira',
      'matricula': '67890-1',
      'email': 'paulo.oliveira@metro.sp.gov.br',
      'nivel': 'Gestor de Base',
      'status': 'Ativo',
    },
    {
      'nome': 'Ana Costa',
      'matricula': '11223-3',
      'email': 'ana.costa@metro.sp.gov.br',
      'nivel': 'Técnico',
      'status': 'Inativo',
    },
    {
      'nome': 'Marcos Santos',
      'matricula': '33445-5',
      'email': 'marcos.santos@metro.sp.gov.br',
      'nivel': 'Técnico',
      'status': 'Ativo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            headingRowHeight: 48,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 80,
            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
            columns: const [
              DataColumn(label: Text("NOME")),
              DataColumn(label: Text("MATRÍCULA")),
              DataColumn(label: Text("NÍVEL")),
              DataColumn(label: Text("STATUS")),
              DataColumn(label: Text("AÇÕES")),
            ],
            rows: users.map((user) {
              final bool ativo = user['status'] == 'Ativo';
              final Color statusColor =
                  ativo ? Colors.green[700]! : Colors.grey[700]!;
              final Color statusBg =
                  ativo ? Colors.green[100]! : Colors.grey[200]!;

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['nome']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user['email']!,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(user['matricula']!)),
                  DataCell(Text(user['nivel']!)),
                  DataCell(
                    Chip(
                      label: Text(
                        user['status']!,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: statusBg,
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("Editar"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: metroBlue,
                            side: BorderSide(color: metroBlue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Permissões",
                            style: TextStyle(
                              color: metroBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
