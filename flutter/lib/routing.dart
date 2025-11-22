import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/materiais_page.dart';
import 'pages/instrumentos_page.dart';
import 'pages/relatorios_page.dart';
import 'pages/alertas_page.dart';
import 'pages/usuarios_page.dart';
import 'pages/configuracoes_page.dart';
import 'shell/shell_scaffold.dart';
import 'pages/cadastro_page.dart';
import 'state/auth.dart';

/// Provider para o router que precisa acessar o estado de autenticação
final routerProvider = Provider<GoRouter>((ref) {
  // Observa o estado de autenticação para recriar o router quando necessário
  final authState = ref.watch(authStateProvider);
  
  // Cria o router - será recriado quando authState mudar, mas isso é necessário
  // para que o redirect funcione corretamente
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Aguarda o estado carregar (evita redirecionamentos durante inicialização)
      if (authState.isLoading) {
        return null; // Não redireciona enquanto carrega
      }

      // Trata erros do authStateProvider
      if (authState.hasError) {
        // Se houver erro, permite acesso à tela de login
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToCadastro = state.matchedLocation == '/cadastro';
        if (!isGoingToLogin && !isGoingToCadastro) {
          return '/login';
        }
        return null;
      }

      final isLoggedIn = authState.asData?.value != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToCadastro = state.matchedLocation == '/cadastro';

      // Se não está logado e não está indo para login ou cadastro, redireciona para login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToCadastro) {
        return '/login';
      }

      // Se está logado e está tentando acessar login ou cadastro, redireciona para dashboard
      if (isLoggedIn && (isGoingToLogin || isGoingToCadastro)) {
        return '/';
      }

      // A verificação de permissão para /usuarios é feita na própria página
      // para ter feedback visual melhor (mensagem de acesso negado)

      return null; // Não redireciona
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),

      // Rota de cadastro adicionada aqui, fora do ShellRoute
      GoRoute(
        path: '/cadastro',
        builder: (context, state) => const CadastroPage(),
      ),

      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
          GoRoute(
              path: '/materiais', builder: (_, __) => const MateriaisPage()),
          GoRoute(
              path: '/instrumentos',
              builder: (_, __) => const InstrumentosPage()),
          GoRoute(
              path: '/relatorios', builder: (_, __) => const RelatoriosPage()),
          GoRoute(path: '/alertas', builder: (_, __) => const AlertasPage()),
          GoRoute(path: '/usuarios', builder: (_, __) => const UsuariosPage()),
          GoRoute(
              path: '/configuracoes',
              builder: (_, __) => const ConfiguracoesPage()),
        ],
      ),
    ],
  );

  return router;
});

// Router legado removido - usar routerProvider ao invés disso
