import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spss_flutter/pages/login_page.dart';
import 'package:spss_flutter/state/auth.dart';
import 'package:spss_flutter/state/login_controller.dart';

/// Mock simplificado do AuthRepository
class MockAuthRepository extends AuthRepository {
  MockAuthRepository({this.shouldSucceed = true}) : super(baseUrl: 'mock://api');

  final bool shouldSucceed;

  @override
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldSucceed &&
        email == 'admin@metro.sp.gov.br' &&
        password == 'admin123') {
      return 'mock-token';
    } else {
      throw Exception('Falha no login');
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 Testes de Widget - LoginPage', () {
    testWidgets('Mostra loading e executa login com sucesso', (tester) async {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Insere credenciais corretas
      await tester.enterText(
          find.byType(TextFormField).at(0), 'admin@metro.sp.gov.br');
      await tester.enterText(find.byType(TextFormField).at(1), 'admin123');

      // Clica em "Entrar"
      await tester.tap(find.text('Entrar'));
      await tester.pump(const Duration(milliseconds: 200)); // mostra o loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Aguarda o processamento simulado
      await tester.pump(const Duration(seconds: 1));

      // O loginState deve indicar sucesso (sem erro)
      final loginState = container.read(loginControllerProvider);
      expect(loginState.hasError, isFalse);
    });

    testWidgets('Exibe SnackBar ao falhar o login', (tester) async {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider
            .overrideWithValue(MockAuthRepository(shouldSucceed: false)),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      // Credenciais inválidas
      await tester.enterText(find.byType(TextFormField).at(0), 'erro@teste.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaerrada');

      await tester.tap(find.text('Entrar'));
      await tester.pump(const Duration(seconds: 1)); // tempo para exibir snackbar

      // Verifica se o SnackBar apareceu
      expect(find.text('Falha no login'), findsOneWidget);
    });
  });
}
