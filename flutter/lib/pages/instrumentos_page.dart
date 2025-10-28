import 'package:flutter/material.dart';
class InstrumentosPage extends StatelessWidget {
  const InstrumentosPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instrumentos', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
          child: Column(
            children: const [
              ListTile(title: Text('Multímetro #MT-5567'), subtitle: Text('Disponível')),
              Divider(),
              ListTile(title: Text('Osciloscópio #OSC-1234'), subtitle: Text('Emprestado - 3 dias de atraso')),
            ],
          ),
        )
          ],
        ),
      ),
    );
  }
}