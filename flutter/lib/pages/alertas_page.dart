import 'package:flutter/material.dart';
class AlertasPage extends StatelessWidget {
  const AlertasPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alertas', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(child: ListTile(title: Text('Estoque Baixo - Conectores RJ45'), subtitle: Text('Base Jabaquara com 5 unidades restantes')))
          ],
        ),
      ),
    );
  }
}