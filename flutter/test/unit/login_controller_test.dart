import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spss_flutter/state/auth.dart';
import 'package:spss_flutter/state/login_controller.dart';

/// Mock UserCredential simples para testes
class _MockUserCredential implements UserCredential {
  @override
  final User? user;

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  AuthCredential? get credential => null;

  _MockUserCredential({
    this.user,
  });
}

/// Mock User simples para testes
class _MockUser implements User {
  @override
  final String uid;

  @override
  final String? email;

  _MockUser({required this.uid, this.email});

  // Implementações mínimas necessárias
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async =>
      'mock-token-123';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock que simula o AuthRepository sem Firebase real
class MockAuthRepository extends AuthRepository {
  final bool shouldSucceed;

  MockAuthRepository({this.shouldSucceed = true});

  @override
  Future<UserCredential> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldSucceed &&
        email == 'admin@metro.sp.gov.br' &&
        password == 'admin123') {
      final mockUser = _MockUser(uid: 'mock-uid-123', email: email);
      return _MockUserCredential(user: mockUser);
    } else {
      throw Exception('Credenciais inválidas (mock)');
    }
  }

  @override
  Future<void> logout() async {
    // Mock implementation
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
