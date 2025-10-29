import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spss_flutter/state/auth.dart';
import 'package:spss_flutter/state/login_controller.dart';

/// Mock que simula o AuthRepository sem backend real
class MockAuthRepository extends AuthRepository {
  MockAuthRepository() : super(baseUrl: 'http://fake-api');

  @override
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (email == 'admin@metro.sp.gov.br' && password == 'admin123') {
      return 'mock-token-123';
    } else {
      throw Exception('Credenciais inválidas (mock)');
    }
  }
}

void main() {
  // ✅ Inicializa o binding necessário para SharedPreferences funcionar
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de autenticação - LoginController (com mock)', () {
    late ProviderContainer container;
    late LoginController controller;

    setUp(() async {
      // ✅ Inicializa um armazenamento em memória para o SharedPreferences
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      controller = container.read(loginControllerProvider.notifier);
    });

    test('Deve atualizar o estado global após login bem-sucedido', () async {
      await controller.login('admin@metro.sp.gov.br', 'admin123');

      final isLogged = container.read(authStateProvider);
      expect(isLogged, isTrue,
          reason: 'Estado global deve ser true após login mockado');
    });

    test('Deve lançar exceção e manter estado falso se login falhar', () async {
      await expectLater(
        () async => await controller.login('email@errado.com', 'senhaerrada'),
        throwsA(isA<Exception>()),
        reason: 'Login com credenciais incorretas deve falhar',
      );

      final isLogged = container.read(authStateProvider);
      expect(isLogged, isFalse,
          reason: 'Estado global deve permanecer falso após falha');
    });
  });
}
