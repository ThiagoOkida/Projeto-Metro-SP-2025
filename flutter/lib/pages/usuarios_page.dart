import 'package:flutter/material.dart';
class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuários', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(child: ListTile(title: Text('João Silva'), subtitle: Text('Técnico - Ativo')))
          ],
        ),
      ),
    );
  }
}