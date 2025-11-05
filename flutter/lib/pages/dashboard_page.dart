import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Adicionamos um Scaffold para dar uma cor de fundo padrão (branco)
      // e estrutura para futuras barras de app, se necessário.
      backgroundColor: Colors.grey[100], 
      body: SingleChildScrollView(
        // SingleChildScrollView permite que a tela role em telas menores
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Padding geral da página
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Títulos da página
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
                  Text(
                    'Visão geral do sistema de gestão de materiais e instrumentos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const Spacer(),
                  // "Chip" de Status Online
                  Chip(
                    avatar: Icon(Icons.circle, color: Colors.green[700], size: 12),
                    label: const Text('Sistema Online'),
                    labelStyle: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w500),
                    backgroundColor: Colors.green[100],
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Espaço antes do grid

              // --- Grid de Resumo ---
              _buildSummaryGrid(context),

              const SizedBox(height: 24),

              // --- Próximas Seções (Alertas e Atividade) ---
              // Vamos adicionar o conteúdo aqui nas próximas etapas
              // _buildAlertsAndActivity(context),

            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o grid de 4 colunas que se adapta ao tamanho da tela.
  Widget _buildSummaryGrid(BuildContext context) {
    // LayoutBuilder é usado para pegar o tamanho da tela e tornar o grid responsivo
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4; // Padrão (desktop)
        double screenWidth = constraints.maxWidth;

        if (screenWidth < 1200) {
          crossAxisCount = 2; // Tablet
        }
        if (screenWidth < 600) {
          crossAxisCount = 1; // Celular
        }

        // GridView.count cria um grid com um número fixo de colunas
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true, // Para o GridView não tentar rolar infinitamente
          physics: const NeverScrollableScrollPhysics(), // Desabilita o scroll do Grid
          childAspectRatio: (crossAxisCount == 1) ? 2.5 : 2.0, // Ajusta a proporção
          children: const [
            _SummaryCard(
              title: 'Total de Materiais',
              value: '1.372',
              subtitle: '+12 este mês',
              details: 'Tipos diferentes de materiais',
              icon: Icons.inventory_2_outlined,
              subtitleColor: Colors.green,
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
              details: 'Requerem atenção imediata',
              icon: Icons.warning_amber_rounded,
              subtitleColor: Colors.red,
            ),
            _SummaryCard(
              title: 'Bases Operacionais',
              value: '12',
              subtitle: '100% ativas',
              details: 'Bases de manutenção',
              icon: Icons.home_work_outlined,
              subtitleColor: Colors.blue,
            ),
          ],
        );
      },
    );
  }
}

[privado]
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
                  style: textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                ),
                const Spacer(),
                Icon(icon, color: Colors.grey[500]),
              ],
            ),
            const SizedBox(height: 12),

            // --- Valor Principal ---
            Text(
              value,
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // --- Subtítulo (com cor) ---
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
            
            const Spacer(), // Empurra os detalhes para baixo

            // --- Detalhes ---
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