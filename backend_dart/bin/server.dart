import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

void main() async {
  final router = Router();

  // Rota de login (mock)
  router.post('/auth/login', (Request req) async {
    final data = jsonDecode(await req.readAsString());
    if (data['email'] == 'admin@metro.sp.gov.br' && data['password'] == 'admin123') {
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

  // Endpoint de Materiais
  router.get('/materiais', (Request req) {
    final data = [
      {'nome': 'Conectores RJ45', 'estoque': 5, 'critico': true},
      {'nome': 'Cabo Cat6', 'estoque': 120, 'critico': false},
    ];
    return Response.ok(jsonEncode(data), headers: {'Content-Type': 'application/json'});
  });

  // Endpoint de Instrumentos
  router.get('/instrumentos', (Request req) {
    final data = [
      {'id': 'MT-5567', 'nome': 'Multímetro Digital', 'status': 'Disponível'},
      {'id': 'OSC-1234', 'nome': 'Osciloscópio', 'status': 'Em campo (3 dias)'},
    ];
    return Response.ok(jsonEncode(data), headers: {'Content-Type': 'application/json'});
  });

  // Endpoint de Alertas
  router.get('/alertas', (Request req) {
    final data = [
      {'id': 1, 'titulo': 'Estoque Baixo - Conectores RJ45', 'base': 'Jabaquara', 'restante': 5},
      {'id': 2, 'titulo': 'Instrumento não devolvido', 'base': 'Sé', 'restante': 0},
    ];
    return Response.ok(jsonEncode(data), headers: {'Content-Type': 'application/json'});
  });

  // Pipeline com CORS + logs
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  // Servidor rodando
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('✅ Servidor rodando em http://${server.address.host}:${server.port}');
}
