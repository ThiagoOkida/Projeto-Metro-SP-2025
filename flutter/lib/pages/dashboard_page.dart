import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/data_providers.dart';
import '../repositories/dashboard_repository.dart';
import '../widgets/nova_requisicao_dialog.dart';
import '../widgets/devolver_instrumento_dialog.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
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
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Visão geral do sistema de gestão de materiais e instrumentos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Chip(
                    avatar: Icon(
                      Icons.circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 12,
                    ),
                    label: const Text('Sistema Online'),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSummaryGrid(context, ref, statsAsync),
              const SizedBox(height: 24),
              _buildAcoesRapidas(context, ref),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, WidgetRef ref,
      AsyncValue<DashboardStats> statsAsync) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4; 
        double screenWidth = constraints.maxWidth;

        if (screenWidth < 1200) {
          crossAxisCount = 2; 
        }
        if (screenWidth < 600) {
          crossAxisCount = 1; 
        }
        return statsAsync.when(
          data: (stats) => GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: (crossAxisCount == 1) ? 2.5 : 2.0,
            children: [
              _SummaryCard(
                title: 'Total de Materiais',
                value: stats.totalMateriais.toString(),
                subtitle: '${stats.materiaisCriticos} críticos',
                details: 'Tipos diferentes de materiais',
                icon: Icons.inventory_2_outlined,
                subtitleColor:
                    stats.materiaisCriticos > 0 ? Colors.red : Colors.green,
              ),
              _SummaryCard(
                title: 'Instrumentos Ativos',
                value: stats.instrumentosAtivos.toString(),
                subtitle: '${stats.totalInstrumentos} total',
                details: 'Instrumentos técnicos cadastrados',
                icon: Icons.construction_outlined,
              ),
              _SummaryCard(
                title: 'Alertas Ativos',
                value: stats.alertasAtivos.toString(),
                subtitle:
                    stats.alertasAtivos > 0 ? 'Requerem atenção' : 'Tudo ok',
                details: 'Requerem atenção imediata',
                icon: Icons.warning_amber_rounded,
                subtitleColor:
                    stats.alertasAtivos > 0 ? Colors.red : Colors.green,
              ),
              const _SummaryCard(
                title: 'Bases Operacionais',
                value: '12',
                subtitle: '100% ativas',
                details: 'Bases de manutenção',
                icon: Icons.home_work_outlined,
                subtitleColor: Colors.blue,
              ),
            ],
          ),
          loading: () => GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: (crossAxisCount == 1) ? 2.5 : 2.0,
            children: List.generate(4, (index) => const _SummaryCardLoading()),
          ),
          error: (error, stack) => GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: (crossAxisCount == 1) ? 2.5 : 2.0,
            children: [
              _SummaryCard(
                title: 'Erro ao carregar',
                value: '--',
                subtitle: 'Verifique conexão',
                details: error.toString(),
                icon: Icons.error_outline,
                subtitleColor: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildAcoesRapidas(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ações Rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 4; 
                if (constraints.maxWidth < 1200) {
                  crossAxisCount = 2;
                }
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1; 
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.5,
                  children: [
                    _AcaoRapidaCard(
                      icon: Icons.description_outlined,
                      title: 'Nova Requisição',
                      onTap: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) => const NovaRequisicaoDialog(),
                        );
                        if (result == true) {
                        }
                      },
                    ),
                    _AcaoRapidaCard(
                      icon: Icons.assignment_return,
                      title: 'Devolver Instrumento',
                      onTap: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) => const DevolverInstrumentoDialog(),
                        );
                        if (result == true) {
                        }
                      },
                    ),
                    _AcaoRapidaCard(
                      icon: Icons.bar_chart,
                      title: 'Relatório Mensal',
                      onTap: () {
                        context.push('/relatorios');
                      },
                    ),
                    _AcaoRapidaCard(
                      icon: Icons.people_outline,
                      title: 'Gerenciar Usuários',
                      onTap: () {
                        context.push('/usuarios');
                      },
                    ),
                  ],
                );
              },
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
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Icon(Icons.inventory_2_outlined, color: Colors.grey[300]),
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
            const Spacer(),
            Container(
              width: 150,
              height: 14,
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String details;
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
                  style:
                      textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
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
                color: subtitleColor != null ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              backgroundColor: subtitleColor ?? Colors.grey[200],
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),

            const Spacer(), 
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
class _AcaoRapidaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AcaoRapidaCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
