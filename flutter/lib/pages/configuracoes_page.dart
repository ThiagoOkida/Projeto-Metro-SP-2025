import 'package:flutter/material.dart';
class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configurações', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(child: ListTile(title: Text('Tema'), subtitle: Text('Padrão')))
          ],
        ),
      ),
    );
  }
}