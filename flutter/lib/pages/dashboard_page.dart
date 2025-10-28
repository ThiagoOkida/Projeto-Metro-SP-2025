import 'package:flutter/material.dart';
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visão Geral', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: const [
            Card(child: ListTile(title: Text('Itens em estoque'), subtitle: Text('1.245'), trailing: Icon(Icons.trending_up))),
            Card(child: ListTile(title: Text('Alertas ativos'), subtitle: Text('3'), trailing: Icon(Icons.warning))),
            Card(child: ListTile(title: Text('Ordens do mês'), subtitle: Text('128'), trailing: Icon(Icons.assignment))),
          ],
        )
          ],
        ),
      ),
    );
  }
}