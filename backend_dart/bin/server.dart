import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:http/http.dart' as http;

Future<void> salvarUsuarioNoFirestore(
    String uid, String nome, String email) async {
  final projectId = Platform.environment['FIREBASE_PROJECT_ID'] ?? 'seu-projeto-id';
  
  if (projectId == 'seu-projeto-id') {
    print('⚠️  AVISO: Configure a variável de ambiente FIREBASE_PROJECT_ID');
    print('⚠️  Ou atualize o projectId no código');
  }
  
  final url = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/usuarios/$uid',
  );

  final body = jsonEncode({
    'fields': {
      'nome': {'stringValue': nome},
      'email': {'stringValue': email},
      'perfil': {'stringValue': 'contribuinte'},
      'criadoEm': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
    }
  });
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    print('✅ Usuário $uid salvo no Firestore com sucesso!');
  } else {
    print('❌ Erro ao salvar: ${response.statusCode} - ${response.body}');
    throw Exception('Erro ao salvar usuário no Firestore');
  }
}
void main() async {
  final router = Router();
  router.post('/api/cadastro', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString());
      final uid = body['uid'] as String?;
      final nome = body['nome'] as String?;
      final email = body['email'] as String?;

      if (uid == null || nome == null || email == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'UID, nome e email são obrigatórios'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await salvarUsuarioNoFirestore(uid, nome, email);

      return Response.ok(
        jsonEncode({'status': 'sucesso', 'uid': uid}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('❌ Erro no endpoint /api/cadastro: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro interno: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });
  router.post('/auth/login', (Request req) async {
    return Response(
      410, // Gone - recurso não está mais disponível
      body: jsonEncode({
        'error': 'Esta rota foi descontinuada. Use Firebase Auth diretamente no Flutter.',
        'message': 'A autenticação agora é gerenciada pelo Firebase Auth no cliente.'
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('✅ Servidor rodando em http://${server.address.host}:${server.port}');
}
