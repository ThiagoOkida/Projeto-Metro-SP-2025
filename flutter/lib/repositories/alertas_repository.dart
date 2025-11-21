import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Alerta
class Alerta {
  final String id;
  final String titulo;
  final String descricao;
  final String tipo; // 'estoque_baixo', 'manutencao', 'vencimento', 'outro'
  final String severidade; // 'baixa', 'media', 'alta', 'critica'
  final bool resolvido;
  final String? materialId;
  final String? instrumentoId;
  final String? localizacao;
  final DateTime? criadoEm;
  final DateTime? resolvidoEm;

  Alerta({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    this.severidade = 'media',
    this.resolvido = false,
    this.materialId,
    this.instrumentoId,
    this.localizacao,
    this.criadoEm,
    this.resolvidoEm,
  });

  factory Alerta.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Alerta(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      tipo: data['tipo'] ?? 'outro',
      severidade: data['severidade'] ?? 'media',
      resolvido: data['resolvido'] ?? false,
      materialId: data['materialId'],
      instrumentoId: data['instrumentoId'],
      localizacao: data['localizacao'],
      criadoEm: data['criadoEm']?.toDate(),
      resolvidoEm: data['resolvidoEm']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo,
      'severidade': severidade,
      'resolvido': resolvido,
      'materialId': materialId,
      'instrumentoId': instrumentoId,
      'localizacao': localizacao,
      'criadoEm': criadoEm,
      'resolvidoEm': resolvidoEm,
    };
  }

  bool get isCritico => severidade == 'critica';
  bool get isAlto => severidade == 'alta';
}

/// Repositório para gerenciar alertas no Firestore
class AlertasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca todos os alertas não resolvidos
  Stream<List<Alerta>> getAlertasAtivos() {
    return _firestore
        .collection('alertas')
        .where('resolvido', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final alertas = snapshot.docs
              .map((doc) => Alerta.fromFirestore(doc))
              .toList();
          // Ordenar por data de criação (mais recente primeiro)
          alertas.sort((a, b) {
            if (a.criadoEm == null && b.criadoEm == null) return 0;
            if (a.criadoEm == null) return 1;
            if (b.criadoEm == null) return -1;
            return b.criadoEm!.compareTo(a.criadoEm!);
          });
          return alertas;
        });
  }

  /// Busca alertas por tipo
  Stream<List<Alerta>> getAlertasPorTipo(String tipo) {
    return _firestore
        .collection('alertas')
        .where('tipo', isEqualTo: tipo)
        .where('resolvido', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final alertas = snapshot.docs
              .map((doc) => Alerta.fromFirestore(doc))
              .toList();
          // Ordenar por data de criação (mais recente primeiro)
          alertas.sort((a, b) {
            if (a.criadoEm == null && b.criadoEm == null) return 0;
            if (a.criadoEm == null) return 1;
            if (b.criadoEm == null) return -1;
            return b.criadoEm!.compareTo(a.criadoEm!);
          });
          return alertas;
        });
  }

  /// Busca alertas críticos
  Stream<List<Alerta>> getAlertasCriticos() {
    return _firestore
        .collection('alertas')
        .where('severidade', isEqualTo: 'critica')
        .where('resolvido', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final alertas = snapshot.docs
              .map((doc) => Alerta.fromFirestore(doc))
              .toList();
          // Ordenar por data de criação (mais recente primeiro)
          alertas.sort((a, b) {
            if (a.criadoEm == null && b.criadoEm == null) return 0;
            if (a.criadoEm == null) return 1;
            if (b.criadoEm == null) return -1;
            return b.criadoEm!.compareTo(a.criadoEm!);
          });
          return alertas;
        });
  }

  /// Busca um alerta por ID
  Future<Alerta?> getAlertaById(String id) async {
    final doc = await _firestore.collection('alertas').doc(id).get();
    if (doc.exists) {
      return Alerta.fromFirestore(doc);
    }
    return null;
  }

  /// Conta o total de alertas ativos
  Future<int> getTotalAlertasAtivos() async {
    final snapshot = await _firestore
        .collection('alertas')
        .where('resolvido', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Busca todos os alertas (resolvidos e não resolvidos)
  Stream<List<Alerta>> getAllAlertas() {
    return _firestore
        .collection('alertas')
        .snapshots()
        .map((snapshot) {
          final alertas = snapshot.docs
              .map((doc) => Alerta.fromFirestore(doc))
              .toList();
          // Ordenar por data de criação (mais recente primeiro)
          alertas.sort((a, b) {
            if (a.criadoEm == null && b.criadoEm == null) return 0;
            if (a.criadoEm == null) return 1;
            if (b.criadoEm == null) return -1;
            return b.criadoEm!.compareTo(a.criadoEm!);
          });
          return alertas;
        });
  }

  /// Marca um alerta como resolvido
  Future<void> marcarAlertaComoResolvido(String id) async {
    await _firestore.collection('alertas').doc(id).update({
      'resolvido': true,
      'resolvidoEm': FieldValue.serverTimestamp(),
    });
  }

  /// Ignora um alerta (marca como resolvido sem ação)
  Future<void> ignorarAlerta(String id) async {
    await _firestore.collection('alertas').doc(id).update({
      'resolvido': true,
      'resolvidoEm': FieldValue.serverTimestamp(),
    });
  }

  /// Marca todos os alertas pendentes como resolvidos
  Future<void> marcarTodosComoLidos() async {
    final snapshot = await _firestore
        .collection('alertas')
        .where('resolvido', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {
        'resolvido': true,
        'resolvidoEm': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}

