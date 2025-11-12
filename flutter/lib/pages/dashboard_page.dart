import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Visão geral do sistema de gestão de materiais e instrumentos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Chip(
                    avatar: Icon(Icons.circle,
                        color: Colors.green[700], size: 12),
                    label: const Text('Sistema Online'),
                    labelStyle: TextStyle(
                      color: Colors.green[900],
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: Colors.green[100],
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSummaryGrid(context),

              const SizedBox(height: 24),

              _buildAlertsAndActivity(context),

              const SizedBox(height: 24),

              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------ GRID SUPERIOR ------------------------------

  Widget _buildSummaryGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int cross = 4;
        final double width = constraints.maxWidth;
        double ratio = width < 600 ? 2.8 : 2.2;

        if (width < 1200 && width >= 600) {
          cross = 2;
          ratio = 2.5;
        } else if (width < 600) {
          cross = 1;
        }

        return GridView.count(
          crossAxisCount: cross,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: ratio,
          children: const [
            _SummaryCard(
              title: 'Total de Materiais',
              value: '1.372',
              subtitle: '+12 este mês',
              subtitleColor: Colors.green,
              details: 'Tipos diferentes de materiais',
              icon: Icons.inventory_2_outlined,
            ),
            _SummaryCard(
              title: 'Instrumentos Ativos',
              value: '686',
              subtitle: '45 em campo',
              details: 'Instrumentos técnicos cadastrados',
              icon: Icons.construction_outlined,
            ),
            _SummaryCard(
              title: 'Alertas Ativos',
              value: '23',
              subtitle: '5 desde ontem',
              subtitleColor: Colors.red,
              details: 'Requerem atenção imediata',
              icon: Icons.warning_amber_rounded,
            ),
            _SummaryCard(
              title: 'Bases Operacionais',
              value: '12',
              subtitle: '100% ativas',
              subtitleColor: Colors.blue,
              details: 'Bases de manutenção',
              icon: Icons.home_work_outlined,
            ),
          ],
        );
      },
    );
  }

  // ------------------------------ ALERTAS + ATIVIDADE ------------------------------

  Widget _buildAlertsAndActivity(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              _buildAlertsColumn(context),
              const SizedBox(height: 16),
              _buildActivityColumn(context),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _buildAlertsColumn(context)),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: _buildActivityColumn(context)),
          ],
        );
      },
    );
  }

  Widget _buildAlertsColumn(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Alertas Recentes',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text('Ver Todos', style: TextStyle(color: metroBlue)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const _AlertCard(
              title: 'Estoque Baixo - Conectores',
              subtitle: '2 horas atrás',
              details:
                  'Base Jabaquara: Conectores RJ45 com apenas 5 unidades restantes',
              level: 'HIGH',
            ),
            const Divider(),

            const _AlertCard(
              title: 'Calibração Vencida',
              subtitle: '1 dia atrás',
              details:
                  'Multímetros #MT-4527 venceu calibração em 15/09/2025',
              level: 'MEDIUM',
            ),
            const Divider(),

            const _AlertCard(
              title: 'Instrumento em Atraso',
              subtitle: '3 dias atrás',
              details:
                  'Osciloscópio #OSC-1234 não devolvido por João Silva há 3 dias',
              level: 'HIGH',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityColumn(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atividade Recente',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            const _ActivityItem(
              icon: Icons.upload_rounded,
              iconColor: Colors.orange,
              title: 'Saída de Material',
              details: 'Paulo Silva retirou 10x Cabos de Rede - Base Sé',
              time: '10:30',
            ),
            const _ActivityItem(
              icon: Icons.move_down_rounded,
              iconColor: Colors.blue,
              title: 'Devolução de Instrumento',
              details: 'Marcos Santos devolveu Multímetro #MT-4525',
              time: '09:15',
            ),
            const _ActivityItem(
              icon: Icons.download_rounded,
              iconColor: Colors.green,
              title: 'Entrada de Material',
              details: 'Recebimento de 50x Conectores RJ45 - Base Jabaquara',
              time: '08:45',
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------ AÇÕES RÁPIDAS ------------------------------

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            int cross = 4;

            if (constraints.maxWidth < 900 && constraints.maxWidth >= 600) {
              cross = 2;
            } else if (constraints.maxWidth < 600) {
              cross = 1;
            }

            return GridView.count(
              crossAxisCount: cross,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio:
                  constraints.maxWidth < 600 ? 4.5 : 2.8,
              children: const [
                _ActionCard(
                  title: 'Nova Requisição',
                  icon: Icons.add_shopping_cart,
                ),
                _ActionCard(
                  title: 'Devolver Instrumento',
                  icon: Icons.move_down_rounded,
                ),
                _ActionCard(
                  title: 'Relatório Mensal',
                  icon: Icons.assessment_outlined,
                ),
                _ActionCard(
                  title: 'Gerenciar Usuários',
                  icon: Icons.people_outline,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ========================================================================
// ============================= WIDGETS AUXILIARES ========================
// ========================================================================

class _SummaryCard extends StatelessWidget {
  final String title, value, subtitle, details;
  final IconData icon;
  final Color? subtitleColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.details,
    required this.icon,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color color = subtitleColor ?? Colors.grey.shade700;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Icon(icon, color: Colors.grey[500]),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              value,
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            Chip(
              label: Text(subtitle),
              labelStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              backgroundColor: color.withOpacity(0.1),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),

            const SizedBox(height: 12),

            Text(
              details,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title, subtitle, details, level;

  const _AlertCard({
    required this.title,
    required this.subtitle,
    required this.details,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level) {
      case 'HIGH':
        color = Colors.red;
        break;
      case 'MEDIUM':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(level),
                    backgroundColor: color.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(details,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),

        TextButton(
          onPressed: () {},
          child: const Text(
            'Resolver',
            style: TextStyle(color: Color(0xFF003C8A)),
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, details, time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.details,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(details,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ActionCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: metroBlue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
