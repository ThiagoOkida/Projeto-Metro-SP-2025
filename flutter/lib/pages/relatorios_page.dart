import 'package:flutter/material.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------- TÍTULO -------------------
          Text(
            "Relatórios",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Análises e estatísticas do sistema",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),

          const SizedBox(height: 24),

          // ------------------- LINHA SUPERIOR DE CARDS -------------------
          LayoutBuilder(
            builder: (context, constraints) {
              int cross = constraints.maxWidth < 900 ? 1 : 4;

              return GridView.count(
                crossAxisCount: cross,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: const [
                  _ResumoCard(
                    titulo: "Total de Movimentações",
                    valor: "1.234",
                    descricao: "+12% em relação ao mês anterior",
                    icon: Icons.bar_chart,
                    color: Colors.green,
                  ),
                  _ResumoCard(
                    titulo: "Materiais Críticos",
                    valor: "8",
                    descricao: "Requerem atenção imediata",
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                  _ResumoCard(
                    titulo: "Taxa de Uso",
                    valor: "78%",
                    descricao: "+5% comparado ao período anterior",
                    icon: Icons.show_chart,
                    color: Colors.blue,
                  ),
                  _ResumoCard(
                    titulo: "Valor Total",
                    valor: "R\$ 234.5K",
                    descricao: "Em estoque atual",
                    icon: Icons.monetization_on_outlined,
                    color: Colors.indigo,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ------------------- COLUNAS: MOVIMENTAÇÕES + TOP MATERIAIS -------------------
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(
                  children: [
                    _buildMovimentacoesCard(metroBlue),
                    const SizedBox(height: 16),
                    _buildTopMateriaisCard(metroBlue),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _buildMovimentacoesCard(metroBlue)),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: _buildTopMateriaisCard(metroBlue)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ================================================================================
  // CARD: MOVIMENTAÇÕES MENSAIS
  // ================================================================================

  Widget _buildMovimentacoesCard(Color metroBlue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Movimentações Mensais",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Lista manual do gráfico horizontal
            _barra("Jan", 120, 85, metroBlue),
            _barra("Fev", 145, 92, metroBlue),
            _barra("Mar", 132, 108, metroBlue),
            _barra("Abr", 158, 115, metroBlue),
            _barra("Mai", 142, 98, metroBlue),
            _barra("Jun", 165, 122, metroBlue),
          ],
        ),
      ),
    );
  }

  Widget _barra(String mes, int entrada, int saida, Color metroBlue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$mes", style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          // Barra
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: metroBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (entrada + saida) / 300, // ajuste simples
              child: Container(
                decoration: BoxDecoration(
                  color: metroBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          Text(
            "Entradas: $entrada | Saídas: $saida",
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ================================================================================
  // CARD: TOP MATERIAIS
  // ================================================================================

  Widget _buildTopMateriaisCard(Color metroBlue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top Materiais por Consumo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _material("Aço Inox 304", 850, "+12%", Colors.green),
            _material("Alumínio 6061", 620, "-8%", Colors.red),
            _material("Cobre Eletrolítico", 445, "+5%", Colors.green),
            _material("Bronze SAE 40", 320, "-3%", Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _material(
      String nome, int qtd, String variacao, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(nome,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Text("$qtd unidades",
              style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          const SizedBox(width: 12),
          Text(
            variacao,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CARD SUPERIOR (Resumo)
// =============================================================================

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String descricao;
  final IconData icon;
  final Color color;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.descricao,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(icon, size: 26, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              valor,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                Icon(Icons.trending_up,
                    color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    descricao,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}