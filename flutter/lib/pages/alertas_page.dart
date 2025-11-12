import 'package:flutter/material.dart';

class AlertasPage extends StatelessWidget {
  const AlertasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------- TÍTULO + BOTÃO -----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Central de Alertas',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gestão de alertas e notificações do sistema',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                    label: const Text('Marcar Todos como Lidos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: metroBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ----------------- CARDS DE RESUMO -----------------
              _buildAlertSummary(context),

              const SizedBox(height: 32),

              // ----------------- TÍTULO + FILTROS -----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Alertas Recentes",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),

                  // --------- FILTROS ---------
                  Row(
                    children: [
                      _buildDropdown(
                        items: const [
                          DropdownMenuItem(
                              value: 'todos', child: Text('Todos Status')),
                          DropdownMenuItem(
                              value: 'pendente', child: Text('Pendente')),
                          DropdownMenuItem(
                              value: 'resolvido', child: Text('Resolvido')),
                        ],
                        value: 'todos',
                        onChanged: (v) {},
                      ),
                      const SizedBox(width: 16),
                      _buildDropdown(
                        items: const [
                          DropdownMenuItem(
                              value: 'todas', child: Text('Todas')),
                          DropdownMenuItem(
                              value: 'estoque', child: Text('Estoque')),
                          DropdownMenuItem(
                              value: 'calibracao', child: Text('Calibração')),
                          DropdownMenuItem(
                              value: 'atraso', child: Text('Atraso')),
                        ],
                        value: 'todas',
                        onChanged: (v) {},
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ----------------- LISTA DE ALERTAS -----------------
              const _AlertListItem(
                title: 'Estoque Crítico - Aço Inox 304',
                timestamp: '15/01/2024 10:30',
                details:
                    'Apenas 5 unidades restantes. Necessário realizar pedido urgente.',
                level: 'HIGH',
                status: 'Pendente',
              ),
              const SizedBox(height: 16),

              const _AlertListItem(
                title: 'Calibração Vencida - Paquímetro Digital',
                timestamp: '15/01/2024 09:15',
                details: 'Calibração vencida há 3 dias. Requer atenção imediata.',
                level: 'MEDIUM',
                status: 'Pendente',
              ),
              const SizedBox(height: 16),

              const _AlertListItem(
                title: 'Nova Entrada de Material',
                timestamp: '15/01/2024 08:45',
                details:
                    'Alumínio 6061 - 150 unidades recebidas e conferidas.',
                level: 'LOW',
                status: 'Resolvido',
              ),
              const SizedBox(height: 16),

              const _AlertListItem(
                title: 'Estoque Baixo - Bronze SAE 40',
                timestamp: '14/01/2024 16:20',
                details:
                    'Nível de estoque abaixo do mínimo recomendado.',
                level: 'MEDIUM',
                status: 'Pendente',
              ),
              const SizedBox(height: 16),

              const _AlertListItem(
                title: 'Instrumento Não Devolvido',
                timestamp: '14/01/2024 14:10',
                details:
                    'Micrômetro 0-25mm não devolvido há 7 dias pelo setor de Usinagem.',
                level: 'HIGH',
                status: 'Pendente',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =================================================================
  // RESUMO — GRID 3 ITENS
  // =================================================================

  Widget _buildAlertSummary(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int cross = 3;
        double ratio = 2.5;

        if (constraints.maxWidth < 900 && constraints.maxWidth >= 600) {
          cross = 2;
        } else if (constraints.maxWidth < 600) {
          cross = 1;
          ratio = 3.5;
        }

        return GridView.count(
          crossAxisCount: cross,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: ratio,
          children: const [
            _SummaryCard(
              title: "Alertas Pendentes",
              value: "4",
              details: "Requerem ação",
              icon: Icons.info_outline,
              iconColor: Colors.grey,
            ),
            _SummaryCard(
              title: "Alta Prioridade",
              value: "2",
              details: "Atenção urgente",
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.red,
            ),
            _SummaryCard(
              title: "Resolvidos Hoje",
              value: "1",
              details: "Nas últimas 24h",
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            ),
          ],
        );
      },
    );
  }

  // Dropdown padrão
  Widget _buildDropdown({
    required List<DropdownMenuItem<String>> items,
    required String value,
    required Function(String?) onChanged,
  }) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}

// =================================================================
// WIDGETS PRIVADOS
// =================================================================

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
                  child: Text(title,
                      style: theme.titleMedium
                          ?.copyWith(color: Colors.grey[700])),
                ),
                Icon(icon, color: iconColor),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: theme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),

            const SizedBox(height: 6),

            Text(details,
                style:
                    theme.bodyMedium?.copyWith(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _AlertListItem extends StatelessWidget {
  final String title;
  final String timestamp;
  final String details;
  final String level;
  final String status;

  const _AlertListItem({
    required this.title,
    required this.timestamp,
    required this.details,
    required this.level,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A);

    // Cor por nível
    final Color color;
    final IconData icon;
    switch (level) {
      case "HIGH":
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      case "MEDIUM":
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_outline;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //---------------- TÍTULO ----------------
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Text(timestamp,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 8),
                Chip(
                  label: Text(level),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                )
              ],
            ),

            const SizedBox(height: 10),

            //---------------- DETALHES ----------------
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(details,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),

            const Divider(height: 26),

            //---------------- AÇÕES ----------------
            Row(
              children: [
                Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: status == "Resolvido"
                            ? Colors.green
                            : Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const Spacer(),
                if (status == "Pendente") ...[
                  TextButton(
                    onPressed: () {},
                    child: const Text("Ignorar"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: metroBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Resolver"),
                  )
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
