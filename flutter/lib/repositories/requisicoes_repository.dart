import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Requisição de Material
class Requisicao {
  final String id;
  final String materialId;
  final String materialNome;
  final int quantidade;
  final String solicitanteId;
  final String solicitanteNome;
  final String? baseOperacional;
  final String? observacoes;
  final String status; // 'pendente', 'aprovada', 'rejeitada', 'entregue'
  final DateTime criadoEm;
  final DateTime? atualizadoEm;
  final String? aprovadoPor;
  final DateTime? dataAprovacao;
  final DateTime? dataEntrega;

  Requisicao({
    required this.id,
    required this.materialId,
    required this.materialNome,
    required this.quantidade,
    required this.solicitanteId,
    required this.solicitanteNome,
    this.baseOperacional,
    this.observacoes,
    this.status = 'pendente',
    required this.criadoEm,
    this.atualizadoEm,
    this.aprovadoPor,
    this.dataAprovacao,
    this.dataEntrega,
  });

  factory Requisicao.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Requisicao(
      id: doc.id,
      materialId: data['materialId'] ?? '',
      materialNome: data['materialNome'] ?? '',
      quantidade: data['quantidade'] ?? 0,
      solicitanteId: data['solicitanteId'] ?? '',
      solicitanteNome: data['solicitanteNome'] ?? '',
      baseOperacional: data['baseOperacional'],
      observacoes: data['observacoes'],
      status: data['status'] ?? 'pendente',
      criadoEm: data['criadoEm']?.toDate() ?? DateTime.now(),
      atualizadoEm: data['atualizadoEm']?.toDate(),
      aprovadoPor: data['aprovadoPor'],
      dataAprovacao: data['dataAprovacao']?.toDate(),
      dataEntrega: data['dataEntrega']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialNome': materialNome,
      'quantidade': quantidade,
      'solicitanteId': solicitanteId,
      'solicitanteNome': solicitanteNome,
      'baseOperacional': baseOperacional,
      'observacoes': observacoes,
      'status': status,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'atualizadoEm': atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
      'aprovadoPor': aprovadoPor,
      'dataAprovacao': dataAprovacao != null ? Timestamp.fromDate(dataAprovacao!) : null,
      'dataEntrega': dataEntrega != null ? Timestamp.fromDate(dataEntrega!) : null,
    };
  }
}

/// Repositório para gerenciar requisições no Firestore
class RequisicoesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria uma nova requisição e atualiza o estoque do material
  Future<String> criarRequisicao({
    required String materialId,
    required String materialNome,
    required int quantidade,
    required String solicitanteId,
    required String solicitanteNome,
    String? baseOperacional,
    String? observacoes,
  }) async {
    try {
      // Usa transação para garantir atomicidade (criar requisição + atualizar estoque)
      return await _firestore.runTransaction((transaction) async {
        // Busca o documento do material
        final materialRef = _firestore.collection('materiais').doc(materialId);
        final materialDoc = await transaction.get(materialRef);
        
        if (!materialDoc.exists) {
          throw Exception('Material não encontrado');
        }
        
        final materialData = materialDoc.data()!;
        final estoqueAtual = materialData['quantidade'] as int? ?? 0;
        
        if (estoqueAtual < quantidade) {
          throw Exception('Estoque insuficiente. Disponível: $estoqueAtual');
        }

        // Calcula novo estoque
        final novoEstoque = estoqueAtual - quantidade;

        // Cria a requisição
        final requisicaoRef = _firestore.collection('requisicoes').doc();
        transaction.set(requisicaoRef, {
          'materialId': materialId,
          'materialNome': materialNome,
          'quantidade': quantidade,
          'solicitanteId': solicitanteId,
          'solicitanteNome': solicitanteNome,
          'baseOperacional': baseOperacional,
          'observacoes': observacoes,
          'status': 'pendente',
          'criadoEm': FieldValue.serverTimestamp(),
          'atualizadoEm': FieldValue.serverTimestamp(),
        });

        // Atualiza o estoque do material
        transaction.update(materialRef, {
          'quantidade': novoEstoque,
          'atualizadoEm': FieldValue.serverTimestamp(),
        });

        return requisicaoRef.id;
      });
    } catch (e) {
      throw Exception('Erro ao criar requisição: $e');
    }
  }

  /// Busca todas as requisições
  Stream<List<Requisicao>> getRequisicoes() {
    return _firestore
        .collection('requisicoes')
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Requisicao.fromFirestore(doc))
            .toList());
  }

  /// Busca requisições por solicitante
  Stream<List<Requisicao>> getRequisicoesPorSolicitante(String solicitanteId) {
    return _firestore
        .collection('requisicoes')
        .where('solicitanteId', isEqualTo: solicitanteId)
        .snapshots()
        .map((snapshot) {
          final requisicoes = snapshot.docs
              .map((doc) => Requisicao.fromFirestore(doc))
              .toList();
          requisicoes.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
          return requisicoes;
        });
  }

  /// Busca requisições por status
  Stream<List<Requisicao>> getRequisicoesPorStatus(String status) {
    return _firestore
        .collection('requisicoes')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          final requisicoes = snapshot.docs
              .map((doc) => Requisicao.fromFirestore(doc))
              .toList();
          requisicoes.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
          return requisicoes;
        });
  }
}

