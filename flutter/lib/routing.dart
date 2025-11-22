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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (authState.isLoading) {
        return null; 
      }
      if (authState.hasError) {
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

      if (!isLoggedIn && !isGoingToLogin && !isGoingToCadastro) {
        return '/login';
      }
      if (isLoggedIn && (isGoingToLogin || isGoingToCadastro)) {
        return '/';
      }
      return null; 
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
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

