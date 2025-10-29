import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Integração com o servidor Dart', () {
    test('Endpoint /materiais deve responder com status 200', () async {
      // Dado que o servidor Dart está em execução
      final url = Uri.parse('http://localhost:8080/materiais');

      // Quando a requisição é feita
      final response = await http.get(url);

      // Então o servidor deve responder com sucesso
      expect(response.statusCode, 200,
          reason: 'Servidor respondeu corretamente no endpoint /materiais');
    });
  });
}
