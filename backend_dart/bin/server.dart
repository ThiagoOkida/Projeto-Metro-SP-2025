import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:http/http.dart' as http;

//
// 🧾 Função para salvar usuário via REST API do Firestore
//
Future<void> salvarUsuarioNoFirestore(
    String uid, String nome, String email) async {
  const projectId = 'seu-projeto-id'; // Substitua pelo ID do projeto Firebase
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

  final response = await http.patch(
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

//
// 🚀 Servidor Shelf
//
void main() async {
  final router = Router();

  // -------------------------------
  // 🆕 ROTA DE CADASTRO
  // -------------------------------
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

  // -------------------------------
  // 🔐 ROTA DE LOGIN (mock)
  // -------------------------------
  router.post('/auth/login', (Request req) async {
    final body = jsonDecode(await req.readAsString());
    final email = body['email'];
    final password = body['password'];

    if (email == 'admin@metro.sp.gov.br' && password == 'admin123') {
      return Response.ok(
        jsonEncode({'token': 'dummy-token-123'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response(
      401,
      body: jsonEncode({'error': 'Credenciais inválidas'}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // -------------------------------
  // 🌍 CONFIGURAÇÃO DO SERVIDOR
  // -------------------------------
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('✅ Servidor rodando em http://${server.address.host}:${server.port}');
}
