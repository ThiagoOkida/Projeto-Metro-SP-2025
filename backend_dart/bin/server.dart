import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

void main() async {
  // Cria o roteador principal
  final router = Router();

  // -------------------------------
  // 🔐 ROTA DE LOGIN (mock)
  // -------------------------------
  router.post('/auth/login', (Request req) async {
    final body = jsonDecode(await req.readAsString());

    final email = body['email'];
    final password = body['password'];

    // Credenciais padrão (mock)
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
  // 📦 ENDPOINT DE MATERIAIS
  // -------------------------------
  router.get('/materiais', (Request req) {
    final data = [
      {'nome': 'Conectores RJ45', 'estoque': 5, 'critico': true},
      {'nome': 'Cabo Cat6', 'estoque': 120, 'critico': false},
    ];
    return Response.ok(
      jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // -------------------------------
  // 🧰 ENDPOINT DE INSTRUMENTOS
  // -------------------------------
  router.get('/instrumentos', (Request req) {
    final data = [
      {'id': 'MT-5567', 'nome': 'Multímetro Digital', 'status': 'Disponível'},
      {'id': 'OSC-1234', 'nome': 'Osciloscópio', 'status': 'Em campo (3 dias)'},
    ];
    return Response.ok(
      jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // -------------------------------
  // ⚠️ ENDPOINT DE ALERTAS
  // -------------------------------
  router.get('/alertas', (Request req) {
    final data = [
      {'id': 1, 'titulo': 'Estoque Baixo - Conectores RJ45', 'base': 'Jabaquara', 'restante': 5},
      {'id': 2, 'titulo': 'Instrumento não devolvido', 'base': 'Sé', 'restante': 0},
    ];
    return Response.ok(
      jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // -------------------------------
  // 🌍 CONFIGURAÇÃO DO SERVIDOR E CORS
  // -------------------------------
  final handler = const Pipeline()
      .addMiddleware(logRequests())   // Log de requisições
      .addMiddleware(corsHeaders())   // Permite acesso de origens diferentes
      .addHandler(router);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);

  print('✅ Servidor rodando em http://${server.address.host}:${server.port}');
}
