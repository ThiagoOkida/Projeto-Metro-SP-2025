import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Serviço para enviar notificações por email para gestores e admins
class EmailNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca todos os emails de gestores e admins
  Future<List<String>> _getEmailsGestoresEAdmins() async {
    try {
      final usuariosSnapshot = await _firestore.collection('usuarios').get();
      final emails = <String>[];

      for (var doc in usuariosSnapshot.docs) {
        final data = doc.data();
        final role = (data['role'] ?? data['perfil'] ?? 'contribuinte').toString().toLowerCase();
        final email = data['email']?.toString();
        final ativo = data['ativo'];

        // Verifica se é gestor ou admin e está ativo
        bool isAtivo = false;
        if (ativo is bool) {
          isAtivo = ativo;
        } else if (ativo is String) {
          isAtivo = ativo.toLowerCase() == 'true';
        }

        if ((role == 'admin' || role == 'gestor') && 
            email != null && 
            email.isNotEmpty &&
            isAtivo) {
          emails.add(email);
        }
      }

      return emails;
    } catch (e) {
      print('Erro ao buscar emails de gestores e admins: $e');
      return [];
    }
  }

  /// Obtém as configurações SMTP do Firestore
  Future<Map<String, String>> _getSmtpConfig() async {
    try {
      final configDoc = await _firestore
          .collection('configuracoes')
          .doc('sistema')
          .get();

      if (!configDoc.exists) {
        return {};
      }

      final data = configDoc.data();
      if (data == null) return {};

      return {
        'server': data['smtpServer']?.toString() ?? '',
        'port': data['smtpPort']?.toString() ?? '587',
        'user': data['smtpUser']?.toString() ?? '',
        'password': data['smtpPassword']?.toString() ?? '',
      };
    } catch (e) {
      print('Erro ao buscar configurações SMTP: $e');
      return {};
    }
  }

  /// Envia notificação por email para gestores e admins
  Future<void> enviarNotificacao({
    required String assunto,
    required String mensagem,
    String? tipoAlteracao, // 'criar', 'atualizar', 'deletar'
    String? entidade, // 'material', 'instrumento', 'usuario', etc.
    String? detalhes, // Informações adicionais
  }) async {
    try {
      // Busca emails de gestores e admins
      final emails = await _getEmailsGestoresEAdmins();
      if (emails.isEmpty) {
        print('⚠️ Nenhum gestor ou admin encontrado para notificação');
        return;
      }

      // Busca configurações SMTP
      final smtpConfig = await _getSmtpConfig();
      final server = smtpConfig['server'] ?? '';
      final user = smtpConfig['user'] ?? '';
      final password = smtpConfig['password'] ?? '';
      
      if (server.isEmpty || user.isEmpty || password.isEmpty) {
        print('⚠️ Configurações SMTP não encontradas. Email não enviado.');
        return;
      }

      // Configura servidor SMTP
      final smtpServer = SmtpServer(
        server,
        port: int.tryParse(smtpConfig['port'] ?? '587') ?? 587,
        username: user,
        password: password,
        ssl: false,
        allowInsecure: true,
      );

      // Monta o corpo do email
      final corpoEmail = _montarCorpoEmail(
        mensagem: mensagem,
        tipoAlteracao: tipoAlteracao,
        entidade: entidade,
        detalhes: detalhes,
      );

      // Cria a mensagem
      final message = Message()
        ..from = Address(user, 'Sistema Metro SP')
        ..recipients = emails
        ..subject = assunto
        ..html = corpoEmail;

      // Envia o email
      await send(message, smtpServer);
      print('✅ Notificação enviada para ${emails.length} gestor(es)/admin(s)');
    } catch (e) {
      // Não lança exceção para não interromper o fluxo principal
      print('❌ Erro ao enviar notificação por email: $e');
    }
  }

  /// Monta o corpo HTML do email
  String _montarCorpoEmail({
    required String mensagem,
    String? tipoAlteracao,
    String? entidade,
    String? detalhes,
  }) {
    final tipoLabel = tipoAlteracao != null
        ? {
            'criar': 'Criação',
            'atualizar': 'Atualização',
            'deletar': 'Exclusão',
          }[tipoAlteracao] ?? tipoAlteracao
        : 'Alteração';

    final entidadeLabel = entidade != null
        ? {
            'material': 'Material',
            'instrumento': 'Instrumento',
            'usuario': 'Usuário',
            'alerta': 'Alerta',
            'requisicao': 'Requisição',
            'configuracao': 'Configuração',
          }[entidade] ?? entidade
        : 'Item';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #1565C0; color: white; padding: 20px; text-align: center; }
    .content { background-color: #f9f9f9; padding: 20px; }
    .info-box { background-color: #e3f2fd; border-left: 4px solid #1565C0; padding: 15px; margin: 15px 0; }
    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>Sistema Metro SP - Notificação</h2>
    </div>
    <div class="content">
      <h3>$tipoLabel de $entidadeLabel</h3>
      <p>$mensagem</p>
      ${detalhes != null ? '<div class="info-box"><strong>Detalhes:</strong><br>$detalhes</div>' : ''}
      <p><small>Esta é uma notificação automática do sistema. Por favor, não responda este email.</small></p>
    </div>
    <div class="footer">
      <p>São Paulo Stock Sync - Sistema de Gestão</p>
      <p>© ${DateTime.now().year} Metro SP</p>
    </div>
  </div>
</body>
</html>
''';
  }
}

