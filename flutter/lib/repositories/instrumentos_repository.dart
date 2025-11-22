import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Instrumento
class Instrumento {
  final String id;
  final String nome;
  final String? numeroSerie;
  final String? patrimonio; // Código de patrimônio
  final String? categoria;
  final String
      status; // 'disponivel', 'emprestado', 'manutencao', 'indisponivel', 'em_uso'
  final String? localizacao;
  final String? responsavel;
  final DateTime? dataEmprestimo;
  final DateTime? dataDevolucaoPrevista;
  final DateTime? dataCalibracao;
  final DateTime? proximaCalibracao;
  final String? observacoes;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Instrumento({
    required this.id,
    required this.nome,
    this.numeroSerie,
    this.patrimonio,
    this.categoria,
    this.status = 'disponivel',
    this.localizacao,
    this.responsavel,
    this.dataEmprestimo,
    this.dataDevolucaoPrevista,
    this.dataCalibracao,
    this.proximaCalibracao,
    this.observacoes,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Instrumento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Instrumento(
      id: doc.id,
      nome: data['nome'] ?? '',
      numeroSerie: data['numeroSerie'],
      patrimonio: data['patrimonio'],
      categoria: data['categoria'],
      status: data['status'] ?? 'disponivel',
      localizacao: data['localizacao'],
      responsavel: data['responsavel'],
      dataEmprestimo: data['dataEmprestimo']?.toDate(),
      dataDevolucaoPrevista: data['dataDevolucaoPrevista']?.toDate(),
      dataCalibracao: data['dataCalibracao']?.toDate(),
      proximaCalibracao: data['proximaCalibracao']?.toDate(),
      observacoes: data['observacoes'],
      criadoEm: data['criadoEm']?.toDate(),
      atualizadoEm: data['atualizadoEm']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'numeroSerie': numeroSerie,
      'patrimonio': patrimonio,
      'categoria': categoria,
      'status': status,
      'localizacao': localizacao,
      'responsavel': responsavel,
      'dataEmprestimo': dataEmprestimo,
      'dataDevolucaoPrevista': dataDevolucaoPrevista,
      'dataCalibracao': dataCalibracao,
      'proximaCalibracao': proximaCalibracao,
      'observacoes': observacoes,
      'criadoEm': criadoEm,
      'atualizadoEm': atualizadoEm,
    };
  }

  bool get isDisponivel => status == 'disponivel';
  bool get isEmprestado => status == 'emprestado' || status == 'em_uso';
  bool get isEmAtraso {
    if (!isEmprestado || dataDevolucaoPrevista == null) return false;
    return DateTime.now().isAfter(dataDevolucaoPrevista!);
  }

  /// Retorna o status da calibração
  String get statusCalibracao {
    if (proximaCalibracao == null) return 'ok';
    final agora = DateTime.now();
    final diasRestantes = proximaCalibracao!.difference(agora).inDays;
    
    if (diasRestantes < 0) {
      return 'vencida';
    } else if (diasRestantes <= 30) {
      return 'vencendo';
    }
    return 'ok';
  }

  /// Verifica se a calibração está vencida
  bool get calibracaoVencida => statusCalibracao == 'vencida';
}

/// Repositório para gerenciar instrumentos no Firestore
class InstrumentosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca todos os instrumentos
  Stream<List<Instrumento>> getInstrumentos() {
    return _firestore
        .collection('instrumentos')
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Instrumento.fromFirestore(doc))
            .toList());
  }

  /// Busca instrumentos por status
  Stream<List<Instrumento>> getInstrumentosPorStatus(String status) {
    return _firestore
        .collection('instrumentos')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          final instrumentos = snapshot.docs
              .map((doc) => Instrumento.fromFirestore(doc))
              .toList();
          // Ordenar por nome (alfabética)
          instrumentos.sort((a, b) => a.nome.compareTo(b.nome));
          return instrumentos;
        });
  }

  /// Busca instrumentos disponíveis
  Stream<List<Instrumento>> getInstrumentosDisponiveis() {
    return getInstrumentosPorStatus('disponivel');
  }

  /// Busca instrumentos emprestados
  Stream<List<Instrumento>> getInstrumentosEmprestados() {
    return _firestore
        .collection('instrumentos')
        .where('status', whereIn: ['emprestado', 'em_uso'])
        .snapshots()
        .map((snapshot) {
          final instrumentos = snapshot.docs
              .map((doc) => Instrumento.fromFirestore(doc))
              .toList();
          instrumentos.sort((a, b) => a.nome.compareTo(b.nome));
          return instrumentos;
        });
  }

  /// Busca instrumentos com calibração vencida
  Stream<List<Instrumento>> getInstrumentosCalibracaoVencida() {
    return _firestore
        .collection('instrumentos')
        .snapshots()
        .map((snapshot) {
          final instrumentos = snapshot.docs
              .map((doc) => Instrumento.fromFirestore(doc))
              .where((inst) => inst.calibracaoVencida)
              .toList();
          return instrumentos;
        });
  }

  /// Retira um instrumento (empresta)
  Future<void> retirarInstrumento({
    required String instrumentoId,
    required String responsavelId,
    required String responsavelNome,
    String? localizacao,
    DateTime? dataDevolucaoPrevista,
  }) async {
    try {
      final instrumento = await getInstrumentoById(instrumentoId);
      if (instrumento == null) {
        throw Exception('Instrumento não encontrado');
      }
      
      if (instrumento.status != 'disponivel') {
        throw Exception('Este instrumento não está disponível');
      }

      final updateData = <String, dynamic>{
        'status': 'em_uso',
        'responsavel': responsavelNome,
        'dataEmprestimo': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      };

      if (localizacao != null && localizacao.isNotEmpty) {
        updateData['localizacao'] = localizacao;
      }

      if (dataDevolucaoPrevista != null) {
        updateData['dataDevolucaoPrevista'] = Timestamp.fromDate(dataDevolucaoPrevista);
      }

      await _firestore.collection('instrumentos').doc(instrumentoId).update(updateData);
    } catch (e) {
      throw Exception('Erro ao retirar instrumento: $e');
    }
  }

  /// Busca um instrumento por ID
  Future<Instrumento?> getInstrumentoById(String id) async {
    final doc = await _firestore.collection('instrumentos').doc(id).get();
    if (doc.exists) {
      return Instrumento.fromFirestore(doc);
    }
    return null;
  }

  /// Conta o total de instrumentos
  Future<int> getTotalInstrumentos() async {
    final snapshot = await _firestore.collection('instrumentos').count().get();
    return snapshot.count ?? 0;
  }

  /// Conta instrumentos ativos (disponíveis ou emprestados)
  Future<int> getTotalInstrumentosAtivos() async {
    final snapshot = await _firestore
        .collection('instrumentos')
        .where('status', whereIn: ['disponivel', 'emprestado'])
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Devolve um instrumento emprestado
  Future<void> devolverInstrumento(String instrumentoId) async {
    try {
      final instrumento = await getInstrumentoById(instrumentoId);
      if (instrumento == null) {
        throw Exception('Instrumento não encontrado');
      }
      
      if (instrumento.status != 'emprestado' && instrumento.status != 'em_uso') {
        throw Exception('Este instrumento não está emprestado');
      }

      await _firestore.collection('instrumentos').doc(instrumentoId).update({
        'status': 'disponivel',
        'responsavel': null,
        'dataEmprestimo': null,
        'dataDevolucaoPrevista': null,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao devolver instrumento: $e');
    }
  }

  /// Cria um novo instrumento
  Future<String> criarInstrumento({
    required String nome,
    String? numeroSerie,
    String? patrimonio,
    String? categoria,
    String? localizacao,
    DateTime? dataCalibracao,
    DateTime? proximaCalibracao,
    String? observacoes,
  }) async {
    try {
      final docRef = await _firestore.collection('instrumentos').add({
        'nome': nome,
        'numeroSerie': numeroSerie,
        'patrimonio': patrimonio,
        'categoria': categoria,
        'status': 'disponivel',
        'localizacao': localizacao,
        'responsavel': null,
        'dataEmprestimo': null,
        'dataDevolucaoPrevista': null,
        'dataCalibracao': dataCalibracao != null ? Timestamp.fromDate(dataCalibracao) : null,
        'proximaCalibracao': proximaCalibracao != null ? Timestamp.fromDate(proximaCalibracao) : null,
        'observacoes': observacoes,
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar instrumento: $e');
    }
  }
}

