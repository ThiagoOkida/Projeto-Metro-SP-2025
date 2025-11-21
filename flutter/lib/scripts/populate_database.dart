import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

/// Script para popular o banco de dados Firestore com dados iniciais
///
/// Execução:
/// 1. Como script standalone: dart run lib/scripts/populate_database.dart
/// 2. Ou chame populateDatabase() de dentro do app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('🚀 Iniciando população do banco de dados...');
  await populateDatabase();
  print('✅ Banco de dados populado com sucesso!');
  exit(0);
}

/// Popula o banco de dados com dados iniciais do Metro SP
Future<void> populateDatabase() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  // Limpa coleções existentes (opcional - comente se não quiser limpar)
  // await _clearCollections(firestore);

  // Popula materiais
  final materiaisIds = await _populateMateriais(firestore, batch);

  // Popula instrumentos
  final instrumentosIds = await _populateInstrumentos(firestore, batch);

  // Popula alertas (usa IDs dos materiais e instrumentos criados)
  await _populateAlertas(firestore, batch, materiaisIds, instrumentosIds);

  // Commit de todas as operações
  await batch.commit();
  print('📦 ${materiaisIds.length} materiais criados');
  print('🔧 ${instrumentosIds.length} instrumentos criados');
  print('⚠️ Alertas criados');
}

/// Popula a coleção de materiais
Future<List<String>> _populateMateriais(
    FirebaseFirestore firestore, WriteBatch batch) async {
  final materiais = [
    // Materiais com estoque crítico (< 10)
    {
      'nome': 'Conectores RJ45',
      'quantidade': 5,
      'categoria': 'Conectores',
      'unidade': 'unidade',
      'localizacao': 'Base Jabaquara',
      'descricao': 'Conectores de rede categoria 6',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Fusíveis 10A',
      'quantidade': 8,
      'categoria': 'Componentes Elétricos',
      'unidade': 'unidade',
      'localizacao': 'Base Sé',
      'descricao': 'Fusíveis de 10 amperes',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Parafusos M6x20',
      'quantidade': 12,
      'categoria': 'Fixadores',
      'unidade': 'unidade',
      'localizacao': 'Base Vila Madalena',
      'descricao': 'Parafusos métricos 6mm x 20mm',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    // Materiais com estoque normal
    {
      'nome': 'Cabo Cat6',
      'quantidade': 120,
      'categoria': 'Cabos',
      'unidade': 'metro',
      'localizacao': 'Base Jabaquara',
      'descricao': 'Cabo de rede categoria 6',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Cabo de Força 2.5mm²',
      'quantidade': 250,
      'categoria': 'Cabos',
      'unidade': 'metro',
      'localizacao': 'Base Sé',
      'descricao': 'Cabo elétrico flexível 2.5mm²',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Lâmpadas LED 12W',
      'quantidade': 85,
      'categoria': 'Iluminação',
      'unidade': 'unidade',
      'localizacao': 'Base Vila Madalena',
      'descricao': 'Lâmpadas LED 12W para iluminação',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Disjuntores 20A',
      'quantidade': 45,
      'categoria': 'Componentes Elétricos',
      'unidade': 'unidade',
      'localizacao': 'Base Jabaquara',
      'descricao': 'Disjuntores unipolares 20 amperes',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Chave de Fenda Phillips',
      'quantidade': 35,
      'categoria': 'Ferramentas',
      'unidade': 'unidade',
      'localizacao': 'Base Sé',
      'descricao': 'Chave de fenda Phillips tamanho médio',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Multímetro Digital',
      'quantidade': 22,
      'categoria': 'Instrumentos',
      'unidade': 'unidade',
      'localizacao': 'Base Vila Madalena',
      'descricao': 'Multímetro digital básico',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Fita Isolante',
      'quantidade': 180,
      'categoria': 'Material de Consumo',
      'unidade': 'rolo',
      'localizacao': 'Base Jabaquara',
      'descricao': 'Fita isolante preta 19mm',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Terminais Elétricos',
      'quantidade': 320,
      'categoria': 'Componentes Elétricos',
      'unidade': 'unidade',
      'localizacao': 'Base Sé',
      'descricao': 'Terminais para conexão elétrica',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Caixas de Passagem',
      'quantidade': 65,
      'categoria': 'Material Elétrico',
      'unidade': 'unidade',
      'localizacao': 'Base Vila Madalena',
      'descricao': 'Caixas de passagem 4x2',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
  ];

  final ids = <String>[];
  for (var material in materiais) {
    final docRef = firestore.collection('materiais').doc();
    batch.set(docRef, material);
    ids.add(docRef.id);
  }

  return ids;
}

/// Popula a coleção de instrumentos
Future<List<String>> _populateInstrumentos(
    FirebaseFirestore firestore, WriteBatch batch) async {
  final instrumentos = [
    {
      'nome': 'Multímetro Fluke 87V',
      'numeroSerie': 'MT-5567',
      'status': 'disponivel',
      'localizacao': 'Base Jabaquara',
      'observacoes': 'Multímetro de alta precisão',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Osciloscópio Tektronix TBS1052B',
      'numeroSerie': 'OSC-1234',
      'status': 'emprestado',
      'localizacao': 'Base Sé',
      'responsavel': 'João Silva',
      'dataEmprestimo':
          Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
      'dataDevolucaoPrevista': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2))), // 3 dias de atraso
      'observacoes': 'Emprestado para manutenção de sinal',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Medidor de Tensão Digital',
      'numeroSerie': 'MD-7890',
      'status': 'disponivel',
      'localizacao': 'Base Vila Madalena',
      'observacoes': 'Medidor de tensão AC/DC',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Analisador de Espectro',
      'numeroSerie': 'AE-4567',
      'status': 'manutencao',
      'localizacao': 'Base Jabaquara',
      'observacoes': 'Em manutenção preventiva',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Termômetro Infravermelho',
      'numeroSerie': 'TI-2345',
      'status': 'disponivel',
      'localizacao': 'Base Sé',
      'observacoes': 'Termômetro com laser',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Megômetro Digital',
      'numeroSerie': 'MG-6789',
      'status': 'emprestado',
      'localizacao': 'Base Vila Madalena',
      'responsavel': 'Maria Santos',
      'dataEmprestimo':
          Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      'dataDevolucaoPrevista':
          Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
      'observacoes': 'Teste de isolamento',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Detector de Gás',
      'numeroSerie': 'DG-3456',
      'status': 'disponivel',
      'localizacao': 'Base Jabaquara',
      'observacoes': 'Detector de gás combustível',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Medidor de Isolação',
      'numeroSerie': 'MI-9012',
      'status': 'disponivel',
      'localizacao': 'Base Sé',
      'observacoes': 'Medidor de resistência de isolamento',
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    },
  ];

  final ids = <String>[];
  for (var instrumento in instrumentos) {
    final docRef = firestore.collection('instrumentos').doc();
    batch.set(docRef, instrumento);
    ids.add(docRef.id);
  }

  return ids;
}

