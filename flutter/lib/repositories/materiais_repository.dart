import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Material
class Material {
  final String id;
  final String nome;
  final int quantidade;
  final String? descricao;
  final String? categoria;
  final String? unidade;
  final String? localizacao;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;
  final String? codigo;
  final String? tipo; // 'Material de Consumo Regular' ou 'Material de Consumo Específico'
  final int? quantidadeMinima;

  Material({
    required this.id,
    required this.nome,
    required this.quantidade,
    this.descricao,
    this.categoria,
    this.unidade,
    this.localizacao,
    this.criadoEm,
    this.atualizadoEm,
    this.codigo,
    this.tipo,
    this.quantidadeMinima,
  });

  factory Material.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Material(
      id: doc.id,
      nome: data['nome'] ?? '',
      quantidade: data['quantidade'] ?? 0,
      descricao: data['descricao'],
      categoria: data['categoria'],
      unidade: data['unidade'],
      localizacao: data['localizacao'],
      criadoEm: data['criadoEm']?.toDate(),
      atualizadoEm: data['atualizadoEm']?.toDate(),
      codigo: data['codigo'],
      tipo: data['tipo'],
      quantidadeMinima: data['quantidadeMinima'] is int 
          ? data['quantidadeMinima'] as int?
          : (data['quantidadeMinima'] is num 
              ? (data['quantidadeMinima'] as num).toInt() 
              : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'descricao': descricao,
      'categoria': categoria,
      'unidade': unidade,
      'localizacao': localizacao,
      'criadoEm': criadoEm,
      'atualizadoEm': atualizadoEm,
      'codigo': codigo,
      'tipo': tipo,
      'quantidadeMinima': quantidadeMinima,
    };
  }

  /// Retorna o status do estoque baseado na quantidade mínima
  String get statusEstoque {
    final min = quantidadeMinima ?? 10;
    if (quantidade < min * 0.3) {
      return 'critico';
    } else if (quantidade < min) {
      return 'baixo';
    }
    return 'normal';
  }

  /// Verifica se o estoque está crítico
  bool get estoqueCritico => statusEstoque == 'critico';

  /// Verifica se o estoque está baixo
  bool get estoqueBaixo => statusEstoque == 'baixo';

  /// Verifica se o estoque está normal
  bool get estoqueNormal => statusEstoque == 'normal';
}

/// Repositório para gerenciar materiais no Firestore
class MateriaisRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca todos os materiais
  Stream<List<Material>> getMateriais() {
    return _firestore.collection('materiais').orderBy('nome').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Material.fromFirestore(doc)).toList());
  }

  /// Busca materiais com estoque crítico
  Stream<List<Material>> getMateriaisCriticos() {
    return _firestore
        .collection('materiais')
        .where('quantidade', isLessThan: 10)
        .snapshots()
        .map((snapshot) {
          final materiais = snapshot.docs
              .map((doc) => Material.fromFirestore(doc))
              .toList();
          // Ordenar por quantidade (menor primeiro)
          materiais.sort((a, b) => a.quantidade.compareTo(b.quantidade));
          return materiais;
        });
  }

  /// Busca um material por ID
  Future<Material?> getMaterialById(String id) async {
    final doc = await _firestore.collection('materiais').doc(id).get();
    if (doc.exists) {
      return Material.fromFirestore(doc);
    }
    return null;
  }

  /// Conta o total de materiais
  Future<int> getTotalMateriais() async {
    final snapshot = await _firestore.collection('materiais').count().get();
    return snapshot.count ?? 0;
  }

  /// Busca materiais com estoque baixo (mas não crítico)
  Stream<List<Material>> getMateriaisEstoqueBaixo() {
    return _firestore
        .collection('materiais')
        .snapshots()
        .map((snapshot) {
          final materiais = snapshot.docs
              .map((doc) => Material.fromFirestore(doc))
              .where((m) => m.estoqueBaixo)
              .toList();
          materiais.sort((a, b) => a.quantidade.compareTo(b.quantidade));
          return materiais;
        });
  }

  /// Busca materiais com estoque normal
  Stream<List<Material>> getMateriaisEstoqueNormal() {
    return _firestore
        .collection('materiais')
        .snapshots()
        .map((snapshot) {
          final materiais = snapshot.docs
              .map((doc) => Material.fromFirestore(doc))
              .where((m) => m.estoqueNormal)
              .toList();
          return materiais;
        });
  }

  /// Cria um novo material
  Future<String> criarMaterial({
    required String nome,
    required int quantidade,
    String? descricao,
    String? categoria,
    String? tipo,
    String? unidade,
    String? localizacao,
    String? codigo,
    int? quantidadeMinima,
  }) async {
    try {
      final docRef = await _firestore.collection('materiais').add({
        'nome': nome,
        'quantidade': quantidade,
        'descricao': descricao,
        'categoria': categoria,
        'tipo': tipo,
        'unidade': unidade ?? 'Peça',
        'localizacao': localizacao,
        'codigo': codigo,
        'quantidadeMinima': quantidadeMinima,
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar material: $e');
    }
  }
}

