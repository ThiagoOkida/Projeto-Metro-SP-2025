import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart';

class LoginController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LoginController(this.ref) : super(const AsyncValue.data(null));

  /// Efetua o login e atualiza o estado global de autenticação.
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final token =
          await ref.read(authRepositoryProvider).login(email, password);

      // Salva o token localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Atualiza o estado global
      ref.read(authStateProvider.notifier).state = true;

      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Mantém o erro no estado para ser detectado pelos testes
      state = AsyncValue.error(e, st);

      // ⚠️ NÃO rethrow! Permite que o SnackBar apareça no teste de widget.
      ref.read(authStateProvider.notifier).state = false;
    }
  }

  /// Efetua logout, limpa o token salvo e redefine o estado global.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    ref.read(authStateProvider.notifier).state = false;
    state = const AsyncValue.data(null);
  }
}

/// Provider para o controlador de login.
/// Usado para acessar o controlador a partir das telas.
final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>(
  (ref) => LoginController(ref),
);