/// Popula a coleção de alertas
Future<void> _populateAlertas(FirebaseFirestore firestore, WriteBatch batch,
    List<String> materiaisIds, List<String> instrumentosIds) async {
  final alertas = [
    // Alertas de estoque baixo (ligados aos materiais com quantidade < 10)
    {
      'titulo': 'Estoque Baixo - Conectores RJ45',
      'descricao': 'Base Jabaquara com apenas 5 unidades restantes',
      'tipo': 'estoque_baixo',
      'severidade': 'critica',
      'resolvido': false,
      'materialId': materiaisIds[0], // Conectores RJ45
      'localizacao': 'Base Jabaquara',
      'criadoEm': FieldValue.serverTimestamp(),
    },
    {
      'titulo': 'Estoque Baixo - Fusíveis 10A',
      'descricao': 'Base Sé com apenas 8 unidades restantes',
      'tipo': 'estoque_baixo',
      'severidade': 'alta',
      'resolvido': false,
      'materialId': materiaisIds[1], // Fusíveis 10A
      'localizacao': 'Base Sé',
      'criadoEm': FieldValue.serverTimestamp(),
    },
    {
      'titulo': 'Estoque Baixo - Parafusos M6x20',
      'descricao': 'Base Vila Madalena com apenas 12 unidades restantes',
      'tipo': 'estoque_baixo',
      'severidade': 'media',
      'resolvido': false,
      'materialId': materiaisIds[2], // Parafusos
      'localizacao': 'Base Vila Madalena',
      'criadoEm': FieldValue.serverTimestamp(),
    },
    // Alertas de manutenção
    {
      'titulo': 'Instrumento em Manutenção',
      'descricao': 'Analisador de Espectro #AE-4567 em manutenção preventiva',
      'tipo': 'manutencao',
      'severidade': 'media',
      'resolvido': false,
      'instrumentoId': instrumentosIds[3], // Analisador de Espectro
      'localizacao': 'Base Jabaquara',
      'criadoEm': FieldValue.serverTimestamp(),
    },
    // Alertas de atraso
    {
      'titulo': 'Devolução Atrasada - Osciloscópio',
      'descricao': 'Osciloscópio #OSC-1234 com 3 dias de atraso na devolução',
      'tipo': 'vencimento',
      'severidade': 'alta',
      'resolvido': false,
      'instrumentoId': instrumentosIds[1], // Osciloscópio
      'localizacao': 'Base Sé',
      'criadoEm': FieldValue.serverTimestamp(),
    },
  ];

  for (var alerta in alertas) {
    final docRef = firestore.collection('alertas').doc();
    batch.set(docRef, alerta);
  }
}

/// Limpa as coleções existentes (opcional - use com cuidado!)
/// Descomente a chamada em populateDatabase() se quiser limpar antes de popular
// Future<void> _clearCollections(FirebaseFirestore firestore) async {
//   final collections = ['materiais', 'instrumentos', 'alertas'];
//   
//   for (var collectionName in collections) {
//     final snapshot = await firestore.collection(collectionName).get();
//     final batch = firestore.batch();
//     
//     for (var doc in snapshot.docs) {
//       batch.delete(doc.reference);
//     }
//     
//     await batch.commit();
//     print('🗑️ Coleção $collectionName limpa');
//   }
// }

