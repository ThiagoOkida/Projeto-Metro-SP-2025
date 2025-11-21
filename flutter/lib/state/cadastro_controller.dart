// flutter/lib/state/cadastro_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth.dart';

// --- 1. O Estado ---
enum CadastroStatus { idle, loading, success, error }

class CadastroState {
  final CadastroStatus status;
  final String? errorMessage;

  CadastroState({this.status = CadastroStatus.idle, this.errorMessage});

  CadastroState copyWith({CadastroStatus? status, String? errorMessage}) {
    return CadastroState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// --- 2. O Notifier (O Controller) ---
class CadastroController extends StateNotifier<CadastroState> {
  CadastroController(this.ref) : super(CadastroState());

  final Ref ref;

  Future<void> cadastrar(
      String nome, String email, String password, String confirmPassword) async {
    // 1. Validação de senhas
    if (password != confirmPassword) {
      state = state.copyWith(
        status: CadastroStatus.error,
        errorMessage: 'As senhas não conferem',
      );
      _resetErrorState();
      return;
    }

    // 2. Validação de senha mínima
    if (password.length < 6) {
      state = state.copyWith(
        status: CadastroStatus.error,
        errorMessage: 'A senha deve ter pelo menos 6 caracteres',
      );
      _resetErrorState();
      return;
    }

    // 3. Inicia o loading
    state = state.copyWith(status: CadastroStatus.loading);

    try {
      // 4. Cria a conta no Firebase Auth
      final authRepo = ref.read(authRepositoryProvider);
      final userCredential = await authRepo.cadastrar(email, password);

      // 5. Salva os dados do usuário no Firestore
      if (userCredential.user != null) {
        await authRepo.salvarUsuarioNoFirestore(
          userCredential.user!.uid,
          nome,
          email,
        );
      }

      // 6. Sucesso
      state = state.copyWith(status: CadastroStatus.success);
    } catch (e) {
      // 7. Erro
      String errorMessage = 'Erro ao cadastrar';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Este email já está em uso';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'A senha é muito fraca';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Email inválido';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      state = state.copyWith(
        status: CadastroStatus.error,
        errorMessage: errorMessage,
      );
      _resetErrorState();
    }
  }

  // Helper para limpar a mensagem de erro da tela
  void _resetErrorState() {
    Future.delayed(const Duration(seconds: 3), () {
      if (state.status == CadastroStatus.error) {
        state = state.copyWith(status: CadastroStatus.idle, errorMessage: null);
      }
    });
  }
}

// --- 3. O Provedor (O que a UI vai consumir) ---
final cadastroControllerProvider =
    StateNotifierProvider<CadastroController, CadastroState>((ref) {
  return CadastroController(ref);
});