import 'package:flutter_test/flutter_test.dart';
import 'package:spss_flutter/state/auth.dart';

void main() {
  group('Autenticação - AuthRepository', () {
    final repo = AuthRepository();

    test('Usuário deve autenticar com sucesso usando credenciais válidas', () async {
      // Dado que o usuário fornece credenciais corretas
      const email = 'admin@metro.sp.gov.br';
      const senha = 'admin123';

      // Quando ele tenta fazer login
      final token = await repo.login(email, senha);

      // Então o sistema deve retornar um token válido
      expect(token, isNotEmpty, reason: 'Token retornado com sucesso');
    });

    test('Usuário deve receber erro ao tentar autenticar com credenciais inválidas', () async {
      // Dado que o usuário informa dados incorretos
      const email = 'usuario@invalido.com';
      const senha = 'senha_errada';

      // Quando ele tenta fazer login
      // Então o sistema deve lançar uma exceção
      expect(() async => await repo.login(email, senha),
          throwsException, reason: 'Login incorreto deve falhar');
    });
  });
}
