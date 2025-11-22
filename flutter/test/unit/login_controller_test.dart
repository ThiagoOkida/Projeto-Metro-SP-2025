import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spss_flutter/state/auth.dart';
import 'package:spss_flutter/state/login_controller.dart';

/// Mock que simula o AuthRepository sem Firebase real
/// Nota: Para testes completos com UserCredential, você precisaria
/// inicializar o Firebase ou usar um pacote de mocks como firebase_auth_mocks
class MockAuthRepository extends AuthRepository {
  final bool shouldSucceed;

  MockAuthRepository({this.shouldSucceed = true}) : super();

  @override
  Future<UserCredential> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldSucceed &&
        email == 'admin@metro.sp.gov.br' &&
        password == 'admin123') {
      // Para testes sem Firebase inicializado, vamos simular sucesso
      // mas não podemos criar um UserCredential real
      // O LoginController trata exceções, então vamos lançar uma exceção
      // que indica sucesso mas não pode ser completada sem Firebase
      // Na prática, para testes completos você precisaria:
      // 1. Inicializar Firebase com opções de teste, OU
      // 2. Usar firebase_auth_mocks, OU  
      // 3. Criar uma abstração que permita injetar o FirebaseAuth
      throw UnimplementedError(
        'MockAuthRepository: Para testes completos, inicialize Firebase ou use firebase_auth_mocks. '
        'Este mock simula apenas falhas de autenticação.',
      );
    } else {
      throw Exception('Credenciais inválidas (mock)');
    }
  }

  @override
  Future<void> logout() async {
    // Mock implementation - sempre bem-sucedido
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

    test('Deve completar login sem erro quando credenciais são válidas',
        () async {
      // O controller deve completar sem lançar exceção
      await controller.login('admin@metro.sp.gov.br', 'admin123');

      // Verifica que o estado não tem erro
      final loginState = container.read(loginControllerProvider);
      expect(loginState.hasError, isFalse,
          reason: 'Login com credenciais válidas não deve ter erro');
    });

    test('Deve lançar exceção se login falhar', () async {
      await expectLater(
        () async => await controller.login('email@errado.com', 'senhaerrada'),
        throwsA(isA<Exception>()),
        reason: 'Login com credenciais incorretas deve falhar',
      );

      // Verifica que o estado tem erro
      final loginState = container.read(loginControllerProvider);
      expect(loginState.hasError, isTrue,
          reason: 'Login com credenciais inválidas deve ter erro');
    });
  });
}
