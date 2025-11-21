import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo de Configurações
class Configuracoes {
  final String nomeEmpresa;
  final String idioma;
  final String fusoHorario;
  final bool modoEscuro;
  final bool notificacoesEmail;
  final bool alertasEstoqueBaixo;
  final bool alertasCalibracao;
  final bool resumoDiario;
  final String tempoSessao;
  final bool autenticacaoDoisFatores;
  final bool registroAtividades;
  final String frequenciaBackup;
  final int retencaoDados;
  final String smtpServer;
  final String smtpPort;
  final String smtpUser;
  final String smtpPassword;
  final DateTime? atualizadoEm;

  Configuracoes({
    this.nomeEmpresa = 'Empresa XYZ Ltda',
    this.idioma = 'Português (Brasil)',
    this.fusoHorario = 'América/São Paulo (GMT-3)',
    this.modoEscuro = false,
    this.notificacoesEmail = true,
    this.alertasEstoqueBaixo = true,
    this.alertasCalibracao = true,
    this.resumoDiario = false,
    this.tempoSessao = '30 minutos',
    this.autenticacaoDoisFatores = false,
    this.registroAtividades = true,
    this.frequenciaBackup = 'Diário',
    this.retencaoDados = 365,
    this.smtpServer = '',
    this.smtpPort = '587',
    this.smtpUser = '',
    this.smtpPassword = '',
    this.atualizadoEm,
  });

  factory Configuracoes.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Configuracoes(
      nomeEmpresa: data['nomeEmpresa'] ?? 'Empresa XYZ Ltda',
      idioma: data['idioma'] ?? 'Português (Brasil)',
      fusoHorario: data['fusoHorario'] ?? 'América/São Paulo (GMT-3)',
      modoEscuro: data['modoEscuro'] ?? false,
      notificacoesEmail: data['notificacoesEmail'] ?? true,
      alertasEstoqueBaixo: data['alertasEstoqueBaixo'] ?? true,
      alertasCalibracao: data['alertasCalibracao'] ?? true,
      resumoDiario: data['resumoDiario'] ?? false,
      tempoSessao: data['tempoSessao'] ?? '30 minutos',
      autenticacaoDoisFatores: data['autenticacaoDoisFatores'] ?? false,
      registroAtividades: data['registroAtividades'] ?? true,
      frequenciaBackup: data['frequenciaBackup'] ?? 'Diário',
      retencaoDados: data['retencaoDados'] ?? 365,
      smtpServer: data['smtpServer'] ?? '',
      smtpPort: data['smtpPort'] ?? '587',
      smtpUser: data['smtpUser'] ?? '',
      smtpPassword: data['smtpPassword'] ?? '',
      atualizadoEm: data['atualizadoEm']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomeEmpresa': nomeEmpresa,
      'idioma': idioma,
      'fusoHorario': fusoHorario,
      'modoEscuro': modoEscuro,
      'notificacoesEmail': notificacoesEmail,
      'alertasEstoqueBaixo': alertasEstoqueBaixo,
      'alertasCalibracao': alertasCalibracao,
      'resumoDiario': resumoDiario,
      'tempoSessao': tempoSessao,
      'autenticacaoDoisFatores': autenticacaoDoisFatores,
      'registroAtividades': registroAtividades,
      'frequenciaBackup': frequenciaBackup,
      'retencaoDados': retencaoDados,
      'smtpServer': smtpServer,
      'smtpPort': smtpPort,
      'smtpUser': smtpUser,
      'smtpPassword': smtpPassword,
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
  }
}

