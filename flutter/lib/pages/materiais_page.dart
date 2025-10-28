import 'package:flutter/material.dart';
class MateriaisPage extends StatelessWidget {
  const MateriaisPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Materiais', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
          child: Column(
            children: const [
              ListTile(title: Text('Conectores RJ45'), subtitle: Text('Em estoque: 5 (CRÍTICO)')),
              Divider(),
              ListTile(title: Text('Cabo Cat6'), subtitle: Text('Em estoque: 120')),
            ],
          ),
        )
          ],
        ),
      ),
    );
  }
}