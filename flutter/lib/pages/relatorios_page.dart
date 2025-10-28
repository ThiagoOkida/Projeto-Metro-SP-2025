import 'package:flutter/material.dart';
class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Relatórios', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(child: ListTile(title: Text('Relatório mensal'), subtitle: Text('Visão geral de movimentações')))
          ],
        ),
      ),
    );
  }
}