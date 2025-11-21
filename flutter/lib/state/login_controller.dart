import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth.dart';

class LoginController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LoginController(this.ref) : super(const AsyncValue.data(null));

  /// Efetua o login usando Firebase Auth e atualiza o estado global de autenticação.
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).login(email, password);
      
      // O estado de autenticação é gerenciado automaticamente pelo StreamProvider
      // authStateProvider que observa as mudanças do Firebase Auth
      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Mantém o erro no estado para ser detectado pelos testes
      state = AsyncValue.error(e, st);
      
      // ⚠️ NÃO rethrow! Permite que o SnackBar apareça no teste de widget.
    }
  }

  /// Efetua logout usando Firebase Auth.
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider para o controlador de login.
/// Usado para acessar o controlador a partir das telas.
final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>(
  (ref) => LoginController(ref),
);