/// Repositório para gerenciar configurações
class ConfiguracoesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _docId = 'sistema'; // ID único do documento de configurações

  /// Busca as configurações do sistema
  Future<Configuracoes> getConfiguracoes() async {
    try {
      final doc = await _firestore.collection('configuracoes').doc(_docId).get();
      if (doc.exists) {
        return Configuracoes.fromFirestore(doc);
      }
      // Retorna configurações padrão se não existir
      return Configuracoes();
    } catch (e) {
      // Em caso de erro, tenta carregar do SharedPreferences como fallback
      return await _loadFromLocal();
    }
  }

  /// Salva as configurações no Firestore
  Future<void> salvarConfiguracoes(Configuracoes config) async {
    try {
      await _firestore.collection('configuracoes').doc(_docId).set(
        config.toMap(),
        SetOptions(merge: true),
      );
      // Também salva localmente como backup
      await _saveToLocal(config);
    } catch (e) {
      // Se falhar no Firestore, salva apenas localmente
      await _saveToLocal(config);
      throw Exception('Erro ao salvar configurações: $e');
    }
  }

  /// Carrega configurações do SharedPreferences (fallback)
  Future<Configuracoes> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return Configuracoes(
      nomeEmpresa: prefs.getString('nomeEmpresa') ?? 'Empresa XYZ Ltda',
      idioma: prefs.getString('idioma') ?? 'Português (Brasil)',
      fusoHorario: prefs.getString('fusoHorario') ?? 'América/São Paulo (GMT-3)',
      modoEscuro: prefs.getBool('modoEscuro') ?? false,
      notificacoesEmail: prefs.getBool('notificacoesEmail') ?? true,
      alertasEstoqueBaixo: prefs.getBool('alertasEstoqueBaixo') ?? true,
      alertasCalibracao: prefs.getBool('alertasCalibracao') ?? true,
      resumoDiario: prefs.getBool('resumoDiario') ?? false,
      tempoSessao: prefs.getString('tempoSessao') ?? '30 minutos',
      autenticacaoDoisFatores: prefs.getBool('autenticacaoDoisFatores') ?? false,
      registroAtividades: prefs.getBool('registroAtividades') ?? true,
      frequenciaBackup: prefs.getString('frequenciaBackup') ?? 'Diário',
      retencaoDados: prefs.getInt('retencaoDados') ?? 365,
      smtpServer: prefs.getString('smtpServer') ?? '',
      smtpPort: prefs.getString('smtpPort') ?? '587',
      smtpUser: prefs.getString('smtpUser') ?? '',
      smtpPassword: prefs.getString('smtpPassword') ?? '',
    );
  }

  /// Salva configurações no SharedPreferences (backup)
  Future<void> _saveToLocal(Configuracoes config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nomeEmpresa', config.nomeEmpresa);
    await prefs.setString('idioma', config.idioma);
    await prefs.setString('fusoHorario', config.fusoHorario);
    await prefs.setBool('modoEscuro', config.modoEscuro);
    await prefs.setBool('notificacoesEmail', config.notificacoesEmail);
    await prefs.setBool('alertasEstoqueBaixo', config.alertasEstoqueBaixo);
    await prefs.setBool('alertasCalibracao', config.alertasCalibracao);
    await prefs.setBool('resumoDiario', config.resumoDiario);
    await prefs.setString('tempoSessao', config.tempoSessao);
    await prefs.setBool('autenticacaoDoisFatores', config.autenticacaoDoisFatores);
    await prefs.setBool('registroAtividades', config.registroAtividades);
    await prefs.setString('frequenciaBackup', config.frequenciaBackup);
    await prefs.setInt('retencaoDados', config.retencaoDados);
    await prefs.setString('smtpServer', config.smtpServer);
    await prefs.setString('smtpPort', config.smtpPort);
    await prefs.setString('smtpUser', config.smtpUser);
    await prefs.setString('smtpPassword', config.smtpPassword);
  }

  /// Testa a conexão SMTP (simulado)
  Future<bool> testarConexaoSMTP(String server, String port, String user, String password) async {
    // Simula um teste de conexão (em produção, você usaria um pacote como mailer)
    await Future.delayed(const Duration(seconds: 2));
    // Retorna true se os campos estiverem preenchidos
    return server.isNotEmpty && user.isNotEmpty && password.isNotEmpty;
  }
}

