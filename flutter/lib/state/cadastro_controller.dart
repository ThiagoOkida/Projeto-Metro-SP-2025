// flutter/lib/state/cadastro_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 1. O Estado (igual ao que tínhamos) ---
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
  // Se precisar ler outros providers (como o AuthRepository),
  // você pode recebê-lo no construtor.
  // final AuthRepository _authRepository;

  CadastroController(this.ref) : super(CadastroState()); // , this._authRepository

  final Ref ref;

  Future<void> cadastrar(
      String nome, String email, String password, String confirmPassword) async {
    // 1. Validação simples
    if (password != confirmPassword) {
      state = state.copyWith(
        status: CadastroStatus.error,
        errorMessage: 'As senhas não conferem',
      );
      // Reseta o estado para idle para o usuário poder tentar de novo
      _resetErrorState();
      return;
    }

    // 2. Inicia o loading
    state = state.copyWith(status: CadastroStatus.loading);

    try {
      // 3. Chamar o repositório (descomente quando tiver)
      // await _authRepository.cadastrar(nome, email, password);

      // Simulação de sucesso (REMOVA ISSO QUANDO CONECTAR O REPO)
      await Future.delayed(const Duration(seconds: 2));

      // 4. Sucesso
      state = state.copyWith(status: CadastroStatus.success);
    } catch (e) {
      // 5. Erro
      state = state.copyWith(
        status: CadastroStatus.error,
        errorMessage: e.toString(),
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
  // Ex: final authRepo = ref.watch(authRepositoryProvider);
  // return CadastroController(ref, authRepo);
  return CadastroController(ref);
});