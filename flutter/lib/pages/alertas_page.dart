import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';
import '../repositories/alertas_repository.dart' as repo;

class AlertasPage extends ConsumerStatefulWidget {
  const AlertasPage({super.key});

  @override
  ConsumerState<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends ConsumerState<AlertasPage> {
  String? _statusFiltro;
  String? _tipoFiltro;

  @override
  Widget build(BuildContext context) {
    final alertasAsync = ref.watch(alertasAtivosProvider);
    final todosAlertasAsync = ref.watch(alertasProvider);

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
                        'Central de Alertas',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestão de alertas e notificações do sistema',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _marcarTodosComoLidos(context),
                  icon: const Icon(Icons.notifications_none),
                  label: const Text('Marcar Todos como Lidos'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cards de Resumo
            todosAlertasAsync.when(
              data: (todosAlertas) {
                final pendentes = todosAlertas.where((a) => !a.resolvido).length;
                final altaPrioridade = todosAlertas.where((a) => !a.resolvido && (a.severidade == 'alta' || a.severidade == 'critica')).length;
                final hoje = DateTime.now();
                final resolvidosHoje = todosAlertas.where((a) {
                  if (!a.resolvido || a.resolvidoEm == null) return false;
                  return a.resolvidoEm!.year == hoje.year &&
                      a.resolvidoEm!.month == hoje.month &&
                      a.resolvidoEm!.day == hoje.day;
                }).length;

                return _buildSummaryCards(context, pendentes, altaPrioridade, resolvidosHoje);
              },
              loading: () => _buildSummaryCardsLoading(context),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // Filtros
            _buildFiltros(context),

            const SizedBox(height: 16),

            // Lista de Alertas
            alertasAsync.when(
              data: (alertas) {
                final filtrados = _filtrarAlertas(alertas);
                return _buildListaAlertas(context, filtrados);
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
                          'Erro ao carregar alertas: $error',
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

  List<repo.Alerta> _filtrarAlertas(List<repo.Alerta> alertas) {
    var filtrados = alertas;

    if (_statusFiltro != null && _statusFiltro != 'Todos Status') {
      filtrados = filtrados.where((a) {
        if (_statusFiltro == 'Pendente') return !a.resolvido;
        if (_statusFiltro == 'Resolvido') return a.resolvido;
        return true;
      }).toList();
    }

    if (_tipoFiltro != null && _tipoFiltro != 'Todas') {
      filtrados = filtrados.where((a) => a.tipo == _tipoFiltro?.toLowerCase().replaceAll(' ', '_')).toList();
    }

    return filtrados;
  }

  Widget _buildSummaryCards(BuildContext context, int pendentes, int altaPrioridade, int resolvidosHoje) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 900) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          children: [
            _SummaryCard(
              title: 'Alertas Pendentes',
              value: pendentes.toString(),
              subtitle: 'Requerem ação',
              icon: Icons.access_time,
              color: Colors.orange,
            ),
            _SummaryCard(
              title: 'Alta Prioridade',
              value: altaPrioridade.toString(),
              subtitle: 'Atenção urgente',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
            ),
            _SummaryCard(
              title: 'Resolvidos Hoje',
              value: resolvidosHoje.toString(),
              subtitle: 'Nas últimas 24h',
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCardsLoading(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 900) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          children: List.generate(3, (index) => const _SummaryCardLoading()),
        );
      },
    );
  }

  Widget _buildFiltros(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
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
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todos Status')),
                  DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                  DropdownMenuItem(value: 'Resolvido', child: Text('Resolvido')),
                ],
                onChanged: (value) => setState(() => _statusFiltro = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _tipoFiltro,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todas')),
                  DropdownMenuItem(value: 'Estoque Baixo', child: Text('Estoque Baixo')),
                  DropdownMenuItem(value: 'Calibração', child: Text('Calibração')),
                  DropdownMenuItem(value: 'Manutenção', child: Text('Manutenção')),
                ],
                onChanged: (value) => setState(() => _tipoFiltro = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaAlertas(BuildContext context, List<repo.Alerta> alertas) {
    if (alertas.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum alerta encontrado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: alertas.map((alerta) => _buildCardAlerta(context, alerta)).toList(),
    );
  }

  Future<void> _resolverAlerta(BuildContext context, repo.Alerta alerta) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolver Alerta'),
        content: Text('Deseja marcar o alerta "${alerta.titulo}" como resolvido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Resolver'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        final repository = ref.read(alertasRepositoryProvider);
        await repository.marcarAlertaComoResolvido(alerta.id);
        
        // Envia notificação por email para gestores e admins
        try {
          final emailService = ref.read(emailNotificationServiceProvider);
          await emailService.enviarNotificacao(
            assunto: 'Alerta Resolvido',
            mensagem: 'Um alerta foi marcado como resolvido no sistema.',
            tipoAlteracao: 'atualizar',
            entidade: 'alerta',
            detalhes: 'Alerta: ${alerta.titulo}\n'
                'Descrição: ${alerta.descricao}\n'
                'Tipo: ${alerta.tipo}\n'
                'Severidade: ${alerta.severidade}',
          );
        } catch (e) {
          debugPrint('Erro ao enviar notificação por email: $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Alerta "${alerta.titulo}" marcado como resolvido.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao resolver alerta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _ignorarAlerta(BuildContext context, repo.Alerta alerta) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ignorar Alerta'),
        content: Text('Deseja ignorar o alerta "${alerta.titulo}"? Ele será marcado como resolvido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ignorar'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        final repository = ref.read(alertasRepositoryProvider);
        await repository.ignorarAlerta(alerta.id);
        
        // Envia notificação por email para gestores e admins
        try {
          final emailService = ref.read(emailNotificationServiceProvider);
          await emailService.enviarNotificacao(
            assunto: 'Alerta Ignorado',
            mensagem: 'Um alerta foi ignorado no sistema.',
            tipoAlteracao: 'atualizar',
            entidade: 'alerta',
            detalhes: 'Alerta: ${alerta.titulo}\n'
                'Descrição: ${alerta.descricao}\n'
                'Tipo: ${alerta.tipo}\n'
                'Severidade: ${alerta.severidade}',
          );
        } catch (e) {
          debugPrint('Erro ao enviar notificação por email: $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Alerta "${alerta.titulo}" ignorado.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao ignorar alerta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _marcarTodosComoLidos(BuildContext context) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar Todos como Lidos'),
        content: const Text('Deseja marcar todos os alertas pendentes como resolvidos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        final repository = ref.read(alertasRepositoryProvider);
        await repository.marcarTodosComoLidos();
        
        // Envia notificação por email para gestores e admins
        try {
          final emailService = ref.read(emailNotificationServiceProvider);
          await emailService.enviarNotificacao(
            assunto: 'Todos os Alertas Marcados como Lidos',
            mensagem: 'Todos os alertas pendentes foram marcados como resolvidos no sistema.',
            tipoAlteracao: 'atualizar',
            entidade: 'alerta',
            detalhes: 'Ação realizada em massa: todos os alertas pendentes foram resolvidos.',
          );
        } catch (e) {
          debugPrint('Erro ao enviar notificação por email: $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todos os alertas foram marcados como lidos.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao marcar alertas: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildCardAlerta(BuildContext context, repo.Alerta alerta) {
    Color iconColor;
    IconData icon;
    Color priorityColor;
    String priorityLabel;

    switch (alerta.severidade) {
      case 'critica':
      case 'alta':
        iconColor = Colors.red;
        icon = Icons.warning;
        priorityColor = Colors.red;
        priorityLabel = 'HIGH';
        break;
      case 'media':
        iconColor = Colors.orange;
        icon = Icons.access_time;
        priorityColor = Colors.blue;
        priorityLabel = 'MEDIUM';
        break;
      default:
        iconColor = Colors.amber;
        icon = Icons.info_outline;
        priorityColor = Colors.grey;
        priorityLabel = 'LOW';
    }

    if (alerta.tipo == 'nova_entrada') {
      iconColor = Colors.amber;
      icon = Icons.inventory_2;
    }

    final dataFormatada = alerta.criadoEm != null
        ? '${alerta.criadoEm!.day.toString().padLeft(2, '0')}/${alerta.criadoEm!.month.toString().padLeft(2, '0')}/${alerta.criadoEm!.year} ${alerta.criadoEm!.hour.toString().padLeft(2, '0')}:${alerta.criadoEm!.minute.toString().padLeft(2, '0')}'
        : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: alerta.resolvido ? Colors.grey[50] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alerta.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: priorityColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          priorityLabel,
                          style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dataFormatada,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alerta.descricao,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: alerta.resolvido ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          alerta.resolvido ? 'Resolvido' : 'Pendente',
                          style: TextStyle(
                            color: alerta.resolvido ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!alerta.resolvido) ...[
                        TextButton(
                          onPressed: () => _resolverAlerta(context, alerta),
                          child: const Text('Resolver'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _ignorarAlerta(context, alerta),
                          child: const Text('Ignorar'),
                        ),
                      ],
                    ],
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
